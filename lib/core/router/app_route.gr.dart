// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:amayalert/feature/activity/activity_screen.dart' as _i1;
import 'package:amayalert/feature/auth/change_password_screen.dart' as _i2;
import 'package:amayalert/feature/auth/forgot_password_screen.dart' as _i8;
import 'package:amayalert/feature/auth/on_boarding_screen.dart' as _i14;
import 'package:amayalert/feature/auth/reset_password_screen.dart' as _i19;
import 'package:amayalert/feature/auth/sign_in_screen.dart' as _i22;
import 'package:amayalert/feature/auth/sign_up_screen.dart' as _i23;
import 'package:amayalert/feature/home/home_screen.dart' as _i9;
import 'package:amayalert/feature/main/main_screen.dart' as _i10;
import 'package:amayalert/feature/maps/map_screen.dart' as _i11;
import 'package:amayalert/feature/messages/chat_screen.dart' as _i3;
import 'package:amayalert/feature/messages/message_screen.dart' as _i12;
import 'package:amayalert/feature/messages/new_conversation_screen.dart'
    as _i13;
import 'package:amayalert/feature/posts/comments_screen.dart' as _i4;
import 'package:amayalert/feature/posts/create_posts_screen.dart' as _i5;
import 'package:amayalert/feature/posts/share_post_screen.dart' as _i21;
import 'package:amayalert/feature/profile/edit_profile_screen.dart' as _i7;
import 'package:amayalert/feature/profile/otp_verification_screen.dart' as _i15;
import 'package:amayalert/feature/profile/profile_model.dart' as _i29;
import 'package:amayalert/feature/profile/profile_screen.dart' as _i16;
import 'package:amayalert/feature/profile/user_profile_screen.dart' as _i24;
import 'package:amayalert/feature/rescue/create_rescue_screen.dart' as _i6;
import 'package:amayalert/feature/rescue/rescue_detail_screen.dart' as _i17;
import 'package:amayalert/feature/rescue/rescue_list_screen.dart' as _i18;
import 'package:amayalert/feature/settings/settings_screen.dart' as _i20;
import 'package:amayalert/feature/webview/webview_screen.dart' as _i25;
import 'package:auto_route/auto_route.dart' as _i26;
import 'package:flutter/material.dart' as _i27;
import 'package:image_picker/image_picker.dart' as _i28;

/// generated route for
/// [_i1.ActivityScreen]
class ActivityRoute extends _i26.PageRouteInfo<void> {
  const ActivityRoute({List<_i26.PageRouteInfo>? children})
    : super(ActivityRoute.name, initialChildren: children);

  static const String name = 'ActivityRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i1.ActivityScreen());
    },
  );
}

/// generated route for
/// [_i2.ChangePasswordScreen]
class ChangePasswordRoute extends _i26.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i26.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i2.ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [_i3.ChatScreen]
class ChatRoute extends _i26.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i27.Key? key,
    required String otherUserId,
    required String otherUserName,
    _i28.ImagePicker? imagePicker,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(
           key: key,
           otherUserId: otherUserId,
           otherUserName: otherUserName,
           imagePicker: imagePicker,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i26.WrappedRoute(
        child: _i3.ChatScreen(
          key: args.key,
          otherUserId: args.otherUserId,
          otherUserName: args.otherUserName,
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
    this.imagePicker,
  });

  final _i27.Key? key;

  final String otherUserId;

  final String otherUserName;

  final _i28.ImagePicker? imagePicker;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, otherUserId: $otherUserId, otherUserName: $otherUserName, imagePicker: $imagePicker}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        otherUserId == other.otherUserId &&
        otherUserName == other.otherUserName &&
        imagePicker == other.imagePicker;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      otherUserId.hashCode ^
      otherUserName.hashCode ^
      imagePicker.hashCode;
}

/// generated route for
/// [_i4.CommentsScreen]
class CommentsRoute extends _i26.PageRouteInfo<CommentsRouteArgs> {
  CommentsRoute({
    required int postId,
    _i27.Key? key,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         CommentsRoute.name,
         args: CommentsRouteArgs(postId: postId, key: key),
         initialChildren: children,
       );

  static const String name = 'CommentsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommentsRouteArgs>();
      return _i26.WrappedRoute(
        child: _i4.CommentsScreen(postId: args.postId, key: args.key),
      );
    },
  );
}

class CommentsRouteArgs {
  const CommentsRouteArgs({required this.postId, this.key});

  final int postId;

  final _i27.Key? key;

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
/// [_i5.CreatePostsScreen]
class CreatePostsRoute extends _i26.PageRouteInfo<void> {
  const CreatePostsRoute({List<_i26.PageRouteInfo>? children})
    : super(CreatePostsRoute.name, initialChildren: children);

  static const String name = 'CreatePostsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i5.CreatePostsScreen());
    },
  );
}

/// generated route for
/// [_i6.CreateRescueScreen]
class CreateRescueRoute extends _i26.PageRouteInfo<void> {
  const CreateRescueRoute({List<_i26.PageRouteInfo>? children})
    : super(CreateRescueRoute.name, initialChildren: children);

  static const String name = 'CreateRescueRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i6.CreateRescueScreen();
    },
  );
}

/// generated route for
/// [_i7.EditProfileScreen]
class EditProfileRoute extends _i26.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i27.Key? key,
    required _i29.Profile profile,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i7.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i27.Key? key;

  final _i29.Profile profile;

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
/// [_i8.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i26.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i26.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i8.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i9.HomeScreen]
class HomeRoute extends _i26.PageRouteInfo<void> {
  const HomeRoute({List<_i26.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i9.HomeScreen());
    },
  );
}

/// generated route for
/// [_i10.MainScreen]
class MainRoute extends _i26.PageRouteInfo<void> {
  const MainRoute({List<_i26.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i10.MainScreen();
    },
  );
}

/// generated route for
/// [_i11.MapScreen]
class MapRoute extends _i26.PageRouteInfo<void> {
  const MapRoute({List<_i26.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i11.MapScreen());
    },
  );
}

/// generated route for
/// [_i12.MessageScreen]
class MessageRoute extends _i26.PageRouteInfo<void> {
  const MessageRoute({List<_i26.PageRouteInfo>? children})
    : super(MessageRoute.name, initialChildren: children);

  static const String name = 'MessageRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i12.MessageScreen());
    },
  );
}

/// generated route for
/// [_i13.NewConversationScreen]
class NewConversationRoute extends _i26.PageRouteInfo<void> {
  const NewConversationRoute({List<_i26.PageRouteInfo>? children})
    : super(NewConversationRoute.name, initialChildren: children);

  static const String name = 'NewConversationRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i13.NewConversationScreen());
    },
  );
}

/// generated route for
/// [_i14.OnBoardingScreen]
class OnBoardingRoute extends _i26.PageRouteInfo<OnBoardingRouteArgs> {
  OnBoardingRoute({
    _i27.Key? key,
    void Function(bool)? onResult,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         OnBoardingRoute.name,
         args: OnBoardingRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'OnBoardingRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnBoardingRouteArgs>(
        orElse: () => const OnBoardingRouteArgs(),
      );
      return _i26.WrappedRoute(
        child: _i14.OnBoardingScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class OnBoardingRouteArgs {
  const OnBoardingRouteArgs({this.key, this.onResult});

  final _i27.Key? key;

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
/// [_i15.OtpVerificationScreen]
class OtpVerificationRoute
    extends _i26.PageRouteInfo<OtpVerificationRouteArgs> {
  OtpVerificationRoute({
    _i27.Key? key,
    required String email,
    required String sentOtp,
    required String newPhone,
    required String userId,
    List<_i26.PageRouteInfo>? children,
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

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpVerificationRouteArgs>();
      return _i26.WrappedRoute(
        child: _i15.OtpVerificationScreen(
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

  final _i27.Key? key;

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
/// [_i16.ProfileScreen]
class ProfileRoute extends _i26.PageRouteInfo<void> {
  const ProfileRoute({List<_i26.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i16.ProfileScreen());
    },
  );
}

/// generated route for
/// [_i17.RescueDetailScreen]
class RescueDetailRoute extends _i26.PageRouteInfo<RescueDetailRouteArgs> {
  RescueDetailRoute({
    _i27.Key? key,
    required String rescueId,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         RescueDetailRoute.name,
         args: RescueDetailRouteArgs(key: key, rescueId: rescueId),
         initialChildren: children,
       );

  static const String name = 'RescueDetailRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RescueDetailRouteArgs>();
      return _i17.RescueDetailScreen(key: args.key, rescueId: args.rescueId);
    },
  );
}

class RescueDetailRouteArgs {
  const RescueDetailRouteArgs({this.key, required this.rescueId});

  final _i27.Key? key;

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
/// [_i18.RescueListScreen]
class RescueListRoute extends _i26.PageRouteInfo<void> {
  const RescueListRoute({List<_i26.PageRouteInfo>? children})
    : super(RescueListRoute.name, initialChildren: children);

  static const String name = 'RescueListRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i18.RescueListScreen();
    },
  );
}

/// generated route for
/// [_i19.ResetPasswordScreen]
class ResetPasswordRoute extends _i26.PageRouteInfo<void> {
  const ResetPasswordRoute({List<_i26.PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i19.ResetPasswordScreen();
    },
  );
}

/// generated route for
/// [_i20.SettingsScreen]
class SettingsRoute extends _i26.PageRouteInfo<void> {
  const SettingsRoute({List<_i26.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i20.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i21.SharePostScreen]
class SharePostRoute extends _i26.PageRouteInfo<SharePostRouteArgs> {
  SharePostRoute({
    required int postId,
    String? previewContent,
    _i27.Key? key,
    List<_i26.PageRouteInfo>? children,
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

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SharePostRouteArgs>();
      return _i26.WrappedRoute(
        child: _i21.SharePostScreen(
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

  final _i27.Key? key;

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
/// [_i22.SignInScreen]
class SignInRoute extends _i26.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i27.Key? key,
    void Function(bool)? onResult,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         SignInRoute.name,
         args: SignInRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignInRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i26.WrappedRoute(
        child: _i22.SignInScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.onResult});

  final _i27.Key? key;

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
/// [_i23.SignUpScreen]
class SignUpRoute extends _i26.PageRouteInfo<void> {
  const SignUpRoute({List<_i26.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return _i26.WrappedRoute(child: const _i23.SignUpScreen());
    },
  );
}

/// generated route for
/// [_i24.UserProfileScreen]
class UserProfileRoute extends _i26.PageRouteInfo<UserProfileRouteArgs> {
  UserProfileRoute({
    _i27.Key? key,
    required String userId,
    String? userName,
    List<_i26.PageRouteInfo>? children,
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

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserProfileRouteArgs>();
      return _i26.WrappedRoute(
        child: _i24.UserProfileScreen(
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

  final _i27.Key? key;

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
/// [_i25.WebViewScreen]
class WebViewRoute extends _i26.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i27.Key? key,
    required String url,
    String? title,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i25.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, this.title});

  final _i27.Key? key;

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
