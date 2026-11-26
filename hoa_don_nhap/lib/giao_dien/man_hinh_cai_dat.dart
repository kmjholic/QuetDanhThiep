import 'package:flutter/material.dart';

import '../dieu_khien/lich_su_dk.dart';
import '../du_lieu/kho_cai_dat.dart';
import '../ngon_ngu/chuoi.dart';
import '../phu_thuoc.dart';
import 'thanh_phan/nghe_thay_doi.dart';
import 'thanh_phan/trinh_sua.dart';

class ManHinhCaiDat extends StatefulWidget {
  const ManHinhCaiDat({super.key});

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  @override
  void initState() {
    super.initState();
    // Tab Danh thiếp dựng lười: nếu chưa ai tải danh sách thì tải ở đây để số lượng/nút xoá đúng.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ls = PhuThuoc.of(context).lichSuDanhThiep;
      if (ls.trangThai == TrangThaiLichSu.dangTai) ls.tai();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pt = PhuThuoc.of(context);
    return NgheThayDoi(
      nguon: [pt.caiDat, pt.lichSu, pt.lichSuDanhThiep],
      builder: (context) {
        final c = Chuoi.of(context);
        final cd = pt.caiDat;
        final theme = Theme.of(context);
        Widget nhom(String s) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            s,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        );
        final soHoaDon = pt.lichSu.ds.length;
        final soDanhThiep = pt.lichSuDanhThiep.ds.length;
        return Scaffold(
          appBar: AppBar(title: Text(c.t(K.caiDat))),
          body: ListView(
            children: [
              nhom(c.t(K.ngonNgu)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<NgonNgu>(
                  key: const Key('chon_ngon_ngu'),
                  segments: [
                    ButtonSegment(
                      value: NgonNgu.heThong,
                      label: Text(c.t(K.theoMay)),
                    ),
                    const ButtonSegment(
                      value: NgonNgu.vi,
                      label: Text('Tiếng Việt'),
                    ),
                    const ButtonSegment(
                      value: NgonNgu.en,
                      label: Text('English'),
                    ),
                  ],
                  selected: {cd.ngonNgu},
                  onSelectionChanged: (s) => cd.datNgonNgu(s.first),
                ),
              ),
              nhom(c.t(K.nhanDang)),
              SwitchListTile(
                key: const Key('cong_tac_demo'),
                title: Text(c.t(K.cheDoDemo)),
                subtitle: Text(
                  cd.choDoiCheDo
                      ? c.t(K.cheDoDemoMoTa)
                      : (cd.coOcrThietBi
                            ? c.t(K.demoTheoCauHinh)
                            : c.t(K.demoBatBuoc)),
                ),
                value: cd.dungDemo,
                onChanged: cd.choDoiCheDo ? cd.datDemo : null,
              ),
              ListTile(
                leading: Icon(
                  cd.dungDemo ? Icons.science_outlined : Icons.memory,
                ),
                title: Text(
                  cd.dungDemo ? c.t(K.dangDungDemo) : c.t(K.dangDungThietBi),
                ),
              ),
              nhom(c.t(K.duLieu)),
              ListTile(
                key: const Key('nut_xoa_het'),
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: soHoaDon == 0 ? null : theme.colorScheme.error,
                ),
                title: Text(c.t(K.xoaHet)),
                subtitle: Text(c.t(K.soHoaDon, {'n': '$soHoaDon'})),
                enabled: soHoaDon > 0,
                onTap: () async {
                  final dongY = await hoiXacNhan(
                    context,
                    tieuDe: c.t(K.xoaHet),
                    moTa: c.t(K.xoaHetHoi, {'n': '$soHoaDon'}),
                    nutDongY: c.t(K.xoa),
                    nguyHiem: true,
                  );
                  if (!dongY) return;
                  try {
                    await pt.lichSu.xoaHet();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(c.t(K.daXoaHet))));
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(c.t(K.loiXoa))));
                    }
                  }
                },
              ),
              ListTile(
                key: const Key('nut_xoa_het_dt'),
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: soDanhThiep == 0 ? null : theme.colorScheme.error,
                ),
                title: Text(c.t(K.dtXoaHet)),
                subtitle: Text(c.t(K.dtSoDanhThiep, {'n': '$soDanhThiep'})),
                enabled: soDanhThiep > 0,
                onTap: () async {
                  final dongY = await hoiXacNhan(
                    context,
                    tieuDe: c.t(K.dtXoaHet),
                    moTa: c.t(K.dtXoaHetHoi, {'n': '$soDanhThiep'}),
                    nutDongY: c.t(K.xoa),
                    nguyHiem: true,
                  );
                  if (!dongY) return;
                  try {
                    await pt.lichSuDanhThiep.xoaHet();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(c.t(K.dtDaXoaHet))),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(c.t(K.loiXoa))));
                    }
                  }
                },
              ),
              nhom(c.t(K.gioiThieu)),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(c.t(K.quyenRiengTu)),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(c.t(K.tenApp)),
                subtitle: Text(c.t(K.phienBan, {'v': phienBanApp})),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
