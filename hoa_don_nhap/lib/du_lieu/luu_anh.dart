import '../mo_hinh/hoa_don.dart';

/// Giữ ảnh hóa đơn lâu dài. Ảnh chụp bằng camera nằm trong thư mục tạm (cache) và có thể bị hệ điều hành
/// xoá, nên khi lưu hóa đơn phải chép sang thư mục riêng của app. Bản thật: `nen_tang/luu_anh_tep.dart`.
abstract interface class LuuAnh {
  /// Trả về ảnh đã được giữ lại (ảnh mẫu dạng asset giữ nguyên).
  Future<AnhHoaDon> giuLai(AnhHoaDon anh, String maHoaDon);

  /// Xoá ảnh đã giữ (không làm gì với asset hoặc ảnh không thuộc thư mục của app).
  Future<void> xoa(AnhHoaDon? anh);
}

/// Không chép gì — dùng cho kiểm thử và nền tảng không có hệ thống tệp (web).
class LuuAnhGiuNguyen implements LuuAnh {
  final daXoa = <AnhHoaDon>[];

  @override
  Future<AnhHoaDon> giuLai(AnhHoaDon anh, String maHoaDon) async => anh;

  @override
  Future<void> xoa(AnhHoaDon? anh) async {
    if (anh != null) daXoa.add(anh);
  }
}
