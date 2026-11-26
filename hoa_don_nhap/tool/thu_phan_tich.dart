import 'package:hoa_don_nhap/mo_hinh/phan_tich_danh_thiep.dart';

void main() {
  const mau = '''
CÔNG TY TNHH GIẢI PHÁP ABC
NGUYỄN VĂN AN
Giám đốc kinh doanh
Mobile: 0912 345 678
Tel: 024 3333 4444 | Fax: 024 3333 4445
Email: an.nguyen@abc.com.vn
Website: www.abc.com.vn
Địa chỉ: Số 12 Láng Hạ, Đống Đa, Hà Nội
''';
  final kq = BoPhanTichDanhThiep.phanTich(mau);
  print('${kq.hoTen} | ${kq.chucVu} | ${kq.congTy}');
  print('${kq.dienThoai} | ${kq.dienThoaiKhac} | ${kq.email} | ${kq.website}');
  print(kq.diaChi);
}
