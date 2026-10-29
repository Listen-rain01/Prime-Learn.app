import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/exam/data/models/exam_paper_dto.dart';
import 'package:primelearn/features/exam/data/parsers/exam_page_parser.dart';
import 'package:primelearn/features/exam/data/parsers/exam_paper_parser.dart';
import 'package:primelearn/features/exam/data/parsers/exam_submit_parser.dart';
import 'package:primelearn/features/exam/data/services/exam_api.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';

/// 考试仓储实现。
class ExamRepositoryImpl implements ExamRepository {
  /// 创建仓储实现。
  ExamRepositoryImpl(this._api, {this.pageParser = const ExamPageParser()});

  final ExamApi _api;
  final ExamPageParser pageParser;
  static const ExamPaperParser _paperParser = ExamPaperParser();

  @override
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  }) async {
    final body = await _api.fetchPapers(userId, bankId);
    return _paperParser.parse(body).map(toExamPaper).toList(growable: false);
  }

  @override
  Future<String> createExam({
    required String userId,
    required String paperId,
    required int type,
  }) async {
    final decoded = JsonEnvelope.decode(
      await _api.createExam(userId: userId, paperId: paperId, type: type),
      label: '创建考试',
    );
    final ksmxid = decoded['data']?.toString().trim() ?? '';
    if (ksmxid.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '创建考试未返回 ksmxid',
      );
    }
    return ksmxid;
  }

  @override
  Future<void> enterExam({
    required String ksmxid,
    required String userId,
    required int style,
  }) async {
    JsonEnvelope.decode(
      await _api.enterExam(ksmxid: ksmxid, userId: userId, style: style),
      label: '进入考试',
    );
  }

  @override
  Future<ExamPageData> fetchExamPage() async =>
      pageParser.parse(await _api.fetchExamPage());

  @override
  Future<void> submitAnswers({
    required String ksmxid,
    required String answer,
  }) async {
    // 平台返回非标准 JSON（键未加引号），用专用解析器。
    const ExamSubmitParser().parse(
      await _api.submitAnswers(ksmxid: ksmxid, answer: answer),
    );
  }

  @override
  Future<ExamResult> settleMock(String ksmxid) async =>
      _parseSettle(await _api.settleMock(ksmxid));

  @override
  Future<ExamResult> settleMobile({
    required String ksmxid,
    required String mxid2,
    required String mxid3,
  }) async => _parseSettle(
    await _api.settleMobile(ksmxid: ksmxid, mxid2: mxid2, mxid3: mxid3),
  );

  ExamResult _parseSettle(String body) {
    if (body.trim().isEmpty) {
      throw const ApiException(kind: ApiErrorKind.protocol, message: '结算返回空响应');
    }
    if (body.trim() == 'error') {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '结算失败：考试会话无效或已结算',
      );
    }
    final parts = body.split('|');
    // 平台实测返回整数，但 `100.0` 这类形态也必须能解析，否则整场成绩丢失。
    final scoreText = parts.length > 1 ? parts[1].trim() : '';
    final scoreValue = double.tryParse(scoreText);
    if (scoreValue == null) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '无法解析结算分数',
      );
    }
    final passText = parts.length > 2 ? parts[2].trim() : '';
    return ExamResult(
      score: scoreValue.round(),
      passed: _isPassed(passText),
      message: parts.first.trim(),
    );
  }

  /// 判定是否合格。
  ///
  /// 不能用 `contains('合格') && !contains('不合格')`：平台会返回「未合格」，
  /// 它同时含「合格」且不含「不合格」，会被误判成合格。
  /// 因此先判否定形态（未合格 / 不合格 / 不及格），再判肯定形态。
  bool _isPassed(String text) {
    if (text.isEmpty) return false;
    const negative = ['未合格', '不合格', '不及格', '未能合格'];
    for (final word in negative) {
      if (text.contains(word)) return false;
    }
    return text.contains('合格') || text.contains('及格');
  }
}
