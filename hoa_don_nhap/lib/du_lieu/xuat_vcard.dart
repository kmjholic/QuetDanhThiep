/// Lỗi khi xuất/chia sẻ tệp vCard (không ghi được tệp, không mở được bảng chia sẻ…).
class LoiXuatVCard implements Exception {
  const LoiXuatVCard(this.chiTiet);
  final String chiTiet;

  @override
  String toString() => 'LoiXuatVCard: $chiTiet';
}

/// Đưa một tệp `.vcf` ra khỏi app qua bảng chia sẻ của hệ điều hành
/// (người dùng chọn Danh bạ, Zalo, Gmail, Drive…). Không cần quyền, không cần mạng.
///
/// Nội dung vCard do `TaoVCard` tạo ra; bản thật (`nen_tang/`) chỉ việc ghi [noiDung] thành tệp
/// tạm (UTF-8, không BOM) tên [tenTep] rồi mở bảng chia sẻ. Ném [LoiXuatVCard] khi thất bại.
abstract interface class BoXuatVCard {
  Future<void> chiaSe({required String tenTep, required String noiDung});
}

/// Một lần "chia sẻ" mà [BoXuatVCardGia] đã ghi lại.
class TepDaXuat {
  const TepDaXuat(this.tenTep, this.noiDung);
  final String tenTep;
  final String noiDung;
}

/// Bản giả cho kiểm thử: không ghi tệp, chỉ ghi nhớ những gì được yêu cầu chia sẻ.
class BoXuatVCardGia implements BoXuatVCard {
  final List<TepDaXuat> daXuat = [];

  /// Đặt để giả lập lỗi ở lần chia sẻ kế tiếp (và các lần sau cho đến khi gỡ).
  LoiXuatVCard? loi;

  @override
  Future<void> chiaSe({required String tenTep, required String noiDung}) async {
    final l = loi;
    if (l != null) throw l;
    daXuat.add(TepDaXuat(tenTep, noiDung));
  }
}
