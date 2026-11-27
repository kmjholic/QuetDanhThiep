# Quét hóa đơn nhập & danh thiếp

Ứng dụng Flutter giúp cửa hàng lưu hóa đơn nhập hàng và quản lý thông tin danh thiếp ngay trên điện thoại. Ứng dụng hỗ trợ tiếng Việt và tiếng Anh.

## Tính năng

- **Hóa đơn:** chụp hoặc chọn ảnh, nhận dạng chữ (OCR), chỉnh sửa, sao chép và lưu lịch sử.
- **Danh thiếp:** nhận dạng thông tin và mã QR, chỉnh sửa, lưu riêng với hóa đơn và xuất danh bạ dạng `.vcf`.
- **Xử lý trên thiết bị:** OCR và quét QR dùng Google ML Kit trên nền tảng được hỗ trợ; ứng dụng không yêu cầu API key hay dịch vụ nhận dạng đám mây.
- **Dùng thử:** có chế độ demo và ảnh mẫu để trải nghiệm các luồng chính.
- **Lưu trữ cục bộ:** dữ liệu được lưu trên thiết bị; ứng dụng không đồng bộ lên đám mây.

## Bắt đầu

### Yêu cầu

- Flutter 3.44 trở lên và Dart 3.12 trở lên.
- Android Studio cùng Android SDK.
- Thiết bị Android 7.0 trở lên hoặc máy ảo Android.

### Chạy ứng dụng

Mở terminal tại thư mục ứng dụng:

```bash
cd hoa_don_nhap
flutter pub get
flutter run
```

Chọn chế độ nhận dạng khi chạy:

```bash
flutter run --dart-define=OCR_MODE=auto
```

`auto` là chế độ mặc định; có thể thay bằng `device` để luôn dùng nhận dạng trên thiết bị hoặc `demo` để dùng dữ liệu mẫu.

## Kiểm thử

Chạy các lệnh trong thư mục `hoa_don_nhap`:

```bash
flutter analyze
flutter test
```

## Tài liệu

- [Hướng dẫn và mô tả chi tiết ứng dụng](hoa_don_nhap/README_MO_RONG.md)
- [Tài liệu MVP quét hóa đơn](hoa_don_nhap/README.md)

## Giới hạn

OCR hoạt động tốt nhất với chữ in rõ nét; người dùng nên kiểm tra và chỉnh sửa kết quả trước khi lưu. Khả năng nhận dạng trên thiết bị phụ thuộc nền tảng và chất lượng ảnh. Ứng dụng hiện chưa hỗ trợ đọc thẻ NFC vật lý.
