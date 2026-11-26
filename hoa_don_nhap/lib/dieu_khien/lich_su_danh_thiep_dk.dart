import '../du_lieu/kho_danh_thiep.dart';
import '../du_lieu/luu_anh.dart';
import '../du_lieu/xuat_vcard.dart';
import '../mo_hinh/danh_thiep.dart';
import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/vcard.dart';
import 'lich_su_dk.dart' show TrangThaiLichSu;
import 'thong_bao.dart';

/// Danh sách danh thiếp đã lưu trên máy (tách biệt với lịch sử hóa đơn).
class DieuKhienLichSuDanhThiep with CoThongBao {
  final KhoDanhThiep _kho;
  final LuuAnh _luuAnh;
  final BoXuatVCard _xuat;

  TrangThaiLichSu trangThai = TrangThaiLichSu.dangTai;
  List<DanhThiep> ds = const [];
  Object? loi;

  DieuKhienLichSuDanhThiep(this._kho, this._luuAnh, this._xuat);

  bool get trong => trangThai == TrangThaiLichSu.sanSang && ds.isEmpty;

  Future<void> tai() async {
    trangThai = TrangThaiLichSu.dangTai;
    loi = null;
    baoThayDoi();
    try {
      ds = await _kho.docTatCa();
      trangThai = TrangThaiLichSu.sanSang;
    } catch (e) {
      loi = e;
      trangThai = TrangThaiLichSu.loi;
    }
    baoThayDoi();
  }

  DanhThiep? tim(String id) {
    for (final d in ds) {
      if (d.id == id) return d;
    }
    return null;
  }

  AnhHoaDon? _anhCua(DanhThiep? d) => AnhHoaDon.giaiMa(d?.duongDanAnh);

  /// Lưu mới hoặc cập nhật. Ảnh được chép vào thư mục của app trước. Lỗi được ném ra cho màn hình báo.
  Future<DanhThiep> luu(DanhThiep d) async {
    final anh = _anhCua(d);
    final anhMoi = anh == null ? null : await _luuAnh.giuLai(anh, d.id);
    final moi = anhMoi == null ? d : d.copyWith(duongDanAnh: anhMoi.maHoa());
    ds = await _kho.luu(moi);
    trangThai = TrangThaiLichSu.sanSang;
    baoThayDoi();
    return moi;
  }

  Future<void> xoa(String id) async {
    final d = tim(id);
    ds = await _kho.xoa(id);
    await _luuAnh.xoa(_anhCua(d));
    baoThayDoi();
  }

  /// Xoá toàn bộ danh thiếp (KHÔNG đụng tới hóa đơn).
  Future<void> xoaHet() async {
    final cu = ds;
    await _kho.xoaHet();
    for (final d in cu) {
      await _luuAnh.xoa(_anhCua(d));
    }
    ds = const [];
    trangThai = TrangThaiLichSu.sanSang;
    baoThayDoi();
  }

  /// Xuất một danh thiếp ra .vcf và mở bảng chia sẻ. Ném [LoiXuatVCard] khi thất bại.
  Future<void> xuatMot(DanhThiep d) =>
      _xuat.chiaSe(tenTep: TaoVCard.tenTep(d), noiDung: TaoVCard.tao(d));

  /// Xuất tất cả danh thiếp vào MỘT tệp .vcf. Danh sách trống thì không làm gì (trả false).
  Future<bool> xuatTatCa() async {
    if (ds.isEmpty) return false;
    await _xuat.chiaSe(
      tenTep: 'danh_thiep_tat_ca.${TaoVCard.phanMoRong}',
      noiDung: TaoVCard.taoNhieu(ds),
    );
    return true;
  }
}
