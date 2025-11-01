import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class UserProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  final String userId;
  final String? userName;

  const UserProfileScreen({super.key, required this.userId, this.userName});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<PostRepository>()),
      ],
      child: this,
    );
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();

    // Check if viewing current user's profile
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _isCurrentUser = currentUserId == widget.userId;

    // Load user profile and posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileRepository>().getUserProfile(widget.userId);
      context.read<PostRepository>().loadUserPosts(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileRepository bloc) => bloc.profile);
    final isLoading = context.select(
      (ProfileRepository bloc) => bloc.isLoading,
    );
    final userPosts = context.select((PostRepository bloc) => bloc.userPosts);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: CustomText(
          text: widget.userName ?? 'Profile',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.gray50,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryLight),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(
              child: CustomText(
                text: 'User not found',
                fontSize: 16,
                color: Colors.grey,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Profile Card
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gray200,
                              width: 2,
                            ),
                          ),
                          child: user.profilePicture != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.profilePicture!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // User Info
                        CustomText(
                          text: user.fullName,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 4),
                        if (!user.email.contains('guest'))
                          CustomText(
                            text: user.email,
                            fontSize: 16,
                            color: AppColors.gray600,
                          ),

                        const SizedBox(height: 16),

                        // User Details
                        if (user.gender != null ||
                            user.phoneNumber != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                if (user.gender != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        user.gender?.toLowerCase() == 'male'
                                            ? LucideIcons.user
                                            : LucideIcons.userCheck,
                                        size: 16,
                                        color: AppColors.gray600,
                                      ),
                                      const SizedBox(width: 8),
                                      CustomText(
                                        text: user.gender!,
                                        fontSize: 14,
                                        color: AppColors.gray600,
                                      ),
                                    ],
                                  ),
                                if (user.gender != null &&
                                    user.phoneNumber != null)
                                  const SizedBox(height: 8),
                                if (user.phoneNumber != null && !_isCurrentUser)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        LucideIcons.phone,
                                        size: 16,
                                        color: AppColors.gray600,
                                      ),
                                      const SizedBox(width: 8),
                                      CustomText(
                                        text: user.phoneNumber!,
                                        fontSize: 14,
                                        color: AppColors.gray600,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Action Buttons
                        if (!_isCurrentUser &&
                            !user.email.contains('guest')) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        LucideIcons.messageCircle,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      CustomText(
                                        text: 'Message',
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Posts Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.messageSquare,
                              size: 20,
                              color: AppColors.gray600,
                            ),
                            const SizedBox(width: 8),
                            CustomText(
                              text: 'Posts (${userPosts.length})',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        userPosts.isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        LucideIcons.messageSquare,
                                        size: 40,
                                        color: AppColors.gray400,
                                      ),
                                      const SizedBox(height: 12),
                                      CustomText(
                                        text: _isCurrentUser
                                            ? 'No posts yet'
                                            : 'No posts to show',
                                        fontSize: 16,
                                        color: AppColors.gray500,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: userPosts.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: AppColors.gray200,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final post = userPosts[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: post.content,
                                          fontSize: 15,
                                          color: Colors.black87,
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 8),

                                        // Post image if available
                                        if (post.mediaUrl != null) ...[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: post.mediaUrl!,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                    height: 200,
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Container(
                                                    height: 200,
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],

                                        CustomText(
                                          text: timeago.format(
                                            post.createdAt.toLocal(),
                                          ),
                                          fontSize: 13,
                                          color: AppColors.gray500,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
