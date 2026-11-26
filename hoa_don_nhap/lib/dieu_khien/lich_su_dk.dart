import '../du_lieu/kho_lich_su.dart';
import '../du_lieu/luu_anh.dart';
import '../mo_hinh/hoa_don.dart';
import 'thong_bao.dart';

enum TrangThaiLichSu { dangTai, sanSang, loi }

/// Danh sách hóa đơn đã lưu trên máy.
class DieuKhienLichSu with CoThongBao {
  final KhoLichSu _kho;
  final LuuAnh _luuAnh;

  TrangThaiLichSu trangThai = TrangThaiLichSu.dangTai;
  List<HoaDon> ds = const [];
  Object? loi;

  DieuKhienLichSu(this._kho, this._luuAnh);

  bool get trong => trangThai == TrangThaiLichSu.sanSang && ds.isEmpty;

  Future<void> tai() async {
    trangThai = TrangThaiLichSu.dangTai;
    loi = null;
    baoThayDoi();
    try {
      ds = await _kho.docTatCa();
      trangThai = TrangThaiLichSu.sanSang;
    } catch (e) {
      loi = e;
      trangThai = TrangThaiLichSu.loi;
    }
    baoThayDoi();
  }

  HoaDon? tim(String ma) {
    for (final h in ds) {
      if (h.ma == ma) return h;
    }
    return null;
  }

  /// Lưu mới hoặc cập nhật. Ảnh được chép vào thư mục của app trước. Lỗi được ném ra cho màn hình báo.
  Future<HoaDon> luu(HoaDon h) async {
    final anh = h.anh == null ? null : await _luuAnh.giuLai(h.anh!, h.ma);
    final moi = anh == null ? h : h.copyWith(anh: anh);
    ds = await _kho.luu(moi);
    trangThai = TrangThaiLichSu.sanSang;
    baoThayDoi();
    return moi;
  }

  Future<void> xoa(String ma) async {
    final h = tim(ma);
    ds = await _kho.xoa(ma);
    await _luuAnh.xoa(h?.anh);
    baoThayDoi();
  }

  Future<void> xoaHet() async {
    final cu = ds;
    await _kho.xoaHet();
    for (final h in cu) {
      await _luuAnh.xoa(h.anh);
    }
    ds = const [];
    trangThai = TrangThaiLichSu.sanSang;
    baoThayDoi();
  }
}
