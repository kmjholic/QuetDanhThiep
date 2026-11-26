import 'package:flutter/widgets.dart';

import '../../dieu_khien/thong_bao.dart';

/// Vẽ lại [builder] mỗi khi một trong các bộ điều khiển [nguon] báo thay đổi
/// (giống `ListenableBuilder`, dành cho bộ điều khiển Dart thuần dùng [CoThongBao]).
class NgheThayDoi extends StatefulWidget {
  final List<CoThongBao> nguon;
  final WidgetBuilder builder;

  const NgheThayDoi({super.key, required this.nguon, required this.builder});

  @override
  State<NgheThayDoi> createState() => _NgheThayDoiState();
}

class _NgheThayDoiState extends State<NgheThayDoi> {
  void _doi() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    for (final n in widget.nguon) {
      n.themNghe(_doi);
    }
  }

  @override
  void didUpdateWidget(NgheThayDoi old) {
    super.didUpdateWidget(old);
    for (final n in old.nguon) {
      n.boNghe(_doi);
    }
    for (final n in widget.nguon) {
      n.themNghe(_doi);
    }
  }

  @override
  void dispose() {
    for (final n in widget.nguon) {
      n.boNghe(_doi);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
