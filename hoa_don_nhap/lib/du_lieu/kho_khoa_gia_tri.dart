/// Nơi lưu chuỗi theo khoá. Bản thật dùng shared_preferences (`nen_tang/kho_prefs.dart`);
/// bản trong bộ nhớ dưới đây dùng cho kiểm thử.
abstract interface class KhoKhoaGiaTri {
  Future<String?> doc(String khoa);
  Future<void> ghi(String khoa, String giaTri);
  Future<void> xoa(String khoa);
}

class KhoBoNho implements KhoKhoaGiaTri {
  final Map<String, String> duLieu;

  /// Bật để giả lập bộ nhớ máy lỗi (kiểm thử trạng thái lỗi).
  bool hong = false;

  KhoBoNho([Map<String, String>? duLieu]) : duLieu = duLieu ?? {};

  void _kiemTra() {
    if (hong) throw StateError('Bộ nhớ giả lập đang lỗi');
  }

  @override
  Future<String?> doc(String khoa) async {
    _kiemTra();
    return duLieu[khoa];
  }

  @override
  Future<void> ghi(String khoa, String giaTri) async {
    _kiemTra();
    duLieu[khoa] = giaTri;
  }

  @override
  Future<void> xoa(String khoa) async {
    _kiemTra();
    duLieu.remove(khoa);
  }
}
