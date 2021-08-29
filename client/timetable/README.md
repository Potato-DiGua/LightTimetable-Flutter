# LightTimetable-Flutter
轻课程表Flutter版
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### 配置
在`client\timetable\lib\utils\http_util.dart`中修改服务器地址`BASE_URL`

### json
##### 一次性生成
在项目根目录下运行
```shell script
flutter packages pub run build_runner build
```
我们可以在需要时为我们的model生成json序列化代码。 这触发了一次性构建，它通过我们的源文件，挑选相关的并为它们生成必要的序列化代码。
虽然这非常方便，但如果我们不需要每次在model类中进行更改时都要手动运行构建命令的话会更好。

##### 持续生成
使用_watcher_可以使我们的源代码生成的过程更加方便。它会监视我们项目中文件的变化，并在需要时自动构建必要的文件。我们可以通过
```shell script
flutter packages pub run build_runner watch
```
在项目根目录下运行来启动_watcher_。

只需启动一次观察器，然后并让它在后台运行，这是安全的。

### 构建web
```shell
# 移动端
flutter build web --web-renderer html

# pc端
flutter build web --web-renderer canvaskit
```
### web起服务
```shell
python -m http.server 80 --directory .\build\web\
```

### android 打包
```shell
flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
# 安装
adb install .\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

