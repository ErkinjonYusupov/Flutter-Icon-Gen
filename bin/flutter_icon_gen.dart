import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_icon_gen/flutter_icon_gen.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('config', abbr: 'c', defaultsTo: 'icon.yaml', help: 'Config file path (default: icon.yaml)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    print(parser.usage);
    exit(1);
  }

  if (args['help'] as bool) {
    print('flutter_icon_gen - Flutter launcher icon generator\n');
    print('Usage:');
    print('  dart run flutter_icon_gen [-c icon.yaml]\n');
    print('Options:');
    print(parser.usage);
    print('\nExample icon.yaml:');
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
    print('Error: "$configPath" not found.');
    print('Create an icon.yaml file in your Flutter project root.\n');
    print('Example icon.yaml:');
    print('''
icon:
  image_path: "assets/icon.png"
  platforms:
    android: true
    ios: true
''');
    exit(1);
  }

  print('flutter_icon_gen starting...');
  print('Config: $configPath\n');

  try {
    final generator = IconGenerator(configPath: configPath);
    await generator.generate();
    print('\nAll icons generated successfully!');
  } catch (e) {
    print('\nError: $e');
    exit(1);
  }
}
