// Test TaoVCard / DocVCard. Phần "khớp kết quả tool/thu_vcard.dart" assert đúng đầu ra thật đã chạy.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/mo_hinh/danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/phan_tich_danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/vcard.dart';
import 'package:hoa_don_nhap/ocr/mau_danh_thiep.dart';

String _s(Object? v) => v?.toString() ?? '';

String _chiSo(Object? v) => _s(v).replaceAll(RegExp(r'\D'), '');

DanhThiep _theAn({
  String id = 'dt1',
  String congTy = 'CÔNG TY TNHH GIẢI PHÁP ABC',
  String dienThoaiKhac = '024 3333 4444',
  String email = 'an.nguyen@abc.com.vn',
  String diaChi = 'Số 12 Láng Hạ, Đống Đa, Hà Nội',
}) {
  return DanhThiep(
    id: id,
    thoiGian: DateTime.utc(2026, 11, 25, 8, 30),
    hoTen: 'Nguyễn Văn An',
    chucVu: 'Giám đốc kinh doanh',
    congTy: congTy,
    dienThoai: '0912 345 678',
    dienThoaiKhac: dienThoaiKhac,
    email: email,
    website: 'www.abc.com.vn',
    diaChi: diaChi,
    ghiChu: '',
    duongDanAnh: null,
    nguon: NguonDanhThiep.thucong,
  );
}

/// Tách theo CRLF và bỏ dòng rỗng ở cuối.
List<String> _dong(String s) {
  final d = s.split('\r\n');
  while (d.isNotEmpty && d.last.isEmpty) {
    d.removeLast();
  }
  return d;
}

void main() {
  group('TaoVCard.tao', () {
    test('khớp đầu ra thật của tool/thu_vcard.dart', () {
      expect(_dong(TaoVCard.tao(_theAn())), [
        'BEGIN:VCARD',
        'VERSION:3.0',
        'FN:Nguyễn Văn An',
        'N:Nguyễn;An;Văn;;',
        'ORG:CÔNG TY TNHH GIẢI PHÁP ABC',
        'TITLE:Giám đốc kinh doanh',
        'TEL;TYPE=CELL:0912 345 678',
        'TEL;TYPE=WORK,VOICE:024 3333 4444',
        r'EMAIL;TYPE=INTERNET,WORK:an.nguyen@abc.com.vn',
        'URL:https://www.abc.com.vn',
        r'ADR;TYPE=WORK:;;Số 12 Láng Hạ\, Đống Đa\, Hà Nội;;;;',
        'REV:20261125T083000Z',
        'END:VCARD',
      ]);
    });

    test('dùng CRLF làm dấu xuống dòng, không có LF lẻ', () {
      final out = TaoVCard.tao(_theAn());
      expect(out, contains('\r\n'));
      expect(out.replaceAll('\r\n', ''), isNot(contains('\n')));
    });

    test('không có số thứ hai → chỉ một dòng TEL', () {
      final out = TaoVCard.tao(_theAn(dienThoaiKhac: ''));
      expect(_dong(out).where((l) => l.startsWith('TEL')).length, 1);
    });

    test('thêm https:// cho website', () {
      expect(TaoVCard.tao(_theAn()), contains('URL:https://www.abc.com.vn'));
    });

    test('escape dấu \\ ; , trong địa chỉ', () {
      final out = TaoVCard.tao(_theAn(diaChi: r'A\B; C, D'));
      expect(out, contains(r'ADR;TYPE=WORK:;;A\\B\; C\, D;;;;'));
    });

    test(
      'dòng dài được gấp: mỗi dòng ≤ 75 byte, gỡ gấp ra đúng nguyên văn',
      () {
        final congTy = 'CÔNG TY CỔ PHẦN ĐẦU TƯ VÀ PHÁT TRIỂN CÔNG NGHỆ ' * 3;
        final out = TaoVCard.tao(_theAn(congTy: congTy.trim()));
        for (final l in _dong(out)) {
          expect(utf8.encode(l).length, lessThanOrEqualTo(75), reason: l);
        }
        final goGap = out.replaceAll('\r\n ', '');
        expect(goGap, contains('ORG:${congTy.trim()}'));
      },
    );

    test('tenTep, mimeType, phanMoRong', () {
      expect(TaoVCard.tenTep(_theAn(id: 'dt1')), 'danh_thiep_dt1.vcf');
      expect(TaoVCard.mimeType, 'text/vcard');
      expect(TaoVCard.phanMoRong, 'vcf');
    });
  });

  group('TaoVCard.taoNhieu', () {
    test('nhiều danh thiếp → nhiều khối BEGIN/END', () {
      final out = TaoVCard.taoNhieu([_theAn(id: 'a'), _theAn(id: 'b')]);
      expect('BEGIN:VCARD'.allMatches(out).length, 2);
      expect('END:VCARD'.allMatches(out).length, 2);
    });
  });

  group('DocVCard', () {
    test('nhận dạng vCard, MECARD; từ chối văn bản thường', () {
      expect(DocVCard.nhanDang(TaoVCard.tao(_theAn())), isTrue);
      expect(DocVCard.nhanDang('MECARD:N:Trần,Bình;TEL:0901234567;;'), isTrue);
      expect(DocVCard.nhanDang('https://example.vn'), isFalse);
      expect(DocVCard.nhanDang('xin chào'), isFalse);
      expect(DocVCard.nhanDang(''), isFalse);
    });

    test('đọc ngược vCard do TaoVCard tạo ra (khớp thu_vcard.dart)', () {
      final kq = DocVCard.doc(TaoVCard.tao(_theAn()));
      expect(_s(kq.hoTen), 'Nguyễn Văn An');
      expect(_s(kq.dienThoai), '0912 345 678');
      expect(_s(kq.dienThoaiKhac), '024 3333 4444');
      expect(_s(kq.diaChi), 'Số 12 Láng Hạ, Đống Đa, Hà Nội');
      expect(_s(kq.email), 'an.nguyen@abc.com.vn');
      expect(_s(kq.congTy), 'CÔNG TY TNHH GIẢI PHÁP ABC');
    });

    test('đọc vCard sau khi gấp dòng vẫn ra đúng công ty', () {
      final congTy = ('CÔNG TY CỔ PHẦN ĐẦU TƯ VÀ PHÁT TRIỂN CÔNG NGHỆ ' * 3)
          .trim();
      final kq = DocVCard.doc(TaoVCard.tao(_theAn(congTy: congTy)));
      expect(_s(kq.congTy), congTy);
    });

    test('đọc MECARD', () {
      final kq = DocVCard.doc(
        'MECARD:N:Trần,Bình;TEL:0901234567;EMAIL:binh@example.vn;;',
      );
      expect(_s(kq.hoTen), contains('Trần'));
      expect(_s(kq.hoTen), contains('Bình'));
      expect(_chiSo(kq.dienThoai), '0901234567');
      expect(_s(kq.email), 'binh@example.vn');
    });

    test('văn bản không phải vCard → kết quả rỗng, không ném lỗi', () {
      expect(DocVCard.doc('xin chào').rong, isTrue);
      expect(DocVCard.doc('').rong, isTrue);
      expect(() => DocVCard.doc('BEGIN:VCARD\r\nrác'), returnsNormally);
    });

    test('mã QR thật trên ảnh danh_thiep_2_qr.jpg', () {
      final m = dsDanhThiepMau.firstWhere((m) => m.coQr);
      final kq = DocVCard.doc(m.noiDungQr.first);
      expect(_s(kq.hoTen), 'Trần Thị Minh Anh');
      expect(_s(kq.chucVu), 'Trưởng phòng Marketing');
      expect(_s(kq.congTy), 'Công ty Cổ phần Giải pháp Số Việt');
      expect(_s(kq.email), 'minhanh.tran@giaiphapso.vn');
      // QR ghi +84987654321 (không dấu cách): chỉ so phần chữ số cuối.
      expect(_chiSo(kq.dienThoai), endsWith('987654321'));
      // QR không có website / địa chỉ.
      expect(_s(kq.website), isEmpty);
      expect(_s(kq.diaChi), isEmpty);
    });

    test('gộp QR + OCR của mẫu có QR: website, địa chỉ lấy từ OCR', () {
      final m = dsDanhThiepMau.firstWhere((m) => m.coQr);
      final gop = DocVCard.doc(
        m.noiDungQr.first,
      ).boSung(BoPhanTichDanhThiep.phanTich(m.vanBan));
      expect(_s(gop.hoTen), 'Trần Thị Minh Anh'); // từ QR
      expect(_s(gop.website), contains('giaiphapso.vn')); // từ OCR
      expect(_s(gop.diaChi), contains('Lê Lợi')); // từ OCR
    });
  });
}
