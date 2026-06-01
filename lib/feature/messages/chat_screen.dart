import 'dart:async';
import 'dart:io';

import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/services/chat_filter_service.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<EnhancedMessageRepository>()),
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
      ],
      child: this,
    );
  }
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  bool _isUploading = false;
  bool _hasInappropriateContent = false;
  double _uploadProgress = 0.0;
  Timer? _filterDebounce;
  String _lastFilterText = '';
  // Throttle for mark-as-seen operations
  bool _markSeenCooldown = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ChatScreen initialized with phone: ${widget.otherUserPhone}');
    WidgetsBinding.instance.addObserver(this);

    // Defer all Provider operations that call notifyListeners to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileRepository>().getUserProfile(userID ?? "");
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    // Listener removed
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
      if (_markSeenCooldown) return;
      _markSeenCooldown = true;
      repo.markMessagesAsSeen(
        userId: currentUserId,
        otherUserId: widget.otherUserId,
      );
      Timer(const Duration(seconds: 1), () {
        _markSeenCooldown = false;
      });
    }
  }

  void _onTextChanged(String text) {
    final trimmed = text.trim();
    final isComposing = trimmed.isNotEmpty;

    // Cancel any pending filter evaluation
    _filterDebounce?.cancel();

    // Safe: onChanged callbacks are always outside build phase
    if (_isComposing != isComposing) {
      if (mounted) {
        setState(() {
          _isComposing = isComposing;
        });
      }
    }

    if (trimmed.isEmpty) {
      if (_hasInappropriateContent && mounted) {
        setState(() {
          _hasInappropriateContent = false;
        });
      }
      return;
    }

    _lastFilterText = trimmed;
    // Debounce async filter check
    _filterDebounce = Timer(const Duration(milliseconds: 300), () async {
      final current = _lastFilterText;
      bool ok = true;
      try {
        ok = await ChatFilterService().filterMessage(current);
      } catch (_) {
        ok = true; // Fail-open to avoid blocking typing on transient errors
      }
      if (!mounted) return;
      // Ignore stale results if text changed since debounce started
      if (current != text.trim()) return;
      setState(() {
        _hasInappropriateContent = !ok;
      });
    });
  }

  void _loadMessages() {
    if (!mounted) return;
    final repo = context.read<EnhancedMessageRepository>();
    final currentUser = repo.currentUserId;
    if (currentUser != null) {
      try {
        repo.loadConversation(
          userId1: currentUser,
          userId2: widget.otherUserId,
        );

        // Mark messages as seen from this user
        repo.markMessagesAsSeen(
          userId: currentUser,
          otherUserId: widget.otherUserId,
        );

        // Subscribe to real-time updates (best-effort in test environments)
        try {
          repo.subscribeToConversation(
            userId1: currentUser,
            userId2: widget.otherUserId,
          );
        } catch (_) {}
      } catch (_) {}
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
    bool isFiltered = await ChatFilterService().filterMessage(content);
    // Check for inappropriate content before sending
    if (!isFiltered) {
      // Show warning dialog instead of just a snackbar for better user experience
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Message Blocked'),
            ],
          ),
          content: Text(ChatFilterService.getDetailedBlockReason(content)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return; // Don't send the message
    }

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

  // Deterministic avatar color — same palette as message/new-conversation screens
  Color _avatarColor() {
    const palette = [
      Color(0xFF1D6BF3), Color(0xFF2E7D32), Color(0xFFDC2626),
      Color(0xFF7C3AED), Color(0xFFF59E0B), Color(0xFF0891B2),
      Color(0xFFDB2777), Color(0xFF16A34A),
    ];
    final name = widget.otherUserName;
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length;
    return palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    final initial = widget.otherUserName.isNotEmpty
        ? widget.otherUserName.trim()[0].toUpperCase()
        : '?';

    return ChangeNotifierProvider.value(
      value: sl<EnhancedMessageRepository>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(LucideIcons.arrowLeft,
                color: AppColors.textPrimaryLight, size: 20),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.otherUserPhone != null &&
                        widget.otherUserPhone!.isNotEmpty)
                      Text(
                        widget.otherUserPhone!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray400),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (widget.otherUserPhone != null &&
                widget.otherUserPhone!.isNotEmpty)
              IconButton(
                onPressed: _makePhoneCall,
                icon: const Icon(LucideIcons.phone,
                    color: AppColors.primary, size: 20),
                tooltip: 'Call ${widget.otherUserName}',
              ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<EnhancedMessageRepository>(
                builder: (context, repo, _) {
                  // Loading
                  if (repo.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  // Error
                  if (repo.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.wifiOff,
                                  size: 28, color: AppColors.danger),
                            ),
                            const SizedBox(height: 16),
                            const Text('Failed to load messages',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(repo.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondaryLight)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                repo.clearError();
                                _loadMessages();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final messages = repo.currentConversationMessages;

                  // Empty
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.messageCircle,
                                size: 32, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text('No messages yet',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('Say hi to ${widget.otherUserName}!',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    );
                  }

                  final currentUid =
                      Supabase.instance.client.auth.currentUser?.id;

                  // Build list with date separators
                  // messages are in ascending order (oldest first)
                  // ListView is reversed so index 0 = newest
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // index 0 = newest message (reversed)
                      final reversedIdx = messages.length - 1 - index;
                      final msg = messages[reversedIdx];
                      final isMe = msg.sender == currentUid;

                      // Check if we need a date separator
                      // In reversed list, separator goes AFTER current item
                      final showSeparator = reversedIdx == 0 ||
                          !_sameDay(
                              messages[reversedIdx - 1].createdAt,
                              msg.createdAt);

                      return Column(
                        children: [
                          if (showSeparator)
                            _DateSeparator(date: msg.createdAt),
                          MessageBubble(message: msg, isMe: isMe),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Upload progress
            if (_isUploading)
              LinearProgressIndicator(
                value: _uploadProgress,
                color: AppColors.primary,
                backgroundColor: AppColors.gray200,
              ),

            // Input
            MessageInput(
              controller: _messageController,
              isComposing: _isComposing,
              hasInappropriateContent: _hasInappropriateContent,
              onSend: _sendMessage,
              onTextChanged: _onTextChanged,
              receiverId: widget.otherUserId,
              onUploadStart: () => setState(() => _isUploading = true),
              onUploadProgress: (p) =>
                  setState(() => _uploadProgress = p),
              onUploadEnd: () => setState(() {
                _isUploading = false;
                _uploadProgress = 0.0;
              }),
              imagePicker: widget.imagePicker,
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.gray300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.gray300)),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  static const _sentColor = AppColors.primary;
  static const _receivedColor = Color(0xFFEEF0F4);

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.72;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
          // ── Bubble ──────────────────────────────────────────────────
          Container(
            constraints: BoxConstraints(maxWidth: maxW),
            decoration: BoxDecoration(
              color: isMe ? _sentColor : _receivedColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image attachment
                  if (message.hasAttachment &&
                      message.attachmentType == AttachmentType.image)
                    _ImageAttachment(
                        url: message.attachmentUrl ?? '', maxW: maxW),

                  // Generic attachment
                  if (message.hasAttachment &&
                      message.attachmentType != AttachmentType.image)
                    _GenericAttachment(message: message, isMe: isMe),

                  // Text content
                  if (message.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textPrimaryLight,
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                      ),
                    ),

                  // Timestamp + read receipt
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(message.createdAt, locale: 'en_short'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.65)
                                : AppColors.gray400,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isSeen
                                ? LucideIcons.checkCheck
                                : LucideIcons.check,
                            size: 13,
                            color: message.isSeen
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.55),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Failed upload retry ──────────────────────────────────────
          Builder(builder: (context) {
            final repo = Provider.of<EnhancedMessageRepository>(
              context,
              listen: false,
            );
            if (message.id < 0 && repo.failedUploads.contains(message.id)) {
              return GestureDetector(
                onTap: () async {
                  final localPath = repo.uploadPlaceholders[message.id];
                  if (localPath == null) return;
                  final uid = Supabase.instance.client.auth.currentUser?.id;
                  if (uid == null) return;
                  await repo.retryUpload(
                    tempId: message.id,
                    senderId: uid,
                    file: XFile(localPath),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.triangle,
                          size: 12, color: AppColors.danger),
                      const SizedBox(width: 4),
                      Text(
                        'Upload failed — tap to retry',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
            ],   // Column children
          ),     // Column
        ],       // Row children
      ),         // Row
    );           // Padding
  }
}

class _ImageAttachment extends StatelessWidget {
  final String url;
  final double maxW;
  const _ImageAttachment({required this.url, required this.maxW});

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: maxW,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: maxW,
            height: 200,
            color: AppColors.gray200,
            child: const Center(child: CircularProgressIndicator.adaptive()),
          );
        },
        errorBuilder: (_, _, _) => Container(
          width: maxW,
          height: 200,
          color: AppColors.gray200,
          child: const Icon(LucideIcons.imageOff,
              color: AppColors.gray400, size: 32),
        ),
      );
    }
    return Image.file(File(url),
        width: maxW, height: 200, fit: BoxFit.cover);
  }
}

class _GenericAttachment extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _GenericAttachment({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message.attachmentType?.icon ?? '📎',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            'Attachment',
            style: TextStyle(
              fontSize: 14,
              color: isMe ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isComposing;
  final bool hasInappropriateContent;
  final VoidCallback onSend;
  final ValueChanged<String>? onTextChanged;
  final String receiverId;
  final VoidCallback? onUploadStart;
  final void Function(double progress)? onUploadProgress;
  final VoidCallback? onUploadEnd;
  final ImagePicker? imagePicker;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isComposing,
    this.hasInappropriateContent = false,
    required this.onSend,
    this.onTextChanged,
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send image: ${result.error}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image sent')));
        }
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
    final canSend =
        widget.isComposing && !_sendingImage && !widget.hasInappropriateContent;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attach image
              GestureDetector(
                onTap: _sendingImage ? null : _onImageButtonPressed,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.paperclip,
                    size: 18,
                    color: _sendingImage
                        ? AppColors.gray300
                        : AppColors.gray500,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    onChanged: widget.onTextChanged,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) {
                      if (canSend) widget.onSend();
                    },
                    maxLines: null,
                    style: const TextStyle(fontSize: 14.5),
                    decoration: InputDecoration(
                      hintText: widget.hasInappropriateContent
                          ? 'Message blocked — edit before sending'
                          : 'Message...',
                      hintStyle: TextStyle(
                        color: widget.hasInappropriateContent
                            ? AppColors.danger
                            : AppColors.gray400,
                        fontSize: 14.5,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Send button
              AnimatedScale(
                scale: widget.isComposing ? 1.0 : 0.85,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: canSend ? widget.onSend : null,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.hasInappropriateContent
                          ? AppColors.danger
                          : canSend
                              ? AppColors.primary
                              : AppColors.gray300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.hasInappropriateContent
                          ? LucideIcons.triangle
                          : LucideIcons.send,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
