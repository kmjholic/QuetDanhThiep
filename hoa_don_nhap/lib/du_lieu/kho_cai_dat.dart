import 'kho_khoa_gia_tri.dart';

enum NgonNgu { heThong, vi, en }

/// Cài đặt người dùng: ngôn ngữ giao diện và công tắc chế độ demo.
class KhoCaiDat {
  static const khoaNgonNgu = 'cai_dat_ngon_ngu';
  static const khoaDemo = 'cai_dat_demo';
  final KhoKhoaGiaTri _kho;

  KhoCaiDat(this._kho);

  Future<NgonNgu> docNgonNgu() async {
    final s = await _kho.doc(khoaNgonNgu);
    return NgonNgu.values.firstWhere((n) => n.name == s, orElse: () => NgonNgu.heThong);
  }

  Future<void> ghiNgonNgu(NgonNgu n) => _kho.ghi(khoaNgonNgu, n.name);

  Future<bool> docDemo() async => (await _kho.doc(khoaDemo)) == 'true';

  Future<void> ghiDemo(bool bat) => _kho.ghi(khoaDemo, '$bat');
}
