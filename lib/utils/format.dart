String _p2(int n) => n.toString().padLeft(2, '0');

/// 타이머 표시. 음수는 초과 시간으로 '+' 표시 (예: 1:05:09, 12:30, +03:10)
String formatClock(int ms) {
  final neg = ms < 0;
  final t = ms.abs() ~/ 1000;
  final h = t ~/ 3600, m = t % 3600 ~/ 60, s = t % 60;
  return '${neg ? '+' : ''}${h > 0 ? '$h:${_p2(m)}' : _p2(m)}:${_p2(s)}';
}

/// 분 단위 요약 (예: 45분, 2시간 5분)
String formatMinutes(int ms) {
  final m = (ms / 60000).round();
  return m >= 60 ? '${m ~/ 60}시간 ${m % 60}분' : '$m분';
}

/// 기록 날짜 (예: 9/30 17:05)
String formatDate(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return '${d.month}/${d.day} ${_p2(d.hour)}:${_p2(d.minute)}';
}
