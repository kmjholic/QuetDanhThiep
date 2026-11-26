import 'package:flutter/material.dart';

import '../dieu_khien/quet_dk.dart';
import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/xu_ly_van_ban.dart';
import '../ngon_ngu/chuoi.dart';
import '../ocr/bo_nhan_dang.dart';
import '../phu_thuoc.dart';
import 'thanh_phan/anh_hoa_don.dart';
import 'thanh_phan/trang_thai.dart';
import 'thanh_phan/trinh_sua.dart';

/// Nhận dạng một ảnh rồi cho sửa, sao chép, lưu. Trả về `true` (qua Navigator.pop) khi đã lưu.
class ManHinhQuet extends StatefulWidget {
  final AnhHoaDon anh;
  final NguonAnh nguon;

  const ManHinhQuet({super.key, required this.anh, required this.nguon});

  @override
  State<ManHinhQuet> createState() => _ManHinhQuetState();
}

class _ManHinhQuetState extends State<ManHinhQuet> {
  DieuKhienQuet? _dk;
  final _tieuDe = TextEditingController();
  final _noiDung = TextEditingController();
  String _tieuDeGoc = '', _noiDungGoc = '';
  bool _daDienKetQua = false, _dangLuu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dk != null) return;
    final pt = PhuThuoc.of(context);
    _dk = DieuKhienQuet(
      boNhanDang: pt.layBoNhanDang(pt.caiDat.dungDemo),
      anh: widget.anh,
      nguon: widget.nguon,
    )..themNghe(_khiDoi);
    Future.microtask(_dk!.batDau); // bắt đầu sau khi khung hình đầu được dựng

  }

  void _khiDoi() {
    final dk = _dk!;
    if (dk.trangThai == TrangThaiQuet.coChu && !_daDienKetQua) {
      _daDienKetQua = true;
      _tieuDe.text = _tieuDeGoc = dk.tieuDeGoiY;
      _noiDung.text = _noiDungGoc = dk.vanBan;
    }
    if (dk.trangThai != TrangThaiQuet.coChu) _daDienKetQua = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dk?.huy();
    _tieuDe.dispose();
    _noiDung.dispose();
    super.dispose();
  }

  bool get _coThayDoi =>
      _dk?.trangThai == TrangThaiQuet.coChu && (_tieuDe.text != _tieuDeGoc || _noiDung.text != _noiDungGoc || _dk!.nhapTay);

  Future<void> _luu() async {
    final c = Chuoi.of(context);
    final pt = PhuThuoc.of(context);
    setState(() => _dangLuu = true);
    try {
      final h = _dk!.taoHoaDon(
        tieuDe: _tieuDe.text,
        noiDung: _noiDung.text,
        tieuDeMacDinh: c.t(K.tieuDeMacDinh, {'t': dinhDangThoiGian(DateTime.now())}),
      );
      await pt.lichSu.luu(h);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(c.t(K.loiLuu))));
    }
  }

  Future<void> _khiQuayLai(bool daQuayLai, Object? _) async {
    if (daQuayLai) return;
    if (!_coThayDoi) {
      Navigator.of(context).pop(false);
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
    if (bo && mounted) Navigator.of(context).pop(false);
  }

  String _thongDiepLoi(Chuoi c, LoiNhanDang? loi) => switch (loi?.loai) {
        LoaiLoiNhanDang.khongDocDuocAnh => c.t(K.loiAnhHong),
        LoaiLoiNhanDang.khongHoTro => c.t(K.loiKhongHoTro),
        _ => c.t(K.loiThatBai),
      };

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    final dk = _dk!;
    return PopScope<Object?>(
      // Đang ở khung sửa: chặn nút Quay lại để hỏi trước khi bỏ nội dung chưa lưu (xem _khiQuayLai).
      canPop: dk.trangThai != TrangThaiQuet.coChu,
      onPopInvokedWithResult: _khiQuayLai,
      child: Scaffold(
        appBar: AppBar(title: Text(c.t(K.ketQua))),
        body: switch (dk.trangThai) {
          TrangThaiQuet.dangNhanDang => _CoAnh(
              anh: widget.anh,
              child: Column(children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(c.t(K.dangNhanDang), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(dk.laDemo ? c.t(K.xuLyDemo) : c.t(K.xuLyTrenMay), textAlign: TextAlign.center),
              ]),
            ),
          TrangThaiQuet.loi => _CoAnh(
              anh: widget.anh,
              child: KhungTrangThai(
                icon: Icons.error_outline,
                laLoi: true,
                tieuDe: c.t(K.loiNhanDangTieuDe),
                moTa: _thongDiepLoi(c, dk.loi),
                hanhDong: [
                  FilledButton.icon(onPressed: dk.batDau, icon: const Icon(Icons.refresh), label: Text(c.t(K.thuLai))),
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(c.t(K.chonAnhKhac))),
                ],
              ),
            ),
          TrangThaiQuet.khongCoChu => _CoAnh(
              anh: widget.anh,
              child: KhungTrangThai(
                icon: Icons.text_snippet_outlined,
                tieuDe: c.t(K.khongCoChuTieuDe),
                moTa: c.t(K.khongCoChuMeo),
                hanhDong: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(c.t(K.chupLai)),
                  ),
                  OutlinedButton.icon(
                    key: const Key('nut_nhap_tay'),
                    onPressed: dk.chuyenSangNhapTay,
                    icon: const Icon(Icons.edit_note),
                    label: Text(c.t(K.nhapTay)),
                  ),
                ],
              ),
            ),
          TrangThaiQuet.coChu => TrinhSuaHoaDon(
              anh: widget.anh,
              tieuDe: _tieuDe,
              noiDung: _noiDung,
              canhBao: dk.laDemo && !dk.nhapTay ? c.t(K.ghiChuDemo) : null,
              thongTin: dk.nhapTay || dk.thoiGian == null
                  ? null
                  : c.t(K.thongKe, {
                      'n': '${dk.soDong}',
                      's': (dk.thoiGian!.inMilliseconds / 1000).toStringAsFixed(1),
                    }),
            ),
        },
        bottomNavigationBar: dk.trangThai != TrangThaiQuet.coChu
            ? null
            : ListenableBuilder(
                listenable: Listenable.merge([_tieuDe, _noiDung]),
                builder: (context, _) => ThanhNutDay(nut: [
                  OutlinedButton.icon(
                    key: const Key('nut_sao_chep'),
                    onPressed: _noiDung.text.trim().isEmpty ? null : () => saoChepVanBan(context, _tieuDe.text, _noiDung.text),
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(c.t(K.saoChep)),
                  ),
                  FilledButton.icon(
                    key: const Key('nut_luu'),
                    onPressed: _dangLuu || _noiDung.text.trim().isEmpty ? null : _luu,
                    icon: _dangLuu
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: Text(c.t(K.luu)),
                  ),
                ]),
              ),
      ),
    );
  }
}

/// Ảnh ở trên, nội dung trạng thái ở dưới — dùng cho đang nhận dạng / lỗi / không có chữ.
class _CoAnh extends StatelessWidget {
  final AnhHoaDon anh;
  final Widget child;

  const _CoAnh({required this.anh, required this.child});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(height: 240, child: AnhHoaDonWidget(anh: anh, giaiMaRong: 900)),
          ),
          const SizedBox(height: 16),
          child,
        ],
      );
}
