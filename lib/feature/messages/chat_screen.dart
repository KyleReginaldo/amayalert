import 'dart:io';

import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhone;
  final ImagePicker? imagePicker;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhone,
    this.imagePicker,
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
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    debugPrint('ChatScreen initialized with phone: ${widget.otherUserPhone}');
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
    final repo = context.read<EnhancedMessageRepository>();
    final currentUserId = repo.currentUserId;
    if (currentUserId != null && mounted) {
      repo.markMessagesAsSeen(
        userId: currentUserId,
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
    final repo = context.read<EnhancedMessageRepository>();
    final currentUser = repo.currentUserId;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final repository = context.read<EnhancedMessageRepository>();

        // Load conversation messages

        try {
          repository.loadConversation(
            userId1: currentUser,
            userId2: widget.otherUserId,
          );

          // Mark messages as seen from this user
          repository.markMessagesAsSeen(
            userId: currentUser,
            otherUserId: widget.otherUserId,
          );

          // Subscribe to real-time updates (best-effort in test environments)
          try {
            repository.subscribeToConversation(
              userId1: currentUser,
              userId2: widget.otherUserId,
            );
          } catch (_) {}
        } catch (_) {}
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

    final messageRepository = context.read<EnhancedMessageRepository>();
    final currentUserId = messageRepository.currentUserId;
    if (currentUserId == null) return;

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    final request = CreateMessageRequest(
      receiver: widget.otherUserId,
      content: content,
    );

    final result = await messageRepository.sendMessage(
      senderId: currentUserId,
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

  Future<void> _makePhoneCall() async {
    if (widget.otherUserPhone == null || widget.otherUserPhone!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Clean the phone number - remove any spaces, dashes, or other formatting
    final cleanPhoneNumber = widget.otherUserPhone!.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    try {
      debugPrint('Attempting to call: $cleanPhoneNumber');

      // Try different URL schemes
      final phoneUrls = [
        Uri.parse('tel:$cleanPhoneNumber'),
        Uri.parse('tel://$cleanPhoneNumber'),
      ];

      bool launched = false;

      for (final phoneUrl in phoneUrls) {
        debugPrint('Trying phone URL: $phoneUrl');

        try {
          if (await canLaunchUrl(phoneUrl)) {
            await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
            debugPrint('Phone call launched successfully with URL: $phoneUrl');
            launched = true;
            break;
          }
        } catch (e) {
          debugPrint('Failed to launch with URL $phoneUrl: $e');
          continue;
        }
      }

      if (!launched) {
        debugPrint('All phone URL attempts failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot make phone calls on this device.\nPhone: $cleanPhoneNumber',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Phone call error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
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
          actions: [
            if (widget.otherUserPhone != null &&
                widget.otherUserPhone!.isNotEmpty)
              IconButton(
                onPressed: _makePhoneCall,
                icon: const Icon(LucideIcons.phone),
                tooltip: 'Call ${widget.otherUserName}',
              ),
            // Debug button to show phone number (remove in production)
            if (kDebugMode && widget.otherUserPhone != null)
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone: ${widget.otherUserPhone}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                tooltip: 'Show phone number',
              ),
          ],
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
              // Show upload progress if active
              if (_isUploading) LinearProgressIndicator(value: _uploadProgress),
              MessageInput(
                controller: _messageController,
                isComposing: _isComposing,
                onSend: _sendMessage,
                receiverId: widget.otherUserId,
                onUploadStart: () => setState(() => _isUploading = true),
                onUploadProgress: (p) => setState(() => _uploadProgress = p),
                onUploadEnd: () => setState(() {
                  _isUploading = false;
                  _uploadProgress = 0.0;
                }),
                imagePicker: widget.imagePicker,
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
                  if (message.content.isNotEmpty) ...[
                    CustomText(
                      text: message.content,
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (message.hasAttachment &&
                      message.attachmentType == AttachmentType.image) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Builder(
                        builder: (context) {
                          final url = message.attachmentUrl ?? '';
                          final isNetwork = url.startsWith('http');
                          if (isNetwork) {
                            return Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 160,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 160,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: 160,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(LucideIcons.image),
                                    ),
                                  ),
                            );
                          }

                          // Local file placeholder (optimistic). Use Image.file so tests/platforms handle it.
                          return Image.file(
                            File(url),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 160,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else if (message.hasAttachment) ...[
                    // Generic attachment preview for non-image types
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.blue.shade700
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            message.attachmentType?.icon ?? '📎',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomText(
                              text: message.attachmentUrl ?? 'Attachment',
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
                  // Show failed / retry for optimistic placeholders
                  Builder(
                    builder: (context) {
                      final repo = Provider.of<EnhancedMessageRepository>(
                        context,
                        listen: false,
                      );
                      if (message.id < 0 &&
                          repo.failedUploads.contains(message.id)) {
                        return Row(
                          children: [
                            const SizedBox(width: 4),
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () async {
                                final localPath =
                                    repo.uploadPlaceholders[message.id];
                                if (localPath == null) return;
                                final currentUser =
                                    Supabase.instance.client.auth.currentUser;
                                if (currentUser == null) return;
                                final file = XFile(localPath);
                                await repo.retryUpload(
                                  tempId: message.id,
                                  senderId: currentUser.id,
                                  file: file,
                                );
                              },
                              child: CustomText(
                                text: 'Upload failed — tap to retry',
                                color: isMe
                                    ? Colors.white70
                                    : Colors.red.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
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

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isComposing;
  final VoidCallback onSend;
  final String receiverId;
  final VoidCallback? onUploadStart;
  final void Function(double progress)? onUploadProgress;
  final VoidCallback? onUploadEnd;
  final ImagePicker? imagePicker;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isComposing,
    required this.onSend,
    required this.receiverId,
    this.onUploadStart,
    this.onUploadProgress,
    this.onUploadEnd,
    this.imagePicker,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final ImagePicker _picker = widget.imagePicker ?? ImagePicker();
  bool _sendingImage = false;

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;

      final repository = context.read<EnhancedMessageRepository>();
      final currentUserId = repository.currentUserId;
      if (currentUserId == null) return;

      setState(() => _sendingImage = true);

      // Minimal attach: directly upload/send the picked image without optimistic placeholders
      widget.onUploadStart?.call();

      final request = CreateMessageRequest(
        receiver: widget.receiverId,
        content: '',
      );

      final result = await repository.sendMessage(
        senderId: currentUserId,
        request: request,
        attachmentFile: picked,
      );

      if (!result.isSuccess) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send image: ${result.error}')),
          );
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image sent')));
        // success — scroll to bottom if desired
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // parent ChatScreen handles scrolling; attempt a best-effort call
          final state = context.findAncestorStateOfType<_ChatScreenState>();
          state?._scrollToBottom();
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking/sending image: $e')),
        );
    } finally {
      if (mounted) setState(() => _sendingImage = false);
      widget.onUploadEnd?.call();
    }
  }

  // Helper used by tests to bypass UI modal and directly provide a picked file
  Future<void> pickAndSendFile(XFile file) async {
    try {
      final repository = context.read<EnhancedMessageRepository>();
      final currentUserId = repository.currentUserId;
      if (currentUserId == null) return;

      setState(() => _sendingImage = true);

      widget.onUploadStart?.call();

      final request = CreateMessageRequest(
        receiver: widget.receiverId,
        content: '',
      );
      final result = await repository.sendMessage(
        senderId: currentUserId,
        request: request,
        attachmentFile: file,
      );

      if (!result.isSuccess) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send image: ${result.error}')),
          );
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image sent')));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final state = context.findAncestorStateOfType<_ChatScreenState>();
          state?._scrollToBottom();
        });
      }
    } finally {
      if (mounted) setState(() => _sendingImage = false);
      widget.onUploadEnd?.call();
    }
  }

  // Minimal attach: open gallery directly
  Future<void> _onImageButtonPressed() async {
    await _pickAndSendImage(ImageSource.gallery);
  }

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
            IconButton(
              onPressed: _sendingImage ? null : _onImageButtonPressed,
              icon: Icon(LucideIcons.image, color: Colors.grey.shade700),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onSend(),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: (widget.isComposing && !_sendingImage)
                    ? widget.onSend
                    : null,
                icon: Icon(
                  LucideIcons.send,
                  color: (widget.isComposing && !_sendingImage)
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
