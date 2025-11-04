import 'package:amayalert/core/services/badge_service.dart';
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

import '../../core/router/app_route.gr.dart';

@RoutePage()
class MessageScreen extends StatefulWidget implements AutoRouteWrapper {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EnhancedMessageRepository>(),
      child: this,
    );
  }
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Clear badge when messages screen is opened
    BadgeService().clearUnreadCount();
  }

  void _loadConversations() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EnhancedMessageRepository>().loadConversations(
          currentUser.id,
        );
        context.read<EnhancedMessageRepository>().subscribeToUserMessages(
          currentUser.id,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EnhancedMessageRepository>(),
      child: Scaffold(
        appBar: AppBar(
          title: const CustomText(text: 'Messages'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // Navigate to new conversation screen
                context.router.push(NewConversationRoute());
              },
              icon: const Icon(LucideIcons.plus),
            ),
          ],
        ),
        body: Consumer<EnhancedMessageRepository>(
          builder: (context, messageRepository, child) {
            debugPrint('error: ${messageRepository.errorMessage}');
            if (messageRepository.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (messageRepository.errorMessage != null) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.wifi,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomText(
                        text: 'Oops! Something went wrong',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text: 'We couldn\'t load your conversations right now',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: ElevatedButton(
                          onPressed: () {
                            messageRepository.clearError();
                            _loadConversations();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const CustomText(
                            text: 'Try Again',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (messageRepository.conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.messageCircle,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: 'No conversations yet',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: 'Start a conversation with someone!',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadConversations();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: messageRepository.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = messageRepository.conversations[index];
                  return ConversationItem(
                    conversation: conversation,
                    onTap: () {
                      // Navigate to chat screen
                      context.router.push(
                        ChatRoute(
                          otherUserId: conversation.participantId,
                          otherUserName: conversation.participantName,
                          otherUserPhone: conversation.phoneNumber,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class ConversationItem extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade50,
                  child: conversation.participantProfilePicture != null
                      ? ClipOval(
                          child: Image.network(
                            conversation.participantProfilePicture!,
                            fit: BoxFit.cover,
                            height: 56,
                            width: 56,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                conversation.participantName.isNotEmpty
                                    ? conversation.participantName[0]
                                          .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          conversation.participantName.isNotEmpty
                              ? conversation.participantName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomText(
                              text: conversation.participantName,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          if (conversation.lastActivity != null)
                            CustomText(
                              text: timeago.format(conversation.lastActivity!),
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                        ],
                      ),
                      if (conversation.lastMessage != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                text:
                                    conversation.lastMessage?.hasAttachment ==
                                        true
                                    ? 'Sent an image'
                                    : conversation.lastMessage!.content,
                                fontSize: 14,
                                color:
                                    (conversation.unreadCount > 0 &&
                                        conversation.lastMessage?.sender ==
                                            conversation.participantId &&
                                        conversation.lastMessage?.seenAt ==
                                            null)
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                fontWeight:
                                    (conversation.unreadCount > 0 &&
                                        conversation.lastMessage?.sender ==
                                            conversation.participantId &&
                                        conversation.lastMessage?.seenAt ==
                                            null)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (conversation.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CustomText(
                                  text: conversation.unreadCount > 99
                                      ? '99+'
                                      : '${conversation.unreadCount}',
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
