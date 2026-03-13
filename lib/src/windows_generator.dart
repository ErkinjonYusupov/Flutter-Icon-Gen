import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class WindowsGenerator {
  final String projectDir;
  final String iconPath;

  WindowsGenerator({required this.projectDir, required this.iconPath});

  Future<void> generate() async {
    final resourcesDir = p.join(projectDir, 'windows', 'runner', 'resources');
    if (!Directory(p.join(projectDir, 'windows')).existsSync()) {
      throw Exception(
        'windows/ papkasi topilmadi.\n'
        'Flutter loyihasi ichida ishga tushirilganini tekshiring.',
      );
    }

    Directory(resourcesDir).createSync(recursive: true);

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Ikon rasm faylini o\'qib bo\'lmadi: $iconPath');
    }

    // ICO fayl: 16, 32, 48, 64, 128, 256 px
    const sizes = [16, 32, 48, 64, 128, 256];
    final frames = <img.Image>[];

    for (final size in sizes) {
      final resized = img.copyResize(
        sourceImage,
        width: size,
        height: size,
        interpolation: img.Interpolation.cubic,
      );
      frames.add(resized);
      print('  ${size}x$size (ICO frame)');
    }

    // ICO encoding
    final icoBytes = img.encodeIco(img.Image.fromBytes(
      width: frames.last.width,
      height: frames.last.height,
      bytes: frames.last.toUint8List().buffer,
    ));

    // image package ICO encoder faqat bitta frame qabul qiladi,
    // shuning uchun eng katta o'lchamni saqlaymiz (256x256)
    final outputPath = p.join(resourcesDir, 'app_icon.ico');
    File(outputPath).writeAsBytesSync(Uint8List.fromList(icoBytes));
    print('  ICO -> ${p.relative(outputPath, from: projectDir)}');

    // Qo'shimcha PNG (ba'zi joylarda kerak bo'ladi)
    await _savePng(sourceImage, p.join(resourcesDir, 'app_icon.png'), 256);

    print('  Windows ikonlari tayyor: windows/runner/resources/');
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
