import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../du_lieu/bo_chon_anh.dart';
import '../du_lieu/kho_khoa_gia_tri.dart';
import '../du_lieu/luu_anh.dart';
import '../mo_hinh/hoa_don.dart';

/// Máy có ML Kit (nhận dạng trên thiết bị) hay không.
bool get coOcrThietBi =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Lưu chuỗi bằng shared_preferences (API mới `SharedPreferencesAsync`; trên Android là DataStore).
class KhoPrefs implements KhoKhoaGiaTri {
  final SharedPreferencesAsync _p = SharedPreferencesAsync();

  @override
  Future<String?> doc(String khoa) => _p.getString(khoa);

  @override
  Future<void> ghi(String khoa, String giaTri) => _p.setString(khoa, giaTri);

  @override
  Future<void> xoa(String khoa) => _p.remove(khoa);
}

/// Chép ảnh vào `<thư mục tài liệu của app>/<tenThuMuc>/<mã>.<đuôi>` — chỉ app này đọc được, gỡ app là mất.
/// Hóa đơn dùng thư mục mặc định `hoa_don`; danh thiếp dùng `LuuAnhTep(tenThuMuc: 'danh_thiep')`.
class LuuAnhTep implements LuuAnh {
  final String tenThuMuc;

  LuuAnhTep({this.tenThuMuc = 'hoa_don'});

  Future<Directory> _thuMuc() async {
    final goc = await getApplicationDocumentsDirectory();
    final d = Directory('${goc.path}${Platform.pathSeparator}$tenThuMuc');
    await d.create(recursive: true);
    return d;
  }

  @override
  Future<AnhHoaDon> giuLai(AnhHoaDon anh, String maHoaDon) async {
    if (anh.laAsset) return anh;
    final thuMuc = await _thuMuc();
    if (anh.duongDan.startsWith(thuMuc.path)) {
      return anh; // đã giữ từ lần lưu trước
    }
    final cham = anh.duongDan.lastIndexOf('.');
    final duoi = cham > anh.duongDan.lastIndexOf(Platform.pathSeparator)
        ? anh.duongDan.substring(cham).toLowerCase()
        : '.jpg';
    final dich = '${thuMuc.path}${Platform.pathSeparator}$maHoaDon$duoi';
    await File(anh.duongDan).copy(dich);
    return AnhHoaDon.tep(dich);
  }

  @override
  Future<void> xoa(AnhHoaDon? anh) async {
    if (anh == null || anh.laAsset) return;
    final thuMuc = await _thuMuc();
    if (!anh.duongDan.startsWith(thuMuc.path)) return;
    try {
      await File(anh.duongDan).delete();
    } on FileSystemException {
      // tệp đã mất — không sao
    }
  }
}

/// ML Kit chỉ đọc tệp: chép ảnh mẫu từ assets ra thư mục tạm.
Future<String> chepAssetRaTepTam(String asset) async {
  final duLieu = await rootBundle.load(asset);
  final tam = await getTemporaryDirectory();
  final tep = File(
    '${tam.path}${Platform.pathSeparator}mau_${asset.split('/').last}',
  );
  await tep.writeAsBytes(
    duLieu.buffer.asUint8List(duLieu.offsetInBytes, duLieu.lengthInBytes),
    flush: true,
  );
  return tep.path;
}

/// Chụp ảnh / chọn ảnh bằng image_picker.
///
/// Android: dùng ứng dụng camera của máy và trình chọn ảnh hệ thống (Android Photo Picker) nên app KHÔNG
/// khai báo quyền CAMERA hay quyền đọc ảnh. Ảnh được thu nhỏ còn cạnh dài ≤ 2400 px: đủ nét cho OCR,
/// nhẹ bộ nhớ.
class ChonAnh implements BoChonAnh {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<AnhHoaDon?> chon(NguonAnh nguon) async {
    try {
      final x = await _picker.pickImage(
        source: nguon == NguonAnh.mayAnh
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      return x == null ? null : AnhHoaDon.tep(x.path);
    } on PlatformException catch (e) {
      final ma = e.code.toLowerCase();
      if (ma.contains('access_denied') || ma.contains('permission')) {
        throw LoiChonAnh(LoaiLoiChonAnh.khongCoQuyen, e.code);
      }
      if (ma.contains('no_available_camera') ||
          ma.contains('camera_unavailable')) {
        throw LoiChonAnh(LoaiLoiChonAnh.khongCoCamera, e.code);
      }
      throw LoiChonAnh(LoaiLoiChonAnh.khac, '${e.code}: ${e.message}');
    }
  }

  @override
  Future<AnhHoaDon?> layAnhBiGianDoan() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final r = await _picker.retrieveLostData();
      if (r.isEmpty) return null;
      final f = (r.files != null && r.files!.isNotEmpty)
          ? r.files!.first
          : r.file;
      return f == null ? null : AnhHoaDon.tep(f.path);
    } catch (_) {
      return null;
    }
  }
}
