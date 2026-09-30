import 'package:flutter/material.dart';

import '../theme.dart';

enum StepMark { todo, current, done }

/// 번호가 붙은 공정 단계 목록. 단계를 누르면 [detailBuilder]로 설명을 펼친다.
class StepsList extends StatelessWidget {
  const StepsList({
    super.key,
    required this.steps,
    required this.openIndex,
    required this.onToggle,
    required this.detailBuilder,
    this.stateOf,
    this.timeOf,
  });

  final List<String> steps;
  final int? openIndex;
  final ValueChanged<int> onToggle;
  final Widget Function(int index) detailBuilder;
  final StepMark Function(int index)? stateOf;

  /// 단계 오른쪽에 표시할 걸린 시간
  final String Function(int index)? timeOf;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            index: i,
            name: steps[i],
            state: stateOf?.call(i) ?? StepMark.todo,
            time: timeOf?.call(i) ?? '',
            open: openIndex == i,
            onTap: () => onToggle(i),
            detail: openIndex == i ? detailBuilder(i) : null,
            showDivider: i > 0,
            colors: c,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.name,
    required this.state,
    required this.time,
    required this.open,
    required this.onTap,
    required this.detail,
    required this.showDivider,
    required this.colors,
  });

  final int index;
  final String name;
  final StepMark state;
  final String time;
  final bool open;
  final VoidCallback onTap;
  final Widget? detail;
  final bool showDivider;
  final BakeColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final isCur = state == StepMark.current, isDone = state == StepMark.done;
    final badge = Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCur ? c.crust : (isDone ? c.okSoft : null),
        border: isCur || isDone ? null : Border.all(color: c.line),
      ),
      child: Text(
        isDone ? '✓' : '${index + 1}',
        style: TextStyle(fontSize: 12, color: isCur ? Colors.white : (isDone ? c.ok : c.muted)),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: isCur ? c.crustSoft : null,
        border: showDivider ? Border(top: BorderSide(color: c.line)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  badge,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isDone ? c.muted : c.ink,
                        fontWeight: isCur ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(time, style: TextStyle(fontSize: 13, color: c.muted, fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(Icons.chevron_right, size: 18, color: c.muted),
                  ),
                ],
              ),
            ),
          ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 12, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: c.paper,
                  border: Border.all(color: c.line),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: detail,
              ),
            ),
        ],
      ),
    );
  }
}
