// Chỉnh thư mục android/ do `flutter create` sinh ra cho đúng nhu cầu của app (chạy MỘT lần, chạy lại vô hại):
//
//   flutter create . --platforms=android --org vn.edu.phenikaa --project-name hoa_don_nhap
//   flutter pub get
//   dart run tool/cau_hinh_android.dart
//
// 1. Tên app trên màn hình điện thoại: "Quét hóa đơn" (thay cho "hoa_don_nhap").
// 2. minSdk tối thiểu 24 (Android 7.0) — image_picker và path_provider yêu cầu.
// 3. Quy tắc R8 cho bản release: ML Kit tham chiếu tới mô hình chữ Trung/Nhật/Hàn/Devanagari mà app không
//    đóng gói (chỉ dùng chữ Latinh, có tiếng Việt); thiếu quy tắc này `flutter build apk` báo "Missing classes".
//
// 4. Xoá test/widget_test.dart mẫu mà `flutter create` thêm vào (nó thử app đếm số `MyApp` không có ở đây).
//
// Không thêm quyền nào: chụp ảnh qua ứng dụng camera của máy và chọn ảnh qua trình chọn ảnh hệ thống.
import 'dart:io';

const tenHienThi = 'Quét hóa đơn';
const minSdkToiThieu = 24;
const danhDau = '// [hoa_don_nhap] R8';

const quyTacR8 = '''
# [hoa_don_nhap] ML Kit chỉ dùng mô hình chữ Latinh; bỏ qua các mô hình chữ khác không được đóng gói.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
''';

String suaManifest(String s) =>
    s.replaceFirst(RegExp(r'android:label="[^"]*"'), 'android:label="$tenHienThi"');

/// build.gradle.kts (mặc định của `flutter create` từ Flutter 3.29).
String suaGradleKts(String s) {
  var kq = s.replaceFirst(RegExp(r'minSdk\s*=\s*flutter\.minSdkVersion'), 'minSdk = maxOf($minSdkToiThieu, flutter.minSdkVersion)');
  kq = kq.replaceFirstMapped(RegExp(r'minSdk\s*=\s*(\d+)'), (m) {
    final n = int.parse(m[1]!);
    return n >= minSdkToiThieu ? m[0]! : 'minSdk = $minSdkToiThieu';
  });
  if (!kq.contains(danhDau)) {
    kq = kq.replaceFirstMapped(RegExp(r'(\n(\s*)release\s*\{)'), (m) {
      final le = '${m[2]}    ';
      return '${m[1]}\n$le$danhDau\n${le}proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")';
    });
  }
  return kq;
}

/// build.gradle (Groovy) — dự án tạo bằng Flutter cũ.
String suaGradleGroovy(String s) {
  var kq = s.replaceFirst(
      RegExp(r'minSdk(?:Version)?\s+flutter\.minSdkVersion'), 'minSdkVersion Math.max($minSdkToiThieu, flutter.minSdkVersion)');
  if (!kq.contains(danhDau)) {
    kq = kq.replaceFirstMapped(RegExp(r'(\n(\s*)release\s*\{)'), (m) {
      final le = '${m[2]}    ';
      return "${m[1]}\n$le$danhDau\n${le}proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'";
    });
  }
  return kq;
}

/// Tệp test mẫu của `flutter create` (app đếm số) — không thuộc dự án này.
bool laTestMau(String s) => s.contains('MyApp') && s.contains('Counter increments smoke test');

String themQuyTacR8(String hienCo) => hienCo.contains('[hoa_don_nhap]') ? hienCo : '${hienCo.trimRight()}\n$quyTacR8'.trimLeft();

void main() {
  final app = Directory('android/app');
  if (!app.existsSync()) {
    stderr.writeln('Chưa có thư mục android/. Chạy trước:\n'
        '  flutter create . --platforms=android --org vn.edu.phenikaa --project-name hoa_don_nhap');
    exitCode = 1;
    return;
  }
  void sua(String duongDan, String Function(String) f) {
    final tep = File(duongDan);
    if (!tep.existsSync()) return;
    final cu = tep.readAsStringSync();
    final moi = f(cu);
    if (moi != cu) tep.writeAsStringSync(moi);
    stdout.writeln('${moi == cu ? '·' : '✓'} $duongDan');
  }

  sua('android/app/src/main/AndroidManifest.xml', suaManifest);
  sua('android/app/build.gradle.kts', suaGradleKts);
  sua('android/app/build.gradle', suaGradleGroovy);
  final r8 = File('android/app/proguard-rules.pro');
  final cu = r8.existsSync() ? r8.readAsStringSync() : '';
  final moi = themQuyTacR8(cu);
  if (moi != cu) r8.writeAsStringSync(moi);
  stdout.writeln('${moi == cu ? '·' : '✓'} android/app/proguard-rules.pro');
  final testMau = File('test/widget_test.dart');
  if (testMau.existsSync() && laTestMau(testMau.readAsStringSync())) {
    testMau.deleteSync();
    stdout.writeln('✓ đã xoá test/widget_test.dart mẫu của flutter create');
  }
  stdout.writeln('Xong. Chạy: flutter run');
}
