import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class MacosIconSize {
  final int size;
  final int scale;

  const MacosIconSize(this.size, this.scale);

  String get filename => 'app_icon_${size}x${size}${scale == 2 ? "@2x" : ""}.png';
  int get pixelSize => size * scale;
}

const _macosSizes = [
  MacosIconSize(16, 1),
  MacosIconSize(16, 2),
  MacosIconSize(32, 1),
  MacosIconSize(32, 2),
  MacosIconSize(64, 1),
  MacosIconSize(64, 2),
  MacosIconSize(128, 1),
  MacosIconSize(128, 2),
  MacosIconSize(256, 1),
  MacosIconSize(256, 2),
  MacosIconSize(512, 1),
  MacosIconSize(512, 2),
];

class MacosGenerator {
  final String projectDir;
  final String iconPath;

  MacosGenerator({required this.projectDir, required this.iconPath});

  Future<void> generate() async {
    final iconsetDir = p.join(
      projectDir,
      'macos',
      'Runner',
      'Assets.xcassets',
      'AppIcon.appiconset',
    );

    if (!Directory(p.join(projectDir, 'macos')).existsSync()) {
      throw Exception(
        'macos/ papkasi topilmadi.\n'
        'Flutter loyihasi ichida ishga tushirilganini tekshiring.',
      );
    }

    Directory(iconsetDir).createSync(recursive: true);

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Ikon rasm faylini o\'qib bo\'lmadi: $iconPath');
    }

    final contentsImages = <Map<String, String>>[];

    for (final size in _macosSizes) {
      final px = size.pixelSize;
      final resized = img.copyResize(
        sourceImage,
        width: px,
        height: px,
        interpolation: img.Interpolation.cubic,
      );

      final outputPath = p.join(iconsetDir, size.filename);
      final pngBytes = img.encodePng(resized);
      File(outputPath).writeAsBytesSync(Uint8List.fromList(pngBytes));
      print('  ${px}x$px -> macos/Runner/Assets.xcassets/AppIcon.appiconset/${size.filename}');

      contentsImages.add({
        'idiom': 'mac',
        'filename': size.filename,
        'scale': '${size.scale}x',
        'size': '${size.size}x${size.size}',
      });
    }

    // Contents.json
    final contents = {
      'images': contentsImages,
      'info': {'version': 1, 'author': 'flutter_icon_gen'},
    };

    File(p.join(iconsetDir, 'Contents.json')).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(contents),
    );

    print('  macOS ikonlari tayyor: macos/Runner/Assets.xcassets/AppIcon.appiconset/');
  }
}
