import 'package:flutter_test/flutter_test.dart';

import '../../tool/cau_hinh_android.dart';

// Mẫu rút gọn từ tệp do `flutter create` sinh ra.
const kts = '''
android {
    namespace = "vn.edu.phenikaa.hoa_don_nhap"
    defaultConfig {
        applicationId = "vn.edu.phenikaa.hoa_don_nhap"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
''';

const groovy = '''
android {
    defaultConfig {
        minSdkVersion flutter.minSdkVersion
    }
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
''';

void main() {
  test('manifest: đổi tên hiển thị', () {
    expect(
      suaManifest('<application android:label="hoa_don_nhap" android:name="\${applicationName}">'),
      '<application android:label="Quét hóa đơn" android:name="\${applicationName}">',
    );
  });

  test('build.gradle.kts: minSdk ≥ 24 và thêm quy tắc R8 đúng khối release; chạy lại không đổi', () {
    final a = suaGradleKts(kts);
    expect(a, contains('minSdk = maxOf(24, flutter.minSdkVersion)'));
    expect(a, contains('release {\n            $danhDau\n            proguardFiles('));
    expect(suaGradleKts(a), a);
    expect(suaGradleKts(kts.replaceFirst('flutter.minSdkVersion', '21')), contains('minSdk = 24'));
    expect(suaGradleKts(kts.replaceFirst('flutter.minSdkVersion', '26')), contains('minSdk = 26'));
  });

  test('build.gradle (Groovy) cũ cũng được sửa', () {
    final a = suaGradleGroovy(groovy);
    expect(a, contains('minSdkVersion Math.max(24, flutter.minSdkVersion)'));
    expect(a, contains("proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'"));
    expect(suaGradleGroovy(a), a);
  });

  test('proguard-rules.pro: thêm một lần, giữ quy tắc cũ', () {
    final a = themQuyTacR8('-keep class foo.** { *; }\n');
    expect(a, startsWith('-keep class foo.**'));
    expect(a, contains('-dontwarn com.google.mlkit.vision.text.chinese.**'));
    expect(themQuyTacR8(a), a);
    expect(themQuyTacR8(''), startsWith('# [hoa_don_nhap]'));
  });

  test('nhận ra test mẫu của flutter create, không đụng test của dự án', () {
    expect(laTestMau("testWidgets('Counter increments smoke test', (tester) async { await tester.pumpWidget(const MyApp());"), isTrue);
    expect(laTestMau("testWidgets('giao diện tiếng Anh', (tester) async {});"), isFalse);
  });
}
