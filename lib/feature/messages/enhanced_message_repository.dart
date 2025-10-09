import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/core/services/badge_service.dart';
import 'package:amayalert/core/services/push_notification_service.dart';
import 'package:amayalert/feature/messages/enhanced_message_provider.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enhanced message repository with comprehensive messaging features
class EnhancedMessageRepository extends ChangeNotifier {
  final EnhancedMessageProvider _provider;

  EnhancedMessageRepository({EnhancedMessageProvider? provider})
    : _provider = provider ?? EnhancedMessageProvider();

  // State management
  List<ChatConversation> _conversations = [];
  List<Message> _currentConversationMessages = [];
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
  }) async {
    final result = await _provider.sendMessage(
      senderId: senderId,
      request: request,
      attachmentFile: attachmentFile,
    );

    if (result.isSuccess) {
      // Add message to current conversation if it matches
      if (_currentConversationPartnerId == request.receiver) {
        _currentConversationMessages.add(result.value);
        notifyListeners();
      }
      // Refresh conversations to update last message
      await loadConversations(senderId);

      // Send push notification to the receiver
      await _sendPushNotification(
        senderId: senderId,
        receiverId: request.receiver,
        messageContent: request.content,
        messageId: result.value.id.toString(),
      );
    } else {
      _setResultError(result, 'Failed to send message');
    }

    return result;
  }

  /// Send push notification when a message is sent
  Future<void> _sendPushNotification({
    required String senderId,
    required String receiverId,
    required String messageContent,
    required String messageId,
  }) async {
    try {
      // Get sender's name from Supabase
      final senderResponse = await Supabase.instance.client
          .from('users')
          .select('full_name')
          .eq('id', senderId)
          .single();

      final senderName = senderResponse['full_name'] ?? 'Someone';

      // Send push notification
      final success = await PushNotificationService.sendMessageNotification(
        receiverUserId: receiverId,
        senderName: senderName,
        messageContent: messageContent,
        additionalData: {
          'sender_id': senderId,
          'message_id': messageId,
          'conversation_id': '${senderId}_$receiverId',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (success) {
        debugPrint(
          '✅ Push notification sent successfully for message: $messageId',
        );
      } else {
        debugPrint(
          '❌ Failed to send push notification for message: $messageId',
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending push notification: $e');
      // Don't throw error as push notification failure shouldn't break message sending
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
        // Refresh conversations when new message received
        loadConversations(userId);
      },
    );
  }

  /// Handle new message from real-time subscription
  void _handleNewMessage(Message message) {
    // Add to current conversation if it matches
    if (_currentConversationPartnerId != null &&
        (message.sender == _currentConversationPartnerId ||
            message.receiver == _currentConversationPartnerId)) {
      _currentConversationMessages.add(message);

      // Auto-mark as seen if user is viewing the conversation and message is for them
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null &&
          message.receiver == currentUserId &&
          message.sender == _currentConversationPartnerId) {
        // Mark this specific message as seen
        markMessageAsSeen(messageId: message.id, userId: currentUserId);
      }

      notifyListeners();
    }
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
      _setResultError(result, 'Failed to mark message as seen');
    }
  }

  @override
  void dispose() {
    unsubscribeFromConversation();
    unsubscribeFromUserMessages();
    super.dispose();
  }
}
