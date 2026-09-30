import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/items.dart';
import '../models/bake_item.dart';
import '../models/practice.dart';
import '../services/alert_service.dart';
import '../services/storage_service.dart';

enum AppView { home, prep, run, result, history }

/// 앱 전체 상태와 동작. 화면은 이 객체를 구독하고 메서드만 호출한다.
class AppController extends ChangeNotifier {
  AppController({StorageService? storage, AlertService? alerts, int Function()? clock, Random? random})
      : _storage = storage ?? StorageService(),
        _alerts = alerts ?? AlertService(),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch),
        _random = random ?? Random();

  final StorageService _storage;
  final AlertService _alerts;
  final int Function() _clock;
  final Random _random;

  AppData data = AppData();
  AppView view = AppView.home;

  /// 준비 화면에서 보고 있는 품목
  String? prepId;

  /// 준비 화면에서 펼친 단계
  int? prepOpen;

  /// 타이머 화면 갱신용 현재 시각(ms). 250ms마다 바뀐다
  final ValueNotifier<int> now = ValueNotifier(0);
  Timer? _ticker;

  Future<void> init() async {
    data = await _storage.load();
    final a = data.active;
    if (a != null) {
      view = a.isFinished ? AppView.result : AppView.run;
      if (!a.isFinished && !a.isPaused) _alerts.keepScreenOn(true);
    }
    _syncTicker();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    now.dispose();
    super.dispose();
  }

  // ---------- 조회 ----------

  BakeCategory get category => data.category;
  Prefs get prefs => data.prefs;
  List<BakeItem> get items => itemsOf(category);
  PracticeSession? get active => data.active;
  BakeItem? get prepItem => prepId == null ? null : findItem(category, prepId!);
  BakeItem? get activeItem => active == null ? null : findItem(active!.category, active!.itemId);

  /// 진행 중(끝내지 않은) 세션이 있으면 다른 화면으로 못 나간다
  bool get sessionRunning => active != null && !active!.isFinished;

  int nowMs() => _clock();

  String _key(BakeCategory cat, String id) => '${cat.name}:$id';

  int countFor(BakeCategory cat, String id) => data.history.where((h) => h.category == cat && h.itemId == id).length;

  ItemTimes timesFor(BakeCategory cat, String id) =>
      prefs.times[_key(cat, id)] ?? ItemTimes(defaultTotalMinutes(cat, id), defaultWeighMinutes);

  String recipeOf(BakeCategory cat, String id) => prefs.recipes[_key(cat, id)] ?? '';

  // ---------- 저장 ----------

  void _commit() {
    _storage.save(data);
    notifyListeners();
  }

  // ---------- 홈·준비 ----------

  void setCategory(BakeCategory cat) {
    data.category = cat;
    _commit();
  }

  void setFresh(bool v) {
    prefs.fresh = v;
    _commit();
  }

  void setSound(bool v) {
    prefs.sound = v;
    _commit();
  }

  /// 무작위 품목 선택. "적게 연습한 품목 우선"이면 연습 횟수가 가장 적은 품목 중에서 고른다
  BakeItem drawItem() {
    var pool = items;
    if (prefs.fresh) {
      final minCount = pool.map((i) => countFor(category, i.id)).reduce(min);
      pool = pool.where((i) => countFor(category, i.id) == minCount).toList();
    }
    return pool[_random.nextInt(pool.length)];
  }

  void openPrep(String id) {
    prepId = id;
    prepOpen = null;
    view = AppView.prep;
    notifyListeners();
  }

  void goHome() {
    view = AppView.home;
    notifyListeners();
  }

  /// 상단 탭 전환. 진행 중인 세션이 있으면 연습 화면을 유지
  void selectTab(bool history) {
    if (sessionRunning) {
      view = AppView.run;
    } else if (active != null) {
      view = AppView.result;
    } else {
      view = history ? AppView.history : AppView.home;
    }
    notifyListeners();
  }

  void togglePrepOpen(int i) {
    prepOpen = prepOpen == i ? null : i;
    notifyListeners();
  }

  void setRecipe(String text) {
    if (prepId == null) return;
    prefs.recipes[_key(category, prepId!)] = text;
    _storage.save(data);
  }

  // ---------- 세션 ----------

  void startSession({required int totalMin, required int weighMin}) {
    final it = prepItem;
    if (it == null) return;
    final total = totalMin.clamp(30, 300), weigh = weighMin.clamp(1, 30);
    prefs.times[_key(category, it.id)] = ItemTimes(total, weigh);
    data.active = PracticeSession(
      category: category,
      itemId: it.id,
      startAt: _clock(),
      totalMin: total,
      weighMin: weigh,
      steps: it.steps.map(StepRecord.new).toList(),
    );
    view = AppView.run;
    _alerts.keepScreenOn(true);
    _syncTicker();
    _commit();
  }

  void toggleStepOpen(int i) {
    final a = active;
    if (a == null) return;
    a.openIndex = a.openIndex == i ? null : i;
    _commit();
  }

  void toggleWeighed(int i, bool v) {
    final a = active;
    if (a == null) return;
    while (a.weighed.length <= i) {
      a.weighed.add(false);
    }
    a.weighed[i] = v;
    _commit();
  }

  void completeStep() {
    final a = active;
    if (a == null) return;
    final i = a.currentIndex;
    if (i < 0) return;
    a.steps[i].atMs = a.elapsedMs(_clock());
    if (a.currentIndex < 0) {
      a.endAt = a.elapsedMs(_clock());
      view = AppView.result;
      _alerts.keepScreenOn(false);
      _syncTicker();
    } else {
      a.openIndex = a.currentIndex;
    }
    _commit();
  }

  void undoStep() {
    final a = active;
    if (a == null) return;
    var i = a.currentIndex;
    i = i < 0 ? a.steps.length - 1 : i - 1;
    if (i < 0) return;
    a.steps[i].atMs = null;
    _commit();
  }

  void togglePause() {
    final a = active;
    if (a == null) return;
    final t = _clock();
    if (a.pauseStart != null) {
      a.pausedMs += t - a.pauseStart!;
      a.pauseStart = null;
      _alerts.keepScreenOn(true);
    } else {
      a.pauseStart = t;
      _alerts.keepScreenOn(false);
    }
    _commit();
  }

  /// 남은 단계와 상관없이 지금 끝내고 결과 화면으로
  void finishNow() {
    final a = active;
    if (a == null) return;
    final t = _clock();
    a.endAt = a.elapsedMs(t);
    if (a.pauseStart != null) {
      a.pausedMs += t - a.pauseStart!;
      a.pauseStart = null;
    }
    view = AppView.result;
    _alerts.keepScreenOn(false);
    _syncTicker();
    _commit();
  }

  void saveResult({required List<bool> checks, required String memo}) {
    final a = active, it = activeItem;
    if (a == null || it == null) return;
    data.history.add(HistoryEntry(
      date: _clock(),
      category: a.category,
      itemId: a.itemId,
      name: it.name,
      limitMin: a.totalMin,
      usedMs: a.endAt ?? a.elapsedMs(_clock()),
      steps: a.completedDurations(),
      checks: checks,
      memo: memo.trim(),
    ));
    data.active = null;
    view = AppView.history;
    _commit();
  }

  void discardResult() {
    data.active = null;
    view = AppView.home;
    _alerts.keepScreenOn(false);
    _syncTicker();
    _commit();
  }

  void clearHistory() {
    data.history.clear();
    _commit();
  }

  // ---------- 타이머·알림 ----------

  void _syncTicker() {
    if (sessionRunning) {
      _ticker ??= Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
      tick();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  /// 시간 알림 확인. 계량 시간 초과, 남은 30분·10분, 종료 시 한 번씩 울린다
  @visibleForTesting
  void tick() {
    final t = _clock();
    now.value = t;
    final a = active;
    if (a == null || a.isFinished) return;
    final el = a.elapsedMs(t), rem = a.limitMs - el;
    var changed = false;
    if (!a.weighingDone && a.weighMin * 60000 - el <= 0 && a.fired.add('w')) {
      _alerts.alert(strong: false, sound: prefs.sound);
      changed = true;
    }
    for (final m in const [30, 10, 0]) {
      if (rem <= m * 60000 && a.limitMs > m * 60000 && a.fired.add('$m')) {
        _alerts.alert(strong: m == 0, sound: prefs.sound);
        changed = true;
      }
    }
    if (changed) _storage.save(data);
  }
}
