# Quét hóa đơn nhập — MVP Flutter (Android)

Ứng dụng giúp nhân viên cửa hàng tạp hóa **lưu hóa đơn nhập hàng bằng điện thoại**: chụp hoặc chọn ảnh hóa đơn →
máy **nhận dạng chữ (OCR) ngay trên điện thoại** → sửa lại văn bản → **sao chép** hoặc **lưu vào lịch sử** trên máy.
Giao diện tiếng Việt và tiếng Anh.

Phạm vi cố ý giữ nhỏ: không đăng nhập, không thanh toán, không đồng bộ đám mây, không tự hạch toán hay kết nối
phần mềm kế toán.

| Tính năng                   | Ghi chú                                                                                                               |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Chụp ảnh / chọn ảnh có sẵn  | `image_picker`: camera của máy và trình chọn ảnh hệ thống — app **không xin quyền** camera hay đọc ảnh                |
| Nhận dạng chữ trên thiết bị | Google ML Kit, mô hình chữ Latinh (có tiếng Việt). Không gửi ảnh đi, **không cần mạng, không cần API key**            |
| Giữ đúng hàng của hóa đơn   | ML Kit trả chữ theo khối/cột; app ghép lại theo toạ độ để "Tên hàng · SL · Đơn giá · Thành tiền" nằm trên một dòng    |
| Sửa, sao chép, lưu          | Tiêu đề tự đoán từ dòng đầu (thường là tên nhà cung cấp); sao chép tiêu đề + nội dung vào bộ nhớ tạm                  |
| Lịch sử trên máy            | Xem lại, sửa, xoá từng hóa đơn; xoá toàn bộ trong Cài đặt                                                             |
| Đủ trạng thái giao diện     | Đang tải · lỗi (có Thử lại) · chưa có dữ liệu · không tìm thấy chữ (có Nhập tay) · hỏi trước khi bỏ nội dung chưa lưu |
| Chế độ demo + hóa đơn mẫu   | Trải nghiệm trọn luồng khi máy chưa có OCR (web, máy tính) hoặc máy ảo không có camera                                |
| Tiếng Việt / English        | Theo ngôn ngữ máy hoặc chọn trong Cài đặt                                                                             |

---

## 1. Chạy thử nhanh (Android)

Cần: Flutter **3.44 trở lên** (đã viết cho 3.47 / Dart 3.13), Android Studio + Android SDK, một điện thoại
Android 7.0+ (bật gỡ lỗi USB) hoặc máy ảo Android.

```bash
cd hoa_don_nhap

# 1) Sinh thư mục android/ (dự án giao kèm chỉ có mã Dart, tài nguyên và test)
flutter create . --platforms=android --org vn.edu.phenikaa --project-name hoa_don_nhap

# 2) Tải gói
flutter pub get

# 3) Chỉnh android/ cho app này: tên "Quét hóa đơn", minSdk ≥ 24, quy tắc R8 cho ML Kit
dart run tool/cau_hinh_android.dart

# 4) Chạy trên điện thoại / máy ảo đang kết nối
flutter run
```

`flutter create .` không ghi đè `lib/`, `test/`, `pubspec.yaml` có sẵn; nó thêm `android/` và một
`test/widget_test.dart` mẫu (app đếm số) — bước 3 tự xoá tệp mẫu này.

**Thử ngay không cần hóa đơn thật:** bấm biểu tượng hóa đơn trên thanh tiêu đề (hoặc nút _Thử với hóa đơn mẫu_
khi lịch sử trống) → chọn một trong 4 ảnh mẫu:

| Ảnh mẫu                    | Để thử                                        |
| -------------------------- | --------------------------------------------- |
| Đại lý nước giải khát      | luồng chính: nhận dạng → sửa → sao chép → lưu |
| Nhà phân phối mì và gia vị | bảng 5 cột (mã, tên, ĐVT, SL, thành tiền)     |
| Ảnh mờ                     | trạng thái "Không tìm thấy chữ" → _Nhập tay_  |
| Tệp ảnh hỏng               | trạng thái lỗi → _Thử lại_ / _Chọn ảnh khác_  |

Ở chế độ trên thiết bị, ảnh mẫu được ML Kit **đọc thật** (chép ra tệp tạm), nên đây cũng là cách kiểm tra OCR
trên máy ảo không có camera. Tên cửa hàng, công ty, số điện thoại trên ảnh mẫu đều là hư cấu.

Bản phát hành để thử nội bộ: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
(mặc định ký bằng khoá debug — đủ để cài thử, **không** dùng để đưa lên Google Play).

---

## 2. Cấu hình và API key

**Ứng dụng này không cần API key.** OCR chạy bằng mô hình ML Kit đóng gói sẵn trong APK: nhận dạng không cần
mạng, ảnh và văn bản hóa đơn không bị gửi đi. (Thư viện ML Kit của Google có thể gửi số liệu sử dụng/chẩn đoán
ẩn danh của chính SDK — xem điều khoản ML Kit nếu cửa hàng có yêu cầu riêng về dữ liệu.)

Lựa chọn duy nhất lúc build là **chế độ nhận dạng** `OCR_MODE`:

| Giá trị           | Ý nghĩa                                                                                                    |
| ----------------- | ---------------------------------------------------------------------------------------------------------- |
| `auto` (mặc định) | Android/iOS: ML Kit trên thiết bị, người dùng bật/tắt _Chế độ demo_ trong Cài đặt. Web/máy tính: luôn demo |
| `device`          | Luôn dùng ML Kit; khoá công tắc demo                                                                       |
| `demo`            | Luôn dùng văn bản mẫu — để trình diễn luồng ứng dụng khi chưa có dịch vụ nhận dạng                         |

```bash
flutter run --dart-define=OCR_MODE=demo
# hoặc dùng tệp cấu hình riêng của máy (đã nằm trong .gitignore):
cp config/app_config.example.json config/app_config.json
flutter run --dart-define-from-file=config/app_config.json
```

**Vì sao không bao giờ đặt API key trong mã Flutter:** mọi thứ đóng gói vào APK — kể cả chuỗi trong mã nguồn,
tệp `.env` đóng gói kèm hay giá trị `--dart-define` — đều đọc ngược được bằng công cụ giải nén APK. Khoá nằm trong
app là khoá đã lộ. Nếu sau này cần OCR/AI đám mây (ví dụ để đọc chữ viết tay), cách an toàn là:

1. Khoá API chỉ đặt ở **máy chủ của bạn** (biến môi trường của máy chủ, không vào Git).
2. App gửi ảnh tới máy chủ đó; máy chủ kiểm tra, giới hạn số lần gọi rồi mới gọi nhà cung cấp AI.
3. App chỉ biết **địa chỉ máy chủ** (không bí mật) qua `--dart-define`.
4. Viết một lớp mới cài đặt giao diện `BoNhanDang` (`lib/ocr/bo_nhan_dang.dart`) — màn hình không phải sửa gì.

MVP này **không** làm phần đám mây vì OCR trên thiết bị đã đủ cho hóa đơn in và giữ ảnh hóa đơn trên máy cửa hàng.

---

## 3. Luồng sử dụng và các trạng thái

```
Lịch sử ──Chụp ảnh / Chọn ảnh / Hóa đơn mẫu──▶ Kết quả nhận dạng ──Lưu──▶ Lịch sử (+ thông báo "Đã lưu")
   │                                            ├─ đang nhận dạng (ảnh + thanh tiến trình)
   │                                            ├─ lỗi → Thử lại · Chọn ảnh khác
   │                                            ├─ không có chữ → Chụp lại · Nhập tay
   │                                            └─ có chữ → sửa tiêu đề/nội dung · Sao chép · Lưu
   └──chạm một hóa đơn──▶ Chi tiết: xem ảnh (phóng to), sửa, Lưu thay đổi, Sao chép, Xoá (có hỏi lại)
```

| Màn hình  | Đang tải                       | Lỗi                                              | Chưa có dữ liệu                            |
| --------- | ------------------------------ | ------------------------------------------------ | ------------------------------------------ |
| Lịch sử   | vòng xoay "Đang tải lịch sử…"  | "Không đọc được lịch sử" + Thử lại               | hướng dẫn + _Thử với hóa đơn mẫu_          |
| Nhận dạng | ảnh + "Đang nhận dạng chữ…"    | ảnh hỏng / máy không hỗ trợ / lỗi khác + Thử lại | "Không tìm thấy chữ" + mẹo chụp + Nhập tay |
| Chọn ảnh  | nút bị khoá khi đang mở camera | chưa cấp quyền / không có camera (thông báo)     | —                                          |

Bấm _Quay lại_ khi còn nội dung chưa lưu → hộp thoại "Bỏ các thay đổi?". Ảnh chụp camera trên máy ít RAM có thể
làm Android đóng app; lần mở sau app tự lấy lại ảnh vừa chụp (`retrieveLostData`).

---

## 4. Dữ liệu lưu ở đâu

| Dữ liệu                     | Nơi lưu                                                                                                  |
| --------------------------- | -------------------------------------------------------------------------------------------------------- |
| Văn bản, tiêu đề, thời gian | `shared_preferences` (API mới `SharedPreferencesAsync`, trên Android là DataStore), một danh sách JSON   |
| Ảnh hóa đơn                 | chép vào `<thư mục tài liệu của app>/hoa_don/<mã>.jpg` — ảnh camera gốc nằm trong cache và có thể bị xoá |
| Ngôn ngữ, công tắc demo     | `shared_preferences`                                                                                     |

Chỉ app này đọc được; gỡ app là mất hết. Danh sách JSON phù hợp vài nghìn hóa đơn của một cửa hàng nhỏ; nếu cần
tìm kiếm/lọc nhiều hơn, thay `KhoLichSu` bằng SQLite (`sqflite`) mà không phải sửa màn hình.

---

## 5. Cấu trúc mã nguồn

```
lib/
├── main.dart                 khởi tạo: cấu hình, kho dữ liệu, chọn bộ nhận dạng
├── app.dart                  MaterialApp: ngôn ngữ, giao diện sáng/tối
├── phu_thuoc.dart            InheritedWidget chứa các đối tượng dùng chung (thay được bằng đồ giả khi test)
├── cau_hinh/cau_hinh.dart    OCR_MODE (auto | device | demo)
├── ngon_ngu/                 bảng chuỗi vi/en (du_lieu_chuoi.dart) + LocalizationsDelegate (chuoi.dart)
├── mo_hinh/                  HoaDon, AnhHoaDon; xử lý văn bản (chuẩn hoá, đoán tiêu đề, định dạng ngày)
├── ocr/                      giao diện BoNhanDang, ghép dòng theo hàng, chế độ demo, hóa đơn mẫu
├── du_lieu/                  kho lịch sử, kho cài đặt, lưu ảnh, giao diện chọn ảnh (Dart thuần)
├── dieu_khien/               bộ điều khiển lịch sử / quét / cài đặt (Dart thuần, kiểm thử không cần máy)
├── nen_tang/                 phần chạm vào nền tảng: ML Kit, image_picker, shared_preferences, path_provider
└── giao_dien/                4 màn hình + thành phần dùng chung (trạng thái, khung sửa, xem ảnh)
assets/mau/                   4 ảnh hóa đơn mẫu
tool/cau_hinh_android.dart    chỉnh android/ sau flutter create
test/thuan/                   47 kiểm thử Dart thuần (logic, dữ liệu, chuỗi, cấu hình android)
test/giao_dien/               8 kiểm thử widget cho toàn bộ luồng (dùng kho bộ nhớ + demo + bộ chọn ảnh giả)
```

Bộ điều khiển (`dieu_khien/`) là Dart thuần với cơ chế báo thay đổi tối giản (`CoThongBao`, tương tự
`ChangeNotifier`); màn hình nghe bằng widget `NgheThayDoi`. Nhờ vậy logic quét/lưu kiểm thử được mà không cần
điện thoại hay máy ảo.

---

## 6. Kiểm thử

```bash
flutter analyze
flutter test                     # cả test thuần lẫn test widget
flutter test test/thuan          # chỉ phần logic
```

Kiểm thử widget chạy với chế độ demo, kho dữ liệu trong bộ nhớ và bộ chọn ảnh giả: trạng thái trống, luồng
mẫu → sửa → sao chép → lưu, ảnh mờ → nhập tay, ảnh hỏng → lỗi, lỗi đọc lịch sử → thử lại, chưa cấp quyền camera,
sửa/xoá trong chi tiết, giao diện tiếng Anh.

---

## 7. Giới hạn đã biết

- OCR đọc tốt chữ **in**; chữ viết tay, giấy nhàu, ảnh tối hoặc nghiêng nhiều sẽ sai — người dùng sửa ở khung văn bản.
- Bảng nhiều cột in sát nhau có thể bị ghép lệch hàng khi ảnh chụp nghiêng > 5°. Mẹo: giữ máy song song tờ hóa đơn.
- Chưa có cắt/xoay ảnh trước khi nhận dạng, chưa tìm kiếm trong lịch sử, chưa sao lưu (ngoài phạm vi MVP).
- iOS: mã đã sẵn sàng (ML Kit hỗ trợ iOS 15.5+), nhưng cần tự thêm `NSCameraUsageDescription` và
  `NSPhotoLibraryUsageDescription` vào `ios/Runner/Info.plist` — chưa kiểm thử.

## 8. Xử lý sự cố

| Thấy                                                                      | Làm                                                                     |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `uses-sdk:minSdkVersion ... cannot be smaller than version 24`            | Chưa chạy `dart run tool/cau_hinh_android.dart`                         |
| `flutter build apk --release` báo _Missing classes ... text.chinese_ (R8) | Như trên — tool thêm quy tắc vào `android/app/proguard-rules.pro`       |
| Máy ảo: nút Chụp ảnh không có camera                                      | Dùng _Hóa đơn mẫu_, hoặc bật Virtual scene camera trong cấu hình máy ảo |
| Báo "Máy này chưa hỗ trợ nhận dạng trên thiết bị"                         | Đang chạy web/máy tính — dùng chế độ demo, hoặc chạy trên Android       |
| Lỗi Gradle/Java khi build lần đầu                                         | `flutter doctor -v`; dùng JDK 17+ đi kèm Android Studio                 |
# QuetDanhThiep
