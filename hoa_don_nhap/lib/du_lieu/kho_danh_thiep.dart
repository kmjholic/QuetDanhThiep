import 'dart:convert';

import '../mo_hinh/danh_thiep.dart';
import 'kho_khoa_gia_tri.dart';

/// Lịch sử danh thiếp: một danh sách JSON trong [KhoKhoaGiaTri], mới nhất ở đầu.
///
/// Tách biệt với lịch sử hóa đơn (khoá riêng [khoa]). Ảnh KHÔNG nằm ở đây mà là tệp riêng
/// (`LuuAnh`); danh sách chỉ giữ đường dẫn.
class KhoDanhThiep {
  static const khoa = 'danh_thiep_v1';
  final KhoKhoaGiaTri _kho;

  KhoDanhThiep(this._kho);

  /// Bản ghi hỏng lẻ tẻ (không phải object, thiếu mã) bị bỏ qua;
  /// nếu cả chuỗi JSON hỏng thì ném [FormatException].
  Future<List<DanhThiep>> docTatCa() async {
    final raw = await _kho.doc(khoa);
    if (raw == null || raw.isEmpty) return [];
    final j = jsonDecode(raw);
    if (j is! List) {
      throw const FormatException('Danh sách danh thiếp không phải mảng JSON');
    }
    final ds = <DanhThiep>[];
    for (final x in j) {
      if (x is! Map) continue;
      try {
        final d = DanhThiep.fromJson(x.cast<String, dynamic>());
        if (d.id.isNotEmpty) ds.add(d); // thiếu mã thì không sửa/xoá được: bỏ
      } catch (_) {
        // bỏ qua bản ghi hỏng (ví dụ khoá không phải chuỗi)
      }
    }
    _sapXep(ds);
    return ds;
  }

  /// Mới nhất trước; cùng thời điểm thì theo mã để thứ tự ổn định.
  static void _sapXep(List<DanhThiep> ds) {
    ds.sort((a, b) {
      final c = b.thoiGian.compareTo(a.thoiGian);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  }

  Future<void> _ghi(List<DanhThiep> ds) =>
      _kho.ghi(khoa, jsonEncode([for (final d in ds) d.toJson()]));

  /// Thêm mới hoặc cập nhật (theo [DanhThiep.id]). Trả về danh sách sau khi lưu.
  /// Mã rỗng bị từ chối vì bản ghi thiếu mã sẽ bị bỏ khi đọc lại.
  Future<List<DanhThiep>> luu(DanhThiep d) async {
    if (d.id.isEmpty) {
      throw ArgumentError.value(d.id, 'id', 'Mã danh thiếp không được rỗng');
    }
    final ds = await docTatCa();
    final i = ds.indexWhere((x) => x.id == d.id);
    if (i >= 0) {
      ds[i] = d;
    } else {
      ds.add(d);
    }
    _sapXep(ds);
    await _ghi(ds);
    return ds;
  }

  Future<List<DanhThiep>> xoa(String id) async {
    final ds = (await docTatCa())..removeWhere((d) => d.id == id);
    await _ghi(ds);
    return ds;
  }

  Future<void> xoaHet() => _kho.xoa(khoa);
}
