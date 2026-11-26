import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/cau_hinh/cau_hinh.dart';
import 'package:hoa_don_nhap/dieu_khien/cai_dat_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/quet_dk.dart';
import 'package:hoa_don_nhap/du_lieu/kho_cai_dat.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/kho_lich_su.dart';
import 'package:hoa_don_nhap/du_lieu/luu_anh.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/ocr/bo_nhan_dang.dart';
import 'package:hoa_don_nhap/ocr/dinh_dang_anh.dart';
import 'package:hoa_don_nhap/ocr/hoa_don_mau.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo.dart';

/// Bộ nhận dạng giả: trả về văn bản cho trước, hoặc ném lỗi.
class BoGia implements BoNhanDang {
  String vanBan;
  Object? loi;
  int soLanGoi = 0;

  BoGia({this.vanBan = '', this.loi});

  @override
  bool get laDemo => false;

  @override
  Future<KetQuaNhanDang> nhanDang(AnhHoaDon anh) async {
    soLanGoi++;
    if (loi != null) throw loi!;
    return KetQuaNhanDang(vanBan: vanBan, soDong: 1, thoiGian: const Duration(milliseconds: 420));
  }

  @override
  Future<void> dong() async {}
}

const anhTep = AnhHoaDon.tep('/tam/anh.jpg');

DieuKhienQuet quet(BoNhanDang bo) => DieuKhienQuet(
      boNhanDang: bo,
      anh: anhTep,
      nguon: NguonAnh.mayAnh,
      bayGio: () => DateTime(2026, 11, 4, 9, 30),
      ngauNhien: () => 7,
    );

void main() {
  group('DieuKhienQuet', () {
    test('có chữ: chuẩn hoá văn bản, đoán tiêu đề, báo thay đổi 2 lần (đang chạy → xong)', () async {
      final dk = quet(BoGia(vanBan: 'ĐẠI LÝ MINH TÂM   \r\n\r\n\r\nNước suối   5'));
      final cacTrangThai = <TrangThaiQuet>[];
      dk.themNghe(() => cacTrangThai.add(dk.trangThai));
      await dk.batDau();
      expect(cacTrangThai, [TrangThaiQuet.dangNhanDang, TrangThaiQuet.coChu]);
      expect(dk.vanBan, 'ĐẠI LÝ MINH TÂM\n\nNước suối   5');
      expect(dk.tieuDeGoiY, 'ĐẠI LÝ MINH TÂM');
      expect(dk.soDong, 2);
    });

    test('ảnh không có chữ → trạng thái "không có chữ" (không phải lỗi)', () async {
      final dk = quet(BoGia(vanBan: '  \n '));
      await dk.batDau();
      expect(dk.trangThai, TrangThaiQuet.khongCoChu);
      expect(dk.loi, isNull);
    });

    test('LoiNhanDang giữ nguyên loại; lỗi lạ → thatBai; Thử lại chạy lại bộ nhận dạng', () async {
      final bo = BoGia(loi: const LoiNhanDang(LoaiLoiNhanDang.khongDocDuocAnh));
      final dk = quet(bo);
      await dk.batDau();
      expect(dk.trangThai, TrangThaiQuet.loi);
      expect(dk.loi!.loai, LoaiLoiNhanDang.khongDocDuocAnh);

      bo.loi = StateError('bất ngờ');
      await dk.batDau();
      expect(dk.loi!.loai, LoaiLoiNhanDang.thatBai);

      bo
        ..loi = null
        ..vanBan = 'Tạp hóa';
      await dk.batDau();
      expect(dk.trangThai, TrangThaiQuet.coChu);
      expect(bo.soLanGoi, 3);
    });

    test('Nhập tay: chuyển sang khung sửa với nội dung trống', () async {
      final dk = quet(BoGia());
      await dk.batDau();
      dk.chuyenSangNhapTay();
      expect(dk.trangThai, TrangThaiQuet.coChu);
      expect(dk.nhapTay, isTrue);
      expect(dk.vanBan, '');
    });

    test('taoHoaDon: tiêu đề trống → đoán từ nội dung → tiêu đề mặc định', () {
      final dk = quet(BoGia());
      final a = dk.taoHoaDon(tieuDe: '  Đại lý A ', noiDung: 'x', tieuDeMacDinh: 'HĐ');
      expect(a.tieuDe, 'Đại lý A');
      expect(dk.taoHoaDon(tieuDe: '', noiDung: '\nCông ty An Phát\n1.000', tieuDeMacDinh: 'HĐ').tieuDe, 'Công ty An Phát');
      final c = dk.taoHoaDon(tieuDe: '', noiDung: '500.000', tieuDeMacDinh: 'Hóa đơn 04/11');
      expect(c.tieuDe, 'Hóa đơn 04/11');
      expect(c.anh, anhTep);
      expect(c.nguon, NguonAnh.mayAnh);
      expect(c.taoLuc, DateTime(2026, 11, 4, 9, 30));
    });

    test('màn hình đã đóng (huy) thì kết quả trả về muộn bị bỏ qua', () async {
      final dk = quet(BoGia(vanBan: 'abc'));
      var soLanBao = 0;
      dk.themNghe(() => soLanBao++);
      final f = dk.batDau(); // đã báo "đang nhận dạng" 1 lần
      dk.huy();
      await f;
      expect(soLanBao, 1);
      expect(dk.trangThai, TrangThaiQuet.dangNhanDang);
    });
  });

  group('DieuKhienLichSu', () {
    test('tải: đang tải → sẵn sàng (trống); lỗi bộ nhớ → trạng thái lỗi; thử lại được', () async {
      final kho = KhoBoNho()..hong = true;
      final ls = DieuKhienLichSu(KhoLichSu(kho), LuuAnhGiuNguyen());
      expect(ls.trangThai, TrangThaiLichSu.dangTai);
      await ls.tai();
      expect(ls.trangThai, TrangThaiLichSu.loi);
      kho.hong = false;
      await ls.tai();
      expect(ls.trangThai, TrangThaiLichSu.sanSang);
      expect(ls.trong, isTrue);
    });

    test('lưu giữ lại ảnh, xoá thì xoá ảnh; xoá hết xoá mọi ảnh', () async {
      final luuAnh = LuuAnhGiuNguyen();
      final ls = DieuKhienLichSu(KhoLichSu(KhoBoNho()), luuAnh);
      await ls.tai();
      final h = quet(BoGia()).taoHoaDon(tieuDe: 'A', noiDung: 'x', tieuDeMacDinh: '');
      await ls.luu(h);
      expect(ls.ds.single.ma, h.ma);
      expect(ls.tim(h.ma)?.tieuDe, 'A');
      await ls.xoa(h.ma);
      expect(ls.ds, isEmpty);
      expect(luuAnh.daXoa, [anhTep]);
      await ls.luu(h);
      await ls.xoaHet();
      expect(ls.ds, isEmpty);
      expect(luuAnh.daXoa.length, 2);
    });
  });

  group('DieuKhienCaiDat', () {
    test('đọc/ghi ngôn ngữ và công tắc demo', () async {
      final kho = KhoBoNho();
      final cd = DieuKhienCaiDat(KhoCaiDat(kho), cauHinh: const CauHinh(), coOcrThietBi: true);
      await cd.tai();
      expect(cd.dungDemo, isFalse);
      await cd.datDemo(true);
      await cd.datNgonNgu(NgonNgu.en);
      final cd2 = DieuKhienCaiDat(KhoCaiDat(kho), cauHinh: const CauHinh(), coOcrThietBi: true);
      await cd2.tai();
      expect(cd2.dungDemo, isTrue);
      expect(cd2.ngonNgu, NgonNgu.en);
    });
    test('bộ nhớ lỗi không làm hỏng app: dùng giá trị mặc định', () async {
      final cd = DieuKhienCaiDat(KhoCaiDat(KhoBoNho()..hong = true), cauHinh: const CauHinh(), coOcrThietBi: true);
      await cd.tai();
      expect(cd.ngonNgu, NgonNgu.heThong);
      await cd.datNgonNgu(NgonNgu.vi); // ghi lỗi nhưng vẫn đổi trong phiên
      expect(cd.ngonNgu, NgonNgu.vi);
    });
    test('cấu hình OCR_MODE=device khoá công tắc demo', () async {
      final cd = DieuKhienCaiDat(KhoCaiDat(KhoBoNho()),
          cauHinh: const CauHinh(cheDo: CheDoOcr.thietBi), coOcrThietBi: true);
      await cd.datDemo(true);
      expect(cd.dungDemo, isFalse);
    });
  });

  group('Chế độ demo và ảnh mẫu', () {
    final demo = NhanDangDemo(treo: Duration.zero);

    test('mẫu thường trả đúng văn bản; ảnh người dùng trả văn bản mẫu đầu tiên', () async {
      final kq = await demo.nhanDang(AnhHoaDon.asset(dsHoaDonMau[1].asset));
      expect(kq.vanBan, contains('PHÂN PHỐI AN PHÁT'));
      expect(kq.soDong, greaterThan(5));
      final kq2 = await demo.nhanDang(anhTep);
      expect(kq2.vanBan, startsWith('ĐẠI LÝ NƯỚC GIẢI KHÁT'));
    });

    test('mẫu "mờ" → rỗng; mẫu "hỏng" → LoiNhanDang khongDocDuocAnh', () async {
      final mo = dsHoaDonMau.firstWhere((m) => m.kieu == KieuMau.khongCoChu);
      final hong = dsHoaDonMau.firstWhere((m) => m.kieu == KieuMau.loi);
      expect((await demo.nhanDang(AnhHoaDon.asset(mo.asset))).trong, isTrue);
      await expectLater(
        demo.nhanDang(AnhHoaDon.asset(hong.asset)),
        throwsA(isA<LoiNhanDang>().having((e) => e.loai, 'loai', LoaiLoiNhanDang.khongDocDuocAnh)),
      );
    });

    test('tệp ảnh mẫu có trong assets/ và khớp kiểu (ảnh hỏng thật sự không phải ảnh)', () {
      for (final m in dsHoaDonMau) {
        final tep = File(m.asset);
        expect(tep.existsSync(), isTrue, reason: m.asset);
        final dinhDang = dinhDangAnh(tep.openSync().readSync(16));
        if (m.kieu == KieuMau.loi) {
          expect(dinhDang, isNull, reason: m.asset);
        } else {
          expect(dinhDang, 'jpeg', reason: m.asset);
        }
      }
    });
  });
}
