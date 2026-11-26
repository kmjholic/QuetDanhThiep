// Test bộ phân tích danh thiếp (Regex + heuristic) — Dart thuần, không cần thiết bị.
//
// Ghi chú: các so sánh họ tên / chức vụ / công ty dùng chữ thường để không phụ thuộc việc bộ phân tích
// có đổi "NGUYỄN VĂN AN" thành "Nguyễn Văn An" hay không.
import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/mo_hinh/phan_tich_danh_thiep.dart';
import 'package:hoa_don_nhap/ocr/mau_danh_thiep.dart';

/// Trường có thể là String hoặc String? tuỳ cách khai báo: quy về String.
String _s(Object? v) => v?.toString() ?? '';

String _thuong(Object? v) => _s(v).toLowerCase();

String _chiSo(Object? v) => _s(v).replaceAll(RegExp(r'\D'), '');

KetQuaPhanTich _pt(String vanBan) => BoPhanTichDanhThiep.phanTich(vanBan);

void main() {
  group('BoPhanTichDanhThiep — danh thiếp chuẩn (ảnh danh_thiep_1.jpg)', () {
    const vanBan = '''
CÔNG TY TNHH THƯƠNG MẠI AN PHÁT
NGUYỄN VĂN AN
Giám đốc kinh doanh
Mobile: 0912 345 678
Tel: 024 3333 4444
Email: an.nguyen@anphat.vn
Web: www.anphat.vn
25 Nguyễn Trãi, Thanh Xuân, Hà Nội''';

    test('tách đủ các trường chính', () {
      final kq = _pt(vanBan);
      expect(kq.rong, isFalse);
      expect(_thuong(kq.hoTen), 'nguyễn văn an');
      expect(_thuong(kq.chucVu), 'giám đốc kinh doanh');
      expect(_thuong(kq.congTy), contains('an phát'));
      expect(_s(kq.dienThoai), '0912 345 678');
      expect(_s(kq.dienThoaiKhac), '024 3333 4444');
      expect(_s(kq.email), 'an.nguyen@anphat.vn');
      expect(_s(kq.website), contains('anphat.vn'));
      expect(_s(kq.diaChi), contains('Nguyễn Trãi'));
    });

    test('họ tên không bị nhầm với tên công ty hay chức vụ', () {
      final kq = _pt(vanBan);
      expect(_thuong(kq.hoTen), isNot(contains('công ty')));
      expect(_thuong(kq.hoTen), isNot(contains('giám đốc')));
    });

    test('website lưu không có tiền tố https://', () {
      expect(_s(_pt(vanBan).website), isNot(startsWith('http')));
    });

    test('email, số điện thoại không bị lẫn vào địa chỉ', () {
      final kq = _pt(vanBan);
      expect(_s(kq.diaChi), isNot(contains('@')));
      expect(_s(kq.diaChi), isNot(contains('0912')));
    });
  });

  group('BoPhanTichDanhThiep — danh thiếp có QR (ảnh danh_thiep_2_qr.jpg)', () {
    const vanBan = '''
CÔNG TY CỔ PHẦN GIẢI PHÁP SỐ VIỆT
TRẦN THỊ MINH ANH
Trưởng phòng Marketing
Mobile: 0987 654 321
Email: minhanh.tran@giaiphapso.vn
Web: www.giaiphapso.vn
88 Lê Lợi, Quận 1, TP. Hồ Chí Minh''';

    test('tách đủ các trường chính', () {
      final kq = _pt(vanBan);
      expect(_thuong(kq.hoTen), 'trần thị minh anh');
      expect(_thuong(kq.chucVu), 'trưởng phòng marketing');
      expect(_thuong(kq.congTy), contains('giải pháp số việt'));
      expect(_s(kq.dienThoai), '0987 654 321');
      expect(_s(kq.dienThoaiKhac), isEmpty);
      expect(_s(kq.email), 'minhanh.tran@giaiphapso.vn');
      expect(_s(kq.website), contains('giaiphapso.vn'));
      expect(_s(kq.diaChi), contains('Lê Lợi'));
    });
  });

  group(
    'BoPhanTichDanhThiep — mẫu pipe (khớp kết quả tool/thu_phan_tich.dart)',
    () {
      test('Nguyễn Văn An / ABC', () {
        final kq = _pt('''
Nguyễn Văn An
Giám đốc kinh doanh
CÔNG TY TNHH GIẢI PHÁP ABC
ĐT: 0912 345 678
Tel: 024 3333 4444
Email: an.nguyen@abc.com.vn
Web: www.abc.com.vn
Số 12 Láng Hạ, Đống Đa, Hà Nội''');
        expect(_s(kq.hoTen), 'Nguyễn Văn An');
        expect(_s(kq.chucVu), 'Giám đốc kinh doanh');
        expect(_s(kq.congTy), 'CÔNG TY TNHH GIẢI PHÁP ABC');
        expect(_s(kq.dienThoai), '0912 345 678');
        expect(_s(kq.dienThoaiKhac), '024 3333 4444');
        expect(_s(kq.email), 'an.nguyen@abc.com.vn');
        expect(_s(kq.website), 'www.abc.com.vn');
        expect(_s(kq.diaChi), 'Số 12 Láng Hạ, Đống Đa, Hà Nội');
      });
    },
  );

  group('BoPhanTichDanhThiep — số điện thoại', () {
    test('số quốc tế +84 giữ dạng hiển thị', () {
      final kq = _pt('Trần Thị Bình\nDT: +84 912 345 678');
      expect(_s(kq.dienThoai), '+84 912 345 678');
    });

    test('số viết liền được chia nhóm hiển thị', () {
      final kq = _pt('Trần Thị Bình\nDT: 0912345678');
      expect(_s(kq.dienThoai), '0912 345 678');
    });

    test('số fax không được lấy làm số điện thoại', () {
      final kq = _pt('Trần Thị Bình\nMobile: 0912 345 678\nFax: 024 3333 5555');
      expect(_s(kq.dienThoai), '0912 345 678');
      expect(_chiSo(kq.dienThoaiKhac), isNot('02433335555'));
    });

    test('mã số thuế không bị nhận là số điện thoại', () {
      final kq = _pt('Trần Thị Bình\nMST: 0101234567\nMobile: 0912 345 678');
      expect(_s(kq.dienThoai), '0912 345 678');
      expect(_chiSo(kq.dienThoaiKhac), isNot('0101234567'));
    });
  });

  group('BoPhanTichDanhThiep — email, website', () {
    test('email viết hoa được đổi thành chữ thường', () {
      final kq = _pt('Trần Thị Bình\nEmail: BINH.TRAN@Example.VN');
      expect(_s(kq.email), 'binh.tran@example.vn');
    });

    test('website có https:// được bỏ tiền tố', () {
      final kq = _pt('Trần Thị Bình\nhttps://www.example.vn');
      expect(_s(kq.website), isNot(startsWith('http')));
      expect(_s(kq.website), contains('example.vn'));
    });

    test('phần tên miền của email không bị nhận là website', () {
      final kq = _pt('Trần Thị Bình\nEmail: binh@example.vn');
      expect(_s(kq.email), 'binh@example.vn');
      expect(_s(kq.website), isEmpty);
    });
  });

  group('BoPhanTichDanhThiep — đầu vào xấu', () {
    test('chuỗi rỗng → kết quả rỗng', () {
      expect(_pt('').rong, isTrue);
    });

    test('chỉ có khoảng trắng / xuống dòng → rỗng', () {
      expect(_pt('  \n\n \t ').rong, isTrue);
    });

    test('văn bản không giống danh thiếp không làm bộ phân tích ném lỗi', () {
      expect(() => _pt('@@@ ### 123 ... ;;; \u0000'), returnsNormally);
    });
  });

  group('KetQuaPhanTich.boSung — gộp QR + OCR', () {
    test('bên gọi được ưu tiên, bên kia điền chỗ trống', () {
      final qr = _pt('Trần Thị Bình\nEmail: qr@a.vn');
      final ocr = _pt('Nguyễn Văn An\nEmail: ocr@b.vn\nMobile: 0912 345 678');
      final gop = qr.boSung(ocr);
      expect(_s(gop.hoTen), _s(qr.hoTen)); // QR ưu tiên
      expect(_s(gop.email), 'qr@a.vn'); // QR ưu tiên
      expect(_s(gop.dienThoai), '0912 345 678'); // OCR điền chỗ trống
    });

    test('gộp với kết quả rỗng giữ nguyên dữ liệu', () {
      final a = _pt('Trần Thị Bình\nEmail: binh@a.vn');
      final gop = a.boSung(_pt(''));
      expect(_s(gop.hoTen), _s(a.hoTen));
      expect(_s(gop.email), 'binh@a.vn');
    });
  });

  group('Văn bản demo của danh thiếp mẫu', () {
    test('mẫu chuẩn: phân tích ra họ tên, SĐT, email', () {
      final m = dsDanhThiepMau.firstWhere((m) => m.ma == 'chuan');
      final kq = _pt(m.vanBan);
      expect(_thuong(kq.hoTen), 'nguyễn văn an');
      expect(_s(kq.dienThoai), '0912 345 678');
      expect(_s(kq.email), 'an.nguyen@anphat.vn');
    });

    test('mẫu QR: văn bản OCR demo cũng phân tích được', () {
      final m = dsDanhThiepMau.firstWhere((m) => m.ma == 'co_qr');
      final kq = _pt(m.vanBan);
      expect(_thuong(kq.hoTen), 'trần thị minh anh');
      expect(_s(kq.email), 'minhanh.tran@giaiphapso.vn');
    });
  });
}
