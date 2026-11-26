import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/app.dart';
import 'package:hoa_don_nhap/cau_hinh/cau_hinh.dart';
import 'package:hoa_don_nhap/dieu_khien/cai_dat_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_dk.dart';
import 'package:hoa_don_nhap/du_lieu/bo_chon_anh.dart';
import 'package:hoa_don_nhap/du_lieu/kho_cai_dat.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/kho_lich_su.dart';
import 'package:hoa_don_nhap/du_lieu/luu_anh.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo.dart';
import 'package:hoa_don_nhap/phu_thuoc.dart';

class _ChonAnhGia implements BoChonAnh {
  @override
  Future<AnhHoaDon?> chon(NguonAnh nguon) async => null;
  @override
  Future<AnhHoaDon?> layAnhBiGianDoan() async => null;
}

void main() {
  testWidgets('khung hai tab: chuyển qua lại, mỗi tab giữ trạng thái riêng', (
    tester,
  ) async {
    // flutter_test mặc định locale 'en' → ép tiếng Việt để khớp chuỗi.
    tester.platformDispatcher.localesTestValue = const [Locale('vi')];
    tester.platformDispatcher.localeTestValue = const Locale('vi');
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    final k = KhoBoNho();
    final cd = DieuKhienCaiDat(
      KhoCaiDat(k),
      cauHinh: const CauHinh(cheDo: CheDoOcr.demo),
      coOcrThietBi: false,
    );
    await tester.pumpWidget(
      UngDung(
        boc: (child) => PhuThuoc(
          lichSu: DieuKhienLichSu(KhoLichSu(k), LuuAnhGiuNguyen()),
          caiDat: cd,
          chonAnh: _ChonAnhGia(),
          layBoNhanDang: (_) => NhanDangDemo(
            treo: Duration.zero,
          ), // KHÔNG truyền tham số danh thiếp
          child: child,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Chưa có hóa đơn nào'), findsOneWidget);
    expect(find.text('Hóa đơn'), findsOneWidget); // nhãn tab
    expect(find.text('Danh thiếp'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab_danh_thiep')));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có danh thiếp nào'), findsOneWidget);
    expect(find.text('Chưa có hóa đơn nào'), findsNothing); // tab kia đang ẩn

    await tester.tap(find.byKey(const Key('tab_hoa_don')));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có hóa đơn nào'), findsOneWidget);
    expect(find.text('Chưa có danh thiếp nào'), findsNothing);
  });
}
