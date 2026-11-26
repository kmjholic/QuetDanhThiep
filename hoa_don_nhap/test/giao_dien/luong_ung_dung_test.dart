// Kiểm thử giao diện (widget test) — chạy bằng `flutter test` trên máy có Flutter SDK.
// Dùng kho trong bộ nhớ, bộ nhận dạng demo và bộ chọn ảnh giả: không cần điện thoại, camera hay mạng.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:hoa_don_nhap/ocr/hoa_don_mau.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo.dart';
import 'package:hoa_don_nhap/phu_thuoc.dart';

class ChonAnhGia implements BoChonAnh {
  AnhHoaDon? tra;
  LoiChonAnh? loi;

  @override
  Future<AnhHoaDon?> chon(NguonAnh nguon) async {
    if (loi != null) throw loi!;
    return tra;
  }

  @override
  Future<AnhHoaDon?> layAnhBiGianDoan() async => null;
}

const treoDemo = Duration(seconds: 2);

Future<DieuKhienLichSu> dungApp(
  WidgetTester tester, {
  KhoBoNho? kho,
  ChonAnhGia? chonAnh,
  NgonNgu ngonNgu = NgonNgu.vi,
}) async {
  final k = kho ?? KhoBoNho();
  final cd = DieuKhienCaiDat(KhoCaiDat(k), cauHinh: const CauHinh(cheDo: CheDoOcr.demo), coOcrThietBi: false);
  await cd.datNgonNgu(ngonNgu);
  final ls = DieuKhienLichSu(KhoLichSu(k), LuuAnhGiuNguyen());
  final demo = NhanDangDemo(treo: treoDemo);
  await tester.pumpWidget(UngDung(
    boc: (child) => PhuThuoc(
      lichSu: ls,
      caiDat: cd,
      chonAnh: chonAnh ?? ChonAnhGia(),
      layBoNhanDang: (_) => demo,
      child: child,
    ),
  ));
  await tester.pump(); // khung hình đầu: đang tải
  await tester.pump(); // lịch sử đã tải xong
  return ls;
}

/// Chọn một hóa đơn mẫu trong bảng "Chọn hóa đơn mẫu" rồi chờ nhận dạng xong.
Future<void> quetMau(WidgetTester tester, HoaDonMau mau) async {
  await tester.tap(find.byKey(const Key('nut_thu_mau')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(mau.tenVi));
  await tester.pump(); // mở màn hình quét
  await tester.pump(const Duration(milliseconds: 350)); // chuyển trang
  expect(find.text('Đang nhận dạng chữ…'), findsOneWidget);
  await tester.pump(treoDemo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('chưa có dữ liệu: hiện hướng dẫn, nút Chụp ảnh / Chọn ảnh, băng chế độ demo', (tester) async {
    await dungApp(tester);
    expect(find.text('Chưa có hóa đơn nào'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('Chọn ảnh'), findsOneWidget);
    expect(find.textContaining('Chế độ demo'), findsOneWidget);
  });

  testWidgets('luồng chính: hóa đơn mẫu → nhận dạng → sửa → sao chép → lưu → có trong lịch sử', (tester) async {
    String? daChep;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') daChep = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    final ls = await dungApp(tester);
    await quetMau(tester, dsHoaDonMau.first);

    final tieuDe = tester.widget<TextField>(find.byKey(const Key('o_tieu_de')));
    expect(tieuDe.controller!.text, 'ĐẠI LÝ NƯỚC GIẢI KHÁT MINH TÂM');
    expect(find.text('Văn bản dưới đây là dữ liệu mẫu của chế độ demo.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('o_tieu_de')), 'Đại lý Minh Tâm');
    await tester.tap(find.byKey(const Key('nut_sao_chep')));
    await tester.pump();
    expect(daChep, startsWith('Đại lý Minh Tâm\n\nĐẠI LÝ NƯỚC GIẢI KHÁT'));
    expect(find.text('Đã sao chép vào bộ nhớ tạm'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nut_luu')));
    await tester.pumpAndSettle();
    expect(ls.ds.single.tieuDe, 'Đại lý Minh Tâm');
    expect(find.text('Đại lý Minh Tâm'), findsOneWidget); // thẻ trong danh sách
    expect(find.text('Đã lưu vào lịch sử'), findsOneWidget);
  });

  testWidgets('ảnh mờ: "không tìm thấy chữ" → Nhập tay; nút Lưu chỉ bật khi có nội dung', (tester) async {
    await dungApp(tester);
    await quetMau(tester, dsHoaDonMau.firstWhere((m) => m.kieu == KieuMau.khongCoChu));
    expect(find.text('Không tìm thấy chữ trong ảnh'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nut_nhap_tay')));
    await tester.pumpAndSettle();
    FilledButton nutLuu() => tester.widget<FilledButton>(find.byKey(const Key('nut_luu')));
    expect(nutLuu().onPressed, isNull);
    await tester.enterText(find.byKey(const Key('o_noi_dung')), 'Mì gói 10 thùng');
    await tester.pump();
    expect(nutLuu().onPressed, isNotNull);
  });

  testWidgets('tệp ảnh hỏng: trạng thái lỗi có nút Thử lại và Chọn ảnh khác', (tester) async {
    await dungApp(tester);
    await quetMau(tester, dsHoaDonMau.firstWhere((m) => m.kieu == KieuMau.loi));
    expect(find.text('Không nhận dạng được'), findsOneWidget);
    expect(find.textContaining('Ảnh có thể bị hỏng'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    await tester.tap(find.text('Chọn ảnh khác'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có hóa đơn nào'), findsOneWidget);
  });

  testWidgets('lỗi đọc lịch sử: hiện lỗi + Thử lại, sửa xong thì về trạng thái trống', (tester) async {
    final kho = KhoBoNho()..hong = true;
    await dungApp(tester, kho: kho);
    expect(find.text('Không đọc được lịch sử trên máy.'), findsOneWidget);
    kho.hong = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Chưa có hóa đơn nào'), findsOneWidget);
  });

  testWidgets('chưa cấp quyền camera: báo rõ cách khắc phục', (tester) async {
    await dungApp(tester, chonAnh: ChonAnhGia()..loi = const LoiChonAnh(LoaiLoiChonAnh.khongCoQuyen));
    await tester.tap(find.byKey(const Key('nut_chup')));
    await tester.pumpAndSettle();
    expect(find.textContaining('chưa được cấp quyền'), findsOneWidget);
  });

  testWidgets('chi tiết: sửa, lưu thay đổi, xoá có xác nhận', (tester) async {
    final h = HoaDon(
      ma: 'm1',
      tieuDe: 'Đại lý A',
      noiDung: 'Nước suối   5   480.000',
      taoLuc: DateTime(2026, 11, 3, 8),
      suaLuc: DateTime(2026, 11, 3, 8),
      nguon: NguonAnh.mau,
      anh: AnhHoaDon.asset(dsHoaDonMau.first.asset),
    );
    final kho = KhoBoNho({KhoLichSu.khoa: jsonEncode([h.toJson()])});
    final ls = await dungApp(tester, kho: kho);
    await tester.tap(find.text('Đại lý A'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết hóa đơn'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('o_noi_dung')), 'Nước suối   6   576.000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('nut_luu_thay_doi')));
    await tester.pumpAndSettle();
    expect(ls.ds.single.noiDung, 'Nước suối   6   576.000');

    await tester.tap(find.byKey(const Key('nut_xoa')));
    await tester.pumpAndSettle();
    expect(find.text('Xoá hóa đơn này?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Xoá'));
    await tester.pumpAndSettle();
    expect(ls.ds, isEmpty);
    expect(find.text('Đã xoá hóa đơn'), findsOneWidget);
    expect(find.text('Chưa có hóa đơn nào'), findsOneWidget);
  });

  testWidgets('giao diện tiếng Anh', (tester) async {
    await dungApp(tester, ngonNgu: NgonNgu.en);
    expect(find.text('No invoices yet'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose photo'), findsOneWidget);
  });
}
