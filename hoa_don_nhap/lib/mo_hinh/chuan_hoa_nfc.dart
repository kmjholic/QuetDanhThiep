/// Chuẩn hoá chữ tiếng Việt về dạng NFC (dấu gộp sẵn vào chữ cái: "ậ" là MỘT ký tự).
/// ML Kit và vCard của một số máy có thể trả dạng NFD ("a" + các dấu rời) làm bộ phân tích Regex hụt chữ.
///
/// Chỉ xử lý 12 nguyên âm tiếng Việt (a ă â e ê i o ô ơ u ư y) và 5 dấu thanh; ký tự khác giữ nguyên.
/// Dart không có sẵn NFC, và dự án không thêm gói unicode chỉ vì việc này.
library;

/// Mỗi hàng: chữ gốc, rồi các dạng [không dấu, huyền, sắc, ngã, hỏi, nặng].
const _hang = <String>[
  'aàáãảạ',
  'ăằắẵẳặ',
  'âầấẫẩậ',
  'eèéẽẻẹ',
  'êềếễểệ',
  'iìíĩỉị',
  'oòóõỏọ',
  'ôồốỗổộ',
  'ơờớỡởợ',
  'uùúũủụ',
  'ưừứữửự',
  'yỳýỹỷỵ',
];

/// Dấu thanh rời → chỉ số trong hàng.
const _ton = <int, int>{0x0300: 1, 0x0301: 2, 0x0303: 3, 0x0309: 4, 0x0323: 5};

/// Dấu phụ rời (mũ, á, râu) → {chữ gốc: chữ sau khi thêm dấu}.
const _dau = <int, Map<String, String>>{
  0x0302: {'a': 'â', 'e': 'ê', 'o': 'ô'},
  0x0306: {'a': 'ă'},
  0x031B: {'o': 'ơ', 'u': 'ư'},
};

/// chữ gốc → hàng.
final Map<String, String> _bang = {for (final h in _hang) h[0]: h};

/// bất kỳ chữ nào trong bảng → (chữ gốc không dấu thanh, chỉ số dấu thanh).
final Map<String, (String, int)> _thongTin = {
  for (final h in _hang)
    for (var i = 0; i < h.length; i++) h[i]: (h[0], i),
};

String chuanHoaNfcViet(String s) {
  if (!s.runes.any((r) => r >= 0x0300 && r <= 0x036F)) {
    return s; // đường nhanh: không có dấu rời
  }
  final r = s.runes.toList();
  final out = StringBuffer();
  var i = 0;
  while (i < r.length) {
    final c = String.fromCharCode(r[i]);
    final thuong = c.toLowerCase();
    final tt = _thongTin[thuong];
    i++;
    if (tt == null) {
      out.write(c);
      continue;
    }
    var goc = tt.$1;
    var ton = tt.$2;
    while (i < r.length) {
      final m = r[i];
      final tonMoi = _ton[m];
      if (tonMoi != null) {
        if (ton != 0) break; // đã có dấu thanh: để nguyên dấu thừa
        ton = tonMoi;
        i++;
        continue;
      }
      final gocMoi = _dau[m]?[goc];
      if (gocMoi != null) {
        goc = gocMoi;
        i++;
        continue;
      }
      break;
    }
    final kq = _bang[goc]![ton];
    out.write(c == thuong ? kq : kq.toUpperCase());
  }
  return out.toString();
}
