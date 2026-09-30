import 'package:flutter/material.dart';

import 'screens/root_screen.dart';
import 'state/app_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppController();
  await app.init();
  runApp(BakePracticeApp(app: app));
}

class BakePracticeApp extends StatelessWidget {
  const BakePracticeApp({super.key, required this.app, this.googleFont = true});
  final AppController app;

  /// 테스트에서는 false (폰트를 네트워크로 받지 않도록)
  final bool googleFont;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '제과제빵 실기 연습 타이머',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light, googleFont: googleFont),
        darkTheme: buildTheme(Brightness.dark, googleFont: googleFont),
        home: RootScreen(app: app),
      );
}
