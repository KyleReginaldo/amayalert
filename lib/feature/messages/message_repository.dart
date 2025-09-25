import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:amayalert/feature/messages/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageRepository extends ChangeNotifier {
  final MessageProvider _messageProvider;

  MessageRepository({MessageProvider? provider})
    : _messageProvider = provider ?? MessageProvider();

  List<ChatConversation> _conversations = [];
  List<Message> _currentConversationMessages = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _conversationSubscription;
  RealtimeChannel? _userMessagesSubscription;
  String? _currentConversationPartnerId;

  List<ChatConversation> get conversations => _conversations;
  List<Message> get currentConversationMessages => _currentConversationMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentConversationPartnerId => _currentConversationPartnerId;

  Future<Result<String>> sendMessage({
    required String senderId,
    required CreateMessageRequest request,
    XFile? attachmentFile,
  }) async {
    _setLoading(true);

    final result = await _messageProvider.sendMessage(
      senderId: senderId,
      request: request,
      attachmentFile: attachmentFile,
    );

    if (result.isSuccess) {
      // Refresh conversations and current conversation
      await loadConversations(senderId);
      if (_currentConversationPartnerId != null) {
        await loadConversation(
          userId1: senderId,
          userId2: _currentConversationPartnerId!,
        );
      }
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }

    _setLoading(false);
    return result;
  }

  Future<void> loadConversations(String userId) async {
    _setLoading(true);

    final result = await _messageProvider.getUserConversations(userId: userId);

    if (result.isSuccess) {
      _conversations = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
  }

  Future<void> loadConversation({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    _setLoading(true);
    _currentConversationPartnerId = userId2;

    final result = await _messageProvider.getConversation(
      userId1: userId1,
      userId2: userId2,
      limit: limit,
    );

    if (result.isSuccess) {
      _currentConversationMessages = result.value.reversed
          .toList(); // Reverse to show oldest first
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
  }

  Future<Result<String>> updateMessage({
    required int messageId,
    required String senderId,
    required UpdateMessageRequest request,
  }) async {
    _setLoading(true);

    final result = await _messageProvider.updateMessage(
      messageId: messageId,
      senderId: senderId,
      request: request,
    );

    if (result.isSuccess) {
      // Update local message list
      final index = _currentConversationMessages.indexWhere(
        (msg) => msg.id == messageId,
      );
      if (index != -1) {
        // You would need to refetch or update the message locally
        await loadConversation(
          userId1: senderId,
          userId2: _currentConversationPartnerId!,
        );
      }
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }

    _setLoading(false);
    return result;
  }

  Future<Result<String>> deleteMessage({
    required int messageId,
    required String senderId,
  }) async {
    _setLoading(true);

    final result = await _messageProvider.deleteMessage(
      messageId: messageId,
      senderId: senderId,
    );

    if (result.isSuccess) {
      // Remove message from local list
      _currentConversationMessages.removeWhere((msg) => msg.id == messageId);
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
    return result;
  }

  void subscribeToConversation({
    required String userId1,
    required String userId2,
  }) {
    _conversationSubscription = _messageProvider.subscribeToConversation(
      userId1: userId1,
      userId2: userId2,
      onNewMessage: (message) {
        // Add new message to current conversation
        if (_currentConversationPartnerId == userId2 ||
            _currentConversationPartnerId == userId1) {
          _currentConversationMessages.add(message);
          notifyListeners();
        }
      },
      onMessageUpdated: (message) {
        // Update message in current conversation
        final index = _currentConversationMessages.indexWhere(
          (msg) => msg.id == message.id,
        );
        if (index != -1) {
          _currentConversationMessages[index] = message;
          notifyListeners();
        }
      },
      onMessageDeleted: (messageId) {
        // Remove message from current conversation
        _currentConversationMessages.removeWhere((msg) => msg.id == messageId);
        notifyListeners();
      },
    );
  }

  void subscribeToUserMessages(String userId) {
    _userMessagesSubscription = _messageProvider.subscribeToUserMessages(
      userId: userId,
      onNewMessage: (message) {
        // Update conversation list when new message received
        loadConversations(userId);
      },
    );
  }

  void unsubscribeFromConversation() {
    _conversationSubscription?.unsubscribe();
    _conversationSubscription = null;
  }

  void unsubscribeFromUserMessages() {
    _userMessagesSubscription?.unsubscribe();
    _userMessagesSubscription = null;
  }

  void clearCurrentConversation() {
    _currentConversationMessages.clear();
    _currentConversationPartnerId = null;
    unsubscribeFromConversation();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromConversation();
    unsubscribeFromUserMessages();
    super.dispose();
  }
}
