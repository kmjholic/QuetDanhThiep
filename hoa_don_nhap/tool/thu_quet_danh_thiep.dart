import 'package:hoa_don_nhap/dieu_khien/quet_danh_thiep_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/quet_dk.dart' show TrangThaiQuet;
import 'package:hoa_don_nhap/mo_hinh/chuan_hoa_nfc.dart';
import 'package:hoa_don_nhap/mo_hinh/danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/ocr/bo_quet_ma.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo.dart';

var _loi = 0;
void kiem(String ten, bool dung) {
  if (!dung) _loi++;
  print('${dung ? 'OK  ' : 'LỖI'} $ten');
}

DieuKhienQuetDanhThiep dk(String asset) => DieuKhienQuetDanhThiep(
  boNhanDang: NhanDangDemo(treo: Duration.zero),
  boQuetMa: BoQuetMaDemo(treo: Duration.zero),
  anh: AnhHoaDon.asset(asset),
  bayGio: () => DateTime(2026, 11, 25, 9),
  ngauNhien: () => 7,
);

Future<void> main() async {
  // NFC
  kiem(
    'NFD → NFC: a+nặng+mũ = ậ',
    chuanHoaNfcViet('a\u0323\u0302') == '\u1EAD',
  );
  kiem(
    'NFD → NFC: a+mũ+nặng = ậ',
    chuanHoaNfcViet('a\u0302\u0323') == '\u1EAD',
  );
  kiem('hoa/thường', chuanHoaNfcViet('NGUYE\u0302\u0303N') == 'NGUY\u1EC4N');
  kiem('chữ không dấu giữ nguyên', chuanHoaNfcViet('Hanoi 123') == 'Hanoi 123');

  // Mẫu chuẩn: chỉ OCR
  var d = dk('assets/danh_thiep/danh_thiep_1.jpg');
  await d.batDau();
  kiem('chuẩn → coChu', d.trangThai == TrangThaiQuet.coChu);
  kiem(
    'chuẩn → nguồn ocr, không dùng QR',
    d.nguon == NguonDanhThiep.ocr && !d.daDungQr,
  );
  final k = d.ketQua!;
  print(
    '     OCR: ${k.hoTen} | ${k.chucVu} | ${k.congTy} | ${k.dienThoai} | ${k.dienThoaiKhac} | ${k.email} | ${k.website} | ${k.diaChi}',
  );
  kiem('email', k.email == 'an.nguyen@minhphat.example');
  kiem('SĐT di động', k.dienThoai == '0912 345 678');

  // Mẫu có QR: QR ưu tiên + OCR điền chỗ trống
  d = dk('assets/danh_thiep/danh_thiep_2_qr.jpg');
  await d.batDau();
  kiem(
    'có QR → coChu, daDungQr',
    d.trangThai == TrangThaiQuet.coChu && d.daDungQr,
  );
  kiem('có QR → nguồn qr', d.nguon == NguonDanhThiep.qr);
  print(
    '     gộp: ${d.ketQua!.hoTen} | ${d.ketQua!.email} | ${d.ketQua!.website} | ${d.ketQua!.diaChi}',
  );
  kiem('email lấy từ QR', d.ketQua!.email == 'ngoc.tran@hoasen.example');

  // Mờ / hỏng
  d = dk('assets/danh_thiep/danh_thiep_mo.jpg');
  await d.batDau();
  kiem('mờ → khongCoChu', d.trangThai == TrangThaiQuet.khongCoChu);
  d.chuyenSangNhapTay();
  kiem(
    'nhập tay → coChu + nguồn thucong',
    d.trangThai == TrangThaiQuet.coChu && d.nguon == NguonDanhThiep.thucong,
  );

  d = dk('assets/danh_thiep/danh_thiep_hong.jpg');
  await d.batDau();
  kiem('hỏng → loi', d.trangThai == TrangThaiQuet.loi && d.loi != null);

  // Tạo danh thiếp
  d = dk('assets/danh_thiep/danh_thiep_1.jpg');
  await d.batDau();
  final dt = d.taoDanhThiep(hoTen: '  An  ', email: ' AN@X.EXAMPLE ');
  kiem('trim + email thường', dt.hoTen == 'An' && dt.email == 'an@x.example');
  kiem(
    'giữ ảnh mẫu',
    dt.duongDanAnh == 'asset:assets/danh_thiep/danh_thiep_1.jpg',
  );
  kiem(
    'duongDanAnh rỗng → null',
    d.taoDanhThiep(hoTen: 'A', duongDanAnh: '').duongDanAnh == null,
  );

  // Huỷ giữa chừng không ném lỗi
  d = dk('assets/danh_thiep/danh_thiep_1.jpg');
  final f = d.batDau();
  d.huy();
  await f;
  kiem('huỷ giữa chừng an toàn', true);

  print(_loi == 0 ? '\nTẤT CẢ OK' : '\n$_loi mục LỖI');
}
