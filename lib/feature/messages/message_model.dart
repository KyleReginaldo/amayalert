// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

part 'message_model.mapper.dart';

@MappableEnum(caseStyle: CaseStyle.camelCase)
/// Message status enumeration
enum MessageStatus {
  sent,
  delivered,
  read,
  edited,
  failed;

  String get displayName {
    switch (this) {
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.edited:
        return 'Edited';
      case MessageStatus.failed:
        return 'Failed';
    }
  }
}

@MappableEnum(caseStyle: CaseStyle.camelCase)
/// Attachment type enumeration
enum AttachmentType {
  image,
  video,
  audio,
  document,
  other;

  String get displayName {
    switch (this) {
      case AttachmentType.image:
        return 'Image';
      case AttachmentType.video:
        return 'Video';
      case AttachmentType.audio:
        return 'Audio';
      case AttachmentType.document:
        return 'Document';
      case AttachmentType.other:
        return 'File';
    }
  }

  String get icon {
    switch (this) {
      case AttachmentType.image:
        return '🖼️';
      case AttachmentType.video:
        return '🎥';
      case AttachmentType.audio:
        return '🎵';
      case AttachmentType.document:
        return '📄';
      case AttachmentType.other:
        return '📎';
    }
  }
}

@MappableEnum(caseStyle: CaseStyle.camelCase)
/// Conversation type enumeration
enum ConversationType {
  direct,
  group,
  broadcast;

  String get displayName {
    switch (this) {
      case ConversationType.direct:
        return 'Direct Message';
      case ConversationType.group:
        return 'Group Chat';
      case ConversationType.broadcast:
        return 'Broadcast';
    }
  }
}

/// Enhanced Message model with additional features
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Message with MessageMappable {
  final int id;
  final String sender;
  final String receiver;
  final String content;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? seenAt;

  const Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    this.attachmentUrl,
    required this.createdAt,
    this.updatedAt,
    this.seenAt,
  });

  /// Check if current user is the sender
  bool isSentByUser(String userId) {
    return sender == userId;
  }

  /// Check if current user is the receiver
  bool isReceivedByUser(String userId) {
    return receiver == userId;
  }

  /// Check if message has attachment
  bool get hasAttachment {
    return attachmentUrl != null && attachmentUrl!.isNotEmpty;
  }

  /// Get message status based on timestamps
  MessageStatus get status {
    if (updatedAt != null && updatedAt != createdAt) {
      return MessageStatus.edited;
    }
    return MessageStatus.sent;
  }

  /// Check if message was edited
  bool get isEdited {
    return updatedAt != null &&
        updatedAt!.isAfter(createdAt.add(const Duration(seconds: 1)));
  }

  /// Get attachment type from URL
  AttachmentType? get attachmentType {
    if (!hasAttachment) return null;

    final url = attachmentUrl!.toLowerCase();
    if (url.contains('.jpg') ||
        url.contains('.jpeg') ||
        url.contains('.png') ||
        url.contains('.gif') ||
        url.contains('.webp')) {
      return AttachmentType.image;
    } else if (url.contains('.mp4') ||
        url.contains('.mov') ||
        url.contains('.avi') ||
        url.contains('.mkv')) {
      return AttachmentType.video;
    } else if (url.contains('.mp3') ||
        url.contains('.wav') ||
        url.contains('.m4a')) {
      return AttachmentType.audio;
    } else if (url.contains('.pdf') ||
        url.contains('.doc') ||
        url.contains('.docx') ||
        url.contains('.txt')) {
      return AttachmentType.document;
    }
    return AttachmentType.other;
  }

  /// Get relative time string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get formatted time for chat display
  String getFormattedTime() {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  /// Check if message is seen by the receiver
  bool get isSeen {
    return seenAt != null;
  }

  /// Check if message is unread for the given user
  bool isUnreadFor(String userId) {
    return receiver == userId && !isSeen;
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
        other.updatedAt == updatedAt &&
        other.seenAt == seenAt;
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
      seenAt,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, sender: $sender, receiver: $receiver, '
        'content: $content, attachmentUrl: $attachmentUrl, '
        'createdAt: $createdAt, updatedAt: $updatedAt, seenAt: $seenAt)';
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// Data class for creating new messages
class CreateMessageRequest with CreateMessageRequestMappable {
  final String receiver;
  final String content;
  final String? attachmentUrl;

  const CreateMessageRequest({
    required this.receiver,
    required this.content,
    this.attachmentUrl,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// Data class for updating messages
class UpdateMessageRequest with UpdateMessageRequestMappable {
  final String? content;
  final String? attachmentUrl;

  const UpdateMessageRequest({this.content, this.attachmentUrl});

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> json = {};

    if (content != null) json['content'] = content;
    if (attachmentUrl != null) json['attachment_url'] = attachmentUrl;

    json['updated_at'] = DateTime.now().toIso8601String();

    return json;
  }

  bool get isEmpty => content == null && attachmentUrl == null;
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// Enhanced chat conversation with user info
class ChatConversation with ChatConversationMappable {
  final String participantId;
  final String participantName;
  final String? participantProfilePicture;
  final String? participantEmail;
  final String? phoneNumber;
  final bool isOnline;
  final DateTime? lastSeen;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? lastActivity;
  final ConversationType type;

  const ChatConversation({
    required this.participantId,
    required this.participantName,
    this.participantProfilePicture,
    this.participantEmail,
    this.phoneNumber,
    this.isOnline = false,
    this.lastSeen,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
    this.type = ConversationType.direct,
  });

  factory ChatConversation.fromMessages({
    required String participantId,
    required String participantName,
    String? participantProfilePicture,
    String? participantEmail,
    bool isOnline = false,
    DateTime? lastSeen,
    String? phoneNumber,
    required List<Message> messages,
    required String currentUserId,
    ConversationType type = ConversationType.direct,
  }) {
    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final lastMessage = sortedMessages.isNotEmpty ? sortedMessages.first : null;

    // Count unread messages (messages sent by participant to current user that haven't been seen)
    final unreadCount = messages
        .where(
          (msg) =>
              msg.sender == participantId &&
              msg.receiver == currentUserId &&
              msg.seenAt == null,
        )
        .length;

    return ChatConversation(
      participantId: participantId,
      participantName: participantName,
      participantProfilePicture: participantProfilePicture,
      participantEmail: participantEmail,
      isOnline: isOnline,
      lastSeen: lastSeen,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      phoneNumber: phoneNumber,
      lastActivity: lastMessage?.createdAt,
      type: type,
    );
  }

  /// Get display text for last message
  String get lastMessagePreview {
    if (lastMessage == null) return 'No messages yet';

    if (lastMessage!.hasAttachment) {
      final type = lastMessage!.attachmentType?.displayName ?? 'File';
      return '${lastMessage!.attachmentType?.icon ?? '📎'} $type';
    }

    return lastMessage!.content.length > 50
        ? '${lastMessage!.content.substring(0, 50)}...'
        : lastMessage!.content;
  }

  /// Get online status text
  String get onlineStatusText {
    if (isOnline) return 'Online';
    if (lastSeen != null) {
      return 'Last seen ${_formatLastSeen(lastSeen!)}';
    }
    return 'Offline';
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
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

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// User info for messaging
class MessageUser with MessageUserMappable {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicture;
  final String phoneNumber;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;

  const MessageUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.phoneNumber,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });

  factory MessageUser.fromJson(Map<String, dynamic> json) {
    return MessageUser(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown User',
      email: json['email'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
      phoneNumber: json['phone_number'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'] as String? ?? '') ??
                DateTime.now()
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Get display name (first name + last initial)
  String get displayName {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return '${parts.first} ${parts.last[0]}.';
    }
    return fullName;
  }

  /// Get initials for avatar
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.length > 1
        ? fullName.substring(0, 2).toUpperCase()
        : fullName.toUpperCase();
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// Message thread/conversation metadata
class MessageThread with MessageThreadMappable {
  final String id;
  final List<String> participants;
  final String? title;
  final ConversationType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastMessageId;
  final bool isArchived;
  final bool isMuted;

  const MessageThread({
    required this.id,
    required this.participants,
    this.title,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    this.lastMessageId,
    this.isArchived = false,
    this.isMuted = false,
  });

  /// Check if user is participant
  bool hasParticipant(String userId) {
    return participants.contains(userId);
  }

  /// Get other participants (excluding current user)
  List<String> getOtherParticipants(String currentUserId) {
    return participants.where((id) => id != currentUserId).toList();
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// Message search result
class MessageSearchResult with MessageSearchResultMappable {
  final Message message;
  final String conversationId;
  final String conversationName;
  final List<String> matchedTerms;

  const MessageSearchResult({
    required this.message,
    required this.conversationId,
    required this.conversationName,
    required this.matchedTerms,
  });
}

/// Message delivery receipt
class MessageDeliveryReceipt {
  final int messageId;
  final String userId;
  final MessageStatus status;
  final DateTime timestamp;

  const MessageDeliveryReceipt({
    required this.messageId,
    required this.userId,
    required this.status,
    required this.timestamp,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
/// Typing indicator
class TypingIndicator with TypingIndicatorMappable {
  final String userId;
  final String conversationId;
  final DateTime timestamp;

  const TypingIndicator({
    required this.userId,
    required this.conversationId,
    required this.timestamp,
  });

  /// Check if typing indicator is still valid (within last 3 seconds)
  bool get isActive {
    return DateTime.now().difference(timestamp).inSeconds < 3;
  }
}
