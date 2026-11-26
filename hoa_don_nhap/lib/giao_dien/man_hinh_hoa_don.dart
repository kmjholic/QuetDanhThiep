import 'package:flutter/material.dart';

import '../dieu_khien/lich_su_dk.dart';
import '../du_lieu/bo_chon_anh.dart';
import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import '../ngon_ngu/chuoi.dart';
import '../ocr/hoa_don_mau.dart';
import '../phu_thuoc.dart';
import 'man_hinh_cai_dat.dart';
import 'man_hinh_chi_tiet.dart';
import 'man_hinh_quet.dart';
import 'thanh_phan/anh_hoa_don.dart';
import 'thanh_phan/nghe_thay_doi.dart';
import 'thanh_phan/trang_thai.dart';
import 'thanh_phan/trinh_sua.dart';

/// Tab "Hóa đơn": lịch sử hóa đơn + nút Chụp ảnh / Chọn ảnh.
/// (Trước đây tên `ManHinhChinh`; nay nằm trong khung chính `ManHinhChinh` có thanh điều hướng.)
class ManHinhHoaDon extends StatefulWidget {
  const ManHinhHoaDon({super.key});

  @override
  State<ManHinhHoaDon> createState() => _ManHinhHoaDonState();
}

class _ManHinhHoaDonState extends State<ManHinhHoaDon> {
  bool _dangMoAnh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pt = PhuThuoc.of(context);
      await pt.lichSu.tai();
      // Android có thể huỷ app khi mở camera; nếu vậy, lấy lại ảnh vừa chụp và đi tiếp.
      final anh = await pt.chonAnh.layAnhBiGianDoan();
      if (anh != null && mounted) await _moQuet(anh, NguonAnh.mayAnh);
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
    final mau = await showModalBottomSheet<HoaDonMau>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(c.t(K.chonMauTieuDe)),
              subtitle: Text(c.t(K.chonMauMoTa)),
            ),
            for (final m in dsHoaDonMau)
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 40,
                    height: 52,
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
        builder: (_) => ManHinhQuet(anh: anh, nguon: nguon),
      ),
    );
    if (daLuu == true && mounted) _bao(c.t(K.daLuu));
  }

  Future<void> _moChiTiet(HoaDon h) async {
    final c = Chuoi.of(context);
    final kq = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => ManHinhChiTiet(ma: h.ma)));
    if (kq == ManHinhChiTiet.daXoa && mounted) _bao(c.t(K.daXoa));
  }

  @override
  Widget build(BuildContext context) {
    final pt = PhuThuoc.of(context);
    final c = Chuoi.of(context);
    return NgheThayDoi(
      nguon: [pt.lichSu, pt.caiDat],
      builder: (context) {
        final ls = pt.lichSu;
        return Scaffold(
          appBar: AppBar(
            title: Text(c.t(K.lichSu)),
            actions: [
              IconButton(
                tooltip: c.t(K.dungMau),
                icon: const Icon(Icons.receipt_outlined),
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
          body: Column(
            children: [
              if (pt.caiDat.dungDemo) _BangDemo(text: c.t(K.bannerDemo)),
              Expanded(
                child: switch (ls.trangThai) {
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
                        icon: Icons.receipt_long_outlined,
                        tieuDe: c.t(K.trongTieuDe),
                        moTa: c.t(K.trongMoTa),
                        hanhDong: [
                          OutlinedButton.icon(
                            key: const Key('nut_thu_mau'),
                            onPressed: _dangMoAnh ? null : _chonMau,
                            icon: const Icon(Icons.receipt_outlined),
                            label: Text(c.t(K.thuMau)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TrangThaiLichSu.sanSang => _DanhSach(
                    ds: ls.ds,
                    khiChon: _moChiTiet,
                  ),
                },
              ),
            ],
          ),
          bottomNavigationBar: ThanhNutDay(
            nut: [
              FilledButton.icon(
                key: const Key('nut_chup'),
                onPressed: _dangMoAnh ? null : () => _layAnh(NguonAnh.mayAnh),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(c.t(K.chupAnh)),
              ),
              OutlinedButton.icon(
                key: const Key('nut_chon'),
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

class _BangDemo extends StatelessWidget {
  final String text;

  const _BangDemo({required this.text});

  @override
  Widget build(BuildContext context) {
    final mau = Theme.of(context).colorScheme;
    return Material(
      color: mau.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.science_outlined,
              size: 20,
              color: mau.onTertiaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: mau.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DanhSach extends StatelessWidget {
  final List<HoaDon> ds;
  final void Function(HoaDon) khiChon;

  const _DanhSach({required this.ds, required this.khiChon});

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
              c.t(K.soHoaDon, {'n': '${ds.length}'}),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final h = ds[i - 1];
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => khiChon(h),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 48,
                      height: 64,
                      child: h.anh == null
                          ? ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.notes_outlined),
                            )
                          : AnhHoaDonWidget(anh: h.anh!, giaiMaRong: 150),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.tieuDe,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dinhDangThoiGian(h.taoLuc),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tomTat(h.noiDung),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
