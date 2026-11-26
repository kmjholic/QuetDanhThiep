import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import 'bo_nhan_dang.dart';
import 'hoa_don_mau.dart';

/// Chế độ demo: KHÔNG đọc ảnh, trả về văn bản mẫu sau một khoảng chờ giả lập — đủ để trải nghiệm trọn
/// luồng chụp → chờ → sửa → sao chép → lưu khi chưa có bộ nhận dạng (web, máy tính, máy ảo thiếu dịch vụ).
///
/// * Ảnh mẫu bình thường → đúng văn bản của mẫu đó.
/// * Ảnh mẫu "mờ" → kết quả rỗng (trạng thái "không tìm thấy chữ").
/// * Ảnh mẫu "hỏng" → ném lỗi (trạng thái lỗi).
/// * Ảnh người dùng tự chụp/chọn → văn bản của mẫu đầu tiên (màn hình ghi rõ đây là dữ liệu mẫu).
class NhanDangDemo implements BoNhanDang {
  final Duration treo;

  NhanDangDemo({this.treo = const Duration(milliseconds: 1200)});

  @override
  bool get laDemo => true;

  @override
  Future<KetQuaNhanDang> nhanDang(AnhHoaDon anh) async {
    await Future<void>.delayed(treo);
    final mau = anh.laAsset ? timMauTheoAsset(anh.duongDan) : null;
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
        final vanBan = chuanHoaVanBan((mau ?? dsHoaDonMau.first).vanBan);
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
