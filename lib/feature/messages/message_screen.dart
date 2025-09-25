import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:amayalert/feature/messages/message_repository.dart';
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
      value: sl<MessageRepository>(),
      child: this,
    );
  }
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MessageRepository>().loadConversations(currentUser.id);
        context.read<MessageRepository>().subscribeToUserMessages(
          currentUser.id,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<MessageRepository>(),
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
        body: Consumer<MessageRepository>(
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
                      text: 'Error loading conversations',
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
                        _loadConversations();
                      },
                      child: const CustomText(text: 'Retry'),
                    ),
                  ],
                ),
              );
            }

            if (messageRepository.conversations.isEmpty) {
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
                      text: 'No conversations yet',
                      fontSize: 16,
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
              child: ListView.separated(
                itemCount: messageRepository.conversations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(LucideIcons.user, color: Colors.blue, size: 20),
      ),
      title: CustomText(
        text: conversation.participantName,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      subtitle: conversation.lastMessage != null
          ? CustomText(
              text: conversation.lastMessage!.content,
              fontSize: 14,
              color: Colors.grey.shade600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastActivity != null)
            CustomText(
              text: timeago.format(conversation.lastActivity!),
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          const SizedBox(height: 4),
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomText(
                text: '${conversation.unreadCount}',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
