/// 종목 (제과기능사 / 제빵기능사)
enum BakeCategory {
  pastry('제과'),
  bread('제빵');

  const BakeCategory(this.label);
  final String label;

  static BakeCategory fromName(String? name) =>
      BakeCategory.values.firstWhere((c) => c.name == name, orElse: () => BakeCategory.pastry);
}

/// 실기 공개 품목 하나
class BakeItem {
  const BakeItem({
    required this.id,
    required this.name,
    required this.method,
    required this.difficulty,
    required this.steps,
    required this.tips,
  });

  final String id;
  final String name;

  /// 반죽법 (크림법, 공립법, 스트레이트법 등)
  final String method;

  /// 난이도 1~5 (커뮤니티 평가 기준 참고값)
  final int difficulty;

  /// 공정 단계 이름. 단계 설명은 step_guide.dart에서 이름으로 매칭
  final List<String> steps;

  /// 이 품목의 주의할 점
  final List<String> tips;
}
