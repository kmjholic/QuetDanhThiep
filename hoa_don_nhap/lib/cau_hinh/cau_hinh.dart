/// Cấu hình lúc build, truyền bằng `--dart-define` hoặc `--dart-define-from-file=config/app_config.json`.
///
/// QUAN TRỌNG: mọi giá trị đi vào bản build Flutter (kể cả `--dart-define`) đều đọc ngược được từ APK.
/// Vì vậy ở đây chỉ có các lựa chọn KHÔNG bí mật. Ứng dụng này nhận dạng chữ ngay trên điện thoại bằng
/// ML Kit nên không cần API key nào; xem README mục "Cấu hình và API key".
library;

/// Cách nhận dạng chữ.
enum CheDoOcr {
  /// Android/iOS: nhận dạng trên thiết bị, người dùng có thể bật chế độ demo trong Cài đặt.
  /// Nền tảng khác (web, máy tính, test): luôn demo.
  tuDong,

  /// Luôn nhận dạng trên thiết bị (khoá công tắc demo trong Cài đặt).
  thietBi,

  /// Luôn dùng dữ liệu mẫu — để trình diễn luồng ứng dụng khi chưa có dịch vụ nhận dạng.
  demo,
}

class CauHinh {
  final CheDoOcr cheDo;

  const CauHinh({this.cheDo = CheDoOcr.tuDong});

  /// Đọc từ `--dart-define=OCR_MODE=auto|device|demo`. Giá trị lạ → `auto`.
  factory CauHinh.tuMoiTruong() =>
      CauHinh(cheDo: docCheDo(const String.fromEnvironment('OCR_MODE', defaultValue: 'auto')));

  static CheDoOcr docCheDo(String giaTri) => switch (giaTri.trim().toLowerCase()) {
        'device' || 'thiet_bi' || 'on_device' => CheDoOcr.thietBi,
        'demo' => CheDoOcr.demo,
        _ => CheDoOcr.tuDong,
      };

  /// Chế độ thực dùng. [coOcrThietBi]: nền tảng có ML Kit (Android/iOS).
  /// [nguoiDungChonDemo]: công tắc trong Cài đặt.
  bool dungDemo({required bool coOcrThietBi, required bool nguoiDungChonDemo}) {
    if (!coOcrThietBi) return true;
    return switch (cheDo) {
      CheDoOcr.demo => true,
      CheDoOcr.thietBi => false,
      CheDoOcr.tuDong => nguoiDungChonDemo,
    };
  }

  /// Công tắc demo trong Cài đặt chỉ bật/tắt được khi cấu hình là `auto` và máy có ML Kit.
  bool choDoiCheDo({required bool coOcrThietBi}) => coOcrThietBi && cheDo == CheDoOcr.tuDong;
}
