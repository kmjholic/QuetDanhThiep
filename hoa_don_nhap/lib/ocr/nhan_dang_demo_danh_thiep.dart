import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import 'bo_nhan_dang.dart';
import 'hoa_don_mau.dart' show KieuMau;
import 'mau_danh_thiep.dart';

/// Demo OCR cho danh thiếp (bản song song với [NhanDangDemo] của hóa đơn, tra bảng mẫu danh thiếp):
/// * Mẫu bình thường → văn bản của mẫu đó. * Mẫu "mờ" → rỗng. * Mẫu "hỏng" → ném lỗi.
/// * Ảnh người dùng tự chụp/chọn → văn bản của mẫu đầu tiên.
class NhanDangDemoDanhThiep implements BoNhanDang {
  final Duration treo;

  NhanDangDemoDanhThiep({this.treo = const Duration(milliseconds: 1200)});

  @override
  bool get laDemo => true;

  @override
  Future<KetQuaNhanDang> nhanDang(AnhHoaDon anh) async {
    await Future<void>.delayed(treo);
    final mau = anh.laAsset ? timDanhThiepMauTheoAsset(anh.duongDan) : null;
    switch (mau?.kieu) {
      case KieuMau.loi:
        throw const LoiNhanDang(
          LoaiLoiNhanDang.khongDocDuocAnh,
          'demo: tệp ảnh hỏng',
        );
      case KieuMau.khongCoChu:
        return KetQuaNhanDang(vanBan: '', soDong: 0, thoiGian: treo);
      case KieuMau.binhThuong:
      case null:
        final vanBan = chuanHoaVanBan((mau ?? dsDanhThiepMau.first).vanBan);
        return KetQuaNhanDang(
          vanBan: vanBan,
          soDong: demDong(vanBan),
          thoiGian: treo,
        );
    }
  }

  @override
  Future<void> dong() async {}
}
