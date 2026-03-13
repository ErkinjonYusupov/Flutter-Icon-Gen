import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_icon_gen/flutter_icon_gen.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('config', abbr: 'c', defaultsTo: 'icon.yaml', help: 'Konfigurasiya fayli (default: icon.yaml)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Yordam');

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('Xato: $e');
    print(parser.usage);
    exit(1);
  }

  if (args['help'] as bool) {
    print('flutter_icon_gen - Flutter launcher ikonlar generatori\n');
    print('Ishlatilishi:');
    print('  dart run flutter_icon_gen [-c icon.yaml]\n');
    print('Parametrlar:');
    print(parser.usage);
    print('\nicon.yaml namunasi:');
    print('''
icon:
  image_path: "assets/icon.png"
  platforms:
    android: true
    ios: true
''');
    exit(0);
  }

  final configPath = args['config'] as String;

  final configFile = File(configPath);
  if (!configFile.existsSync()) {
    print('Xato: "$configPath" fayli topilmadi.');
    print('Flutter loyiha papkasida icon.yaml fayli yarating.\n');
    print('Namuna icon.yaml:');
    print('''
icon:
  image_path: "assets/icon.png"
  platforms:
    android: true
    ios: true
''');
    exit(1);
  }

  print('flutter_icon_gen ishga tushmoqda...');
  print('Konfigurasiya: $configPath\n');

  try {
    final generator = IconGenerator(configPath: configPath);
    await generator.generate();
    print('\nBarcha ikonlar muvaffaqiyatli yaratildi!');
  } catch (e) {
    print('\nXato yuz berdi: $e');
    exit(1);
  }
}
