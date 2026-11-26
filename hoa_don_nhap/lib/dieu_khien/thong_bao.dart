/// Cơ chế "báo thay đổi" tối giản, tương tự `ChangeNotifier` của Flutter nhưng là Dart thuần,
/// để các bộ điều khiển kiểm thử được bằng `dart test` không cần máy ảo hay điện thoại.
/// Giao diện lắng nghe bằng widget `NgheThayDoi` (giao_dien/thanh_phan/nghe_thay_doi.dart).
mixin CoThongBao {
  final _nghe = <void Function()>[];
  bool _daHuy = false;

  bool get daHuy => _daHuy;

  void themNghe(void Function() f) => _nghe.add(f);

  void boNghe(void Function() f) => _nghe.remove(f);

  void baoThayDoi() {
    if (_daHuy) return;
    for (final f in List.of(_nghe)) {
      f();
    }
  }

  /// Gọi khi màn hình đóng: sau đó mọi kết quả trả về muộn đều bị bỏ qua.
  void huy() {
    _daHuy = true;
    _nghe.clear();
  }
}
