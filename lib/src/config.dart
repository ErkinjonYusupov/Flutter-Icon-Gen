import 'dart:io';
import 'package:yaml/yaml.dart';

class IconConfig {
  final String imagePath;
  final bool generateAndroid;
  final bool generateIos;
  final bool generateWeb;
  final bool generateWindows;
  final bool generateMacos;
  final bool generateLinux;
  final String? androidIconName;
  final bool? adaptiveIcon;
  final String? adaptiveForeground;
  final String? adaptiveBackground;

  const IconConfig({
    required this.imagePath,
    required this.generateAndroid,
    required this.generateIos,
    required this.generateWeb,
    required this.generateWindows,
    required this.generateMacos,
    required this.generateLinux,
    this.androidIconName,
    this.adaptiveIcon,
    this.adaptiveForeground,
    this.adaptiveBackground,
  });

  factory IconConfig.fromFile(String configPath) {
    final file = File(configPath);
    if (!file.existsSync()) {
      throw Exception('Konfigurasiya fayli topilmadi: $configPath');
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;

    final iconSection = yaml['icon'];
    if (iconSection == null) {
      throw Exception('icon.yaml faylida "icon:" bo\'limi topilmadi');
    }

    final imagePath = iconSection['image_path'] as String?;
    if (imagePath == null || imagePath.isEmpty) {
      throw Exception('"image_path" ko\'rsatilmagan');
    }

    final platforms = iconSection['platforms'] as YamlMap?;
    final adaptiveSection = iconSection['adaptive_icon'] as YamlMap?;

    return IconConfig(
      imagePath: imagePath,
      generateAndroid: platforms?['android'] as bool? ?? true,
      generateIos: platforms?['ios'] as bool? ?? true,
      generateWeb: platforms?['web'] as bool? ?? false,
      generateWindows: platforms?['windows'] as bool? ?? false,
      generateMacos: platforms?['macos'] as bool? ?? false,
      generateLinux: platforms?['linux'] as bool? ?? false,
      androidIconName: iconSection['android_icon_name'] as String?,
      adaptiveIcon: adaptiveSection != null,
      adaptiveForeground: adaptiveSection?['foreground'] as String?,
      adaptiveBackground: adaptiveSection?['background'] as String?,
    );
  }
}
