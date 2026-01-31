# Project Physique

## Windows Desktop

- [Flutter Windows Desktop Setup](https://docs.flutter.dev/platform-integration/windows/install-windows)

### Prerequisites for Windows
To run Flutter on Windows desktop, you need:
- Visual Studio 2022 (not VS Code) with C++ development workload
- Windows 10 or later
- 64-bit version of Windows

### Installing Visual Studio
1. Download [Visual Studio 2022 Community](https://visualstudio.microsoft.com/downloads/)
2. During installation, select:
   - **Desktop development with C++** workload
   - This includes Windows 10/11 SDK and MSVC compiler
3. Restart your computer after installation

### Running on Windows
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

### Building for Windows
```bash
flutter build windows
```

The executable will be in: `build/windows/x64/runner/Release/`

---

## Web (Easiest for Testing)

```bash
# Build for web
flutter build web

# Or run directly
flutter run -d chrome
flutter run -d edge
```

## Project Documentation

See [README.md](README.md) for full project documentation.
