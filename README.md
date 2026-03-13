# flutter_icon_gen

A CLI tool that automatically generates launcher icons for all Flutter platforms from a single source image.

## Features

- Single command to generate icons for all platforms
- Supports Android, iOS, Web, Windows, macOS, and Linux
- Android adaptive icon support (foreground + background)
- Automatically updates `web/manifest.json`
- Simple `icon.yaml` configuration

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_icon_gen: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

### 1. Create `icon.yaml` in your Flutter project root

```yaml
icon:
  image_path: "assets/icon.png"
  platforms:
    android: true
    ios: true
    web: true
    windows: true
    macos: true
    linux: true
```

### 2. Run the generator

```bash
dart run flutter_icon_gen
```

To use a custom config file:

```bash
dart run flutter_icon_gen -c my_icon.yaml
```

## Configuration

| Field | Description | Default |
|-------|-------------|---------|
| `icon.image_path` | Path to the source image | **Required** |
| `icon.platforms.android` | Generate Android icons | `true` |
| `icon.platforms.ios` | Generate iOS icons | `true` |
| `icon.platforms.web` | Generate Web icons | `false` |
| `icon.platforms.windows` | Generate Windows icons | `false` |
| `icon.platforms.macos` | Generate macOS icons | `false` |
| `icon.platforms.linux` | Generate Linux icons | `false` |
| `icon.android_icon_name` | Android icon resource name | `ic_launcher` |
| `icon.adaptive_icon.foreground` | Adaptive icon foreground image | — |
| `icon.adaptive_icon.background` | Adaptive icon background (color or image path) | — |

### Full example

```yaml
icon:
  image_path: "assets/icon.png"
  platforms:
    android: true
    ios: true
    web: true
    windows: true
    macos: true
    linux: true
  android_icon_name: "ic_launcher"
  adaptive_icon:
    foreground: "assets/icon_foreground.png"
    background: "#FFFFFF"
```

## Generated icon sizes

### Android

| Directory | Size |
|-----------|------|
| mipmap-mdpi | 48×48 |
| mipmap-hdpi | 72×72 |
| mipmap-xhdpi | 96×96 |
| mipmap-xxhdpi | 144×144 |
| mipmap-xxxhdpi | 192×192 |

Adaptive icon foreground layers are generated at 108px–432px, and XML descriptors are written to `mipmap-anydpi-v26/`.

### iOS

All required sizes from 20×20 to 1024×1024, with `Contents.json` written automatically.

### Web

| File | Size |
|------|------|
| `web/favicon.png` | 32×32 |
| `web/icons/Icon-192.png` | 192×192 |
| `web/icons/Icon-512.png` | 512×512 |
| `web/icons/Icon-maskable-192.png` | 192×192 |
| `web/icons/Icon-maskable-512.png` | 512×512 |

`web/manifest.json` icons field is updated automatically.

### Windows

Generates `windows/runner/resources/app_icon.ico` and `app_icon.png` (256×256).

### macOS

All required sizes from 16×16 to 1024×1024 (@1x and @2x), with `Contents.json` written automatically.

### Linux

Icons generated following the freedesktop.org hicolor theme standard:
`linux/data/icons/hicolor/<size>x<size>/apps/app_icon.png` for sizes 16, 32, 48, 64, 128, 256, and 512.

## Requirements

- Dart SDK >= 3.0.0
- Supported image formats: PNG, JPG, BMP, GIF
- Recommended minimum source image size: **1024×1024 px**

## License

MIT
# Flutter-Icon-Gen
