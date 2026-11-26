import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../mo_hinh/hoa_don.dart';
import '../../ngon_ngu/chuoi.dart';

/// Ảnh hóa đơn từ tệp, asset (ảnh mẫu) hoặc (trên web) URL blob. Ảnh lỗi → biểu tượng + chữ báo.
class AnhHoaDonWidget extends StatelessWidget {
  final AnhHoaDon anh;
  final BoxFit fit;

  /// Giải mã ảnh ở độ rộng này (điểm ảnh) để tiết kiệm bộ nhớ khi chỉ hiện ảnh nhỏ.
  final int? giaiMaRong;

  const AnhHoaDonWidget({super.key, required this.anh, this.fit = BoxFit.cover, this.giaiMaRong});

  Widget _loi(BuildContext context, Object e, StackTrace? st) {
    final mau = Theme.of(context).colorScheme;
    return ColoredBox(
      color: mau.surfaceContainerHighest,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.broken_image_outlined, color: mau.onSurfaceVariant),
          if (giaiMaRong == null || giaiMaRong! > 200)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(Chuoi.of(context).t(K.khongHienAnh), style: Theme.of(context).textTheme.bodySmall),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (anh.laAsset) {
      return Image.asset(anh.duongDan, fit: fit, cacheWidth: giaiMaRong, errorBuilder: _loi);
    }
    if (kIsWeb) return Image.network(anh.duongDan, fit: fit, errorBuilder: _loi);
    return Image.file(File(anh.duongDan), fit: fit, cacheWidth: giaiMaRong, errorBuilder: _loi);
  }
}

/// Xem ảnh toàn màn hình, phóng to bằng hai ngón tay để đối chiếu với văn bản.
class ManHinhXemAnh extends StatelessWidget {
  final AnhHoaDon anh;

  const ManHinhXemAnh({super.key, required this.anh});

  static Future<void> mo(BuildContext context, AnhHoaDon anh) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ManHinhXemAnh(anh: anh)));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(Chuoi.of(context).t(K.xemAnh)),
        ),
        body: InteractiveViewer(
          maxScale: 6,
          child: Center(child: AnhHoaDonWidget(anh: anh, fit: BoxFit.contain)),
        ),
      );
}
