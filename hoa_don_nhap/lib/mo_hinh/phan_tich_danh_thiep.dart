import 'danh_thiep.dart';

/// Kết quả tách trường từ văn bản OCR của một danh thiếp. Trường không tìm thấy là chuỗi rỗng.
class KetQuaPhanTich {
  const KetQuaPhanTich({
    this.hoTen = '',
    this.chucVu = '',
    this.congTy = '',
    this.dienThoai = '',
    this.dienThoaiKhac = '',
    this.email = '',
    this.website = '',
    this.diaChi = '',
    this.dongConLai = const [],
  });

  final String hoTen;
  final String chucVu;
  final String congTy;
  final String dienThoai;
  final String dienThoaiKhac;
  final String email;
  final String website;
  final String diaChi;

  /// Các dòng (hoặc số/email/web thừa) không xếp được vào trường nào.
  final List<String> dongConLai;

  /// Không tách được trường thông tin liên hệ nào.
  bool get rong =>
      hoTen.isEmpty &&
      chucVu.isEmpty &&
      congTy.isEmpty &&
      dienThoai.isEmpty &&
      dienThoaiKhac.isEmpty &&
      email.isEmpty &&
      website.isEmpty &&
      diaChi.isEmpty;

  /// Giữ giá trị của đối tượng này, chỉ lấy từ [khac] cho các trường còn trống.
  /// Dùng để gộp: `ketQuaQr.boSung(ketQuaOcr)`.
  KetQuaPhanTich boSung(KetQuaPhanTich khac) {
    String chon(String a, String b) => a.isNotEmpty ? a : b;
    return KetQuaPhanTich(
      hoTen: chon(hoTen, khac.hoTen),
      chucVu: chon(chucVu, khac.chucVu),
      congTy: chon(congTy, khac.congTy),
      dienThoai: chon(dienThoai, khac.dienThoai),
      dienThoaiKhac: chon(dienThoaiKhac, khac.dienThoaiKhac),
      email: chon(email, khac.email),
      website: chon(website, khac.website),
      diaChi: chon(diaChi, khac.diaChi),
      dongConLai: dongConLai.isNotEmpty ? dongConLai : khac.dongConLai,
    );
  }

  /// Chuyển thành [DanhThiep] để chỉnh sửa/lưu.
  DanhThiep taoDanhThiep({
    required String id,
    required DateTime thoiGian,
    NguonDanhThiep nguon = NguonDanhThiep.ocr,
    String? duongDanAnh,
    String ghiChu = '',
  }) {
    return DanhThiep(
      id: id,
      thoiGian: thoiGian,
      hoTen: hoTen,
      chucVu: chucVu,
      congTy: congTy,
      dienThoai: dienThoai,
      dienThoaiKhac: dienThoaiKhac,
      email: email,
      website: website,
      diaChi: diaChi,
      ghiChu: ghiChu,
      duongDanAnh: duongDanAnh,
      nguon: nguon,
    );
  }
}

/// Bộ tách trường danh thiếp bằng Regex và heuristic. Dart thuần, chạy offline.
///
/// Quy trình: tách dòng → rút email, website, số điện thoại (thay bằng dấu đánh dấu)
/// → bỏ nhãn "Tel:", "Email:"… → xếp từng dòng còn lại vào chức vụ / công ty / địa chỉ
/// → chọn dòng giống họ tên nhất → dòng chữ in hoa còn lại coi là công ty.
abstract final class BoPhanTichDanhThiep {
  static KetQuaPhanTich phanTich(String vanBan) {
    final tt = _ThongTinLienLac();
    final dong = <_Dong>[];

    for (final tho in _tachDong(vanBan)) {
      var du = _xuLyDong(tho, tt);
      du = _catTheoMau(du, _reNhanSauTach);
      du = du.replaceAll(_danhDau, ' ');
      du = _lamSach(du);
      final kd = _khongDau(du);
      if (_demChu(kd) < 2 || _reChiNhan.hasMatch(kd)) continue;
      dong.add(_Dong(du, dong.length));
    }

    var chucVu = '';
    var congTy = '';
    var chucStt = -1;
    final diaChi = <String>[];
    final chuaPhanLoai = <_Dong>[];
    final khac = <_Dong>[]; // dòng chức vụ/công ty thừa: không dùng làm họ tên

    for (final d in dong) {
      final kd = _khongDau(d.text);

      if (_reNhanDiaChi.hasMatch(kd)) {
        final dc = _lamSach(_catTheoMau(d.text, _reNhanDiaChi));
        if (dc.isNotEmpty) diaChi.add(dc);
        continue;
      }

      final soTu = d.text.split(' ').length;
      final batDauChuc = _reChucBatDau.hasMatch(kd);
      final cuoiChuc = _reChucCuoi.hasMatch(kd) && soTu <= 6;
      final coCongTy = _reCongTy.hasMatch(kd);

      if (batDauChuc || cuoiChuc) {
        if (chucVu.isEmpty) {
          chucVu = d.text;
          chucStt = d.stt;
        } else {
          khac.add(d);
        }
      } else if (coCongTy) {
        if (congTy.isEmpty) {
          congTy = d.text;
        } else if (_laDiaChi(kd, d.text)) {
          diaChi.add(d.text);
        } else {
          khac.add(d);
        }
      } else if (_laDiaChi(kd, d.text)) {
        diaChi.add(d.text);
      } else if (_reChucTrong.hasMatch(kd) && soTu <= 7) {
        if (chucVu.isEmpty) {
          chucVu = d.text;
          chucStt = d.stt;
        } else {
          khac.add(d);
        }
      } else {
        chuaPhanLoai.add(d);
      }
    }

    // Chọn dòng giống họ tên nhất trong các dòng chưa phân loại.
    var hoTen = '';
    _Dong? dongTen;
    var diemTot = -1;
    for (var k = 0; k < chuaPhanLoai.length; k++) {
      final d = chuaPhanLoai[k];
      final kq = _tenHopLe(d.text);
      if (kq == null) continue;
      var diem = 1 + (k < 3 ? 3 - k : 0); // càng ở trên càng được điểm
      if (kq.hoVn) diem += 3; // họ phổ biến của người Việt
      if (chucStt >= 0 && (d.stt == chucStt - 1 || d.stt == chucStt + 1)) {
        diem += 2; // nằm sát dòng chức vụ
      }
      if (kq.soTu <= 4) diem += 1;
      if (diem > diemTot) {
        diemTot = diem;
        hoTen = kq.ten;
        dongTen = d;
      }
    }

    final conLaiChua = chuaPhanLoai.where((d) => d != dongTen).toList();

    // Chưa có công ty: lấy dòng chữ IN HOA đầu tiên còn lại.
    if (congTy.isEmpty) {
      for (final d in conLaiChua) {
        if (_giongTenCongTy(d.text)) {
          congTy = d.text;
          conLaiChua.remove(d);
          break;
        }
      }
    }

    // Số điện thoại: ưu tiên số di động làm số chính.
    _Sdt? chinh;
    for (final s in tt.dienThoai) {
      if (s.diDong) {
        chinh = s;
        break;
      }
    }
    chinh ??= tt.dienThoai.isNotEmpty ? tt.dienThoai.first : null;
    _Sdt? phu;
    for (final s in tt.dienThoai) {
      if (chinh != null && s.khoa != chinh.khoa) {
        phu = s;
        break;
      }
    }

    final conLai = [...conLaiChua, ...khac]
      ..sort((a, b) => a.stt.compareTo(b.stt));
    final thua = <String>[
      ...conLai.map((d) => d.text),
      ...tt.emails.skip(1),
      ...tt.websites.skip(1),
      ...tt.dienThoai
          .where((s) => s != chinh && s != phu)
          .map((s) => s.hienThi),
    ];

    return KetQuaPhanTich(
      hoTen: hoTen,
      chucVu: chucVu,
      congTy: congTy,
      dienThoai: chinh?.hienThi ?? '',
      dienThoaiKhac: phu?.hienThi ?? '',
      email: tt.emails.isNotEmpty ? tt.emails.first : '',
      website: tt.websites.isNotEmpty ? tt.websites.first : '',
      diaChi: _noiDiaChi(diaChi),
      dongConLai: thua,
    );
  }

  // ---------------------------------------------------------------------------
  // Hằng số và biểu thức chính quy
  // ---------------------------------------------------------------------------

  /// Thay thế phần đã rút ra (email/web/số) để còn nhận ra nhãn đứng trước nó.
  static const String _danhDau = '\u0001';

  static final RegExp _reEmail = RegExp(
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}',
  );

  /// OCR hay chèn khoảng trắng quanh dấu @.
  static final RegExp _reQuanhAt = RegExp(r'(\S)\s*@\s*(\S)');

  static final RegExp _reWeb = RegExp(
    r'(?:https?://)?(?:www\.)?[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.'
    r'(?:com|net|org|edu|gov|info|biz|io|vn|asia|app|dev|store|shop)'
    r'(?:\.vn)?(?:/[^\s,;]*)?',
    caseSensitive: false,
  );

  /// Ứng viên số điện thoại: chuỗi số cùng dấu cách, chấm, gạch, ngoặc.
  static final RegExp _reSdt = RegExp(r'(?<![A-Za-z0-9_@])[+(]*\d[\d\s.()–-]*');

  static final RegExp _reFax = RegExp(r'(?:\bfax|\bf)\s*[:./-]*\s*\(?\s*$');
  static final RegExp _reTelFax = RegExp(r'tel\s*/\s*fax\s*[:./-]*\s*$');

  /// Mã số thuế, số tài khoản: không phải số điện thoại (so khớp trên bản không dấu).
  static final RegExp _reBoSo = RegExp(
    r'\b(?:mst|ma so thue|tax\s*(?:code|id|no)|vat\s*(?:no|code)?|stk|'
    r'so tai khoan|account\s*(?:no|number)?|a/c)\s*[:.]?\s*[0-9][0-9 .-]*',
  );

  static const String _nhan =
      'telephone|tel|phone|mobile|mob|cell|hotline|fax|sdt|dtdd|dt|dd|'
      'dien thoai|di dong|zalo|viber|whatsapp|e-mail|email|mail|website|web|'
      'url|lien he|contact';

  /// Nhãn đứng ngay trước phần đã rút ra ("Tel: ▮", "M: ▮").
  static final RegExp _reNhanSauTach = RegExp(
    r'(?:\b(?:' + _nhan + r')\b[\s/,&:.-]*)+\u0001|\b[mtpfew]\s*[:.]\s*\u0001',
  );

  /// Dòng chỉ còn lại nhãn trơ trọi.
  static final RegExp _reChiNhan = RegExp(r'^(?:' + _nhan + r')\s*[:./-]*$');

  static final RegExp _reNhanDiaChi = RegExp(
    r'^(?:(?:dia chi|address)\b\s*[:.-]*|(?:add|dc|d/c)\s*[:.-]+)\s*',
  );

  static final RegExp _reDiaChi = RegExp(
    r'\b(?:so|duong|pho|phuong|quan|huyen|thanh pho|tp|tinh|ngo|ngach|hem|'
    r'tang|toa nha|khu|xa|thon|kcn|kdt|street|st|road|rd|ward|district|'
    r'floor|building|city|lane|avenue|ave|blvd|p|q)\b',
  );

  static final RegExp _reTinh = RegExp(
    r'\b(?:viet nam|vietnam|ha noi|hanoi|ho chi minh|hcm|sai gon|saigon|'
    r'da nang|hai phong|can tho)\b',
  );

  static const String _tuChucVu =
      'tong giam doc|pho tong giam doc|pho giam doc|giam doc|truong phong|'
      'pho phong|truong nhom|truong bo phan|truong khoa|pho chu tich|chu tich|'
      'chu nhiem|chuyen vien|chuyen gia|ky su|nhan vien|ke toan|giam sat|'
      'quan ly|tro ly|co van|bac si|luat su|kien truc su|thu ky|giang vien|'
      'giao su|lap trinh vien|chu cua hang|founder|co-founder|ceo|cto|cfo|coo|'
      'cmo|cio|director|manager|president|vice president|vp|engineer|'
      'developer|consultant|executive|supervisor|specialist|officer|assistant|'
      'head of|chief|owner|designer|architect|accountant|secretary';

  static final RegExp _reChucBatDau = RegExp(r'^(?:' + _tuChucVu + r')\b');
  static final RegExp _reChucCuoi = RegExp(r'\b(?:' + _tuChucVu + r')\.?$');
  static final RegExp _reChucTrong = RegExp(r'\b(?:' + _tuChucVu + r')\b');

  static final RegExp _reCongTy = RegExp(
    r'\b(?:cong ty|tnhh|co phan|cp|jsc|tap doan|ltd|limited|corp|'
    r'corporation|inc|company|group|holdings|joint stock|ngan hang|bank|'
    r'dai hoc|hoc vien|university|college|school|studio|agency|enterprise|'
    r'enterprises|trading|solutions|technologies|technology|tech|software|'
    r'logistics|express|dntn|doanh nghiep|hop tac xa|htx|nha hang|khach san|'
    r'hotel|resort|phong kham|benh vien|clinic|hospital|llc|pte|gmbh)\b|'
    r'\bco\.',
  );

  /// Học vị, danh xưng đứng trước tên: bỏ khi đánh giá và khi lưu họ tên.
  static final RegExp _reXungHo = RegExp(
    r'^(?:mr|mrs|ms|miss|dr|prof|gs|pgs|ts|ths|bs|ks|ls)\b[.\s]+',
  );

  /// Chỉ chữ cái, khoảng trắng, chấm, gạch nối, nháy.
  static final RegExp _reChuTen = RegExp(
    r"^[\p{L}\p{M}][\p{L}\p{M} .'’-]*$",
    unicode: true,
  );

  static const Set<String> _hoVn = {
    'nguyen',
    'tran',
    'le',
    'pham',
    'hoang',
    'huynh',
    'phan',
    'vu',
    'vo',
    'dang',
    'bui',
    'do',
    'ho',
    'ngo',
    'duong',
    'ly',
    'dinh',
    'trinh',
    'doan',
    'mai',
    'lam',
    'ta',
    'to',
    'cao',
    'chu',
    'ha',
    'hua',
    'kieu',
    'la',
    'luu',
    'luong',
    'mac',
    'quach',
    'thai',
    'trieu',
    'truong',
    'van',
    'vuong',
    'tu',
    'diep',
    'nghiem',
    'phung',
    'tang',
    'thach',
    'tong',
    'au',
    'banh',
    'bach',
    'cu',
    'dam',
    'giang',
    'khuat',
    'nong',
  };

  /// Từ chữ thường được phép nằm trong tên ("Nguyễn thị Lan", "Van der Berg").
  static const Set<String> _tieuTu = {
    'van',
    'von',
    'de',
    'da',
    'di',
    'du',
    'la',
    'le',
    'bin',
    'ben',
    'al',
    'el',
    'thi',
  };

  /// Địa danh: hai từ viết hoa nhưng không phải họ tên.
  static const Set<String> _diaDanh = {
    'viet nam',
    'vietnam',
    'ha noi',
    'hanoi',
    'ho chi minh',
    'sai gon',
    'saigon',
    'da nang',
    'hai phong',
    'can tho',
  };

  // ---------------------------------------------------------------------------
  // Xử lý chuỗi
  // ---------------------------------------------------------------------------

  static const Map<String, String> _nhomDau = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<String, String> _bangBoDau = () {
    final m = <String, String>{};
    _nhomDau.forEach((goc, cacDau) {
      for (final c in cacDau.split('')) {
        m[c] = goc;
      }
    });
    return m;
  }();

  /// Viết thường và bỏ dấu tiếng Việt, **giữ nguyên độ dài** chuỗi (tính theo đơn vị UTF-16)
  /// để vị trí khớp trên bản này dùng lại được trên chuỗi gốc. Giả định văn bản dạng NFC.
  static String _khongDau(String s) {
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final u = s[i];
      final thuong = u.toLowerCase();
      final c = thuong.length == 1 ? thuong : u;
      sb.write(_bangBoDau[c] ?? c);
    }
    return sb.toString();
  }

  /// Thay các đoạn khớp [re] (tìm trên bản không dấu) bằng một khoảng trắng trong chuỗi gốc.
  static String _catTheoMau(String s, RegExp re) {
    final kd = _khongDau(s);
    final sb = StringBuffer();
    var cuoi = 0;
    for (final m in re.allMatches(kd)) {
      sb.write(s.substring(cuoi, m.start));
      sb.write(' ');
      cuoi = m.end;
    }
    sb.write(s.substring(cuoi));
    return sb.toString();
  }

  static int _demChu(String kd) => RegExp(r'[a-z]').allMatches(kd).length;

  static String _lamSach(String s) {
    var t = s.replaceAll(RegExp(r'\s+'), ' ');
    t = t.replaceAll(RegExp(r'^[\s,;:|/.\-–•·]+'), '');
    t = t.replaceAll(RegExp(r'[\s,;:|/\-–•·]+$'), '');
    return t.trim();
  }

  /// Tách thành các dòng/đoạn; `|`, `•`, `·`, tab cũng là chỗ ngắt.
  static List<String> _tachDong(String vanBan) {
    final kq = <String>[];
    for (final dong in vanBan.split(RegExp(r'[\r\n]+'))) {
      for (final manh in dong.split(RegExp(r'[|•●▪·\t]'))) {
        final s = manh.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (s.isNotEmpty) kq.add(s);
      }
    }
    return kq;
  }

  static bool _laDiaChi(String kd, String text) {
    final coSo = RegExp(r'\d').hasMatch(text);
    final coPhay = text.contains(',');
    return (_reDiaChi.hasMatch(kd) && (coSo || coPhay)) ||
        (_reTinh.hasMatch(kd) && coPhay);
  }

  static String _noiDiaChi(List<String> cacDong) {
    final sb = StringBuffer();
    for (final d in cacDong) {
      if (sb.isEmpty) {
        sb.write(d);
      } else {
        final dangCo = sb.toString();
        sb.write(dangCo.endsWith(',') ? ' $d' : ', $d');
      }
    }
    return sb.toString();
  }

  /// Dòng toàn chữ IN HOA, không số, không quá dài: có thể là tên công ty.
  static bool _giongTenCongTy(String text) {
    final kd = _khongDau(text);
    return text == text.toUpperCase() &&
        _demChu(kd) >= 3 &&
        !RegExp(r'\d').hasMatch(text) &&
        text.split(' ').length <= 8;
  }

  // ---------------------------------------------------------------------------
  // Rút email, website, số điện thoại
  // ---------------------------------------------------------------------------

  /// Rút liên lạc khỏi dòng, thay mỗi phần rút được bằng [_danhDau]; trả về phần còn lại.
  static String _xuLyDong(String dong, _ThongTinLienLac tt) {
    var s = _catTheoMau(dong, _reBoSo);
    s = s.replaceAllMapped(_reQuanhAt, (m) => '${m[1]}@${m[2]}');
    s = s.replaceAllMapped(_reEmail, (m) {
      tt.emails.add(m[0]!.toLowerCase());
      return _danhDau;
    });
    s = s.replaceAllMapped(_reWeb, (m) {
      final w = _chuanHoaWeb(m[0]!);
      if (w.isEmpty) return m[0]!;
      tt.websites.add(w);
      return _danhDau;
    });
    return _taoDienThoai(s, tt);
  }

  static String _chuanHoaWeb(String tho) {
    var w = tho.trim().toLowerCase();
    w = w.replaceFirst(RegExp(r'^https?://'), '');
    w = w.replaceAll(RegExp(r'[/.,;)]+$'), '');
    return w.contains('.') ? w : '';
  }

  static String _taoDienThoai(String s, _ThongTinLienLac tt) {
    final kd = _khongDau(s);
    final sb = StringBuffer();
    var cuoi = 0;
    var truoc = 0;
    for (final m in _reSdt.allMatches(s)) {
      final tienTo = kd.substring(truoc, m.start);
      truoc = m.end;
      final ds = _tachSdt(m[0]!);
      if (ds.isEmpty) continue; // không phải số điện thoại: giữ nguyên chữ
      final laFax = _reFax.hasMatch(tienTo) && !_reTelFax.hasMatch(tienTo);
      if (!laFax) {
        for (final d in ds) {
          if (!tt.dienThoai.any((x) => x.khoa == d.khoa)) tt.dienThoai.add(d);
        }
      }
      sb.write(s.substring(cuoi, m.start));
      sb.write(_danhDau);
      cuoi = m.end;
    }
    sb.write(s.substring(cuoi));
    return sb.toString();
  }

  /// Một ứng viên có thể chứa nhiều số hoặc số dính chữ số khác ("1. 0912 345 678"):
  /// thử các cửa sổ token dài nhất trước, từ trái sang phải.
  static List<_Sdt> _tachSdt(String tho) {
    final tu = tho
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final kq = <_Sdt>[];
    var i = 0;
    while (i < tu.length) {
      var tim = false;
      for (var j = tu.length; j > i; j--) {
        final sdt = _chuanHoaSdt(tu.sublist(i, j).join(' '));
        if (sdt != null) {
          kq.add(sdt);
          i = j;
          tim = true;
          break;
        }
      }
      if (!tim) i++;
    }
    return kq;
  }

  /// Nhận: di động 10 số (03/05/07/08/09), máy bàn 10–11 số bắt đầu bằng 0,
  /// +84 / 84 / 0084, đường dây nóng 1800/1900, số quốc tế có dấu +.
  static _Sdt? _chuanHoaSdt(String tho) {
    var so = tho.replaceAll(RegExp(r'\D'), '');
    if (so.isEmpty) return null;

    var quocTe = RegExp(r'^[\s(]*\+').hasMatch(tho);
    if (!quocTe && so.startsWith('00')) {
      quocTe = true;
      so = so.substring(2);
    }
    if (!quocTe &&
        so.startsWith('84') &&
        (so.length == 11 || so.length == 12)) {
      quocTe = true;
    }

    if (quocTe) {
      if (so.startsWith('840')) so = '84${so.substring(3)}'; // "+84 (0) 912…"
      if (so.length < 9 || so.length > 14) return null;
      if (so.startsWith('84')) {
        final dd = so.substring(2);
        if (dd.length < 9 || dd.length > 10) return null;
        return _Sdt(
          '+84 ${_nhomVn(dd)}',
          diDong: dd.length == 9 && '35789'.contains(dd[0]),
          khoa: so,
        );
      }
      return _Sdt('+$so', diDong: false, khoa: so);
    }

    if (so.startsWith('0') && (so.length == 10 || so.length == 11)) {
      final hienThi = so.length == 10
          ? '${so.substring(0, 4)} ${so.substring(4, 7)} ${so.substring(7)}'
          : '${so.substring(0, 3)} ${so.substring(3, 7)} ${so.substring(7)}';
      return _Sdt(
        hienThi,
        diDong: so.length == 10 && '35789'.contains(so[1]),
        khoa: '84${so.substring(1)}',
      );
    }

    if ((so.startsWith('1800') || so.startsWith('1900')) &&
        so.length >= 8 &&
        so.length <= 10) {
      return _Sdt(
        '${so.substring(0, 4)} ${so.substring(4)}',
        diDong: false,
        khoa: so,
      );
    }
    return null;
  }

  static String _nhomVn(String dd) => dd.length == 9
      ? '${dd.substring(0, 3)} ${dd.substring(3, 6)} ${dd.substring(6)}'
      : '${dd.substring(0, 2)} ${dd.substring(2, 6)} ${dd.substring(6)}';

  // ---------------------------------------------------------------------------
  // Nhận diện họ tên
  // ---------------------------------------------------------------------------

  /// Trả về họ tên đã chuẩn hoá nếu [dong] trông giống một họ tên, ngược lại null.
  /// Hợp lệ: 2–5 từ, chỉ chữ; mọi từ Viết Hoa Đầu, hoặc mọi từ IN HOA. Họ tên IN HOA
  /// được đổi sang Viết Hoa Đầu. Bỏ danh xưng/học vị đứng trước (Mr., TS., ThS.…).
  static ({String ten, bool hoVn, int soTu})? _tenHopLe(String dong) {
    var s = dong.trim();
    final mXungHo = _reXungHo.firstMatch(_khongDau(s));
    if (mXungHo != null) s = s.substring(mXungHo.end).trim();
    if (s.isEmpty || !_reChuTen.hasMatch(s)) return null;

    final tu = s.split(RegExp(r'\s+'));
    if (tu.length < 2 || tu.length > 5) return null;
    if (_diaDanh.contains(_khongDau(s).replaceAll('.', '').trim())) return null;

    var toanHoaDau = true;
    var toanHoa = true;
    var coTuDai = false;
    for (final t in tu) {
      switch (_kieuTu(t)) {
        case 1: // Viết hoa đầu
          toanHoa = false;
          coTuDai = true;
        case 2: // TOÀN HOA (từ 2 chữ trở lên)
          toanHoaDau = false;
          coTuDai = true;
        case 3: // chữ thường: chỉ chấp nhận từ nối
          if (!_tieuTu.contains(_khongDau(t))) return null;
          toanHoa = false;
        case 4: // một chữ hoa ("A", "A.")
          break;
        default: // không có chữ, hoặc lẫn lộn kiểu "tRan"
          return null;
      }
    }
    if (!coTuDai || (!toanHoaDau && !toanHoa)) return null;

    final ten = toanHoaDau ? tu.join(' ') : tu.map(_vietHoaDau).join(' ');
    final hoVn = _hoVn.contains(_khongDau(tu.first).replaceAll('.', ''));
    return (ten: ten, hoVn: hoVn, soTu: tu.length);
  }

  /// 0 = không có chữ, 1 = Hoa đầu, 2 = TOÀN HOA, 3 = thường, 4 = một chữ hoa, 5 = lẫn lộn.
  static int _kieuTu(String w) {
    final chu = w
        .split('')
        .where((c) => c.toLowerCase() != c.toUpperCase())
        .toList();
    if (chu.isEmpty) return 0;
    bool hoa(String c) => c == c.toUpperCase();
    final soHoa = chu.where(hoa).length;
    if (chu.length == 1) return hoa(chu.first) ? 4 : 3;
    if (soHoa == chu.length) return 2;
    if (soHoa == 0) return 3;
    return hoa(chu.first) ? 1 : 5;
  }

  /// "NGUYỄN" → "Nguyễn"; sau dấu '-', '.', nháy lại viết hoa ("ANH-TUẤN" → "Anh-Tuấn").
  static String _vietHoaDau(String w) {
    final sb = StringBuffer();
    var dau = true;
    for (final c in w.split('')) {
      sb.write(dau ? c.toUpperCase() : c.toLowerCase());
      dau = c == '-' || c == '.' || c == "'" || c == '’';
    }
    return sb.toString();
  }
}

// -----------------------------------------------------------------------------
// Kiểu nội bộ
// -----------------------------------------------------------------------------

class _Dong {
  const _Dong(this.text, this.stt);
  final String text;

  /// Thứ tự dòng (sau khi đã bỏ dòng rỗng) để tính "nằm sát dòng chức vụ".
  final int stt;
}

class _Sdt {
  const _Sdt(this.hienThi, {required this.diDong, required this.khoa});
  final String hienThi;
  final bool diDong;

  /// Chuỗi số chuẩn hoá (đầu 84) để loại trùng.
  final String khoa;
}

class _ThongTinLienLac {
  final List<String> emails = [];
  final List<String> websites = [];
  final List<_Sdt> dienThoai = [];
}
