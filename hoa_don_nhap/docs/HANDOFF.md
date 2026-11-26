# HANDOFF: Mở rộng "Quét danh thiếp"

## 1. Tổng quan tiến độ

0%. Giai đoạn: đã phân tích README + pubspec, chờ người dùng duyệt kế hoạch và gửi file lib/ cũ.

## 2. Các file đã tạo/sửa hoàn chỉnh

(chưa có)

## 3. File đang làm dở

(không)

## 4. Kế hoạch bước tiếp theo

- A1 lib/mo_hinh/danh_thiep.dart; A2 lib/mo_hinh/phan_tich_danh_thiep.dart (không cần file cũ).
- Cần cung cấp: phu_thuoc.dart, main.dart, app.dart, 1 test widget + helper, du_lieu/\*, du_lieu_chuoi.dart.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

- SharedPreferences: khoá danh sách danh thiếp `danh_thiep_v1`.
- Ảnh: <tài liệu app>/danh_thiep/<mã>.jpg. Asset mẫu: assets/danh_thiep/.
- Lớp: DanhThiep, BoPhanTichDanhThiep, TaoVCard, DocVCard, KhoDanhThiep,
  BoQuetMa, BoXuatVCard, DieuKhienQuetDanhThiep, DieuKhienLichSuDanhThiep, ManHinhChinh.
- Khoá chuỗi mới: tiền tố `dt_`. Trường `nguon`: ocr | qr | thucong.
- PhuThuoc: tham số mới phải TUỲ CHỌN để 55 test cũ không vỡ.
- Không đổi hành vi "Xoá toàn bộ" của hóa đơn.

# cập nhật sau Bước A1 + A2

## 1. Tổng quan tiến độ

Khoảng 9% (2/23 hạng mục: A1, A2 xong). Giai đoạn A (nền tảng dữ liệu, Dart thuần) đang làm.
Chưa gửi file cũ nào trong lib/. Chưa chạy được dart analyze/test (môi trường AI không có Dart):
NGƯỜI DÙNG CẦN chạy `dart analyze lib/mo_hinh` và thử tool/thu_phan_tich.dart.

## 2. Các file đã tạo/sửa hoàn chỉnh

- lib/mo_hinh/danh_thiep.dart: enum NguonDanhThiep {ocr, qr, thucong} (+ tuTen);
  class DanhThiep (bất biến) với copyWith(xoaAnh), toJson/fromJson (chịu dữ liệu hỏng), ==, hashCode,
  getter coNoiDung, tenHienThi, chuCaiDau.
- lib/mo_hinh/phan_tich_danh_thiep.dart: class KetQuaPhanTich (rong, boSung(khac), taoDanhThiep(...));
  abstract final class BoPhanTichDanhThiep.phanTich(String) → KetQuaPhanTich. Tách email, website,
  SĐT VN/quốc tế (loại fax, MST, STK), chức vụ, công ty, địa chỉ, họ tên (điểm số heuristic).

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- A3 lib/mo_hinh/vcard.dart: TaoVCard.tao(DanhThiep) (vCard 3.0, escape \ , ; xuống dòng, gấp dòng 75 byte,
  2 dòng TEL nếu có dienThoaiKhac, thêm https:// cho URL) và DocVCard.doc(String) cho BEGIN:VCARD và MECARD:
  → trả KetQuaPhanTich (để dùng boSung với kết quả OCR).
- A4 lib/du_lieu/kho_danh_thiep.dart; A5 lib/du_lieu/xuat_vcard.dart.
- A3 không cần file cũ. Từ A4 nên có: lib/du_lieu/ (kho lịch sử hóa đơn, lưu ảnh) để theo đúng phong cách.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

- THAY ĐỔI so với kế hoạch: DanhThiep có thêm `dienThoaiKhac` (số thứ hai, thường máy bàn).
- Trường DanhThiep: id, thoiGian, hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website,
  diaChi, ghiChu, duongDanAnh (String?), nguon. Khoá JSON trùng tên trường; thoiGian = ISO-8601;
  nguon = tên enum ('ocr'|'qr'|'thucong').
- KetQuaPhanTich: hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website, diaChi, dongConLai.
  Gộp QR+OCR: `ketQuaQr.boSung(ketQuaOcr)` (QR ưu tiên, OCR điền chỗ trống).
- SĐT lưu dạng hiển thị: "0912 345 678", "024 3333 4444", "+84 912 345 678".
- Website lưu không có "https://" (vCard sẽ thêm). Email lưu chữ thường.
- SharedPreferences: khoá danh sách danh thiếp `danh_thiep_v1`. Ảnh: <tài liệu app>/danh_thiep/<id>.jpg.
  Asset mẫu: assets/danh_thiep/.
- Lớp đã chốt (chưa viết): TaoVCard, DocVCard, KhoDanhThiep, BoQuetMa, BoXuatVCard,
  DieuKhienQuetDanhThiep, DieuKhienLichSuDanhThiep, ManHinhChinh. Khoá chuỗi mới: tiền tố `dt_`.
- PhuThuoc: tham số mới phải TUỲ CHỌN để 55 test cũ không vỡ. Không đổi hành vi "Xoá toàn bộ" hóa đơn.
- Bộ phân tích giả định văn bản NFC; nếu OCR trả NFD thì chuẩn hoá NFC ở DieuKhienQuetDanhThiep (B3).

# cập nhật sau A3

## 1. Tổng quan tiến độ

Khoảng 13% (3/23 hạng mục: A1, A2, A3 xong). Giai đoạn A (nền tảng dữ liệu, Dart thuần) đang làm, còn A4, A5.
Chưa gửi file cũ nào trong lib/. AI chưa chạy được dart analyze/test (không có Dart):
NGƯỜI DÙNG CẦN chạy `dart analyze lib/mo_hinh` và thử tool/thu_phan_tich.dart, tool/thu_vcard.dart
(xoá hai tệp tool này khi xong).

## 2. Các file đã tạo/sửa hoàn chỉnh

- lib/mo_hinh/danh_thiep.dart: enum NguonDanhThiep {ocr, qr, thucong} (+ tuTen);
  class DanhThiep (bất biến) với copyWith(xoaAnh), toJson/fromJson (chịu dữ liệu hỏng), ==, hashCode,
  getter coNoiDung, tenHienThi, chuCaiDau.
- lib/mo_hinh/phan_tich_danh_thiep.dart: class KetQuaPhanTich (rong, boSung(khac), taoDanhThiep(...));
  abstract final class BoPhanTichDanhThiep.phanTich(String) → KetQuaPhanTich. Tách email, website,
  SĐT VN/quốc tế (loại fax, MST, STK), chức vụ, công ty, địa chỉ, họ tên (điểm số heuristic).
- lib/mo_hinh/vcard.dart: abstract final class TaoVCard {tao(DanhThiep), taoNhieu(Iterable), tenTep(DanhThiep),
  mimeType='text/vcard', phanMoRong='vcf'} (vCard 3.0, CRLF, gấp dòng 75 byte UTF-8, escape \ ; , xuống dòng);
  abstract final class DocVCard {nhanDang(String) → bool, doc(String) → KetQuaPhanTich} đọc vCard 2.1/3.0/4.0
  (kể cả quoted-printable) và MECARD; trả KetQuaPhanTich rỗng nếu không nhận ra. Phụ thuộc phan_tich_danh_thiep.dart.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- A4 lib/du_lieu/kho_danh_thiep.dart: giao diện KhoDanhThiep (tai, luu, xoa, xoaTatCa), bản bộ nhớ, bản
  SharedPreferencesAsync (khoá `danh_thiep_v1`). A5 lib/du_lieu/xuat_vcard.dart: giao diện BoXuatVCard
  (ghi .vcf tạm + chia sẻ) và bản giả để test.
- Để A4/A5 đúng phong cách dự án, NGƯỜI DÙNG gửi: file kho lịch sử hóa đơn trong lib/du_lieu/ (cùng giao diện và
  bản bộ nhớ), file lưu ảnh, file nen_tang/ cài đặt shared_preferences tương ứng.
  Nếu chưa gửi thì AI viết A4/A5 theo giả định và đánh dấu chỗ cần đối chiếu.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

- THAY ĐỔI so với kế hoạch: DanhThiep có thêm `dienThoaiKhac` (số thứ hai, thường máy bàn); vCard xuất 2 dòng TEL.
- Trường DanhThiep: id, thoiGian, hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website,
  diaChi, ghiChu, duongDanAnh (String?), nguon. Khoá JSON trùng tên trường; thoiGian = ISO-8601;
  nguon = tên enum ('ocr'|'qr'|'thucong').
- KetQuaPhanTich: hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website, diaChi, dongConLai.
  Gộp QR+OCR (B3): `DocVCard.doc(noiDungQr).boSung(BoPhanTichDanhThiep.phanTich(vanBanOcr))`
  (QR ưu tiên, OCR điền chỗ trống). Với nhiều mã QR: chọn mã đầu có DocVCard.nhanDang(...) và !doc(...).rong.
- dongConLai từ DocVCard chứa NOTE/phòng ban/mục thừa: B3 quyết định có đưa vào ghiChu không.
- SĐT lưu dạng hiển thị: "0912 345 678", "024 3333 4444", "+84 912 345 678".
- Website lưu không có "https://" (TaoVCard tự thêm). Email lưu chữ thường.
- vCard: N theo thứ tự Việt Nam (họ;tên;đệm), FN giữ nguyên; ADR đặt trọn vào ô "đường";
  TEL;TYPE=CELL cho di động VN 10 số, còn lại WORK,VOICE. Tên tệp: danh*thiep*<id>.vcf.
- SharedPreferences: khoá danh sách danh thiếp `danh_thiep_v1`. Ảnh: <tài liệu app>/danh_thiep/<id>.jpg.
  Asset mẫu: assets/danh_thiep/.
- Lớp đã chốt (chưa viết): KhoDanhThiep, BoQuetMa, BoXuatVCard, DieuKhienQuetDanhThiep,
  DieuKhienLichSuDanhThiep, ManHinhChinh. Khoá chuỗi mới: tiền tố `dt_`.
- PhuThuoc: tham số mới phải TUỲ CHỌN để 55 test cũ không vỡ. Không đổi hành vi "Xoá toàn bộ" hóa đơn.
- Bộ phân tích giả định văn bản NFC; nếu OCR trả NFD thì chuẩn hoá NFC ở DieuKhienQuetDanhThiep (B3).

# cập nhật sau A4 + A5

## 1. Tổng quan tiến độ

Khoảng 22% (5/23 hạng mục: A1–A5 xong). Giai đoạn A (nền tảng dữ liệu, Dart thuần) HOÀN TẤT.
Tiếp theo: giai đoạn B (OCR/QR + bộ điều khiển).
Đã nhận file cũ: lib/nen*tang/nen_tang.dart, lib/du_lieu/kho_lich_su.dart, lib/du_lieu/kho_khoa_gia_tri.dart.
AI chưa chạy được dart analyze/test (không có Dart). NGƯỜI DÙNG CẦN chạy `dart analyze lib` và thử
tool/thu_phan_tich.dart, tool/thu_vcard.dart, tool/thu_kho.dart (xoá các tệp tool/thu*\*.dart khi xong).

## 2. Các file đã tạo/sửa hoàn chỉnh

- lib/mo_hinh/danh_thiep.dart: enum NguonDanhThiep {ocr, qr, thucong} (+ tuTen);
  class DanhThiep (bất biến) với copyWith(xoaAnh), toJson/fromJson (chịu dữ liệu hỏng), ==, hashCode,
  getter coNoiDung, tenHienThi, chuCaiDau.
- lib/mo_hinh/phan_tich_danh_thiep.dart: class KetQuaPhanTich (rong, boSung(khac), taoDanhThiep(...));
  abstract final class BoPhanTichDanhThiep.phanTich(String) → KetQuaPhanTich. Tách email, website,
  SĐT VN/quốc tế (loại fax, MST, STK), chức vụ, công ty, địa chỉ, họ tên (điểm số heuristic).
- lib/mo_hinh/vcard.dart: TaoVCard {tao, taoNhieu, tenTep, mimeType, phanMoRong} (vCard 3.0, CRLF, gấp dòng 75 byte);
  DocVCard {nhanDang(String), doc(String) → KetQuaPhanTich} đọc vCard 2.1/3.0/4.0 + MECARD.
- lib/du_lieu/kho_danh_thiep.dart: class KhoDanhThiep(KhoKhoaGiaTri) {static khoa='danh_thiep_v1',
  docTatCa() (bỏ bản ghi hỏng/thiếu id, ném FormatException nếu cả JSON hỏng), luu(d) (ArgumentError nếu id rỗng;
  trả danh sách mới nhất trước), xoa(id), xoaHet()}. Dùng KhoPrefs (máy thật) / KhoBoNho (test) có sẵn.
- lib/du_lieu/xuat_vcard.dart: abstract interface BoXuatVCard {chiaSe({tenTep, noiDung})};
  LoiXuatVCard(chiTiet); TepDaXuat; BoXuatVCardGia {daXuat, loi} cho test.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- B1 lib/ocr/bo_quet_ma.dart: giao diện BoQuetMa.quet(duongDan) → Future<List<String>> (nội dung các mã QR/vạch
  đọc được), LoiQuetMa nếu cần, BoQuetMaDemo (trả nội dung theo ảnh mẫu).
- B2 lib/ocr/mau_danh_thiep.dart: 4 ảnh mẫu (chuẩn, có QR, mờ, hỏng), văn bản demo, nội dung QR demo (vCard).
  B2 cần xem cách module demo/mẫu hóa đơn đang ánh xạ ảnh → văn bản.
- NGƯỜI DÙNG gửi cho B1/B2: toàn bộ lib/ocr/\* (bo_nhan_dang.dart, bản demo, mẫu hóa đơn, ghép dòng),
  lib/mo_hinh/hoa_don.dart (để xem AnhHoaDon, tuJson), lib/du_lieu/luu_anh.dart, lib/du_lieu/bo_chon_anh.dart.
- Sau đó: B3 DieuKhienQuetDanhThiep (cần thêm lib/dieu_khien/dieu_khien_quet.dart + co_thong_bao.dart),
  B4 DieuKhienLichSuDanhThiep, B5 nen_tang (QR ML Kit, chia sẻ .vcf).

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

- THAY ĐỔI so với kế hoạch gốc:
  (a) DanhThiep có thêm `dienThoaiKhac`; vCard xuất 2 dòng TEL.
  (b) KhoDanhThiep là lớp cụ thể bọc KhoKhoaGiaTri (giống KhoLichSu), KHÔNG có bản SharedPreferences riêng.
  (c) BoXuatVCard.chiaSe nhận tenTep + noiDung (nội dung do TaoVCard tạo trong bộ điều khiển B4), bản thật
  (B5) chỉ ghi tệp tạm UTF-8 không BOM + chia sẻ bằng share_plus.
- Khác quy ước HoaDon: HoaDon dùng ma/taoLuc/tuJson; DanhThiep dùng id/thoiGian/fromJson. Đã chốt giữ nguyên;
  đổi nếu người dùng muốn đồng nhất.
- Trường DanhThiep: id, thoiGian, hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website,
  diaChi, ghiChu, duongDanAnh (String?), nguon. Khoá JSON trùng tên trường; thoiGian = ISO-8601;
  nguon = tên enum ('ocr'|'qr'|'thucong').
- KetQuaPhanTich: hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website, diaChi, dongConLai.
  Gộp QR+OCR (B3): `DocVCard.doc(noiDungQr).boSung(BoPhanTichDanhThiep.phanTich(vanBanOcr))`
  (QR ưu tiên). Nhiều mã QR: chọn mã đầu có DocVCard.nhanDang(...) và !doc(...).rong.
- dongConLai từ DocVCard chứa NOTE/phòng ban/mục thừa: B3 quyết định có đưa vào ghiChu không.
- SĐT lưu dạng hiển thị "0912 345 678", "024 3333 4444", "+84 912 345 678". Website lưu không có "https://".
  Email chữ thường.
- vCard: N theo thứ tự Việt Nam (họ;tên;đệm), FN giữ nguyên; ADR đặt trọn vào ô "đường";
  TEL;TYPE=CELL cho di động VN 10 số, còn lại WORK,VOICE. Tên tệp: danh*thiep*<id>.vcf.
- Cấu trúc cũ đã biết: lib/nen_tang/nen_tang.dart chứa coOcrThietBi, KhoPrefs, LuuAnhTep, chepAssetRaTepTam, ChonAnh
  (một file). Ảnh dùng AnhHoaDon (laAsset, duongDan, AnhHoaDon.tep(path)), BoChonAnh/NguonAnh/LoiChonAnh/LoaiLoiChonAnh
  — TÁI DÙNG cho danh thiếp, không viết bản song song.
- CẦN SỬA khi tới C6/B5: LuuAnhTep thêm tham số tuỳ chọn `tenThuMuc` (mặc định 'hoa_don') → danh thiếp dùng
  LuuAnhTep(tenThuMuc: 'danh_thiep'). Hành vi cũ giữ nguyên.
- SharedPreferences: khoá danh sách danh thiếp `danh_thiep_v1` (hóa đơn: `lich_su_hoa_don_v1`).
  Ảnh: <tài liệu app>/danh_thiep/<id>.jpg. Asset mẫu: assets/danh_thiep/.
- Lớp đã chốt (chưa viết): BoQuetMa, DieuKhienQuetDanhThiep, DieuKhienLichSuDanhThiep, ManHinhChinh.
  Khoá chuỗi mới: tiền tố `dt_`.
- PhuThuoc: tham số mới phải TUỲ CHỌN để 55 test cũ không vỡ. Không đổi hành vi "Xoá toàn bộ" hóa đơn.
- Bộ phân tích giả định văn bản NFC; nếu OCR trả NFD thì chuẩn hoá NFC ở DieuKhienQuetDanhThiep (B3).

# cập nhật sau B1 + B2

## 1. Tổng quan tiến độ

Khoảng 30% (7/23: A1–A5, B1, B2 xong). Giai đoạn B (OCR/QR + bộ điều khiển) đang làm; còn B3, B4, B5.
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib` và các tool/thu*\*.dart
(xoá tool/thu*_.dart khi xong). Ảnh mẫu assets/danh_thiep/_.jpg CHƯA được tạo.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ nguyên danh sách A1–A5 ở mục trước) và thêm:

- lib/ocr/bo_quet_ma.dart: enum LoaiLoiQuetMa {khongDocDuocAnh, khongHoTro, thatBai}; LoiQuetMa(loai, [chiTiet]);
  abstract interface BoQuetMa {laDemo, quet(AnhHoaDon) → Future<List<String>>, dong()};
  BoQuetMaRong (const, luôn []); BoQuetMaDemo({treo=400ms}) tra theo asset mẫu danh thiếp.
  LƯU Ý: import KieuMau phải là `hoa_don_mau.dart`.
- lib/ocr/mau_danh_thiep.dart: class DanhThiepMau {ma, asset, tenVi, tenEn, kieu(KieuMau), vanBan, noiDungQr, coQr};
  dsDanhThiepMau (chuan, co_qr, anh_mo, anh_hong); timDanhThiepMauTheoAsset(asset).

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- B3 lib/dieu_khien/quet_danh_thiep_dk.dart: DieuKhienQuetDanhThiep (theo mẫu quet_dk.dart: with CoThongBao,
  trạng thái dangNhanDang/coChu/khongCoChu/loi, chuẩn hoá NFC, gộp QR+OCR, taoDanhThiep, huỷ an toàn).
- B4 lib/dieu_khien/lich_su_danh_thiep_dk.dart: DieuKhienLichSuDanhThiep (tải, xoá, xuất vCard qua BoXuatVCard).
- B5 lib/nen_tang/: bản ML Kit của BoQuetMa + bản chia sẻ BoXuatVCard (share_plus).
- Tạo ảnh mẫu assets/danh_thiep/ (cần môi trường có Python/PIL + thư viện qrcode, hoặc người dùng tự cung cấp).
- Không cần gửi thêm file cho B3. Cần gửi cho B4/B5: lib/dieu_khien/ (điều khiển lịch sử hóa đơn).

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và SỬA/THÊM:

- Tên thực tế của file cũ: lib/dieu_khien/quet_dk.dart (lớp DieuKhienQuet, TrangThaiQuet) và
  lib/dieu_khien/thong_bao.dart (mixin CoThongBao: themNghe, boNghe, baoThayDoi, huy, daHuy),
  KHÔNG phải dieu_khien_quet.dart / co_thong_bao.dart. File mới đặt tên theo kiểu \*\_dk.dart.
- Mẫu bộ điều khiển: DieuKhienQuet nhận boNhanDang, anh (AnhHoaDon), nguon, bayGio, ngauNhien (tiêm để test);
  dùng chuanHoaVanBan, demDong, doanTieuDe, taoMa(DateTime, int) từ mo_hinh/xu_ly_van_ban.dart.
- BoNhanDang.nhanDang(AnhHoaDon) → KetQuaNhanDang{vanBan, soDong, thoiGian, trong}; LoiNhanDang(LoaiLoiNhanDang).
- HoaDon.ma/taoLuc; NguonAnh {mayAnh, thuVien, mau} dùng chung cho danh thiếp (nguồn ảnh khác với
  DanhThiep.nguon ocr|qr|thucong).
- Asset mẫu danh thiếp: danh_thiep_1.jpg, danh_thiep_2_qr.jpg, danh_thiep_mo.jpg, danh_thiep_hong.jpg.

# cập nhật sau B3

## 1. Tổng quan tiến độ

Khoảng 35% (8/23: A1–A5, B1, B2, B3 xong). Giai đoạn B đang làm; còn B4, B5.
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`.
Ảnh mẫu assets/danh_thiep/\*.jpg CHƯA tạo. Chưa viết test cho phần danh thiếp.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách A1–A5, B1, B2) và thêm:

- lib/mo_hinh/chuan_hoa_nfc.dart: chuanHoaNfcViet(String) → String; gộp dấu rời về NFC cho 12 nguyên âm
  tiếng Việt, chịu cả hai thứ tự dấu; đường nhanh nếu không có ký tự 0x0300–0x036F.
- lib/dieu_khien/quet_danh_thiep_dk.dart: DieuKhienQuetDanhThiep(boNhanDang, anh, boQuetMa?=BoQuetMaRong,
  bayGio?, ngauNhien?) with CoThongBao; trangThai (TrangThaiQuet của quet_dk.dart), ketQua (KetQuaPhanTich?),
  vanBanOcr, daDungQr, thoiGian, loi (LoiNhanDang?), loiQuetMa, nhapTay, getter nguon (NguonDanhThiep),
  laDemo; batDau() chạy OCR+QR song song rồi gộp qr.boSung(ocr); chuyenSangNhapTay();
  taoDanhThiep({hoTen, chucVu, congTy, dienThoai, dienThoaiKhac, email, website, diaChi, ghiChu, duongDanAnh?}).
  QR lỗi không làm hỏng lượt quét; OCR lỗi mà QR đọc được vẫn coChu.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- B4 lib/dieu_khien/lich_su_danh_thiep_dk.dart: DieuKhienLichSuDanhThiep (tải, luu, xoa, xuất vCard 1 hoặc nhiều
  qua TaoVCard + BoXuatVCard; trạng thái tải/lỗi/trống giống lịch sử hóa đơn).
  NGƯỜI DÙNG gửi: file điều khiển lịch sử hóa đơn trong lib/dieu_khien/ (tên có thể là lich_su_dk.dart).
- B5 lib/nen_tang/: bản ML Kit của BoQuetMa + bản chia sẻ BoXuatVCard (share_plus); sửa LuuAnhTep (tenThuMuc).
  Gửi: lib/nen_tang/nen_tang.dart (nếu có thay đổi), lib/ocr/dinh_dang_anh.dart và ghep_dong.dart nếu có code.
- Tạo ảnh mẫu assets/danh_thiep/ (Python PIL + qrcode, nếu môi trường có).

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Giả định chưa kiểm chứng: constructor DanhThiep nhận 13 tham số có tên; KetQuaPhanTich.boSung trả KetQuaPhanTich;
  kiểu dongConLai chưa dùng.
- DanhThiep.duongDanAnh mặc định = AnhHoaDon.maHoa() ("asset:..." cho ảnh mẫu); giải mã bằng AnhHoaDon.giaiMa.
- Test cần viết: mỗi hàng \_hang của chuan_hoa_nfc có đúng 6 ký tự; NFD → NFC (ví dụ a+0323+0302 → ậ).

# cập nhật sau B4

## 1. Tổng quan tiến độ

Khoảng 39% (9/23: A1–A5, B1–B4 xong). Giai đoạn B còn B5 (nen*tang).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib tool` và 3 tool mới:
tool/thu_quet_ma.dart (B1+B2), tool/thu_quet_danh_thiep.dart (B3), tool/thu_lich_su_danh_thiep.dart (B4).
Xoá tool/thu*_.dart khi xong. Ảnh mẫu assets/danh_thiep/_.jpg CHƯA tạo. Chưa viết test chính thức.
QUY ƯỚC MỚI: sau mỗi lượt AI thêm mục "Kiểm tra nhanh" (tool/thu\_\*.dart chạy bằng dart run).

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ A1–A5, B1–B3) và thêm:

- lib/ocr/nhan_dang_demo_danh_thiep.dart: NhanDangDemoDanhThiep({treo=1200ms}) implements BoNhanDang;
  tra dsDanhThiepMau (bình thường → vanBan; mờ → rỗng; hỏng → LoiNhanDang; ảnh tự chọn → mẫu đầu).
  LÝ DO: NhanDangDemo cũ chỉ tra mẫu hóa đơn.
- lib/dieu_khien/lich_su_danh_thiep_dk.dart: DieuKhienLichSuDanhThiep(KhoDanhThiep, LuuAnh, BoXuatVCard)
  with CoThongBao; dùng TrangThaiLichSu của lich_su_dk.dart; trangThai, ds, loi, trong; tai(), tim(id),
  luu(DanhThiep) (chép ảnh qua LuuAnh.giuLai rồi copyWith(duongDanAnh: maHoa())), xoa(id), xoaHet(),
  xuatMot(DanhThiep), xuatTatCa() → bool (false nếu trống; tên tệp danh_thiep_tat_ca.vcf).

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- B5 lib/nen_tang/: bản ML Kit của BoQuetMa (google_mlkit_barcode_scanning, chỉ QR), bản BoXuatVCard
  (share_plus + ghi tệp tạm UTF-8 không BOM), LuuAnhTep thêm `tenThuMuc` (mặc định 'hoa_don').
  Cần: lib/nen_tang/nen_tang.dart (đầy đủ), lib/du_lieu/luu_anh.dart, lib/ocr/dinh_dang_anh.dart và
  ghep_dong.dart (nếu có code), pubspec.yaml hiện tại.
- Sau B5: giai đoạn C (PhuThuoc tuỳ chọn, chuỗi dt\_\*, màn hình, điều hướng), D (test, README_MO_RONG.md, ảnh mẫu).

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Giả định chưa kiểm chứng: LuuAnh.giuLai(AnhHoaDon, String) → Future<AnhHoaDon>; LuuAnh.xoa(AnhHoaDon?);
  DanhThiep.copyWith có tham số duongDanAnh; BoXuatVCard.chiaSe trả Future; KhoBoNho() không tham số.
- Màn hình danh thiếp dùng NhanDangDemoDanhThiep (không dùng NhanDangDemo) khi laDemo; BoQuetMaDemo cho QR.
- Màn hình sửa danh thiếp: hiển thị vanBanOcr cho người dùng tự chép vào ghiChu (dongConLai chưa dùng).

# cập nhật sau B5

## 1. Tổng quan tiến độ

Khoảng 43% (10/23: A1–A5, B1–B5 xong). Giai đoạn A và B HOÀN TẤT. Tiếp theo: giai đoạn C (PhuThuoc,
chuỗi dt*\*, màn hình, điều hướng), rồi D (test chính thức, ảnh mẫu, README_MO_RONG.md).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN: chạy `flutter pub add google_mlkit_barcode_scanning share_plus`,
tạo assets/danh_thiep/.gitkeep, thêm `- assets/danh_thiep/` vào pubspec, chạy `dart analyze lib tool`,
các tool/thu*_.dart và test/tam_nen_tang_test.dart. Xoá các tệp tạm này khi xong.
Ảnh mẫu assets/danh_thiep/_.jpg CHƯA tạo (4 tên: danh_thiep_1.jpg, danh_thiep_2_qr.jpg, danh_thiep_mo.jpg,
danh_thiep_hong.jpg).
QUY ƯỚC: sau mỗi lượt AI thêm mục "Kiểm tra nhanh".

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ A1–A5, B1–B4) và thêm:

- lib/nen_tang/nen_tang.dart (SỬA): LuuAnhTep({tenThuMuc='hoa_don'}); các phần khác giữ nguyên.
- lib/nen_tang/quet_ma_mlkit.dart: BoQuetMaMlKit implements BoQuetMa; BarcodeScanner(formats: [qrCode]) tạo lười;
  asset → chepAssetRaTepTam; tệp thiếu/rỗng → LoiQuetMa.khongDocDuocAnh; lỗi khác → thatBai; trả rawValue; dong().
- lib/nen_tang/xuat_vcard_chia_se.dart: tenTepAnToan(String) (hàm công khai); BoXuatVCardChiaSe implements BoXuatVCard;
  ghi tệp tạm <tmp>/vcard/<tên> UTF-8 không BOM rồi SharePlus.instance.share(ShareParams(files:[XFile])).

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo (giai đoạn C)

- C1 PhuThuoc: thêm tham số TUỲ CHỌN (khoDanhThiep, luuAnhDanhThiep, boQuetMa, boXuatVCard, và bộ nhận dạng demo
  danh thiếp) mặc định an toàn để 55 test cũ không vỡ; main.dart: chọn BoQuetMaMlKit/BoQuetMaDemo,
  NhanDangDemoDanhThiep khi laDemo, LuuAnhTep(tenThuMuc: 'danh_thiep'), BoXuatVCardChiaSe.
  NGƯỜI DÙNG gửi: lib/phu_thuoc.dart, lib/main.dart, lib/app.dart, lib/cau_hinh/cau_hinh.dart,
  và tệp ocr thiết bị (nen_tang/…ml kit OCR, nếu tên khác nen_tang.dart).
- C2 chuỗi dt\_\* (vi/en): gửi lib/ngon_ngu/du_lieu_chuoi.dart và lib/ngon_ngu/chuoi.dart.
- C3 ManHinhChinh (chọn Hóa đơn / Danh thiếp), C4 màn quét + sửa danh thiếp, C5 lịch sử + chi tiết, C6 cài đặt.
  Gửi: các màn hình trong lib/giao_dien/ (kể cả thanh_phan/), một test widget + helper để bám mẫu.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Gói mới: google_mlkit_barcode_scanning, share_plus (dùng ShareParams, share_plus ≥ 11).
- Giả định chưa kiểm chứng: LoiXuatVCard(String chiTiet) tham số vị trí; BoXuatVCard.chiaSe → Future<void>.
- coOcrThietBi (nen_tang.dart) cũng là điều kiện cho BoQuetMaMlKit; web/máy tính dùng BoQuetMaDemo/BoQuetMaRong.
- Ảnh danh thiếp lưu: <tài liệu app>/danh_thiep/<id>.jpg; DanhThiep.duongDanAnh dạng AnhHoaDon.maHoa().

# cập nhật sau C1

## 1. Tổng quan tiến độ

Khoảng 48% (11/23: A1–A5, B1–B5, C1 xong). Đang ở giai đoạn C; còn C2 (chuỗi dt*\*), C3–C6 (màn hình, điều hướng).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`, `flutter test` (55 test cũ pass),
test/tam_phu_thuoc_test.dart, test/tam_nen_tang_test.dart và các tool/thu*_.dart. Xoá các tệp tạm khi xong.
Ảnh mẫu assets/danh_thiep/_.jpg CHƯA tạo.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ A1–A5, B1–B5) và thêm:

- lib/phu_thuoc.dart (SỬA): thêm lichSuDanhThiep (DieuKhienLichSuDanhThiep), layBoNhanDangDanhThiep(bool dungDemo),
  layBoQuetMa(bool dungDemo); cả 3 TUỲ CHỌN. Mặc định: kho KhoBoNho + LuuAnhGiuNguyen + BoXuatVCardGia,
  NhanDangDemoDanhThiep(), BoQuetMaRong. Constructor không còn const.
- lib/main.dart (SỬA): dựng lichSuDanhThiep (KhoDanhThiep(kho), LuuAnhTep(tenThuMuc:'danh_thiep') hoặc
  LuuAnhGiuNguyen trên web, BoXuatVCardChiaSe hoặc BoXuatVCardGia trên web); layBoDanhThiep và layBoQuetMa
  chọn demo (NhanDangDemoDanhThiep, BoQuetMaDemo) khi dungDemo || !coOcrThietBi, còn lại NhanDangMlKit dùng chung
  với hóa đơn và BoQuetMaMlKit. KHÔNG sửa app.dart, cau_hinh.dart, ocr_mlkit.dart.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- C2 chuỗi dt\__ (vi/en): NGƯỜI DÙNG gửi lib/ngon_ngu/du_lieu_chuoi.dart và lib/ngon_ngu/chuoi.dart (K._).
- C3 ManHinhChinh: hiện lib/giao_dien/man_hinh_chinh.dart đang là màn lịch sử hóa đơn (app.dart: home: ManHinhChinh).
  Kế hoạch: đổi thành khung có thanh điều hướng/tab Hóa đơn | Danh thiếp, mà màn hóa đơn cũ giữ nguyên hành vi.
  Gửi: lib/giao_dien/man_hinh_chinh.dart và các màn hình còn lại trong lib/giao_dien/ (+ thanh_phan/),
  cùng 1 test widget + helper dựng PhuThuoc để bám mẫu.
- C4 màn quét + sửa danh thiếp, C5 lịch sử + chi tiết danh thiếp, C6 cài đặt (nếu cần).

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Màn hình danh thiếp lấy: PhuThuoc.of(ctx).lichSuDanhThiep, .layBoNhanDangDanhThiep(dungDemo), .layBoQuetMa(dungDemo);
  dungDemo = caiDat (cùng cách màn hóa đơn đang tính qua cauHinh.dungDemo).
- Cần gọi lichSuDanhThiep.tai() khi mở màn danh sách danh thiếp.
- Giả định chưa kiểm chứng: KhoBoNho nằm ở lib/du_lieu/kho_khoa_gia_tri.dart, constructor không tham số;
  BoXuatVCardGia() không tham số.
- Test cũ dựng PhuThuoc không có tham số danh thiếp: phải luôn chạy được.

# cập nhật sau C2

## 1. Tổng quan tiến độ

Khoảng 52% (12/23: A1–A5, B1–B5, C1, C2 xong). Giai đoạn C: còn C3 (khung điều hướng), C4 (quét + sửa),
C5 (lịch sử + chi tiết), C6 (cài đặt: xoá toàn bộ danh thiếp).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`, `flutter test` (55 test cũ pass),
tool/thu*chuoi.dart và các tệp tạm trước (tool/thu*\_.dart, test/tam\_\_.dart). Xoá khi xong.
Đã khôi phục lib/ocr/nhan_dang_demo.dart về bản gốc (lớp NhanDangDemo); bản danh thiếp ở
nhan_dang_demo_danh_thiep.dart (NhanDangDemoDanhThiep). Ảnh mẫu assets/danh_thiep/\*.jpg CHƯA tạo.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ A1–A5, B1–B5, C1) và thêm:

- lib/ngon_ngu/du_lieu_chuoi.dart (SỬA): thêm 51 khoá `dt*` vào enum K, chuoiVi, chuoiEn; khoá cũ giữ nguyên.
  chuoi.dart KHÔNG đổi.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- C3 ManHinhChinh → khung có tab Hóa đơn | Danh thiếp (NavigationBar); màn hóa đơn cũ giữ nguyên hành vi.
  NGƯỜI DÙNG gửi: lib/giao_dien/man_hinh_chinh.dart, các màn hình còn lại trong lib/giao_dien/ (+ thanh_phan/),
  1 test widget + helper dựng PhuThuoc.
- C4–C6 như mục trước.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và SỬA/THÊM:

- Khoá chuỗi danh thiếp: tiền tố `dt` + CamelCase (dtLuu... không dùng gạch dưới vì lint).
  Danh sách: dtTabHoaDon, dtTabDanhThiep, dtLichSu, dtQuet, dtSoDanhThiep{n}, dtTrongTieuDe, dtTrongMoTa, dtThuMau,
  dtChonMauTieuDe, dtChonMauMoTa, dtKetQua, dtDangQuet, dtDaDungQr, dtLoiQuetMa, dtKhongCoChuTieuDe,
  dtKhongCoChuMeo, dtGhiChuDemo, dtHoTen, dtChucVu, dtCongTy, dtDienThoai, dtDienThoaiKhac, dtEmail, dtWebsite,
  dtDiaChi, dtGhiChu, dtCanNoiDung, dtVanBanGoc, dtNguon{n}, dtNguonOcr, dtNguonQr, dtNguonThuCong, dtDaLuu,
  dtChiTiet, dtXuatVCard, dtXuatTatCa, dtXuatTrong, dtLoiXuat, dtXoaHoiTieuDe, dtXoaHoiMoTa, dtDaXoa,
  dtKhongTimThay, dtXoaHet, dtXoaHetHoi{n}, dtDaXoaHet.
- Dùng lại khoá hóa đơn cho: luu, loiLuu, huy, xoa, thuLai, chonAnh, chupAnh, chupLai, nhapTay, chonAnhKhac, thongKe,
  bannerDemo, boThayDoi\*, tiepTucSua, bo, taoLuc, luuThayDoi, loiNhanDangTieuDe, loiAnhHong, loiKhongHoTro,
  loiThatBai, loiXoa, dangTaiLichSu, loiTaiLichSu, xemAnh, khongHienAnh.
  # cập nhật sau C3

## 1. Tổng quan tiến độ

Khoảng 57% (13/23: A1–A5, B1–B5, C1–C3 xong). Giai đoạn C: còn C4 (quét + sửa danh thiếp),
C5 (lịch sử + chi tiết danh thiếp, THAY bản tạm), C6 (cài đặt: xoá toàn bộ danh thiếp).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`, `flutter test` (55 test cũ pass),
test/tam_khung_chinh_test.dart và các tệp tạm trước. Xoá các tệp tạm khi xong.
Ảnh mẫu assets/danh_thiep/\*.jpg CHƯA tạo.
LƯU Ý: 3 file man_hinh_cai_dat.dart, man_hinh_chi_tiet.dart, man_hinh_quet.dart trong lượt gửi trước đều RỖNG
(chỉ có dòng tiêu đề); C4–C6 cần người dùng gửi lại nội dung đầy đủ.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ A1–A5, B1–B5, C1, C2) và thêm:

- lib/giao_dien/man_hinh_hoa_don.dart (MỚI, chuyển từ man_hinh_chinh.dart cũ): ManHinhHoaDon = màn lịch sử
  hóa đơn cũ, chỉ đổi tên lớp (ManHinhChinh → ManHinhHoaDon), hành vi y nguyên.
- lib/giao_dien/man_hinh_chinh.dart (VIẾT LẠI): ManHinhChinh = khung Scaffold + NavigationBar 2 tab
  (Key 'tab_hoa_don', 'tab_danh_thiep'; nhãn K.dtTabHoaDon / K.dtTabDanhThiep), IndexedStack(sizing: expand),
  tab Danh thiếp dựng lười (lần mở đầu tiên), PopScope: Back ở tab Danh thiếp về tab Hóa đơn.
  app.dart KHÔNG đổi (vẫn home: ManHinhChinh).
- lib/giao_dien/man_hinh_lich_su_danh_thiep.dart (TẠM): ManHinhLichSuDanhThiep (const, không tham số),
  Scaffold Key('man_hinh_lich_su_danh_thiep') chỉ hiện trạng thái trống. C5 GHI ĐÈ file này.

## 3. File đang làm dở

Không (file TẠM ở trên chờ C5).

## 4. Kế hoạch bước tiếp theo

- C4 màn quét + sửa danh thiếp: file dự kiến lib/giao_dien/man_hinh_quet_danh_thiep.dart (nhận AnhHoaDon + NguonAnh,
  dùng DieuKhienQuetDanhThiep, ô sửa 8 trường + ghi chú, hiện vanBanOcr, nút Lưu/Xuất vCard) và, nếu cần,
  lib/giao_dien/thanh_phan/trinh_sua_danh_thiep.dart (khung sửa dùng chung cho quét và chi tiết).
  NGƯỜI DÙNG gửi: lib/giao_dien/man_hinh_quet.dart (nội dung đầy đủ), lib/dieu_khien/quet_dk.dart.
- C5 lịch sử + chi tiết: ManHinhLichSuDanhThiep thật (ghi đè bản tạm) + lib/giao_dien/man_hinh_chi_tiet_danh_thiep.dart.
  NGƯỜI DÙNG gửi: lib/giao_dien/man_hinh_chi_tiet.dart (nội dung đầy đủ).
- C6 cài đặt: thêm mục "Xoá toàn bộ danh thiếp". NGƯỜI DÙNG gửi: lib/giao_dien/man_hinh_cai_dat.dart (đầy đủ),
  lib/dieu_khien/cai_dat_dk.dart.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Khung chính: ManHinhChinh (khung) ≠ ManHinhHoaDon (tab hóa đơn). Mỗi tab có Scaffold riêng; snackbar do
  Scaffold ngoài cùng hiển thị (cần theo dõi test cũ về snackbar).
- Giả định chưa kiểm chứng: K.dtTabHoaDon, K.dtTabDanhThiep, K.dtLichSu, K.dtTrongTieuDe, K.dtTrongMoTa tồn tại
  (theo HANDOFF C2); NavigationDestination nhận key.
- ManHinhLichSuDanhThiep phải gọi PhuThuoc.of(ctx).lichSuDanhThiep.tai() trong initState (tab dựng lười nên
  lệnh tải chỉ chạy khi người dùng mở tab).

# cập nhật sau C4

## 1. Tổng quan tiến độ

Khoảng 61% (14/23: A1–A5, B1–B5, C1–C4 xong). Còn C5 (lịch sử + chi tiết, THAY bản tạm),
C6 (cài đặt: xoá toàn bộ danh thiếp), rồi D (test, ảnh mẫu, README_MO_RONG.md).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`, `flutter test` (55 test cũ pass).
Đã nhận đủ nội dung quet_dk.dart, man_hinh_quet.dart, man_hinh_chi_tiet.dart, man_hinh_cai_dat.dart.
Ảnh mẫu assets/danh_thiep/\*.jpg CHƯA tạo.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước) và thêm:

- lib/giao_dien/thanh_phan/trinh_sua_danh_thiep.dart: CacOSuaDanhThiep (9 TextEditingController: hoTen, chucVu,
  congTy, dienThoai, dienThoaiKhac, email, website, diaChi, ghiChu; tatCa, dat({...}), dauVet, coNoiDung, dispose());
  TrinhSuaDanhThiep({cacO, anh?, canhBao?, thongTin?, vanBanGoc=''}) — ListView ảnh + banner + 9 ô + ExpansionTile văn bản gốc.
- lib/giao_dien/man_hinh_quet_danh_thiep.dart: ManHinhQuetDanhThiep({anh, nguon}) → pop(true) khi lưu; dùng
  DieuKhienQuetDanhThiep, pt.layBoNhanDangDanhThiep/layBoQuetMa(pt.caiDat.dungDemo); nút Xuất vCard (xuatMot) + Lưu.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- C5 lib/giao_dien/man_hinh_lich_su_danh_thiep.dart (GHI ĐÈ bản tạm: danh sách, nút chụp/chọn ảnh/thử mẫu → mở
  ManHinhQuetDanhThiep, xuất tất cả, tải lichSuDanhThiep.tai() trong initState) và
  lib/giao_dien/man_hinh_chi_tiet_danh_thiep.dart (dùng TrinhSuaDanhThiep, bám man_hinh_chi_tiet.dart).
  Cần gửi: lib/giao_dien/man_hinh_hoa_don.dart (màn lịch sử hóa đơn, để bám mẫu danh sách + nút thêm ảnh),
  lib/giao_dien/thanh_phan/\* (trinh_sua.dart, trang_thai.dart, anh_hoa_don.dart), lib/dieu_khien/lich_su_dk.dart.
- C6 man_hinh_cai_dat.dart: thêm mục "Xoá toàn bộ danh thiếp" (K.dtXoaHet, dtXoaHetHoi, dtDaXoaHet), giữ nguyên mục hóa đơn.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Key widget: 'o_ho_ten','o_chuc_vu','o_cong_ty','o_dien_thoai','o_dien_thoai_khac','o_email','o_website',
  'o_dia_chi','o_ghi_chu','van_ban_goc','nut_xuat_vcard','nut_luu_danh_thiep' ('nut_nhap_tay' dùng lại tên cũ).
- Giả định chưa kiểm chứng: K.dtNguon nhận {'n'}; KetQuaPhanTich.\* là String/String?; xuatMot ném lỗi khi thất bại.
- Màn quét không có nút "Sao chép" (khác hóa đơn); xuất vCard thay cho nó.

# cập nhật sau C5

## 1. Tổng quan tiến độ

Khoảng 65% (15/23: A1–A5, B1–B5, C1–C5 xong). Còn C6 (cài đặt: xoá toàn bộ danh thiếp), rồi D (test chính thức,
ảnh mẫu assets/danh*thiep/\*.jpg, README_MO_RONG.md, dọn tool/thu*\_.dart + test/tam\_\_.dart).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`, `flutter test` (55 test cũ pass).

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước; bản TẠM của lich_su danh thiếp đã bị thay) và thêm/sửa:

- lib/giao_dien/man_hinh_lich_su_danh_thiep.dart (GHI ĐÈ): ManHinhLichSuDanhThiep (const, không tham số), Key
  'man_hinh_lich_su_danh_thiep'; hàm công khai anhCuaDanhThiep(DanhThiep) → AnhHoaDon?; tải lichSuDanhThiep.tai() trong
  initState (postFrame); chọn ảnh/chụp/thử mẫu → ManHinhQuetDanhThiep; chạm → ManHinhChiTietDanhThiep; xuất tất cả.
- lib/giao_dien/man_hinh_chi_tiet_danh_thiep.dart: ManHinhChiTietDanhThiep({id}), const daXoa='da_xoa'; sửa 9 trường
  qua TrinhSuaDanhThiep; Lưu (copyWith + lichSuDanhThiep.luu), Xuất vCard (xuatMot), Xoá, PopScope hỏi bỏ thay đổi.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- C6 lib/giao_dien/man_hinh_cai_dat.dart (đã có nội dung): thêm nhóm/mục "Xoá toàn bộ danh thiếp" (Key 'nut_xoa_het_dt',
  K.dtXoaHet, dtXoaHetHoi{n}, dtDaXoaHet, dtSoDanhThiep{n}); NgheThayDoi thêm pt.lichSuDanhThiep; giữ nguyên mục hóa đơn.
  Không cần gửi thêm file.
- D1 test mới (test/danh_thiep/...): phan_tich, vcard, kho, dieu khien quet, lich su dk, chuan_hoa_nfc, widget luu→xem→xoá.
  NGƯỜI DÙNG gửi: 1 test widget cũ + helper dựng PhuThuoc (test/giao_dien/\*).
- D2 ảnh mẫu assets/danh_thiep/ (4 tệp), pubspec (assets + 2 gói mới), D3 README_MO_RONG.md (có mục "Dùng trợ lý AI"),
  D4 danh sách tệp tạm cần xoá, rồi xoá docs/HANDOFF.md.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Key mới: 'nut*xuat_tat_ca', 'nut_thu_mau_dt', 'nut_thu_mau_dt_appbar', 'nut_chup_dt', 'nut_chon_dt', 'dt*<id>' (thẻ trong
  danh sách), 'nut_xoa_dt', 'nut_luu_thay_doi_dt'. 'nut_xuat_vcard' dùng ở cả màn quét và màn chi tiết.
- Tab Danh thiếp KHÔNG gọi layAnhBiGianDoan (tab Hóa đơn đã xử lý, tránh tranh chấp).
- Giả định chưa kiểm chứng: DanhThiep.copyWith nhận đủ 9 tham số chuỗi; AnhHoaDon.giaiMa(String) trả AnhHoaDon?/ném lỗi;
  NguonAnh.mau, K.dtNguon{n}; các trường chuỗi của DanhThiep không null; file man_hinh_hoa_don.dart (tiêu đề gửi là ma_hinh).

# cập nhật sau C6

## 1. Tổng quan tiến độ

Khoảng 70% (16/23: A1–A5, B1–B5, C1–C6 xong). Giai đoạn A, B, C HOÀN TẤT. Còn giai đoạn D: test chính thức,
ảnh mẫu assets/danh_thiep/\*.jpg, pubspec, README_MO_RONG.md, dọn tệp tạm, xoá docs/HANDOFF.md.
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib`, `flutter test` (55 test cũ pass).

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước) và thêm/sửa:

- lib/giao_dien/man_hinh_cai_dat.dart (SỬA): ManHinhCaiDat chuyển StatefulWidget (constructor const giữ nguyên);
  initState gọi lichSuDanhThiep.tai() nếu trangThai == dangTai; thêm ListTile Key 'nut_xoa_het_dt' (K.dtXoaHet,
  dtSoDanhThiep{n}, dtXoaHetHoi{n}, dtDaXoaHet; lỗi dùng K.loiXoa); NgheThayDoi nghe thêm pt.lichSuDanhThiep.
  Mục hóa đơn ('nut_xoa_het') y nguyên.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo (giai đoạn D)

- D1 test mới: test/danh_thiep/phan_tich_test.dart, vcard_test.dart, kho_test.dart, chuan_hoa_nfc_test.dart,
  quet_danh_thiep_dk_test.dart, lich_su_danh_thiep_dk_test.dart; test/giao_dien/danh_thiep_test.dart (widget:
  tab → thử mẫu → lưu → xem chi tiết → sửa → xoá; cài đặt xoá hết).
  NGƯỜI DÙNG gửi: 1 test widget cũ trong test/giao_dien/ + file helper dựng PhuThuoc (nếu có).
- D2 assets/danh_thiep/ (danh_thiep_1.jpg, danh_thiep_2_qr.jpg, danh_thiep_mo.jpg, danh_thiep_hong.jpg) + pubspec
  (`- assets/danh_thiep/`, google_mlkit_barcode_scanning, share_plus). NGƯỜI DÙNG gửi pubspec.yaml hiện tại.
- D3 README*MO_RONG.md (5 mục theo yêu cầu, gồm "Dùng trợ lý AI"). D4 liệt kê tệp tạm cần xoá
  (tool/thu*\_.dart, test/tam\_\_.dart, docs/HANDOFF.md). D5 đóng gói .zip nếu môi trường cho phép.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Key mới: 'nut_xoa_het_dt'.
- Cài đặt tải danh thiếp một lần vì tab Danh thiếp dựng lười (tránh hiển thị 0 sai).

# cập nhật sau D1a

## 1. Tổng quan tiến độ

Khoảng 74% (17/23: A1–A5, B1–B5, C1–C6, D1a xong). Còn D1b (test phân tích + vCard), D2 (ảnh mẫu + pubspec),
D3 (README_MO_RONG.md), D4 (dọn tệp tạm), D5 (đóng gói).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib test`,
`flutter test test/thuan/danh_thiep_dieu_khien_test.dart test/giao_dien/danh_thiep_luong_test.dart`, rồi `flutter test`.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước) và thêm:

- test/thuan/danh_thiep_dieu_khien_test.dart: BoQuetMaGia (bộ quét mã giả), dkQuet(...), taoThe(ngau, ten); nhóm
  chuanHoaNfcViet, KhoDanhThiep, DieuKhienQuetDanhThiep, DieuKhienLichSuDanhThiep. Import BoGia, anhTep từ dieu_khien_test.dart.
- test/giao_dien/danh_thiep_luong_test.dart: MoiTruong, dungApp (màn hình 800x2400, PhuThuoc đủ tham số danh thiếp),
  moTabDanhThiep, quetMau, choSnackBar, truong; 7 widget test. Import ChonAnhGia từ luong_ung_dung_test.dart.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- D1b test/thuan/phan_tich_danh_thiep_test.dart + vcard_test.dart: NGƯỜI DÙNG gửi kết quả chạy tool/thu_phan_tich.dart,
  tool/thu_vcard.dart (hoặc lib/mo_hinh/phan_tich_danh_thiep.dart + vcard.dart) để assert đúng đầu ra thật.
- D2 assets/danh_thiep/ (4 ảnh) + pubspec: NGƯỜI DÙNG gửi pubspec.yaml hiện tại; ảnh: cần môi trường có Python/PIL +
  qrcode hoặc người dùng tự cung cấp (ảnh hỏng thật sự không phải JPEG; ảnh mờ không có chữ).
- D3 README*MO_RONG.md, D4 liệt kê tệp tạm (tool/thu*\_.dart, test/tam\_\_.dart, docs/HANDOFF.md), D5 .zip.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Test chọn mẫu theo thuộc tính: chuẩn = kieu không phải khongCoChu/loi và !coQr; QR = coQr; mờ = KieuMau.khongCoChu; hỏng = KieuMau.loi.
- Giả định chưa kiểm chứng: TepDaXuat.tenTep/noiDung; BoXuatVCardGia.loi nhận LoiXuatVCard('...'); LoaiLoiQuetMa.thatBai;
  tham số treo: của NhanDangDemoDanhThiep và BoQuetMaDemo; nhapTay → nguon == thucong; OCR lỗi + QR đọc được → coChu.

# cập nhật sau D2

## 1. Tổng quan tiến độ

Khoảng 78% (18/23: A1–A5, B1–B5, C1–C6, D1a, D2 xong). Còn D1b (test phân tích + vCard + test tệp ảnh mẫu),
D3 (README_MO_RONG.md), D4 (dọn tệp tạm), D5 (đóng gói).
NGƯỜI DÙNG CẦN: chép 4 ảnh vào assets/danh_thiep/, thêm `- assets/danh_thiep/` vào pubspec, `flutter pub get`,
sửa lỗi biên dịch test (nếu còn) rồi chạy `flutter test`.

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước) và thêm:

- assets/danh_thiep/danh_thiep_1.jpg (chuẩn), danh_thiep_2_qr.jpg (QR vCard, đã tự kiểm đọc lại), danh_thiep_mo.jpg (nhoè),
  danh_thiep_hong.jpg (ASCII 67 byte, không phải ảnh). Toàn bộ dữ liệu hư cấu.
- tool/tao_anh_danh_thiep.py (TẠM): tạo 4 ảnh trên bằng Pillow + cv2.QRCodeEncoder; có bước tự kiểm tra.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- D1b: test/thuan/phan_tich_danh_thiep_test.dart, vcard_test.dart, và test tệp ảnh mẫu danh thiếp (bám nhóm 'tệp ảnh mẫu có trong
  assets/' của dieu_khien_test.dart: dinhDangAnh == 'jpeg' trừ mẫu hỏng).
  NGƯỜI DÙNG gửi lib/ocr/mau_danh_thiep.dart (để khớp văn bản mẫu với chữ trên ảnh) + kết quả tool/thu_phan_tich.dart, thu_vcard.dart.
- D3 README*MO_RONG.md, D4 dọn tệp tạm (tool/thu*_.dart, tool/tao*anh_danh_thiep.py, test/tam*_.dart, docs/HANDOFF.md), D5 .zip.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Nội dung ảnh mẫu: thẻ 1 = Nguyễn Văn An / Giám đốc kinh doanh / Công ty TNHH Thương mại An Phát / 0912 345 678 /
  024 3333 4444 / an.nguyen@anphat.vn / www.anphat.vn / 25 Nguyễn Trãi, Thanh Xuân, Hà Nội.
  Thẻ 2 (QR) = Trần Thị Minh Anh / Trưởng phòng Marketing / Công ty Cổ phần Giải pháp Số Việt / 0987 654 321 /
  minhanh.tran@giaiphapso.vn / www.giaiphapso.vn / 88 Lê Lợi, Quận 1, TP. Hồ Chí Minh.
- QR trong ảnh 2 chỉ có N, FN, ORG, TITLE, TEL, EMAIL (không URL/địa chỉ) → web/địa chỉ phải đến từ OCR (thử gộp QR+OCR).
- Chưa kiểm chứng: ML Kit đọc 2 ảnh trên máy thật; văn bản demo trong mau_danh_thiep.dart có khớp chữ trên ảnh hay không.

# cập nhật sau D1b

## 1. Tổng quan tiến độ

Khoảng 83% (19/23: A1–A5, B1–B5, C1–C6, D1a, D1b, D2 xong). Còn D3 (README_MO_RONG.md), D4 (dọn tệp tạm), D5 (đóng gói).
AI chưa chạy được dart analyze/test. NGƯỜI DÙNG CẦN chạy `dart analyze lib test` và `flutter test` (cả 55 test cũ).

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước) và thêm/sửa:

- lib/ocr/mau_danh_thiep.dart (SỬA): vanBan/noiDungQr khớp chữ + mã QR thật trên ảnh (An Phát; Minh Anh / Giải pháp Số Việt; QR TEL=+84987654321, chỉ N/FN/ORG/TITLE/TEL/EMAIL).
- test/thuan/phan_tich_danh_thiep_test.dart: BoPhanTichDanhThiep (2 thẻ mẫu, SĐT, email/website, đầu vào xấu, boSung, văn bản demo).
- test/thuan/vcard_test.dart: TaoVCard (khớp từng dòng thu_vcard), escape, gấp dòng, taoNhieu; DocVCard (nhận dạng, đọc ngược, MECARD, QR thật, gộp QR+OCR).
- test/thuan/mau_danh_thiep_test.dart: dsDanhThiepMau, tệp ảnh JPEG thật (mẫu hỏng thì không), pubspec có assets/danh_thiep/.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- Sửa test D1b/D1a nếu `flutter test` báo đỏ (gửi thông báo lỗi).
- D3 README*MO_RONG.md (5 mục, gồm "Dùng trợ lý AI"); D4 liệt kê tệp tạm cần xoá (tool/thu*_.dart, tool/tao*anh_danh_thiep.py, test/tam*_.dart, docs/HANDOFF.md); D5 .zip.
- Để viết README chính xác: gửi pubspec.yaml hiện tại và cây thư mục `lib/`, `test/`.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- Test so sánh hoTen/chucVu/congTy theo chữ thường (chưa biết bộ phân tích có đổi hoa/thường).
- Chưa kiểm chứng: DanhThiep(13 tham số có tên), nhóm số 0912345678 → "0912 345 678", bỏ fax/MST, TaoVCard.tenTep = danh*thiep*<id>.vcf, DocVCard chuẩn hoá +84.
- Nếu test D1a có assert theo tên mẫu cũ (Bích Ngọc/Hoa Sen/Minh Phát) thì phải cập nhật.

# cập nhật sau D1b + D3 (đối chiếu kế hoạch gốc)

## 1. Tổng quan tiến độ

Khoảng 88%. Giai đoạn A, B, C hoàn tất; D1a, D1b, D2, D3 (README) xong. Còn: cấu hình Android, test chuỗi,
rà phủ test giao diện, thử ML Kit trên máy thật, D4 (dọn tệp tạm), D5 (đóng gói).
Kết quả người dùng đã chạy: 35 test (phan_tich + vcard) PASS; 10 test (mau_danh_thiep) PASS; `flutter test` toàn bộ
chỉ đỏ ở test/giao_dien/tam_khung_chinh_test.dart do locale 'en' → người dùng đã ép locale 'vi' và test PASS.
`dart analyze lib test`: 8 info `curly_braces_in_flow_control_structures` (6 ở file mới: kho_danh_thiep.dart:23,53;
man_hinh_lich_su_danh_thiep.dart:105; chuan_hoa_nfc.dart:45; vcard.dart:35; xuat_vcard_chia_se.dart:15;
2 ở file gốc, KHÔNG sửa: man_hinh_hoa_don.dart:98, nen_tang.dart:53).

## 2. Các file đã tạo/sửa hoàn chỉnh

(giữ danh sách trước) và thêm/sửa:

- lib/ocr/mau_danh_thiep.dart (SỬA): vanBan/noiDungQr khớp ảnh thật (thẻ 1 An Phát; thẻ 2 Trần Thị Minh Anh / Giải pháp
  Số Việt; QR TEL=+84987654321, chỉ N/FN/ORG/TITLE/TEL/EMAIL, KHÔNG có URL/địa chỉ).
- test/thuan/phan_tich_danh_thiep_test.dart, vcard_test.dart, mau_danh_thiep_test.dart (đều PASS).
- test/giao_dien/tam_khung_chinh_test.dart: PASS sau khi ép locale 'vi' (tester.platformDispatcher.localesTestValue).
- README_MO_RONG.md (thư mục gốc): 5 mục theo yêu cầu, người dùng đã thêm vào dự án.
- pubspec.yaml: google_mlkit_barcode_scanning ^0.16.1, share_plus ^13.3.1, assets/danh_thiep/.

## 3. File đang làm dở

Không.

## 4. Kế hoạch bước tiếp theo

- (G1) Cấu hình Android: chạy `flutter build apk --debug`; người dùng gửi test/thuan/cau_hinh_android_test.dart,
  android/app/build.gradle(.kts), AndroidManifest.xml → AI chỉnh minSdk/compileSdk nếu cần + cập nhật test.
- (G2) test/thuan/chuoi_danh_thiep_test.dart: mọi khoá dt\* có vi+en không rỗng, placeholder {n} khớp vi/en.
  Cần 40 dòng đầu lib/ngon_ngu/du_lieu_chuoi.dart.
- (G3) Rà test/giao_dien/danh_thiep_luong_test.dart so với 5 kịch bản gốc: mẫu→sửa→lưu→xuất; mờ→nhập tay;
  hỏng→thử lại; QR; tiếng Anh. Bổ sung kịch bản thiếu. Cần danh sách tên 7 test.
- (G4) Người dùng thử tay ML Kit thật: tắt demo, tab Danh thiếp → Thử mẫu, với danh_thiep_1.jpg và danh_thiep_2_qr.jpg.
- (G5, tuỳ chọn) sửa 6 cảnh báo lint ở file mới (gửi 6 file, AI xuất bản đầy đủ).
- Xác nhận lib/giao_dien/man_hinh_danh_thiep.dart: có trong cây thư mục nhưng KHÔNG có trong HANDOFF (xoá nếu là bản nháp;
  nếu đang dùng thì bổ sung vào README_MO_RONG.md mục 2).
- D4 dọn tệp tạm: test/thuan/tam*nen_tang_test.dart, tam_phu_thuoc_test.dart (chạy xanh rồi xoá hoặc đổi tên bỏ "tam*"),
  tool/thu\_\*.dart, tool/tao_anh_danh_thiep.py (nếu còn), cuối cùng docs/HANDOFF.md.
- D5 đóng gói .zip.

## 5. Ghi chú kỹ thuật / Quy ước đặt tên

(giữ mục 5 cũ) và thêm:

- ĐÃ KIỂM CHỨNG bằng test pass: DanhThiep(13 tham số có tên); SĐT "0912 345 678"/"024 3333 4444"/"+84 912 345 678";
  bỏ fax/MST; email chữ thường; website không có https://; TaoVCard.tenTep = danh*thiep*<id>.vcf, mimeType 'text/vcard',
  phanMoRong 'vcf'; DocVCard đọc vCard/MECARD/QR thật; KetQuaPhanTich.boSung (QR ưu tiên).
- flutter_test mặc định locale 'en': test widget có assert chuỗi tiếng Việt phải ép locale 'vi'.
- Đánh số kế hoạch gốc (D1–D6 trong bản kế hoạch ban đầu) khác đánh số trong HANDOFF (D1a/D1b/D2…): theo HANDOFF.
