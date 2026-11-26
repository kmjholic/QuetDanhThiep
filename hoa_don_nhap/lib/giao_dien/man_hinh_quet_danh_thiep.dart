import 'package:flutter/material.dart';

import '../dieu_khien/quet_danh_thiep_dk.dart';
import '../dieu_khien/quet_dk.dart';
import '../mo_hinh/danh_thiep.dart';
import '../mo_hinh/hoa_don.dart';
import '../ngon_ngu/chuoi.dart';
import '../ocr/bo_nhan_dang.dart';
import '../phu_thuoc.dart';
import 'thanh_phan/anh_hoa_don.dart';
import 'thanh_phan/trang_thai.dart';
import 'thanh_phan/trinh_sua.dart';
import 'thanh_phan/trinh_sua_danh_thiep.dart';

/// Nhận dạng chữ + mã QR của một ảnh danh thiếp rồi cho sửa, xuất vCard, lưu.
/// Trả về `true` (qua Navigator.pop) khi đã lưu.
class ManHinhQuetDanhThiep extends StatefulWidget {
  final AnhHoaDon anh;
  final NguonAnh nguon;

  const ManHinhQuetDanhThiep({
    super.key,
    required this.anh,
    required this.nguon,
  });

  @override
  State<ManHinhQuetDanhThiep> createState() => _ManHinhQuetDanhThiepState();
}

class _ManHinhQuetDanhThiepState extends State<ManHinhQuetDanhThiep> {
  DieuKhienQuetDanhThiep? _dk;
  final _o = CacOSuaDanhThiep();
  String _dauVetGoc = '';
  bool _daDienKetQua = false, _dangLuu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dk != null) return;
    final pt = PhuThuoc.of(context);
    final dungDemo = pt.caiDat.dungDemo;
    _dk = DieuKhienQuetDanhThiep(
      boNhanDang: pt.layBoNhanDangDanhThiep(dungDemo),
      anh: widget.anh,
      boQuetMa: pt.layBoQuetMa(dungDemo),
    )..themNghe(_khiDoi);
    Future.microtask(_dk!.batDau); // bắt đầu sau khi khung hình đầu được dựng
  }

  void _khiDoi() {
    final dk = _dk!;
    if (dk.trangThai == TrangThaiQuet.coChu && !_daDienKetQua) {
      _daDienKetQua = true;
      final kq = dk.nhapTay ? null : dk.ketQua;
      _o.dat(
        hoTen: kq?.hoTen ?? '',
        chucVu: kq?.chucVu ?? '',
        congTy: kq?.congTy ?? '',
        dienThoai: kq?.dienThoai ?? '',
        dienThoaiKhac: kq?.dienThoaiKhac ?? '',
        email: kq?.email ?? '',
        website: kq?.website ?? '',
        diaChi: kq?.diaChi ?? '',
      );
      _dauVetGoc = _o.dauVet;
    }
    if (dk.trangThai != TrangThaiQuet.coChu) _daDienKetQua = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dk?.huy();
    _o.dispose();
    super.dispose();
  }

  bool get _coThayDoi =>
      _dk?.trangThai == TrangThaiQuet.coChu &&
      (_o.dauVet != _dauVetGoc || _dk!.nhapTay);

  DanhThiep _taoDanhThiep() => _dk!.taoDanhThiep(
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

  Future<void> _luu() async {
    final c = Chuoi.of(context);
    final pt = PhuThuoc.of(context);
    setState(() => _dangLuu = true);
    try {
      await pt.lichSuDanhThiep.luu(_taoDanhThiep());
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(c.t(K.loiLuu))));
    }
  }

  Future<void> _xuat() async {
    final c = Chuoi.of(context);
    final pt = PhuThuoc.of(context);
    try {
      await pt.lichSuDanhThiep.xuatMot(_taoDanhThiep());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(c.t(K.dtLoiXuat))));
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

  String _thongTin(Chuoi c, DieuKhienQuetDanhThiep dk) {
    final dong = <String>[];
    if (!dk.nhapTay) {
      final nguon = switch (dk.nguon) {
        NguonDanhThiep.ocr => c.t(K.dtNguonOcr),
        NguonDanhThiep.qr => c.t(K.dtNguonQr),
        NguonDanhThiep.thucong => c.t(K.dtNguonThuCong),
      };
      dong.add(c.t(K.dtNguon, {'n': nguon}));
      if (dk.daDungQr) dong.add(c.t(K.dtDaDungQr));
      if (dk.loiQuetMa != null) dong.add(c.t(K.dtLoiQuetMa));
    }
    return dong.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    final dk = _dk!;
    return PopScope<Object?>(
      // Đang ở khung sửa: chặn nút Quay lại để hỏi trước khi bỏ nội dung chưa lưu (xem _khiQuayLai).
      canPop: dk.trangThai != TrangThaiQuet.coChu,
      onPopInvokedWithResult: _khiQuayLai,
      child: Scaffold(
        appBar: AppBar(title: Text(c.t(K.dtKetQua))),
        body: switch (dk.trangThai) {
          TrangThaiQuet.dangNhanDang => _CoAnh(
            anh: widget.anh,
            child: Column(
              children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  c.t(K.dtDangQuet),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  dk.laDemo ? c.t(K.xuLyDemo) : c.t(K.xuLyTrenMay),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          TrangThaiQuet.loi => _CoAnh(
            anh: widget.anh,
            child: KhungTrangThai(
              icon: Icons.error_outline,
              laLoi: true,
              tieuDe: c.t(K.loiNhanDangTieuDe),
              moTa: _thongDiepLoi(c, dk.loi),
              hanhDong: [
                FilledButton.icon(
                  onPressed: dk.batDau,
                  icon: const Icon(Icons.refresh),
                  label: Text(c.t(K.thuLai)),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(c.t(K.chonAnhKhac)),
                ),
              ],
            ),
          ),
          TrangThaiQuet.khongCoChu => _CoAnh(
            anh: widget.anh,
            child: KhungTrangThai(
              icon: Icons.text_snippet_outlined,
              tieuDe: c.t(K.dtKhongCoChuTieuDe),
              moTa: c.t(K.dtKhongCoChuMeo),
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
          TrangThaiQuet.coChu => TrinhSuaDanhThiep(
            anh: widget.anh,
            cacO: _o,
            canhBao: dk.laDemo && !dk.nhapTay ? c.t(K.dtGhiChuDemo) : null,
            thongTin: _thongTin(c, dk),
            vanBanGoc: dk.nhapTay ? '' : dk.vanBanOcr,
          ),
        },
        bottomNavigationBar: dk.trangThai != TrangThaiQuet.coChu
            ? null
            : ListenableBuilder(
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
                      key: const Key('nut_luu_danh_thiep'),
                      onPressed: _dangLuu || !_o.coNoiDung ? null : _luu,
                      icon: _dangLuu
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(c.t(K.luu)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Ảnh ở trên, nội dung trạng thái ở dưới — dùng cho đang quét / lỗi / không có chữ.
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
        child: SizedBox(
          height: 240,
          child: AnhHoaDonWidget(anh: anh, giaiMaRong: 900),
        ),
      ),
      const SizedBox(height: 16),
      child,
    ],
  );
}
