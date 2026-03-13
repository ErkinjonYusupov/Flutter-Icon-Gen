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
      throw Exception('windows/ directory not found. Make sure you are running this inside a Flutter project.');
    }

    Directory(resourcesDir).createSync(recursive: true);

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Could not read icon image: $iconPath');
    }

    // ICO file: 16, 32, 48, 64, 128, 256 px
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

    // ICO encoder only accepts a single frame — saving the largest (256x256)
    final icoBytes = img.encodeIco(img.Image.fromBytes(
      width: frames.last.width,
      height: frames.last.height,
      bytes: frames.last.toUint8List().buffer,
    ));

    final outputPath = p.join(resourcesDir, 'app_icon.ico');
    File(outputPath).writeAsBytesSync(Uint8List.fromList(icoBytes));
    print('  ICO -> ${p.relative(outputPath, from: projectDir)}');

    await _savePng(sourceImage, p.join(resourcesDir, 'app_icon.png'), 256);

    print('  Windows icons done: windows/runner/resources/');
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
