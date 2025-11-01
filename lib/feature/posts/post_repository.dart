import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/posts/post_comment.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepository extends ChangeNotifier {
  final PostProvider _postProvider;

  PostRepository({PostProvider? provider})
    : _postProvider = provider ?? PostProvider();

  RealtimeChannel? _commentsChannel;

  List<Post> _posts = [];
  List<Post> _userPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<PostComment> _comments = [];
  List<PostComment> get comments => _comments;

  List<Post> get posts => _posts;
  List<Post> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Result<String>> createPost({
    required String userId,
    required CreatePostDTO dto,
  }) async {
    _setLoading(true);
    final result = await _postProvider.createPost(userId: userId, dto: dto);
    if (result.isSuccess) {
      await loadPosts();
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }
    _setLoading(false);
    return result;
  }

  Future<void> loadPosts() async {
    _setLoading(true);

    final result = await _postProvider.getPosts();

    if (result.isSuccess) {
      _posts = result.value;
      _errorMessage = null;
      // After loading posts, subscribe to realtime comments so UI reflects live counts
      _subscribeToComments();
    } else {
      _errorMessage = result.error;
      _posts = [];
    }

    _setLoading(false);
  }

  void _subscribeToComments() {
    try {
      // Unsubscribe previous channel if exists
      _commentsChannel?.unsubscribe();

      final supabase = Supabase.instance.client;
      debugPrint('Subscribing to comments realtime channel');
      _commentsChannel = supabase.channel('posts_comments_channel');

      _commentsChannel!.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'comments',
        callback: (payload) {
          try {
            debugPrint(
              'Comments realtime payload received: ${payload.newRecord}',
            );

            // payload.newRecord is provided by supabase realtime.
            final record = payload.newRecord;
            // Defensive: Supabase realtime sometimes returns relation fields as an
            // ID string (e.g. user: '<user-id>') instead of a nested object.
            // The PostCommentMapper expects `user` to be a Map (Profile) or null.
            final map = Map<String, dynamic>.from(record);
            if (map['user'] is String) {
              debugPrint(
                'Realtime comment payload contains user as id string; clearing user to avoid mapper error',
              );
              map['user'] = null;
            }

            final comment = PostCommentMapper.fromMap(map);

            debugPrint(
              'Parsed comment for post ${comment.post} id=${comment.id}',
            );

            final idx = _posts.indexWhere((p) => p.id == comment.post);
            if (idx != -1) {
              final p = _posts[idx];
              final updatedComments = <PostComment>[];
              if (p.comments != null) updatedComments.addAll(p.comments!);
              updatedComments.add(comment);

              final updatedPost = Post(
                id: p.id,
                user: p.user,
                content: p.content,
                mediaUrl: p.mediaUrl,
                visibility: p.visibility,
                createdAt: p.createdAt,
                updatedAt: p.updatedAt,
                comments: updatedComments,
                sharedPost: p.sharedPost,
              );

              _posts[idx] = updatedPost;
              notifyListeners();
            } else {
              debugPrint('Received comment for unknown post ${comment.post}');
            }
          } catch (e, st) {
            debugPrint('Error handling new comment realtime payload: $e\n$st');
          }
        },
      );

      _commentsChannel!.subscribe();
    } catch (e, st) {
      debugPrint('Failed to subscribe to post comments realtime: $e\n$st');
    }
  }

  Future<void> loadUserPosts(String userId) async {
    _setLoading(true);
    final result = await _postProvider.getUserPosts(userId);
    if (result.isSuccess) {
      _userPosts = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
  }

  Future<Result<Post>> getPost(int postId) async {
    return await _postProvider.getPost(postId);
  }

  Future<Result<String>> updatePost({
    required int postId,
    required String userId,
    required UpdatePostDTO dto,
  }) async {
    _setLoading(true);

    final result = await _postProvider.updatePost(
      postId: postId,
      userId: userId,
      dto: dto,
    );

    if (result.isSuccess) {
      // Refresh posts after successful update
      await loadPosts();
      await loadUserPosts(userId);
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }

    _setLoading(false);
    return result;
  }

  Future<Result<String>> deletePost({
    required int postId,
    required String userId,
  }) async {
    _setLoading(true);

    final result = await _postProvider.deletePost(
      postId: postId,
      userId: userId,
    );

    if (result.isSuccess) {
      // Remove post from local lists
      _posts.removeWhere((post) => post.id == postId);
      _userPosts.removeWhere((post) => post.id == postId);
      _errorMessage = null;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
    return result;
  }

  /// Create a comment for a message
  Future<Result<String>> createMessageComment({
    required String userId,
    required int messageId,
    required String comment,
  }) async {
    _setLoading(true);

    final result = await _postProvider.createMessageComment(
      userId: userId,
      messageId: messageId,
      comment: comment,
    );
    _setLoading(false);
    return result;
  }

  /// Share a post (records a share action)
  Future<Result<String>> sharePost({
    required String userId,
    required int postId,
  }) async {
    _setLoading(true);

    final result = await _postProvider.sharePost(
      userId: userId,
      postId: postId,
    );

    // Optionally refresh post share counts elsewhere

    _setLoading(false);
    return result;
  }

  // Prefetch comments for a post without toggling the repository-wide loading
  // state. This is used to populate the local cache so UI can show counts
  // immediately after posts are loaded.

  Future<void> getCommentsForPost(int postId) async {
    _setLoading(true);

    final result = await _postProvider.getCommentsForPost(postId);
    if (result.isError) {
      _comments = [];
      _errorMessage = result.error;
      _setLoading(false);
      notifyListeners();
    } else if (result.isSuccess) {
      _comments = result.value;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      _commentsChannel?.unsubscribe();
    } catch (_) {}
    super.dispose();
  }
}
