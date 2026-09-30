import 'package:flutter/material.dart';

import '../data/items.dart';
import '../models/bake_item.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// 기록: 종목별 품목 연습 횟수, 최근 연습 목록
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.app});
  final AppController app;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final history = app.data.history.reversed.toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        for (final cat in BakeCategory.values) ..._coverage(context, cat),
        const SectionTitle('최근 연습'),
        if (history.isEmpty)
          SectionCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Text('아직 기록이 없어. 과제를 하나 뽑아서 첫 연습을 해봐.', textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
          )
        else ...[
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < history.length; i++)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(border: i > 0 ? Border(top: BorderSide(color: c.line)) : null),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(history[i].name, style: const TextStyle(fontWeight: FontWeight.w500))),
                          _pill(context, history[i].overTime),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          '${formatDate(history[i].date)} · ${formatClock(history[i].usedMs)} / ${history[i].limitMin}분'
                          ' · 체크 ${history[i].checks.where((v) => v).length}/${history[i].checks.length}',
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                        if (history[i].memo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(history[i].memo, style: TextStyle(fontSize: 14, color: c.muted)),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          BigButton('기록 모두 지우기', style: BigButtonStyle.danger, onPressed: () async {
            if (await confirmDialog(context, '연습 기록을 전부 지울까? 되돌릴 수 없어.', ok: '지우기')) app.clearHistory();
          }),
        ],
      ],
    );
  }

  List<Widget> _coverage(BuildContext context, BakeCategory cat) {
    final c = context.colors;
    final items = itemsOf(cat);
    final done = items.where((i) => app.countFor(cat, i.id) > 0).length;
    return [
      SectionTitle('${cat.label} 연습 현황 ($done/${items.length})', padding: const EdgeInsets.only(top: 6, bottom: 8)),
      GridView.extent(
        maxCrossAxisExtent: 130,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.6,
        children: [
          for (final it in items)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: c.paper,
                border: Border.all(color: c.line),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${app.countFor(cat, it.id)}',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: app.countFor(cat, it.id) > 0 ? c.ink : c.alarm)),
                  Expanded(
                    child: Text(it.name, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis, maxLines: 2),
                  ),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _pill(BuildContext context, bool over) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: over ? c.alarmSoft : c.okSoft, borderRadius: BorderRadius.circular(999)),
      child: Text(over ? '시간 초과' : '시간 내', style: TextStyle(fontSize: 12, color: over ? c.alarm : c.ok)),
    );
  }
}
