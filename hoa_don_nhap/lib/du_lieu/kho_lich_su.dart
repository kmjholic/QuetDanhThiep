import 'dart:convert';

import '../mo_hinh/hoa_don.dart';
import 'kho_khoa_gia_tri.dart';

/// Lịch sử hóa đơn: một danh sách JSON trong [KhoKhoaGiaTri], mới nhất ở đầu.
///
/// Đủ cho vài nghìn hóa đơn văn bản của một cửa hàng nhỏ. Ảnh KHÔNG nằm ở đây mà là tệp riêng
/// (`LuuAnh`), lịch sử chỉ giữ đường dẫn.
class KhoLichSu {
  static const khoa = 'lich_su_hoa_don_v1';
  final KhoKhoaGiaTri _kho;

  KhoLichSu(this._kho);

  /// Bản ghi hỏng lẻ tẻ bị bỏ qua; nếu cả chuỗi JSON hỏng thì ném [FormatException].
  Future<List<HoaDon>> docTatCa() async {
    final raw = await _kho.doc(khoa);
    if (raw == null || raw.isEmpty) return [];
    final j = jsonDecode(raw);
    if (j is! List) throw const FormatException('Lịch sử không phải danh sách');
    final ds = <HoaDon>[];
    for (final x in j) {
      if (x is! Map) continue;
      try {
        ds.add(HoaDon.tuJson(x.cast<String, Object?>()));
      } on FormatException {
        // bỏ qua bản ghi hỏng
      }
    }
    ds.sort((a, b) => b.taoLuc.compareTo(a.taoLuc));
    return ds;
  }

  Future<void> _ghi(List<HoaDon> ds) => _kho.ghi(khoa, jsonEncode([for (final h in ds) h.toJson()]));

  /// Thêm mới hoặc cập nhật (theo [HoaDon.ma]). Trả về danh sách sau khi lưu.
  Future<List<HoaDon>> luu(HoaDon h) async {
    final ds = await docTatCa();
    final i = ds.indexWhere((x) => x.ma == h.ma);
    if (i >= 0) {
      ds[i] = h;
    } else {
      ds.insert(0, h);
    }
    ds.sort((a, b) => b.taoLuc.compareTo(a.taoLuc));
    await _ghi(ds);
    return ds;
  }

  Future<List<HoaDon>> xoa(String ma) async {
    final ds = (await docTatCa())..removeWhere((h) => h.ma == ma);
    await _ghi(ds);
    return ds;
  }

  Future<void> xoaHet() => _kho.xoa(khoa);
}
