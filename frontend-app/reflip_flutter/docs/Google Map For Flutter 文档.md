在此项目中添加 Flutter 版 Google 地图软件包插件。

flutter pub add google_maps_flutter
  
设置平台版本

设置 iOS 平台的最低版本。

在您的首选 IDE 中打开 ios/Podfile 配置文件。
将以下几行内容添加到此 Podfile 的开头：

  # Set platform to 14.0 to enable latest Google Maps SDK
  platform :ios, '14.0'

将您的 API 密钥添加到项目中
您在按开始前须知一文做准备工作时，为自己的应用生成了一个 API 密钥。现在，请将该密钥添加到您的 Flutter 项目中。您应将此 API 密钥添加到 Flutter 项目的所有目标平台：iOS、Android 和 Web。

在下例中，请将 YOUR_API_KEY 替换为您的 API 密钥。

iOS
将您的 API 密钥添加到 AppDelegate.swift 文件中。

使用您的首选 IDE 打开 Flutter 项目中的 ios/Runner/AppDelegate.swift 文件。
添加以下导入语句，将 Flutter 版 Google 地图软件包添加到您的应用中：

import GoogleMaps
将您的 API 添加到 application(_:didFinishLaunchingWithOptions:) 方法，将其中的 YOUR_API_KEY 替换为您的 API 密钥：

GMSServices.provideAPIKey("YOUR_API_KEY")
保存并关闭 AppDelegate.swift 文件。
完成的 AppDelegate.swift 文件应与以下内容类似：


import UIKit
import Flutter
import GoogleMaps  // Add this import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // TODO: Add your Google Maps API key
    GMSServices.provideAPIKey("YOUR_API_KEY")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

添加地图
以下代码展示了如何在新的 Flutter 应用中添加简单的地图。

注意：假设前面的步骤均已成功完成，下面的 Dart 主函数应该可以在所有平台（包括 Android、iOS 和 Web）上正常运行。
使用您的首选 IDE 打开 Flutter 项目中的 lib/main.dart 文件。
在应用的默认主方法中添加或更新方法，以创建和初始化 mapController 的实例。

      import 'package:flutter/material.dart';
      import 'package:google_maps_flutter/google_maps_flutter.dart';
      
      void main() => runApp(const MyApp());
      
      class MyApp extends StatefulWidget {
        const MyApp({super.key});
      
        @override
        State<MyApp> createState() => _MyAppState();
      }
      
      class _MyAppState extends State<MyApp> {
        late GoogleMapController mapController;
      
        final LatLng _center = const LatLng(-33.86, 151.20);
      
        void _onMapCreated(GoogleMapController controller) {
          mapController = controller;
        }
      
        @override
        Widget build(BuildContext context) {
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Maps Sample App'),
                backgroundColor: Colors.green[700],
              ),
              body: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
              ),
            ),
          );
        }
      }
启动您要用于运行应用的模拟器或设备。
运行应用。您看到的输出应该会类似于：

  flutter run

   
键入您要运行的平台所对应的编号。每次您调用 flutter run 时，Flutter 都会向您显示这些平台选项。如果您的开发系统没有正在运行的模拟器或已连接的测试设备，Flutter 会选择打开 Chrome。

每个平台都应显示一张以澳大利亚悉尼为中心的地图。如果该地图没有显示，请检查您是否已将 API 密钥添加到相应的目标项目中。

