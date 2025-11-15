import 'package:dart_mappable/dart_mappable.dart';

part 'report_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Report with ReportMappable {
  final int id;
  final String createdAt;
  final int post;
  final String reason;
  final String reportedBy;

  const Report({
    required this.id,
    required this.createdAt,
    required this.post,
    required this.reason,
    required this.reportedBy,
  });

  static const fromMap = ReportMapper.fromMap;
  static const fromJson = ReportMapper.fromJson;
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CreateReportRequest with CreateReportRequestMappable {
  final int post;
  final String reason;
  final String reportedBy;

  const CreateReportRequest({
    required this.post,
    required this.reason,
    required this.reportedBy,
  });

  static const fromMap = CreateReportRequestMapper.fromMap;
  static const fromJson = CreateReportRequestMapper.fromJson;
}

// Common report reasons
class ReportReasons {
  static const String spam = 'Spam';
  static const String harassment = 'Harassment';
  static const String inappropriateContent = 'Inappropriate Content';
  static const String falseInformation = 'False Information';
  static const String violence = 'Violence or Dangerous Content';
  static const String hateSpeech = 'Hate Speech';
  static const String copyright = 'Copyright Violation';
  static const String other = 'Other';

  static const List<String> all = [
    spam,
    harassment,
    inappropriateContent,
    falseInformation,
    violence,
    hateSpeech,
    copyright,
    other,
  ];
}
