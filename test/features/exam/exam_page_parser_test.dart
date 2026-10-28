import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/data/parsers/exam_page_parser.dart';
import 'package:primelearn/features/exam/domain/exam_answer_builder.dart';

String _vDataHtml(List<List<String>> records) {
  final array = records.map((fields) => fields.join(',')).join('|');
  return 'var vData = {"AllCount":"${records.length}",'
      '"ExamTypeName":"模拟题库","AllQuestionArray":"$array"};';
}

List<String> _record(String id, {String correct = 'A', String type = '1'}) {
  final fields = List<String>.filled(22, '');
  fields[0] = 'rec-$id';
  fields[1] = id;
  fields[2] = '1';
  fields[10] = '1';
  fields[13] = correct;
  fields[14] = type;
  fields[15] = Uri.encodeComponent('第 $id 题题干');
  fields[16] =
      '${Uri.encodeComponent('A.选项一')}#'
      '${Uri.encodeComponent('B.选项二')}';
  return fields;
}

void main() {
  const parser = ExamPageParser();

  test('解析 vData 与题目字段', () {
    final page = parser.parse(_vDataHtml([_record('q1')]));

    expect(page.questions, hasLength(1));
    expect(page.examTypeName, '模拟题库');
    expect(page.totalCount, 1);
    final question = page.questions.single;
    expect(question.id, 'q1');
    expect(question.correctAnswer, 'A');
    expect(question.stem, '第 q1 题题干');
    expect(question.options, ['A.选项一', 'B.选项二']);
  });

  test('尾部空字段被省略时仍可解析', () {
    final fields = _record('q1').sublist(0, 15);
    final page = parser.parse(_vDataHtml([fields]));

    expect(page.questions.single.id, 'q1');
    expect(page.questions.single.stem, '');
    expect(page.questions.single.options, isEmpty);
  });

  test('缺少 vData 时抛协议异常', () {
    expect(
      () => parser.parse('<html></html>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '考试页缺少 vData'),
      ),
    );
  });

  test('答案串把字段 13 写入字段 4', () {
    final page = parser.parse(
      _vDataHtml([_record('q1', correct: 'B'), _record('q2', correct: 'Y')]),
    );

    final answer = buildExamAnswer(page.questions);

    expect(answer.split('|'), hasLength(2));
    final first = answer.split('|').first.split(',');
    expect(first, hasLength(15));
    expect(first[4], 'B');
    final second = answer.split('|').last.split(',');
    expect(second[4], 'Y');
  });
}
