import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'cau_hinh/cau_hinh.dart';
import 'dieu_khien/cai_dat_dk.dart';
import 'dieu_khien/lich_su_danh_thiep_dk.dart';
import 'dieu_khien/lich_su_dk.dart';
import 'du_lieu/kho_cai_dat.dart';
import 'du_lieu/kho_danh_thiep.dart';
import 'du_lieu/kho_lich_su.dart';
import 'du_lieu/luu_anh.dart';
import 'du_lieu/xuat_vcard.dart';
import 'nen_tang/nen_tang.dart';
import 'nen_tang/ocr_mlkit.dart';
import 'nen_tang/quet_ma_mlkit.dart';
import 'nen_tang/xuat_vcard_chia_se.dart';
import 'ocr/bo_nhan_dang.dart';
import 'ocr/bo_quet_ma.dart';
import 'ocr/nhan_dang_demo.dart';
import 'ocr/nhan_dang_demo_danh_thiep.dart';
import 'phu_thuoc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cauHinh = CauHinh.tuMoiTruong();
  final kho = KhoPrefs();
  final caiDat = DieuKhienCaiDat(
    KhoCaiDat(kho),
    cauHinh: cauHinh,
    coOcrThietBi: coOcrThietBi,
  );
  await caiDat.tai(); // đọc ngôn ngữ trước khung hình đầu để không bị nháy chữ
  final lichSu = DieuKhienLichSu(
    KhoLichSu(kho),
    kIsWeb ? LuuAnhGiuNguyen() : LuuAnhTep(),
  );

  // Danh thiếp: kho riêng (khoá danh_thiep_v1), ảnh vào thư mục danh_thiep/, xuất .vcf qua bảng chia sẻ.
  final lichSuDanhThiep = DieuKhienLichSuDanhThiep(
    KhoDanhThiep(kho),
    kIsWeb ? LuuAnhGiuNguyen() : LuuAnhTep(tenThuMuc: 'danh_thiep'),
    kIsWeb ? BoXuatVCardGia() : BoXuatVCardChiaSe(),
  );

  final demo = NhanDangDemo();
  final demoDanhThiep = NhanDangDemoDanhThiep();
  final quetMaDemo = BoQuetMaDemo();
  NhanDangMlKit?
  mlKit; // tạo khi cần lần đầu (nạp mô hình ML Kit mất một chút thời gian)
  BoQuetMaMlKit? quetMaMlKit;
  BoNhanDang layMlKit() =>
      mlKit ??= NhanDangMlKit(tepTuAsset: chepAssetRaTepTam);
  BoNhanDang layBo(bool dungDemo) =>
      dungDemo || !coOcrThietBi ? demo : layMlKit();
  BoNhanDang layBoDanhThiep(bool dungDemo) =>
      dungDemo || !coOcrThietBi ? demoDanhThiep : layMlKit();
  BoQuetMa layBoQuetMa(bool dungDemo) => dungDemo || !coOcrThietBi
      ? quetMaDemo
      : (quetMaMlKit ??= BoQuetMaMlKit());

  runApp(
    UngDung(
      boc: (child) => PhuThuoc(
        lichSu: lichSu,
        caiDat: caiDat,
        chonAnh: ChonAnh(),
        layBoNhanDang: layBo,
        lichSuDanhThiep: lichSuDanhThiep,
        layBoNhanDangDanhThiep: layBoDanhThiep,
        layBoQuetMa: layBoQuetMa,
        child: child,
      ),
    ),
  );
}
