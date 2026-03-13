import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class LinuxGenerator {
  final String projectDir;
  final String iconPath;

  LinuxGenerator({required this.projectDir, required this.iconPath});

  Future<void> generate() async {
    if (!Directory(p.join(projectDir, 'linux')).existsSync()) {
      throw Exception(
        'linux/ papkasi topilmadi.\n'
        'Flutter loyihasi ichida ishga tushirilganini tekshiring.',
      );
    }

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Ikon rasm faylini o\'qib bo\'lmadi: $iconPath');
    }

    // Linux freedesktop.org standartiga ko'ra hicolor theme
    // data/icons/hicolor/<size>x<size>/apps/
    const sizes = [16, 32, 48, 64, 128, 256, 512];

    for (final size in sizes) {
      final sizeDir = p.join(
        projectDir,
        'linux',
        'data',
        'icons',
        'hicolor',
        '${size}x$size',
        'apps',
      );
      Directory(sizeDir).createSync(recursive: true);

      final resized = img.copyResize(
        sourceImage,
        width: size,
        height: size,
        interpolation: img.Interpolation.cubic,
      );

      final outputPath = p.join(sizeDir, 'app_icon.png');
      final pngBytes = img.encodePng(resized);
      File(outputPath).writeAsBytesSync(Uint8List.fromList(pngBytes));
      print('  ${size}x$size -> ${p.relative(outputPath, from: projectDir)}');
    }

    // my_application.cc da ishlatiladigan asosiy ikon
    final runnerDir = p.join(projectDir, 'linux', 'runner');
    if (Directory(runnerDir).existsSync()) {
      await _savePng(sourceImage, p.join(runnerDir, 'my_application_icon.png'), 512);
    }

    print('  Linux ikonlari tayyor: linux/data/icons/');
  }

  Future<void> _savePng(img.Image source, String outputPath, int size) async {
    final resized = img.copyResize(
      source,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    final pngBytes = img.encodePng(resized);
    File(outputPath).writeAsBytesSync(Uint8List.fromList(pngBytes));
    print('  ${size}x$size -> ${p.relative(outputPath, from: projectDir)}');
  }
}
