import 'package:flutter/widgets.dart';

import 'dieu_khien/cai_dat_dk.dart';
import 'dieu_khien/lich_su_danh_thiep_dk.dart';
import 'dieu_khien/lich_su_dk.dart';
import 'du_lieu/bo_chon_anh.dart';
import 'du_lieu/kho_danh_thiep.dart';
import 'du_lieu/kho_khoa_gia_tri.dart';
import 'du_lieu/luu_anh.dart';
import 'du_lieu/xuat_vcard.dart';
import 'ocr/bo_nhan_dang.dart';
import 'ocr/bo_quet_ma.dart';
import 'ocr/nhan_dang_demo_danh_thiep.dart';

const phienBanApp = '1.0.0';

/// Các đối tượng dùng chung, đặt trên cùng cây widget. Màn hình lấy bằng `PhuThuoc.of(context)`.
/// Kiểm thử widget thay bằng bản giả (kho trong bộ nhớ, bộ nhận dạng demo, bộ chọn ảnh giả).
///
/// Các tham số của phần DANH THIẾP đều TUỲ CHỌN và có mặc định an toàn (kho bộ nhớ, demo, không quét mã)
/// để các test và nơi dựng [PhuThuoc] có từ trước không phải sửa.
class PhuThuoc extends InheritedWidget {
  final DieuKhienLichSu lichSu;
  final DieuKhienCaiDat caiDat;
  final BoChonAnh chonAnh;

  /// Trả về bộ nhận dạng theo chế độ đang dùng (demo hoặc ML Kit).
  final BoNhanDang Function(bool dungDemo) layBoNhanDang;

  /// Lịch sử danh thiếp (tách biệt với [lichSu] của hóa đơn).
  final DieuKhienLichSuDanhThiep lichSuDanhThiep;

  /// Bộ nhận dạng chữ cho danh thiếp: demo dùng mẫu danh thiếp, không demo dùng ML Kit.
  final BoNhanDang Function(bool dungDemo) layBoNhanDangDanhThiep;

  /// Bộ quét mã QR theo chế độ đang dùng (demo, ML Kit, hoặc rỗng).
  final BoQuetMa Function(bool dungDemo) layBoQuetMa;

  PhuThuoc({
    super.key,
    required this.lichSu,
    required this.caiDat,
    required this.chonAnh,
    required this.layBoNhanDang,
    DieuKhienLichSuDanhThiep? lichSuDanhThiep,
    BoNhanDang Function(bool dungDemo)? layBoNhanDangDanhThiep,
    BoQuetMa Function(bool dungDemo)? layBoQuetMa,
    required super.child,
  }) : lichSuDanhThiep =
           lichSuDanhThiep ??
           DieuKhienLichSuDanhThiep(
             KhoDanhThiep(KhoBoNho()),
             LuuAnhGiuNguyen(),
             BoXuatVCardGia(),
           ),
       layBoNhanDangDanhThiep =
           layBoNhanDangDanhThiep ?? ((_) => NhanDangDemoDanhThiep()),
       layBoQuetMa = layBoQuetMa ?? ((_) => const BoQuetMaRong());

  static PhuThuoc of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PhuThuoc>()!;

  @override
  bool updateShouldNotify(PhuThuoc oldWidget) => false;
}
