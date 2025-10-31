import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/posts/post_comment.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_provider.dart';
import 'package:flutter/material.dart';

class PostRepository extends ChangeNotifier {
  final PostProvider _postProvider;

  PostRepository({PostProvider? provider})
    : _postProvider = provider ?? PostProvider();

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
    } else {
      _errorMessage = result.error;
      _posts = [];
    }

    _setLoading(false);
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
}
