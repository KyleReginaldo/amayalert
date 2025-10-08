import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constant/constant.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

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

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileRepository>().getUserProfile(userID ?? "");
      context.read<PostRepository>().loadUserPosts(userID ?? "");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileRepository bloc) => bloc.profile);
    final userPosts = context.select((PostRepository bloc) => bloc.userPosts);
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const CustomText(
          text: 'Profile',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.gray50,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              context.router.push(SettingsRoute());
            },
            icon: Icon(LucideIcons.settings, color: Colors.black),
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gray200,
                              width: 2,
                            ),
                          ),
                          child: user.profilePicture != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.profilePicture!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
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
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 8),

                        // User Info
                        CustomText(
                          text: user.fullName,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          text: user.email,
                          fontSize: 15,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            context.router.push(
                              EditProfileRoute(profile: user),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Icon(
                                  LucideIcons.pen,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                CustomText(
                                  text: 'Edit Profile',
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
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
                                        text: 'No posts yet',
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
                                        const SizedBox(height: 6),
                                        CustomText(
                                          text: '${post.createdAt.toLocal()}'
                                              .split(' ')[0],
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
