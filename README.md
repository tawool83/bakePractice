# 제과제빵 실기 연습 타이머

제과·제빵기능사 실기 연습용 모바일 웹앱. 품목 랜덤 추첨, 시험·계량 타이머, 공정 단계 체크, 배합표 체크리스트, 비중 계산기, 연습 기록.

빌드 과정 없음. `index.html`을 브라우저로 바로 열거나 GitHub Pages 같은 정적 호스팅에 올리면 됩니다. 기록은 브라우저 localStorage에 저장됩니다.

## 파일 구조

| 파일 | 내용 |
|---|---|
| `index.html` | 화면 뼈대와 스크립트 로드 순서 |
| `css/style.css` | 스타일 (색상 토큰, 다크 모드 포함) |
| `js/utils.js` | 공통 유틸 (이스케이프, 시간 포맷 등) |
| `js/data.js` | **품목 데이터**: 품목·공정 단계·주의할 점 |
| `js/storage.js` | 상태 `S`와 localStorage 저장 |
| `js/alerts.js` | 진동, 알림음, 화면 꺼짐 방지 |
| `js/step-guide.js` | **단계별 상세 설명** (단계 이름 정규식 매칭), 배합표 파싱 |
| `js/session.js` | 연습 세션 시작·경과 시간 |
| `js/views.js` | 화면별 HTML 렌더링 |
| `js/timer.js` | 타이머 표시와 시간 알림 |
| `js/app.js` | 이벤트 처리, 앱 시작 |

스크립트는 모듈이 아닌 일반 `<script>`로 `index.html`에 적힌 순서대로 로드되며, 뒤 파일이 앞 파일의 전역 선언을 사용합니다. 파일을 추가하면 `index.html`에 순서를 맞춰 넣어주세요.

## 자주 하는 수정

- 품목 추가·공정 변경: `js/data.js`의 `PASTRY`, `BREAD`
- 단계 설명 추가: `js/step-guide.js`의 `RULES`에 `[정규식, () => [설명...]]` 추가
- 기본 시험시간: `js/utils.js`의 `timesFor`
- 저장 형식 변경 시 `js/storage.js`의 `KEY` 버전을 올릴 것
