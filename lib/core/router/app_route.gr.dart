// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:amayalert/feature/activity/activity_detail_screen.dart' as _i1;
import 'package:amayalert/feature/activity/activity_model.dart' as _i30;
import 'package:amayalert/feature/activity/activity_screen.dart' as _i2;
import 'package:amayalert/feature/auth/change_password_screen.dart' as _i3;
import 'package:amayalert/feature/auth/forgot_password_otp_screen.dart' as _i9;
import 'package:amayalert/feature/auth/forgot_password_screen.dart' as _i10;
import 'package:amayalert/feature/auth/on_boarding_screen.dart' as _i16;
import 'package:amayalert/feature/auth/reset_password_screen.dart' as _i21;
import 'package:amayalert/feature/auth/sign_in_screen.dart' as _i24;
import 'package:amayalert/feature/auth/sign_up_screen.dart' as _i25;
import 'package:amayalert/feature/home/home_screen.dart' as _i11;
import 'package:amayalert/feature/main/main_screen.dart' as _i12;
import 'package:amayalert/feature/maps/map_screen.dart' as _i13;
import 'package:amayalert/feature/messages/chat_screen.dart' as _i4;
import 'package:amayalert/feature/messages/message_screen.dart' as _i14;
import 'package:amayalert/feature/messages/new_conversation_screen.dart'
    as _i15;
import 'package:amayalert/feature/posts/comments_screen.dart' as _i5;
import 'package:amayalert/feature/posts/create_posts_screen.dart' as _i6;
import 'package:amayalert/feature/posts/share_post_screen.dart' as _i23;
import 'package:amayalert/feature/profile/edit_profile_screen.dart' as _i8;
import 'package:amayalert/feature/profile/otp_verification_screen.dart' as _i17;
import 'package:amayalert/feature/profile/profile_model.dart' as _i33;
import 'package:amayalert/feature/profile/profile_screen.dart' as _i18;
import 'package:amayalert/feature/profile/user_profile_screen.dart' as _i26;
import 'package:amayalert/feature/rescue/create_rescue_screen.dart' as _i7;
import 'package:amayalert/feature/rescue/rescue_detail_screen.dart' as _i19;
import 'package:amayalert/feature/rescue/rescue_list_screen.dart' as _i20;
import 'package:amayalert/feature/settings/settings_screen.dart' as _i22;
import 'package:amayalert/feature/webview/webview_screen.dart' as _i27;
import 'package:auto_route/auto_route.dart' as _i28;
import 'package:flutter/foundation.dart' as _i31;
import 'package:flutter/material.dart' as _i29;
import 'package:image_picker/image_picker.dart' as _i32;

/// generated route for
/// [_i1.ActivityDetailScreen]
class ActivityDetailRoute extends _i28.PageRouteInfo<ActivityDetailRouteArgs> {
  ActivityDetailRoute({
    _i29.Key? key,
    required _i30.Activity activity,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         ActivityDetailRoute.name,
         args: ActivityDetailRouteArgs(key: key, activity: activity),
         initialChildren: children,
       );

  static const String name = 'ActivityDetailRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ActivityDetailRouteArgs>();
      return _i1.ActivityDetailScreen(key: args.key, activity: args.activity);
    },
  );
}

class ActivityDetailRouteArgs {
  const ActivityDetailRouteArgs({this.key, required this.activity});

  final _i29.Key? key;

  final _i30.Activity activity;

  @override
  String toString() {
    return 'ActivityDetailRouteArgs{key: $key, activity: $activity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityDetailRouteArgs) return false;
    return key == other.key && activity == other.activity;
  }

  @override
  int get hashCode => key.hashCode ^ activity.hashCode;
}

/// generated route for
/// [_i2.ActivityScreen]
class ActivityRoute extends _i28.PageRouteInfo<void> {
  const ActivityRoute({List<_i28.PageRouteInfo>? children})
    : super(ActivityRoute.name, initialChildren: children);

  static const String name = 'ActivityRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i2.ActivityScreen());
    },
  );
}

/// generated route for
/// [_i3.ChangePasswordScreen]
class ChangePasswordRoute extends _i28.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i28.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i3.ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [_i4.ChatScreen]
class ChatRoute extends _i28.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i31.Key? key,
    required String otherUserId,
    required String otherUserName,
    String? otherUserPhone,
    _i32.ImagePicker? imagePicker,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(
           key: key,
           otherUserId: otherUserId,
           otherUserName: otherUserName,
           otherUserPhone: otherUserPhone,
           imagePicker: imagePicker,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i28.WrappedRoute(
        child: _i4.ChatScreen(
          key: args.key,
          otherUserId: args.otherUserId,
          otherUserName: args.otherUserName,
          otherUserPhone: args.otherUserPhone,
          imagePicker: args.imagePicker,
        ),
      );
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhone,
    this.imagePicker,
  });

  final _i31.Key? key;

  final String otherUserId;

  final String otherUserName;

  final String? otherUserPhone;

  final _i32.ImagePicker? imagePicker;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, otherUserId: $otherUserId, otherUserName: $otherUserName, otherUserPhone: $otherUserPhone, imagePicker: $imagePicker}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        otherUserId == other.otherUserId &&
        otherUserName == other.otherUserName &&
        otherUserPhone == other.otherUserPhone &&
        imagePicker == other.imagePicker;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      otherUserId.hashCode ^
      otherUserName.hashCode ^
      otherUserPhone.hashCode ^
      imagePicker.hashCode;
}

/// generated route for
/// [_i5.CommentsScreen]
class CommentsRoute extends _i28.PageRouteInfo<CommentsRouteArgs> {
  CommentsRoute({
    required int postId,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         CommentsRoute.name,
         args: CommentsRouteArgs(postId: postId, key: key),
         initialChildren: children,
       );

  static const String name = 'CommentsRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommentsRouteArgs>();
      return _i28.WrappedRoute(
        child: _i5.CommentsScreen(postId: args.postId, key: args.key),
      );
    },
  );
}

class CommentsRouteArgs {
  const CommentsRouteArgs({required this.postId, this.key});

  final int postId;

  final _i29.Key? key;

  @override
  String toString() {
    return 'CommentsRouteArgs{postId: $postId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CommentsRouteArgs) return false;
    return postId == other.postId && key == other.key;
  }

  @override
  int get hashCode => postId.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i6.CreatePostsScreen]
class CreatePostsRoute extends _i28.PageRouteInfo<void> {
  const CreatePostsRoute({List<_i28.PageRouteInfo>? children})
    : super(CreatePostsRoute.name, initialChildren: children);

  static const String name = 'CreatePostsRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i6.CreatePostsScreen());
    },
  );
}

/// generated route for
/// [_i7.CreateRescueScreen]
class CreateRescueRoute extends _i28.PageRouteInfo<void> {
  const CreateRescueRoute({List<_i28.PageRouteInfo>? children})
    : super(CreateRescueRoute.name, initialChildren: children);

  static const String name = 'CreateRescueRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i7.CreateRescueScreen();
    },
  );
}

/// generated route for
/// [_i8.EditProfileScreen]
class EditProfileRoute extends _i28.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i29.Key? key,
    required _i33.Profile profile,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i8.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i29.Key? key;

  final _i33.Profile profile;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, profile: $profile}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileRouteArgs) return false;
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => key.hashCode ^ profile.hashCode;
}

/// generated route for
/// [_i9.ForgotPasswordOtpScreen]
class ForgotPasswordOtpRoute
    extends _i28.PageRouteInfo<ForgotPasswordOtpRouteArgs> {
  ForgotPasswordOtpRoute({
    _i29.Key? key,
    required String email,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         ForgotPasswordOtpRoute.name,
         args: ForgotPasswordOtpRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'ForgotPasswordOtpRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgotPasswordOtpRouteArgs>();
      return _i9.ForgotPasswordOtpScreen(key: args.key, email: args.email);
    },
  );
}

class ForgotPasswordOtpRouteArgs {
  const ForgotPasswordOtpRouteArgs({this.key, required this.email});

  final _i29.Key? key;

  final String email;

  @override
  String toString() {
    return 'ForgotPasswordOtpRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForgotPasswordOtpRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [_i10.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i28.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i28.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i10.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i11.HomeScreen]
class HomeRoute extends _i28.PageRouteInfo<void> {
  const HomeRoute({List<_i28.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i11.HomeScreen());
    },
  );
}

/// generated route for
/// [_i12.MainScreen]
class MainRoute extends _i28.PageRouteInfo<void> {
  const MainRoute({List<_i28.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i12.MainScreen();
    },
  );
}

/// generated route for
/// [_i13.MapScreen]
class MapRoute extends _i28.PageRouteInfo<void> {
  const MapRoute({List<_i28.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i13.MapScreen());
    },
  );
}

/// generated route for
/// [_i14.MessageScreen]
class MessageRoute extends _i28.PageRouteInfo<void> {
  const MessageRoute({List<_i28.PageRouteInfo>? children})
    : super(MessageRoute.name, initialChildren: children);

  static const String name = 'MessageRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i14.MessageScreen());
    },
  );
}

/// generated route for
/// [_i15.NewConversationScreen]
class NewConversationRoute extends _i28.PageRouteInfo<void> {
  const NewConversationRoute({List<_i28.PageRouteInfo>? children})
    : super(NewConversationRoute.name, initialChildren: children);

  static const String name = 'NewConversationRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i15.NewConversationScreen());
    },
  );
}

/// generated route for
/// [_i16.OnBoardingScreen]
class OnBoardingRoute extends _i28.PageRouteInfo<OnBoardingRouteArgs> {
  OnBoardingRoute({
    _i29.Key? key,
    void Function(bool)? onResult,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         OnBoardingRoute.name,
         args: OnBoardingRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'OnBoardingRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnBoardingRouteArgs>(
        orElse: () => const OnBoardingRouteArgs(),
      );
      return _i28.WrappedRoute(
        child: _i16.OnBoardingScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class OnBoardingRouteArgs {
  const OnBoardingRouteArgs({this.key, this.onResult});

  final _i29.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'OnBoardingRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OnBoardingRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i17.OtpVerificationScreen]
class OtpVerificationRoute
    extends _i28.PageRouteInfo<OtpVerificationRouteArgs> {
  OtpVerificationRoute({
    _i29.Key? key,
    required String email,
    required String sentOtp,
    required String newPhone,
    required String userId,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         OtpVerificationRoute.name,
         args: OtpVerificationRouteArgs(
           key: key,
           email: email,
           sentOtp: sentOtp,
           newPhone: newPhone,
           userId: userId,
         ),
         initialChildren: children,
       );

  static const String name = 'OtpVerificationRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpVerificationRouteArgs>();
      return _i28.WrappedRoute(
        child: _i17.OtpVerificationScreen(
          key: args.key,
          email: args.email,
          sentOtp: args.sentOtp,
          newPhone: args.newPhone,
          userId: args.userId,
        ),
      );
    },
  );
}

class OtpVerificationRouteArgs {
  const OtpVerificationRouteArgs({
    this.key,
    required this.email,
    required this.sentOtp,
    required this.newPhone,
    required this.userId,
  });

  final _i29.Key? key;

  final String email;

  final String sentOtp;

  final String newPhone;

  final String userId;

  @override
  String toString() {
    return 'OtpVerificationRouteArgs{key: $key, email: $email, sentOtp: $sentOtp, newPhone: $newPhone, userId: $userId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpVerificationRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        sentOtp == other.sentOtp &&
        newPhone == other.newPhone &&
        userId == other.userId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      email.hashCode ^
      sentOtp.hashCode ^
      newPhone.hashCode ^
      userId.hashCode;
}

/// generated route for
/// [_i18.ProfileScreen]
class ProfileRoute extends _i28.PageRouteInfo<void> {
  const ProfileRoute({List<_i28.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i18.ProfileScreen());
    },
  );
}

/// generated route for
/// [_i19.RescueDetailScreen]
class RescueDetailRoute extends _i28.PageRouteInfo<RescueDetailRouteArgs> {
  RescueDetailRoute({
    _i29.Key? key,
    required String rescueId,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         RescueDetailRoute.name,
         args: RescueDetailRouteArgs(key: key, rescueId: rescueId),
         initialChildren: children,
       );

  static const String name = 'RescueDetailRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RescueDetailRouteArgs>();
      return _i19.RescueDetailScreen(key: args.key, rescueId: args.rescueId);
    },
  );
}

class RescueDetailRouteArgs {
  const RescueDetailRouteArgs({this.key, required this.rescueId});

  final _i29.Key? key;

  final String rescueId;

  @override
  String toString() {
    return 'RescueDetailRouteArgs{key: $key, rescueId: $rescueId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RescueDetailRouteArgs) return false;
    return key == other.key && rescueId == other.rescueId;
  }

  @override
  int get hashCode => key.hashCode ^ rescueId.hashCode;
}

/// generated route for
/// [_i20.RescueListScreen]
class RescueListRoute extends _i28.PageRouteInfo<void> {
  const RescueListRoute({List<_i28.PageRouteInfo>? children})
    : super(RescueListRoute.name, initialChildren: children);

  static const String name = 'RescueListRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i20.RescueListScreen();
    },
  );
}

/// generated route for
/// [_i21.ResetPasswordScreen]
class ResetPasswordRoute extends _i28.PageRouteInfo<void> {
  const ResetPasswordRoute({List<_i28.PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i21.ResetPasswordScreen();
    },
  );
}

/// generated route for
/// [_i22.SettingsScreen]
class SettingsRoute extends _i28.PageRouteInfo<void> {
  const SettingsRoute({List<_i28.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i22.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i23.SharePostScreen]
class SharePostRoute extends _i28.PageRouteInfo<SharePostRouteArgs> {
  SharePostRoute({
    required int postId,
    String? previewContent,
    _i29.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         SharePostRoute.name,
         args: SharePostRouteArgs(
           postId: postId,
           previewContent: previewContent,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'SharePostRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SharePostRouteArgs>();
      return _i28.WrappedRoute(
        child: _i23.SharePostScreen(
          postId: args.postId,
          previewContent: args.previewContent,
          key: args.key,
        ),
      );
    },
  );
}

class SharePostRouteArgs {
  const SharePostRouteArgs({
    required this.postId,
    this.previewContent,
    this.key,
  });

  final int postId;

  final String? previewContent;

  final _i29.Key? key;

  @override
  String toString() {
    return 'SharePostRouteArgs{postId: $postId, previewContent: $previewContent, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SharePostRouteArgs) return false;
    return postId == other.postId &&
        previewContent == other.previewContent &&
        key == other.key;
  }

  @override
  int get hashCode => postId.hashCode ^ previewContent.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i24.SignInScreen]
class SignInRoute extends _i28.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i29.Key? key,
    void Function(bool)? onResult,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         SignInRoute.name,
         args: SignInRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignInRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i28.WrappedRoute(
        child: _i24.SignInScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.onResult});

  final _i29.Key? key;

  final void Function(bool)? onResult;

  @override
  String toString() {
    return 'SignInRouteArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignInRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i25.SignUpScreen]
class SignUpRoute extends _i28.PageRouteInfo<void> {
  const SignUpRoute({List<_i28.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return _i28.WrappedRoute(child: const _i25.SignUpScreen());
    },
  );
}

/// generated route for
/// [_i26.UserProfileScreen]
class UserProfileRoute extends _i28.PageRouteInfo<UserProfileRouteArgs> {
  UserProfileRoute({
    _i29.Key? key,
    required String userId,
    String? userName,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         UserProfileRoute.name,
         args: UserProfileRouteArgs(
           key: key,
           userId: userId,
           userName: userName,
         ),
         initialChildren: children,
       );

  static const String name = 'UserProfileRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserProfileRouteArgs>();
      return _i28.WrappedRoute(
        child: _i26.UserProfileScreen(
          key: args.key,
          userId: args.userId,
          userName: args.userName,
        ),
      );
    },
  );
}

class UserProfileRouteArgs {
  const UserProfileRouteArgs({this.key, required this.userId, this.userName});

  final _i29.Key? key;

  final String userId;

  final String? userName;

  @override
  String toString() {
    return 'UserProfileRouteArgs{key: $key, userId: $userId, userName: $userName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserProfileRouteArgs) return false;
    return key == other.key &&
        userId == other.userId &&
        userName == other.userName;
  }

  @override
  int get hashCode => key.hashCode ^ userId.hashCode ^ userName.hashCode;
}

/// generated route for
/// [_i27.WebViewScreen]
class WebViewRoute extends _i28.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i29.Key? key,
    required String url,
    String? title,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i27.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, this.title});

  final _i29.Key? key;

  final String url;

  final String? title;

  @override
  String toString() {
    return 'WebViewRouteArgs{key: $key, url: $url, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WebViewRouteArgs) return false;
    return key == other.key && url == other.url && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ url.hashCode ^ title.hashCode;
}
