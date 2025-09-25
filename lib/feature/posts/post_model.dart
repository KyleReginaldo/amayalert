import 'package:dart_mappable/dart_mappable.dart';import 'package:dart_mappable/dart_mappable.dart';import 'package:dart_mappable/dart_mappable.dart';



part 'post_model.mapper.dart';



@MappableClass(caseStyle: CaseStyle.snakeCase)part 'post_model.mapper.dart';part 'post_model.mapper.dart';

class Post with PostMappable {

  final int id;

  final String user;

  final String content;@MappableClass(caseStyle: CaseStyle.snakeCase)@MappableClass(caseStyle: CaseStyle.snakeCase)

  final String? mediaUrl;

  final PostVisibility visibility;class Post with PostMappable {class Post with PostMappable {

  final DateTime createdAt;

  final DateTime? updatedAt;  final int id;  final int id;



  const Post({  final String user; // Changed from userId to match database schema  final String user; // Changed from userId to match database schema

    required this.id,

    required this.user,  final String content;  final String content;

    required this.content,

    this.mediaUrl,  final String? mediaUrl;  final String? mediaUrl;

    required this.visibility,

    required this.createdAt,  final PostVisibility visibility;  final PostVisibility visibility;

    this.updatedAt,

  });  final DateTime createdAt;  final DateTime createdAt;

}

  final DateTime? updatedAt; // Made nullable to match database schema  final DateTime? updatedAt; // Made nullable to match database schema

enum PostVisibility {

  public,

  friends,

  private;  const Post({  const Post({



  String get value {    required this.id,    required this.id,

    switch (this) {

      case PostVisibility.public:    required this.user,    required this.user,

        return 'public';

      case PostVisibility.friends:    required this.content,    required this.content,

        return 'friends';

      case PostVisibility.private:    this.mediaUrl,    this.mediaUrl,

        return 'private';

    }    required this.visibility,    required this.visibility,

  }

    required this.createdAt,    required this.createdAt,

  static PostVisibility fromString(String? value) {

    if (value == null) return PostVisibility.public;    this.updatedAt,    this.updatedAt,

    switch (value.toLowerCase()) {

      case 'public':  });  });

        return PostVisibility.public;

      case 'friends':}}

        return PostVisibility.friends;

      case 'private':      updatedAt: json['updated_at'] != null

        return PostVisibility.private;

      default:/// Enum for post visibility levels          ? DateTime.parse(json['updated_at'] as String)

        return PostVisibility.public;

    }enum PostVisibility {          : null,

  }

  public,    );

  String get displayName {

    switch (this) {  friends,  }

      case PostVisibility.public:

        return 'Public';  private;

      case PostVisibility.friends:

        return 'Friends Only';  /// Converts Post to JSON for database insertion

      case PostVisibility.private:

        return 'Private';  /// Get the string value for database storage  Map<String, dynamic> toJson() {

    }

  }  String get value {    return {

}

    switch (this) {      'id': id,

@MappableClass(caseStyle: CaseStyle.snakeCase)

class CreatePostRequest with CreatePostRequestMappable {      case PostVisibility.public:      'user': user,

  final String user;

  final String content;        return 'public';      'content': content,

  final String? mediaUrl;

  final PostVisibility visibility;      case PostVisibility.friends:      'media_url': mediaUrl,



  const CreatePostRequest({        return 'friends';      'visibility': visibility.value,

    required this.user,

    required this.content,      case PostVisibility.private:      'created_at': createdAt.toIso8601String(),

    this.mediaUrl,

    this.visibility = PostVisibility.public,        return 'private';      'updated_at': updatedAt?.toIso8601String(),

  });

}    }    };



@MappableClass(caseStyle: CaseStyle.snakeCase)  }  }

class UpdatePostRequest with UpdatePostRequestMappable {

  final String? content;

  final String? mediaUrl;

  final PostVisibility? visibility;  /// Create enum from string value  /// Converts Post to JSON for database insertion (without id for new posts)



  const UpdatePostRequest({  static PostVisibility fromString(String? value) {  Map<String, dynamic> toInsertJson() {

    this.content,

    this.mediaUrl,    if (value == null) return PostVisibility.public;    return {

    this.visibility,

  });      'user': user,



  bool get isEmpty => content == null && mediaUrl == null && visibility == null;    switch (value.toLowerCase()) {      'content': content,

}
      case 'public':      'media_url': mediaUrl,

        return PostVisibility.public;      'visibility': visibility.value,

      case 'friends':    };

        return PostVisibility.friends;  }

      case 'private':

        return PostVisibility.private;  /// Converts Post to JSON for database updates

      default:  Map<String, dynamic> toUpdateJson() {

        return PostVisibility.public;    return {

    }      'content': content,

  }      'media_url': mediaUrl,

      'visibility': visibility.value,

  /// Get display name for UI      'updated_at': DateTime.now().toIso8601String(),

  String get displayName {    };

    switch (this) {  }

      case PostVisibility.public:

        return 'Public';  /// Creates a copy of this Post with the given fields replaced with new values

      case PostVisibility.friends:  Post copyWith({

        return 'Friends Only';    int? id,

      case PostVisibility.private:    String? user,

        return 'Private';    String? content,

    }    String? mediaUrl,

  }    PostVisibility? visibility,

    DateTime? createdAt,

  /// Get icon for UI representation    DateTime? updatedAt,

  String get icon {  }) {

    switch (this) {    return Post(

      case PostVisibility.public:      id: id ?? this.id,

        return '🌍';      user: user ?? this.user,

      case PostVisibility.friends:      content: content ?? this.content,

        return '👥';      mediaUrl: mediaUrl ?? this.mediaUrl,

      case PostVisibility.private:      visibility: visibility ?? this.visibility,

        return '🔒';      createdAt: createdAt ?? this.createdAt,

    }      updatedAt: updatedAt ?? this.updatedAt,

  }    );

}  }



/// Data class for creating new posts  @override

@MappableClass(caseStyle: CaseStyle.snakeCase)  bool operator ==(Object other) {

class CreatePostRequest with CreatePostRequestMappable {    if (identical(this, other)) return true;

  final String user;    return other is Post &&

  final String content;        other.id == id &&

  final String? mediaUrl;        other.user == user &&

  final PostVisibility visibility;        other.content == content &&

        other.mediaUrl == mediaUrl &&

  const CreatePostRequest({        other.visibility == visibility &&

    required this.user,        other.createdAt == createdAt &&

    required this.content,        other.updatedAt == updatedAt;

    this.mediaUrl,  }

    this.visibility = PostVisibility.public,

  });  @override

}  int get hashCode {

    return Object.hash(

/// Data class for updating posts      id,

@MappableClass(caseStyle: CaseStyle.snakeCase)      user,

class UpdatePostRequest with UpdatePostRequestMappable {      content,

  final String? content;      mediaUrl,

  final String? mediaUrl;      visibility,

  final PostVisibility? visibility;      createdAt,

      updatedAt,

  const UpdatePostRequest({    );

    this.content,  }

    this.mediaUrl,

    this.visibility,  @override

  });  String toString() {

    return 'Post(id: $id, user: $user, content: $content, mediaUrl: $mediaUrl, '

  bool get isEmpty => content == null && mediaUrl == null && visibility == null;        'visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt)';

}  }
}

enum PostVisibility {
  public,
  private;

  String get value {
    switch (this) {
      case PostVisibility.public:
        return 'public';
      case PostVisibility.private:
        return 'private';
    }
  }

  static PostVisibility fromString(String? value) {
    if (value == null) return PostVisibility.public;

    switch (value.toLowerCase()) {
      case 'public':
        return PostVisibility.public;
      case 'private':
        return PostVisibility.private;
      default:
        return PostVisibility.public;
    }
  }
}

/// Data class for creating new posts
class CreatePostRequest {
  final String user;
  final String content;
  final String? mediaUrl;
  final PostVisibility visibility;

  const CreatePostRequest({
    required this.user,
    required this.content,
    this.mediaUrl,
    this.visibility = PostVisibility.public,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'content': content,
      'media_url': mediaUrl,
      'visibility': visibility.value,
    };
  }
}

/// Data class for updating posts
class UpdatePostRequest {
  final String? content;
  final String? mediaUrl;
  final PostVisibility? visibility;

  const UpdatePostRequest({this.content, this.mediaUrl, this.visibility});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (content != null) json['content'] = content;
    if (mediaUrl != null) json['media_url'] = mediaUrl;
    if (visibility != null) json['visibility'] = visibility!.value;

    // Always update the updated_at field
    json['updated_at'] = DateTime.now().toIso8601String();

    return json;
  }

  bool get isEmpty => content == null && mediaUrl == null && visibility == null;
}

/// Database table type aliases for better type safety
typedef PostRow = Map<String, dynamic>;
typedef PostInsert = Map<String, dynamic>;
typedef PostUpdate = Map<String, dynamic>;
