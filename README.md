# Quét hóa đơn nhập & quản lý danh thiếp

## Mục đích

Ứng dụng Flutter hỗ trợ cửa hàng lưu hóa đơn nhập hàng và quản lý thông tin liên hệ từ danh thiếp ngay trên điện thoại. Người dùng có thể nhận dạng nội dung từ ảnh, kiểm tra và chỉnh sửa kết quả trước khi lưu. Giao diện hỗ trợ tiếng Việt và tiếng Anh.

## Tính năng

- **Hóa đơn:** chụp hoặc chọn ảnh, nhận dạng chữ (OCR), chỉnh sửa, sao chép và lưu lịch sử.
- **Danh thiếp:** nhận dạng thông tin và mã QR, chỉnh sửa, lưu riêng với hóa đơn và xuất danh bạ dạng `.vcf`.
- **Xử lý trên thiết bị:** OCR và quét QR dùng Google ML Kit trên nền tảng được hỗ trợ; ứng dụng không cần API key hay dịch vụ nhận dạng đám mây.
- **Dùng thử:** có chế độ demo và ảnh mẫu để trải nghiệm các luồng chính.
- **Lưu trữ cục bộ:** dữ liệu được lưu trên thiết bị; ứng dụng không đồng bộ lên đám mây.

## Cài đặt

### Yêu cầu

- Flutter 3.44 trở lên và Dart 3.12 trở lên.
- Android Studio cùng Android SDK.
- Thiết bị Android 7.0 trở lên hoặc máy ảo Android.

### Cài dependencies

Chạy các lệnh sau từ thư mục gốc repository:

```bash
cd hoa_don_nhap
flutter pub get
```

## Cấu hình

Ứng dụng không cần API key hoặc khóa bí mật. Có thể chọn chế độ OCR bằng `OCR_MODE` khi chạy:

| Giá trị | Ý nghĩa |
| --- | --- |
| `auto` | Mặc định. Dùng ML Kit trên nền tảng hỗ trợ; dùng demo trên nền tảng không hỗ trợ. |
| `device` | Yêu cầu nhận dạng trên thiết bị; cần chạy trên nền tảng được ML Kit hỗ trợ. |
| `demo` | Dùng dữ liệu mẫu để trình diễn luồng ứng dụng. |

Ví dụ cấu hình mặc định trong [`hoa_don_nhap/config/app_config.example.json`](hoa_don_nhap/config/app_config.example.json) là `OCR_MODE: auto`. Không đưa khóa bí mật vào mã nguồn hoặc repository.

## Cách chạy

Mở terminal tại thư mục `hoa_don_nhap`:

```bash
flutter run
```

Chọn chế độ nhận dạng khác nếu cần:

```bash
flutter run --dart-define=OCR_MODE=demo
```

Có thể thay `demo` bằng `auto` hoặc `device`. Trên Android, kết nối thiết bị đã bật gỡ lỗi USB hoặc khởi động máy ảo trước khi chạy.

## Cách chạy test

Chạy trong thư mục `hoa_don_nhap`:

```bash
flutter analyze
flutter test
```

## Dữ liệu được lưu ở đâu?

- Nội dung hóa đơn, danh thiếp và tùy chọn ứng dụng được lưu cục bộ bằng `SharedPreferences`.
- Ảnh do người dùng lưu được đặt trong thư mục tài liệu riêng của ứng dụng trên thiết bị.
- Khi xuất danh thiếp, tệp vCard tạm được chuyển sang ứng dụng do người dùng chọn trong bảng chia sẻ của hệ điều hành.
- Ứng dụng không đồng bộ dữ liệu lên máy chủ. Gỡ cài đặt ứng dụng có thể làm mất dữ liệu cục bộ; hãy xuất hoặc sao lưu dữ liệu cần giữ trước khi gỡ.

## Dùng AI

Ứng dụng dùng Google ML Kit để nhận dạng chữ trên ảnh hóa đơn/danh thiếp và quét mã QR trên nền tảng được hỗ trợ. Việc nhận dạng được xử lý trên thiết bị, không cần API key và không gửi ảnh đến dịch vụ AI đám mây. Phần phân tích thông tin danh thiếp dùng quy tắc và heuristic để phân loại văn bản, không phải mô hình tạo sinh. Kết quả OCR có thể sai, vì vậy người dùng cần kiểm tra và chỉnh sửa trước khi lưu. SDK ML Kit có thể thu thập dữ liệu sử dụng hoặc chẩn đoán theo điều khoản của Google.

## Tài liệu

- [Hướng dẫn và mô tả chi tiết ứng dụng](hoa_don_nhap/README_MO_RONG.md)
- [Tài liệu MVP quét hóa đơn](hoa_don_nhap/README.md)

## Giới hạn

OCR hoạt động tốt nhất với chữ in rõ nét; người dùng nên kiểm tra và chỉnh sửa kết quả trước khi lưu. Khả năng nhận dạng trên thiết bị phụ thuộc nền tảng và chất lượng ảnh. Ứng dụng hiện chưa hỗ trợ đọc thẻ NFC vật lý.
