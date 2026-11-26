import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/mo_hinh/xu_ly_van_ban.dart';
import 'package:hoa_don_nhap/ocr/bo_nhan_dang.dart';
import 'package:hoa_don_nhap/ocr/dinh_dang_anh.dart';
import 'package:hoa_don_nhap/ocr/ghep_dong.dart';

DongChu d(String chu, double trai, double tren, {double cao = 30, double rong = 200}) =>
    DongChu(chu, trai: trai, tren: tren, phai: trai + rong, duoi: tren + cao);

void main() {
  group('chuanHoaVanBan', () {
    test('gom CRLF, bỏ khoảng trắng cuối dòng, tối đa một dòng trống', () {
      expect(chuanHoaVanBan('  A  \r\nB\t\r\n\r\n\r\n\r\nC  \n'), 'A\nB\n\nC');
    });
    test('chuỗi toàn khoảng trắng → rỗng', () {
      expect(chuanHoaVanBan(' \n\t\n '), '');
    });
  });

  group('doanTieuDe', () {
    test('lấy dòng đầu có ít nhất 3 chữ cái, bỏ dòng toàn số', () {
      expect(doanTieuDe('0123 456\n--\nĐẠI LÝ MINH TÂM\nSố: 1'), 'ĐẠI LÝ MINH TÂM');
    });
    test('gộp nhiều khoảng trắng, cắt dài kèm dấu …', () {
      final t = doanTieuDe('Công   ty ${'x' * 100}', toiDa: 20);
      expect(t.length, 20);
      expect(t.startsWith('Công ty '), isTrue);
      expect(t.endsWith('…'), isTrue);
    });
    test('không có dòng phù hợp → rỗng', () {
      expect(doanTieuDe('12/11\n500.000'), '');
    });
  });

  test('tomTat: hai dòng đầu không rỗng nối bằng " · "', () {
    expect(tomTat('\nA   B\n\nC\nD'), 'A B · C');
  });

  test('dinhDangThoiGian: dd/MM/yyyy HH:mm', () {
    expect(dinhDangThoiGian(DateTime(2026, 3, 7, 9, 5)), '07/03/2026 09:05');
  });

  test('taoMa: khác nhau khi khác số ngẫu nhiên, chỉ gồm chữ thường và số', () {
    final t = DateTime(2026, 11, 4);
    expect(taoMa(t, 1) == taoMa(t, 2), isFalse);
    expect(RegExp(r'^[0-9a-z]+$').hasMatch(taoMa(t, 65535)), isTrue);
  });

  group('ghepThanhHang', () {
    test('các khối cùng độ cao thành một hàng, sắp trái → phải', () {
      final kq = ghepThanhHang([
        d('480.000', 800, 102),
        d('Nước suối 500ml', 50, 100),
        d('5', 560, 98),
        d('Trà xanh', 50, 160),
        d('540.000', 800, 161),
      ]);
      expect(kq, 'Nước suối 500ml   5   480.000\nTrà xanh   540.000');
    });
    test('hai hàng sát nhau nhưng lệch hơn nửa chiều cao thì tách', () {
      expect(ghepThanhHang([d('A', 0, 0), d('B', 300, 20)]), 'A\nB');
    });
    test('bỏ dòng rỗng; danh sách rỗng → chuỗi rỗng', () {
      expect(ghepThanhHang([d('  ', 0, 0)]), '');
      expect(ghepThanhHang(const []), '');
    });
  });

  group('dinhDangAnh', () {
    test('nhận JPEG, PNG, WEBP, HEIC', () {
      expect(dinhDangAnh([0xFF, 0xD8, 0xFF, 0xE0]), 'jpeg');
      expect(dinhDangAnh([0x89, 0x50, 0x4E, 0x47, 0x0D]), 'png');
      expect(dinhDangAnh([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits]), 'webp');
      expect(dinhDangAnh([0, 0, 0, 24, ...'ftypheic'.codeUnits]), 'heic');
    });
    test('tệp rác hoặc quá ngắn → null', () {
      expect(dinhDangAnh('NOT-AN-IMAGE'.codeUnits), isNull);
      expect(dinhDangAnh([0xFF]), isNull);
    });
  });
}
