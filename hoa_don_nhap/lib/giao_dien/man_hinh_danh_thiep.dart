import 'package:flutter/material.dart';

import '../dieu_khien/lich_su_dk.dart' show TrangThaiLichSu;
import '../ngon_ngu/chuoi.dart';
import '../phu_thuoc.dart';
import 'man_hinh_cai_dat.dart';
import 'thanh_phan/nghe_thay_doi.dart';
import 'thanh_phan/trang_thai.dart';

/// TẠM (C3): khung tab Danh thiếp. C5 thay bằng danh sách thật + nút quét + xuất vCard.
class ManHinhDanhThiep extends StatefulWidget {
  const ManHinhDanhThiep({super.key});

  @override
  State<ManHinhDanhThiep> createState() => _ManHinhDanhThiepState();
}

class _ManHinhDanhThiepState extends State<ManHinhDanhThiep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) PhuThuoc.of(context).lichSuDanhThiep.tai();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pt = PhuThuoc.of(context);
    final c = Chuoi.of(context);
    return NgheThayDoi(
      nguon: [pt.lichSuDanhThiep, pt.caiDat],
      builder: (context) {
        final ls = pt.lichSuDanhThiep;
        return Scaffold(
          appBar: AppBar(
            title: Text(c.t(K.dtLichSu)),
            actions: [
              IconButton(
                tooltip: c.t(K.caiDat),
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManHinhCaiDat(),
                  ),
                ),
              ),
            ],
          ),
          body: switch (ls.trangThai) {
            TrangThaiLichSu.dangTai => TrangThaiDangTai(
              thongDiep: c.t(K.dangTaiLichSu),
            ),
            TrangThaiLichSu.loi => Center(
              child: SingleChildScrollView(
                child: KhungTrangThai(
                  icon: Icons.error_outline,
                  laLoi: true,
                  tieuDe: c.t(K.loiTaiLichSu),
                  moTa: '${ls.loi}',
                  hanhDong: [
                    FilledButton.icon(
                      onPressed: ls.tai,
                      icon: const Icon(Icons.refresh),
                      label: Text(c.t(K.thuLai)),
                    ),
                  ],
                ),
              ),
            ),
            TrangThaiLichSu.sanSang => Center(
              child: SingleChildScrollView(
                child: KhungTrangThai(
                  icon: Icons.contacts_outlined,
                  tieuDe: ls.ds.isEmpty
                      ? c.t(K.dtTrongTieuDe)
                      : c.t(K.dtSoDanhThiep, {'n': '${ls.ds.length}'}),
                  moTa: ls.ds.isEmpty ? c.t(K.dtTrongMoTa) : '',
                ),
              ),
            ),
          },
        );
      },
    );
  }
}
