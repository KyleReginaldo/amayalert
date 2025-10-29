import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class ChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EnhancedMessageRepository>(),
      child: this,
    );
  }
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // Unsubscribe from conversation channel when leaving chat screen
    try {
      final repository = context.read<EnhancedMessageRepository>();
      repository.unsubscribeFromConversation();
    } catch (_) {}

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Mark messages as seen when app becomes active/visible
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsSeen();
    }
  }

  void _markMessagesAsSeen() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null && mounted) {
      context.read<EnhancedMessageRepository>().markMessagesAsSeen(
        userId: currentUser.id,
        otherUserId: widget.otherUserId,
      );
    }
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = _messageController.text.trim().isNotEmpty;
    });
  }

  void _loadMessages() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final repository = context.read<EnhancedMessageRepository>();

        // Load conversation messages
        repository.loadConversation(
          userId1: currentUser.id,
          userId2: widget.otherUserId,
        );

        // Mark messages as seen from this user
        repository.markMessagesAsSeen(
          userId: currentUser.id,
          otherUserId: widget.otherUserId,
        );

        // Subscribe to real-time updates
        repository.subscribeToConversation(
          userId1: currentUser.id,
          userId2: widget.otherUserId,
        );
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final messageRepository = context.read<EnhancedMessageRepository>();

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    final request = CreateMessageRequest(
      receiver: widget.otherUserId,
      content: content,
    );

    final result = await messageRepository.sendMessage(
      senderId: currentUser.id,
      request: request,
    );

    if (result.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      _messageController.text = content;
      setState(() {
        _isComposing = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EnhancedMessageRepository>(),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: widget.otherUserName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const CustomText(
                text: 'Online',
                fontSize: 12,
                color: Colors.green,
              ),
            ],
          ),
        ),
        body: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            children: [
              Expanded(
                child: Consumer<EnhancedMessageRepository>(
                  builder: (context, messageRepository, child) {
                    if (messageRepository.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (messageRepository.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              text: 'Error loading messages',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            CustomText(
                              text: messageRepository.errorMessage!,
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                messageRepository.clearError();
                                _loadMessages();
                              },
                              child: const CustomText(text: 'Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages =
                        messageRepository.currentConversationMessages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.messageSquare,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              text: 'No messages yet',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            CustomText(
                              text: 'Start the conversation!',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = messages.length - 1 - index;
                        final message = messages[reversedIndex];
                        final currentUser =
                            Supabase.instance.client.auth.currentUser;
                        final isMe = message.sender == currentUser?.id;

                        return MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                ),
              ),
              MessageInput(
                controller: _messageController,
                isComposing: _isComposing,
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(LucideIcons.user, size: 16, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: message.content,
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: timeago.format(message.createdAt),
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isSeen
                              ? LucideIcons.checkCheck
                              : LucideIcons.check,
                          size: 14,
                          color: message.isSeen
                              ? Colors.blue.shade200
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(LucideIcons.user, size: 16, color: Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isComposing;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isComposing,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: isComposing ? onSend : null,
                icon: Icon(
                  LucideIcons.send,
                  color: isComposing ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
