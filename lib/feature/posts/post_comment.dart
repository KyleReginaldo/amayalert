// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'post_comment.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class PostComment with PostCommentMappable {
  final int id;
  final String? comment;
  final DateTime createdAt;
  final Profile? user;
  final int post;

  PostComment({
    required this.id,
    this.comment,
    required this.createdAt,
    this.user,
    required this.post,
  });
}
