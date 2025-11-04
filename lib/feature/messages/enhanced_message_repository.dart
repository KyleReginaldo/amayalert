import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/core/services/badge_service.dart';
import 'package:amayalert/feature/messages/enhanced_message_provider.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enhanced message repository with comprehensive messaging features
class EnhancedMessageRepository extends ChangeNotifier {
  final EnhancedMessageProvider _provider;
  final String? Function()? _currentUserIdGetter;

  EnhancedMessageRepository({
    EnhancedMessageProvider? provider,
    String? Function()? currentUserIdGetter,
  }) : _provider = provider ?? EnhancedMessageProvider(),
       _currentUserIdGetter =
           currentUserIdGetter ??
           (() => Supabase.instance.client.auth.currentUser?.id);

  // State management
  List<ChatConversation> _conversations = [];
  List<Message> _currentConversationMessages = [];
  // optimistic upload placeholders (temp negative ids -> local path)
  final Map<int, String> _uploadPlaceholders = {};
  final Set<int> _failedUploads = {};

  // Expose read-only views for UI
  Map<int, String> get uploadPlaceholders =>
      Map.unmodifiable(_uploadPlaceholders);
  Set<int> get failedUploads => Set.unmodifiable(_failedUploads);
  List<MessageUser> _availableUsers = [];
  List<MessageSearchResult> _searchResults = [];
  final Map<String, TypingIndicator> _typingIndicators = {};

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  String? _errorMessage;
  String? _currentConversationPartnerId;

  RealtimeChannel? _conversationSubscription;
  RealtimeChannel? _userMessagesSubscription;

  // Getters
  List<ChatConversation> get conversations => _conversations;
  List<Message> get currentConversationMessages => _currentConversationMessages;
  List<MessageUser> get availableUsers => _availableUsers;
  List<MessageSearchResult> get searchResults => _searchResults;
  Map<String, TypingIndicator> get typingIndicators => _typingIndicators;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreMessages => _hasMoreMessages;
  String? get errorMessage => _errorMessage;
  String? get currentConversationPartnerId => _currentConversationPartnerId;

  /// Send message with enhanced features
  Future<Result<Message>> sendMessage({
    required String senderId,
    required CreateMessageRequest request,
    XFile? attachmentFile,
    void Function(double progress)? onUploadProgress,
  }) async {
    final result = await _provider.sendMessage(
      senderId: senderId,
      request: request,
      attachmentFile: attachmentFile,
      onUploadProgress: onUploadProgress,
    );

    if (result.isSuccess) {
      // Add message to current conversation if it involves the current partner
      try {
        _maybeAddMessageToCurrentConversation(result.value);
      } catch (e, st) {
        debugPrint(
          '⚠️ Error adding sent message to current conversation: $e\n$st',
        );
      }

      // Update conversations list locally (avoid reloading from network)
      try {
        _applyMessageToConversations(result.value);
      } catch (e, st) {
        debugPrint(
          '⚠️ Error updating conversations locally after send: $e\n$st',
        );
      }

      // Send push notification to the receiver (fire-and-forget to avoid blocking UI/tests)
    } else {
      _setResultError(result, 'Failed to send message');
    }

    return result;
  }

  /// Create an optimistic placeholder for an uploading attachment.
  /// Returns the temporary negative id assigned.
  int createUploadPlaceholder({
    required String localPath,
    required String senderId,
    required String receiverId,
  }) {
    final tempId = -DateTime.now().microsecondsSinceEpoch;
    final placeholder = Message(
      id: tempId,
      sender: senderId,
      receiver: receiverId,
      content: '',
      attachmentUrl: localPath,
      createdAt: DateTime.now(),
      updatedAt: null,
      seenAt: null,
    );

    _currentConversationMessages.add(placeholder);
    _applyMessageToConversations(placeholder);
    _uploadPlaceholders[tempId] = localPath;
    notifyListeners();
    return tempId;
  }

  /// Replace an optimistic placeholder (tempId) with the real message from server
  void replacePlaceholderWithReal({
    required int tempId,
    required Message realMessage,
  }) {
    final indexTemp = _currentConversationMessages.indexWhere(
      (m) => m.id == tempId,
    );
    final indexReal = _currentConversationMessages.indexWhere(
      (m) => m.id == realMessage.id,
    );

    if (indexTemp != -1) {
      if (indexReal != -1) {
        // Real message already present (realtime arrived first). Remove placeholder.
        _currentConversationMessages.removeAt(indexTemp);
        // ensure ordering: move real message to most recent if needed
        final real = _currentConversationMessages.removeAt(
          indexReal > indexTemp ? indexReal - 1 : indexReal,
        );
        _currentConversationMessages.add(real);
      } else {
        // Replace placeholder with real message
        _currentConversationMessages[indexTemp] = realMessage;
      }
    } else {
      // No placeholder found. If real isn't present, add; otherwise nothing to do.
      if (indexReal == -1) {
        _currentConversationMessages.add(realMessage);
      }
    }

    _uploadPlaceholders.remove(tempId);
    _failedUploads.remove(tempId);
    _applyMessageToConversations(realMessage);
    notifyListeners();
  }

  /// Mark a placeholder upload as failed so UI can show retry
  void markPlaceholderFailed(int tempId) {
    _failedUploads.add(tempId);
    notifyListeners();
  }

  /// Retry sending an attachment for a failed placeholder
  Future<void> retryUpload({
    required int tempId,
    required String senderId,
    required XFile file,
  }) async {
    final localPath = _uploadPlaceholders[tempId];
    if (localPath == null) return;

    // create request with empty content but attachment (provider handles upload)
    final receiverId = _currentConversationPartnerId ?? '';
    final request = CreateMessageRequest(receiver: receiverId, content: '');

    final result = await sendMessage(
      senderId: senderId,
      request: request,
      attachmentFile: file,
      onUploadProgress: (p) {},
    );

    if (result.isSuccess) {
      replacePlaceholderWithReal(tempId: tempId, realMessage: result.value);
    } else {
      markPlaceholderFailed(tempId);
    }
  }

  /// Load conversations with enhanced user info
  Future<void> loadConversations(String userId) async {
    _setLoading(true);

    final result = await _provider.getUserConversations(userId: userId);

    if (result.isSuccess) {
      _conversations = result.value;
      _clearError();

      // Update badge count
      _updateBadgeCount();
    } else {
      _setResultError(result, 'Failed to load conversations');
    }

    _setLoading(false);
  }

  /// Update the badge service with total unread count
  void _updateBadgeCount() {
    final totalUnread = _conversations.fold<int>(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
    BadgeService().updateUnreadMessageCount(totalUnread);
  }

  /// Load conversation messages with pagination
  Future<void> loadConversation({
    required String userId1,
    required String userId2,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMoreMessages) return;
      _setLoadingMore(true);
    } else {
      _setLoading(true);
      _currentConversationPartnerId = userId2;
      _currentConversationMessages.clear();
      _hasMoreMessages = true;
    }

    final offset = loadMore ? _currentConversationMessages.length : 0;
    final result = await _provider.getConversation(
      userId1: userId1,
      userId2: userId2,
      limit: 50,
      offset: offset,
    );

    if (result.isSuccess) {
      final newMessages = result.value;

      if (loadMore) {
        _currentConversationMessages.addAll(newMessages.reversed);
      } else {
        _currentConversationMessages = newMessages.reversed.toList();

        // Mark messages as seen when initially loading conversation (not when loading more)
        // Note: This will be silent if seen_at column doesn't exist
        markMessagesAsSeen(userId: userId1, otherUserId: userId2);
      }

      _hasMoreMessages = newMessages.length == 50;
      _clearError();
    } else {
      _setResultError(result, 'Failed to load conversation');
    }

    if (loadMore) {
      _setLoadingMore(false);
    } else {
      _setLoading(false);
    }
  }

  /// Search messages
  Future<void> searchMessages({
    required String userId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _setLoading(true);

    final result = await _provider.searchMessages(userId: userId, query: query);

    if (result.isSuccess) {
      _searchResults = result.value;
      _clearError();
    } else {
      _setResultError(result, 'Failed to search messages');
    }

    _setLoading(false);
  }

  /// Load available users for new conversations
  Future<void> loadAvailableUsers({
    required String currentUserId,
    String? searchQuery,
  }) async {
    _setLoading(true);

    final result = await _provider.getAvailableUsers(
      currentUserId: currentUserId,
      searchQuery: searchQuery,
    );

    if (result.isSuccess) {
      _availableUsers = result.value;
      _clearError();
    } else {
      _setResultError(result, 'Failed to load users');
    }

    _setLoading(false);
  }

  /// Update message
  Future<Result<Message>> updateMessage({
    required int messageId,
    required String senderId,
    required UpdateMessageRequest request,
  }) async {
    final result = await _provider.updateMessage(
      messageId: messageId,
      senderId: senderId,
      request: request,
    );

    if (result.isSuccess) {
      // Update message in current conversation
      final index = _currentConversationMessages.indexWhere(
        (msg) => msg.id == messageId,
      );
      if (index != -1) {
        _currentConversationMessages[index] = result.value;
        notifyListeners();
      }
    } else {
      _setResultError(result, 'Failed to update message');
    }

    return result;
  }

  /// Delete message
  Future<Result<void>> deleteMessage({
    required int messageId,
    required String senderId,
  }) async {
    final result = await _provider.deleteMessage(
      messageId: messageId,
      senderId: senderId,
    );

    if (result.isSuccess) {
      // Remove from current conversation
      _currentConversationMessages.removeWhere((msg) => msg.id == messageId);
      notifyListeners();
    } else {
      _setResultError(result, 'Failed to delete message');
    }

    return result;
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String userId,
    required List<int> messageIds,
  }) async {
    await _provider.markMessagesAsRead(userId: userId, messageIds: messageIds);
  }

  /// Subscribe to conversation updates
  void subscribeToConversation({
    required String userId1,
    required String userId2,
  }) {
    unsubscribeFromConversation();

    _conversationSubscription = _provider.subscribeToConversation(
      userId1: userId1,
      userId2: userId2,
      onNewMessage: _handleNewMessage,
      onMessageUpdated: _handleMessageUpdated,
      onMessageDeleted: _handleMessageDeleted,
    );
  }

  /// Subscribe to user messages
  void subscribeToUserMessages(String userId) {
    unsubscribeFromUserMessages();

    _userMessagesSubscription = _provider.subscribeToUserMessages(
      userId: userId,
      onNewMessage: (message) {
        // Defensive logging + update conversations locally for incoming message (avoid heavy reload)
        try {
          debugPrint(
            '📥 Incoming message (subscribe): id=${message.id} sender=${message.sender} receiver=${message.receiver} createdAt=${message.createdAt}',
          );
          _applyMessageToConversations(message);

          // If the conversation is open, also add to current messages (avoids separate reload)
          try {
            if (_messageBelongsToOpenConversation(message)) {
              _maybeAddMessageToCurrentConversation(message);
            }
          } catch (e, st) {
            debugPrint(
              '⚠️ Error adding incoming message to open conversation: $e\n$st',
            );
          }
        } catch (e, st) {
          debugPrint(
            '⚠️ Error applying incoming message to conversations: $e\n$st',
          );
        }
      },
    );
  }

  /// Handle new message from real-time subscription
  void _handleNewMessage(Message message) {
    try {
      debugPrint(
        '📥 Realtime new message handler: id=${message.id} sender=${message.sender} receiver=${message.receiver} createdAt=${message.createdAt}',
      );
      // Ensure this message belongs to the currently open conversation (both participants match)
      if (_messageBelongsToOpenConversation(message)) {
        // Avoid duplicates: if message with same id exists, update it instead
        final existingIndex = _currentConversationMessages.indexWhere(
          (m) => m.id == message.id,
        );
        if (existingIndex != -1) {
          _currentConversationMessages[existingIndex] = message;
        } else {
          _currentConversationMessages.add(message);
        }

        // Auto-mark as seen if the current user is the receiver
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        if (currentUserId != null && message.receiver == currentUserId) {
          // Best-effort; don't throw if it fails
          try {
            markMessageAsSeen(messageId: message.id, userId: currentUserId);
          } catch (e, st) {
            debugPrint('⚠️ Error auto-marking message as seen: $e\n$st');
          }
        }

        debugPrint(
          'ℹ️ Message applied to open conversation: id=${message.id} existingIndex=$existingIndex currentMessages=${_currentConversationMessages.length}',
        );
        notifyListeners();
      }
    } catch (e, st) {
      debugPrint('⚠️ Error handling incoming message: $e\n$st');
    }
  }

  /// Helper to get current authenticated user id (or null)
  String? _currentUserId() =>
      _currentUserIdGetter?.call() ??
      Supabase.instance.client.auth.currentUser?.id;

  /// Public accessor for current user id (uses injected getter if provided)
  String? get currentUserId => _currentUserId();

  /// Returns true when the message involves both the current user and the open conversation partner
  bool _messageBelongsToOpenConversation(Message message) {
    final partner = _currentConversationPartnerId;
    final me = _currentUserId();
    if (partner == null || me == null) return false;
    return (message.sender == partner && message.receiver == me) ||
        (message.receiver == partner && message.sender == me);
  }

  /// Add message to current conversation if it belongs to it
  void _maybeAddMessageToCurrentConversation(Message message) {
    if (_messageBelongsToOpenConversation(message)) {
      // If message already exists (e.g., local add then realtime echo), replace it instead of duplicating
      final existingIndex = _currentConversationMessages.indexWhere(
        (m) => m.id == message.id,
      );
      if (existingIndex != -1) {
        _currentConversationMessages[existingIndex] = message;
      } else {
        _currentConversationMessages.add(message);
      }
      notifyListeners();
    }
  }

  /// Apply a message to the conversations list (update lastMessage, unread count, badge)
  void _applyMessageToConversations(Message message) {
    final me = _currentUserId();
    if (me == null) return;

    // determine the partner id (the other participant)
    final partnerId = message.sender == me ? message.receiver : message.sender;

    final idx = _conversations.indexWhere((c) => c.participantId == partnerId);
    final isIncomingToMe = message.receiver == me && message.seenAt == null;

    if (idx != -1) {
      final old = _conversations[idx];
      final updated = ChatConversation(
        participantId: old.participantId,
        participantName: old.participantName,
        participantProfilePicture: old.participantProfilePicture,
        participantEmail: old.participantEmail,
        isOnline: old.isOnline,
        lastSeen: old.lastSeen,
        lastMessage: message,
        unreadCount: old.unreadCount + (isIncomingToMe ? 1 : 0),
        lastActivity: message.createdAt,
        type: old.type,
      );

      _conversations[idx] = updated;
    } else {
      // create a minimal conversation entry
      final newConv = ChatConversation(
        participantId: partnerId,
        participantName: partnerId,
        participantProfilePicture: null,
        participantEmail: null,
        isOnline: false,
        lastSeen: null,
        lastMessage: message,
        unreadCount: isIncomingToMe ? 1 : 0,
        lastActivity: message.createdAt,
        type: ConversationType.direct,
      );
      _conversations.insert(0, newConv);
    }

    // update app badge and notify
    _updateBadgeCount();
    notifyListeners();
  }

  /// Handle message update from real-time subscription
  void _handleMessageUpdated(Message message) {
    final index = _currentConversationMessages.indexWhere(
      (msg) => msg.id == message.id,
    );
    if (index != -1) {
      _currentConversationMessages[index] = message;
      notifyListeners();
    }
  }

  /// Handle message deletion from real-time subscription
  void _handleMessageDeleted(int messageId) {
    _currentConversationMessages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  /// Add typing indicator
  void addTypingIndicator(String userId, String conversationId) {
    _typingIndicators[userId] = TypingIndicator(
      userId: userId,
      conversationId: conversationId,
      timestamp: DateTime.now(),
    );
    notifyListeners();

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _typingIndicators.remove(userId);
      notifyListeners();
    });
  }

  /// Get active typing users for conversation
  List<String> getTypingUsers(String conversationId) {
    return _typingIndicators.entries
        .where(
          (entry) =>
              entry.value.conversationId == conversationId &&
              entry.value.isActive,
        )
        .map((entry) => entry.key)
        .toList();
  }

  /// Unsubscribe methods
  void unsubscribeFromConversation() {
    _conversationSubscription?.unsubscribe();
    _conversationSubscription = null;
  }

  void unsubscribeFromUserMessages() {
    _userMessagesSubscription?.unsubscribe();
    _userMessagesSubscription = null;
  }

  /// Clear current conversation
  void clearCurrentConversation() {
    _currentConversationMessages.clear();
    _currentConversationPartnerId = null;
    _hasMoreMessages = true;
    unsubscribeFromConversation();
    notifyListeners();
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  /// State management helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setResultError(Result result, String defaultMessage) {
    final errorMessage = result.isError ? result.error : defaultMessage;
    _setError(errorMessage);
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Mark all messages from a specific user as seen
  Future<void> markMessagesAsSeen({
    required String userId,
    required String otherUserId,
  }) async {
    debugPrint(
      '📖 Attempting to mark messages as seen: $userId <- $otherUserId',
    );

    final result = await _provider.markMessagesAsSeen(
      userId: userId,
      otherUserId: otherUserId,
    );

    if (result.isSuccess) {
      debugPrint('✅ Messages marked as seen successfully');
      // Refresh conversations to update unread counts and badge
      await loadConversations(userId);
      // Refresh current conversation to show seen status
      if (_currentConversationPartnerId == otherUserId) {
        loadConversation(userId1: userId, userId2: otherUserId);
      }
    } else {
      debugPrint(
        '❌ Failed to mark messages as seen, but continuing gracefully',
      );
      // Don't set error since this is now handled gracefully in the provider
      // Still refresh conversations to update badge count
      await loadConversations(userId);
    }
  }

  /// Mark specific message as seen
  Future<void> markMessageAsSeen({
    required int messageId,
    required String userId,
  }) async {
    final result = await _provider.markMessageAsSeen(
      messageId: messageId,
      userId: userId,
    );

    if (result.isSuccess) {
      // Update local message if it exists
      final messageIndex = _currentConversationMessages.indexWhere(
        (message) => message.id == messageId,
      );
      if (messageIndex != -1) {
        final updatedMessage = Message(
          id: _currentConversationMessages[messageIndex].id,
          sender: _currentConversationMessages[messageIndex].sender,
          receiver: _currentConversationMessages[messageIndex].receiver,
          content: _currentConversationMessages[messageIndex].content,
          attachmentUrl:
              _currentConversationMessages[messageIndex].attachmentUrl,
          createdAt: _currentConversationMessages[messageIndex].createdAt,
          updatedAt: _currentConversationMessages[messageIndex].updatedAt,
          seenAt: DateTime.now(),
        );
        _currentConversationMessages[messageIndex] = updatedMessage;
        notifyListeners();
      }

      // Refresh conversations to update badge count
      await loadConversations(userId);
    } else {
      debugPrint(
        '❌ Failed to mark individual message as seen, but continuing gracefully',
      );
      // Don't set error since this is not critical - message functionality should continue
      // Still refresh conversations to update badge count
      await loadConversations(userId);
    }
  }

  @override
  void dispose() {
    unsubscribeFromConversation();
    unsubscribeFromUserMessages();
    super.dispose();
  }
}
