/// Nguồn gốc dữ liệu của một danh thiếp.
enum NguonDanhThiep {
  /// Tách từ chữ nhận dạng (OCR).
  ocr,

  /// Đọc từ mã QR (vCard / MECARD).
  qr,

  /// Người dùng tự nhập.
  thucong;

  /// Đọc từ tên đã lưu; giá trị lạ hoặc thiếu coi là [thucong].
  static NguonDanhThiep tuTen(Object? ten) {
    for (final n in values) {
      if (n.name == ten) return n;
    }
    return NguonDanhThiep.thucong;
  }
}

/// Một danh thiếp đã lưu (hoặc đang chỉnh sửa).
class DanhThiep {
  const DanhThiep({
    required this.id,
    required this.thoiGian,
    this.hoTen = '',
    this.chucVu = '',
    this.congTy = '',
    this.dienThoai = '',
    this.dienThoaiKhac = '',
    this.email = '',
    this.website = '',
    this.diaChi = '',
    this.ghiChu = '',
    this.duongDanAnh,
    this.nguon = NguonDanhThiep.thucong,
  });

  /// Mã duy nhất, cũng là tên tệp ảnh (`danh_thiep/<id>.jpg`).
  final String id;
  final DateTime thoiGian;
  final String hoTen;
  final String chucVu;
  final String congTy;

  /// Số điện thoại chính (ưu tiên di động).
  final String dienThoai;

  /// Số thứ hai (thường là máy bàn). Bỏ trống nếu không có.
  final String dienThoaiKhac;
  final String email;
  final String website;
  final String diaChi;
  final String ghiChu;

  /// Đường dẫn ảnh đã chép vào thư mục tài liệu của app; null nếu không có ảnh.
  final String? duongDanAnh;
  final NguonDanhThiep nguon;

  /// Có ít nhất một trường thông tin liên hệ (không tính ghi chú).
  bool get coNoiDung =>
      hoTen.trim().isNotEmpty ||
      chucVu.trim().isNotEmpty ||
      congTy.trim().isNotEmpty ||
      dienThoai.trim().isNotEmpty ||
      dienThoaiKhac.trim().isNotEmpty ||
      email.trim().isNotEmpty ||
      website.trim().isNotEmpty ||
      diaChi.trim().isNotEmpty;

  /// Tên dùng làm tiêu đề trong danh sách: họ tên, không có thì công ty, email, số điện thoại.
  String get tenHienThi {
    for (final s in [hoTen, congTy, email, dienThoai]) {
      if (s.trim().isNotEmpty) return s.trim();
    }
    return '';
  }

  /// Chữ cái hiển thị trong ảnh đại diện (chữ đầu của tên cuối cùng).
  String get chuCaiDau {
    final ten = tenHienThi;
    if (ten.isEmpty) return '?';
    final tu = ten.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (tu.isEmpty) return '?';
    return String.fromCharCode(tu.last.runes.first).toUpperCase();
  }

  /// Bản sao có thay đổi. Đặt [xoaAnh] = true để bỏ đường dẫn ảnh.
  DanhThiep copyWith({
    String? id,
    DateTime? thoiGian,
    String? hoTen,
    String? chucVu,
    String? congTy,
    String? dienThoai,
    String? dienThoaiKhac,
    String? email,
    String? website,
    String? diaChi,
    String? ghiChu,
    String? duongDanAnh,
    bool xoaAnh = false,
    NguonDanhThiep? nguon,
  }) {
    return DanhThiep(
      id: id ?? this.id,
      thoiGian: thoiGian ?? this.thoiGian,
      hoTen: hoTen ?? this.hoTen,
      chucVu: chucVu ?? this.chucVu,
      congTy: congTy ?? this.congTy,
      dienThoai: dienThoai ?? this.dienThoai,
      dienThoaiKhac: dienThoaiKhac ?? this.dienThoaiKhac,
      email: email ?? this.email,
      website: website ?? this.website,
      diaChi: diaChi ?? this.diaChi,
      ghiChu: ghiChu ?? this.ghiChu,
      duongDanAnh: xoaAnh ? null : (duongDanAnh ?? this.duongDanAnh),
      nguon: nguon ?? this.nguon,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'thoiGian': thoiGian.toIso8601String(),
    'hoTen': hoTen,
    'chucVu': chucVu,
    'congTy': congTy,
    'dienThoai': dienThoai,
    'dienThoaiKhac': dienThoaiKhac,
    'email': email,
    'website': website,
    'diaChi': diaChi,
    'ghiChu': ghiChu,
    'duongDanAnh': duongDanAnh,
    'nguon': nguon.name,
  };

  /// Đọc từ JSON đã lưu. Chịu được trường thiếu hoặc sai kiểu (dữ liệu cũ/hỏng).
  factory DanhThiep.fromJson(Map<String, dynamic> json) {
    final anh = _chuoi(json['duongDanAnh']);
    return DanhThiep(
      id: _chuoi(json['id']),
      thoiGian:
          DateTime.tryParse(_chuoi(json['thoiGian'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      hoTen: _chuoi(json['hoTen']),
      chucVu: _chuoi(json['chucVu']),
      congTy: _chuoi(json['congTy']),
      dienThoai: _chuoi(json['dienThoai']),
      dienThoaiKhac: _chuoi(json['dienThoaiKhac']),
      email: _chuoi(json['email']),
      website: _chuoi(json['website']),
      diaChi: _chuoi(json['diaChi']),
      ghiChu: _chuoi(json['ghiChu']),
      duongDanAnh: anh.isEmpty ? null : anh,
      nguon: NguonDanhThiep.tuTen(json['nguon']),
    );
  }

  static String _chuoi(Object? v) => v is String ? v : '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DanhThiep &&
          other.id == id &&
          other.thoiGian == thoiGian &&
          other.hoTen == hoTen &&
          other.chucVu == chucVu &&
          other.congTy == congTy &&
          other.dienThoai == dienThoai &&
          other.dienThoaiKhac == dienThoaiKhac &&
          other.email == email &&
          other.website == website &&
          other.diaChi == diaChi &&
          other.ghiChu == ghiChu &&
          other.duongDanAnh == duongDanAnh &&
          other.nguon == nguon;

  @override
  int get hashCode => Object.hash(
    id,
    thoiGian,
    hoTen,
    chucVu,
    congTy,
    dienThoai,
    dienThoaiKhac,
    email,
    website,
    diaChi,
    ghiChu,
    duongDanAnh,
    nguon,
  );
}
