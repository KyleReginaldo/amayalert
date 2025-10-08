import 'dart:io';

import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enhanced message provider with comprehensive messaging features
class EnhancedMessageProvider {
  final supabase = Supabase.instance.client;

  /// Send a message with enhanced features
  Future<Result<Message>> sendMessage({
    required String senderId,
    required CreateMessageRequest request,
    XFile? attachmentFile,
  }) async {
    try {
      String? attachmentUrl;

      // Upload attachment if provided
      if (attachmentFile != null) {
        final uploadResult = await _uploadAttachment(attachmentFile);
        if (!uploadResult.isSuccess) {
          return Result.error(uploadResult.error);
        }
        attachmentUrl = uploadResult.value;
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

      final message = MessageMapper.fromMap(response);
      return Result.success(message);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get conversation with pagination
  Future<Result<List<Message>>> getConversation({
    required String userId1,
    required String userId2,
    int limit = 50,
    int offset = 0,
    DateTime? before,
  }) async {
    try {
      final response = await supabase
          .from('messages')
          .select()
          .or(
            'and(sender.eq.$userId1,receiver.eq.$userId2),and(sender.eq.$userId2,receiver.eq.$userId1)',
          )
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final messages = response
          .map((json) => MessageMapper.fromMap(json))
          .toList();

      return Result.success(messages);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get user conversations with enhanced user info
  Future<Result<List<ChatConversation>>> getUserConversations({
    required String userId,
  }) async {
    try {
      // Get messages with user info joined
      final response = await supabase
          .from('messages')
          .select('''
            *,
            sender_user:sender(id, full_name, email, profile_picture, phone_number, created_at),
            receiver_user:receiver(id, full_name, email, profile_picture, phone_number, created_at)
          ''')
          .or('sender.eq.$userId,receiver.eq.$userId')
          .order('created_at', ascending: false);

      // Group messages by conversation partner
      final Map<String, List<Message>> conversationMap = {};
      final Map<String, MessageUser> participantInfo = {};

      for (final messageJson in response) {
        final message = MessageMapper.fromMap(messageJson);
        final partnerId = message.sender == userId
            ? message.receiver
            : message.sender;

        // Extract user info
        final userJson = message.sender == userId
            ? messageJson['receiver_user']
            : messageJson['sender_user'];

        if (userJson != null) {
          participantInfo[partnerId] = MessageUser.fromJson(userJson);
        }

        if (!conversationMap.containsKey(partnerId)) {
          conversationMap[partnerId] = [];
        }
        conversationMap[partnerId]!.add(message);
      }

      // Convert to ChatConversation objects
      final conversations = conversationMap.entries.map((entry) {
        final participant = participantInfo[entry.key];
        return ChatConversation.fromMessages(
          participantId: entry.key,
          participantName: participant?.fullName ?? 'Unknown User',
          participantProfilePicture: participant?.profilePicture,
          participantEmail: participant?.email,
          isOnline: participant?.isOnline ?? false,
          lastSeen: participant?.lastSeen,
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

  /// Search messages across all conversations
  Future<Result<List<MessageSearchResult>>> searchMessages({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await supabase
          .from('messages')
          .select('''
            *,
            sender_user:sender(full_name),
            receiver_user:receiver(full_name)
          ''')
          .or('sender.eq.$userId,receiver.eq.$userId')
          .ilike('content', '%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      final searchResults = response.map((json) {
        final message = MessageMapper.fromMap(json);
        final partnerId = message.sender == userId
            ? message.receiver
            : message.sender;

        final partnerName = message.sender == userId
            ? (json['receiver_user']?['full_name'] as String? ?? 'Unknown')
            : (json['sender_user']?['full_name'] as String? ?? 'Unknown');

        return MessageSearchResult(
          message: message,
          conversationId: partnerId,
          conversationName: partnerName,
          matchedTerms: [query],
        );
      }).toList();

      return Result.success(searchResults);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get all users for starting new conversations
  Future<Result<List<MessageUser>>> getAvailableUsers({
    required String currentUserId,
    String? searchQuery,
  }) async {
    try {
      var query = supabase
          .from('users')
          .select(
            'id, full_name, email, profile_picture, phone_number, created_at',
          )
          .neq('id', currentUserId);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%,phone_number.ilike.%$searchQuery%',
        );
      }

      final response = await query.order('full_name').limit(50);

      final users = response.map((json) => MessageUser.fromJson(json)).toList();

      return Result.success(users);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Mark messages as read
  Future<Result<void>> markMessagesAsRead({
    required String userId,
    required List<int> messageIds,
  }) async {
    try {
      // Note: This would require adding a read_receipts table in your database
      // For now, we'll simulate this functionality
      debugPrint(
        'Marking ${messageIds.length} messages as read for user $userId',
      );
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Upload attachment file
  Future<Result<String>> _uploadAttachment(XFile file) async {
    try {
      final fileName =
          'messages/${DateTime.now().microsecondsSinceEpoch}_${file.name}';

      await supabase.storage.from('files').upload(fileName, File(file.path));

      final url = supabase.storage.from('files').getPublicUrl(fileName);
      return Result.success(url);
    } catch (e) {
      return Result.error('Failed to upload attachment: $e');
    }
  }

  /// Update message
  Future<Result<Message>> updateMessage({
    required int messageId,
    required String senderId,
    required UpdateMessageRequest request,
  }) async {
    try {
      // Check ownership
      final messageCheck = await supabase
          .from('messages')
          .select('sender')
          .eq('id', messageId)
          .single();

      if (messageCheck['sender'] != senderId) {
        return Result.error('You can only edit your own messages');
      }

      final updateData = request.toMap();
      final response = await supabase
          .from('messages')
          .update(updateData)
          .eq('id', messageId)
          .select()
          .single();

      final message = MessageMapper.fromMap(response);
      return Result.success(message);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Delete message
  Future<Result<void>> deleteMessage({
    required int messageId,
    required String senderId,
  }) async {
    try {
      // Check ownership and get attachment info
      final messageCheck = await supabase
          .from('messages')
          .select('sender, attachment_url')
          .eq('id', messageId)
          .single();

      if (messageCheck['sender'] != senderId) {
        return Result.error('You can only delete your own messages');
      }

      // Delete attachment if exists
      final attachmentUrl = messageCheck['attachment_url'] as String?;
      if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
        await _deleteAttachment(attachmentUrl);
      }

      // Delete message
      await supabase.from('messages').delete().eq('id', messageId);
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Delete attachment file
  Future<void> _deleteAttachment(String url) async {
    try {
      final uri = Uri.parse(url);
      final filePath = uri.pathSegments.skip(4).join('/');
      await supabase.storage.from('files').remove([filePath]);
    } catch (e) {
      debugPrint('Failed to delete attachment: $e');
    }
  }

  /// Subscribe to real-time updates
  RealtimeChannel subscribeToConversation({
    required String userId1,
    required String userId2,
    required Function(Message message) onNewMessage,
    required Function(Message message) onMessageUpdated,
    required Function(int messageId) onMessageDeleted,
  }) {
    return supabase
        .channel('conversation_${userId1}_$userId2')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final message = MessageMapper.fromMap(payload.newRecord);
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
              final message = MessageMapper.fromMap(payload.newRecord);
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
        )
      ..subscribe();
  }

  /// Subscribe to user messages for conversation list updates
  RealtimeChannel subscribeToUserMessages({
    required String userId,
    required Function(Message message) onNewMessage,
  }) {
    return supabase
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
              final message = MessageMapper.fromMap(payload.newRecord);
              onNewMessage(message);
            } catch (e) {
              debugPrint('Error parsing new message: $e');
            }
          },
        )
      ..subscribe();
  }
}
