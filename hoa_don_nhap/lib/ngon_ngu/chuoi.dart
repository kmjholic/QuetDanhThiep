import 'package:flutter/widgets.dart';

import 'du_lieu_chuoi.dart';

export 'du_lieu_chuoi.dart' show K;

/// Chuỗi giao diện theo ngôn ngữ đang dùng: `Chuoi.of(context).t(K.luu)`.
///
/// Dự án nhỏ nên dùng bảng chuỗi viết tay (`du_lieu_chuoi.dart`) thay cho gen-l10n/.arb: không cần bước
/// sinh mã, đọc là hiểu. Các widget Material (nút Huỷ của hộp thoại, chọn văn bản…) được dịch nhờ
/// `GlobalMaterialLocalizations` của gói flutter_localizations.
class Chuoi {
  final Locale locale;
  final Map<K, String> _bang;

  Chuoi(this.locale) : _bang = locale.languageCode == 'en' ? chuoiEn : chuoiVi;

  static const ngonNguHoTro = [Locale('vi'), Locale('en')];

  static Chuoi of(BuildContext context) => Localizations.of<Chuoi>(context, Chuoi)!;

  String t(K khoa, [Map<String, String> thamSo = const {}]) => dienThamSo(_bang[khoa] ?? chuoiVi[khoa]!, thamSo);

  bool get laTiengAnh => locale.languageCode == 'en';

  static const LocalizationsDelegate<Chuoi> delegate = _UyQuyen();
}

class _UyQuyen extends LocalizationsDelegate<Chuoi> {
  const _UyQuyen();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<Chuoi> load(Locale locale) async => Chuoi(locale);

  @override
  bool shouldReload(_UyQuyen old) => false;
}
