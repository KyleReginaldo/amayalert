import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, @PathParam('id') required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase
          .from('posts')
          .select('''
            *,
            user:user(*),
            comments:comments(
              *,
              user:user(*)
            ),
            shared_post:shared_post(
              *,
              user:user(*)
            )
          ''')
          .eq('id', widget.postId)
          .order('created_at', ascending: false)
          .single();

      final post = PostMapper.fromMap(response);

      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const CustomText(
          text: 'Post Details',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            CustomText(
              text: 'Error loading post',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: CustomText(
                text: _errorMessage!,
                fontSize: 14,
                color: AppColors.textSecondaryLight,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPost,
              child: const CustomText(text: 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_post == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.messageSquare,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Post not found',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPost,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post content
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.router.push(
                            UserProfileRoute(userId: _post!.user.id),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: _post!.user.profilePicture != null
                              ? CachedNetworkImageProvider(
                                  _post!.user.profilePicture!,
                                )
                              : null,
                          child: _post!.user.profilePicture == null
                              ? Text(
                                  _post!.user.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.router.push(
                                  UserProfileRoute(userId: _post!.user.id),
                                );
                              },
                              child: CustomText(
                                text: _post!.user.fullName,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                CustomText(
                                  text: timeago.format(_post!.createdAt),
                                  fontSize: 12,
                                  color: AppColors.gray600,
                                ),
                                const SizedBox(width: 4),
                                CustomText(
                                  text: '•',
                                  fontSize: 12,
                                  color: AppColors.gray600,
                                ),
                                const SizedBox(width: 4),
                                CustomText(
                                  text: _post!.visibility.displayName,
                                  fontSize: 12,
                                  color: AppColors.gray600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post content
                  CustomText(
                    text: _post!.content,
                    fontSize: 15,
                    color: Colors.black87,
                  ),

                  // Media if available
                  if (_post!.hasMedia) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _post!.mediaUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: AppColors.gray200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: AppColors.gray200,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],

                  // Shared post if available
                  if (_post!.sharedPost != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage:
                                    _post!.sharedPost!.user.profilePicture !=
                                        null
                                    ? CachedNetworkImageProvider(
                                        _post!.sharedPost!.user.profilePicture!,
                                      )
                                    : null,
                                child:
                                    _post!.sharedPost!.user.profilePicture ==
                                        null
                                    ? Text(
                                        _post!.sharedPost!.user.fullName[0]
                                            .toUpperCase(),
                                        style: const TextStyle(fontSize: 14),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: _post!.sharedPost!.user.fullName,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    CustomText(
                                      text: timeago.format(
                                        _post!.sharedPost!.createdAt,
                                      ),
                                      fontSize: 11,
                                      color: AppColors.gray600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomText(
                            text: _post!.sharedPost!.content,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          if (_post!.sharedPost!.hasMedia) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: _post!.sharedPost!.mediaUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Edit indicator
                  if (_post!.updatedAt != null &&
                      _post!.updatedAt != _post!.createdAt) ...[
                    const SizedBox(height: 8),
                    CustomText(
                      text: 'Edited ${timeago.format(_post!.updatedAt!)}',
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final result = await context.router.push<bool>(
                            CommentsRoute(postId: _post!.id),
                          );
                          if (result == true) {
                            _loadPost();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.messageCircle,
                                color: AppColors.gray600,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              CustomText(
                                text: _post!.comments?.length.toString() ?? '0',
                                fontSize: 14,
                                color: AppColors.gray600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () async {
                          final didShare = await context.router.push<bool>(
                            SharePostRoute(
                              postId: _post!.sharedPost?.id ?? _post!.id,
                              previewContent:
                                  _post!.sharedPost?.content ?? _post!.content,
                            ),
                          );
                          if (didShare == true) {
                            _loadPost();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            LucideIcons.share,
                            color: AppColors.gray600,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Comments section
            if (_post!.comments != null && _post!.comments!.isNotEmpty) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.messageSquare,
                          size: 18,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 8),
                        CustomText(
                          text: 'Comments (${_post!.comments!.length})',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _post!.comments!.length > 3
                          ? 3
                          : _post!.comments!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = _post!.comments![index];
                        return _buildCommentItem(comment);
                      },
                    ),
                    if (_post!.comments!.length > 3) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          final result = await context.router.push<bool>(
                            CommentsRoute(postId: _post!.id),
                          );
                          if (result == true) {
                            _loadPost();
                          }
                        },
                        child: CustomText(
                          text: 'View all ${_post!.comments!.length} comments',
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: comment.user?.profilePicture != null
              ? CachedNetworkImageProvider(comment.user!.profilePicture!)
              : null,
          child: comment.user?.profilePicture == null
              ? Text(
                  comment.user?.fullName[0].toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 12),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: comment.user?.fullName ?? 'Unknown User',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: comment.comment ?? '',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: timeago.format(comment.createdAt),
                  fontSize: 11,
                  color: AppColors.gray600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
