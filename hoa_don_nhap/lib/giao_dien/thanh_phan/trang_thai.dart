import 'package:flutter/material.dart';

/// Khung dùng chung cho trạng thái "chưa có dữ liệu", "lỗi", "không tìm thấy chữ".
class KhungTrangThai extends StatelessWidget {
  final IconData icon;
  final String tieuDe;
  final String? moTa;
  final List<Widget> hanhDong;
  final bool laLoi;

  const KhungTrangThai({
    super.key,
    required this.icon,
    required this.tieuDe,
    this.moTa,
    this.hanhDong = const [],
    this.laLoi = false,
  });

  @override
  Widget build(BuildContext context) {
    final mau = Theme.of(context).colorScheme;
    final chu = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: laLoi ? mau.errorContainer : mau.secondaryContainer,
            child: Icon(icon, size: 36, color: laLoi ? mau.onErrorContainer : mau.onSecondaryContainer),
          ),
          const SizedBox(height: 16),
          Text(tieuDe, style: chu.titleMedium, textAlign: TextAlign.center),
          if (moTa != null) ...[
            const SizedBox(height: 8),
            Text(moTa!, style: chu.bodyMedium?.copyWith(color: mau.onSurfaceVariant), textAlign: TextAlign.center),
          ],
          if (hanhDong.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: hanhDong),
          ],
        ],
      ),
    );
  }
}

/// Trạng thái đang tải: vòng xoay + dòng chữ.
class TrangThaiDangTai extends StatelessWidget {
  final String thongDiep;

  const TrangThaiDangTai({super.key, required this.thongDiep});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(thongDiep, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}
