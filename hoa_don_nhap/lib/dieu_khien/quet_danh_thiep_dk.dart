import 'dart:math';

import '../mo_hinh/chuan_hoa_nfc.dart';
import '../mo_hinh/danh_thiep.dart';
import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/phan_tich_danh_thiep.dart';
import '../mo_hinh/vcard.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import '../ocr/bo_nhan_dang.dart';
import '../ocr/bo_quet_ma.dart';
import 'quet_dk.dart' show TrangThaiQuet;
import 'thong_bao.dart';

/// Một lần quét danh thiếp: chạy OCR và quét mã QR SONG SONG cho một ảnh, gộp kết quả
/// (QR ưu tiên, OCR điền chỗ trống) để người dùng sửa rồi tạo [DanhThiep].
class DieuKhienQuetDanhThiep with CoThongBao {
  final BoNhanDang boNhanDang;
  final BoQuetMa boQuetMa;
  final AnhHoaDon anh;
  final DateTime Function() _bayGio;
  final int Function() _ngauNhien;

  TrangThaiQuet trangThai = TrangThaiQuet.dangNhanDang;

  /// Các trường đã tách (null khi chưa có kết quả hoặc đang nhập tay).
  KetQuaPhanTich? ketQua;

  /// Văn bản OCR (đã chuẩn hoá) — để màn hình cho xem "văn bản gốc" và người dùng tự chép thêm vào ghi chú.
  String vanBanOcr = '';

  /// true: có ít nhất một mã QR là vCard/MECARD đọc được và đã dùng để điền thông tin.
  bool daDungQr = false;

  Duration? thoiGian;
  LoiNhanDang? loi;

  /// Lỗi quét QR (nếu có). KHÔNG làm hỏng cả lượt quét: OCR vẫn chạy bình thường.
  LoiQuetMa? loiQuetMa;

  /// Người dùng chọn "Nhập tay" khi máy không đọc được gì.
  bool nhapTay = false;

  DieuKhienQuetDanhThiep({
    required this.boNhanDang,
    required this.anh,
    BoQuetMa? boQuetMa,
    DateTime Function()? bayGio,
    int Function()? ngauNhien,
  }) : boQuetMa = boQuetMa ?? const BoQuetMaRong(),
       _bayGio = bayGio ?? DateTime.now,
       _ngauNhien = ngauNhien ?? (() => Random().nextInt(1 << 16));

  bool get laDemo => boNhanDang.laDemo;

  /// Nguồn sẽ ghi vào danh thiếp: nhập tay → thucong; có dùng QR → qr; còn lại → ocr.
  NguonDanhThiep get nguon => nhapTay
      ? NguonDanhThiep.thucong
      : daDungQr
      ? NguonDanhThiep.qr
      : NguonDanhThiep.ocr;

  Future<void> batDau() async {
    trangThai = TrangThaiQuet.dangNhanDang;
    loi = null;
    loiQuetMa = null;
    nhapTay = false;
    daDungQr = false;
    ketQua = null;
    vanBanOcr = '';
    baoThayDoi();

    final ket = await Future.wait([_chayOcr(), _chayQr()]);
    if (daHuy) return;
    final ocr = ket[0] as ({KetQuaNhanDang? kq, LoiNhanDang? loi});
    final qr = ket[1] as ({List<String> noiDung, LoiQuetMa? loi});
    loiQuetMa = qr.loi;

    final tuQr = _chonKetQuaQr(qr.noiDung);
    daDungQr = tuQr != null;

    if (ocr.kq != null) {
      thoiGian = ocr.kq!.thoiGian;
      vanBanOcr = chuanHoaVanBan(chuanHoaNfcViet(ocr.kq!.vanBan));
    }

    if (ocr.kq == null && tuQr == null) {
      // OCR hỏng và QR cũng không cứu được → lỗi (ưu tiên lỗi của OCR).
      loi = ocr.loi;
      trangThai = TrangThaiQuet.loi;
    } else if (vanBanOcr.isEmpty && tuQr == null) {
      trangThai = TrangThaiQuet.khongCoChu;
    } else {
      final tuOcr = vanBanOcr.isEmpty
          ? null
          : BoPhanTichDanhThiep.phanTich(vanBanOcr);
      ketQua = tuQr != null
          ? (tuOcr == null ? tuQr : tuQr.boSung(tuOcr))
          : tuOcr;
      trangThai = TrangThaiQuet.coChu;
    }
    baoThayDoi();
  }

  void chuyenSangNhapTay() {
    nhapTay = true;
    daDungQr = false;
    ketQua = null;
    vanBanOcr = '';
    trangThai = TrangThaiQuet.coChu;
    baoThayDoi();
  }

  /// Tạo danh thiếp từ nội dung người dùng đã sửa. Mặc định giữ ảnh gốc ([anh]); màn hình có thể truyền
  /// đường dẫn ảnh đã chép vào thư mục của app ([duongDanAnh]), hoặc `''` để lưu không kèm ảnh.
  DanhThiep taoDanhThiep({
    required String hoTen,
    String chucVu = '',
    String congTy = '',
    String dienThoai = '',
    String dienThoaiKhac = '',
    String email = '',
    String website = '',
    String diaChi = '',
    String ghiChu = '',
    String? duongDanAnh,
  }) {
    final t = _bayGio();
    final anhLuu = duongDanAnh ?? anh.maHoa();
    return DanhThiep(
      id: taoMa(t, _ngauNhien()),
      thoiGian: t,
      hoTen: hoTen.trim(),
      chucVu: chucVu.trim(),
      congTy: congTy.trim(),
      dienThoai: dienThoai.trim(),
      dienThoaiKhac: dienThoaiKhac.trim(),
      email: email.trim().toLowerCase(),
      website: website.trim(),
      diaChi: diaChi.trim(),
      ghiChu: ghiChu.trim(),
      duongDanAnh: anhLuu.isEmpty ? null : anhLuu,
      nguon: nguon,
    );
  }

  Future<({KetQuaNhanDang? kq, LoiNhanDang? loi})> _chayOcr() async {
    try {
      return (kq: await boNhanDang.nhanDang(anh), loi: null);
    } on LoiNhanDang catch (e) {
      return (kq: null, loi: e);
    } catch (e) {
      return (kq: null, loi: LoiNhanDang(LoaiLoiNhanDang.thatBai, '$e'));
    }
  }

  Future<({List<String> noiDung, LoiQuetMa? loi})> _chayQr() async {
    try {
      return (noiDung: await boQuetMa.quet(anh), loi: null);
    } on LoiQuetMa catch (e) {
      return (noiDung: const <String>[], loi: e);
    } catch (e) {
      return (
        noiDung: const <String>[],
        loi: LoiQuetMa(LoaiLoiQuetMa.thatBai, '$e'),
      );
    }
  }

  /// Mã đầu tiên là vCard/MECARD đọc ra được thông tin; không có → null.
  KetQuaPhanTich? _chonKetQuaQr(List<String> noiDung) {
    for (final m in noiDung) {
      final c = chuanHoaNfcViet(m);
      if (!DocVCard.nhanDang(c)) continue;
      final kq = DocVCard.doc(c);
      if (!kq.rong) return kq;
    }
    return null;
  }
}
