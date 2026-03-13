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
      throw Exception('Ikon fayli topilmadi: ${config.imagePath}');
    }

    print('Ikon fayli: ${config.imagePath}');

    if (config.generateAndroid) {
      print('\nAndroid ikonlari yaratilmoqda...');
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
      print('\niOS ikonlari yaratilmoqda...');
      await IosGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateWeb) {
      print('\nWeb ikonlari yaratilmoqda...');
      await WebGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateWindows) {
      print('\nWindows ikonlari yaratilmoqda...');
      await WindowsGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateMacos) {
      print('\nmacOS ikonlari yaratilmoqda...');
      await MacosGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }

    if (config.generateLinux) {
      print('\nLinux ikonlari yaratilmoqda...');
      await LinuxGenerator(
        projectDir: projectDir,
        iconPath: iconFile.path,
      ).generate();
    }
  }
}
