import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class AndroidIconSize {
  final String dirName;
  final int size;
  const AndroidIconSize(this.dirName, this.size);
}

const _standardSizes = [
  AndroidIconSize('mipmap-mdpi', 48),
  AndroidIconSize('mipmap-hdpi', 72),
  AndroidIconSize('mipmap-xhdpi', 96),
  AndroidIconSize('mipmap-xxhdpi', 144),
  AndroidIconSize('mipmap-xxxhdpi', 192),
];

// Adaptive icon uchun foreground o'lchami (faqat markaziy qism ko'rinadi)
const _adaptiveSizes = [
  AndroidIconSize('mipmap-mdpi', 108),
  AndroidIconSize('mipmap-hdpi', 162),
  AndroidIconSize('mipmap-xhdpi', 216),
  AndroidIconSize('mipmap-xxhdpi', 324),
  AndroidIconSize('mipmap-xxxhdpi', 432),
];

class AndroidGenerator {
  final String projectDir;
  final String iconPath;
  final String iconName;
  final bool adaptiveIcon;
  final String? adaptiveForegroundPath;
  final String? adaptiveBackground;

  AndroidGenerator({
    required this.projectDir,
    required this.iconPath,
    required this.iconName,
    required this.adaptiveIcon,
    this.adaptiveForegroundPath,
    this.adaptiveBackground,
  });

  Future<void> generate() async {
    final resDir = p.join(projectDir, 'android', 'app', 'src', 'main', 'res');
    final resDirectory = Directory(resDir);

    if (!resDirectory.existsSync()) {
      throw Exception(
        'Android res papkasi topilmadi: $resDir\n'
        'Flutter loyihasi ichida ishga tushirilganini tekshiring.',
      );
    }

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Ikon rasm faylini o\'qib bo\'lmadi: $iconPath');
    }

    // Oddiy ikonlar
    for (final size in _standardSizes) {
      await _generateIcon(
        sourceImage: sourceImage,
        outputDir: p.join(resDir, size.dirName),
        fileName: '$iconName.png',
        size: size.size,
      );
    }

    if (adaptiveIcon) {
      await _generateAdaptiveIcons(resDir, sourceImage);
    }

    print('  Android ikonlari tayyor: $resDir');
  }

  Future<void> _generateAdaptiveIcons(
    String resDir,
    img.Image defaultImage,
  ) async {
    // Foreground image
    img.Image? foregroundImage;
    if (adaptiveForegroundPath != null) {
      final fgBytes = File(adaptiveForegroundPath!).readAsBytesSync();
      foregroundImage = img.decodeImage(fgBytes);
    }
    foregroundImage ??= defaultImage;

    for (final size in _adaptiveSizes) {
      await _generateIcon(
        sourceImage: foregroundImage,
        outputDir: p.join(resDir, size.dirName),
        fileName: '${iconName}_foreground.png',
        size: size.size,
      );
    }

    // Adaptive icon XML (mipmap-anydpi-v26)
    final anydpiDir = Directory(p.join(resDir, 'mipmap-anydpi-v26'));
    anydpiDir.createSync(recursive: true);

    final bgColor = adaptiveBackground ?? '#FFFFFF';
    final isColor = bgColor.startsWith('#');

    // Background resource
    if (isColor) {
      // color resource yozish
      final valuesDir = Directory(p.join(resDir, 'values'));
      valuesDir.createSync(recursive: true);
      final colorFile = File(p.join(valuesDir.path, 'ic_launcher_background.xml'));
      colorFile.writeAsStringSync('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="${iconName}_background">$bgColor</color>
</resources>
''');
    } else {
      // background rasm sifatida
      final bgBytes = File(p.join(projectDir, bgColor)).readAsBytesSync();
      final bgImage = img.decodeImage(bgBytes);
      if (bgImage != null) {
        for (final size in _adaptiveSizes) {
          await _generateIcon(
            sourceImage: bgImage,
            outputDir: p.join(resDir, size.dirName),
            fileName: '${iconName}_background.png',
            size: size.size,
          );
        }
      }
    }

    // ic_launcher.xml
    final bgResource = isColor
        ? '@color/${iconName}_background'
        : '@mipmap/${iconName}_background';

    File(p.join(anydpiDir.path, '$iconName.xml')).writeAsStringSync(
      '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="$bgResource"/>
    <foreground android:drawable="@mipmap/${iconName}_foreground"/>
</adaptive-icon>
''',
    );

    // ic_launcher_round.xml
    File(p.join(anydpiDir.path, '${iconName}_round.xml')).writeAsStringSync(
      '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="$bgResource"/>
    <foreground android:drawable="@mipmap/${iconName}_foreground"/>
</adaptive-icon>
''',
    );
  }

  Future<void> _generateIcon({
    required img.Image sourceImage,
    required String outputDir,
    required String fileName,
    required int size,
  }) async {
    final dir = Directory(outputDir);
    dir.createSync(recursive: true);

    final resized = img.copyResize(
      sourceImage,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );

    final outputPath = p.join(outputDir, fileName);
    final pngBytes = img.encodePng(resized);
    File(outputPath).writeAsBytesSync(Uint8List.fromList(pngBytes));
    print('  ${size}x$size -> ${p.relative(outputPath, from: projectDir)}');
  }
}
