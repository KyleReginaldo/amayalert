// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'post_model.dart';

class PostVisibilityMapper extends EnumMapper<PostVisibility> {
  PostVisibilityMapper._();

  static PostVisibilityMapper? _instance;
  static PostVisibilityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostVisibilityMapper._());
    }
    return _instance!;
  }

  static PostVisibility fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PostVisibility decode(dynamic value) {
    switch (value) {
      case r'public':
        return PostVisibility.public;
      case r'friends':
        return PostVisibility.friends;
      case r'private':
        return PostVisibility.private;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PostVisibility self) {
    switch (self) {
      case PostVisibility.public:
        return r'public';
      case PostVisibility.friends:
        return r'friends';
      case PostVisibility.private:
        return r'private';
    }
  }
}

extension PostVisibilityMapperExtension on PostVisibility {
  String toValue() {
    PostVisibilityMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PostVisibility>(this) as String;
  }
}

class PostMapper extends ClassMapperBase<Post> {
  PostMapper._();

  static PostMapper? _instance;
  static PostMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostMapper._());
      ProfileMapper.ensureInitialized();
      PostVisibilityMapper.ensureInitialized();
      PostCommentMapper.ensureInitialized();
      PostMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Post';

  static int _$id(Post v) => v.id;
  static const Field<Post, int> _f$id = Field('id', _$id);
  static Profile _$user(Post v) => v.user;
  static const Field<Post, Profile> _f$user = Field('user', _$user);
  static String _$content(Post v) => v.content;
  static const Field<Post, String> _f$content = Field('content', _$content);
  static String? _$mediaUrl(Post v) => v.mediaUrl;
  static const Field<Post, String> _f$mediaUrl = Field(
    'mediaUrl',
    _$mediaUrl,
    key: r'media_url',
    opt: true,
  );
  static PostVisibility _$visibility(Post v) => v.visibility;
  static const Field<Post, PostVisibility> _f$visibility = Field(
    'visibility',
    _$visibility,
  );
  static DateTime _$createdAt(Post v) => v.createdAt;
  static const Field<Post, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime? _$updatedAt(Post v) => v.updatedAt;
  static const Field<Post, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static List<PostComment>? _$comments(Post v) => v.comments;
  static const Field<Post, List<PostComment>> _f$comments = Field(
    'comments',
    _$comments,
    opt: true,
  );
  static Post? _$sharedPost(Post v) => v.sharedPost;
  static const Field<Post, Post> _f$sharedPost = Field(
    'sharedPost',
    _$sharedPost,
    key: r'shared_post',
    opt: true,
  );
  static bool _$hasMedia(Post v) => v.hasMedia;
  static const Field<Post, bool> _f$hasMedia = Field(
    'hasMedia',
    _$hasMedia,
    key: r'has_media',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Post> fields = const {
    #id: _f$id,
    #user: _f$user,
    #content: _f$content,
    #mediaUrl: _f$mediaUrl,
    #visibility: _f$visibility,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #comments: _f$comments,
    #sharedPost: _f$sharedPost,
    #hasMedia: _f$hasMedia,
  };

  static Post _instantiate(DecodingData data) {
    return Post(
      id: data.dec(_f$id),
      user: data.dec(_f$user),
      content: data.dec(_f$content),
      mediaUrl: data.dec(_f$mediaUrl),
      visibility: data.dec(_f$visibility),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      comments: data.dec(_f$comments),
      sharedPost: data.dec(_f$sharedPost),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Post fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Post>(map);
  }

  static Post fromJson(String json) {
    return ensureInitialized().decodeJson<Post>(json);
  }
}

mixin PostMappable {
  String toJson() {
    return PostMapper.ensureInitialized().encodeJson<Post>(this as Post);
  }

  Map<String, dynamic> toMap() {
    return PostMapper.ensureInitialized().encodeMap<Post>(this as Post);
  }

  PostCopyWith<Post, Post, Post> get copyWith =>
      _PostCopyWithImpl<Post, Post>(this as Post, $identity, $identity);
  @override
  String toString() {
    return PostMapper.ensureInitialized().stringifyValue(this as Post);
  }

  @override
  bool operator ==(Object other) {
    return PostMapper.ensureInitialized().equalsValue(this as Post, other);
  }

  @override
  int get hashCode {
    return PostMapper.ensureInitialized().hashValue(this as Post);
  }
}

extension PostValueCopy<$R, $Out> on ObjectCopyWith<$R, Post, $Out> {
  PostCopyWith<$R, Post, $Out> get $asPost =>
      $base.as((v, t, t2) => _PostCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PostCopyWith<$R, $In extends Post, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProfileCopyWith<$R, Profile, Profile> get user;
  ListCopyWith<
    $R,
    PostComment,
    PostCommentCopyWith<$R, PostComment, PostComment>
  >?
  get comments;
  PostCopyWith<$R, Post, Post>? get sharedPost;
  $R call({
    int? id,
    Profile? user,
    String? content,
    String? mediaUrl,
    PostVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PostComment>? comments,
    Post? sharedPost,
  });
  PostCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PostCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Post, $Out>
    implements PostCopyWith<$R, Post, $Out> {
  _PostCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Post> $mapper = PostMapper.ensureInitialized();
  @override
  ProfileCopyWith<$R, Profile, Profile> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  ListCopyWith<
    $R,
    PostComment,
    PostCommentCopyWith<$R, PostComment, PostComment>
  >?
  get comments => $value.comments != null
      ? ListCopyWith(
          $value.comments!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(comments: v),
        )
      : null;
  @override
  PostCopyWith<$R, Post, Post>? get sharedPost =>
      $value.sharedPost?.copyWith.$chain((v) => call(sharedPost: v));
  @override
  $R call({
    int? id,
    Profile? user,
    String? content,
    Object? mediaUrl = $none,
    PostVisibility? visibility,
    DateTime? createdAt,
    Object? updatedAt = $none,
    Object? comments = $none,
    Object? sharedPost = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (user != null) #user: user,
      if (content != null) #content: content,
      if (mediaUrl != $none) #mediaUrl: mediaUrl,
      if (visibility != null) #visibility: visibility,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (comments != $none) #comments: comments,
      if (sharedPost != $none) #sharedPost: sharedPost,
    }),
  );
  @override
  Post $make(CopyWithData data) => Post(
    id: data.get(#id, or: $value.id),
    user: data.get(#user, or: $value.user),
    content: data.get(#content, or: $value.content),
    mediaUrl: data.get(#mediaUrl, or: $value.mediaUrl),
    visibility: data.get(#visibility, or: $value.visibility),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    comments: data.get(#comments, or: $value.comments),
    sharedPost: data.get(#sharedPost, or: $value.sharedPost),
  );

  @override
  PostCopyWith<$R2, Post, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PostCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreatePostRequestMapper extends ClassMapperBase<CreatePostRequest> {
  CreatePostRequestMapper._();

  static CreatePostRequestMapper? _instance;
  static CreatePostRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CreatePostRequestMapper._());
      PostVisibilityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CreatePostRequest';

  static String _$user(CreatePostRequest v) => v.user;
  static const Field<CreatePostRequest, String> _f$user = Field('user', _$user);
  static String _$content(CreatePostRequest v) => v.content;
  static const Field<CreatePostRequest, String> _f$content = Field(
    'content',
    _$content,
  );
  static String? _$mediaUrl(CreatePostRequest v) => v.mediaUrl;
  static const Field<CreatePostRequest, String> _f$mediaUrl = Field(
    'mediaUrl',
    _$mediaUrl,
    key: r'media_url',
    opt: true,
  );
  static PostVisibility _$visibility(CreatePostRequest v) => v.visibility;
  static const Field<CreatePostRequest, PostVisibility> _f$visibility = Field(
    'visibility',
    _$visibility,
    opt: true,
    def: PostVisibility.public,
  );

  @override
  final MappableFields<CreatePostRequest> fields = const {
    #user: _f$user,
    #content: _f$content,
    #mediaUrl: _f$mediaUrl,
    #visibility: _f$visibility,
  };

  static CreatePostRequest _instantiate(DecodingData data) {
    return CreatePostRequest(
      user: data.dec(_f$user),
      content: data.dec(_f$content),
      mediaUrl: data.dec(_f$mediaUrl),
      visibility: data.dec(_f$visibility),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreatePostRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreatePostRequest>(map);
  }

  static CreatePostRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CreatePostRequest>(json);
  }
}

mixin CreatePostRequestMappable {
  String toJson() {
    return CreatePostRequestMapper.ensureInitialized()
        .encodeJson<CreatePostRequest>(this as CreatePostRequest);
  }

  Map<String, dynamic> toMap() {
    return CreatePostRequestMapper.ensureInitialized()
        .encodeMap<CreatePostRequest>(this as CreatePostRequest);
  }

  CreatePostRequestCopyWith<
    CreatePostRequest,
    CreatePostRequest,
    CreatePostRequest
  >
  get copyWith =>
      _CreatePostRequestCopyWithImpl<CreatePostRequest, CreatePostRequest>(
        this as CreatePostRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CreatePostRequestMapper.ensureInitialized().stringifyValue(
      this as CreatePostRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return CreatePostRequestMapper.ensureInitialized().equalsValue(
      this as CreatePostRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CreatePostRequestMapper.ensureInitialized().hashValue(
      this as CreatePostRequest,
    );
  }
}

extension CreatePostRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreatePostRequest, $Out> {
  CreatePostRequestCopyWith<$R, CreatePostRequest, $Out>
  get $asCreatePostRequest => $base.as(
    (v, t, t2) => _CreatePostRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CreatePostRequestCopyWith<
  $R,
  $In extends CreatePostRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? user,
    String? content,
    String? mediaUrl,
    PostVisibility? visibility,
  });
  CreatePostRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CreatePostRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreatePostRequest, $Out>
    implements CreatePostRequestCopyWith<$R, CreatePostRequest, $Out> {
  _CreatePostRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CreatePostRequest> $mapper =
      CreatePostRequestMapper.ensureInitialized();
  @override
  $R call({
    String? user,
    String? content,
    Object? mediaUrl = $none,
    PostVisibility? visibility,
  }) => $apply(
    FieldCopyWithData({
      if (user != null) #user: user,
      if (content != null) #content: content,
      if (mediaUrl != $none) #mediaUrl: mediaUrl,
      if (visibility != null) #visibility: visibility,
    }),
  );
  @override
  CreatePostRequest $make(CopyWithData data) => CreatePostRequest(
    user: data.get(#user, or: $value.user),
    content: data.get(#content, or: $value.content),
    mediaUrl: data.get(#mediaUrl, or: $value.mediaUrl),
    visibility: data.get(#visibility, or: $value.visibility),
  );

  @override
  CreatePostRequestCopyWith<$R2, CreatePostRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CreatePostRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UpdatePostRequestMapper extends ClassMapperBase<UpdatePostRequest> {
  UpdatePostRequestMapper._();

  static UpdatePostRequestMapper? _instance;
  static UpdatePostRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpdatePostRequestMapper._());
      PostVisibilityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UpdatePostRequest';

  static String? _$content(UpdatePostRequest v) => v.content;
  static const Field<UpdatePostRequest, String> _f$content = Field(
    'content',
    _$content,
    opt: true,
  );
  static String? _$mediaUrl(UpdatePostRequest v) => v.mediaUrl;
  static const Field<UpdatePostRequest, String> _f$mediaUrl = Field(
    'mediaUrl',
    _$mediaUrl,
    key: r'media_url',
    opt: true,
  );
  static PostVisibility? _$visibility(UpdatePostRequest v) => v.visibility;
  static const Field<UpdatePostRequest, PostVisibility> _f$visibility = Field(
    'visibility',
    _$visibility,
    opt: true,
  );
  static bool _$isEmpty(UpdatePostRequest v) => v.isEmpty;
  static const Field<UpdatePostRequest, bool> _f$isEmpty = Field(
    'isEmpty',
    _$isEmpty,
    key: r'is_empty',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UpdatePostRequest> fields = const {
    #content: _f$content,
    #mediaUrl: _f$mediaUrl,
    #visibility: _f$visibility,
    #isEmpty: _f$isEmpty,
  };

  static UpdatePostRequest _instantiate(DecodingData data) {
    return UpdatePostRequest(
      content: data.dec(_f$content),
      mediaUrl: data.dec(_f$mediaUrl),
      visibility: data.dec(_f$visibility),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UpdatePostRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdatePostRequest>(map);
  }

  static UpdatePostRequest fromJson(String json) {
    return ensureInitialized().decodeJson<UpdatePostRequest>(json);
  }
}

mixin UpdatePostRequestMappable {
  String toJson() {
    return UpdatePostRequestMapper.ensureInitialized()
        .encodeJson<UpdatePostRequest>(this as UpdatePostRequest);
  }

  Map<String, dynamic> toMap() {
    return UpdatePostRequestMapper.ensureInitialized()
        .encodeMap<UpdatePostRequest>(this as UpdatePostRequest);
  }

  UpdatePostRequestCopyWith<
    UpdatePostRequest,
    UpdatePostRequest,
    UpdatePostRequest
  >
  get copyWith =>
      _UpdatePostRequestCopyWithImpl<UpdatePostRequest, UpdatePostRequest>(
        this as UpdatePostRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UpdatePostRequestMapper.ensureInitialized().stringifyValue(
      this as UpdatePostRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return UpdatePostRequestMapper.ensureInitialized().equalsValue(
      this as UpdatePostRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return UpdatePostRequestMapper.ensureInitialized().hashValue(
      this as UpdatePostRequest,
    );
  }
}

extension UpdatePostRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpdatePostRequest, $Out> {
  UpdatePostRequestCopyWith<$R, UpdatePostRequest, $Out>
  get $asUpdatePostRequest => $base.as(
    (v, t, t2) => _UpdatePostRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UpdatePostRequestCopyWith<
  $R,
  $In extends UpdatePostRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? content, String? mediaUrl, PostVisibility? visibility});
  UpdatePostRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UpdatePostRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpdatePostRequest, $Out>
    implements UpdatePostRequestCopyWith<$R, UpdatePostRequest, $Out> {
  _UpdatePostRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpdatePostRequest> $mapper =
      UpdatePostRequestMapper.ensureInitialized();
  @override
  $R call({
    Object? content = $none,
    Object? mediaUrl = $none,
    Object? visibility = $none,
  }) => $apply(
    FieldCopyWithData({
      if (content != $none) #content: content,
      if (mediaUrl != $none) #mediaUrl: mediaUrl,
      if (visibility != $none) #visibility: visibility,
    }),
  );
  @override
  UpdatePostRequest $make(CopyWithData data) => UpdatePostRequest(
    content: data.get(#content, or: $value.content),
    mediaUrl: data.get(#mediaUrl, or: $value.mediaUrl),
    visibility: data.get(#visibility, or: $value.visibility),
  );

  @override
  UpdatePostRequestCopyWith<$R2, UpdatePostRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UpdatePostRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

