import 'dart:convert';

import 'danh_thiep.dart';
import 'phan_tich_danh_thiep.dart';

/// Số di động Việt Nam: 10 số bắt đầu 03/05/07/08/09, hoặc dạng +84 tương ứng.
bool _laSoDiDong(String so) {
  final s = so.replaceAll(RegExp(r'\D'), '');
  if (s.startsWith('84') && s.length == 11) return '35789'.contains(s[2]);
  if (s.startsWith('0') && s.length == 10) return '35789'.contains(s[1]);
  return false;
}

/// Tạo nội dung tệp `.vcf` (vCard 3.0, UTF-8, xuống dòng CRLF, gấp dòng 75 byte).
abstract final class TaoVCard {
  static const String mimeType = 'text/vcard';
  static const String phanMoRong = 'vcf';

  /// vCard của một danh thiếp (kết thúc bằng CRLF).
  static String tao(DanhThiep d) {
    final dong = <String>['BEGIN:VCARD', 'VERSION:3.0'];

    final hoTen = d.hoTen.trim();
    final fn = hoTen.isNotEmpty ? hoTen : d.tenHienThi;
    dong.add('FN:${_thoat(fn)}');
    dong.add('N:${_taoN(hoTen)}');
    if (hoTen.isEmpty && d.congTy.trim().isNotEmpty) {
      dong.add(
        'X-ABShowAs:COMPANY',
      ); // danh thiếp chỉ có công ty (Apple Contacts)
    }

    if (d.congTy.trim().isNotEmpty) dong.add('ORG:${_thoat(d.congTy.trim())}');
    if (d.chucVu.trim().isNotEmpty) {
      dong.add('TITLE:${_thoat(d.chucVu.trim())}');
    }

    for (final so in [d.dienThoai, d.dienThoaiKhac]) {
      final s = _motDong(so);
      if (s.isEmpty) continue;
      final loai = _laSoDiDong(s) ? 'CELL' : 'WORK,VOICE';
      dong.add('TEL;TYPE=$loai:$s');
    }

    final email = _motDong(d.email);
    if (email.isNotEmpty) dong.add('EMAIL;TYPE=INTERNET,WORK:$email');

    final web = _motDong(d.website).replaceAll(' ', '');
    if (web.isNotEmpty) {
      final coScheme = RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*://').hasMatch(web);
      dong.add('URL:${coScheme ? web : 'https://$web'}');
    }

    // ADR: hộp thư; mở rộng; đường; thành phố; tỉnh; mã bưu chính; quốc gia.
    // Địa chỉ Việt Nam không tách đáng tin cậy nên đặt trọn vào ô "đường".
    if (d.diaChi.trim().isNotEmpty) {
      dong.add('ADR;TYPE=WORK:;;${_thoat(d.diaChi.trim())};;;;');
    }
    if (d.ghiChu.trim().isNotEmpty) dong.add('NOTE:${_thoat(d.ghiChu.trim())}');

    dong.add('REV:${_rev(d.thoiGian)}');
    dong.add('END:VCARD');

    return '${dong.map(_gap).join('\r\n')}\r\n';
  }

  /// Nhiều danh thiếp trong một tệp `.vcf`.
  static String taoNhieu(Iterable<DanhThiep> ds) => ds.map(tao).join();

  /// Tên tệp an toàn (chỉ ASCII), ví dụ `danh_thiep_1700000000.vcf`.
  static String tenTep(DanhThiep d) {
    final id = d.id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'danh_thiep_${id.isEmpty ? 'moi' : id}.$phanMoRong';
  }

  /// Tên theo kiểu Việt Nam: họ = từ đầu, tên = từ cuối, tên đệm = phần giữa.
  /// (Tên viết kiểu phương Tây "John Smith" sẽ bị đảo họ/tên trong ô N,
  /// nhưng FN vẫn đúng nên danh bạ hiển thị đúng.)
  static String _taoN(String hoTen) {
    final tu = hoTen.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (tu.isEmpty) return ';;;;';
    if (tu.length == 1) return '${_thoat(tu.first)};;;;';
    final dem = tu.sublist(1, tu.length - 1).join(' ');
    return '${_thoat(tu.first)};${_thoat(tu.last)};${_thoat(dem)};;';
  }

  /// Thoát ký tự đặc biệt của giá trị văn bản vCard: \ ; , và xuống dòng.
  static String _thoat(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll(RegExp(r'\r\n|\r|\n'), '\\n');

  static String _motDong(String s) =>
      s.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();

  static String _rev(DateTime t) {
    final u = t.toUtc();
    String h(int n) => n.toString().padLeft(2, '0');
    return '${u.year.toString().padLeft(4, '0')}${h(u.month)}${h(u.day)}'
        'T${h(u.hour)}${h(u.minute)}${h(u.second)}Z';
  }

  /// Gấp dòng theo RFC 6350: tối đa 75 byte UTF-8 mỗi dòng, dòng tiếp theo bắt đầu
  /// bằng một dấu cách. Không cắt giữa một ký tự.
  static String _gap(String dong) {
    final sb = StringBuffer();
    var dem = 0;
    for (final r in dong.runes) {
      final ch = String.fromCharCode(r);
      final n = utf8.encode(ch).length;
      if (dem + n > 75) {
        sb.write('\r\n ');
        dem = 1;
      }
      sb.write(ch);
      dem += n;
    }
    return sb.toString();
  }
}

/// Đọc nội dung mã QR dạng vCard hoặc MECARD thành [KetQuaPhanTich].
abstract final class DocVCard {
  static final RegExp _reVcard = RegExp(r'BEGIN:VCARD', caseSensitive: false);
  static final RegExp _reMecard = RegExp(r'^MECARD:', caseSensitive: false);
  static final RegExp _reQp = RegExp(r'QUOTED-PRINTABLE', caseSensitive: false);

  /// Nội dung có phải vCard/MECARD hay không (để chọn trong các mã QR quét được).
  static bool nhanDang(String vanBan) {
    final s = _lamSach(vanBan);
    return _reMecard.hasMatch(s) || _reVcard.hasMatch(s);
  }

  /// Đọc vCard (2.1/3.0/4.0, chỉ thẻ đầu tiên) hoặc MECARD.
  /// Không nhận ra định dạng thì trả về [KetQuaPhanTich] rỗng.
  static KetQuaPhanTich doc(String vanBan) {
    final s = _lamSach(vanBan);
    if (_reMecard.hasMatch(s)) return _docMecard(s);
    if (_reVcard.hasMatch(s)) return _docVcard(s);
    return const KetQuaPhanTich();
  }

  static String _lamSach(String s) => s.replaceAll('\uFEFF', '').trim();

  // ---------------------------------------------------------------------------
  // vCard
  // ---------------------------------------------------------------------------

  static KetQuaPhanTich _docVcard(String s) {
    final chuan = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final tho = chuan
        .replaceAll(RegExp(r'\n[ \t]'), '')
        .split('\n'); // gỡ gấp dòng

    // Nối dòng quoted-printable bị ngắt bằng "=" ở cuối.
    final dong = <String>[];
    for (var i = 0; i < tho.length; i++) {
      var l = tho[i];
      if (_reQp.hasMatch(l)) {
        while (l.endsWith('=') && i + 1 < tho.length) {
          i++;
          l = l.substring(0, l.length - 1) + tho[i];
        }
      }
      dong.add(l);
    }

    var hoTen = '';
    var hoTenN = '';
    var congTy = '';
    var chucVu = '';
    var email = '';
    var website = '';
    var diaChi = '';
    final tels = <_Tel>[];
    final thua = <String>[];
    var trongThe = false;

    for (final l in dong) {
      final t = l.trim().toUpperCase();
      if (t == 'BEGIN:VCARD') {
        trongThe = true;
        continue;
      }
      if (t == 'END:VCARD') break;
      if (!trongThe) continue;

      final idx = l.indexOf(':');
      if (idx < 1) continue;
      final phanTen = l.substring(0, idx).split(';');
      var ten = phanTen.first.trim().toUpperCase();
      final cham = ten.lastIndexOf('.'); // "item1.TEL" → "TEL"
      if (cham >= 0) ten = ten.substring(cham + 1);
      final loai = phanTen.skip(1).map((e) => e.toUpperCase()).toList();
      var giaTri = l.substring(idx + 1);
      if (loai.any((p) => p.contains('QUOTED-PRINTABLE'))) {
        giaTri = _giaiQp(giaTri);
      }
      final loaiGop = loai.join(',');

      switch (ten) {
        case 'FN':
          if (hoTen.isEmpty) hoTen = _boThoat(giaTri).trim();
        case 'N':
          final c = _tach(
            giaTri,
            ';',
          ).map(_boThoat).map((e) => e.trim()).toList();
          String lay(int i) => i < c.length ? c[i] : '';
          // Thứ tự Việt Nam, khớp với TaoVCard: họ, tên đệm, tên.
          hoTenN = [
            lay(0),
            lay(2),
            lay(1),
          ].where((e) => e.isNotEmpty).join(' ');
        case 'ORG':
          final c = _tach(giaTri, ';')
              .map(_boThoat)
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          if (c.isNotEmpty && congTy.isEmpty) {
            congTy = c.first;
            thua.addAll(c.skip(1));
          }
        case 'TITLE':
          if (chucVu.isEmpty) chucVu = _boThoat(giaTri).trim();
        case 'ROLE':
          if (chucVu.isEmpty) chucVu = _boThoat(giaTri).trim();
        case 'TEL':
          if (loaiGop.contains('FAX')) break;
          final so = _chuanHoaSdt(_boThoat(giaTri));
          if (so.isNotEmpty) {
            tels.add(
              _Tel(
                so,
                diDong:
                    loaiGop.contains('CELL') ||
                    loaiGop.contains('MOBILE') ||
                    _laSoDiDong(so),
              ),
            );
          }
        case 'EMAIL':
          final e = _boThoat(giaTri)
              .trim()
              .replaceFirst(RegExp(r'^mailto:', caseSensitive: false), '')
              .toLowerCase();
          if (e.isEmpty) break;
          if (email.isEmpty) {
            email = e;
          } else {
            thua.add(e);
          }
        case 'URL':
          final w = _chuanHoaWeb(_boThoat(giaTri));
          if (w.isEmpty) break;
          if (website.isEmpty) {
            website = w;
          } else {
            thua.add(w);
          }
        case 'ADR':
          final c = _tach(
            giaTri,
            ';',
          ).map(_boThoat).map((e) => e.trim()).toList();
          String lay(int i) => i < c.length ? c[i] : '';
          // [0]=hộp thư [1]=mở rộng [2]=đường [3]=thành phố [4]=tỉnh [5]=mã [6]=quốc gia
          final dc = [
            lay(1),
            lay(2),
            lay(3),
            lay(4),
            lay(5),
            lay(6),
          ].where((e) => e.isNotEmpty).join(', ');
          if (dc.isEmpty) break;
          if (diaChi.isEmpty) {
            diaChi = dc;
          } else {
            thua.add(dc);
          }
        case 'NOTE':
          final n = _boThoat(giaTri).trim();
          if (n.isNotEmpty) thua.add(n);
      }
    }

    return _ghep(
      hoTen: hoTen.isNotEmpty ? hoTen : hoTenN,
      chucVu: chucVu,
      congTy: congTy,
      email: email,
      website: website,
      diaChi: diaChi,
      tels: tels,
      thua: thua,
    );
  }

  // ---------------------------------------------------------------------------
  // MECARD:N:Ho,Ten;TEL:...;EMAIL:...;ORG:...;ADR:...;URL:...;NOTE:...;;
  // ---------------------------------------------------------------------------

  static KetQuaPhanTich _docMecard(String s) {
    final noiDung = s.substring('MECARD:'.length);
    var hoTen = '';
    var congTy = '';
    var chucVu = '';
    var email = '';
    var website = '';
    var diaChi = '';
    final tels = <_Tel>[];
    final thua = <String>[];

    for (final muc in _tach(noiDung, ';')) {
      final i = muc.indexOf(':');
      if (i < 1) continue;
      final khoa = muc.substring(0, i).trim().toUpperCase();
      final giaTri = muc.substring(i + 1);

      switch (khoa) {
        case 'N':
          // "Họ,Tên" → "Họ Tên" (thứ tự Việt Nam); không có dấu phẩy thì giữ nguyên.
          final c = _tach(
            giaTri,
            ',',
          ).map(_boThoat).map((e) => e.trim()).where((e) => e.isNotEmpty);
          if (hoTen.isEmpty) hoTen = c.join(' ');
        case 'TEL':
        case 'TEL-AV':
          final so = _chuanHoaSdt(_boThoat(giaTri));
          if (so.isNotEmpty) tels.add(_Tel(so, diDong: _laSoDiDong(so)));
        case 'EMAIL':
          final e = _boThoat(giaTri).trim().toLowerCase();
          if (e.isEmpty) break;
          if (email.isEmpty) {
            email = e;
          } else {
            thua.add(e);
          }
        case 'URL':
          final w = _chuanHoaWeb(_boThoat(giaTri));
          if (w.isEmpty) break;
          if (website.isEmpty) {
            website = w;
          } else {
            thua.add(w);
          }
        case 'ORG':
          if (congTy.isEmpty) congTy = _boThoat(giaTri).trim();
        case 'TITLE':
          if (chucVu.isEmpty) chucVu = _boThoat(giaTri).trim();
        case 'ADR':
          // "hộp thư,phòng,đường,thành phố,…": ghép các phần không rỗng.
          final dc = _tach(giaTri, ',')
              .map(_boThoat)
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .join(', ');
          if (dc.isNotEmpty && diaChi.isEmpty) diaChi = dc;
        case 'NOTE':
          final n = _boThoat(giaTri).trim();
          if (n.isNotEmpty) thua.add(n);
      }
    }

    return _ghep(
      hoTen: hoTen,
      chucVu: chucVu,
      congTy: congTy,
      email: email,
      website: website,
      diaChi: diaChi,
      tels: tels,
      thua: thua,
    );
  }

  // ---------------------------------------------------------------------------
  // Dùng chung
  // ---------------------------------------------------------------------------

  /// Chọn số chính (ưu tiên di động) và số phụ; số còn lại vào `dongConLai`.
  static KetQuaPhanTich _ghep({
    required String hoTen,
    required String chucVu,
    required String congTy,
    required String email,
    required String website,
    required String diaChi,
    required List<_Tel> tels,
    required List<String> thua,
  }) {
    final rieng = <_Tel>[];
    for (final t in tels) {
      final khoa = t.so.replaceAll(RegExp(r'\D'), '');
      if (!rieng.any((x) => x.so.replaceAll(RegExp(r'\D'), '') == khoa)) {
        rieng.add(t);
      }
    }
    _Tel? chinh;
    for (final t in rieng) {
      if (t.diDong) {
        chinh = t;
        break;
      }
    }
    chinh ??= rieng.isNotEmpty ? rieng.first : null;
    _Tel? phu;
    for (final t in rieng) {
      if (t != chinh) {
        phu = t;
        break;
      }
    }

    return KetQuaPhanTich(
      hoTen: hoTen,
      chucVu: chucVu,
      congTy: congTy,
      dienThoai: chinh?.so ?? '',
      dienThoaiKhac: phu?.so ?? '',
      email: email,
      website: website,
      diaChi: diaChi,
      dongConLai: [
        ...thua,
        ...rieng.where((t) => t != chinh && t != phu).map((t) => t.so),
      ],
    );
  }

  /// Chuẩn hoá số cho cùng dạng hiển thị với bộ phân tích OCR ("0912 345 678").
  static String _chuanHoaSdt(String tho) {
    final s = tho
        .replaceFirst(RegExp(r'^tel:', caseSensitive: false), '')
        .trim();
    if (s.isEmpty) return '';
    final chuan = BoPhanTichDanhThiep.phanTich(s).dienThoai;
    return chuan.isNotEmpty ? chuan : s;
  }

  static String _chuanHoaWeb(String tho) {
    var w = tho.trim();
    w = w.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
    w = w.replaceAll(RegExp(r'/+$'), '');
    return w;
  }

  /// Tách theo [ngan] nhưng bỏ qua dấu đã được thoát bằng `\`. Giữ nguyên các ký tự thoát.
  static List<String> _tach(String s, String ngan) {
    final kq = <String>[];
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '\\' && i + 1 < s.length) {
        sb.write(c);
        sb.write(s[i + 1]);
        i++;
      } else if (c == ngan) {
        kq.add(sb.toString());
        sb.clear();
      } else {
        sb.write(c);
      }
    }
    kq.add(sb.toString());
    return kq;
  }

  /// Bỏ ký tự thoát: `\n`/`\N` → xuống dòng; `\x` → `x`.
  static String _boThoat(String s) {
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '\\' && i + 1 < s.length) {
        final n = s[i + 1];
        sb.write(n == 'n' || n == 'N' ? '\n' : n);
        i++;
      } else {
        sb.write(c);
      }
    }
    return sb.toString();
  }

  /// Giải mã quoted-printable (vCard 2.1) theo UTF-8.
  static String _giaiQp(String s) {
    final bytes = <int>[];
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '=' && i + 2 < s.length) {
        final hex = int.tryParse(s.substring(i + 1, i + 3), radix: 16);
        if (hex != null) {
          bytes.add(hex);
          i += 2;
          continue;
        }
      }
      bytes.addAll(utf8.encode(c));
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}

class _Tel {
  const _Tel(this.so, {required this.diDong});
  final String so;
  final bool diDong;
}
