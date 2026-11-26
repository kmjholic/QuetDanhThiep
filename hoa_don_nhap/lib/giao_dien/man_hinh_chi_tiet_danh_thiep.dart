import 'package:flutter/material.dart';

import '../mo_hinh/danh_thiep.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import '../ngon_ngu/chuoi.dart';
import '../phu_thuoc.dart';
import 'man_hinh_lich_su_danh_thiep.dart' show anhCuaDanhThiep;
import 'thanh_phan/trang_thai.dart';
import 'thanh_phan/trinh_sua.dart';
import 'thanh_phan/trinh_sua_danh_thiep.dart';

/// Xem, sửa, xuất vCard, xoá một danh thiếp đã lưu. Trả về [daXoa] khi danh thiếp bị xoá.
class ManHinhChiTietDanhThiep extends StatefulWidget {
  static const daXoa = 'da_xoa';
  final String id;

  const ManHinhChiTietDanhThiep({super.key, required this.id});

  @override
  State<ManHinhChiTietDanhThiep> createState() =>
      _ManHinhChiTietDanhThiepState();
}

class _ManHinhChiTietDanhThiepState extends State<ManHinhChiTietDanhThiep> {
  DanhThiep? _d;
  final _o = CacOSuaDanhThiep();
  String _dauVetGoc = '';
  bool _dangLuu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_d != null) return;
    _d = PhuThuoc.of(context).lichSuDanhThiep.tim(widget.id);
    _napO(_d);
  }

  void _napO(DanhThiep? d) {
    _o.dat(
      hoTen: d?.hoTen ?? '',
      chucVu: d?.chucVu ?? '',
      congTy: d?.congTy ?? '',
      dienThoai: d?.dienThoai ?? '',
      dienThoaiKhac: d?.dienThoaiKhac ?? '',
      email: d?.email ?? '',
      website: d?.website ?? '',
      diaChi: d?.diaChi ?? '',
      ghiChu: d?.ghiChu ?? '',
    );
    _dauVetGoc = _o.dauVet;
  }

  @override
  void dispose() {
    _o.dispose();
    super.dispose();
  }

  bool get _coThayDoi => _d != null && _o.dauVet != _dauVetGoc;

  /// Bản danh thiếp theo nội dung đang hiện trong các ô (đã cắt khoảng trắng đầu/cuối).
  DanhThiep _banHienTai() => _d!.copyWith(
    hoTen: _o.hoTen.text.trim(),
    chucVu: _o.chucVu.text.trim(),
    congTy: _o.congTy.text.trim(),
    dienThoai: _o.dienThoai.text.trim(),
    dienThoaiKhac: _o.dienThoaiKhac.text.trim(),
    email: _o.email.text.trim(),
    website: _o.website.text.trim(),
    diaChi: _o.diaChi.text.trim(),
    ghiChu: _o.ghiChu.text.trim(),
  );

  void _bao(String s) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(s)));

  Future<void> _luu() async {
    final c = Chuoi.of(context);
    final pt = PhuThuoc.of(context);
    setState(() => _dangLuu = true);
    try {
      final moi = _banHienTai();
      await pt.lichSuDanhThiep.luu(moi);
      if (!mounted) return;
      setState(() {
        _d = moi;
        _napO(moi);
      });
      _bao(c.t(K.daLuu));
    } catch (_) {
      if (mounted) _bao(c.t(K.loiLuu));
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
  }

  Future<void> _xuat() async {
    final c = Chuoi.of(context);
    final pt = PhuThuoc.of(context);
    try {
      await pt.lichSuDanhThiep.xuatMot(_banHienTai());
    } catch (_) {
      if (mounted) _bao(c.t(K.dtLoiXuat));
    }
  }

  Future<void> _xoa() async {
    final c = Chuoi.of(context);
    final pt = PhuThuoc.of(context);
    final dongY = await hoiXacNhan(
      context,
      tieuDe: c.t(K.dtXoaHoiTieuDe),
      moTa: c.t(K.dtXoaHoiMoTa),
      nutDongY: c.t(K.xoa),
      nguyHiem: true,
    );
    if (!dongY || !mounted) return;
    try {
      await pt.lichSuDanhThiep.xoa(widget.id);
      if (mounted) Navigator.of(context).pop(ManHinhChiTietDanhThiep.daXoa);
    } catch (_) {
      if (mounted) _bao(c.t(K.loiXoa));
    }
  }

  Future<void> _khiQuayLai(bool daQuayLai, Object? _) async {
    if (daQuayLai) return;
    if (!_coThayDoi) {
      Navigator.of(context).pop();
      return;
    }
    final c = Chuoi.of(context);
    final bo = await hoiXacNhan(
      context,
      tieuDe: c.t(K.boThayDoiTieuDe),
      moTa: c.t(K.boThayDoiMoTa),
      nutDongY: c.t(K.bo),
      nutHuy: c.t(K.tiepTucSua),
      nguyHiem: true,
    );
    if (bo && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    final d = _d;
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: Text(c.t(K.dtChiTiet))),
        body: Center(
          child: KhungTrangThai(
            icon: Icons.search_off,
            tieuDe: c.t(K.dtKhongTimThay),
          ),
        ),
      );
    }
    final nguon = switch (d.nguon) {
      NguonDanhThiep.ocr => c.t(K.dtNguonOcr),
      NguonDanhThiep.qr => c.t(K.dtNguonQr),
      NguonDanhThiep.thucong => c.t(K.dtNguonThuCong),
    };
    final thongTin = [
      c.t(K.taoLuc, {'t': dinhDangThoiGian(d.thoiGian)}),
      c.t(K.dtNguon, {'n': nguon}),
    ].join(' · ');
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _khiQuayLai,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.t(K.dtChiTiet)),
          actions: [
            IconButton(
              key: const Key('nut_xoa_dt'),
              tooltip: c.t(K.xoa),
              icon: const Icon(Icons.delete_outline),
              onPressed: _xoa,
            ),
          ],
        ),
        body: TrinhSuaDanhThiep(
          anh: anhCuaDanhThiep(d),
          cacO: _o,
          thongTin: thongTin,
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: Listenable.merge(_o.tatCa),
          builder: (context, _) => ThanhNutDay(
            nut: [
              OutlinedButton.icon(
                key: const Key('nut_xuat_vcard'),
                onPressed: _o.coNoiDung ? _xuat : null,
                icon: const Icon(Icons.contact_page_outlined),
                label: Text(c.t(K.dtXuatVCard)),
              ),
              FilledButton.icon(
                key: const Key('nut_luu_thay_doi_dt'),
                onPressed: !_coThayDoi || _dangLuu || !_o.coNoiDung
                    ? null
                    : _luu,
                icon: const Icon(Icons.save_outlined),
                label: Text(c.t(K.luuThayDoi)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
