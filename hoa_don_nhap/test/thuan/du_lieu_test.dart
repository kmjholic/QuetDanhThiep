import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/cau_hinh/cau_hinh.dart';
import 'package:hoa_don_nhap/du_lieu/kho_cai_dat.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/kho_lich_su.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/ngon_ngu/du_lieu_chuoi.dart';

HoaDon hd(String ma, int phut, {AnhHoaDon? anh}) => HoaDon(
      ma: ma,
      tieuDe: 'HĐ $ma',
      noiDung: 'Nội dung $ma',
      taoLuc: DateTime(2026, 11, 4, 8, phut),
      suaLuc: DateTime(2026, 11, 4, 8, phut),
      nguon: NguonAnh.mayAnh,
      anh: anh,
    );

void main() {
  group('HoaDon / AnhHoaDon', () {
    test('JSON đi rồi về giữ nguyên mọi trường, kể cả ảnh asset và ảnh tệp', () {
      for (final anh in [const AnhHoaDon.asset('assets/mau/hoa_don_1.jpg'), const AnhHoaDon.tep('/data/x.jpg'), null]) {
        final goc = hd('a1', 5, anh: anh);
        final ve = HoaDon.tuJson(jsonDecode(jsonEncode(goc.toJson())) as Map<String, Object?>);
        expect(ve.ma, goc.ma);
        expect(ve.tieuDe, goc.tieuDe);
        expect(ve.noiDung, goc.noiDung);
        expect(ve.taoLuc, goc.taoLuc);
        expect(ve.suaLuc, goc.suaLuc);
        expect(ve.nguon, goc.nguon);
        expect(ve.anh, anh);
      }
    });
    test('thiếu trường bắt buộc → FormatException', () {
      expect(() => HoaDon.tuJson({'ma': 'x'}), throwsA(isA<FormatException>()));
    });
    test('nguồn lạ → thư viện; sửa lúc thiếu → bằng tạo lúc', () {
      final h = HoaDon.tuJson({'ma': 'x', 'noi_dung': 'y', 'tao_luc': 0, 'nguon': '???'});
      expect(h.nguon, NguonAnh.thuVien);
      expect(h.suaLuc, h.taoLuc);
    });
  });

  group('KhoLichSu', () {
    test('kho trống → danh sách rỗng', () async {
      expect(await KhoLichSu(KhoBoNho()).docTatCa(), isEmpty);
    });
    test('lưu: mới nhất ở đầu; lưu lại cùng mã thì cập nhật, không nhân đôi', () async {
      final kho = KhoLichSu(KhoBoNho());
      await kho.luu(hd('a', 1));
      await kho.luu(hd('b', 2));
      final ds = await kho.luu(hd('a', 1).copyWith(noiDung: 'đã sửa'));
      expect(ds.map((h) => h.ma).toList(), ['b', 'a']);
      expect((await kho.docTatCa()).last.noiDung, 'đã sửa');
    });
    test('xoá một và xoá hết', () async {
      final kho = KhoLichSu(KhoBoNho());
      await kho.luu(hd('a', 1));
      await kho.luu(hd('b', 2));
      expect((await kho.xoa('a')).map((h) => h.ma).toList(), ['b']);
      await kho.xoaHet();
      expect(await kho.docTatCa(), isEmpty);
    });
    test('bản ghi hỏng lẻ tẻ bị bỏ qua, phần còn lại vẫn đọc được', () async {
      final raw = jsonEncode([hd('a', 1).toJson(), {'ma': 'thiếu'}, 'rác', hd('b', 2).toJson()]);
      final ds = await KhoLichSu(KhoBoNho({KhoLichSu.khoa: raw})).docTatCa();
      expect(ds.map((h) => h.ma).toList(), ['b', 'a']);
    });
    test('cả chuỗi JSON hỏng → FormatException (màn hình hiện trạng thái lỗi)', () async {
      final kho = KhoLichSu(KhoBoNho({KhoLichSu.khoa: '{hỏng'}));
      await expectLater(kho.docTatCa(), throwsA(isA<FormatException>()));
    });
  });

  group('KhoCaiDat', () {
    test('mặc định: theo máy, demo tắt; ghi rồi đọc lại', () async {
      final kho = KhoCaiDat(KhoBoNho());
      expect(await kho.docNgonNgu(), NgonNgu.heThong);
      expect(await kho.docDemo(), isFalse);
      await kho.ghiNgonNgu(NgonNgu.en);
      await kho.ghiDemo(true);
      expect(await kho.docNgonNgu(), NgonNgu.en);
      expect(await kho.docDemo(), isTrue);
    });
  });

  group('CauHinh (OCR_MODE)', () {
    test('đọc giá trị, giá trị lạ → tự động', () {
      expect(CauHinh.docCheDo('device'), CheDoOcr.thietBi);
      expect(CauHinh.docCheDo(' DEMO '), CheDoOcr.demo);
      expect(CauHinh.docCheDo('auto'), CheDoOcr.tuDong);
      expect(CauHinh.docCheDo('openai'), CheDoOcr.tuDong);
    });
    test('không có ML Kit (web, máy tính) → luôn demo, không cho đổi', () {
      const ch = CauHinh(cheDo: CheDoOcr.thietBi);
      expect(ch.dungDemo(coOcrThietBi: false, nguoiDungChonDemo: false), isTrue);
      expect(ch.choDoiCheDo(coOcrThietBi: false), isFalse);
    });
    test('tự động: theo công tắc người dùng; thietBi/demo: khoá công tắc', () {
      const tuDong = CauHinh();
      expect(tuDong.dungDemo(coOcrThietBi: true, nguoiDungChonDemo: true), isTrue);
      expect(tuDong.dungDemo(coOcrThietBi: true, nguoiDungChonDemo: false), isFalse);
      expect(tuDong.choDoiCheDo(coOcrThietBi: true), isTrue);
      expect(const CauHinh(cheDo: CheDoOcr.thietBi).dungDemo(coOcrThietBi: true, nguoiDungChonDemo: true), isFalse);
      expect(const CauHinh(cheDo: CheDoOcr.demo).dungDemo(coOcrThietBi: true, nguoiDungChonDemo: false), isTrue);
      expect(const CauHinh(cheDo: CheDoOcr.demo).choDoiCheDo(coOcrThietBi: true), isFalse);
    });
  });

  group('Chuỗi giao diện vi/en', () {
    test('mọi khoá có đủ bản tiếng Việt và tiếng Anh, không rỗng', () {
      for (final k in K.values) {
        expect(chuoiVi[k]?.trim(), isNotEmpty, reason: 'thiếu vi: $k');
        expect(chuoiEn[k]?.trim(), isNotEmpty, reason: 'thiếu en: $k');
      }
    });
    test('hai ngôn ngữ dùng cùng bộ tham số {…}', () {
      final re = RegExp(r'\{(\w+)\}');
      for (final k in K.values) {
        final a = re.allMatches(chuoiVi[k]!).map((m) => m[1]).toSet();
        final b = re.allMatches(chuoiEn[k]!).map((m) => m[1]).toSet();
        expect(a, b, reason: 'tham số khác nhau ở $k');
      }
    });
    test('dienThamSo thay đúng chỗ', () {
      expect(dienThamSo(chuoiVi[K.thongKe]!, {'n': '12', 's': '0.8'}), 'Đọc được 12 dòng trong 0.8 giây');
    });
  });
}
