# 제과제빵 실기 연습 타이머

제과·제빵기능사 실기 연습용 Flutter 앱 (Android, Web). 품목 랜덤 추첨, 시험·계량 타이머, 공정 단계 체크와 상세 설명, 배합표 체크리스트, 비중 계산기, 연습 기록.

기록은 기기에 저장됩니다 (Android: SharedPreferences, Web: 브라우저 localStorage). 서버는 없습니다.

## 실행

```bash
flutter pub get
flutter run -d chrome        # 웹
flutter run                  # 연결된 안드로이드 기기
flutter test                 # 테스트
flutter build web --release  # build/web 을 정적 호스팅에 올리면 됨
flutter build apk --release
```

## 폴더 구조

```
lib/
  main.dart                  앱 시작, 테마 연결
  theme.dart                 색상 토큰(BakeColors), 라이트·다크 테마
  models/
    bake_item.dart           종목(BakeCategory), 품목(BakeItem)
    practice.dart            연습 세션, 기록, 설정, JSON 변환
  data/
    items.dart               ★ 품목 데이터: 품목·공정 단계·주의할 점, 기본 시험시간
    step_guide.dart          ★ 단계별 상세 설명(정규식 매칭), 배합표 파싱, 비중 계산
  state/
    app_controller.dart      앱 상태와 동작(ChangeNotifier), 타이머 알림
  services/
    storage_service.dart     저장·불러오기
    alert_service.dart       진동, 알림음, 화면 꺼짐 방지
  screens/                   화면 (root → home / prep / run / result / history)
  widgets/                   공통 위젯 (카드, 단계 목록, 단계 설명, 타이머 다이얼, 추첨 연출)
  utils/format.dart          시간 표시
assets/sounds/beep.wav       알림음 (880Hz)
test/                        데이터·컨트롤러·화면 테스트
legacy-web/                  Flutter 이전의 HTML/JS 버전 (참고용)
```

화면은 `AppController`를 구독만 하고, 상태 변경은 모두 컨트롤러 메서드로 합니다. 테스트에서는 저장소·알림·시계를 가짜로 바꿔 끼웁니다 (`test/helpers.dart`).

## 자주 하는 수정

- 품목 추가·공정 변경: `lib/data/items.dart`
- 단계 설명 추가: `lib/data/step_guide.dart`의 `_rules`에 `_Rule('정규식', _fixed([...]))` 추가
- 기본 시험시간: `lib/data/items.dart`의 `defaultTotalMinutes`
- 셀프 체크 항목: `lib/screens/result_screen.dart`의 `kSelfChecks` (기존 기록과 순서가 맞아야 하니 뒤에만 추가)
- 저장 형식 변경 시 `lib/services/storage_service.dart`의 `key` 버전을 올릴 것

## 남은 작업

- 큐넷 공개문제 기준 품목별 시험시간 기본값 채우기
- 품목별 배합표 기본값 채우기
- 앱 아이콘, 릴리스 서명 설정
