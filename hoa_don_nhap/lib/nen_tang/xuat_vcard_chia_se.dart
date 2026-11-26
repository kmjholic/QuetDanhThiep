import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../du_lieu/xuat_vcard.dart';
import '../mo_hinh/vcard.dart';

/// Làm sạch tên tệp: bỏ ký tự cấm, bảo đảm có đuôi .vcf và không rỗng.
String tenTepAnToan(String ten) {
  var s = ten.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_').trim();
  if (s.isEmpty || s == '.${TaoVCard.phanMoRong}') s = 'danh_thiep';
  if (!s.toLowerCase().endsWith('.${TaoVCard.phanMoRong}')) {
    s = '$s.${TaoVCard.phanMoRong}';
  }
  return s;
}

/// Bản thật của [BoXuatVCard]: ghi tệp vào thư mục tạm rồi mở bảng chia sẻ (share_plus).
class BoXuatVCardChiaSe implements BoXuatVCard {
  @override
  Future<void> chiaSe({required String tenTep, required String noiDung}) async {
    try {
      final tam = await getTemporaryDirectory();
      final thuMuc = Directory('${tam.path}${Platform.pathSeparator}vcard');
      await thuMuc.create(recursive: true);
      final ten = tenTepAnToan(tenTep);
      final tep = File('${thuMuc.path}${Platform.pathSeparator}$ten');
      await tep.writeAsBytes(
        utf8.encode(noiDung),
        flush: true,
      ); // UTF-8, không BOM

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tep.path, mimeType: TaoVCard.mimeType, name: ten)],
        ),
      );
    } on LoiXuatVCard {
      rethrow;
    } catch (e) {
      throw LoiXuatVCard('$e');
    }
  }
}
