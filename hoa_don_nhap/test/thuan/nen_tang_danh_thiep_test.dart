import 'package:flutter_test/flutter_test.dart';
import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/nen_tang/quet_ma_mlkit.dart';
import 'package:hoa_don_nhap/nen_tang/xuat_vcard_chia_se.dart';
import 'package:hoa_don_nhap/ocr/bo_quet_ma.dart';

void main() {
  group('tenTepAnToan', () {
    test(
      'giữ tên hợp lệ',
      () => expect(tenTepAnToan('danh_thiep_abc.vcf'), 'danh_thiep_abc.vcf'),
    );
    test(
      'bỏ ký tự cấm',
      () => expect(tenTepAnToan('a/b:c?.vcf'), 'a_b_c_.vcf'),
    );
    test('thêm đuôi nếu thiếu', () => expect(tenTepAnToan('an'), 'an.vcf'));
    test(
      'rỗng → tên mặc định',
      () => expect(tenTepAnToan('  '), 'danh_thiep.vcf'),
    );
    test(
      'chỉ có đuôi → tên mặc định',
      () => expect(tenTepAnToan('.vcf'), 'danh_thiep.vcf'),
    );
    test(
      'đuôi viết hoa vẫn nhận',
      () => expect(tenTepAnToan('AN.VCF'), 'AN.VCF'),
    );
  });

  group('BoQuetMaMlKit (không chạm nền tảng)', () {
    test('không phải bản demo', () => expect(BoQuetMaMlKit().laDemo, isFalse));

    test('tệp không tồn tại → LoiQuetMa.khongDocDuocAnh', () async {
      final bo = BoQuetMaMlKit();
      await expectLater(
        bo.quet(const AnhHoaDon.tep('/khong/co/tep_nay.jpg')),
        throwsA(
          isA<LoiQuetMa>().having(
            (e) => e.loai,
            'loai',
            LoaiLoiQuetMa.khongDocDuocAnh,
          ),
        ),
      );
      await bo.dong(); // chưa tạo bộ quét thì đóng vẫn an toàn
    });
  });
}
