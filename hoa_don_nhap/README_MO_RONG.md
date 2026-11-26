# Quét hóa đơn nhập — Bản mở rộng: Quét danh thiếp

Tài liệu này mô tả phần **mở rộng** thêm vào dự án `hoa_don_nhap`. File `README.md` gốc được giữ nguyên.
Toàn bộ nhận dạng chạy **100% trên thiết bị**: không API key, không đăng nhập, không gọi dịch vụ đám mây.

## 1. Mục đích và tính năng mới

Ứng dụng giờ là công cụ quét tài liệu đa năng, hai chức năng chạy song song:

| Chức năng                                                       | Trạng thái                    |
| --------------------------------------------------------------- | ----------------------------- |
| Quét hóa đơn nhập (OCR, ghép dòng theo tọa độ, lịch sử hóa đơn) | Giữ nguyên, không đổi hành vi |
| **Quét danh thiếp vào danh bạ**                                 | Mới                           |

**Điều hướng.** Màn hình chính là một khung có thanh điều hướng 2 tab: **Hóa đơn** | **Danh thiếp**. Tab Hóa đơn chính là màn hình cũ (đổi tên lớp `ManHinhChinh` → `ManHinhHoaDon`). Tab Danh thiếp được dựng khi mở lần đầu và giữ trạng thái khi chuyển tab; nút Back ở tab Danh thiếp quay về tab Hóa đơn.

**Quét danh thiếp (OCR + Regex).** ML Kit Text Recognition (chạy offline) đọc chữ, sau đó `BoPhanTichDanhThiep` dùng biểu thức chính quy và heuristic để tách: họ tên, chức vụ, công ty, số điện thoại (kèm số thứ hai), email, website, địa chỉ. Bộ phân tích loại số fax, mã số thuế, số tài khoản; chuẩn hóa số điện thoại (`0912 345 678`, `+84 912 345 678`), email chữ thường, website bỏ `https://`.

**Quét mã QR trên danh thiếp (điểm cộng).** `google_mlkit_barcode_scanning` đọc mã QR; `DocVCard` hiểu cả **vCard** (2.1/3.0/4.0) lẫn **MECARD**. OCR và QR chạy song song rồi gộp: **QR được ưu tiên, OCR điền chỗ còn trống**. QR lỗi không làm hỏng lượt quét; OCR lỗi nhưng QR đọc được vẫn ra kết quả.

**Chỉnh sửa, lưu lịch sử, xuất vCard.**

- Người dùng kiểm tra và sửa 9 trường (8 trường thông tin + ghi chú) trước khi lưu; có thể xem văn bản OCR gốc.
- Danh thiếp lưu vào lịch sử riêng, tách biệt hoàn toàn với lịch sử hóa đơn.
- Xuất **`.vcf` (vCard 3.0)** cho một danh thiếp hoặc tất cả, qua hộp thoại chia sẻ của hệ điều hành (lưu vào Danh bạ, gửi đi, …).
- Cài đặt có mục "Xoá toàn bộ danh thiếp" (không ảnh hưởng hóa đơn).

**Đa ngôn ngữ.** 51 khóa chuỗi mới (tiền tố `dt`) cho cả tiếng Việt và tiếng Anh trong `lib/ngon_ngu/du_lieu_chuoi.dart`.

## 2. Cấu trúc file đã thêm / sửa

### Thêm mới

| File                                                 | Vai trò                                                               |
| ---------------------------------------------------- | --------------------------------------------------------------------- |
| `lib/mo_hinh/danh_thiep.dart`                        | Mô hình `DanhThiep`, enum `NguonDanhThiep` (ocr / qr / thucong), JSON |
| `lib/mo_hinh/phan_tich_danh_thiep.dart`              | `BoPhanTichDanhThiep` (Regex + heuristic), `KetQuaPhanTich`           |
| `lib/mo_hinh/vcard.dart`                             | `TaoVCard` (xuất vCard 3.0), `DocVCard` (đọc vCard / MECARD)          |
| `lib/mo_hinh/chuan_hoa_nfc.dart`                     | Gộp dấu tiếng Việt rời về dạng NFC                                    |
| `lib/du_lieu/kho_danh_thiep.dart`                    | `KhoDanhThiep`: lưu/đọc lịch sử danh thiếp                            |
| `lib/du_lieu/xuat_vcard.dart`                        | Giao diện `BoXuatVCard` + bản giả dùng cho test                       |
| `lib/ocr/bo_quet_ma.dart`                            | Giao diện `BoQuetMa` (QR), bản rỗng và bản demo                       |
| `lib/ocr/mau_danh_thiep.dart`                        | 4 danh thiếp mẫu + văn bản / mã QR demo                               |
| `lib/ocr/nhan_dang_demo_danh_thiep.dart`             | Bộ nhận dạng demo cho danh thiếp                                      |
| `lib/dieu_khien/quet_danh_thiep_dk.dart`             | `DieuKhienQuetDanhThiep` (OCR + QR, gộp kết quả)                      |
| `lib/dieu_khien/lich_su_danh_thiep_dk.dart`          | `DieuKhienLichSuDanhThiep` (tải, lưu, xoá, xuất)                      |
| `lib/nen_tang/quet_ma_mlkit.dart`                    | `BoQuetMaMlKit` (ML Kit Barcode, chỉ QR)                              |
| `lib/nen_tang/xuat_vcard_chia_se.dart`               | `BoXuatVCardChiaSe` (ghi tệp `.vcf` tạm + `share_plus`)               |
| `lib/giao_dien/man_hinh_hoa_don.dart`                | Màn lịch sử hóa đơn (chuyển từ `man_hinh_chinh.dart` cũ)              |
| `lib/giao_dien/man_hinh_lich_su_danh_thiep.dart`     | Danh sách danh thiếp, chụp / chọn ảnh / thử mẫu                       |
| `lib/giao_dien/man_hinh_quet_danh_thiep.dart`        | Màn quét và sửa kết quả                                               |
| `lib/giao_dien/man_hinh_chi_tiet_danh_thiep.dart`    | Xem, sửa, xuất, xoá một danh thiếp                                    |
| `lib/giao_dien/thanh_phan/trinh_sua_danh_thiep.dart` | Khung sửa 9 trường dùng chung                                         |
| `assets/danh_thiep/`                                 | 4 ảnh mẫu (xem mục 3)                                                 |

### Chỉnh sửa

| File                                  | Thay đổi                                                                              |
| ------------------------------------- | ------------------------------------------------------------------------------------- |
| `lib/giao_dien/man_hinh_chinh.dart`   | Viết lại thành khung 2 tab (`NavigationBar`)                                          |
| `lib/giao_dien/man_hinh_cai_dat.dart` | Thêm mục "Xoá toàn bộ danh thiếp"; mục hóa đơn y nguyên                               |
| `lib/phu_thuoc.dart`                  | Thêm tham số **tùy chọn** cho danh thiếp (mặc định an toàn nên test cũ không cần đổi) |
| `lib/main.dart`                       | Dựng các thành phần danh thiếp (ML Kit trên máy thật, demo trên web/desktop)          |
| `lib/nen_tang/nen_tang.dart`          | `LuuAnhTep` thêm tham số `tenThuMuc` (mặc định `'hoa_don'`, hành vi cũ giữ nguyên)    |
| `lib/ngon_ngu/du_lieu_chuoi.dart`     | Thêm khóa `dt*` (vi/en); khóa cũ giữ nguyên                                           |
| `pubspec.yaml`                        | Thêm `google_mlkit_barcode_scanning`, `share_plus`, asset `assets/danh_thiep/`        |

### Bộ test mới

| File                                         | Nội dung                                                                                      |
| -------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `test/thuan/phan_tich_danh_thiep_test.dart`  | Bộ phân tích: danh thiếp mẫu, số điện thoại, email/website, đầu vào xấu, gộp QR+OCR           |
| `test/thuan/vcard_test.dart`                 | `TaoVCard` (so khớp từng dòng, escape, gấp dòng 75 byte), `DocVCard` (vCard, MECARD, QR thật) |
| `test/thuan/mau_danh_thiep_test.dart`        | Ảnh mẫu tồn tại, JPEG thật (trừ mẫu hỏng), pubspec khai báo asset                             |
| `test/thuan/danh_thiep_dieu_khien_test.dart` | NFC, `KhoDanhThiep`, `DieuKhienQuetDanhThiep`, `DieuKhienLichSuDanhThiep`                     |
| `test/giao_dien/danh_thiep_luong_test.dart`  | Luồng giao diện: tab → thử mẫu → lưu → xem → sửa → xoá, cài đặt                               |

Mã nguồn và test gốc (`test/thuan/` và `test/giao_dien/` cũ) không bị xóa hay sửa hành vi.

## 3. Cài đặt, chạy thử, chạy kiểm thử

**Yêu cầu:** Dart SDK `^3.12.0`, Flutter `>=3.44.0` (theo `pubspec.yaml`).

```bash
flutter pub get
flutter run            # chọn thiết bị Android/iOS (hoặc máy ảo)
```

**Thử với danh thiếp mẫu.** Ảnh mẫu nằm ở `assets/danh_thiep/` (toàn bộ dữ liệu hư cấu):

| Tệp                   | Mục đích                                                                                              |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| `danh_thiep_1.jpg`    | Danh thiếp chuẩn                                                                                      |
| `danh_thiep_2_qr.jpg` | Danh thiếp có mã QR (QR chỉ có tên, công ty, chức vụ, SĐT, email; website và địa chỉ phải đến từ OCR) |
| `danh_thiep_mo.jpg`   | Ảnh mờ, không có chữ → thông báo "không có chữ", chuyển sang nhập tay                                 |
| `danh_thiep_hong.jpg` | Tệp không phải ảnh → thông báo lỗi                                                                    |

Cách thử trên máy ảo không có camera: mở tab **Danh thiếp** → bấm **Thử mẫu** → chọn một mẫu.

- Trên thiết bị Android/iOS: ML Kit đọc **thật** ảnh mẫu (kết quả có thể lệch chút ít).
- Ở **chế độ demo** (bật trong Cài đặt) và trên web/desktop: app trả về văn bản và nội dung QR giả lập định sẵn.

Quét danh thiếp thật: chụp ảnh hoặc chọn từ thư viện trong tab Danh thiếp.

**Chạy kiểm thử:**

```bash
flutter test                      # toàn bộ (gồm 55 test gốc + test danh thiếp)
flutter test test/thuan           # test logic thuần
flutter test test/giao_dien       # test giao diện
dart analyze lib test
```

## 4. Nơi lưu dữ liệu danh thiếp trên thiết bị

| Dữ liệu                     | Nơi lưu                                                                                      |
| --------------------------- | -------------------------------------------------------------------------------------------- |
| Danh sách danh thiếp (JSON) | `SharedPreferences`, khóa **`danh_thiep_v1`** (hóa đơn dùng khóa riêng `lich_su_hoa_don_v1`) |
| Ảnh danh thiếp              | Thư mục tài liệu của ứng dụng: `<tài liệu app>/danh_thiep/<id>.jpg`                          |
| Tệp `.vcf` khi xuất         | Thư mục tạm `<tmp>/vcard/` (ghi UTF-8, không BOM, chỉ để chia sẻ)                            |

Dữ liệu chỉ nằm trên máy. Gỡ ứng dụng hoặc "Xoá toàn bộ danh thiếp" trong Cài đặt sẽ xóa dữ liệu này. Trên web, ảnh không được lưu (giữ nguyên trong bộ nhớ).

## 5. Dùng trợ lý AI

- **Công cụ:** Claude (Anthropic), dùng qua giao diện chat, làm việc theo từng bước nhỏ với tệp bàn giao `docs/HANDOFF.md` để giữ ngữ cảnh giữa các phiên.
- **AI hỗ trợ ở:**
  - Phân tích kiến trúc dự án và lập kế hoạch từng file.
  - Viết mã Dart cho các phần mới: mô hình, bộ phân tích Regex/heuristic, `TaoVCard`/`DocVCard`, kho dữ liệu, bộ điều khiển, lớp ML Kit/chia sẻ, màn hình, chuỗi song ngữ.
  - Sửa nhỏ các file gốc (`phu_thuoc.dart`, `main.dart`, `nen_tang.dart`, `man_hinh_chinh.dart`, `man_hinh_cai_dat.dart`) theo nguyên tắc tham số tùy chọn để không làm vỡ test cũ.
  - Viết test mới và sinh bộ ảnh danh thiếp mẫu (Pillow, mã QR tạo bằng OpenCV).
  - Soạn tài liệu này.
- **Giới hạn:** môi trường của AI không chạy được Dart/Flutter. Mọi lệnh `dart analyze`, `flutter test` và việc thử trên thiết bị do **người phát triển tự chạy**, rồi gửi kết quả để AI sửa lỗi. Người phát triển chịu trách nhiệm duyệt, tích hợp và kiểm thử toàn bộ mã.
