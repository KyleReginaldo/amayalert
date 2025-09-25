import 'dart:io';

import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageProvider {
  final supabase = Supabase.instance.client;

  Future<Result<String>> sendMessage({
    required String senderId,
    required CreateMessageRequest request,
    XFile? attachmentFile,
  }) async {
    try {
      String? attachmentUrl;

      // Upload attachment if provided
      if (attachmentFile != null) {
        final fileName =
            'messages/${DateTime.now().microsecondsSinceEpoch.toString()}_${attachmentFile.name}';
        await supabase.storage
            .from('files')
            .upload(fileName, File(attachmentFile.path));
        attachmentUrl = supabase.storage.from('files').getPublicUrl(fileName);
      }

      // Create message in database
      final messageData = {
        'sender': senderId,
        'receiver': request.receiver,
        'content': request.content,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      };

      final response = await supabase
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      if (response.isNotEmpty) {
        return Result.success('Message sent successfully');
      } else {
        return Result.error('Failed to send message');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<List<Message>>> getConversation({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      final response = await supabase
          .from('messages')
          .select()
          .or(
            'and(sender.eq.$userId1,receiver.eq.$userId2),and(sender.eq.$userId2,receiver.eq.$userId1)',
          )
          .order('created_at', ascending: false)
          .limit(limit);

      final messages = response.map((json) => Message.fromJson(json)).toList();
      return Result.success(messages);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<List<ChatConversation>>> getUserConversations({
    required String userId,
  }) async {
    try {
      // Get all messages where user is sender or receiver
      final response = await supabase
          .from('messages')
          .select('*, sender!inner(*), receiver!inner(*)')
          .or('sender.eq.$userId,receiver.eq.$userId')
          .order('created_at', ascending: false);

      // Group messages by conversation partner
      final Map<String, List<Message>> conversationMap = {};
      final Map<String, String> participantNames = {};

      for (final messageJson in response) {
        final message = Message.fromJson(messageJson);
        final partnerId = message.sender == userId
            ? message.receiver
            : message.sender;

        // Store participant name (you might want to get this from a users table join)
        participantNames[partnerId] = 'User ${partnerId.substring(0, 8)}...';

        if (!conversationMap.containsKey(partnerId)) {
          conversationMap[partnerId] = [];
        }
        conversationMap[partnerId]!.add(message);
      }

      // Convert to ChatConversation objects
      final conversations = conversationMap.entries.map((entry) {
        return ChatConversation.fromMessages(
          participantId: entry.key,
          participantName: participantNames[entry.key] ?? 'Unknown User',
          messages: entry.value,
          currentUserId: userId,
        );
      }).toList();

      // Sort by last activity
      conversations.sort((a, b) {
        if (a.lastActivity == null && b.lastActivity == null) return 0;
        if (a.lastActivity == null) return 1;
        if (b.lastActivity == null) return -1;
        return b.lastActivity!.compareTo(a.lastActivity!);
      });

      return Result.success(conversations);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<String>> updateMessage({
    required int messageId,
    required String senderId,
    required UpdateMessageRequest request,
  }) async {
    try {
      // Check if user owns the message
      final messageCheck = await supabase
          .from('messages')
          .select('sender')
          .eq('id', messageId)
          .single();

      if (messageCheck['sender'] != senderId) {
        return Result.error('You can only edit your own messages');
      }

      final updateData = request.toJson();

      final response = await supabase
          .from('messages')
          .update(updateData)
          .eq('id', messageId)
          .select()
          .single();

      if (response.isNotEmpty) {
        return Result.success('Message updated successfully');
      } else {
        return Result.error('Failed to update message');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<String>> deleteMessage({
    required int messageId,
    required String senderId,
  }) async {
    try {
      // Check if user owns the message
      final messageCheck = await supabase
          .from('messages')
          .select('sender, attachment_url')
          .eq('id', messageId)
          .single();

      if (messageCheck['sender'] != senderId) {
        return Result.error('You can only delete your own messages');
      }

      // Delete associated attachment if exists
      final attachmentUrl = messageCheck['attachment_url'] as String?;
      if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
        try {
          // Extract file path from URL and delete from storage
          final uri = Uri.parse(attachmentUrl);
          final filePath = uri.pathSegments
              .skip(4)
              .join('/'); // Skip /storage/v1/object/public/files/
          await supabase.storage.from('files').remove([filePath]);
        } catch (e) {
          debugPrint('Failed to delete attachment file: $e');
        }
      }

      // Delete message from database
      await supabase.from('messages').delete().eq('id', messageId);

      return Result.success('Message deleted successfully');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Subscribe to real-time message updates for a conversation
  RealtimeChannel subscribeToConversation({
    required String userId1,
    required String userId2,
    required Function(Message message) onNewMessage,
    required Function(Message message) onMessageUpdated,
    required Function(int messageId) onMessageDeleted,
  }) {
    final channel = supabase
        .channel('conversation_${userId1}_$userId2')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sender',
            value: userId1,
          ),
          callback: (payload) {
            try {
              final message = Message.fromJson(payload.newRecord);
              if ((message.sender == userId1 && message.receiver == userId2) ||
                  (message.sender == userId2 && message.receiver == userId1)) {
                onNewMessage(message);
              }
            } catch (e) {
              debugPrint('Error parsing new message: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sender',
            value: userId2,
          ),
          callback: (payload) {
            try {
              final message = Message.fromJson(payload.newRecord);
              if ((message.sender == userId1 && message.receiver == userId2) ||
                  (message.sender == userId2 && message.receiver == userId1)) {
                onNewMessage(message);
              }
            } catch (e) {
              debugPrint('Error parsing new message: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final message = Message.fromJson(payload.newRecord);
              if ((message.sender == userId1 && message.receiver == userId2) ||
                  (message.sender == userId2 && message.receiver == userId1)) {
                onMessageUpdated(message);
              }
            } catch (e) {
              debugPrint('Error parsing updated message: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final messageId = payload.oldRecord['id'] as int;
              onMessageDeleted(messageId);
            } catch (e) {
              debugPrint('Error parsing deleted message: $e');
            }
          },
        );

    channel.subscribe();
    return channel;
  }

  /// Subscribe to all messages for a user (for conversation list updates)
  RealtimeChannel subscribeToUserMessages({
    required String userId,
    required Function(Message message) onNewMessage,
  }) {
    final channel = supabase
        .channel('user_messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver',
            value: userId,
          ),
          callback: (payload) {
            try {
              final message = Message.fromJson(payload.newRecord);
              onNewMessage(message);
            } catch (e) {
              debugPrint('Error parsing new message: $e');
            }
          },
        );

    channel.subscribe();
    return channel;
  }
}
