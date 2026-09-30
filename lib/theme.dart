import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱 색상 토큰 (웹 버전의 CSS 변수와 같은 값). context.colors로 꺼내 쓴다.
@immutable
class BakeColors extends ThemeExtension<BakeColors> {
  const BakeColors({
    required this.bg,
    required this.paper,
    required this.ink,
    required this.muted,
    required this.line,
    required this.crust,
    required this.crustSoft,
    required this.alarm,
    required this.alarmSoft,
    required this.ok,
    required this.okSoft,
  });

  final Color bg, paper, ink, muted, line, crust, crustSoft, alarm, alarmSoft, ok, okSoft;

  static const light = BakeColors(
    bg: Color(0xFFE8ECEE), paper: Color(0xFFFBFBF8), ink: Color(0xFF1D2327), muted: Color(0xFF5B656C), line: Color(0xFFD2D8DC),
    crust: Color(0xFFA5570F), crustSoft: Color(0xFFF4E4CF), alarm: Color(0xFFC22F28), alarmSoft: Color(0xFFF8DEDC),
    ok: Color(0xFF2E6A4E), okSoft: Color(0xFFDCEDE3),
  );

  static const dark = BakeColors(
    bg: Color(0xFF141819), paper: Color(0xFF1E2326), ink: Color(0xFFECEFF0), muted: Color(0xFF9BA4AA), line: Color(0xFF2E3539),
    crust: Color(0xFFE39445), crustSoft: Color(0xFF3A2A1A), alarm: Color(0xFFF2665F), alarmSoft: Color(0xFF3D1F1D),
    ok: Color(0xFF72C39B), okSoft: Color(0xFF1D3328),
  );

  @override
  BakeColors copyWith() => this;

  @override
  BakeColors lerp(BakeColors? other, double t) => t < 0.5 || other == null ? this : other;
}

extension BakeColorsX on BuildContext {
  BakeColors get colors => Theme.of(this).extension<BakeColors>()!;
}

/// [googleFont]는 테스트에서 끈다 (폰트를 네트워크로 받기 때문)
ThemeData buildTheme(Brightness brightness, {bool googleFont = true}) {
  final c = brightness == Brightness.dark ? BakeColors.dark : BakeColors.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: c.crust, brightness: brightness, primary: c.crust, surface: c.paper),
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
  );
  final text = base.textTheme.apply(bodyColor: c.ink, displayColor: c.ink);
  return base.copyWith(
    textTheme: googleFont ? GoogleFonts.ibmPlexSansKrTextTheme(text) : text,
    appBarTheme: AppBarTheme(backgroundColor: c.bg, foregroundColor: c.ink, elevation: 0, scrolledUnderElevation: 0),
    dividerColor: c.line,
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.ok : null),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.line)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}
