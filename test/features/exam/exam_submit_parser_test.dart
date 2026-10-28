import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/data/parsers/exam_submit_parser.dart';

void main() {
  const parser = ExamSubmitParser();

  test('接受平台非标准 JSON 的成功响应', () {
    expect(
      () => parser.parse(
        '{totalCount:1,success:true,error:"",singleInfo:"",data:[{"Result":""}]}',
      ),
      returnsNormally,
    );
  });

  test('接受标准 JSON 的成功响应', () {
    expect(
      () => parser.parse('{"success":true,"data":[{"Result":""}]}'),
      returnsNormally,
    );
  });

  test('success=false 抛出失败', () {
    expect(
      () => parser.parse('{success:false,error:"提交失败"}'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '提交答案失败'),
      ),
    );
  });

  test('空响应抛协议异常', () {
    expect(
      () => parser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '提交答案返回空响应'),
      ),
    );
  });
}
