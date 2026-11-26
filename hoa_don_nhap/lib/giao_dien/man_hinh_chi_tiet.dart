import 'package:flutter/material.dart';

import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import '../ngon_ngu/chuoi.dart';
import '../phu_thuoc.dart';
import 'thanh_phan/trang_thai.dart';
import 'thanh_phan/trinh_sua.dart';

/// Xem, sửa, sao chép, xoá một hóa đơn đã lưu. Trả về [daXoa] khi hóa đơn bị xoá.
class ManHinhChiTiet extends StatefulWidget {
  static const daXoa = 'da_xoa';
  final String ma;

  const ManHinhChiTiet({super.key, required this.ma});

  @override
  State<ManHinhChiTiet> createState() => _ManHinhChiTietState();
}

class _ManHinhChiTietState extends State<ManHinhChiTiet> {
  HoaDon? _h;
  final _tieuDe = TextEditingController();
  final _noiDung = TextEditingController();
  bool _dangLuu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_h != null) return;
    _h = PhuThuoc.of(context).lichSu.tim(widget.ma);
    _tieuDe.text = _h?.tieuDe ?? '';
    _noiDung.text = _h?.noiDung ?? '';
  }

  @override
  void dispose() {
    _tieuDe.dispose();
    _noiDung.dispose();
    super.dispose();
  }

  bool get _coThayDoi => _h != null && (_tieuDe.text != _h!.tieuDe || _noiDung.text != _h!.noiDung);

  void _bao(String s) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(s)));

  Future<void> _luu() async {
    final c = Chuoi.of(context);
    setState(() => _dangLuu = true);
    try {
      final tieuDe = _tieuDe.text.trim().isEmpty ? (doanTieuDe(_noiDung.text).isEmpty ? _h!.tieuDe : doanTieuDe(_noiDung.text)) : _tieuDe.text.trim();
      final moi = await PhuThuoc.of(context).lichSu.luu(
            _h!.copyWith(tieuDe: tieuDe, noiDung: chuanHoaVanBan(_noiDung.text), suaLuc: DateTime.now()),
          );
      if (!mounted) return;
      setState(() {
        _h = moi;
        _tieuDe.text = moi.tieuDe;
        _noiDung.text = moi.noiDung;
      });
      _bao(c.t(K.daLuu));
    } catch (_) {
      if (mounted) _bao(c.t(K.loiLuu));
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
  }

  Future<void> _xoa() async {
    final c = Chuoi.of(context);
    final dongY = await hoiXacNhan(
      context,
      tieuDe: c.t(K.xoaHoiTieuDe),
      moTa: c.t(K.xoaHoiMoTa),
      nutDongY: c.t(K.xoa),
      nguyHiem: true,
    );
    if (!dongY || !mounted) return;
    try {
      await PhuThuoc.of(context).lichSu.xoa(widget.ma);
      if (mounted) Navigator.of(context).pop(ManHinhChiTiet.daXoa);
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
    final h = _h;
    if (h == null) {
      return Scaffold(
        appBar: AppBar(title: Text(c.t(K.chiTiet))),
        body: Center(child: KhungTrangThai(icon: Icons.search_off, tieuDe: c.t(K.khongTimThay))),
      );
    }
    final thongTin = [
      c.t(K.taoLuc, {'t': dinhDangThoiGian(h.taoLuc)}),
      if (h.suaLuc != h.taoLuc) c.t(K.suaLuc, {'t': dinhDangThoiGian(h.suaLuc)}),
    ].join(' · ');
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _khiQuayLai,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.t(K.chiTiet)),
          actions: [
            IconButton(
              key: const Key('nut_xoa'),
              tooltip: c.t(K.xoa),
              icon: const Icon(Icons.delete_outline),
              onPressed: _xoa,
            ),
          ],
        ),
        body: TrinhSuaHoaDon(anh: h.anh, tieuDe: _tieuDe, noiDung: _noiDung, thongTin: thongTin),
        bottomNavigationBar: ListenableBuilder(
          listenable: Listenable.merge([_tieuDe, _noiDung]),
          builder: (context, _) => ThanhNutDay(nut: [
            OutlinedButton.icon(
              onPressed: _noiDung.text.trim().isEmpty ? null : () => saoChepVanBan(context, _tieuDe.text, _noiDung.text),
              icon: const Icon(Icons.copy_outlined),
              label: Text(c.t(K.saoChep)),
            ),
            FilledButton.icon(
              key: const Key('nut_luu_thay_doi'),
              onPressed: !_coThayDoi || _dangLuu || _noiDung.text.trim().isEmpty ? null : _luu,
              icon: const Icon(Icons.save_outlined),
              label: Text(c.t(K.luuThayDoi)),
            ),
          ]),
        ),
      ),
    );
  }
}
