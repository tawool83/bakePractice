import 'package:flutter/material.dart';

import '../models/bake_item.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shuffle_dialog.dart';

/// 첫 화면: 종목 선택, 과제 뽑기, 품목 목록
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.app});
  final AppController app;

  static Future<void> draw(BuildContext context, AppController app) async {
    final pick = app.drawItem();
    await showShuffle(context, app.items, pick);
    app.openPrep(pick.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        SegmentedButton<BakeCategory>(
          showSelectedIcon: false,
          segments: [
            for (final cat in BakeCategory.values) ButtonSegment(value: cat, label: Text('${cat.label}기능사')),
          ],
          selected: {app.category},
          onSelectionChanged: (s) => app.setCategory(s.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: c.crustSoft,
            selectedForegroundColor: c.crust,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: c.crust,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => draw(context, app),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘의 과제 뽑기',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                  SizedBox(height: 2),
                  Text('시험처럼 20개 품목 중 하나를 무작위로 골라줘', style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        CheckboxListTile(
          value: app.prefs.fresh,
          onChanged: (v) => app.setFresh(v ?? true),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text('연습 횟수가 적은 품목에서 우선 뽑기', style: TextStyle(color: c.muted, fontSize: 14)),
        ),
        const SizedBox(height: 10),
        const SectionTitle('품목 직접 고르기'),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < app.items.length; i++) _itemRow(context, app.items[i], i > 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemRow(BuildContext context, BakeItem it, bool divider) {
    final c = context.colors;
    final n = app.countFor(app.category, it.id);
    return Container(
      decoration: BoxDecoration(border: divider ? Border(top: BorderSide(color: c.line)) : null),
      child: InkWell(
        onTap: () => app.openPrep(it.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(it.method, style: TextStyle(fontSize: 13, color: c.muted)),
                  ],
                ),
              ),
              DifficultyDots(it.difficulty),
              const SizedBox(width: 10),
              SizedBox(
                width: 42,
                child: Text(
                  n > 0 ? '$n회' : '미연습',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12.5, color: n > 0 ? c.muted : c.alarm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
