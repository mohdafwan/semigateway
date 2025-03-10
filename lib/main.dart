import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:semicalibration/core/ui/appcolor.dart';
import 'package:semicalibration/features/configuration_fetures/presentation/present_.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize window manager for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1670, 768),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      minimumSize: Size(1370, 768),
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gateway App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColor.primaryColor,
          colorScheme: const ColorScheme.dark(
            primary: AppColor.buttonColor,
            secondary: AppColor.secondaryColor,
            background: AppColor.primaryColor,
          ),
        ),
        home: const PresentScreen(),
      ),
    );
  }
}
