import '../mo_hinh/hoa_don.dart';
import 'hoa_don_mau.dart' show KieuMau;
import 'mau_danh_thiep.dart';

enum LoaiLoiQuetMa {
  /// Tệp ảnh không mở được (hỏng, đã bị xoá, định dạng lạ).
  khongDocDuocAnh,

  /// Nền tảng không có bộ quét mã trên thiết bị (web, máy tính).
  khongHoTro,

  /// Lỗi khác trong lúc quét.
  thatBai,
}

class LoiQuetMa implements Exception {
  final LoaiLoiQuetMa loai;
  final String? chiTiet;

  const LoiQuetMa(this.loai, [this.chiTiet]);

  @override
  String toString() =>
      'LoiQuetMa(${loai.name}${chiTiet == null ? '' : ': $chiTiet'})';
}

/// Bộ quét mã QR / mã vạch trong ảnh. Có ba bản: ML Kit trên thiết bị (`nen_tang/`), demo và rỗng.
/// Màn hình và bộ điều khiển chỉ biết giao diện này.
abstract interface class BoQuetMa {
  /// true: nội dung mã là dữ liệu mẫu, không đọc từ ảnh thật.
  bool get laDemo;

  /// Trả về nội dung chuỗi của MỌI mã đọc được (theo thứ tự tìm thấy). Ảnh không có mã KHÔNG phải lỗi:
  /// trả danh sách rỗng. Ném [LoiQuetMa] khi thất bại.
  Future<List<String>> quet(AnhHoaDon anh);

  Future<void> dong();
}

/// Không quét gì, luôn trả danh sách rỗng. Dùng làm giá trị mặc định khi chưa cấu hình bộ quét mã.
class BoQuetMaRong implements BoQuetMa {
  const BoQuetMaRong();

  @override
  bool get laDemo => false;

  @override
  Future<List<String>> quet(AnhHoaDon anh) async => const [];

  @override
  Future<void> dong() async {}
}

/// Chế độ demo, không đọc ảnh:
/// * Danh thiếp mẫu bình thường → nội dung QR của mẫu đó (rỗng nếu mẫu không có QR).
/// * Danh thiếp mẫu "mờ" → rỗng.
/// * Danh thiếp mẫu "hỏng" → ném [LoiQuetMa].
/// * Ảnh người dùng tự chụp/chọn → rỗng (chỉ còn đường OCR).
class BoQuetMaDemo implements BoQuetMa {
  final Duration treo;

  BoQuetMaDemo({this.treo = const Duration(milliseconds: 400)});

  @override
  bool get laDemo => true;

  @override
  Future<List<String>> quet(AnhHoaDon anh) async {
    await Future<void>.delayed(treo);
    final mau = anh.laAsset ? timDanhThiepMauTheoAsset(anh.duongDan) : null;
    switch (mau?.kieu) {
      case KieuMau.loi:
        throw const LoiQuetMa(
          LoaiLoiQuetMa.khongDocDuocAnh,
          'demo: tệp ảnh hỏng',
        );
      case KieuMau.khongCoChu:
      case null:
        return const [];
      case KieuMau.binhThuong:
        return mau!.noiDungQr;
    }
  }

  @override
  Future<void> dong() async {}
}
