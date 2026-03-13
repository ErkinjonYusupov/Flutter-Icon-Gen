import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class IosIconSize {
  final String idiom;
  final double size;
  final double scale;

  const IosIconSize({required this.idiom, required this.size, required this.scale});

  String get filename {
    final px = (size * scale).toInt();
    return 'Icon-${px}x${px}.png';
  }

  int get pixelSize => (size * scale).toInt();
}

const _iosSizes = [
  // iPhone notification
  IosIconSize(idiom: 'iphone', size: 20, scale: 2),
  IosIconSize(idiom: 'iphone', size: 20, scale: 3),
  // iPhone settings
  IosIconSize(idiom: 'iphone', size: 29, scale: 2),
  IosIconSize(idiom: 'iphone', size: 29, scale: 3),
  // iPhone spotlight
  IosIconSize(idiom: 'iphone', size: 40, scale: 2),
  IosIconSize(idiom: 'iphone', size: 40, scale: 3),
  // iPhone app
  IosIconSize(idiom: 'iphone', size: 60, scale: 2),
  IosIconSize(idiom: 'iphone', size: 60, scale: 3),
  // iPad notification
  IosIconSize(idiom: 'ipad', size: 20, scale: 1),
  IosIconSize(idiom: 'ipad', size: 20, scale: 2),
  // iPad settings
  IosIconSize(idiom: 'ipad', size: 29, scale: 1),
  IosIconSize(idiom: 'ipad', size: 29, scale: 2),
  // iPad spotlight
  IosIconSize(idiom: 'ipad', size: 40, scale: 1),
  IosIconSize(idiom: 'ipad', size: 40, scale: 2),
  // iPad app
  IosIconSize(idiom: 'ipad', size: 76, scale: 1),
  IosIconSize(idiom: 'ipad', size: 76, scale: 2),
  // iPad Pro
  IosIconSize(idiom: 'ipad', size: 83.5, scale: 2),
  // App Store
  IosIconSize(idiom: 'ios-marketing', size: 1024, scale: 1),
];

class IosGenerator {
  final String projectDir;
  final String iconPath;

  IosGenerator({required this.projectDir, required this.iconPath});

  Future<void> generate() async {
    final iconsetDir = p.join(
      projectDir,
      'ios',
      'Runner',
      'Assets.xcassets',
      'AppIcon.appiconset',
    );

    if (!Directory(p.join(projectDir, 'ios')).existsSync()) {
      throw Exception('ios/ directory not found. Make sure you are running this inside a Flutter project.');
    }

    Directory(iconsetDir).createSync(recursive: true);

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Could not read icon image: $iconPath');
    }

    final contentsImages = <Map<String, String>>[];

    for (final size in _iosSizes) {
      final px = size.pixelSize;
      final filename = size.filename;

      final resized = img.copyResize(
        sourceImage,
        width: px,
        height: px,
        interpolation: img.Interpolation.cubic,
      );

      final outputPath = p.join(iconsetDir, filename);
      final pngBytes = img.encodePng(resized);
      File(outputPath).writeAsBytesSync(Uint8List.fromList(pngBytes));
      print('  ${px}x$px -> ios/Runner/Assets.xcassets/AppIcon.appiconset/$filename');

      final sizeStr = size.size == size.size.toInt()
          ? '${size.size.toInt()}'
          : '${size.size}';

      contentsImages.add({
        'idiom': size.idiom,
        'filename': filename,
        'scale': '${size.scale.toInt()}x',
        'size': '${sizeStr}x$sizeStr',
      });
    }

    final contents = {
      'images': contentsImages,
      'info': {'version': 1, 'author': 'flutter_icon_gen'},
    };

    final contentsPath = p.join(iconsetDir, 'Contents.json');
    File(contentsPath).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(contents),
    );

    print('  iOS icons done: ios/Runner/Assets.xcassets/AppIcon.appiconset/');
  }
}
