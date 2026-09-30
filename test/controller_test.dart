import 'package:bake_practice/models/bake_item.dart';
import 'package:bake_practice/models/practice.dart';
import 'package:bake_practice/state/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late MemoryStorage storage;
  late FakeAlerts alerts;
  late FakeClock clock;
  late AppController app;

  setUp(() async {
    storage = MemoryStorage();
    alerts = FakeAlerts();
    clock = FakeClock();
    app = makeController(storage: storage, alerts: alerts, clock: clock);
    await app.init();
  });

  tearDown(() => app.dispose());

  test('세션 시작: 시간 설정 저장, 화면 유지 켜짐', () {
    app.openPrep('pound');
    app.startSession(totalMin: 120, weighMin: 5);
    expect(app.view, AppView.run);
    expect(app.active!.totalMin, 120);
    expect(app.timesFor(BakeCategory.pastry, 'pound').total, 120);
    expect(alerts.screenOn, isTrue);
  });

  test('시간 범위 밖 입력은 제한값으로 맞춤', () {
    app.openPrep('pound');
    app.startSession(totalMin: 999, weighMin: 0);
    expect(app.active!.totalMin, 300);
    expect(app.active!.weighMin, 1);
  });

  test('단계 완료·되돌리기와 일시정지 시간 제외', () {
    app.openPrep('brownie');
    app.startSession(totalMin: 60, weighMin: 10);
    clock.advance(const Duration(minutes: 5));
    app.completeStep();
    expect(app.active!.steps[0].atMs, 5 * 60000);

    app.togglePause();
    clock.advance(const Duration(minutes: 20));
    app.togglePause();
    clock.advance(const Duration(minutes: 1));
    app.completeStep();
    expect(app.active!.steps[1].atMs, 6 * 60000, reason: '일시정지 20분은 빠져야 함');

    app.undoStep();
    expect(app.active!.steps[1].done, isFalse);
    expect(app.active!.currentIndex, 1);
  });

  test('알림은 계량 초과, 30분, 10분, 종료 때 한 번씩만', () {
    app.openPrep('pound');
    app.startSession(totalMin: 60, weighMin: 10);
    alerts.alerts.clear();

    clock.advance(const Duration(minutes: 10));
    app.tick();
    app.tick();
    expect(alerts.alerts, [false], reason: '계량 초과');

    clock.advance(const Duration(minutes: 20));
    app.tick();
    expect(alerts.alerts, [false, false], reason: '남은 30분');

    clock.advance(const Duration(minutes: 20));
    app.tick();
    clock.advance(const Duration(minutes: 10));
    app.tick();
    app.tick();
    expect(alerts.alerts, [false, false, false, true], reason: '10분, 종료(강하게)');
  });

  test('모든 단계 완료하면 결과 화면, 저장하면 기록에 남음', () {
    app.openPrep('brownie');
    app.startSession(totalMin: 60, weighMin: 10);
    final n = app.active!.steps.length;
    for (var i = 0; i < n; i++) {
      clock.advance(const Duration(minutes: 2));
      app.completeStep();
    }
    expect(app.view, AppView.result);
    expect(app.active!.endAt, n * 2 * 60000);
    expect(alerts.screenOn, isFalse);

    app.saveResult(checks: [true, false, true, true, true], memo: '  메모  ');
    expect(app.active, isNull);
    expect(app.view, AppView.history);
    final h = app.data.history.single;
    expect(h.memo, '메모');
    expect(h.steps, hasLength(n));
    expect(app.countFor(BakeCategory.pastry, 'brownie'), 1);
  });

  test('진행 중에는 탭을 눌러도 연습 화면 유지', () {
    app.openPrep('pound');
    app.startSession(totalMin: 60, weighMin: 10);
    app.selectTab(true);
    expect(app.view, AppView.run);
  });

  test('적게 연습한 품목 우선 뽑기', () {
    // 브라우니 하나만 빼고 모두 한 번씩 연습한 상태
    for (final it in app.items.where((i) => i.id != 'brownie')) {
      app.data.history.add(HistoryEntry(
        date: 0, category: BakeCategory.pastry, itemId: it.id, name: it.name,
        limitMin: 60, usedMs: 0, steps: const [], checks: const [], memo: '',
      ));
    }
    for (var i = 0; i < 20; i++) {
      expect(app.drawItem().id, 'brownie');
    }
  });

  test('저장 후 다시 열면 진행 중 세션 복원', () async {
    app.openPrep('pound');
    app.startSession(totalMin: 90, weighMin: 10);
    clock.advance(const Duration(minutes: 3));
    app.completeStep();

    final reopened = makeController(storage: storage, alerts: FakeAlerts(), clock: clock);
    await reopened.init();
    expect(reopened.view, AppView.run);
    expect(reopened.active!.totalMin, 90);
    expect(reopened.active!.steps.first.atMs, 3 * 60000);
    reopened.dispose();
  });

  test('JSON 왕복 변환', () {
    final d = AppData(category: BakeCategory.bread)
      ..prefs.recipes['bread:plain'] = '강력분 1000g'
      ..prefs.times['bread:plain'] = const ItemTimes(210, 12);
    final back = AppData.fromJson(d.toJson());
    expect(back.category, BakeCategory.bread);
    expect(back.prefs.recipes['bread:plain'], '강력분 1000g');
    expect(back.prefs.times['bread:plain']!.total, 210);
  });
}
