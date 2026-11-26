/// Danh thiếp mẫu đóng gói trong app (assets/danh_thiep/) — để thử luồng quét danh thiếp khi chưa có
/// danh thiếp thật, trên máy ảo không có camera, hoặc ở chế độ demo. Mọi tên, công ty, số điện thoại,
/// email đều là HƯ CẤU.
///
/// Văn bản [vanBan] và [noiDungQr] khớp với chữ / mã QR in trên ảnh trong assets/danh_thiep/
/// (mã QR trong ảnh 2 chỉ chứa N, FN, ORG, TITLE, TEL, EMAIL — website và địa chỉ phải lấy từ OCR).
///
/// Ở chế độ trên thiết bị, ảnh mẫu được ML Kit đọc THẬT (kết quả có thể khác chút ít so với [vanBan]).
/// Ở chế độ demo, app trả về đúng [vanBan] (OCR) và [noiDungQr] (quét mã) để trình diễn.
library;

import 'hoa_don_mau.dart' show KieuMau;

class DanhThiepMau {
  final String ma;
  final String asset;
  final String tenVi;
  final String tenEn;
  final KieuMau kieu;

  /// Văn bản OCR giả lập.
  final String vanBan;

  /// Nội dung các mã QR giả lập (vCard / MECARD). Rỗng nếu danh thiếp không có QR.
  final List<String> noiDungQr;

  const DanhThiepMau({
    required this.ma,
    required this.asset,
    required this.tenVi,
    required this.tenEn,
    required this.kieu,
    this.vanBan = '',
    this.noiDungQr = const [],
  });

  bool get coQr => noiDungQr.isNotEmpty;
}

const dsDanhThiepMau = <DanhThiepMau>[
  DanhThiepMau(
    ma: 'chuan',
    asset: 'assets/danh_thiep/danh_thiep_1.jpg',
    tenVi: 'Danh thiếp chuẩn',
    tenEn: 'Standard business card',
    kieu: KieuMau.binhThuong,
    vanBan: '''
CÔNG TY TNHH THƯƠNG MẠI AN PHÁT
NGUYỄN VĂN AN
Giám đốc kinh doanh
Mobile: 0912 345 678
Tel: 024 3333 4444
Email: an.nguyen@anphat.vn
Web: www.anphat.vn
25 Nguyễn Trãi, Thanh Xuân, Hà Nội''',
  ),
  DanhThiepMau(
    ma: 'co_qr',
    asset: 'assets/danh_thiep/danh_thiep_2_qr.jpg',
    tenVi: 'Danh thiếp có mã QR',
    tenEn: 'Card with QR code',
    kieu: KieuMau.binhThuong,
    vanBan: '''
CÔNG TY CỔ PHẦN GIẢI PHÁP SỐ VIỆT
TRẦN THỊ MINH ANH
Trưởng phòng Marketing
Mobile: 0987 654 321
Email: minhanh.tran@giaiphapso.vn
Web: www.giaiphapso.vn
88 Lê Lợi, Quận 1, TP. Hồ Chí Minh''',
    // Đúng nội dung mã QR in trên ảnh: KHÔNG có website / địa chỉ → phải lấy từ OCR.
    noiDungQr: [
      'BEGIN:VCARD\r\n'
          'VERSION:3.0\r\n'
          'N:Trần;Anh;Thị Minh;;\r\n'
          'FN:Trần Thị Minh Anh\r\n'
          'ORG:Công ty Cổ phần Giải pháp Số Việt\r\n'
          'TITLE:Trưởng phòng Marketing\r\n'
          'TEL:+84987654321\r\n'
          'EMAIL:minhanh.tran@giaiphapso.vn\r\n'
          'END:VCARD',
    ],
  ),
  DanhThiepMau(
    ma: 'anh_mo',
    asset: 'assets/danh_thiep/danh_thiep_mo.jpg',
    tenVi: 'Ảnh mờ (thử: không có chữ)',
    tenEn: 'Blurry photo (try: no text)',
    kieu: KieuMau.khongCoChu,
  ),
  DanhThiepMau(
    ma: 'anh_hong',
    asset: 'assets/danh_thiep/danh_thiep_hong.jpg',
    tenVi: 'Tệp ảnh hỏng (thử: lỗi)',
    tenEn: 'Corrupt image file (try: error)',
    kieu: KieuMau.loi,
  ),
];

DanhThiepMau? timDanhThiepMauTheoAsset(String asset) {
  for (final m in dsDanhThiepMau) {
    if (m.asset == asset) return m;
  }
  return null;
}
