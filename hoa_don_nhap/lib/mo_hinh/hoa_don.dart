/// Ảnh của một hóa đơn: tệp trên máy hoặc ảnh mẫu đóng gói trong app (asset).
class AnhHoaDon {
  final String duongDan;
  final bool laAsset;

  const AnhHoaDon.tep(this.duongDan) : laAsset = false;
  const AnhHoaDon.asset(this.duongDan) : laAsset = true;

  static const _tienToAsset = 'asset:';

  /// Chuỗi để lưu vào lịch sử.
  String maHoa() => laAsset ? '$_tienToAsset$duongDan' : duongDan;

  static AnhHoaDon? giaiMa(Object? s) {
    if (s is! String || s.isEmpty) return null;
    return s.startsWith(_tienToAsset) ? AnhHoaDon.asset(s.substring(_tienToAsset.length)) : AnhHoaDon.tep(s);
  }

  @override
  bool operator ==(Object other) => other is AnhHoaDon && other.duongDan == duongDan && other.laAsset == laAsset;

  @override
  int get hashCode => Object.hash(duongDan, laAsset);

  @override
  String toString() => maHoa();
}

/// Ảnh lấy từ đâu.
enum NguonAnh { mayAnh, thuVien, mau }

/// Một hóa đơn đã lưu: tiêu đề (thường là tên nhà cung cấp) + toàn bộ văn bản đã chỉnh sửa.
class HoaDon {
  final String ma;
  final String tieuDe;
  final String noiDung;
  final DateTime taoLuc;
  final DateTime suaLuc;
  final AnhHoaDon? anh;
  final NguonAnh nguon;

  const HoaDon({
    required this.ma,
    required this.tieuDe,
    required this.noiDung,
    required this.taoLuc,
    required this.suaLuc,
    required this.nguon,
    this.anh,
  });

  HoaDon copyWith({String? tieuDe, String? noiDung, DateTime? suaLuc, AnhHoaDon? anh}) => HoaDon(
        ma: ma,
        tieuDe: tieuDe ?? this.tieuDe,
        noiDung: noiDung ?? this.noiDung,
        taoLuc: taoLuc,
        suaLuc: suaLuc ?? this.suaLuc,
        nguon: nguon,
        anh: anh ?? this.anh,
      );

  Map<String, Object?> toJson() => {
        'v': 1,
        'ma': ma,
        'tieu_de': tieuDe,
        'noi_dung': noiDung,
        'tao_luc': taoLuc.millisecondsSinceEpoch,
        'sua_luc': suaLuc.millisecondsSinceEpoch,
        'anh': anh?.maHoa(),
        'nguon': nguon.name,
      };

  /// Ném [FormatException] nếu thiếu trường bắt buộc (kho lịch sử sẽ bỏ qua bản ghi hỏng).
  factory HoaDon.tuJson(Map<String, Object?> j) {
    final ma = j['ma'], noiDung = j['noi_dung'], tao = j['tao_luc'];
    if (ma is! String || ma.isEmpty || noiDung is! String || tao is! int) {
      throw const FormatException('Bản ghi hóa đơn thiếu trường bắt buộc');
    }
    final sua = j['sua_luc'];
    return HoaDon(
      ma: ma,
      tieuDe: j['tieu_de'] is String ? j['tieu_de'] as String : '',
      noiDung: noiDung,
      taoLuc: DateTime.fromMillisecondsSinceEpoch(tao),
      suaLuc: DateTime.fromMillisecondsSinceEpoch(sua is int ? sua : tao),
      anh: AnhHoaDon.giaiMa(j['anh']),
      nguon: NguonAnh.values.firstWhere((n) => n.name == j['nguon'], orElse: () => NguonAnh.thuVien),
    );
  }
}
