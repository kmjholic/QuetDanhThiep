import '../cau_hinh/cau_hinh.dart';
import '../du_lieu/kho_cai_dat.dart';
import 'thong_bao.dart';

/// Ngôn ngữ giao diện và chế độ nhận dạng (trên thiết bị / demo).
class DieuKhienCaiDat with CoThongBao {
  final KhoCaiDat _kho;
  final CauHinh cauHinh;

  /// Nền tảng có ML Kit (Android/iOS).
  final bool coOcrThietBi;

  NgonNgu ngonNgu = NgonNgu.heThong;
  bool _chonDemo = false;

  DieuKhienCaiDat(this._kho, {required this.cauHinh, required this.coOcrThietBi});

  bool get dungDemo => cauHinh.dungDemo(coOcrThietBi: coOcrThietBi, nguoiDungChonDemo: _chonDemo);

  bool get choDoiCheDo => cauHinh.choDoiCheDo(coOcrThietBi: coOcrThietBi);

  /// Lỗi đọc cài đặt không chặn app: dùng giá trị mặc định.
  Future<void> tai() async {
    try {
      ngonNgu = await _kho.docNgonNgu();
      _chonDemo = await _kho.docDemo();
    } catch (_) {
      ngonNgu = NgonNgu.heThong;
      _chonDemo = false;
    }
    baoThayDoi();
  }

  Future<void> datNgonNgu(NgonNgu n) async {
    ngonNgu = n;
    baoThayDoi();
    try {
      await _kho.ghiNgonNgu(n);
    } catch (_) {
      // giữ lựa chọn trong phiên này dù không ghi được
    }
  }

  Future<void> datDemo(bool bat) async {
    if (!choDoiCheDo) return;
    _chonDemo = bat;
    baoThayDoi();
    try {
      await _kho.ghiDemo(bat);
    } catch (_) {}
  }
}
