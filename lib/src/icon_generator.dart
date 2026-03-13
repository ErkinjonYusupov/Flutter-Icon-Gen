import 'dart:io';
import 'package:path/path.dart' as p;
import 'config.dart';
import 'android_generator.dart';
import 'ios_generator.dart';
import 'web_generator.dart';
import 'windows_generator.dart';
import 'macos_generator.dart';
import 'linux_generator.dart';

class IconGenerator {
  final String configPath;

  IconGenerator({required this.configPath});

  Future<void> generate() async {
    final config = IconConfig.fromFile(configPath);
    final projectDir = p.dirname(p.absolute(configPath));

    final iconFile = File(p.join(projectDir, config.imagePath));
    if (!iconFile.existsSync()) {
      throw Exception('Icon file not found: ${config.imagePath}');
    }

    print('Icon: ${config.imagePath}');

    if (config.generateAndroid) {
      print('\nGenerating Android icons...');
      await AndroidGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
        iconName: config.androidIconName ?? 'ic_launcher',
        adaptiveIcon: config.adaptiveIcon ?? false,
        adaptiveForegroundPath: config.adaptiveForeground != null
            ? p.join(projectDir, config.adaptiveForeground!)
            : null,
        adaptiveBackground: config.adaptiveBackground,
      ).generate();
    }

    if (config.generateIos) {
      print('\nGenerating iOS icons...');
      await IosGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateWeb) {
      print('\nGenerating Web icons...');
      await WebGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateWindows) {
      print('\nGenerating Windows icons...');
      await WindowsGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateMacos) {
      print('\nGenerating macOS icons...');
      await MacosGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateLinux) {
      print('\nGenerating Linux icons...');
      await LinuxGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }
  }
}
