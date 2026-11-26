import 'package:hoa_don_nhap/dieu_khien/lich_su_danh_thiep_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_dk.dart' show TrangThaiLichSu;
import 'package:hoa_don_nhap/du_lieu/kho_danh_thiep.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/luu_anh.dart';
import 'package:hoa_don_nhap/du_lieu/xuat_vcard.dart';
import 'package:hoa_don_nhap/mo_hinh/danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';

var _loi = 0;
void kiem(String ten, bool dung) {
  if (!dung) _loi++;
  print('${dung ? 'OK  ' : 'LỖI'} $ten');
}

/// ĐỐI CHIẾU: chữ ký phải khớp interface LuuAnh thật.
class LuuAnhGia implements LuuAnh {
  final daXoa = <AnhHoaDon>[];

  @override
  Future<AnhHoaDon> giuLai(AnhHoaDon anh, String ma) async =>
      AnhHoaDon.tep('/luu/$ma.jpg');

  @override
  Future<void> xoa(AnhHoaDon? anh) async {
    if (anh != null) daXoa.add(anh);
  }
}

DanhThiep mau(String id, String ten, {String? anh}) => DanhThiep(
  id: id,
  thoiGian: DateTime(2026, 11, 25),
  hoTen: ten,
  chucVu: '',
  congTy: '',
  dienThoai: '0912 345 678',
  dienThoaiKhac: '',
  email: '',
  website: '',
  diaChi: '',
  ghiChu: '',
  duongDanAnh: anh,
  nguon: NguonDanhThiep.thucong,
);

Future<void> main() async {
  final kho = KhoDanhThiep(KhoBoNho()); // ĐỐI CHIẾU: constructor KhoBoNho
  final anh = LuuAnhGia();
  final xuat = BoXuatVCardGia();
  final dk = DieuKhienLichSuDanhThiep(kho, anh, xuat);

  kiem('ban đầu đang tải', dk.trangThai == TrangThaiLichSu.dangTai);
  await dk.tai();
  kiem('tải xong → trống', dk.trong);
  kiem(
    'xuatTatCa khi trống → false',
    await dk.xuatTatCa() == false && xuat.daXuat.isEmpty,
  );

  final a = await dk.luu(
    mau('a', 'An', anh: 'asset:assets/danh_thiep/danh_thiep_1.jpg'),
  );
  await dk.luu(mau('b', 'Bình'));
  kiem('có 2 danh thiếp', dk.ds.length == 2);
  kiem('ảnh được chép vào thư mục app', a.duongDanAnh == '/luu/a.jpg');
  kiem('không ảnh thì giữ null', dk.tim('b')!.duongDanAnh == null);

  await dk.luu(dk.tim('b')!.copyWith(hoTen: 'Bình Sửa'));
  kiem(
    'cập nhật không nhân đôi',
    dk.ds.length == 2 && dk.tim('b')!.hoTen == 'Bình Sửa',
  );

  await dk.xuatMot(dk.tim('a')!);
  kiem(
    'xuất 1 → 1 tệp .vcf',
    xuat.daXuat.length == 1 &&
        xuat.daXuat.first.noiDung.contains('BEGIN:VCARD'),
  );
  await dk.xuatTatCa();
  kiem(
    'xuất tất cả → 2 thẻ trong 1 tệp',
    'BEGIN:VCARD'.allMatches(xuat.daXuat.last.noiDung).length == 2,
  );

  await dk.xoa('a');
  kiem('xoá 1 → còn 1, xoá ảnh', dk.ds.length == 1 && anh.daXoa.length == 1);
  await dk.xoaHet();
  kiem('xoá hết → trống', dk.trong);

  // Lỗi đọc kho → trạng thái loi → tải lại
  final kho2 = KhoBoNho(); // ĐỐI CHIẾU
  await kho2.ghi(
    KhoDanhThiep.khoa,
    '{không phải json',
  ); // ĐỐI CHIẾU: tên hàm ghi của KhoKhoaGiaTri
  final dk2 = DieuKhienLichSuDanhThiep(KhoDanhThiep(kho2), anh, xuat);
  await dk2.tai();
  kiem(
    'JSON hỏng → loi',
    dk2.trangThai == TrangThaiLichSu.loi && dk2.loi != null,
  );

  print(_loi == 0 ? '\nTẤT CẢ OK' : '\n$_loi mục LỖI');
}
