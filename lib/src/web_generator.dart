import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class WebGenerator {
  final String projectDir;
  final String iconPath;

  WebGenerator({required this.projectDir, required this.iconPath});

  Future<void> generate() async {
    final webDir = p.join(projectDir, 'web');
    if (!Directory(webDir).existsSync()) {
      throw Exception('web/ directory not found. Make sure you are running this inside a Flutter project.');
    }

    final sourceBytes = File(iconPath).readAsBytesSync();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      throw Exception('Could not read icon image: $iconPath');
    }

    await _save(sourceImage, p.join(webDir, 'favicon.png'), 32);

    final iconsDir = p.join(webDir, 'icons');
    Directory(iconsDir).createSync(recursive: true);

    await _save(sourceImage, p.join(iconsDir, 'Icon-192.png'), 192);
    await _save(sourceImage, p.join(iconsDir, 'Icon-512.png'), 512);
    await _save(sourceImage, p.join(iconsDir, 'Icon-maskable-192.png'), 192);
    await _save(sourceImage, p.join(iconsDir, 'Icon-maskable-512.png'), 512);

    _updateManifest(webDir);

    print('  Web icons done: web/');
  }

  Future<void> _save(img.Image source, String outputPath, int size) async {
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

  void _updateManifest(String webDir) {
    final manifestFile = File(p.join(webDir, 'manifest.json'));
    if (!manifestFile.existsSync()) return;

    try {
      final content = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      content['icons'] = [
        {'src': 'icons/Icon-192.png', 'sizes': '192x192', 'type': 'image/png'},
        {'src': 'icons/Icon-512.png', 'sizes': '512x512', 'type': 'image/png'},
        {
          'src': 'icons/Icon-maskable-192.png',
          'sizes': '192x192',
          'type': 'image/png',
          'purpose': 'maskable',
        },
        {
          'src': 'icons/Icon-maskable-512.png',
          'sizes': '512x512',
          'type': 'image/png',
          'purpose': 'maskable',
        },
      ];
      manifestFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(content),
      );
      print('  manifest.json updated');
    } catch (_) {
      // skip if manifest.json cannot be parsed
    }
  }
}
