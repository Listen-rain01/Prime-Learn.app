// 手动真实环境探针（不参与 CI、不参与测试）。
//
// 用途：登录 → 校验会话 → 读取今日任务，用于取证与协议核对。
// 凭据只从环境变量读取，不落盘、不输出：
//   PL_ID   身份证号
//   PL_PWD  密码
//   PL_DUMP 设为 1 时额外输出脱敏后的原始响应（GUID 替换为 <guid>）
//
// 用法（Windows PowerShell）：
//   $env:PL_ID='...'; $env:PL_PWD='...'; dart run tool/live_probe.dart
//   Remove-Item Env:PL_ID,Env:PL_PWD
import 'dart:io';

import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/auth/data/parsers/exam_context_parser.dart';
import 'package:primelearn/features/auth/data/parsers/login_response_parser.dart';
import 'package:primelearn/features/tasks/data/parsers/daily_tasks_parser.dart';
import 'package:primelearn/features/tasks/data/services/tasks_api.dart';

Future<void> main() async {
  final id = Platform.environment['PL_ID'] ?? '';
  final pwd = Platform.environment['PL_PWD'] ?? '';
  if (id.isEmpty || pwd.isEmpty) {
    stderr.writeln('缺少 PL_ID / PL_PWD');
    exit(2);
  }

  final client = ApiClient();
  const esdt = EsdtCodec();

  try {
    await client.getValidateCode();
    stdout.writeln('[1/4] 预建会话 OK');

    final loginBody = await client.postForm('/PersonWap/GetPersonInfo', {
      'idcard': esdt.encode(id),
      'pwd': esdt.encode(pwd),
      'yzm': 'auto',
      'openid': '',
      'style': '0',
      'auto': 'true',
    });
    final login = const LoginResponseParser().parse(loginBody);
    stdout.writeln(
      '[2/4] 登录 OK：userId=${login.userId.substring(0, 8)}… '
      'name=${_maskName(login.userName)} code=${login.returnCode}',
    );

    final bankBody = await client.postForm('/PersonWap/FirstIndexOne', {
      'pid': login.userId,
    });
    final bank = const ExamContextParser().parse(bankBody);
    stdout.writeln(
      '[3/4] 会话校验 OK：bank=${bank.bankName} examTypeId=${bank.examTypeId}',
    );

    final raw = await client.getRaw(TasksApi.dailyTasksPath(login.userId));
    final tasks = const DailyTasksParser().parse(raw);
    stdout.writeln('[4/4] 今日任务 OK：${tasks.length} 条');
    for (final task in tasks) {
      stdout.writeln(
        '  - ${task.criterion.padRight(15)} ${task.name} '
        '${task.currentScore}/${task.maxScore} '
        'score=${task.score} sort=${task.sort} '
        'state="${task.progressText}"',
      );
    }

    if (Platform.environment['PL_DUMP'] == '1') {
      stdout.writeln('--- redacted raw ---');
      stdout.writeln(_redact(raw));
    }
  } on Object catch (error) {
    stderr.writeln('FAILED: ${error.runtimeType}: $error');
    exit(1);
  }
}

String _maskName(String name) {
  if (name.isEmpty) return '';
  return '${name.substring(0, 1)}${'*' * (name.length - 1)}';
}

/// 仅用于人工核对：把 GUID / 用户 ID 等可识别值替换为占位符。
String _redact(String raw) => raw.replaceAll(
  RegExp(
    r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
  ),
  '<guid>',
);
