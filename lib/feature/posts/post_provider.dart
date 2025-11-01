import 'dart:io';

import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/posts/post_comment.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constant/constant.dart';
import '../../core/utils/onesignal.helper.dart';

const String postQuery =
    '*, user(*), comments(*, user:users(*)), shared_post(*, user(*), comments(*, user:users(*)))';

class PostProvider {
  final supabase = Supabase.instance.client;

  Future<Result<String>> createPost({
    required String userId,
    required CreatePostDTO dto,
  }) async {
    try {
      String? imageUrl;
      if (dto.imageFile != null) {
        final fileName =
            'posts/${DateTime.now().microsecondsSinceEpoch.toString()}_${dto.imageFile!.name}';
        await supabase.storage
            .from('files')
            .upload(fileName, File(dto.imageFile!.path));
        imageUrl = supabase.storage.from('files').getPublicUrl(fileName);
      }
      final postData = {
        'user': userId,
        'content': dto.content,
        if (imageUrl != null) 'media_url': imageUrl,
        if (dto.sharedPost != null) 'shared_post': dto.sharedPost,
        'visibility': dto.visibility,
      };
      final response = await supabase
          .from('posts')
          .insert(postData)
          .select()
          .single();
      if (response.isNotEmpty) {
        if (dto.sharedPost != null) {
          final user = await supabase
              .from('users')
              .select('full_name')
              .eq('id', userId)
              .single();
          final shared = await supabase
              .from('posts')
              .select('user:users(id)')
              .eq('id', dto.sharedPost!)
              .single();
          await sendNotif(
            users: [shared['user']['id']],
            title: 'Post Shared',
            content: '${user['full_name']} shared your post',
          );
        }

        return Result.success('Post created successfully');
      } else {
        return Result.error('Failed to create post');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<List<Post>>> getPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select(postQuery)
          .eq('visibility', 'public')
          .order('created_at', ascending: false);
      List<Post> posts = [];
      for (final json in response) {
        debugPrint('check shared post: $json');
        posts.add(PostMapper.fromMap(json));
      }
      return Result.success(posts);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<List<Post>>> getUserPosts(String userId) async {
    try {
      final response = await supabase
          .from('posts')
          .select(postQuery)
          .eq('user', userId) // Fixed: was 'user_id', should be 'user'
          .order('created_at', ascending: false);
      List<Post> posts = [];
      for (final json in response) {
        posts.add(PostMapper.fromMap(json));
      }
      return Result.success(posts);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<Post>> getPost(int postId) async {
    try {
      final response = await supabase
          .from('posts')
          .select(postQuery)
          .eq('id', postId)
          .single();

      final post = PostMapper.fromMap(response);
      return Result.success(post);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<String>> updatePost({
    required int postId,
    required String userId,
    required UpdatePostDTO dto,
  }) async {
    try {
      // Check if user owns the post
      final postCheck = await supabase
          .from('posts')
          .select('user')
          .eq('id', postId)
          .single();

      if (postCheck['user'] != userId) {
        return Result.error('You can only edit your own posts');
      }

      String? imageUrl;

      // Upload new image if provided
      if (dto.imageFile != null) {
        final fileName =
            'posts/${DateTime.now().microsecondsSinceEpoch.toString()}_${dto.imageFile!.name}';
        await supabase.storage
            .from('files')
            .upload(fileName, File(dto.imageFile!.path));
        imageUrl = supabase.storage.from('files').getPublicUrl(fileName);
      }

      // Prepare update data
      final updateData = dto.toJson();
      if (imageUrl != null) {
        updateData['media_url'] = imageUrl;
      }
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('posts')
          .update(updateData)
          .eq('id', postId)
          .select()
          .single();

      if (response.isNotEmpty) {
        return Result.success('Post updated successfully');
      } else {
        return Result.error('Failed to update post');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<String>> deletePost({
    required int postId,
    required String userId,
  }) async {
    try {
      // Check if user owns the post
      final postCheck = await supabase
          .from('posts')
          .select('user, media_url')
          .eq('id', postId)
          .single();

      if (postCheck['user'] != userId) {
        return Result.error('You can only delete your own posts');
      }

      // Delete associated media if exists
      final mediaUrl = postCheck['media_url'] as String?;
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        try {
          // Extract file path from URL and delete from storage
          final uri = Uri.parse(mediaUrl);
          final filePath = uri.pathSegments
              .skip(4)
              .join('/'); // Skip /storage/v1/object/public/files/
          await supabase.storage.from('files').remove([filePath]);
        } catch (e) {
          debugPrint('Failed to delete media file: $e');
        }
      }

      // Delete post from database
      await supabase.from('posts').delete().eq('id', postId);

      return Result.success('Post deleted successfully');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Create a comment for a message
  /// Matches the `comments` table in `database.types.ts` which has fields:
  /// { id, comment, created_at, message, user }
  Future<Result<String>> createMessageComment({
    required String userId,
    required int messageId,
    required String comment,
  }) async {
    try {
      final response = await supabase
          .from('comments')
          .insert({
            'user': userId,
            'message': messageId,
            'comment': comment,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response['id'] != null) {
        return Result.success(response['id'].toString());
      }

      return Result.error('Failed to create comment');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Record a share action for a post. This will insert into `post_shares`.
  /// If your DB uses a different table name, adjust accordingly.
  Future<Result<String>> sharePost({
    required String userId,
    required int postId,
  }) async {
    try {
      final response = await supabase
          .from('post_shares')
          .insert({
            'user': userId,
            'post': postId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response['id'] != null) {
        return Result.success(response['id'].toString());
      }

      return Result.error('Failed to share post');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Create a comment for a post. Requires a `post_comments` table with columns:
  /// { id, comment, created_at, post, user }
  Future<Result<String>> createPostComment({
    required String userId,
    required int postId,
    required String comment,
  }) async {
    try {
      final post = await supabase
          .from('posts')
          .select()
          .eq('id', postId)
          .single();
      debugPrint('post owner: ${post['user']}');
      final response = await supabase
          .from('comments')
          .insert({
            'user': userId,
            'post': postId,
            'comment': comment,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response['user'] != null && post['user'] != userID) {
        final user = await supabase
            .from('users')
            .select('full_name')
            .eq('id', userId)
            .single();
        await sendNotif(
          users: [post['user']],
          title: 'New Comment on Your Post',
          content: '${user['full_name']} commented: $comment',
        );
      }
      return Result.success(response['id'].toString());
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Fetch comments for a given post id.
  Future<Result<List<PostComment>>> getCommentsForPost(int postId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('*, user:users(*)')
          .eq('post', postId)
          .order('created_at', ascending: true);

      final comments = (response as List).map((m) {
        // We avoid importing PostComment at top to keep provider isolated; use dynamic map
        return PostCommentMapper.fromMap(Map<String, dynamic>.from(m));
      }).toList();

      return Result.success(comments);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }
}
