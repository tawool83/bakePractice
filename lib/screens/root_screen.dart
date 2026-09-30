import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'prep_screen.dart';
import 'result_screen.dart';
import 'run_screen.dart';

/// 상단 제목·탭과 현재 화면. 화면 전환은 AppController.view로 결정한다.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.app});
  final AppController app;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final c = context.colors;
        return PopScope(
          // 안드로이드 뒤로 가기: 준비 화면 → 목록, 기록 → 연습 탭
          canPop: app.view == AppView.home || app.view == AppView.run || app.view == AppView.result,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) app.goHome();
          },
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              title: const Text('실기 연습 타이머', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: false, label: Text('연습')),
                      ButtonSegment(value: true, label: Text('기록')),
                    ],
                    selected: {app.view == AppView.history},
                    onSelectionChanged: (s) => app.selectTab(s.first),
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      selectedBackgroundColor: c.ink,
                      selectedForegroundColor: c.paper,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _body(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    final a = app.active;
    switch (app.view) {
      case AppView.run:
      case AppView.result:
        final item = app.activeItem;
        if (a == null || item == null) return HomeScreen(app: app);
        return a.isFinished
            ? ResultScreen(key: ValueKey('result-${a.startAt}'), app: app, session: a, item: item)
            : RunScreen(app: app, session: a, item: item);
      case AppView.prep:
        final item = app.prepItem;
        if (item == null) return HomeScreen(app: app);
        return PrepScreen(key: ValueKey('prep-${app.category.name}-${item.id}'), app: app, item: item);
      case AppView.history:
        return HistoryScreen(app: app);
      case AppView.home:
        return HomeScreen(app: app);
    }
  }
}
