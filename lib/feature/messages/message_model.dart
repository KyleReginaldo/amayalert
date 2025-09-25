import 'package:dart_mappable/dart_mappable.dart';

/// Message model based on database schema
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Message with MessageMappable {
  final int id;
  final String sender;
  final String receiver;
  final String content;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    this.attachmentUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if current user is the sender
  bool isSentByUser(String userId) {
    return sender == userId;
  }

  /// Check if message has attachment
  bool get hasAttachment {
    return attachmentUrl != null && attachmentUrl!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.sender == sender &&
        other.receiver == receiver &&
        other.content == content &&
        other.attachmentUrl == attachmentUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sender,
      receiver,
      content,
      attachmentUrl,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, sender: $sender, receiver: $receiver, '
        'content: $content, attachmentUrl: $attachmentUrl, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Data class for creating new messages
class CreateMessageRequest {
  final String receiver;
  final String content;
  final String? attachmentUrl;

  const CreateMessageRequest({
    required this.receiver,
    required this.content,
    this.attachmentUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiver': receiver,
      'content': content,
      'attachment_url': attachmentUrl,
    };
  }
}

/// Data class for updating messages
class UpdateMessageRequest {
  final String? content;
  final String? attachmentUrl;

  const UpdateMessageRequest({this.content, this.attachmentUrl});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (content != null) json['content'] = content;
    if (attachmentUrl != null) json['attachment_url'] = attachmentUrl;

    json['updated_at'] = DateTime.now().toIso8601String();

    return json;
  }

  bool get isEmpty => content == null && attachmentUrl == null;
}

/// Chat conversation helper class
class ChatConversation {
  final String participantId;
  final String participantName;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? lastActivity;

  const ChatConversation({
    required this.participantId,
    required this.participantName,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
  });

  factory ChatConversation.fromMessages({
    required String participantId,
    required String participantName,
    required List<Message> messages,
    required String currentUserId,
  }) {
    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final lastMessage = sortedMessages.isNotEmpty ? sortedMessages.first : null;

    // Count unread messages (messages sent by participant to current user)
    final unreadCount = messages
        .where(
          (msg) => msg.sender == participantId && msg.receiver == currentUserId,
        )
        .length;

    return ChatConversation(
      participantId: participantId,
      participantName: participantName,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      lastActivity: lastMessage?.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatConversation &&
        other.participantId == participantId &&
        other.participantName == participantName &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount &&
        other.lastActivity == lastActivity;
  }

  @override
  int get hashCode {
    return Object.hash(
      participantId,
      participantName,
      lastMessage,
      unreadCount,
      lastActivity,
    );
  }

  @override
  String toString() {
    return 'ChatConversation(participantId: $participantId, '
        'participantName: $participantName, lastMessage: $lastMessage, '
        'unreadCount: $unreadCount, lastActivity: $lastActivity)';
  }
}
