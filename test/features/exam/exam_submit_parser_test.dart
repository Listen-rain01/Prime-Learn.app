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

  test('success=false 抛出失败，并带上平台 error 文案', () {
    expect(
      () => parser.parse('{success:false,error:"提交失败"}'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '提交答案失败：提交失败'),
      ),
    );
  });

  test('success=false 且无 error 文案时给通用提示', () {
    expect(
      () => parser.parse('{success:false}'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '提交答案失败'),
      ),
    );
  });

  test('键名不含词边界（notsuccess）不得当成成功', () {
    expect(
      () => parser.parse('{notsuccess:true}'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '提交答案响应格式异常'),
      ),
    );
  });

  test('error 文案里出现 success:true 时仍判失败', () {
    expect(
      () => parser.parse('{"success":false,"error":"success:true"}'),
      throwsA(isA<ApiException>()),
    );
  });

  test('HTML 页面不得当成成功', () {
    expect(
      () => parser.parse('<html>success:true</html>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '提交答案响应格式异常'),
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
