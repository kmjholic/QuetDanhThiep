import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'du_lieu/kho_cai_dat.dart';
import 'giao_dien/man_hinh_chinh.dart';
import 'giao_dien/thanh_phan/nghe_thay_doi.dart';
import 'ngon_ngu/chuoi.dart';
import 'phu_thuoc.dart';

/// Gốc ứng dụng: ngôn ngữ, giao diện sáng/tối, màn hình chính.
class UngDung extends StatelessWidget {
  final PhuThuoc Function(Widget child) boc;

  /// [boc] đặt [PhuThuoc] lên trên MaterialApp để mọi màn hình (kể cả route mới) đều lấy được.
  const UngDung({super.key, required this.boc});

  static ThemeData _giaoDien(Brightness sangToi) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E7A4C),
      brightness: sangToi,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return boc(
      Builder(
        builder: (context) {
          final caiDat = PhuThuoc.of(context).caiDat;
          return NgheThayDoi(
            nguon: [caiDat],
            builder: (context) => MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (ctx) => Chuoi.of(ctx).t(K.tenApp),
              theme: _giaoDien(Brightness.light),
              darkTheme: _giaoDien(Brightness.dark),
              locale: switch (caiDat.ngonNgu) {
                NgonNgu.heThong => null,
                NgonNgu.vi => const Locale('vi'),
                NgonNgu.en => const Locale('en'),
              },
              supportedLocales: Chuoi.ngonNguHoTro,
              localizationsDelegates: const [
                Chuoi.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Máy đặt tiếng Anh → tiếng Anh; mọi ngôn ngữ khác → tiếng Việt.
              localeResolutionCallback: (locale, _) =>
                  locale?.languageCode == 'en'
                  ? const Locale('en')
                  : const Locale('vi'),
              home: const ManHinhChinh(),
            ),
          );
        },
      ),
    );
  }
}
