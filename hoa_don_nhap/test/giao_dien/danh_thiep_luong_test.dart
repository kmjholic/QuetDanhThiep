// Widget test cho phần Danh thiếp. Dùng kho bộ nhớ, bộ nhận dạng/QR demo, bộ xuất vCard giả.
// Không cần điện thoại, camera hay mạng. Chạy bằng `flutter test`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/app.dart';
import 'package:hoa_don_nhap/cau_hinh/cau_hinh.dart';
import 'package:hoa_don_nhap/dieu_khien/cai_dat_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_danh_thiep_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_dk.dart';
import 'package:hoa_don_nhap/du_lieu/kho_cai_dat.dart';
import 'package:hoa_don_nhap/du_lieu/kho_danh_thiep.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/kho_lich_su.dart';
import 'package:hoa_don_nhap/du_lieu/luu_anh.dart';
import 'package:hoa_don_nhap/du_lieu/xuat_vcard.dart';
import 'package:hoa_don_nhap/mo_hinh/phan_tich_danh_thiep.dart';
import 'package:hoa_don_nhap/mo_hinh/vcard.dart';
import 'package:hoa_don_nhap/ocr/bo_quet_ma.dart';
import 'package:hoa_don_nhap/ocr/hoa_don_mau.dart' show KieuMau;
import 'package:hoa_don_nhap/ocr/mau_danh_thiep.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo_danh_thiep.dart';
import 'package:hoa_don_nhap/phu_thuoc.dart';

import 'luong_ung_dung_test.dart' show ChonAnhGia;

const treo = Duration(seconds: 2);

class MoiTruong {
  final KhoBoNho kho;
  final DieuKhienLichSu hoaDon;
  final DieuKhienLichSuDanhThiep danhThiep;
  final BoXuatVCardGia xuat;

  MoiTruong(this.kho, this.hoaDon, this.danhThiep, this.xuat);
}

Future<MoiTruong> dungApp(WidgetTester tester, {KhoBoNho? kho}) async {
  // Màn hình cao để 9 ô sửa danh thiếp đều được dựng trong ListView.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final k = kho ?? KhoBoNho();
  final cd = DieuKhienCaiDat(
    KhoCaiDat(k),
    cauHinh: const CauHinh(cheDo: CheDoOcr.demo),
    coOcrThietBi: false,
  );
  await cd.datNgonNgu(NgonNgu.vi);
  final ls = DieuKhienLichSu(KhoLichSu(k), LuuAnhGiuNguyen());
  final xuat = BoXuatVCardGia();
  final ldt = DieuKhienLichSuDanhThiep(
    KhoDanhThiep(k),
    LuuAnhGiuNguyen(),
    xuat,
  );
  final demo = NhanDangDemo(treo: treo);
  final demoDt = NhanDangDemoDanhThiep(treo: treo);
  final maDemo = BoQuetMaDemo(treo: treo);
  await tester.pumpWidget(
    UngDung(
      boc: (child) => PhuThuoc(
        lichSu: ls,
        lichSuDanhThiep: ldt,
        caiDat: cd,
        chonAnh: ChonAnhGia(),
        layBoNhanDang: (_) => demo,
        layBoNhanDangDanhThiep: (_) => demoDt,
        layBoQuetMa: (_) => maDemo,
        child: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return MoiTruong(k, ls, ldt, xuat);
}

Future<void> moTabDanhThiep(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('tab_danh_thiep')));
  await tester.pumpAndSettle();
}

/// Mở bảng "thử mẫu", chọn một danh thiếp mẫu rồi chờ nhận dạng xong.
Future<void> quetMau(WidgetTester tester, DanhThiepMau mau) async {
  final nutTrong = find.byKey(const Key('nut_thu_mau_dt'));
  await tester.tap(
    nutTrong.evaluate().isNotEmpty
        ? nutTrong
        : find.byKey(const Key('nut_thu_mau_dt_appbar')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(mau.tenVi));
  await tester.pump(); // mở màn quét
  await tester.pump(const Duration(milliseconds: 350)); // chuyển trang
  await tester.pump(treo);
  await tester.pumpAndSettle();
}

/// Chờ thanh thông báo biến mất để không che nút ở đáy màn hình.
Future<void> choSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

String truong(WidgetTester tester, String khoa) =>
    tester.widget<TextField>(find.byKey(Key(khoa))).controller!.text;

DanhThiepMau get mauChuan => dsDanhThiepMau.firstWhere(
  (m) => m.kieu != KieuMau.khongCoChu && m.kieu != KieuMau.loi && !m.coQr,
);
DanhThiepMau get mauQr => dsDanhThiepMau.firstWhere((m) => m.coQr);
DanhThiepMau get mauMo =>
    dsDanhThiepMau.firstWhere((m) => m.kieu == KieuMau.khongCoChu);
DanhThiepMau get mauHong =>
    dsDanhThiepMau.firstWhere((m) => m.kieu == KieuMau.loi);

void main() {
  testWidgets(
    'khung chính vẫn mở ở tab Hóa đơn; tab Danh thiếp hiện trạng thái trống + nút thử mẫu',
    (tester) async {
      await dungApp(tester);
      expect(
        find.byKey(const Key('nut_thu_mau')),
        findsOneWidget,
      ); // màn hóa đơn cũ
      expect(find.byKey(const Key('nut_chup')), findsOneWidget);
      await moTabDanhThiep(tester);
      expect(
        find.byKey(const Key('man_hinh_lich_su_danh_thiep')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('nut_thu_mau_dt')), findsOneWidget);
      expect(find.byKey(const Key('nut_chup_dt')), findsOneWidget);
      expect(find.byKey(const Key('nut_chon_dt')), findsOneWidget);
    },
  );

  testWidgets(
    'luồng chính: mẫu chuẩn → tách trường → lưu → có trong danh sách',
    (tester) async {
      final m = await dungApp(tester);
      await moTabDanhThiep(tester);
      final mau = mauChuan;
      await quetMau(tester, mau);

      final mong = BoPhanTichDanhThiep.phanTich(mau.vanBan);
      expect(mong.hoTen, isNotEmpty);
      expect(truong(tester, 'o_ho_ten'), mong.hoTen);
      expect(truong(tester, 'o_dien_thoai'), mong.dienThoai);
      expect(truong(tester, 'o_email'), mong.email);

      await tester.tap(find.byKey(const Key('nut_luu_danh_thiep')));
      await tester.pumpAndSettle();
      expect(m.danhThiep.ds.single.hoTen, mong.hoTen);
      expect(find.byKey(Key('dt_${m.danhThiep.ds.single.id}')), findsOneWidget);
      expect(m.hoaDon.ds, isEmpty); // không lẫn vào lịch sử hóa đơn
    },
  );

  testWidgets('mẫu có QR: thông tin từ QR được ưu tiên rồi mới tới OCR', (
    tester,
  ) async {
    await dungApp(tester);
    await moTabDanhThiep(tester);
    final mau = mauQr;
    await quetMau(tester, mau);
    final maDau = mau.noiDungQr.firstWhere(
      (s) => DocVCard.nhanDang(s) && !DocVCard.doc(s).rong,
    );
    final mong = DocVCard.doc(
      maDau,
    ).boSung(BoPhanTichDanhThiep.phanTich(mau.vanBan));
    expect(mong.hoTen, isNotEmpty);
    expect(truong(tester, 'o_ho_ten'), mong.hoTen);
    expect(truong(tester, 'o_email'), mong.email);
  });

  testWidgets(
    'ảnh mờ: "không có chữ" → Nhập tay; Lưu chỉ bật khi có nội dung',
    (tester) async {
      await dungApp(tester);
      await moTabDanhThiep(tester);
      await quetMau(tester, mauMo);
      await tester.tap(find.byKey(const Key('nut_nhap_tay')));
      await tester.pumpAndSettle();
      FilledButton nutLuu() => tester.widget<FilledButton>(
        find.byKey(const Key('nut_luu_danh_thiep')),
      );
      expect(nutLuu().onPressed, isNull);
      await tester.enterText(find.byKey(const Key('o_ho_ten')), 'Nguyễn Văn A');
      await tester.pump();
      expect(nutLuu().onPressed, isNotNull);
    },
  );

  testWidgets('tệp ảnh hỏng: có Thử lại và Chọn ảnh khác (quay về danh sách)', (
    tester,
  ) async {
    await dungApp(tester);
    await moTabDanhThiep(tester);
    await quetMau(tester, mauHong);
    expect(find.text('Thử lại'), findsOneWidget);
    await tester.tap(find.text('Chọn ảnh khác'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nut_thu_mau_dt')), findsOneWidget);
  });

  testWidgets('chi tiết: sửa ghi chú, lưu, xuất vCard, xoá có xác nhận', (
    tester,
  ) async {
    final m = await dungApp(tester);
    await moTabDanhThiep(tester);
    await quetMau(tester, mauChuan);
    await tester.tap(find.byKey(const Key('nut_luu_danh_thiep')));
    await tester.pumpAndSettle();
    await choSnackBar(tester);

    final id = m.danhThiep.ds.single.id;
    await tester.tap(find.byKey(Key('dt_$id')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('o_ghi_chu')), 'Gặp ở hội chợ');
    await tester.pump();
    await tester.tap(find.byKey(const Key('nut_luu_thay_doi_dt')));
    await tester.pumpAndSettle();
    expect(m.danhThiep.ds.single.ghiChu, 'Gặp ở hội chợ');
    await choSnackBar(tester);

    await tester.tap(find.byKey(const Key('nut_xuat_vcard')));
    await tester.pumpAndSettle();
    expect(m.xuat.daXuat.single.noiDung, contains('BEGIN:VCARD'));
    await choSnackBar(tester);

    await tester.tap(find.byKey(const Key('nut_xoa_dt')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xoá'));
    await tester.pumpAndSettle();
    expect(m.danhThiep.ds, isEmpty);
    expect(find.byKey(const Key('nut_thu_mau_dt')), findsOneWidget);
  });

  testWidgets('cài đặt: xoá toàn bộ danh thiếp, hóa đơn không bị ảnh hưởng', (
    tester,
  ) async {
    final m = await dungApp(tester);
    await moTabDanhThiep(tester);
    await quetMau(tester, mauChuan);
    await tester.tap(find.byKey(const Key('nut_luu_danh_thiep')));
    await tester.pumpAndSettle();
    await choSnackBar(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ListTile>(find.byKey(const Key('nut_xoa_het'))).enabled,
      isFalse,
    ); // chưa có hóa đơn
    expect(
      tester.widget<ListTile>(find.byKey(const Key('nut_xoa_het_dt'))).enabled,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('nut_xoa_het_dt')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xoá'));
    await tester.pumpAndSettle();
    expect(m.danhThiep.ds, isEmpty);
    expect(
      tester.widget<ListTile>(find.byKey(const Key('nut_xoa_het_dt'))).enabled,
      isFalse,
    );
  });

  testWidgets('cài đặt tự tải danh thiếp dù chưa mở tab Danh thiếp', (
    tester,
  ) async {
    final truoc = await dungApp(tester);
    await moTabDanhThiep(tester);
    await quetMau(tester, mauChuan);
    await tester.tap(find.byKey(const Key('nut_luu_danh_thiep')));
    await tester.pumpAndSettle();
    await choSnackBar(tester);

    // Mở lại app với cùng kho; vào thẳng Cài đặt từ tab Hóa đơn.
    final sau = await dungApp(tester, kho: truoc.kho);
    expect(sau.danhThiep.ds, isEmpty); // chưa tải vì tab lười
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(sau.danhThiep.ds.length, 1);
    expect(
      tester.widget<ListTile>(find.byKey(const Key('nut_xoa_het_dt'))).enabled,
      isTrue,
    );
  });
}
