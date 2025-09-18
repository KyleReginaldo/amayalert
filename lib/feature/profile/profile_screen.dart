import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
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
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    context.read<ProfileRepository>().getUserProfile(userID ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileRepository bloc) => bloc.profile);
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Profile',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: user.profilePicture != null
                        ? ClipOval(
                            child: Image.network(
                              user.profilePicture!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                  ),
                  CustomText(text: user.fullName, fontSize: 16),
                  CustomText(text: user.email, fontSize: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            context.router.push(
                              EditProfileRoute(profile: user),
                            );
                          },
                          child: Row(
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
                                fontSize: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          foregroundColor: WidgetStatePropertyAll(Colors.black),
                        ),
                        icon: Icon(LucideIcons.settings),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Posts history(0)'),
                        Center(
                          child: CustomText(
                            text: 'No posts yet',
                            color: AppColors.textDisabledLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),

                  TextButton(
                    onPressed: () {},
                    child: CustomText(text: 'Sign out', color: AppColors.error),
                  ),
                ],
              ),
            ),
    );
  }
}
