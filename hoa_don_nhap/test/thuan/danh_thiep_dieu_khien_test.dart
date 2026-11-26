import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_danh_thiep_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_dk.dart' show TrangThaiLichSu;
import 'package:hoa_don_nhap/dieu_khien/quet_danh_thiep_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/quet_dk.dart' show TrangThaiQuet;
import 'package:hoa_don_nhap/du_lieu/kho_danh_thiep.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/luu_anh.dart';
import 'package:hoa_don_nhap/du_lieu/xuat_vcard.dart';
import 'package:hoa_don_nhap/mo_hinh/chuan_hoa_nfc.dart';
import 'package:hoa_don_nhap/mo_hinh/danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/mo_hinh/phan_tich_danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/vcard.dart';
import 'package:hoa_don_nhap/ocr/bo_nhan_dang.dart';
import 'package:hoa_don_nhap/ocr/bo_quet_ma.dart';
import 'package:hoa_don_nhap/ocr/hoa_don_mau.dart' show KieuMau;
import 'package:hoa_don_nhap/ocr/mau_danh_thiep.dart';

import 'dieu_khien_test.dart' show BoGia, anhTep;

/// Bộ quét mã giả: trả danh sách cho trước hoặc ném lỗi.
class BoQuetMaGia implements BoQuetMa {
  List<String> noiDung;
  Object? loi;

  BoQuetMaGia({this.noiDung = const [], this.loi});

  @override
  bool get laDemo => false;

  @override
  Future<List<String>> quet(AnhHoaDon anh) async {
    if (loi != null) throw loi!;
    return noiDung;
  }

  @override
  Future<void> dong() async {}
}

DieuKhienQuetDanhThiep dkQuet(
  BoNhanDang bo, {
  BoQuetMa? ma,
  AnhHoaDon anh = anhTep,
  int ngau = 7,
  DateTime? luc,
}) => DieuKhienQuetDanhThiep(
  boNhanDang: bo,
  anh: anh,
  boQuetMa: ma ?? const BoQuetMaRong(),
  bayGio: () => luc ?? DateTime(2026, 11, 4, 9, 30),
  ngauNhien: () => ngau,
);

DanhThiep taoThe(int ngau, String ten) =>
    dkQuet(
      BoGia(),
      ngau: ngau,
      luc: DateTime(2026, 11, 4, 9, ngau),
    ).taoDanhThiep(
      hoTen: ten,
      chucVu: '',
      congTy: '',
      dienThoai: '0912 345 678',
      dienThoaiKhac: '',
      email: '',
      website: '',
      diaChi: '',
      ghiChu: '',
    );

DanhThiepMau get mauChuan => dsDanhThiepMau.firstWhere(
  (m) => m.kieu != KieuMau.khongCoChu && m.kieu != KieuMau.loi && !m.coQr,
);
DanhThiepMau get mauQr => dsDanhThiepMau.firstWhere((m) => m.coQr);

void main() {
  group('chuanHoaNfcViet', () {
    test('gộp dấu rời về ký tự dựng sẵn, chịu cả hai thứ tự dấu', () {
      expect(
        chuanHoaNfcViet('a\u0323\u0302'),
        '\u1EAD',
      ); // ậ (chấm dưới rồi mũ)
      expect(
        chuanHoaNfcViet('a\u0302\u0323'),
        '\u1EAD',
      ); // ậ (mũ rồi chấm dưới)
      expect(chuanHoaNfcViet('e\u0302\u0303'), '\u1EC5'); // ễ
    });
    test('văn bản đã NFC hoặc không có dấu thì giữ nguyên', () {
      expect(chuanHoaNfcViet('Nguyễn Văn A 0912'), 'Nguyễn Văn A 0912');
      expect(chuanHoaNfcViet(''), '');
    });
  });

  group('KhoDanhThiep', () {
    test('lưu nhiều bản, đọc lại ở kho mới; xoá và xoá hết', () async {
      final bo = KhoBoNho();
      final kho = KhoDanhThiep(bo);
      final a = taoThe(1, 'An');
      final b = taoThe(2, 'Bình');
      await kho.luu(a);
      await kho.luu(b);
      final doc = await KhoDanhThiep(bo).docTatCa();
      expect(doc.map((d) => d.id).toSet(), {a.id, b.id});
      await kho.xoa(a.id);
      expect((await kho.docTatCa()).single.id, b.id);
      await kho.xoaHet();
      expect(await kho.docTatCa(), isEmpty);
    });

    test('cùng id thì ghi đè, không nhân đôi', () async {
      final kho = KhoDanhThiep(KhoBoNho());
      final a = taoThe(1, 'An');
      await kho.luu(a);
      await kho.luu(a.copyWith(hoTen: 'An Sửa'));
      final doc = await kho.docTatCa();
      expect(doc.single.hoTen, 'An Sửa');
    });

    test(
      'bản ghi hỏng bị bỏ qua; cả chuỗi JSON hỏng thì ném FormatException',
      () async {
        final tot = KhoDanhThiep(
          KhoBoNho({KhoDanhThiep.khoa: '[5, "x", {"hoTen": "thiếu id"}]'}),
        );
        expect(await tot.docTatCa(), isEmpty);
        final hong = KhoDanhThiep(
          KhoBoNho({KhoDanhThiep.khoa: 'không phải json'}),
        );
        await expectLater(hong.docTatCa(), throwsFormatException);
      },
    );
  });

  group('DieuKhienQuetDanhThiep', () {
    test(
      'chỉ OCR: ra kết quả khớp bộ phân tích, báo thay đổi đang chạy → xong',
      () async {
        final mau = mauChuan;
        final dk = dkQuet(BoGia(vanBan: mau.vanBan));
        final cac = <TrangThaiQuet>[];
        dk.themNghe(() => cac.add(dk.trangThai));
        await dk.batDau();
        expect(cac, [TrangThaiQuet.dangNhanDang, TrangThaiQuet.coChu]);
        final mong = BoPhanTichDanhThiep.phanTich(mau.vanBan);
        expect(mong.hoTen, isNotEmpty);
        expect(dk.ketQua?.hoTen, mong.hoTen);
        expect(dk.ketQua?.dienThoai, mong.dienThoai);
        expect(dk.ketQua?.email, mong.email);
        expect(dk.daDungQr, isFalse);
      },
    );

    test('có QR: dữ liệu QR được ưu tiên, OCR điền chỗ trống', () async {
      final mau = mauQr;
      final dk = dkQuet(
        BoGia(vanBan: mau.vanBan),
        ma: BoQuetMaDemo(treo: Duration.zero),
        anh: AnhHoaDon.asset(mau.asset),
      );
      await dk.batDau();
      expect(dk.trangThai, TrangThaiQuet.coChu);
      expect(dk.daDungQr, isTrue);
      final maDau = mau.noiDungQr.firstWhere(
        (s) => DocVCard.nhanDang(s) && !DocVCard.doc(s).rong,
      );
      final mong = DocVCard.doc(
        maDau,
      ).boSung(BoPhanTichDanhThiep.phanTich(mau.vanBan));
      expect(mong.hoTen, isNotEmpty);
      expect(dk.ketQua?.hoTen, mong.hoTen);
      expect(dk.ketQua?.email, mong.email);
    });

    test('OCR lỗi nhưng QR đọc được: vẫn ra kết quả', () async {
      final mau = mauQr;
      final dk = dkQuet(
        BoGia(loi: const LoiNhanDang(LoaiLoiNhanDang.thatBai)),
        ma: BoQuetMaDemo(treo: Duration.zero),
        anh: AnhHoaDon.asset(mau.asset),
      );
      await dk.batDau();
      expect(dk.trangThai, TrangThaiQuet.coChu);
      expect(dk.daDungQr, isTrue);
    });

    test('quét QR lỗi không làm hỏng lượt quét có chữ', () async {
      final dk = dkQuet(
        BoGia(vanBan: mauChuan.vanBan),
        ma: BoQuetMaGia(loi: const LoiQuetMa(LoaiLoiQuetMa.thatBai)),
      );
      await dk.batDau();
      expect(dk.trangThai, TrangThaiQuet.coChu);
      expect(dk.daDungQr, isFalse);
      expect(dk.loiQuetMa, isNotNull);
    });

    test(
      'không chữ, không QR → "không có chữ"; OCR lỗi, QR rỗng → lỗi, Thử lại được',
      () async {
        final trong = dkQuet(BoGia(vanBan: ' \n '));
        await trong.batDau();
        expect(trong.trangThai, TrangThaiQuet.khongCoChu);

        final bo = BoGia(
          loi: const LoiNhanDang(LoaiLoiNhanDang.khongDocDuocAnh),
        );
        final dk = dkQuet(bo);
        await dk.batDau();
        expect(dk.trangThai, TrangThaiQuet.loi);
        expect(dk.loi!.loai, LoaiLoiNhanDang.khongDocDuocAnh);
        bo
          ..loi = null
          ..vanBan = mauChuan.vanBan;
        await dk.batDau();
        expect(dk.trangThai, TrangThaiQuet.coChu);
        expect(dk.loi, isNull);
      },
    );

    test('Nhập tay: chuyển sang khung sửa, nguồn là thủ công', () async {
      final dk = dkQuet(BoGia());
      await dk.batDau();
      dk.chuyenSangNhapTay();
      expect(dk.trangThai, TrangThaiQuet.coChu);
      expect(dk.nhapTay, isTrue);
      expect(dk.nguon, NguonDanhThiep.thucong);
    });

    test('taoDanhThiep: gắn thời gian, id, ảnh đã mã hoá', () {
      final dk = dkQuet(BoGia());
      final d = dk.taoDanhThiep(
        hoTen: 'Nguyễn Văn A',
        chucVu: 'Giám đốc',
        congTy: 'Công ty An Phát',
        dienThoai: '0912 345 678',
        dienThoaiKhac: '',
        email: 'a@anphat.vn',
        website: '',
        diaChi: '',
        ghiChu: 'Gặp ở hội chợ',
      );
      expect(d.id, isNotEmpty);
      expect(d.thoiGian, DateTime(2026, 11, 4, 9, 30));
      expect(d.hoTen, 'Nguyễn Văn A');
      expect(d.ghiChu, 'Gặp ở hội chợ');
      expect(d.duongDanAnh, anhTep.maHoa());
    });

    test('màn hình đã đóng (huy) thì kết quả trả về muộn bị bỏ qua', () async {
      final dk = dkQuet(BoGia(vanBan: mauChuan.vanBan));
      var soLanBao = 0;
      dk.themNghe(() => soLanBao++);
      final f = dk.batDau();
      dk.huy();
      await f;
      expect(soLanBao, 1);
      expect(dk.trangThai, TrangThaiQuet.dangNhanDang);
    });
  });

  group('DieuKhienLichSuDanhThiep', () {
    DieuKhienLichSuDanhThiep dung(
      KhoBoNho bo,
      LuuAnhGiuNguyen luu,
      BoXuatVCardGia xuat,
    ) => DieuKhienLichSuDanhThiep(KhoDanhThiep(bo), luu, xuat);

    test(
      'tải: lỗi bộ nhớ → trạng thái lỗi; sửa xong tải lại → trống',
      () async {
        final bo = KhoBoNho()..hong = true;
        final ls = dung(bo, LuuAnhGiuNguyen(), BoXuatVCardGia());
        expect(ls.trangThai, TrangThaiLichSu.dangTai);
        await ls.tai();
        expect(ls.trangThai, TrangThaiLichSu.loi);
        bo.hong = false;
        await ls.tai();
        expect(ls.trangThai, TrangThaiLichSu.sanSang);
        expect(ls.trong, isTrue);
      },
    );

    test('lưu, tìm, xoá (xoá cả ảnh), xoá hết', () async {
      final luuAnh = LuuAnhGiuNguyen();
      final ls = dung(KhoBoNho(), luuAnh, BoXuatVCardGia());
      await ls.tai();
      final a = taoThe(1, 'An');
      final b = taoThe(2, 'Bình');
      await ls.luu(a);
      await ls.luu(b);
      expect(ls.ds.length, 2);
      expect(ls.tim(a.id)?.hoTen, 'An');
      expect(ls.tim('khong_co'), isNull);
      await ls.xoa(a.id);
      expect(ls.ds.single.id, b.id);
      expect(luuAnh.daXoa.length, 1);
      await ls.xoaHet();
      expect(ls.ds, isEmpty);
      expect(luuAnh.daXoa.length, 2);
    });

    test(
      'xuất một danh thiếp: tên tệp danh_thiep_*.vcf, nội dung là vCard',
      () async {
        final xuat = BoXuatVCardGia();
        final ls = dung(KhoBoNho(), LuuAnhGiuNguyen(), xuat);
        await ls.tai();
        final a = taoThe(1, 'Nguyễn Văn A');
        await ls.xuatMot(a);
        final tep = xuat.daXuat.single;
        expect(tep.tenTep, startsWith('danh_thiep_'));
        expect(tep.tenTep, endsWith('.vcf'));
        expect(tep.noiDung, contains('BEGIN:VCARD'));
        expect(tep.noiDung, contains('END:VCARD'));
      },
    );

    test(
      'xuất tất cả: trống → false và không xuất gì; có 2 thẻ → một tệp chứa 2 vCard',
      () async {
        final xuat = BoXuatVCardGia();
        final ls = dung(KhoBoNho(), LuuAnhGiuNguyen(), xuat);
        await ls.tai();
        expect(await ls.xuatTatCa(), isFalse);
        expect(xuat.daXuat, isEmpty);
        await ls.luu(taoThe(1, 'An'));
        await ls.luu(taoThe(2, 'Bình'));
        expect(await ls.xuatTatCa(), isTrue);
        final tep = xuat.daXuat.single;
        expect(tep.tenTep, 'danh_thiep_tat_ca.vcf');
        expect('BEGIN:VCARD'.allMatches(tep.noiDung).length, 2);
      },
    );

    test('lỗi chia sẻ được ném ra cho màn hình báo', () async {
      final xuat = BoXuatVCardGia()..loi = const LoiXuatVCard('hỏng');
      final ls = dung(KhoBoNho(), LuuAnhGiuNguyen(), xuat);
      await ls.tai();
      await expectLater(
        ls.xuatMot(taoThe(1, 'An')),
        throwsA(isA<LoiXuatVCard>()),
      );
    });
  });
}
