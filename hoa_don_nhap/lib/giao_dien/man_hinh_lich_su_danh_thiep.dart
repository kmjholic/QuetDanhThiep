import 'package:flutter/material.dart';

import '../dieu_khien/lich_su_dk.dart';
import '../du_lieu/bo_chon_anh.dart';
import '../mo_hinh/danh_thiep.dart';
import '../mo_hinh/hoa_don.dart';
import '../ngon_ngu/chuoi.dart';
import '../ocr/mau_danh_thiep.dart';
import '../phu_thuoc.dart';
import 'man_hinh_cai_dat.dart';
import 'man_hinh_chi_tiet_danh_thiep.dart';
import 'man_hinh_quet_danh_thiep.dart';
import 'thanh_phan/anh_hoa_don.dart';
import 'thanh_phan/nghe_thay_doi.dart';
import 'thanh_phan/trang_thai.dart';
import 'thanh_phan/trinh_sua.dart';

/// Giải mã ảnh đã lưu của một danh thiếp; null nếu không có ảnh hoặc chuỗi hỏng.
AnhHoaDon? anhCuaDanhThiep(DanhThiep d) {
  final s = d.duongDanAnh;
  if (s == null || s.isEmpty) return null;
  try {
    return AnhHoaDon.giaiMa(s);
  } catch (_) {
    return null;
  }
}

/// Tab "Danh thiếp": lịch sử danh thiếp + nút Chụp ảnh / Chọn ảnh + xuất tất cả vCard.
class ManHinhLichSuDanhThiep extends StatefulWidget {
  const ManHinhLichSuDanhThiep({super.key});

  @override
  State<ManHinhLichSuDanhThiep> createState() => _ManHinhLichSuDanhThiepState();
}

class _ManHinhLichSuDanhThiepState extends State<ManHinhLichSuDanhThiep> {
  bool _dangMoAnh = false;

  @override
  void initState() {
    super.initState();
    // Tab dựng lười nên chỉ tải khi người dùng mở tab này.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) PhuThuoc.of(context).lichSuDanhThiep.tai();
    });
  }

  void _bao(String s) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(s)));

  Future<void> _layAnh(NguonAnh nguon) async {
    if (_dangMoAnh) return;
    final c = Chuoi.of(context);
    setState(() => _dangMoAnh = true);
    try {
      final anh = await PhuThuoc.of(context).chonAnh.chon(nguon);
      if (anh != null && mounted) await _moQuet(anh, nguon);
    } on LoiChonAnh catch (e) {
      _bao(switch (e.loai) {
        LoaiLoiChonAnh.khongCoQuyen => c.t(K.loiQuyen),
        LoaiLoiChonAnh.khongCoCamera => c.t(K.loiKhongCoCamera),
        LoaiLoiChonAnh.khac => c.t(K.loiChonAnh),
      });
    } finally {
      if (mounted) setState(() => _dangMoAnh = false);
    }
  }

  Future<void> _chonMau() async {
    final c = Chuoi.of(context);
    final mau = await showModalBottomSheet<DanhThiepMau>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(c.t(K.dtChonMauTieuDe)),
              subtitle: Text(c.t(K.dtChonMauMoTa)),
            ),
            for (final m in dsDanhThiepMau)
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 52,
                    height: 40,
                    child: AnhHoaDonWidget(
                      anh: AnhHoaDon.asset(m.asset),
                      giaiMaRong: 120,
                    ),
                  ),
                ),
                title: Text(c.laTiengAnh ? m.tenEn : m.tenVi),
                onTap: () => Navigator.pop(ctx, m),
              ),
          ],
        ),
      ),
    );
    if (mau != null && mounted) {
      await _moQuet(AnhHoaDon.asset(mau.asset), NguonAnh.mau);
    }
  }

  Future<void> _moQuet(AnhHoaDon anh, NguonAnh nguon) async {
    final c = Chuoi.of(context);
    final daLuu = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManHinhQuetDanhThiep(anh: anh, nguon: nguon),
      ),
    );
    if (daLuu == true && mounted) _bao(c.t(K.dtDaLuu));
  }

  Future<void> _moChiTiet(DanhThiep d) async {
    final c = Chuoi.of(context);
    final kq = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ManHinhChiTietDanhThiep(id: d.id)),
    );
    if (kq == ManHinhChiTietDanhThiep.daXoa && mounted) _bao(c.t(K.dtDaXoa));
  }

  Future<void> _xuatTatCa() async {
    final c = Chuoi.of(context);
    try {
      final coXuat = await PhuThuoc.of(context).lichSuDanhThiep.xuatTatCa();
      if (!coXuat && mounted) _bao(c.t(K.dtXuatTrong));
    } catch (_) {
      if (mounted) _bao(c.t(K.dtLoiXuat));
    }
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
          key: const Key('man_hinh_lich_su_danh_thiep'),
          appBar: AppBar(
            title: Text(c.t(K.dtLichSu)),
            actions: [
              IconButton(
                key: const Key('nut_xuat_tat_ca'),
                tooltip: c.t(K.dtXuatTatCa),
                icon: const Icon(Icons.ios_share),
                onPressed: ls.ds.isEmpty ? null : _xuatTatCa,
              ),
              IconButton(
                key: const Key('nut_thu_mau_dt_appbar'),
                tooltip: c.t(K.dtThuMau),
                icon: const Icon(Icons.contacts_outlined),
                onPressed: _dangMoAnh ? null : _chonMau,
              ),
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
            TrangThaiLichSu.sanSang when ls.ds.isEmpty => Center(
              child: SingleChildScrollView(
                child: KhungTrangThai(
                  icon: Icons.contacts_outlined,
                  tieuDe: c.t(K.dtTrongTieuDe),
                  moTa: c.t(K.dtTrongMoTa),
                  hanhDong: [
                    OutlinedButton.icon(
                      key: const Key('nut_thu_mau_dt'),
                      onPressed: _dangMoAnh ? null : _chonMau,
                      icon: const Icon(Icons.contacts_outlined),
                      label: Text(c.t(K.dtThuMau)),
                    ),
                  ],
                ),
              ),
            ),
            TrangThaiLichSu.sanSang => _DanhSachDanhThiep(
              ds: ls.ds,
              khiChon: _moChiTiet,
            ),
          },
          bottomNavigationBar: ThanhNutDay(
            nut: [
              FilledButton.icon(
                key: const Key('nut_chup_dt'),
                onPressed: _dangMoAnh ? null : () => _layAnh(NguonAnh.mayAnh),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(c.t(K.chupAnh)),
              ),
              OutlinedButton.icon(
                key: const Key('nut_chon_dt'),
                onPressed: _dangMoAnh ? null : () => _layAnh(NguonAnh.thuVien),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(c.t(K.chonAnh)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DanhSachDanhThiep extends StatelessWidget {
  final List<DanhThiep> ds;
  final void Function(DanhThiep) khiChon;

  const _DanhSachDanhThiep({required this.ds, required this.khiChon});

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: ds.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Text(
              c.t(K.dtSoDanhThiep, {'n': '${ds.length}'}),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final d = ds[i - 1];
        final anh = anhCuaDanhThiep(d);
        final dong1 = [
          d.chucVu,
          d.congTy,
        ].where((s) => s.trim().isNotEmpty).join(' · ');
        final dong2 = d.dienThoai.trim().isNotEmpty ? d.dienThoai : d.email;
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('dt_${d.id}'),
            onTap: () => khiChon(d),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 64,
                      height: 48,
                      child: anh == null
                          ? ColoredBox(
                              color: theme.colorScheme.secondaryContainer,
                              child: Center(
                                child: Text(
                                  d.chuCaiDau,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            )
                          : AnhHoaDonWidget(anh: anh, giaiMaRong: 160),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.tenHienThi,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (dong1.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            dong1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (dong2.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            dong2,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
