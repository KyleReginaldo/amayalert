import 'package:dart_mappable/dart_mappable.dart';

part 'post_model.mapper.dart';

/// Post model based on database schema
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Post with PostMappable {
  final int id;
  final String user;
  final String content;
  final String? mediaUrl;
  final PostVisibility visibility;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Post({
    required this.id,
    required this.user,
    required this.content,
    this.mediaUrl,
    required this.visibility,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if post has media attachment
  bool get hasMedia {
    return mediaUrl != null && mediaUrl!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post &&
        other.id == id &&
        other.user == user &&
        other.content == content &&
        other.mediaUrl == mediaUrl &&
        other.visibility == visibility &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      user,
      content,
      mediaUrl,
      visibility,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, user: $user, content: $content, mediaUrl: $mediaUrl, '
        'visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

@MappableEnum()
enum PostVisibility {
  public,
  friends,
  private;

  /// Get the string value for database storage
  String get value {
    switch (this) {
      case PostVisibility.public:
        return 'public';
      case PostVisibility.friends:
        return 'friends';
      case PostVisibility.private:
        return 'private';
    }
  }

  /// Create enum from string value
  static PostVisibility fromString(String? value) {
    if (value == null) return PostVisibility.public;

    switch (value.toLowerCase()) {
      case 'public':
        return PostVisibility.public;
      case 'friends':
        return PostVisibility.friends;
      case 'private':
        return PostVisibility.private;
      default:
        return PostVisibility.public;
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.friends:
        return 'Friends Only';
      case PostVisibility.private:
        return 'Private';
    }
  }

  /// Get icon for UI representation
  String get icon {
    switch (this) {
      case PostVisibility.public:
        return '🌍';
      case PostVisibility.friends:
        return '👥';
      case PostVisibility.private:
        return '🔒';
    }
  }
}

/// Data class for creating new posts
@MappableClass(caseStyle: CaseStyle.snakeCase)
class CreatePostRequest with CreatePostRequestMappable {
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
}

/// Data class for updating posts
@MappableClass(caseStyle: CaseStyle.snakeCase)
class UpdatePostRequest with UpdatePostRequestMappable {
  final String? content;
  final String? mediaUrl;
  final PostVisibility? visibility;

  const UpdatePostRequest({this.content, this.mediaUrl, this.visibility});

  bool get isEmpty => content == null && mediaUrl == null && visibility == null;
}
