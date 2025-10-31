// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'post_comment.dart';

class PostCommentMapper extends ClassMapperBase<PostComment> {
  PostCommentMapper._();

  static PostCommentMapper? _instance;
  static PostCommentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostCommentMapper._());
      ProfileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PostComment';

  static int _$id(PostComment v) => v.id;
  static const Field<PostComment, int> _f$id = Field('id', _$id);
  static String? _$comment(PostComment v) => v.comment;
  static const Field<PostComment, String> _f$comment = Field(
    'comment',
    _$comment,
    opt: true,
  );
  static DateTime _$createdAt(PostComment v) => v.createdAt;
  static const Field<PostComment, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static Profile? _$user(PostComment v) => v.user;
  static const Field<PostComment, Profile> _f$user = Field(
    'user',
    _$user,
    opt: true,
  );
  static int _$post(PostComment v) => v.post;
  static const Field<PostComment, int> _f$post = Field('post', _$post);

  @override
  final MappableFields<PostComment> fields = const {
    #id: _f$id,
    #comment: _f$comment,
    #createdAt: _f$createdAt,
    #user: _f$user,
    #post: _f$post,
  };

  static PostComment _instantiate(DecodingData data) {
    return PostComment(
      id: data.dec(_f$id),
      comment: data.dec(_f$comment),
      createdAt: data.dec(_f$createdAt),
      user: data.dec(_f$user),
      post: data.dec(_f$post),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PostComment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PostComment>(map);
  }

  static PostComment fromJson(String json) {
    return ensureInitialized().decodeJson<PostComment>(json);
  }
}

mixin PostCommentMappable {
  String toJson() {
    return PostCommentMapper.ensureInitialized().encodeJson<PostComment>(
      this as PostComment,
    );
  }

  Map<String, dynamic> toMap() {
    return PostCommentMapper.ensureInitialized().encodeMap<PostComment>(
      this as PostComment,
    );
  }

  PostCommentCopyWith<PostComment, PostComment, PostComment> get copyWith =>
      _PostCommentCopyWithImpl<PostComment, PostComment>(
        this as PostComment,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PostCommentMapper.ensureInitialized().stringifyValue(
      this as PostComment,
    );
  }

  @override
  bool operator ==(Object other) {
    return PostCommentMapper.ensureInitialized().equalsValue(
      this as PostComment,
      other,
    );
  }

  @override
  int get hashCode {
    return PostCommentMapper.ensureInitialized().hashValue(this as PostComment);
  }
}

extension PostCommentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PostComment, $Out> {
  PostCommentCopyWith<$R, PostComment, $Out> get $asPostComment =>
      $base.as((v, t, t2) => _PostCommentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PostCommentCopyWith<$R, $In extends PostComment, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProfileCopyWith<$R, Profile, Profile>? get user;
  $R call({
    int? id,
    String? comment,
    DateTime? createdAt,
    Profile? user,
    int? post,
  });
  PostCommentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PostCommentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PostComment, $Out>
    implements PostCommentCopyWith<$R, PostComment, $Out> {
  _PostCommentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PostComment> $mapper =
      PostCommentMapper.ensureInitialized();
  @override
  ProfileCopyWith<$R, Profile, Profile>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  $R call({
    int? id,
    Object? comment = $none,
    DateTime? createdAt,
    Object? user = $none,
    int? post,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (comment != $none) #comment: comment,
      if (createdAt != null) #createdAt: createdAt,
      if (user != $none) #user: user,
      if (post != null) #post: post,
    }),
  );
  @override
  PostComment $make(CopyWithData data) => PostComment(
    id: data.get(#id, or: $value.id),
    comment: data.get(#comment, or: $value.comment),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    user: data.get(#user, or: $value.user),
    post: data.get(#post, or: $value.post),
  );

  @override
  PostCommentCopyWith<$R2, PostComment, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PostCommentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

