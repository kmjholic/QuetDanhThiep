/// Hóa đơn mẫu đóng gói trong app (assets/mau/) — để thử luồng ứng dụng khi chưa có hóa đơn thật,
/// trên máy ảo không có camera, hoặc ở chế độ demo. Tên cửa hàng, công ty, số điện thoại đều là HƯ CẤU.
///
/// Ở chế độ trên thiết bị, ảnh mẫu được ML Kit đọc THẬT (kết quả có thể khác chút ít so với [vanBan]).
/// Ở chế độ demo, app trả về đúng [vanBan] để trình diễn.
library;

enum KieuMau {
  /// Ảnh rõ, có chữ.
  binhThuong,

  /// Ảnh mờ / ngược sáng — thử trạng thái "không tìm thấy chữ".
  khongCoChu,

  /// Tệp ảnh hỏng — thử trạng thái lỗi.
  loi,
}

class HoaDonMau {
  final String ma;
  final String asset;
  final String tenVi;
  final String tenEn;
  final KieuMau kieu;
  final String vanBan;

  const HoaDonMau({
    required this.ma,
    required this.asset,
    required this.tenVi,
    required this.tenEn,
    required this.kieu,
    this.vanBan = '',
  });
}

const dsHoaDonMau = <HoaDonMau>[
  HoaDonMau(
    ma: 'nuoc_giai_khat',
    asset: 'assets/mau/hoa_don_1.jpg',
    tenVi: 'Đại lý nước giải khát',
    tenEn: 'Beverage wholesaler',
    kieu: KieuMau.binhThuong,
    vanBan: r'''
ĐẠI LÝ NƯỚC GIẢI KHÁT MINH TÂM
12 Ngõ 34 Đường Mẫu, Hà Nội · ĐT 0123 456 789
HÓA ĐƠN BÁN LẺ (MẪU)
Số: 000127   Ngày: 03/11/2026
Khách hàng: Tạp hóa Cô Lan
Tên hàng   SL   Đơn giá   Thành tiền
Nước suối 500ml (thùng 24)   5   96.000   480.000
Trà xanh 455ml (thùng 24)   3   180.000   540.000
Nước ngọt lon 330ml (thùng)   4   205.000   820.000
Sữa đậu nành 200ml (lốc 6)   6   27.000   162.000
Cộng tiền hàng:   2.002.000
Chiết khấu:   -20.000
Tổng thanh toán:   1.982.000
Người giao hàng   Người nhận hàng''',
  ),
  HoaDonMau(
    ma: 'mi_gia_vi',
    asset: 'assets/mau/hoa_don_2.jpg',
    tenVi: 'Nhà phân phối mì và gia vị',
    tenEn: 'Noodle & spice distributor',
    kieu: KieuMau.binhThuong,
    vanBan: r'''
CÔNG TY TNHH PHÂN PHỐI AN PHÁT (MẪU)
Kho: 88 Đường Thử Nghiệm, Q. Mẫu, TP.HCM
PHIẾU XUẤT KHO KIÊM HÓA ĐƠN
Ngày 01/11/2026   Số phiếu: XK-2611-045
Người mua: Cửa hàng tạp hóa Bình An
Mã   Tên hàng   ĐVT   SL   Thành tiền
MI01   Mì gói tôm chua cay   Thùng   10   1.150.000
NM02   Nước mắm 500ml   Chai   24   696.000
DA03   Dầu ăn 1 lít   Chai   12   540.000
DU04   Đường trắng 1kg   Gói   20   460.000
BN05   Bột ngọt 454g   Gói   15   570.000
Tổng cộng:   3.416.000
Đã thanh toán:   2.000.000
Còn nợ:   1.416.000''',
  ),
  HoaDonMau(
    ma: 'anh_mo',
    asset: 'assets/mau/hoa_don_mo.jpg',
    tenVi: 'Ảnh mờ (thử: không có chữ)',
    tenEn: 'Blurry photo (try: no text)',
    kieu: KieuMau.khongCoChu,
  ),
  HoaDonMau(
    ma: 'anh_hong',
    asset: 'assets/mau/hoa_don_hong.jpg',
    tenVi: 'Tệp ảnh hỏng (thử: lỗi)',
    tenEn: 'Corrupt image file (try: error)',
    kieu: KieuMau.loi,
  ),
];

HoaDonMau? timMauTheoAsset(String asset) {
  for (final m in dsHoaDonMau) {
    if (m.asset == asset) return m;
  }
  return null;
}
