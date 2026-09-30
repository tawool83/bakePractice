import 'package:bake_practice/models/practice.dart';
import 'package:bake_practice/services/alert_service.dart';
import 'package:bake_practice/services/storage_service.dart';
import 'package:bake_practice/state/app_controller.dart';

/// 메모리에만 저장하는 저장소
class MemoryStorage extends StorageService {
  MemoryStorage([this.initial]);
  AppData? initial;
  int saves = 0;

  @override
  Future<AppData> load() async => initial ?? AppData();

  @override
  Future<void> save(AppData data) async {
    saves++;
    initial = AppData.fromJson(data.toJson());
  }
}

/// 알림 호출만 기록
class FakeAlerts extends AlertService {
  final List<bool> alerts = [];
  bool screenOn = false;

  @override
  Future<void> alert({required bool strong, required bool sound}) async => alerts.add(strong);

  @override
  Future<void> keepScreenOn(bool on) async => screenOn = on;
}

/// 수동으로 돌리는 시계
class FakeClock {
  int ms = 1000000;
  int call() => ms;
  void advance(Duration d) => ms += d.inMilliseconds;
}

AppController makeController({MemoryStorage? storage, FakeAlerts? alerts, FakeClock? clock}) => AppController(
      storage: storage ?? MemoryStorage(),
      alerts: alerts ?? FakeAlerts(),
      clock: (clock ?? FakeClock()).call,
    );
