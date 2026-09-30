import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// 남은 시간을 원형 게이지로 표시. 시간이 지나면 빨간색
class TimerDial extends StatelessWidget {
  const TimerDial({super.key, required this.fraction, required this.timeText, required this.subText, required this.over});

  /// 남은 비율 0~1
  final double fraction;
  final String timeText;
  final String subText;
  final bool over;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = min(MediaQuery.sizeOf(context).width * 0.78, 300.0);
    final fg = over ? c.alarm : c.crust;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _DialPainter(fraction: fraction.clamp(0, 1), bg: c.line, fg: fg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                child: FittedBox(
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: size * 0.19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      height: 1,
                      color: over ? c.alarm : c.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(subText, style: TextStyle(fontSize: 13, color: c.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.fraction, required this.bg, required this.fg});
  final double fraction;
  final Color bg, fg;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.05;
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, 2 * pi, false, base..color = bg);
    if (fraction > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * fraction, false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = fg);
    }
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.fraction != fraction || old.fg != fg || old.bg != bg;
}
