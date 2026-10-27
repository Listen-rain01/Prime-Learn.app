/// 个人信息 DTO（`MyBaseInfo` 内嵌 `vData` 的字段映射）。
class PersonProfileDto {
  /// 创建 DTO。
  const PersonProfileDto({
    required this.employeeNo,
    required this.name,
    required this.idCard,
    required this.department,
    required this.phone,
    required this.address,
    this.departmentId,
  });

  /// 由 vData JSON 构造。
  factory PersonProfileDto.fromVData(Map<String, dynamic> json) =>
      PersonProfileDto(
        employeeNo: _text(json['pnum']),
        name: _text(json['pname']),
        idCard: _text(json['idcard']),
        department: _text(json['punit']),
        phone: _text(json['tel']),
        address: _text(json['address']),
        departmentId: _textOrNull(json['DepartmentId']),
      );

  /// 工号。
  final String employeeNo;

  /// 姓名。
  final String name;

  /// 身份证号。
  final String idCard;

  /// 工作单位。
  final String department;

  /// 联系方式。
  final String phone;

  /// 家庭地址。
  final String address;

  /// 部门 ID。
  final String? departmentId;
}

String _text(Object? value) => value?.toString().trim() ?? '';

String? _textOrNull(Object? value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}
