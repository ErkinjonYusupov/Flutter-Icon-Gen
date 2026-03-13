# Changelog

## 1.0.0

- All terminal output and error messages translated to English
- Added support for Web, Windows, macOS, and Linux platforms
- Web: generates favicon (32x32), PWA icons (192, 512px), and updates manifest.json
- Windows: generates ICO file and PNG (256x256)
- macOS: generates all required sizes with Contents.json
- Linux: generates hicolor theme icons (16–512px)
- Platform directories are skipped gracefully when disabled in icon.yaml
- Renamed bin entry point to match package name (`flutter_icon_gen.dart`)

## 0.1.0

- Initial release
- Android launcher icon generation (mdpi → xxxhdpi)
- Android adaptive icon support (foreground + background)
- iOS app icon generation with Contents.json
