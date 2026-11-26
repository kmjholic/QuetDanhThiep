import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/cau_hinh/cau_hinh.dart';
import 'package:hoa_don_nhap/dieu_khien/cai_dat_dk.dart';
import 'package:hoa_don_nhap/dieu_khien/lich_su_dk.dart';
import 'package:hoa_don_nhap/du_lieu/bo_chon_anh.dart';
import 'package:hoa_don_nhap/du_lieu/kho_cai_dat.dart';
import 'package:hoa_don_nhap/du_lieu/kho_khoa_gia_tri.dart';
import 'package:hoa_don_nhap/du_lieu/kho_lich_su.dart';
import 'package:hoa_don_nhap/du_lieu/luu_anh.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/ocr/bo_quet_ma.dart';
import 'package:hoa_don_nhap/ocr/nhan_dang_demo.dart';
import 'package:hoa_don_nhap/phu_thuoc.dart';

class _ChonAnhGia implements BoChonAnh {
  @override
  Future<AnhHoaDon?> chon(NguonAnh nguon) async => null;

  @override
  Future<AnhHoaDon?> layAnhBiGianDoan() async => null;
}

void main() {
  PhuThuoc dung({bool kemDanhThiep = false}) {
    final kho = KhoBoNho();
    return PhuThuoc(
      lichSu: DieuKhienLichSu(KhoLichSu(kho), LuuAnhGiuNguyen()),
      caiDat: DieuKhienCaiDat(
        KhoCaiDat(kho),
        cauHinh: const CauHinh(),
        coOcrThietBi: false,
      ),
      chonAnh: _ChonAnhGia(),
      layBoNhanDang: (_) => NhanDangDemo(treo: Duration.zero),
      child: const SizedBox(),
    );
  }

  test('dựng PhuThuoc KHÔNG có tham số danh thiếp (như 55 test cũ)', () {
    final p = dung();
    expect(p.lichSuDanhThiep.trangThai, isNotNull);
    expect(p.layBoNhanDangDanhThiep(true).laDemo, isTrue);
    expect(p.layBoQuetMa(true), isA<BoQuetMaRong>());
  });

  test('lịch sử danh thiếp mặc định tải được và trống', () async {
    final p = dung();
    await p.lichSuDanhThiep.tai();
    expect(p.lichSuDanhThiep.trong, isTrue);
  });
}
