import 'package:image_picker/image_picker.dart';

class CreatePostDTO {
  final String content;
  final String? mediaUrl;
  final String visibility;
  final int? sharedPost;
  final XFile? imageFile;

  CreatePostDTO({
    required this.content,
    this.mediaUrl,
    required this.visibility,
    this.sharedPost,
    this.imageFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (sharedPost != null) 'shared_post': sharedPost,
      'visibility': visibility,
    };
  }
}

class UpdatePostDTO {
  final String? content;
  final String? mediaUrl;
  final String? visibility;
  final XFile? imageFile;

  UpdatePostDTO({this.content, this.mediaUrl, this.visibility, this.imageFile});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (content != null) json['content'] = content;
    if (mediaUrl != null) json['media_url'] = mediaUrl;
    if (visibility != null) json['visibility'] = visibility;

    return json;
  }

  bool get isEmpty =>
      content == null &&
      mediaUrl == null &&
      visibility == null &&
      imageFile == null;
}
