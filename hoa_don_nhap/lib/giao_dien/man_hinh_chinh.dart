import 'package:flutter/material.dart';

import '../ngon_ngu/chuoi.dart';
import 'man_hinh_hoa_don.dart';
import 'man_hinh_lich_su_danh_thiep.dart';

/// Khung chính của ứng dụng: thanh điều hướng dưới đáy chuyển giữa hai loại tài liệu.
///
/// * Tab **Hóa đơn** ([ManHinhHoaDon]): màn hình cũ, giữ nguyên hành vi.
/// * Tab **Danh thiếp** ([ManHinhLichSuDanhThiep]): chỉ được dựng khi người dùng mở tab lần đầu,
///   nên lúc khởi động app không tải thêm dữ liệu danh thiếp.
///
/// Cả hai tab được giữ sống bằng [IndexedStack]: chuyển qua lại không mất vị trí cuộn hay trạng thái.
/// Mỗi tab có [Scaffold] riêng (AppBar, nút đáy riêng); thanh điều hướng nằm ở [Scaffold] ngoài cùng.
/// Nút Back của Android khi đang ở tab Danh thiếp sẽ quay về tab Hóa đơn trước, rồi mới thoát app.
class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  State<ManHinhChinh> createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  static const int _tabHoaDon = 0;
  static const int _tabDanhThiep = 1;

  int _chiSo = _tabHoaDon;
  bool _daMoDanhThiep = false;

  void _chon(int i) {
    if (i == _chiSo) return;
    setState(() {
      _chiSo = i;
      if (i == _tabDanhThiep) _daMoDanhThiep = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    return PopScope(
      canPop: _chiSo == _tabHoaDon,
      onPopInvokedWithResult: (daThoat, _) {
        if (!daThoat) setState(() => _chiSo = _tabHoaDon);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _chiSo,
          sizing: StackFit.expand,
          children: [
            const ManHinhHoaDon(),
            _daMoDanhThiep
                ? const ManHinhLichSuDanhThiep()
                : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _chiSo,
          onDestinationSelected: _chon,
          destinations: [
            NavigationDestination(
              key: const Key('tab_hoa_don'),
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: c.t(K.dtTabHoaDon),
            ),
            NavigationDestination(
              key: const Key('tab_danh_thiep'),
              icon: const Icon(Icons.contacts_outlined),
              selectedIcon: const Icon(Icons.contacts),
              label: c.t(K.dtTabDanhThiep),
            ),
          ],
        ),
      ),
    );
  }
}
