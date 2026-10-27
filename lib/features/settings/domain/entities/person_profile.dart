/// 个人信息（来自 `POST /PersonWap/MyBaseInfo` 的 HTML 内嵌 `vData`）。
class PersonProfile {
  /// 创建个人信息。
  const PersonProfile({
    required this.employeeNo,
    required this.name,
    required this.idCard,
    required this.department,
    required this.phone,
    required this.address,
    this.departmentId,
  });

  /// 工号（`vData.pnum`）。
  final String employeeNo;

  /// 姓名（`vData.pname`）。
  final String name;

  /// 身份证号（`vData.idcard`）。
  final String idCard;

  /// 工作单位（`vData.punit`）。
  final String department;

  /// 联系方式（`vData.tel`）。
  final String phone;

  /// 家庭地址（`vData.address`）。
  final String address;

  /// 部门 ID（`vData.DepartmentId`），头像接口需要。
  final String? departmentId;

  /// 是否所有字段都为空（用于隐藏卡片）。
  bool get isEmpty =>
      employeeNo.isEmpty &&
      name.isEmpty &&
      idCard.isEmpty &&
      department.isEmpty &&
      phone.isEmpty &&
      address.isEmpty;
}
