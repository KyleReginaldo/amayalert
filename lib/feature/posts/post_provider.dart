import 'dart:io';

import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProvider {
  final supabase = Supabase.instance.client;

  Future<Result<String>> createPost({
    required String userId,
    required CreatePostDTO dto,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (dto.imageFile != null) {
        final fileName =
            'posts/${DateTime.now().microsecondsSinceEpoch.toString()}_${dto.imageFile!.name}';
        await supabase.storage
            .from('files')
            .upload(fileName, File(dto.imageFile!.path));
        imageUrl = supabase.storage.from('files').getPublicUrl(fileName);
      }

      // Create post in database
      final postData = {
        'user': userId,
        'content': dto.content,
        if (imageUrl != null) 'media_url': imageUrl,
        'visibility': dto.visibility,
      };

      final response = await supabase
          .from('posts')
          .insert(postData)
          .select()
          .single();

      if (response.isNotEmpty) {
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
          .select()
          .eq('visibility', 'public')
          .order('created_at', ascending: false);

      final posts = response.map((json) {
        debugPrint('posts: $json');
        return PostMapper.fromMap(json);
      }).toList();

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
          .select()
          .eq('user', userId) // Fixed: was 'user_id', should be 'user'
          .order('created_at', ascending: false);

      final posts = response.map((json) => PostMapper.fromMap(json)).toList();

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
          .select()
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
}
