import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../mo_hinh/chuan_hoa_nfc.dart';
import '../mo_hinh/vcard.dart';
import '../ngon_ngu/chuoi.dart';

/// Màn hình quét QR từ camera để điền thông tin danh thiếp.
/// Trả về kết quả phân tích từ QR (vCard/MECARD) hoặc null nếu không phải vCard.
class ManHinhQuetQr extends StatefulWidget {
  const ManHinhQuetQr({super.key});

  @override
  State<ManHinhQuetQr> createState() => _ManHinhQuetQrState();
}

class _ManHinhQuetQrState extends State<ManHinhQuetQr> {
  final MobileScannerController _controller = MobileScannerController();
  bool _daQuet = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _xuLyMa(BarcodeCapture capture) {
    if (_daQuet) return;

    final ma = capture.barcodes.first;
    final noiDung = ma.rawValue;

    if (noiDung == null || noiDung.isEmpty) return;

    // Chuẩn hóa NFC và kiểm tra có phải vCard/MECARD không
    final chuan = chuanHoaNfcViet(noiDung);
    if (!DocVCard.nhanDang(chuan)) {
      // Không phải vCard - có thể thông báo cho người dùng
      return;
    }

    _daQuet = true;
    _controller.stop();

    // Phân tích vCard
    final ketQua = DocVCard.doc(chuan);

    if (mounted) {
      Navigator.of(context).pop(ketQua);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(c.t(K.dtQuetQr)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _xuLyMa,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(c.t(K.loiKhongCoCamera)),
                  ],
                ),
              );
            },
          ),
          _OverlayQr(),
        ],
      ),
    );
  }
}

/// Overlay hướng dẫn quét QR
class _OverlayQr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Chuoi.of(context);
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(painter: _QrCornerPainter()),
            ),
            const SizedBox(height: 24),
            Text(
              c.t(K.dtHuongDanQr),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vẽ 4 góc khung quét QR
class _QrCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final cornerSize = 30.0;
    final path = Path();

    // Góc trên trái
    path.moveTo(0, cornerSize);
    path.lineTo(0, 0);
    path.lineTo(cornerSize, 0);

    // Góc trên phải
    path.moveTo(size.width - cornerSize, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerSize);

    // Góc dưới trái
    path.moveTo(0, size.height - cornerSize);
    path.lineTo(0, size.height);
    path.lineTo(cornerSize, size.height);

    // Góc dưới phải
    path.moveTo(size.width - cornerSize, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - cornerSize);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
