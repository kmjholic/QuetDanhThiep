import 'dart:math';

import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import '../ocr/bo_nhan_dang.dart';
import 'thong_bao.dart';

enum TrangThaiQuet { dangNhanDang, coChu, khongCoChu, loi }

/// Một lần quét: chạy nhận dạng cho một ảnh, giữ kết quả để người dùng sửa rồi tạo [HoaDon].
class DieuKhienQuet with CoThongBao {
  final BoNhanDang boNhanDang;
  final AnhHoaDon anh;
  final NguonAnh nguon;
  final DateTime Function() _bayGio;
  final int Function() _ngauNhien;

  TrangThaiQuet trangThai = TrangThaiQuet.dangNhanDang;
  String vanBan = '';
  String tieuDeGoiY = '';
  int soDong = 0;
  Duration? thoiGian;
  LoiNhanDang? loi;

  /// Người dùng chọn "Nhập tay" khi máy không đọc được chữ.
  bool nhapTay = false;

  DieuKhienQuet({
    required this.boNhanDang,
    required this.anh,
    required this.nguon,
    DateTime Function()? bayGio,
    int Function()? ngauNhien,
  })  : _bayGio = bayGio ?? DateTime.now,
        _ngauNhien = ngauNhien ?? (() => Random().nextInt(1 << 16));

  bool get laDemo => boNhanDang.laDemo;

  Future<void> batDau() async {
    trangThai = TrangThaiQuet.dangNhanDang;
    loi = null;
    nhapTay = false;
    baoThayDoi();
    try {
      final kq = await boNhanDang.nhanDang(anh);
      if (daHuy) return;
      vanBan = chuanHoaVanBan(kq.vanBan);
      soDong = demDong(vanBan);
      thoiGian = kq.thoiGian;
      tieuDeGoiY = doanTieuDe(vanBan);
      trangThai = vanBan.isEmpty ? TrangThaiQuet.khongCoChu : TrangThaiQuet.coChu;
    } on LoiNhanDang catch (e) {
      if (daHuy) return;
      loi = e;
      trangThai = TrangThaiQuet.loi;
    } catch (e) {
      if (daHuy) return;
      loi = LoiNhanDang(LoaiLoiNhanDang.thatBai, '$e');
      trangThai = TrangThaiQuet.loi;
    }
    baoThayDoi();
  }

  void chuyenSangNhapTay() {
    nhapTay = true;
    vanBan = '';
    tieuDeGoiY = '';
    soDong = 0;
    trangThai = TrangThaiQuet.coChu;
    baoThayDoi();
  }

  /// Tạo hóa đơn từ nội dung người dùng đã sửa. Tiêu đề trống → đoán từ dòng đầu → [tieuDeMacDinh].
  HoaDon taoHoaDon({required String tieuDe, required String noiDung, required String tieuDeMacDinh}) {
    final t = _bayGio();
    final nd = chuanHoaVanBan(noiDung);
    var td = tieuDe.trim();
    if (td.isEmpty) td = doanTieuDe(nd);
    if (td.isEmpty) td = tieuDeMacDinh;
    return HoaDon(ma: taoMa(t, _ngauNhien()), tieuDe: td, noiDung: nd, taoLuc: t, suaLuc: t, anh: anh, nguon: nguon);
  }
}
