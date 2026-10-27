import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/data/parsers/exam_paper_parser.dart';

void main() {
  const parser = ExamPaperParser();

  test('解析可考试卷', () {
    final papers = parser.parse('''
{"totalCount": 1, "success": true, "error": "", "data": [
  {"PaperId": "2069a073-0000-0000-0000-000000000001", "PaperName": "2025陕西煤业矿业公司主要负责人", "TotalScore": 100.0, "PassingGrade": 80.0}
]}''');

    expect(papers.single.id, '2069a073-0000-0000-0000-000000000001');
    expect(papers.single.name, '2025陕西煤业矿业公司主要负责人');
    expect(papers.single.totalScore, 100);
    expect(papers.single.passingGrade, 80);
  });

  test('无试卷返回空列表', () {
    expect(
      parser.parse('{"totalCount": 0, "success": true, "data": []}'),
      isEmpty,
    );
  });

  test('success=false 透传错误文案', () {
    expect(
      () => parser.parse('{"success": false, "error": "题库不存在", "data": []}'),
      throwsA(isA<ApiException>()),
    );
  });

  test('空响应抛协议异常', () {
    expect(
      () => parser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });
}
