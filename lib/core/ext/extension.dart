import 'package:amayalert/feature/posts/post_model.dart';
import 'package:dart_mappable/dart_mappable.dart';

extension SafePostMapper on PostMapper {
  static Post fromSupabase(Map<String, dynamic> map) {
    final shared = map['shared_post'];
    // 🧩 If Supabase returned an int instead of a nested map,
    // just set it to null to prevent MapperException.
    if (shared is int) {
      map = Map<String, dynamic>.from(map);
      map['shared_post'] = null;
    }
    return PostMapper.fromMap(map);
  }
}

class PostHook extends MappingHook {
  @override
  Object? beforeDecode(Object? value) {
    if (value is Map<String, dynamic>) {
      final shared = value['shared_post'];

      // 🧠 If the shared_post is just an integer, ignore it
      if (shared is int) {
        value['shared_post'] = null;
      }

      // 🧠 If it's a map but *its own* shared_post is an int, clean that too
      if (shared is Map<String, dynamic>) {
        final nested = shared['shared_post'];
        if (nested is int) {
          shared['shared_post'] = null;
        }
      }
    }
    return value;
  }
}

extension StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).split('_').join(' ');
  }
}
