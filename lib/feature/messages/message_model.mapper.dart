// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'message_model.dart';

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
  static bool _$hasAttachment(Message v) => v.hasAttachment;
  static const Field<Message, bool> _f$hasAttachment = Field(
    'hasAttachment',
    _$hasAttachment,
    key: r'has_attachment',
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
    #hasAttachment: _f$hasAttachment,
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
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (sender != null) #sender: sender,
      if (receiver != null) #receiver: receiver,
      if (content != null) #content: content,
      if (attachmentUrl != $none) #attachmentUrl: attachmentUrl,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
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
  );

  @override
  MessageCopyWith<$R2, Message, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

