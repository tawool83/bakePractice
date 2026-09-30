import 'package:flutter/material.dart';

import '../data/step_guide.dart';
import '../models/bake_item.dart';
import '../theme.dart';
import 'common.dart';

/// 단계 하나의 상세 설명. 계량 단계는 배합표 체크리스트, 비중 단계는 계산기를 함께 보여준다.
class StepDetail extends StatelessWidget {
  const StepDetail({
    super.key,
    required this.stepName,
    required this.category,
    required this.recipe,
    this.weighed,
    this.onWeighed,
  });

  final String stepName;
  final BakeCategory category;
  final List<RecipeLine> recipe;

  /// 연습 중일 때만 전달. null이면 배합표를 읽기 전용으로 보여준다
  final List<bool>? weighed;
  final void Function(int index, bool value)? onWeighed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final guide = stepGuide(stepName, category);
    final sub = TextStyle(fontSize: 13, color: c.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (guide.isNotEmpty) BulletList(guide, fontSize: 14) else Text('공개문제 요구사항대로 진행해.', style: sub),
        if (isWeighStep(stepName)) ..._weighSection(c, sub),
        if (isGravityStep(stepName)) ...[
          const SizedBox(height: 8),
          Text('비중 계산기 (g)', style: sub),
          const SizedBox(height: 4),
          const GravityCalculator(),
        ],
      ],
    );
  }

  List<Widget> _weighSection(BakeColors c, TextStyle sub) {
    if (recipe.isEmpty) {
      return [
        const SizedBox(height: 8),
        Text('배합표를 입력하면 여기서 재료별로 체크하면서 계량할 수 있어. 과제 준비 화면의 배합표 칸에 넣어줘.', style: sub),
      ];
    }
    final live = weighed != null;
    final w = weighed ?? const <bool>[];
    bool got(int i) => i < w.length && w[i];
    return [
      const SizedBox(height: 8),
      Text(live ? '계량 체크 (${List.generate(recipe.length, got).where((v) => v).length}/${recipe.length})' : '내 배합표', style: sub),
      for (var i = 0; i < recipe.length; i++)
        InkWell(
          onTap: live ? () => onWeighed?.call(i, !got(i)) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                if (live)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Checkbox(value: got(i), onChanged: (v) => onWeighed?.call(i, v ?? false)),
                  ),
                if (live) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    recipe[i].name,
                    style: TextStyle(
                      color: got(i) ? c.muted : c.ink,
                      decoration: got(i) ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(recipe[i].amount,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
          ),
        ),
    ];
  }
}

/// 빈 컵, 컵+물, 컵+반죽 무게로 비중 계산
class GravityCalculator extends StatefulWidget {
  const GravityCalculator({super.key});

  @override
  State<GravityCalculator> createState() => _GravityCalculatorState();
}

class _GravityCalculatorState extends State<GravityCalculator> {
  final _cup = TextEditingController(), _water = TextEditingController(), _dough = TextEditingController();

  @override
  void dispose() {
    _cup.dispose();
    _water.dispose();
    _dough.dispose();
    super.dispose();
  }

  Widget _field(String label, TextEditingController ctrl) => Expanded(
        child: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sg = specificGravity(
      cup: double.tryParse(_cup.text),
      cupWater: double.tryParse(_water.text),
      cupDough: double.tryParse(_dough.text),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _field('빈 컵', _cup),
          const SizedBox(width: 6),
          _field('컵+물', _water),
          const SizedBox(width: 6),
          _field('컵+반죽', _dough),
        ]),
        const SizedBox(height: 6),
        Text(
          sg == null ? '비중 -' : '비중 ${sg.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
