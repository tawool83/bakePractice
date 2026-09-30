import 'package:bake_practice/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('품목 선택 → 연습 시작 → 단계 완료 → 끝내기 → 기록 저장', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final clock = FakeClock();
    final app = makeController(clock: clock);
    await app.init();
    await tester.pumpWidget(BakePracticeApp(app: app, googleFont: false));

    expect(find.text('오늘의 과제 뽑기'), findsOneWidget);
    await tester.tap(find.text('브라우니'));
    await tester.pumpAndSettle();

    // 준비 화면
    await tester.scrollUntilVisible(find.text('연습 시작'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('연습 시작'));
    await tester.pump();

    // 연습 화면
    expect(find.text('계량 남은 시간'), findsOneWidget);
    expect(find.text('「재료 계량」 완료'), findsOneWidget);
    clock.advance(const Duration(minutes: 4));
    await tester.tap(find.text('「재료 계량」 완료'));
    await tester.pump();
    expect(find.text('계량 남은 시간'), findsNothing);

    await tester.scrollUntilVisible(find.text('연습 끝내기'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('연습 끝내기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('끝내기'));
    await tester.pumpAndSettle();

    // 결과 화면
    expect(find.text('단계별 걸린 시간'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('기록 저장'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 기록 화면
    expect(find.text('제과 연습 현황 (1/20)'), findsOneWidget);
    expect(app.data.history, hasLength(1));

    app.dispose();
  });
}
