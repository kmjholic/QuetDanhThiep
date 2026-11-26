import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../mo_hinh/hoa_don.dart';
import '../../ngon_ngu/chuoi.dart';
import 'anh_hoa_don.dart';

/// Khung sửa hóa đơn dùng chung cho màn hình "Kết quả nhận dạng" và "Chi tiết hóa đơn":
/// ảnh nhỏ (chạm để phóng to) + tiêu đề + toàn bộ văn bản.
class TrinhSuaHoaDon extends StatelessWidget {
  final AnhHoaDon? anh;
  final TextEditingController tieuDe;
  final TextEditingController noiDung;

  /// Dòng phụ dưới tiêu đề (số dòng đọc được, thời gian tạo…).
  final String? thongTin;

  /// Thẻ cảnh báo ở đầu (ví dụ: dữ liệu mẫu của chế độ demo).
  final String? canhBao;

  const TrinhSuaHoaDon({
    super.key,
    required this.anh,
    required this.tieuDe,
    required this.noiDung,
    this.thongTin,
    this.canhBao,
  });

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (canhBao != null)
          Card(
            color: theme.colorScheme.tertiaryContainer,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.science_outlined, color: theme.colorScheme.onTertiaryContainer),
              title: Text(canhBao!, style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (anh != null) ...[
              Semantics(
                button: true,
                label: c.t(K.xemAnh),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => ManHinhXemAnh.mo(context, anh!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(width: 72, height: 96, child: AnhHoaDonWidget(anh: anh!, giaiMaRong: 220)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const Key('o_tieu_de'),
                    controller: tieuDe,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: c.t(K.tieuDe),
                      hintText: c.t(K.tieuDeGoiY),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (thongTin != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(thongTin!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('o_noi_dung'),
          controller: noiDung,
          minLines: 12,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          decoration: InputDecoration(
            labelText: c.t(K.noiDung),
            hintText: c.t(K.noiDungGoiY),
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// Thanh nút ở đáy màn hình (tránh vùng cử chỉ/thanh điều hướng của Android).
class ThanhNutDay extends StatelessWidget {
  final List<Widget> nut;

  const ThanhNutDay({super.key, required this.nut});

  @override
  Widget build(BuildContext context) => Material(
        elevation: 3,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(children: [
              for (var i = 0; i < nut.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: nut[i]),
              ],
            ]),
          ),
        ),
      );
}

Future<void> saoChepVanBan(BuildContext context, String tieuDe, String noiDung) async {
  final van = [tieuDe.trim(), noiDung.trim()].where((s) => s.isNotEmpty).join('\n\n');
  await Clipboard.setData(ClipboardData(text: van));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(Chuoi.of(context).t(K.daSaoChep))));
  }
}

/// Hộp thoại xác nhận; trả về true khi người dùng đồng ý.
Future<bool> hoiXacNhan(
  BuildContext context, {
  required String tieuDe,
  required String moTa,
  required String nutDongY,
  String? nutHuy,
  bool nguyHiem = false,
}) async {
  final c = Chuoi.of(context);
  final kq = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tieuDe),
      content: Text(moTa),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(nutHuy ?? c.t(K.huy))),
        FilledButton(
          style: nguyHiem
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(nutDongY),
        ),
      ],
    ),
  );
  return kq ?? false;
}
