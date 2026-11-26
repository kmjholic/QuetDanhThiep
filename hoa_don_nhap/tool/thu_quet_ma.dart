import 'package:hoa_don_nhap/mo_hinh/hoa_don.dart';
import 'package:hoa_don_nhap/mo_hinh/vcard.dart';
import 'package:hoa_don_nhap/ocr/bo_quet_ma.dart';
import 'package:hoa_don_nhap/ocr/mau_danh_thiep.dart';

var _loi = 0;
void kiem(String ten, bool dung) {
  if (!dung) _loi++;
  print('${dung ? 'OK  ' : 'LỖI'} $ten');
}

Future<void> main() async {
  final demo = BoQuetMaDemo(treo: Duration.zero);

  // B2: bảng mẫu
  kiem('4 mẫu', dsDanhThiepMau.length == 4);
  kiem(
    'mã mẫu không trùng',
    dsDanhThiepMau.map((m) => m.ma).toSet().length == 4,
  );
  kiem(
    'chỉ mẫu co_qr có QR',
    dsDanhThiepMau.where((m) => m.coQr).map((m) => m.ma).toList().join() ==
        'co_qr',
  );
  kiem(
    'tra theo asset',
    timDanhThiepMauTheoAsset('assets/danh_thiep/danh_thiep_1.jpg')?.ma ==
        'chuan',
  );
  kiem('asset lạ → null', timDanhThiepMauTheoAsset('x.jpg') == null);

  // B1: BoQuetMaDemo / BoQuetMaRong
  final qr = await demo.quet(
    const AnhHoaDon.asset('assets/danh_thiep/danh_thiep_2_qr.jpg'),
  );
  kiem('mẫu co_qr → 1 mã', qr.length == 1);
  kiem('mã là vCard', DocVCard.nhanDang(qr.first));
  final kq = DocVCard.doc(qr.first);
  print(
    '     đọc được: ${kq.hoTen} | ${kq.email} | ${kq.dienThoai} | ${kq.website} | ${kq.diaChi}',
  );
  kiem('email từ QR', kq.email == 'ngoc.tran@hoasen.example');
  kiem(
    'mẫu chuẩn → []',
    (await demo.quet(
      const AnhHoaDon.asset('assets/danh_thiep/danh_thiep_1.jpg'),
    )).isEmpty,
  );
  kiem(
    'mẫu mờ → []',
    (await demo.quet(
      const AnhHoaDon.asset('assets/danh_thiep/danh_thiep_mo.jpg'),
    )).isEmpty,
  );
  kiem(
    'ảnh tự chọn → []',
    (await demo.quet(const AnhHoaDon.tep('/tmp/a.jpg'))).isEmpty,
  );
  try {
    await demo.quet(
      const AnhHoaDon.asset('assets/danh_thiep/danh_thiep_hong.jpg'),
    );
    kiem('mẫu hỏng ném LoiQuetMa', false);
  } on LoiQuetMa catch (e) {
    kiem('mẫu hỏng ném LoiQuetMa', e.loai == LoaiLoiQuetMa.khongDocDuocAnh);
  }
  kiem(
    'BoQuetMaRong → []',
    (await const BoQuetMaRong().quet(const AnhHoaDon.tep('x'))).isEmpty,
  );

  print(_loi == 0 ? '\nTẤT CẢ OK' : '\n$_loi mục LỖI');
}
