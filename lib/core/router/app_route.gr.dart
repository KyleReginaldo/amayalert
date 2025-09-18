// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:amayalert/feature/activity/activity_screen.dart' as _i1;
import 'package:amayalert/feature/auth/on_boarding_screen.dart' as _i8;
import 'package:amayalert/feature/auth/sign_in_screen.dart' as _i10;
import 'package:amayalert/feature/auth/sign_up_screen.dart' as _i11;
import 'package:amayalert/feature/home/home_screen.dart' as _i4;
import 'package:amayalert/feature/main/main_screen.dart' as _i5;
import 'package:amayalert/feature/maps/map_screen.dart' as _i6;
import 'package:amayalert/feature/messages/message_screen.dart' as _i7;
import 'package:amayalert/feature/posts/create_posts_screen.dart' as _i2;
import 'package:amayalert/feature/profile/edit_profile_screen.dart' as _i3;
import 'package:amayalert/feature/profile/profile_model.dart' as _i14;
import 'package:amayalert/feature/profile/profile_screen.dart' as _i9;
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:flutter/material.dart' as _i13;

/// generated route for
/// [_i1.ActivityScreen]
class ActivityRoute extends _i12.PageRouteInfo<void> {
  const ActivityRoute({List<_i12.PageRouteInfo>? children})
    : super(ActivityRoute.name, initialChildren: children);

  static const String name = 'ActivityRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i1.ActivityScreen();
    },
  );
}

/// generated route for
/// [_i2.CreatePostsScreen]
class CreatePostsRoute extends _i12.PageRouteInfo<void> {
  const CreatePostsRoute({List<_i12.PageRouteInfo>? children})
    : super(CreatePostsRoute.name, initialChildren: children);

  static const String name = 'CreatePostsRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreatePostsScreen();
    },
  );
}

/// generated route for
/// [_i3.EditProfileScreen]
class EditProfileRoute extends _i12.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i13.Key? key,
    required _i14.Profile profile,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i3.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i13.Key? key;

  final _i14.Profile profile;

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
/// [_i4.HomeScreen]
class HomeRoute extends _i12.PageRouteInfo<void> {
  const HomeRoute({List<_i12.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return _i12.WrappedRoute(child: const _i4.HomeScreen());
    },
  );
}

/// generated route for
/// [_i5.MainScreen]
class MainRoute extends _i12.PageRouteInfo<void> {
  const MainRoute({List<_i12.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i5.MainScreen();
    },
  );
}

/// generated route for
/// [_i6.MapScreen]
class MapRoute extends _i12.PageRouteInfo<void> {
  const MapRoute({List<_i12.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i6.MapScreen();
    },
  );
}

/// generated route for
/// [_i7.MessageScreen]
class MessageRoute extends _i12.PageRouteInfo<void> {
  const MessageRoute({List<_i12.PageRouteInfo>? children})
    : super(MessageRoute.name, initialChildren: children);

  static const String name = 'MessageRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i7.MessageScreen();
    },
  );
}

/// generated route for
/// [_i8.OnBoardingScreen]
class OnBoardingRoute extends _i12.PageRouteInfo<OnBoardingRouteArgs> {
  OnBoardingRoute({
    _i13.Key? key,
    void Function(bool)? onResult,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         OnBoardingRoute.name,
         args: OnBoardingRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'OnBoardingRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnBoardingRouteArgs>(
        orElse: () => const OnBoardingRouteArgs(),
      );
      return _i8.OnBoardingScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class OnBoardingRouteArgs {
  const OnBoardingRouteArgs({this.key, this.onResult});

  final _i13.Key? key;

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
/// [_i9.ProfileScreen]
class ProfileRoute extends _i12.PageRouteInfo<void> {
  const ProfileRoute({List<_i12.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return _i12.WrappedRoute(child: const _i9.ProfileScreen());
    },
  );
}

/// generated route for
/// [_i10.SignInScreen]
class SignInRoute extends _i12.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({
    _i13.Key? key,
    void Function(bool)? onResult,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         SignInRoute.name,
         args: SignInRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignInRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return _i10.SignInScreen(key: args.key, onResult: args.onResult);
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.onResult});

  final _i13.Key? key;

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
/// [_i11.SignUpScreen]
class SignUpRoute extends _i12.PageRouteInfo<void> {
  const SignUpRoute({List<_i12.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i11.SignUpScreen();
    },
  );
}
