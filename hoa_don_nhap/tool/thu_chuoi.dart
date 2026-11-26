import 'package:hoa_don_nhap/ngon_ngu/du_lieu_chuoi.dart';

var _loi = 0;
void kiem(String ten, bool dung) {
  if (!dung) _loi++;
  print('${dung ? 'OK  ' : 'LỖI'} $ten');
}

Set<String> thamSo(String s) =>
    RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  kiem('tiếng Việt đủ khoá', K.values.every(chuoiVi.containsKey));
  kiem('tiếng Anh đủ khoá', K.values.every(chuoiEn.containsKey));
  kiem(
    'không thừa khoá',
    chuoiVi.length == K.values.length && chuoiEn.length == K.values.length,
  );
  kiem(
    'không chuỗi rỗng',
    [...chuoiVi.values, ...chuoiEn.values].every((s) => s.trim().isNotEmpty),
  );

  final lech = [
    for (final k in K.values)
      if (thamSo(chuoiVi[k]!).difference(thamSo(chuoiEn[k]!)).isNotEmpty ||
          thamSo(chuoiEn[k]!).difference(thamSo(chuoiVi[k]!)).isNotEmpty)
        k.name,
  ];
  kiem(
    'tham số {..} khớp giữa vi và en ${lech.isEmpty ? '' : lech}',
    lech.isEmpty,
  );

  final dt = K.values.where((k) => k.name.startsWith('dt')).length;
  print('     số khoá danh thiếp: $dt');
  kiem('có 51 khoá dt*', dt == 51);
  kiem(
    'dienThamSo',
    dienThamSo(chuoiVi[K.dtSoDanhThiep]!, {'n': '3'}) == '3 danh thiếp',
  );

  print(_loi == 0 ? '\nTẤT CẢ OK' : '\n$_loi mục LỖI');
}
