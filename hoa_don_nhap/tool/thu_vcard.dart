import 'package:hoa_don_nhap/mo_hinh/danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/vcard.dart';

void main() {
  final d = DanhThiep(
    id: '1',
    thoiGian: DateTime.utc(2026, 11, 25, 8, 30),
    hoTen: 'Nguyễn Văn An',
    chucVu: 'Giám đốc kinh doanh',
    congTy: 'CÔNG TY TNHH GIẢI PHÁP ABC',
    dienThoai: '0912 345 678',
    dienThoaiKhac: '024 3333 4444',
    email: 'an.nguyen@abc.com.vn',
    website: 'www.abc.com.vn',
    diaChi: 'Số 12 Láng Hạ, Đống Đa, Hà Nội',
  );
  final vcf = TaoVCard.tao(d);
  print(vcf);
  final lai = DocVCard.doc(vcf);
  print(
    '${lai.hoTen} | ${lai.dienThoai} | ${lai.dienThoaiKhac} | ${lai.diaChi}',
  );
  print(
    DocVCard.doc(
      'MECARD:N:Trần,Thị Bình;TEL:0987654321;EMAIL:binh@x.vn;;',
    ).hoTen,
  );
}
