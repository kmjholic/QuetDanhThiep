# Quét hóa đơn nhập — Bản mở rộng: Quét danh thiếp

Tài liệu này mô tả trạng thái hiện tại của ứng dụng `hoa_don_nhap`, gồm chức năng quét hóa đơn và phần mở rộng quản lý danh thiếp. Trên nền tảng hỗ trợ và ở chế độ thiết bị, OCR và quét QR từ ảnh dùng các bộ xử lý trên thiết bị; ứng dụng không cấu hình API key hay dịch vụ nhận dạng đám mây. Khi người dùng xuất vCard, tệp được chuyển sang ứng dụng do người dùng chọn trong bảng chia sẻ của hệ điều hành.

## 1. Mục đích và tính năng

| Chức năng | Mô tả |
| --- | --- |
| Quét hóa đơn nhập | Chụp/chọn ảnh, nhận dạng chữ, sửa văn bản và lưu vào lịch sử hóa đơn. |
| Quét danh thiếp | Nhận dạng chữ và QR từ ảnh, cho phép sửa thông tin, lưu vào lịch sử danh thiếp riêng và xuất `.vcf`. |

**Điều hướng.** `ManHinhChinh` có hai tab **Hóa đơn** và **Danh thiếp**. Tab danh thiếp chỉ tải dữ liệu khi được mở lần đầu; hai tab được giữ trong `IndexedStack` để duy trì trạng thái khi chuyển qua lại. Nút Back ở tab Danh thiếp quay về tab Hóa đơn trước.

**OCR và phân tích danh thiếp.** `NhanDangMlKit` nhận dạng chữ trên ảnh. `BoPhanTichDanhThiep` dùng Regex và heuristic để tách họ tên, chức vụ, công ty, tối đa hai số điện thoại chính/phụ, email, website và địa chỉ. Bộ phân tích chuẩn hóa một số dạng số điện thoại Việt Nam, bỏ tiền tố `https://` khỏi website và chuyển email về chữ thường. Đây là bộ phân tích heuristic; kết quả được đưa vào màn hình để người dùng kiểm tra, chỉnh sửa.

**QR.** Có hai luồng:

- Khi quét ảnh danh thiếp, `BoQuetMaMlKit` đọc mã QR bằng Google ML Kit Barcode Scanning. `DocVCard` phân tích nội dung vCard/MECARD; OCR và QR chạy song song, thông tin QR được ưu tiên và OCR điền các trường còn thiếu. Lỗi QR không làm mất kết quả OCR; nếu OCR lỗi nhưng có QR hợp lệ, vẫn có thể tạo kết quả.
- Từ màn hình sửa danh thiếp, người dùng có thể mở `ManHinhQuetQr` để quét QR trực tiếp bằng camera (`mobile_scanner`). Luồng này chỉ trả kết quả khi nội dung được nhận diện là vCard/MECARD.

**Chỉnh sửa, lưu và xuất.**

- Màn hình sửa có 9 ô: họ tên, chức vụ, công ty, hai số điện thoại, email, website, địa chỉ và ghi chú; có thể xem văn bản OCR gốc.
- Có thể chuyển sang nhập tay nếu không nhận được nội dung.
- Danh thiếp được lưu riêng với lịch sử hóa đơn. Xóa toàn bộ danh thiếp không xóa hóa đơn.
- `TaoVCard` xuất vCard 3.0 cho một danh thiếp hoặc nhiều danh thiếp trong một tệp `.vcf`. Ứng dụng chia sẻ tệp qua bảng chia sẻ hệ điều hành; không tự ghi trực tiếp vào danh bạ của máy.

**Ngôn ngữ và cấu hình.** Giao diện hỗ trợ tiếng Việt, tiếng Anh và lựa chọn theo ngôn ngữ hệ thống. Trong mã hiện tại, enum `K` có **125 khóa**; cả `chuoiVi` và `chuoiEn` đều định nghĩa đủ 125 khóa, trong đó **48 khóa `dt*`** dành cho danh thiếp. Người dùng cũng có thể chọn chế độ demo khi cấu hình cho phép.

**NFC.** Dự án hiện **không đọc thẻ NFC vật lý**. `chuan_hoa_nfc.dart` nói về Unicode NFC (chuẩn hóa dạng ký tự và dấu tiếng Việt), không phải Near-Field Communication.

## 2. Cấu trúc mã nguồn

### Mô hình và xử lý dữ liệu

| File | Lớp / vai trò |
| --- | --- |
| `lib/mo_hinh/danh_thiep.dart` | `DanhThiep`, `NguonDanhThiep`; mô hình dữ liệu, JSON, bản sao cập nhật và tên hiển thị. |
| `lib/mo_hinh/phan_tich_danh_thiep.dart` | `KetQuaPhanTich`, `BoPhanTichDanhThiep`; phân loại dữ liệu OCR và gộp kết quả theo thứ tự ưu tiên. |
| `lib/mo_hinh/chuan_hoa_nfc.dart` | `chuanHoaNfcViet`; ghép dấu Unicode tiếng Việt rời về dạng NFC. Không giao tiếp với phần cứng NFC. |
| `lib/mo_hinh/vcard.dart` | `TaoVCard` tạo vCard 3.0; `DocVCard` đọc vCard/MECARD. |
| `lib/mo_hinh/hoa_don.dart`, `lib/mo_hinh/xu_ly_van_ban.dart` | Mô hình ảnh/hóa đơn và các hàm xử lý văn bản dùng chung. |

### Dữ liệu, nền tảng và điều khiển

| File | Lớp / vai trò |
| --- | --- |
| `lib/du_lieu/kho_danh_thiep.dart` | `KhoDanhThiep`; lưu/đọc danh sách JSON, cập nhật theo ID, sắp xếp bản ghi mới nhất trước. |
| `lib/du_lieu/kho_khoa_gia_tri.dart` | Giao diện `KhoKhoaGiaTri` và `KhoBoNho` dùng trong kiểm thử. |
| `lib/du_lieu/xuat_vcard.dart` | Giao diện `BoXuatVCard` và `BoXuatVCardGia` dùng để giả lập chia sẻ. |
| `lib/du_lieu/luu_anh.dart`, `lib/nen_tang/nen_tang.dart` | Giao diện lưu ảnh và triển khai `LuuAnhTep`; ảnh danh thiếp dùng thư mục `danh_thiep`. `KhoPrefs` trong `nen_tang.dart` dùng `SharedPreferencesAsync`. |
| `lib/ocr/bo_quet_ma.dart` | Giao diện `BoQuetMa`, bản demo, bản rỗng và các kiểu lỗi quét. |
| `lib/nen_tang/quet_ma_mlkit.dart` | `BoQuetMaMlKit`; quét mã QR từ ảnh bằng ML Kit. |
| `lib/nen_tang/ocr_mlkit.dart` | `NhanDangMlKit`; OCR trên ảnh bằng ML Kit. |
| `lib/nen_tang/xuat_vcard_chia_se.dart` | `BoXuatVCardChiaSe`; ghi UTF-8 vào tệp tạm và gọi `share_plus`. |
| `lib/dieu_khien/quet_danh_thiep_dk.dart` | `DieuKhienQuetDanhThiep`; điều phối OCR, QR, nhập tay và trạng thái một lượt quét. |
| `lib/dieu_khien/lich_su_danh_thiep_dk.dart` | `DieuKhienLichSuDanhThiep`; tải, lưu, xóa danh thiếp/ảnh và xuất vCard. |
| `lib/dieu_khien/cai_dat_dk.dart`, `lib/cau_hinh/cau_hinh.dart` | Điều khiển ngôn ngữ, demo và cấu hình `OCR_MODE`. |
| `lib/dieu_khien/thong_bao.dart` | `CoThongBao`; cơ chế báo thay đổi cho các bộ điều khiển. |
| `lib/phu_thuoc.dart` | `PhuThuoc`; cung cấp các bộ điều khiển và dịch vụ trong cây widget, cho phép thay bằng bản giả khi test. |

### Giao diện và ngôn ngữ

| File | Vai trò |
| --- | --- |
| `lib/giao_dien/man_hinh_chinh.dart` | Khung điều hướng hai tab. |
| `lib/giao_dien/man_hinh_hoa_don.dart` | Tab lịch sử hóa đơn hiện có. |
| `lib/giao_dien/man_hinh_lich_su_danh_thiep.dart` | Danh sách danh thiếp, chụp/chọn ảnh và chọn mẫu. |
| `lib/giao_dien/man_hinh_quet_danh_thiep.dart` | Kết quả OCR/QR, nhập tay, sửa, lưu và xuất vCard. |
| `lib/giao_dien/man_hinh_chi_tiet_danh_thiep.dart` | Xem, sửa, xuất và xóa một danh thiếp. |
| `lib/giao_dien/man_hinh_quet_qr.dart` | Quét QR trực tiếp bằng camera. |
| `lib/giao_dien/thanh_phan/trinh_sua_danh_thiep.dart` | Các ô sửa danh thiếp dùng chung, bao gồm thao tác mở quét QR. |
| `lib/ngon_ngu/chuoi.dart`, `lib/ngon_ngu/du_lieu_chuoi.dart` | `Chuoi`, enum `K` và bảng chuỗi tiếng Việt/Anh. |
| `lib/app.dart` | `MaterialApp`, theme, locale và delegate bản địa hóa. |

## 3. Dữ liệu mẫu và kiểm tra QR

Ảnh mẫu danh thiếp nằm trong `assets/danh_thiep/`; thư mục này được khai báo trong `pubspec.yaml`. Thông tin mẫu là dữ liệu hư cấu.

| Tệp | Nội dung |
| --- | --- |
| `danh_thiep_1.jpg` | Danh thiếp mẫu thông thường, dùng thử nhận dạng OCR. |
| `danh_thiep_2_qr.jpg` | Danh thiếp có mã QR; nội dung QR mẫu có tên, công ty, chức vụ, điện thoại và email. Website/địa chỉ được bổ sung từ OCR. |
| `danh_thiep_mo.jpg` | Mẫu mờ để thử trạng thái không có chữ và chuyển sang nhập tay. |
| `danh_thiep_hong.jpg` | Mẫu lỗi để thử nhánh báo lỗi ảnh. |

Mở tab **Danh thiếp** → chọn **Thử với danh thiếp mẫu** → chọn ảnh. Trên Android/iOS ở chế độ thiết bị, OCR/QR xử lý ảnh bằng các plugin tương ứng. Chế độ demo không đọc ảnh thật: OCR trả văn bản mẫu; QR chỉ trả nội dung giả lập đã khai báo cho ảnh mẫu. Với ảnh người dùng trong demo, bộ quét QR demo trả danh sách rỗng.

Các test liên quan:

```bash
flutter test test/thuan/vcard_test.dart
flutter test test/thuan/danh_thiep_dieu_khien_test.dart
flutter test test/giao_dien/danh_thiep_luong_test.dart
```

`vcard_test.dart` kiểm tra payload QR mẫu và việc phân tích/gộp dữ liệu; các test điều khiển/widget kiểm tra thứ tự ưu tiên QR–OCR bằng bộ giả. Đây **không** phải kiểm thử camera hoặc mô hình ML Kit thực trên thiết bị. Muốn thử giải mã QR thật từ ảnh hoặc camera, chạy ứng dụng trên thiết bị Android/iOS và dùng chế độ thiết bị.

## 4. Cài đặt, chạy và kiểm thử

**Yêu cầu phiên bản** theo `pubspec.yaml`: Dart SDK `^3.12.0`, Flutter `>=3.44.0`.

Chạy các lệnh từ thư mục `hoa_don_nhap`:

```bash
flutter pub get
flutter devices
flutter run -d <device-id>
```

Cấu hình nhận dạng bằng `--dart-define=OCR_MODE=auto|device|demo`:

```bash
flutter run --dart-define=OCR_MODE=auto
flutter run --dart-define=OCR_MODE=device
flutter run --dart-define=OCR_MODE=demo
```

`auto` là mặc định: Android/iOS dùng ML Kit nếu không bật demo trong Cài đặt; nền tảng không có ML Kit dùng demo. `device` khóa chế độ demo và yêu cầu nền tảng hỗ trợ ML Kit. `demo` luôn dùng dữ liệu mẫu.

**Kiểm thử và phân tích tĩnh:**

```bash
flutter test
flutter test test/thuan
flutter test test/giao_dien
dart analyze lib test
```

Thư mục `test/thuan/` bao phủ mô hình, kho dữ liệu, cấu hình, bộ phân tích Regex, chuẩn hóa Unicode, vCard/MECARD và bộ điều khiển. `test/giao_dien/` bao phủ widget và các luồng chính. Lần chạy `flutter test` khi cập nhật tài liệu này hoàn tất với **137 test đạt**. Test dùng bản giả cho nhiều tích hợp; không thay thế kiểm thử thiết bị thật.

Lần chạy `dart analyze lib test` khi cập nhật tài liệu hoàn tất với một thông tin `deprecated_member_use`: `withOpacity` trong `lib/giao_dien/man_hinh_quet_qr.dart` được khuyến nghị thay bằng `withValues()`. Đây là thông tin mức `info`, không làm lệnh `dart analyze` thất bại.

## 5. Lưu dữ liệu

| Dữ liệu | Nơi lưu |
| --- | --- |
| Danh sách danh thiếp | JSON trong `SharedPreferencesAsync`, khóa `danh_thiep_v1`. |
| Ảnh danh thiếp | Thư mục tài liệu ứng dụng, thư mục con `danh_thiep`; ảnh mẫu dạng asset được giữ dưới dạng tham chiếu. |
| Tệp vCard khi chia sẻ | Thư mục tạm `<tmp>/vcard/`, ghi UTF-8 không BOM trước khi mở bảng chia sẻ. |

Danh thiếp và lịch sử hóa đơn có kho/khóa riêng. Trên web, cấu hình hiện tại dùng `LuuAnhGiuNguyen` và `BoXuatVCardGia`; đây không phải lưu ảnh tệp và chia sẻ vCard thật như triển khai nền tảng có hệ thống tệp.

## 6. Lưu ý khi chạy trên Android thật

- `android/app/build.gradle.kts` đặt `minSdk` tối thiểu là **24** và cấu hình Java/Kotlin **17**. Dùng Android SDK/Gradle tương thích với phiên bản Flutter của dự án.
- `android/app/src/main/AndroidManifest.xml` khai báo quyền `android.permission.CAMERA`. Cấp quyền camera khi hệ điều hành hỏi để dùng quét QR trực tiếp; nếu bị từ chối, kiểm tra lại quyền ứng dụng trong Cài đặt Android.
- ML Kit nhận dạng ảnh trên thiết bị; chế độ thực tế phụ thuộc `OCR_MODE` và nền tảng. Kiểm tra trên thiết bị Android thật bằng ảnh rõ, đủ sáng; test widget không kiểm tra khả năng nhận dạng của mô hình trên camera/phần cứng.
- Bản `release` trong `build.gradle.kts` hiện dùng cấu hình ký debug. Cần cấu hình khóa ký phát hành riêng trước khi phân phối ứng dụng.
- **Không có chức năng đọc NFC vật lý.** Chuẩn hóa Unicode NFC trong `chuan_hoa_nfc.dart` chỉ xử lý chuỗi ký tự. Dự án không có plugin, quyền Android hay luồng đọc thẻ NFC.

## 7. Ghi chú về phạm vi tài liệu

README này mô tả hành vi và cấu trúc có trong mã nguồn hiện tại. Quy trình dùng trợ lý AI, công cụ tạo ảnh mẫu hoặc tài liệu bàn giao giữa các phiên không thể được xác nhận chỉ từ mã ứng dụng; cần xác minh riêng với nhóm trước khi đưa các thông tin đó vào báo cáo.
