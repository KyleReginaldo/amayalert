// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:amayalert/feature/activity/activity_screen.dart' as _i1;
import 'package:amayalert/feature/auth/on_boarding_screen.dart' as _i12;
import 'package:amayalert/feature/auth/sign_in_screen.dart' as _i18;
import 'package:amayalert/feature/auth/sign_up_screen.dart' as _i19;
import 'package:amayalert/feature/home/home_screen.dart' as _i7;
import 'package:amayalert/feature/main/main_screen.dart' as _i8;
import 'package:amayalert/feature/maps/map_screen.dart' as _i9;
import 'package:amayalert/feature/messages/chat_screen.dart' as _i2;
import 'package:amayalert/feature/messages/message_screen.dart' as _i10;
import 'package:amayalert/feature/messages/new_conversation_screen.dart'
    as _i11;
import 'package:amayalert/feature/posts/comments_screen.dart' as _i3;
import 'package:amayalert/feature/posts/create_posts_screen.dart' as _i4;
import 'package:amayalert/feature/posts/share_post_screen.dart' as _i17;
import 'package:amayalert/feature/profile/edit_profile_screen.dart' as _i6;
import 'package:amayalert/feature/profile/profile_model.dart' as _i23;
import 'package:amayalert/feature/profile/profile_screen.dart' as _i13;
import 'package:amayalert/feature/rescue/create_rescue_screen.dart' as _i5;
import 'package:amayalert/feature/rescue/rescue_detail_screen.dart' as _i14;
import 'package:amayalert/feature/rescue/rescue_list_screen.dart' as _i15;
import 'package:amayalert/feature/settings/settings_screen.dart' as _i16;
import 'package:amayalert/feature/webview/webview_screen.dart' as _i20;
import 'package:auto_route/auto_route.dart' as _i21;
import 'package:flutter/material.dart' as _i22;

/// generated route for
/// [_i1.ActivityScreen]
class ActivityRoute extends _i21.PageRouteInfo<void> {
  const ActivityRoute({List<_i21.PageRouteInfo>? children})
    : super(ActivityRoute.name, initialChildren: children);

  static const String name = 'ActivityRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i1.ActivityScreen());
    },
  );
}

/// generated route for
/// [_i2.ChatScreen]
class ChatRoute extends _i21.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i22.Key? key,
    required String otherUserId,
    required String otherUserName,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(
           key: key,
           otherUserId: otherUserId,
           otherUserName: otherUserName,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i21.WrappedRoute(
        child: _i2.ChatScreen(
          key: args.key,
          otherUserId: args.otherUserId,
          otherUserName: args.otherUserName,
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
  });

  final _i22.Key? key;

  final String otherUserId;

  final String otherUserName;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, otherUserId: $otherUserId, otherUserName: $otherUserName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key &&
        otherUserId == other.otherUserId &&
        otherUserName == other.otherUserName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ otherUserId.hashCode ^ otherUserName.hashCode;
}

/// generated route for
/// [_i3.CommentsScreen]
class CommentsRoute extends _i21.PageRouteInfo<CommentsRouteArgs> {
  CommentsRoute({
    required int postId,
    _i22.Key? key,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         CommentsRoute.name,
         args: CommentsRouteArgs(postId: postId, key: key),
         initialChildren: children,
       );

  static const String name = 'CommentsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommentsRouteArgs>();
      return _i21.WrappedRoute(
        child: _i3.CommentsScreen(postId: args.postId, key: args.key),
      );
    },
  );
}

class CommentsRouteArgs {
  const CommentsRouteArgs({required this.postId, this.key});

  final int postId;

  final _i22.Key? key;

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
/// [_i4.CreatePostsScreen]
class CreatePostsRoute extends _i21.PageRouteInfo<void> {
  const CreatePostsRoute({List<_i21.PageRouteInfo>? children})
    : super(CreatePostsRoute.name, initialChildren: children);

  static const String name = 'CreatePostsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i4.CreatePostsScreen());
    },
  );
}

/// generated route for
/// [_i5.CreateRescueScreen]
class CreateRescueRoute extends _i21.PageRouteInfo<void> {
  const CreateRescueRoute({List<_i21.PageRouteInfo>? children})
    : super(CreateRescueRoute.name, initialChildren: children);

  static const String name = 'CreateRescueRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i5.CreateRescueScreen();
    },
  );
}

/// generated route for
/// [_i6.EditProfileScreen]
class EditProfileRoute extends _i21.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i22.Key? key,
    required _i23.Profile profile,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i6.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i22.Key? key;

  final _i23.Profile profile;

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
/// [_i7.HomeScreen]
class HomeRoute extends _i21.PageRouteInfo<void> {
  const HomeRoute({List<_i21.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i7.HomeScreen());
    },
  );
}

/// generated route for
/// [_i8.MainScreen]
class MainRoute extends _i21.PageRouteInfo<void> {
  const MainRoute({List<_i21.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i8.MainScreen();
    },
  );
}

/// generated route for
/// [_i9.MapScreen]
class MapRoute extends _i21.PageRouteInfo<void> {
  const MapRoute({List<_i21.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i9.MapScreen());
    },
  );
}

/// generated route for
/// [_i10.MessageScreen]
class MessageRoute extends _i21.PageRouteInfo<void> {
  const MessageRoute({List<_i21.PageRouteInfo>? children})
    : super(MessageRoute.name, initialChildren: children);

  static const String name = 'MessageRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i10.MessageScreen());
    },
  );
}

/// generated route for
/// [_i11.NewConversationScreen]
class NewConversationRoute extends _i21.PageRouteInfo<void> {
  const NewConversationRoute({List<_i21.PageRouteInfo>? children})
    : super(NewConversationRoute.name, initialChildren: children);

  static const String name = 'NewConversationRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i11.NewConversationScreen());
    },
  );
}

/// generated route for
/// [_i12.OnBoardingScreen]
class OnBoardingRoute extends _i21.PageRouteInfo<OnBoardingRouteArgs> {
  OnBoardingRoute({
    _i22.Key? key,
    void Function(bool)? onResult,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         OnBoardingRoute.name,
         args: OnBoardingRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'OnBoardingRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnBoardingRouteArgs>(
        orElse: () => const OnBoardingRouteArgs(),
      );
      return _i21.WrappedRoute(
        child: _i12.OnBoardingScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class OnBoardingRouteArgs {
  const OnBoardingRouteArgs({this.key, this.onResult});

  final _i22.Key? key;

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
/// [_i13.ProfileScreen]
class ProfileRoute extends _i21.PageRouteInfo<void> {
  const ProfileRoute({List<_i21.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i13.ProfileScreen());
    },
  );
}

/// generated route for
/// [_i14.RescueDetailScreen]
class RescueDetailRoute extends _i21.PageRouteInfo<RescueDetailRouteArgs> {
  RescueDetailRoute({
    _i22.Key? key,
    required String rescueId,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         RescueDetailRoute.name,
         args: RescueDetailRouteArgs(key: key, rescueId: rescueId),
         initialChildren: children,
       );

  static const String name = 'RescueDetailRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RescueDetailRouteArgs>();
      return _i14.RescueDetailScreen(key: args.key, rescueId: args.rescueId);
    },
  );
}

class RescueDetailRouteArgs {
  const RescueDetailRouteArgs({this.key, required this.rescueId});

  final _i22.Key? key;

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
/// [_i15.RescueListScreen]
class RescueListRoute extends _i21.PageRouteInfo<void> {
  const RescueListRoute({List<_i21.PageRouteInfo>? children})
    : super(RescueListRoute.name, initialChildren: children);

  static const String name = 'RescueListRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i15.RescueListScreen();
    },
  );
}

/// generated route for
/// [_i16.SettingsScreen]
class SettingsRoute extends _i21.PageRouteInfo<void> {
  const SettingsRoute({List<_i21.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i16.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i17.SharePostScreen]
class SharePostRoute extends _i21.PageRouteInfo<SharePostRouteArgs> {
  SharePostRoute({
    required int postId,
    String? previewContent,
    _i22.Key? key,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SharePostRouteArgs>();
      return _i21.WrappedRoute(
        child: _i17.SharePostScreen(
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

  final _i22.Key? key;

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
/// [_i18.SignInScreen]
class SignInRoute extends _i21.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i22.Key? key,
    void Function(bool)? onResult,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         SignInRoute.name,
         args: SignInRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignInRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i21.WrappedRoute(
        child: _i18.SignInScreen(key: args.key, onResult: args.onResult),
      );
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.onResult});

  final _i22.Key? key;

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
/// [_i19.SignUpScreen]
class SignUpRoute extends _i21.PageRouteInfo<void> {
  const SignUpRoute({List<_i21.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return _i21.WrappedRoute(child: const _i19.SignUpScreen());
    },
  );
}

/// generated route for
/// [_i20.WebViewScreen]
class WebViewRoute extends _i21.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i22.Key? key,
    required String url,
    String? title,
    List<_i21.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i20.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, this.title});

  final _i22.Key? key;

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
