import 'dart:io';

import 'package:flutter/services.dart' show PlatformException;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../mo_hinh/hoa_don.dart';
import '../ocr/bo_quet_ma.dart';
import 'nen_tang.dart' show chepAssetRaTepTam;

/// Quét mã QR bằng ML Kit Barcode Scanning (mô hình đóng gói sẵn, chạy offline trên Android/iOS).
/// Trả về nội dung chuỗi gốc ([Barcode.rawValue]) của mọi mã QR đọc được; vCard/MECARD để
/// `DocVCard` ở lớp mô hình tự phân tích.
class BoQuetMaMlKit implements BoQuetMa {
  BarcodeScanner? _boQuet;

  BarcodeScanner get _bo =>
      _boQuet ??= BarcodeScanner(formats: const [BarcodeFormat.qrCode]);

  @override
  bool get laDemo => false;

  @override
  Future<List<String>> quet(AnhHoaDon anh) async {
    final String duongDan;
    try {
      duongDan = anh.laAsset
          ? await chepAssetRaTepTam(anh.duongDan)
          : anh.duongDan;
    } catch (e) {
      throw LoiQuetMa(LoaiLoiQuetMa.khongDocDuocAnh, '$e');
    }

    final tep = File(duongDan);
    if (!await tep.exists() || await tep.length() == 0) {
      throw LoiQuetMa(
        LoaiLoiQuetMa.khongDocDuocAnh,
        'không có tệp hoặc tệp rỗng: $duongDan',
      );
    }

    try {
      final dsMa = await _bo.processImage(InputImage.fromFilePath(duongDan));
      return [
        for (final ma in dsMa)
          if (ma.rawValue != null && ma.rawValue!.trim().isNotEmpty)
            ma.rawValue!,
      ];
    } on PlatformException catch (e) {
      throw LoiQuetMa(LoaiLoiQuetMa.thatBai, '${e.code}: ${e.message}');
    } catch (e) {
      throw LoiQuetMa(LoaiLoiQuetMa.thatBai, '$e');
    }
  }

  @override
  Future<void> dong() async {
    await _boQuet?.close();
    _boQuet = null;
  }
}
