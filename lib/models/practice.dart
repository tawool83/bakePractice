// 연습 세션, 연습 기록, 사용자 설정 모델과 JSON 변환.
// 저장 형식을 바꾸면 storage_service.dart의 키 버전을 올릴 것.

import 'bake_item.dart';

/// 진행 중인 세션의 공정 단계. [atMs]는 세션 시작 후 완료 시점(일시정지 제외 경과 ms)
class StepRecord {
  StepRecord(this.name, [this.atMs]);
  final String name;
  int? atMs;

  bool get done => atMs != null;

  Map<String, dynamic> toJson() => {'name': name, 'at': atMs};
  factory StepRecord.fromJson(Map<String, dynamic> j) => StepRecord(j['name'] as String, (j['at'] as num?)?.toInt());
}

/// 결과에 남는 단계별 소요 시간
class StepDuration {
  const StepDuration(this.name, this.ms);
  final String name;
  final int ms;

  Map<String, dynamic> toJson() => {'name': name, 'd': ms};
  factory StepDuration.fromJson(Map<String, dynamic> j) => StepDuration(j['name'] as String, (j['d'] as num).toInt());
}

/// 연습 한 번 (타이머가 도는 동안의 상태)
class PracticeSession {
  PracticeSession({
    required this.category,
    required this.itemId,
    required this.startAt,
    required this.totalMin,
    required this.weighMin,
    required this.steps,
    this.pausedMs = 0,
    this.pauseStart,
    Set<String>? fired,
    this.openIndex = 0,
    List<bool>? weighed,
    this.endAt,
  })  : fired = fired ?? {},
        weighed = weighed ?? [];

  final BakeCategory category;
  final String itemId;
  final int startAt;
  final int totalMin;
  final int weighMin;
  final List<StepRecord> steps;
  int pausedMs;
  int? pauseStart;

  /// 이미 울린 알림 키 ('w'=계량 초과, '30'·'10'·'0'=남은 분)
  final Set<String> fired;

  /// 펼쳐진 단계 설명
  int? openIndex;

  /// 배합표 재료별 계량 체크
  final List<bool> weighed;

  /// 끝낸 시점의 경과 ms. null이면 진행 중
  int? endAt;

  bool get isPaused => pauseStart != null;
  bool get isFinished => endAt != null;
  int get limitMs => totalMin * 60000;
  bool get weighingDone => steps.first.done;

  /// 일시정지 시간을 뺀 경과 ms
  int elapsedMs(int now) => now - startAt - pausedMs - (pauseStart != null ? now - pauseStart! : 0);

  /// 아직 완료하지 않은 첫 단계. 모두 끝났으면 -1
  int get currentIndex => steps.indexWhere((s) => !s.done);

  List<StepDuration> completedDurations() {
    var prev = 0;
    return [
      for (final s in steps.where((s) => s.done))
        () {
          final d = StepDuration(s.name, s.atMs! - prev);
          prev = s.atMs!;
          return d;
        }(),
    ];
  }

  Map<String, dynamic> toJson() => {
        'cat': category.name,
        'itemId': itemId,
        'startAt': startAt,
        'pausedMs': pausedMs,
        'pauseStart': pauseStart,
        'totalMin': totalMin,
        'weighMin': weighMin,
        'steps': steps.map((s) => s.toJson()).toList(),
        'fired': fired.toList(),
        'open': openIndex,
        'weighed': weighed,
        'endAt': endAt,
      };

  factory PracticeSession.fromJson(Map<String, dynamic> j) => PracticeSession(
        category: BakeCategory.fromName(j['cat'] as String?),
        itemId: j['itemId'] as String,
        startAt: (j['startAt'] as num).toInt(),
        pausedMs: (j['pausedMs'] as num?)?.toInt() ?? 0,
        pauseStart: (j['pauseStart'] as num?)?.toInt(),
        totalMin: (j['totalMin'] as num).toInt(),
        weighMin: (j['weighMin'] as num).toInt(),
        steps: (j['steps'] as List).map((e) => StepRecord.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        fired: ((j['fired'] as List?) ?? const []).map((e) => e.toString()).toSet(),
        openIndex: (j['open'] as num?)?.toInt(),
        weighed: ((j['weighed'] as List?) ?? const []).map((e) => e == true).toList(),
        endAt: (j['endAt'] as num?)?.toInt(),
      );
}

/// 저장된 연습 기록 하나
class HistoryEntry {
  const HistoryEntry({
    required this.date,
    required this.category,
    required this.itemId,
    required this.name,
    required this.limitMin,
    required this.usedMs,
    required this.steps,
    required this.checks,
    required this.memo,
  });

  final int date;
  final BakeCategory category;
  final String itemId;
  final String name;
  final int limitMin;
  final int usedMs;
  final List<StepDuration> steps;
  final List<bool> checks;
  final String memo;

  bool get overTime => usedMs > limitMin * 60000;

  Map<String, dynamic> toJson() => {
        'date': date,
        'cat': category.name,
        'itemId': itemId,
        'name': name,
        'limitMin': limitMin,
        'usedMs': usedMs,
        'steps': steps.map((s) => s.toJson()).toList(),
        'checks': checks,
        'memo': memo,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        date: (j['date'] as num).toInt(),
        category: BakeCategory.fromName(j['cat'] as String?),
        itemId: j['itemId'] as String,
        name: j['name'] as String,
        limitMin: (j['limitMin'] as num).toInt(),
        usedMs: (j['usedMs'] as num).toInt(),
        steps: ((j['steps'] as List?) ?? const []).map((e) => StepDuration.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        checks: ((j['checks'] as List?) ?? const []).map((e) => e == true).toList(),
        memo: (j['memo'] as String?) ?? '',
      );
}

/// 품목별 시험·계량 시간(분)
class ItemTimes {
  const ItemTimes(this.total, this.weigh);
  final int total;
  final int weigh;

  Map<String, dynamic> toJson() => {'total': total, 'weigh': weigh};
  factory ItemTimes.fromJson(Map<String, dynamic> j) => ItemTimes((j['total'] as num).toInt(), (j['weigh'] as num).toInt());
}

/// 사용자 설정. times·recipes 키는 '종목:품목id'
class Prefs {
  Prefs({this.sound = true, this.fresh = true, Map<String, ItemTimes>? times, Map<String, String>? recipes})
      : times = times ?? {},
        recipes = recipes ?? {};

  bool sound;

  /// 연습 횟수가 적은 품목에서 우선 뽑기
  bool fresh;
  final Map<String, ItemTimes> times;
  final Map<String, String> recipes;

  Map<String, dynamic> toJson() => {
        'sound': sound,
        'fresh': fresh,
        'times': times.map((k, v) => MapEntry(k, v.toJson())),
        'recipes': recipes,
      };

  factory Prefs.fromJson(Map<String, dynamic> j) => Prefs(
        sound: j['sound'] as bool? ?? true,
        fresh: j['fresh'] as bool? ?? true,
        times: ((j['times'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), ItemTimes.fromJson(Map<String, dynamic>.from(v as Map)))),
        recipes: ((j['recipes'] as Map?) ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
      );
}

/// 저장되는 앱 전체 상태
class AppData {
  AppData({this.category = BakeCategory.pastry, Prefs? prefs, List<HistoryEntry>? history, this.active})
      : prefs = prefs ?? Prefs(),
        history = history ?? [];

  BakeCategory category;
  final Prefs prefs;
  final List<HistoryEntry> history;
  PracticeSession? active;

  Map<String, dynamic> toJson() => {
        'cat': category.name,
        'prefs': prefs.toJson(),
        'history': history.map((h) => h.toJson()).toList(),
        'active': active?.toJson(),
      };

  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
        category: BakeCategory.fromName(j['cat'] as String?),
        prefs: j['prefs'] is Map ? Prefs.fromJson(Map<String, dynamic>.from(j['prefs'] as Map)) : null,
        history: ((j['history'] as List?) ?? const [])
            .map((e) => HistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        active: j['active'] is Map ? PracticeSession.fromJson(Map<String, dynamic>.from(j['active'] as Map)) : null,
      );
}
