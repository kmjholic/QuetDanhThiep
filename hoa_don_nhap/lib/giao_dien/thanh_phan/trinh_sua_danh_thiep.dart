import 'package:flutter/material.dart';

import '../../mo_hinh/hoa_don.dart';
import '../../ngon_ngu/chuoi.dart';
import 'anh_hoa_don.dart';

/// Bộ 9 ô nhập của một danh thiếp. Màn quét và màn chi tiết cùng dùng để khỏi lặp code.
class CacOSuaDanhThiep {
  final hoTen = TextEditingController();
  final chucVu = TextEditingController();
  final congTy = TextEditingController();
  final dienThoai = TextEditingController();
  final dienThoaiKhac = TextEditingController();
  final email = TextEditingController();
  final website = TextEditingController();
  final diaChi = TextEditingController();
  final ghiChu = TextEditingController();

  List<TextEditingController> get tatCa => [
    hoTen,
    chucVu,
    congTy,
    dienThoai,
    dienThoaiKhac,
    email,
    website,
    diaChi,
    ghiChu,
  ];

  void dat({
    String hoTen = '',
    String chucVu = '',
    String congTy = '',
    String dienThoai = '',
    String dienThoaiKhac = '',
    String email = '',
    String website = '',
    String diaChi = '',
    String ghiChu = '',
  }) {
    this.hoTen.text = hoTen;
    this.chucVu.text = chucVu;
    this.congTy.text = congTy;
    this.dienThoai.text = dienThoai;
    this.dienThoaiKhac.text = dienThoaiKhac;
    this.email.text = email;
    this.website.text = website;
    this.diaChi.text = diaChi;
    this.ghiChu.text = ghiChu;
  }

  /// Chuỗi đại diện toàn bộ nội dung hiện tại, dùng để biết người dùng đã sửa gì chưa.
  String get dauVet => tatCa.map((c) => c.text).join('\u0001');

  /// Có ít nhất một ô khác rỗng (mới cho phép lưu/xuất).
  bool get coNoiDung => tatCa.any((c) => c.text.trim().isNotEmpty);

  void dispose() {
    for (final c in tatCa) {
      c.dispose();
    }
  }
}

/// Ảnh (nếu có) + cảnh báo + thông tin + 9 ô sửa + văn bản gốc (nếu có).
class TrinhSuaDanhThiep extends StatelessWidget {
  final AnhHoaDon? anh;
  final CacOSuaDanhThiep cacO;
  final String? canhBao;
  final String? thongTin;
  final String vanBanGoc;

  const TrinhSuaDanhThiep({
    super.key,
    required this.cacO,
    this.anh,
    this.canhBao,
    this.thongTin,
    this.vanBanGoc = '',
  });

  Widget _o(
    TextEditingController ctl,
    String nhan,
    String khoa, {
    TextInputType? kieu,
    TextCapitalization hoa = TextCapitalization.none,
    int toiDa = 1,
    int toiThieu = 1,
    bool cuoi = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      key: Key(khoa),
      controller: ctl,
      keyboardType: toiDa > 1 ? TextInputType.multiline : kieu,
      textCapitalization: hoa,
      minLines: toiThieu,
      maxLines: toiDa,
      textInputAction: toiDa > 1 || cuoi
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: nhan,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (anh != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: AnhHoaDonWidget(anh: anh!, giaiMaRong: 900),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (canhBao != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    canhBao!,
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (thongTin != null && thongTin!.isNotEmpty) ...[
          Text(thongTin!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
        ],
        _o(
          cacO.hoTen,
          c.t(K.dtHoTen),
          'o_ho_ten',
          kieu: TextInputType.name,
          hoa: TextCapitalization.words,
        ),
        _o(
          cacO.chucVu,
          c.t(K.dtChucVu),
          'o_chuc_vu',
          hoa: TextCapitalization.sentences,
        ),
        _o(
          cacO.congTy,
          c.t(K.dtCongTy),
          'o_cong_ty',
          hoa: TextCapitalization.words,
        ),
        _o(
          cacO.dienThoai,
          c.t(K.dtDienThoai),
          'o_dien_thoai',
          kieu: TextInputType.phone,
        ),
        _o(
          cacO.dienThoaiKhac,
          c.t(K.dtDienThoaiKhac),
          'o_dien_thoai_khac',
          kieu: TextInputType.phone,
        ),
        _o(
          cacO.email,
          c.t(K.dtEmail),
          'o_email',
          kieu: TextInputType.emailAddress,
        ),
        _o(
          cacO.website,
          c.t(K.dtWebsite),
          'o_website',
          kieu: TextInputType.url,
        ),
        _o(
          cacO.diaChi,
          c.t(K.dtDiaChi),
          'o_dia_chi',
          toiDa: 4,
          toiThieu: 2,
          hoa: TextCapitalization.sentences,
        ),
        _o(
          cacO.ghiChu,
          c.t(K.dtGhiChu),
          'o_ghi_chu',
          toiDa: 5,
          toiThieu: 2,
          hoa: TextCapitalization.sentences,
        ),
        if (vanBanGoc.trim().isNotEmpty)
          ExpansionTile(
            key: const Key('van_ban_goc'),
            tilePadding: EdgeInsets.zero,
            title: Text(c.t(K.dtVanBanGoc), style: theme.textTheme.titleSmall),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(vanBanGoc),
              ),
              const SizedBox(height: 8),
            ],
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
