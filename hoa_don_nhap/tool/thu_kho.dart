import 'package:hoa_don_nhap/du_lieu/kho_danh_thiep.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/mo_hinh/danh_thiep.dart';

Future<void> main() async {
  final bo = KhoBoNho();
  final kho = KhoDanhThiep(bo);
  await kho.luu(DanhThiep(id: 'a', thoiGian: DateTime(2026, 1, 1), hoTen: 'A'));
  await kho.luu(DanhThiep(id: 'b', thoiGian: DateTime(2026, 2, 1), hoTen: 'B'));
  print((await kho.docTatCa()).map((d) => d.id).toList()); // [b, a]
  await kho.luu(
    DanhThiep(id: 'a', thoiGian: DateTime(2026, 1, 1), hoTen: 'A2'),
  );
  print((await kho.docTatCa()).map((d) => d.hoTen).toList()); // [B, A2]
  bo.duLieu[KhoDanhThiep.khoa] = '[1, {"id": "z"}, {"hoTen": "thiếu mã"}]';
  print((await kho.docTatCa()).map((d) => d.id).toList()); // [z]
  await kho.xoaHet();
  print((await kho.docTatCa()).length); // 0
}
