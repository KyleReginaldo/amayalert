// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'message_model.dart';

class MessageStatusMapper extends EnumMapper<MessageStatus> {
  MessageStatusMapper._();

  static MessageStatusMapper? _instance;
  static MessageStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageStatusMapper._());
    }
    return _instance!;
  }

  static MessageStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MessageStatus decode(dynamic value) {
    switch (value) {
      case r'sent':
        return MessageStatus.sent;
      case r'delivered':
        return MessageStatus.delivered;
      case r'read':
        return MessageStatus.read;
      case r'edited':
        return MessageStatus.edited;
      case r'failed':
        return MessageStatus.failed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MessageStatus self) {
    switch (self) {
      case MessageStatus.sent:
        return r'sent';
      case MessageStatus.delivered:
        return r'delivered';
      case MessageStatus.read:
        return r'read';
      case MessageStatus.edited:
        return r'edited';
      case MessageStatus.failed:
        return r'failed';
    }
  }
}

extension MessageStatusMapperExtension on MessageStatus {
  String toValue() {
    MessageStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MessageStatus>(this) as String;
  }
}

class AttachmentTypeMapper extends EnumMapper<AttachmentType> {
  AttachmentTypeMapper._();

  static AttachmentTypeMapper? _instance;
  static AttachmentTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AttachmentTypeMapper._());
    }
    return _instance!;
  }

  static AttachmentType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  AttachmentType decode(dynamic value) {
    switch (value) {
      case r'image':
        return AttachmentType.image;
      case r'video':
        return AttachmentType.video;
      case r'audio':
        return AttachmentType.audio;
      case r'document':
        return AttachmentType.document;
      case r'other':
        return AttachmentType.other;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(AttachmentType self) {
    switch (self) {
      case AttachmentType.image:
        return r'image';
      case AttachmentType.video:
        return r'video';
      case AttachmentType.audio:
        return r'audio';
      case AttachmentType.document:
        return r'document';
      case AttachmentType.other:
        return r'other';
    }
  }
}

extension AttachmentTypeMapperExtension on AttachmentType {
  String toValue() {
    AttachmentTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<AttachmentType>(this) as String;
  }
}

class ConversationTypeMapper extends EnumMapper<ConversationType> {
  ConversationTypeMapper._();

  static ConversationTypeMapper? _instance;
  static ConversationTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConversationTypeMapper._());
    }
    return _instance!;
  }

  static ConversationType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ConversationType decode(dynamic value) {
    switch (value) {
      case r'direct':
        return ConversationType.direct;
      case r'group':
        return ConversationType.group;
      case r'broadcast':
        return ConversationType.broadcast;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ConversationType self) {
    switch (self) {
      case ConversationType.direct:
        return r'direct';
      case ConversationType.group:
        return r'group';
      case ConversationType.broadcast:
        return r'broadcast';
    }
  }
}

extension ConversationTypeMapperExtension on ConversationType {
  String toValue() {
    ConversationTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ConversationType>(this) as String;
  }
}

class MessageMapper extends ClassMapperBase<Message> {
  MessageMapper._();

  static MessageMapper? _instance;
  static MessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Message';

  static int _$id(Message v) => v.id;
  static const Field<Message, int> _f$id = Field('id', _$id);
  static String _$sender(Message v) => v.sender;
  static const Field<Message, String> _f$sender = Field('sender', _$sender);
  static String _$receiver(Message v) => v.receiver;
  static const Field<Message, String> _f$receiver = Field(
    'receiver',
    _$receiver,
  );
  static String _$content(Message v) => v.content;
  static const Field<Message, String> _f$content = Field('content', _$content);
  static String? _$attachmentUrl(Message v) => v.attachmentUrl;
  static const Field<Message, String> _f$attachmentUrl = Field(
    'attachmentUrl',
    _$attachmentUrl,
    key: r'attachment_url',
    opt: true,
  );
  static DateTime _$createdAt(Message v) => v.createdAt;
  static const Field<Message, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime? _$updatedAt(Message v) => v.updatedAt;
  static const Field<Message, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static DateTime? _$seenAt(Message v) => v.seenAt;
  static const Field<Message, DateTime> _f$seenAt = Field(
    'seenAt',
    _$seenAt,
    key: r'seen_at',
    opt: true,
  );
  static bool _$hasAttachment(Message v) => v.hasAttachment;
  static const Field<Message, bool> _f$hasAttachment = Field(
    'hasAttachment',
    _$hasAttachment,
    key: r'has_attachment',
    mode: FieldMode.member,
  );
  static MessageStatus _$status(Message v) => v.status;
  static const Field<Message, MessageStatus> _f$status = Field(
    'status',
    _$status,
    mode: FieldMode.member,
  );
  static bool _$isEdited(Message v) => v.isEdited;
  static const Field<Message, bool> _f$isEdited = Field(
    'isEdited',
    _$isEdited,
    key: r'is_edited',
    mode: FieldMode.member,
  );
  static AttachmentType? _$attachmentType(Message v) => v.attachmentType;
  static const Field<Message, AttachmentType> _f$attachmentType = Field(
    'attachmentType',
    _$attachmentType,
    key: r'attachment_type',
    mode: FieldMode.member,
  );
  static bool _$isSeen(Message v) => v.isSeen;
  static const Field<Message, bool> _f$isSeen = Field(
    'isSeen',
    _$isSeen,
    key: r'is_seen',
    mode: FieldMode.member,
  );
  static int _$hashCode(Message v) => v.hashCode;
  static const Field<Message, int> _f$hashCode = Field(
    'hashCode',
    _$hashCode,
    key: r'hash_code',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Message> fields = const {
    #id: _f$id,
    #sender: _f$sender,
    #receiver: _f$receiver,
    #content: _f$content,
    #attachmentUrl: _f$attachmentUrl,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #seenAt: _f$seenAt,
    #hasAttachment: _f$hasAttachment,
    #status: _f$status,
    #isEdited: _f$isEdited,
    #attachmentType: _f$attachmentType,
    #isSeen: _f$isSeen,
    #hashCode: _f$hashCode,
  };

  static Message _instantiate(DecodingData data) {
    return Message(
      id: data.dec(_f$id),
      sender: data.dec(_f$sender),
      receiver: data.dec(_f$receiver),
      content: data.dec(_f$content),
      attachmentUrl: data.dec(_f$attachmentUrl),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      seenAt: data.dec(_f$seenAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Message fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Message>(map);
  }

  static Message fromJson(String json) {
    return ensureInitialized().decodeJson<Message>(json);
  }
}

mixin MessageMappable {
  String toJson() {
    return MessageMapper.ensureInitialized().encodeJson<Message>(
      this as Message,
    );
  }

  Map<String, dynamic> toMap() {
    return MessageMapper.ensureInitialized().encodeMap<Message>(
      this as Message,
    );
  }

  MessageCopyWith<Message, Message, Message> get copyWith =>
      _MessageCopyWithImpl<Message, Message>(
        this as Message,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MessageMapper.ensureInitialized().stringifyValue(this as Message);
  }

  @override
  bool operator ==(Object other) {
    return MessageMapper.ensureInitialized().equalsValue(
      this as Message,
      other,
    );
  }

  @override
  int get hashCode {
    return MessageMapper.ensureInitialized().hashValue(this as Message);
  }
}

extension MessageValueCopy<$R, $Out> on ObjectCopyWith<$R, Message, $Out> {
  MessageCopyWith<$R, Message, $Out> get $asMessage =>
      $base.as((v, t, t2) => _MessageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MessageCopyWith<$R, $In extends Message, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? sender,
    String? receiver,
    String? content,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? seenAt,
  });
  MessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Message, $Out>
    implements MessageCopyWith<$R, Message, $Out> {
  _MessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Message> $mapper =
      MessageMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? sender,
    String? receiver,
    String? content,
    Object? attachmentUrl = $none,
    DateTime? createdAt,
    Object? updatedAt = $none,
    Object? seenAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (sender != null) #sender: sender,
      if (receiver != null) #receiver: receiver,
      if (content != null) #content: content,
      if (attachmentUrl != $none) #attachmentUrl: attachmentUrl,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (seenAt != $none) #seenAt: seenAt,
    }),
  );
  @override
  Message $make(CopyWithData data) => Message(
    id: data.get(#id, or: $value.id),
    sender: data.get(#sender, or: $value.sender),
    receiver: data.get(#receiver, or: $value.receiver),
    content: data.get(#content, or: $value.content),
    attachmentUrl: data.get(#attachmentUrl, or: $value.attachmentUrl),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    seenAt: data.get(#seenAt, or: $value.seenAt),
  );

  @override
  MessageCopyWith<$R2, Message, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreateMessageRequestMapper extends ClassMapperBase<CreateMessageRequest> {
  CreateMessageRequestMapper._();

  static CreateMessageRequestMapper? _instance;
  static CreateMessageRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CreateMessageRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CreateMessageRequest';

  static String _$receiver(CreateMessageRequest v) => v.receiver;
  static const Field<CreateMessageRequest, String> _f$receiver = Field(
    'receiver',
    _$receiver,
  );
  static String _$content(CreateMessageRequest v) => v.content;
  static const Field<CreateMessageRequest, String> _f$content = Field(
    'content',
    _$content,
  );
  static String? _$attachmentUrl(CreateMessageRequest v) => v.attachmentUrl;
  static const Field<CreateMessageRequest, String> _f$attachmentUrl = Field(
    'attachmentUrl',
    _$attachmentUrl,
    key: r'attachment_url',
    opt: true,
  );

  @override
  final MappableFields<CreateMessageRequest> fields = const {
    #receiver: _f$receiver,
    #content: _f$content,
    #attachmentUrl: _f$attachmentUrl,
  };

  static CreateMessageRequest _instantiate(DecodingData data) {
    return CreateMessageRequest(
      receiver: data.dec(_f$receiver),
      content: data.dec(_f$content),
      attachmentUrl: data.dec(_f$attachmentUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreateMessageRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreateMessageRequest>(map);
  }

  static CreateMessageRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CreateMessageRequest>(json);
  }
}

mixin CreateMessageRequestMappable {
  String toJson() {
    return CreateMessageRequestMapper.ensureInitialized()
        .encodeJson<CreateMessageRequest>(this as CreateMessageRequest);
  }

  Map<String, dynamic> toMap() {
    return CreateMessageRequestMapper.ensureInitialized()
        .encodeMap<CreateMessageRequest>(this as CreateMessageRequest);
  }

  CreateMessageRequestCopyWith<
    CreateMessageRequest,
    CreateMessageRequest,
    CreateMessageRequest
  >
  get copyWith =>
      _CreateMessageRequestCopyWithImpl<
        CreateMessageRequest,
        CreateMessageRequest
      >(this as CreateMessageRequest, $identity, $identity);
  @override
  String toString() {
    return CreateMessageRequestMapper.ensureInitialized().stringifyValue(
      this as CreateMessageRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return CreateMessageRequestMapper.ensureInitialized().equalsValue(
      this as CreateMessageRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CreateMessageRequestMapper.ensureInitialized().hashValue(
      this as CreateMessageRequest,
    );
  }
}

extension CreateMessageRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreateMessageRequest, $Out> {
  CreateMessageRequestCopyWith<$R, CreateMessageRequest, $Out>
  get $asCreateMessageRequest => $base.as(
    (v, t, t2) => _CreateMessageRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CreateMessageRequestCopyWith<
  $R,
  $In extends CreateMessageRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? receiver, String? content, String? attachmentUrl});
  CreateMessageRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CreateMessageRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreateMessageRequest, $Out>
    implements CreateMessageRequestCopyWith<$R, CreateMessageRequest, $Out> {
  _CreateMessageRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CreateMessageRequest> $mapper =
      CreateMessageRequestMapper.ensureInitialized();
  @override
  $R call({String? receiver, String? content, Object? attachmentUrl = $none}) =>
      $apply(
        FieldCopyWithData({
          if (receiver != null) #receiver: receiver,
          if (content != null) #content: content,
          if (attachmentUrl != $none) #attachmentUrl: attachmentUrl,
        }),
      );
  @override
  CreateMessageRequest $make(CopyWithData data) => CreateMessageRequest(
    receiver: data.get(#receiver, or: $value.receiver),
    content: data.get(#content, or: $value.content),
    attachmentUrl: data.get(#attachmentUrl, or: $value.attachmentUrl),
  );

  @override
  CreateMessageRequestCopyWith<$R2, CreateMessageRequest, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CreateMessageRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UpdateMessageRequestMapper extends ClassMapperBase<UpdateMessageRequest> {
  UpdateMessageRequestMapper._();

  static UpdateMessageRequestMapper? _instance;
  static UpdateMessageRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpdateMessageRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UpdateMessageRequest';

  static String? _$content(UpdateMessageRequest v) => v.content;
  static const Field<UpdateMessageRequest, String> _f$content = Field(
    'content',
    _$content,
    opt: true,
  );
  static String? _$attachmentUrl(UpdateMessageRequest v) => v.attachmentUrl;
  static const Field<UpdateMessageRequest, String> _f$attachmentUrl = Field(
    'attachmentUrl',
    _$attachmentUrl,
    key: r'attachment_url',
    opt: true,
  );
  static bool _$isEmpty(UpdateMessageRequest v) => v.isEmpty;
  static const Field<UpdateMessageRequest, bool> _f$isEmpty = Field(
    'isEmpty',
    _$isEmpty,
    key: r'is_empty',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UpdateMessageRequest> fields = const {
    #content: _f$content,
    #attachmentUrl: _f$attachmentUrl,
    #isEmpty: _f$isEmpty,
  };

  static UpdateMessageRequest _instantiate(DecodingData data) {
    return UpdateMessageRequest(
      content: data.dec(_f$content),
      attachmentUrl: data.dec(_f$attachmentUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UpdateMessageRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdateMessageRequest>(map);
  }

  static UpdateMessageRequest fromJson(String json) {
    return ensureInitialized().decodeJson<UpdateMessageRequest>(json);
  }
}

mixin UpdateMessageRequestMappable {
  String toJson() {
    return UpdateMessageRequestMapper.ensureInitialized()
        .encodeJson<UpdateMessageRequest>(this as UpdateMessageRequest);
  }

  Map<String, dynamic> toMap() {
    return UpdateMessageRequestMapper.ensureInitialized()
        .encodeMap<UpdateMessageRequest>(this as UpdateMessageRequest);
  }

  UpdateMessageRequestCopyWith<
    UpdateMessageRequest,
    UpdateMessageRequest,
    UpdateMessageRequest
  >
  get copyWith =>
      _UpdateMessageRequestCopyWithImpl<
        UpdateMessageRequest,
        UpdateMessageRequest
      >(this as UpdateMessageRequest, $identity, $identity);
  @override
  String toString() {
    return UpdateMessageRequestMapper.ensureInitialized().stringifyValue(
      this as UpdateMessageRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return UpdateMessageRequestMapper.ensureInitialized().equalsValue(
      this as UpdateMessageRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return UpdateMessageRequestMapper.ensureInitialized().hashValue(
      this as UpdateMessageRequest,
    );
  }
}

extension UpdateMessageRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpdateMessageRequest, $Out> {
  UpdateMessageRequestCopyWith<$R, UpdateMessageRequest, $Out>
  get $asUpdateMessageRequest => $base.as(
    (v, t, t2) => _UpdateMessageRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UpdateMessageRequestCopyWith<
  $R,
  $In extends UpdateMessageRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? content, String? attachmentUrl});
  UpdateMessageRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UpdateMessageRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpdateMessageRequest, $Out>
    implements UpdateMessageRequestCopyWith<$R, UpdateMessageRequest, $Out> {
  _UpdateMessageRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpdateMessageRequest> $mapper =
      UpdateMessageRequestMapper.ensureInitialized();
  @override
  $R call({Object? content = $none, Object? attachmentUrl = $none}) => $apply(
    FieldCopyWithData({
      if (content != $none) #content: content,
      if (attachmentUrl != $none) #attachmentUrl: attachmentUrl,
    }),
  );
  @override
  UpdateMessageRequest $make(CopyWithData data) => UpdateMessageRequest(
    content: data.get(#content, or: $value.content),
    attachmentUrl: data.get(#attachmentUrl, or: $value.attachmentUrl),
  );

  @override
  UpdateMessageRequestCopyWith<$R2, UpdateMessageRequest, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UpdateMessageRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ChatConversationMapper extends ClassMapperBase<ChatConversation> {
  ChatConversationMapper._();

  static ChatConversationMapper? _instance;
  static ChatConversationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatConversationMapper._());
      MessageMapper.ensureInitialized();
      ConversationTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChatConversation';

  static String _$participantId(ChatConversation v) => v.participantId;
  static const Field<ChatConversation, String> _f$participantId = Field(
    'participantId',
    _$participantId,
    key: r'participant_id',
  );
  static String _$participantName(ChatConversation v) => v.participantName;
  static const Field<ChatConversation, String> _f$participantName = Field(
    'participantName',
    _$participantName,
    key: r'participant_name',
  );
  static String? _$participantProfilePicture(ChatConversation v) =>
      v.participantProfilePicture;
  static const Field<ChatConversation, String> _f$participantProfilePicture =
      Field(
        'participantProfilePicture',
        _$participantProfilePicture,
        key: r'participant_profile_picture',
        opt: true,
      );
  static String? _$participantEmail(ChatConversation v) => v.participantEmail;
  static const Field<ChatConversation, String> _f$participantEmail = Field(
    'participantEmail',
    _$participantEmail,
    key: r'participant_email',
    opt: true,
  );
  static String? _$phoneNumber(ChatConversation v) => v.phoneNumber;
  static const Field<ChatConversation, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    key: r'phone_number',
    opt: true,
  );
  static bool _$isOnline(ChatConversation v) => v.isOnline;
  static const Field<ChatConversation, bool> _f$isOnline = Field(
    'isOnline',
    _$isOnline,
    key: r'is_online',
    opt: true,
    def: false,
  );
  static DateTime? _$lastSeen(ChatConversation v) => v.lastSeen;
  static const Field<ChatConversation, DateTime> _f$lastSeen = Field(
    'lastSeen',
    _$lastSeen,
    key: r'last_seen',
    opt: true,
  );
  static Message? _$lastMessage(ChatConversation v) => v.lastMessage;
  static const Field<ChatConversation, Message> _f$lastMessage = Field(
    'lastMessage',
    _$lastMessage,
    key: r'last_message',
    opt: true,
  );
  static int _$unreadCount(ChatConversation v) => v.unreadCount;
  static const Field<ChatConversation, int> _f$unreadCount = Field(
    'unreadCount',
    _$unreadCount,
    key: r'unread_count',
    opt: true,
    def: 0,
  );
  static DateTime? _$lastActivity(ChatConversation v) => v.lastActivity;
  static const Field<ChatConversation, DateTime> _f$lastActivity = Field(
    'lastActivity',
    _$lastActivity,
    key: r'last_activity',
    opt: true,
  );
  static ConversationType _$type(ChatConversation v) => v.type;
  static const Field<ChatConversation, ConversationType> _f$type = Field(
    'type',
    _$type,
    opt: true,
    def: ConversationType.direct,
  );
  static String _$lastMessagePreview(ChatConversation v) =>
      v.lastMessagePreview;
  static const Field<ChatConversation, String> _f$lastMessagePreview = Field(
    'lastMessagePreview',
    _$lastMessagePreview,
    key: r'last_message_preview',
    mode: FieldMode.member,
  );
  static String _$onlineStatusText(ChatConversation v) => v.onlineStatusText;
  static const Field<ChatConversation, String> _f$onlineStatusText = Field(
    'onlineStatusText',
    _$onlineStatusText,
    key: r'online_status_text',
    mode: FieldMode.member,
  );
  static int _$hashCode(ChatConversation v) => v.hashCode;
  static const Field<ChatConversation, int> _f$hashCode = Field(
    'hashCode',
    _$hashCode,
    key: r'hash_code',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ChatConversation> fields = const {
    #participantId: _f$participantId,
    #participantName: _f$participantName,
    #participantProfilePicture: _f$participantProfilePicture,
    #participantEmail: _f$participantEmail,
    #phoneNumber: _f$phoneNumber,
    #isOnline: _f$isOnline,
    #lastSeen: _f$lastSeen,
    #lastMessage: _f$lastMessage,
    #unreadCount: _f$unreadCount,
    #lastActivity: _f$lastActivity,
    #type: _f$type,
    #lastMessagePreview: _f$lastMessagePreview,
    #onlineStatusText: _f$onlineStatusText,
    #hashCode: _f$hashCode,
  };

  static ChatConversation _instantiate(DecodingData data) {
    return ChatConversation(
      participantId: data.dec(_f$participantId),
      participantName: data.dec(_f$participantName),
      participantProfilePicture: data.dec(_f$participantProfilePicture),
      participantEmail: data.dec(_f$participantEmail),
      phoneNumber: data.dec(_f$phoneNumber),
      isOnline: data.dec(_f$isOnline),
      lastSeen: data.dec(_f$lastSeen),
      lastMessage: data.dec(_f$lastMessage),
      unreadCount: data.dec(_f$unreadCount),
      lastActivity: data.dec(_f$lastActivity),
      type: data.dec(_f$type),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatConversation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatConversation>(map);
  }

  static ChatConversation fromJson(String json) {
    return ensureInitialized().decodeJson<ChatConversation>(json);
  }
}

mixin ChatConversationMappable {
  String toJson() {
    return ChatConversationMapper.ensureInitialized()
        .encodeJson<ChatConversation>(this as ChatConversation);
  }

  Map<String, dynamic> toMap() {
    return ChatConversationMapper.ensureInitialized()
        .encodeMap<ChatConversation>(this as ChatConversation);
  }

  ChatConversationCopyWith<ChatConversation, ChatConversation, ChatConversation>
  get copyWith =>
      _ChatConversationCopyWithImpl<ChatConversation, ChatConversation>(
        this as ChatConversation,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatConversationMapper.ensureInitialized().stringifyValue(
      this as ChatConversation,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatConversationMapper.ensureInitialized().equalsValue(
      this as ChatConversation,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatConversationMapper.ensureInitialized().hashValue(
      this as ChatConversation,
    );
  }
}

extension ChatConversationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatConversation, $Out> {
  ChatConversationCopyWith<$R, ChatConversation, $Out>
  get $asChatConversation =>
      $base.as((v, t, t2) => _ChatConversationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatConversationCopyWith<$R, $In extends ChatConversation, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MessageCopyWith<$R, Message, Message>? get lastMessage;
  $R call({
    String? participantId,
    String? participantName,
    String? participantProfilePicture,
    String? participantEmail,
    String? phoneNumber,
    bool? isOnline,
    DateTime? lastSeen,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    ConversationType? type,
  });
  ChatConversationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ChatConversationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatConversation, $Out>
    implements ChatConversationCopyWith<$R, ChatConversation, $Out> {
  _ChatConversationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatConversation> $mapper =
      ChatConversationMapper.ensureInitialized();
  @override
  MessageCopyWith<$R, Message, Message>? get lastMessage =>
      $value.lastMessage?.copyWith.$chain((v) => call(lastMessage: v));
  @override
  $R call({
    String? participantId,
    String? participantName,
    Object? participantProfilePicture = $none,
    Object? participantEmail = $none,
    Object? phoneNumber = $none,
    bool? isOnline,
    Object? lastSeen = $none,
    Object? lastMessage = $none,
    int? unreadCount,
    Object? lastActivity = $none,
    ConversationType? type,
  }) => $apply(
    FieldCopyWithData({
      if (participantId != null) #participantId: participantId,
      if (participantName != null) #participantName: participantName,
      if (participantProfilePicture != $none)
        #participantProfilePicture: participantProfilePicture,
      if (participantEmail != $none) #participantEmail: participantEmail,
      if (phoneNumber != $none) #phoneNumber: phoneNumber,
      if (isOnline != null) #isOnline: isOnline,
      if (lastSeen != $none) #lastSeen: lastSeen,
      if (lastMessage != $none) #lastMessage: lastMessage,
      if (unreadCount != null) #unreadCount: unreadCount,
      if (lastActivity != $none) #lastActivity: lastActivity,
      if (type != null) #type: type,
    }),
  );
  @override
  ChatConversation $make(CopyWithData data) => ChatConversation(
    participantId: data.get(#participantId, or: $value.participantId),
    participantName: data.get(#participantName, or: $value.participantName),
    participantProfilePicture: data.get(
      #participantProfilePicture,
      or: $value.participantProfilePicture,
    ),
    participantEmail: data.get(#participantEmail, or: $value.participantEmail),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
    isOnline: data.get(#isOnline, or: $value.isOnline),
    lastSeen: data.get(#lastSeen, or: $value.lastSeen),
    lastMessage: data.get(#lastMessage, or: $value.lastMessage),
    unreadCount: data.get(#unreadCount, or: $value.unreadCount),
    lastActivity: data.get(#lastActivity, or: $value.lastActivity),
    type: data.get(#type, or: $value.type),
  );

  @override
  ChatConversationCopyWith<$R2, ChatConversation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatConversationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MessageUserMapper extends ClassMapperBase<MessageUser> {
  MessageUserMapper._();

  static MessageUserMapper? _instance;
  static MessageUserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageUserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MessageUser';

  static String _$id(MessageUser v) => v.id;
  static const Field<MessageUser, String> _f$id = Field('id', _$id);
  static String _$fullName(MessageUser v) => v.fullName;
  static const Field<MessageUser, String> _f$fullName = Field(
    'fullName',
    _$fullName,
    key: r'full_name',
  );
  static String _$email(MessageUser v) => v.email;
  static const Field<MessageUser, String> _f$email = Field('email', _$email);
  static String? _$profilePicture(MessageUser v) => v.profilePicture;
  static const Field<MessageUser, String> _f$profilePicture = Field(
    'profilePicture',
    _$profilePicture,
    key: r'profile_picture',
    opt: true,
  );
  static String _$phoneNumber(MessageUser v) => v.phoneNumber;
  static const Field<MessageUser, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    key: r'phone_number',
  );
  static bool _$isOnline(MessageUser v) => v.isOnline;
  static const Field<MessageUser, bool> _f$isOnline = Field(
    'isOnline',
    _$isOnline,
    key: r'is_online',
    opt: true,
    def: false,
  );
  static DateTime? _$lastSeen(MessageUser v) => v.lastSeen;
  static const Field<MessageUser, DateTime> _f$lastSeen = Field(
    'lastSeen',
    _$lastSeen,
    key: r'last_seen',
    opt: true,
  );
  static DateTime _$createdAt(MessageUser v) => v.createdAt;
  static const Field<MessageUser, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$displayName(MessageUser v) => v.displayName;
  static const Field<MessageUser, String> _f$displayName = Field(
    'displayName',
    _$displayName,
    key: r'display_name',
    mode: FieldMode.member,
  );
  static String _$initials(MessageUser v) => v.initials;
  static const Field<MessageUser, String> _f$initials = Field(
    'initials',
    _$initials,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<MessageUser> fields = const {
    #id: _f$id,
    #fullName: _f$fullName,
    #email: _f$email,
    #profilePicture: _f$profilePicture,
    #phoneNumber: _f$phoneNumber,
    #isOnline: _f$isOnline,
    #lastSeen: _f$lastSeen,
    #createdAt: _f$createdAt,
    #displayName: _f$displayName,
    #initials: _f$initials,
  };

  static MessageUser _instantiate(DecodingData data) {
    return MessageUser(
      id: data.dec(_f$id),
      fullName: data.dec(_f$fullName),
      email: data.dec(_f$email),
      profilePicture: data.dec(_f$profilePicture),
      phoneNumber: data.dec(_f$phoneNumber),
      isOnline: data.dec(_f$isOnline),
      lastSeen: data.dec(_f$lastSeen),
      createdAt: data.dec(_f$createdAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MessageUser fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MessageUser>(map);
  }

  static MessageUser fromJson(String json) {
    return ensureInitialized().decodeJson<MessageUser>(json);
  }
}

mixin MessageUserMappable {
  String toJson() {
    return MessageUserMapper.ensureInitialized().encodeJson<MessageUser>(
      this as MessageUser,
    );
  }

  Map<String, dynamic> toMap() {
    return MessageUserMapper.ensureInitialized().encodeMap<MessageUser>(
      this as MessageUser,
    );
  }

  MessageUserCopyWith<MessageUser, MessageUser, MessageUser> get copyWith =>
      _MessageUserCopyWithImpl<MessageUser, MessageUser>(
        this as MessageUser,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MessageUserMapper.ensureInitialized().stringifyValue(
      this as MessageUser,
    );
  }

  @override
  bool operator ==(Object other) {
    return MessageUserMapper.ensureInitialized().equalsValue(
      this as MessageUser,
      other,
    );
  }

  @override
  int get hashCode {
    return MessageUserMapper.ensureInitialized().hashValue(this as MessageUser);
  }
}

extension MessageUserValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MessageUser, $Out> {
  MessageUserCopyWith<$R, MessageUser, $Out> get $asMessageUser =>
      $base.as((v, t, t2) => _MessageUserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MessageUserCopyWith<$R, $In extends MessageUser, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? fullName,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  });
  MessageUserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MessageUserCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MessageUser, $Out>
    implements MessageUserCopyWith<$R, MessageUser, $Out> {
  _MessageUserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MessageUser> $mapper =
      MessageUserMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? fullName,
    String? email,
    Object? profilePicture = $none,
    String? phoneNumber,
    bool? isOnline,
    Object? lastSeen = $none,
    DateTime? createdAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (fullName != null) #fullName: fullName,
      if (email != null) #email: email,
      if (profilePicture != $none) #profilePicture: profilePicture,
      if (phoneNumber != null) #phoneNumber: phoneNumber,
      if (isOnline != null) #isOnline: isOnline,
      if (lastSeen != $none) #lastSeen: lastSeen,
      if (createdAt != null) #createdAt: createdAt,
    }),
  );
  @override
  MessageUser $make(CopyWithData data) => MessageUser(
    id: data.get(#id, or: $value.id),
    fullName: data.get(#fullName, or: $value.fullName),
    email: data.get(#email, or: $value.email),
    profilePicture: data.get(#profilePicture, or: $value.profilePicture),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
    isOnline: data.get(#isOnline, or: $value.isOnline),
    lastSeen: data.get(#lastSeen, or: $value.lastSeen),
    createdAt: data.get(#createdAt, or: $value.createdAt),
  );

  @override
  MessageUserCopyWith<$R2, MessageUser, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MessageUserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MessageThreadMapper extends ClassMapperBase<MessageThread> {
  MessageThreadMapper._();

  static MessageThreadMapper? _instance;
  static MessageThreadMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageThreadMapper._());
      ConversationTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MessageThread';

  static String _$id(MessageThread v) => v.id;
  static const Field<MessageThread, String> _f$id = Field('id', _$id);
  static List<String> _$participants(MessageThread v) => v.participants;
  static const Field<MessageThread, List<String>> _f$participants = Field(
    'participants',
    _$participants,
  );
  static String? _$title(MessageThread v) => v.title;
  static const Field<MessageThread, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
  );
  static ConversationType _$type(MessageThread v) => v.type;
  static const Field<MessageThread, ConversationType> _f$type = Field(
    'type',
    _$type,
  );
  static DateTime _$createdAt(MessageThread v) => v.createdAt;
  static const Field<MessageThread, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime? _$updatedAt(MessageThread v) => v.updatedAt;
  static const Field<MessageThread, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static String? _$lastMessageId(MessageThread v) => v.lastMessageId;
  static const Field<MessageThread, String> _f$lastMessageId = Field(
    'lastMessageId',
    _$lastMessageId,
    key: r'last_message_id',
    opt: true,
  );
  static bool _$isArchived(MessageThread v) => v.isArchived;
  static const Field<MessageThread, bool> _f$isArchived = Field(
    'isArchived',
    _$isArchived,
    key: r'is_archived',
    opt: true,
    def: false,
  );
  static bool _$isMuted(MessageThread v) => v.isMuted;
  static const Field<MessageThread, bool> _f$isMuted = Field(
    'isMuted',
    _$isMuted,
    key: r'is_muted',
    opt: true,
    def: false,
  );

  @override
  final MappableFields<MessageThread> fields = const {
    #id: _f$id,
    #participants: _f$participants,
    #title: _f$title,
    #type: _f$type,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #lastMessageId: _f$lastMessageId,
    #isArchived: _f$isArchived,
    #isMuted: _f$isMuted,
  };

  static MessageThread _instantiate(DecodingData data) {
    return MessageThread(
      id: data.dec(_f$id),
      participants: data.dec(_f$participants),
      title: data.dec(_f$title),
      type: data.dec(_f$type),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      lastMessageId: data.dec(_f$lastMessageId),
      isArchived: data.dec(_f$isArchived),
      isMuted: data.dec(_f$isMuted),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MessageThread fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MessageThread>(map);
  }

  static MessageThread fromJson(String json) {
    return ensureInitialized().decodeJson<MessageThread>(json);
  }
}

mixin MessageThreadMappable {
  String toJson() {
    return MessageThreadMapper.ensureInitialized().encodeJson<MessageThread>(
      this as MessageThread,
    );
  }

  Map<String, dynamic> toMap() {
    return MessageThreadMapper.ensureInitialized().encodeMap<MessageThread>(
      this as MessageThread,
    );
  }

  MessageThreadCopyWith<MessageThread, MessageThread, MessageThread>
  get copyWith => _MessageThreadCopyWithImpl<MessageThread, MessageThread>(
    this as MessageThread,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MessageThreadMapper.ensureInitialized().stringifyValue(
      this as MessageThread,
    );
  }

  @override
  bool operator ==(Object other) {
    return MessageThreadMapper.ensureInitialized().equalsValue(
      this as MessageThread,
      other,
    );
  }

  @override
  int get hashCode {
    return MessageThreadMapper.ensureInitialized().hashValue(
      this as MessageThread,
    );
  }
}

extension MessageThreadValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MessageThread, $Out> {
  MessageThreadCopyWith<$R, MessageThread, $Out> get $asMessageThread =>
      $base.as((v, t, t2) => _MessageThreadCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MessageThreadCopyWith<$R, $In extends MessageThread, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get participants;
  $R call({
    String? id,
    List<String>? participants,
    String? title,
    ConversationType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    bool? isArchived,
    bool? isMuted,
  });
  MessageThreadCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MessageThreadCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MessageThread, $Out>
    implements MessageThreadCopyWith<$R, MessageThread, $Out> {
  _MessageThreadCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MessageThread> $mapper =
      MessageThreadMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get participants => ListCopyWith(
    $value.participants,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(participants: v),
  );
  @override
  $R call({
    String? id,
    List<String>? participants,
    Object? title = $none,
    ConversationType? type,
    DateTime? createdAt,
    Object? updatedAt = $none,
    Object? lastMessageId = $none,
    bool? isArchived,
    bool? isMuted,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (participants != null) #participants: participants,
      if (title != $none) #title: title,
      if (type != null) #type: type,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (lastMessageId != $none) #lastMessageId: lastMessageId,
      if (isArchived != null) #isArchived: isArchived,
      if (isMuted != null) #isMuted: isMuted,
    }),
  );
  @override
  MessageThread $make(CopyWithData data) => MessageThread(
    id: data.get(#id, or: $value.id),
    participants: data.get(#participants, or: $value.participants),
    title: data.get(#title, or: $value.title),
    type: data.get(#type, or: $value.type),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    lastMessageId: data.get(#lastMessageId, or: $value.lastMessageId),
    isArchived: data.get(#isArchived, or: $value.isArchived),
    isMuted: data.get(#isMuted, or: $value.isMuted),
  );

  @override
  MessageThreadCopyWith<$R2, MessageThread, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MessageThreadCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MessageSearchResultMapper extends ClassMapperBase<MessageSearchResult> {
  MessageSearchResultMapper._();

  static MessageSearchResultMapper? _instance;
  static MessageSearchResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageSearchResultMapper._());
      MessageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MessageSearchResult';

  static Message _$message(MessageSearchResult v) => v.message;
  static const Field<MessageSearchResult, Message> _f$message = Field(
    'message',
    _$message,
  );
  static String _$conversationId(MessageSearchResult v) => v.conversationId;
  static const Field<MessageSearchResult, String> _f$conversationId = Field(
    'conversationId',
    _$conversationId,
    key: r'conversation_id',
  );
  static String _$conversationName(MessageSearchResult v) => v.conversationName;
  static const Field<MessageSearchResult, String> _f$conversationName = Field(
    'conversationName',
    _$conversationName,
    key: r'conversation_name',
  );
  static List<String> _$matchedTerms(MessageSearchResult v) => v.matchedTerms;
  static const Field<MessageSearchResult, List<String>> _f$matchedTerms = Field(
    'matchedTerms',
    _$matchedTerms,
    key: r'matched_terms',
  );

  @override
  final MappableFields<MessageSearchResult> fields = const {
    #message: _f$message,
    #conversationId: _f$conversationId,
    #conversationName: _f$conversationName,
    #matchedTerms: _f$matchedTerms,
  };

  static MessageSearchResult _instantiate(DecodingData data) {
    return MessageSearchResult(
      message: data.dec(_f$message),
      conversationId: data.dec(_f$conversationId),
      conversationName: data.dec(_f$conversationName),
      matchedTerms: data.dec(_f$matchedTerms),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MessageSearchResult fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MessageSearchResult>(map);
  }

  static MessageSearchResult fromJson(String json) {
    return ensureInitialized().decodeJson<MessageSearchResult>(json);
  }
}

mixin MessageSearchResultMappable {
  String toJson() {
    return MessageSearchResultMapper.ensureInitialized()
        .encodeJson<MessageSearchResult>(this as MessageSearchResult);
  }

  Map<String, dynamic> toMap() {
    return MessageSearchResultMapper.ensureInitialized()
        .encodeMap<MessageSearchResult>(this as MessageSearchResult);
  }

  MessageSearchResultCopyWith<
    MessageSearchResult,
    MessageSearchResult,
    MessageSearchResult
  >
  get copyWith =>
      _MessageSearchResultCopyWithImpl<
        MessageSearchResult,
        MessageSearchResult
      >(this as MessageSearchResult, $identity, $identity);
  @override
  String toString() {
    return MessageSearchResultMapper.ensureInitialized().stringifyValue(
      this as MessageSearchResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return MessageSearchResultMapper.ensureInitialized().equalsValue(
      this as MessageSearchResult,
      other,
    );
  }

  @override
  int get hashCode {
    return MessageSearchResultMapper.ensureInitialized().hashValue(
      this as MessageSearchResult,
    );
  }
}

extension MessageSearchResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MessageSearchResult, $Out> {
  MessageSearchResultCopyWith<$R, MessageSearchResult, $Out>
  get $asMessageSearchResult => $base.as(
    (v, t, t2) => _MessageSearchResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MessageSearchResultCopyWith<
  $R,
  $In extends MessageSearchResult,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  MessageCopyWith<$R, Message, Message> get message;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get matchedTerms;
  $R call({
    Message? message,
    String? conversationId,
    String? conversationName,
    List<String>? matchedTerms,
  });
  MessageSearchResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MessageSearchResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MessageSearchResult, $Out>
    implements MessageSearchResultCopyWith<$R, MessageSearchResult, $Out> {
  _MessageSearchResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MessageSearchResult> $mapper =
      MessageSearchResultMapper.ensureInitialized();
  @override
  MessageCopyWith<$R, Message, Message> get message =>
      $value.message.copyWith.$chain((v) => call(message: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get matchedTerms => ListCopyWith(
    $value.matchedTerms,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(matchedTerms: v),
  );
  @override
  $R call({
    Message? message,
    String? conversationId,
    String? conversationName,
    List<String>? matchedTerms,
  }) => $apply(
    FieldCopyWithData({
      if (message != null) #message: message,
      if (conversationId != null) #conversationId: conversationId,
      if (conversationName != null) #conversationName: conversationName,
      if (matchedTerms != null) #matchedTerms: matchedTerms,
    }),
  );
  @override
  MessageSearchResult $make(CopyWithData data) => MessageSearchResult(
    message: data.get(#message, or: $value.message),
    conversationId: data.get(#conversationId, or: $value.conversationId),
    conversationName: data.get(#conversationName, or: $value.conversationName),
    matchedTerms: data.get(#matchedTerms, or: $value.matchedTerms),
  );

  @override
  MessageSearchResultCopyWith<$R2, MessageSearchResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MessageSearchResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TypingIndicatorMapper extends ClassMapperBase<TypingIndicator> {
  TypingIndicatorMapper._();

  static TypingIndicatorMapper? _instance;
  static TypingIndicatorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TypingIndicatorMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TypingIndicator';

  static String _$userId(TypingIndicator v) => v.userId;
  static const Field<TypingIndicator, String> _f$userId = Field(
    'userId',
    _$userId,
    key: r'user_id',
  );
  static String _$conversationId(TypingIndicator v) => v.conversationId;
  static const Field<TypingIndicator, String> _f$conversationId = Field(
    'conversationId',
    _$conversationId,
    key: r'conversation_id',
  );
  static DateTime _$timestamp(TypingIndicator v) => v.timestamp;
  static const Field<TypingIndicator, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static bool _$isActive(TypingIndicator v) => v.isActive;
  static const Field<TypingIndicator, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    key: r'is_active',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<TypingIndicator> fields = const {
    #userId: _f$userId,
    #conversationId: _f$conversationId,
    #timestamp: _f$timestamp,
    #isActive: _f$isActive,
  };

  static TypingIndicator _instantiate(DecodingData data) {
    return TypingIndicator(
      userId: data.dec(_f$userId),
      conversationId: data.dec(_f$conversationId),
      timestamp: data.dec(_f$timestamp),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TypingIndicator fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TypingIndicator>(map);
  }

  static TypingIndicator fromJson(String json) {
    return ensureInitialized().decodeJson<TypingIndicator>(json);
  }
}

mixin TypingIndicatorMappable {
  String toJson() {
    return TypingIndicatorMapper.ensureInitialized()
        .encodeJson<TypingIndicator>(this as TypingIndicator);
  }

  Map<String, dynamic> toMap() {
    return TypingIndicatorMapper.ensureInitialized().encodeMap<TypingIndicator>(
      this as TypingIndicator,
    );
  }

  TypingIndicatorCopyWith<TypingIndicator, TypingIndicator, TypingIndicator>
  get copyWith =>
      _TypingIndicatorCopyWithImpl<TypingIndicator, TypingIndicator>(
        this as TypingIndicator,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TypingIndicatorMapper.ensureInitialized().stringifyValue(
      this as TypingIndicator,
    );
  }

  @override
  bool operator ==(Object other) {
    return TypingIndicatorMapper.ensureInitialized().equalsValue(
      this as TypingIndicator,
      other,
    );
  }

  @override
  int get hashCode {
    return TypingIndicatorMapper.ensureInitialized().hashValue(
      this as TypingIndicator,
    );
  }
}

extension TypingIndicatorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TypingIndicator, $Out> {
  TypingIndicatorCopyWith<$R, TypingIndicator, $Out> get $asTypingIndicator =>
      $base.as((v, t, t2) => _TypingIndicatorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TypingIndicatorCopyWith<$R, $In extends TypingIndicator, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? userId, String? conversationId, DateTime? timestamp});
  TypingIndicatorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TypingIndicatorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TypingIndicator, $Out>
    implements TypingIndicatorCopyWith<$R, TypingIndicator, $Out> {
  _TypingIndicatorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TypingIndicator> $mapper =
      TypingIndicatorMapper.ensureInitialized();
  @override
  $R call({String? userId, String? conversationId, DateTime? timestamp}) =>
      $apply(
        FieldCopyWithData({
          if (userId != null) #userId: userId,
          if (conversationId != null) #conversationId: conversationId,
          if (timestamp != null) #timestamp: timestamp,
        }),
      );
  @override
  TypingIndicator $make(CopyWithData data) => TypingIndicator(
    userId: data.get(#userId, or: $value.userId),
    conversationId: data.get(#conversationId, or: $value.conversationId),
    timestamp: data.get(#timestamp, or: $value.timestamp),
  );

  @override
  TypingIndicatorCopyWith<$R2, TypingIndicator, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TypingIndicatorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

