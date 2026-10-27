/// 签到 DTO。
class CheckInDto {
  /// 创建 DTO。
  const CheckInDto({required this.message});

  /// 由 JSON 构造。
  factory CheckInDto.fromJson(Map<String, dynamic> json) =>
      CheckInDto(message: json['message']?.toString() ?? '');

  /// 服务端 message：`操作成功` / `已签到`。
  final String message;
}
