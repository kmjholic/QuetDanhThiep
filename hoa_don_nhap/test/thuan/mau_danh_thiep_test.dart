// Kiểm tra bộ danh thiếp mẫu: tệp ảnh có thật trong assets/, đúng loại, được khai báo trong pubspec.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/ocr/hoa_don_mau.dart' show KieuMau;
import 'package:hoa_don_nhap/ocr/mau_danh_thiep.dart';

bool _laJpeg(List<int> b) =>
    b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

void main() {
  group('danh thiếp mẫu', () {
    test('có đủ 4 mẫu: chuẩn, có QR, mờ, hỏng', () {
      expect(dsDanhThiepMau.map((m) => m.ma), [
        'chuan',
        'co_qr',
        'anh_mo',
        'anh_hong',
      ]);
    });

    test('mã và đường dẫn asset không trùng nhau', () {
      expect(
        dsDanhThiepMau.map((m) => m.ma).toSet().length,
        dsDanhThiepMau.length,
      );
      expect(
        dsDanhThiepMau.map((m) => m.asset).toSet().length,
        dsDanhThiepMau.length,
      );
    });

    test('chỉ mẫu có QR mới có nội dung QR', () {
      for (final m in dsDanhThiepMau) {
        expect(m.coQr, m.ma == 'co_qr', reason: m.ma);
      }
    });

    test('mẫu mờ / hỏng không có văn bản giả lập', () {
      for (final m in dsDanhThiepMau) {
        if (m.kieu == KieuMau.khongCoChu || m.kieu == KieuMau.loi) {
          expect(m.vanBan, isEmpty, reason: m.ma);
        } else {
          expect(m.vanBan.trim(), isNotEmpty, reason: m.ma);
        }
      }
    });

    test('timDanhThiepMauTheoAsset', () {
      for (final m in dsDanhThiepMau) {
        expect(timDanhThiepMauTheoAsset(m.asset), same(m));
      }
      expect(timDanhThiepMauTheoAsset('assets/khong_co.jpg'), isNull);
    });
  });

  group('tệp ảnh mẫu có trong assets/', () {
    for (final m in dsDanhThiepMau) {
      test('${m.ma}: ${m.asset}', () {
        final f = File(m.asset);
        expect(f.existsSync(), isTrue, reason: 'thiếu ${m.asset}');
        final byte = f.readAsBytesSync();
        expect(byte, isNotEmpty);
        if (m.kieu == KieuMau.loi) {
          expect(
            _laJpeg(byte),
            isFalse,
            reason: 'mẫu hỏng phải KHÔNG phải ảnh JPEG thật',
          );
        } else {
          expect(_laJpeg(byte), isTrue, reason: 'phải là JPEG thật');
        }
      });
    }

    test('pubspec.yaml khai báo thư mục assets/danh_thiep/', () {
      expect(
        File('pubspec.yaml').readAsStringSync(),
        contains('assets/danh_thiep/'),
      );
    });
  });
}
