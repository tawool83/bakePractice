import 'package:flutter/material.dart';

import '../data/step_guide.dart';
import '../models/bake_item.dart';
import '../models/practice.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/step_detail.dart';
import '../widgets/steps_list.dart';
import '../widgets/timer_dial.dart';

/// 연습 중: 남은 시간 다이얼, 계량 시간, 공정 단계 체크
class RunScreen extends StatelessWidget {
  const RunScreen({super.key, required this.app, required this.session, required this.item});
  final AppController app;
  final PracticeSession session;
  final BakeItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors, a = session;
    final ci = a.currentIndex;

    // 단계별 걸린 시간
    final times = <String>[];
    var prev = 0;
    for (final s in a.steps) {
      if (s.done) {
        times.add(formatClock(s.atMs! - prev));
        prev = s.atMs!;
      } else {
        times.add('');
      }
    }
    final recipe = parseRecipe(app.recipeOf(a.category, a.itemId));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(item.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              ValueListenableBuilder<int>(
                valueListenable: app.now,
                builder: (context, now, _) => _clockSection(context, now),
              ),
              if (a.isPaused)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('일시정지됨', textAlign: TextAlign.center, style: TextStyle(color: c.crust, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 8),
              Text('단계를 누르면 방법이 펼쳐져.', style: TextStyle(fontSize: 13, color: c.muted)),
              const SizedBox(height: 6),
              SectionCard(
                padding: EdgeInsets.zero,
                child: StepsList(
                  steps: [for (final s in a.steps) s.name],
                  openIndex: a.openIndex,
                  onToggle: app.toggleStepOpen,
                  stateOf: (i) => a.steps[i].done ? StepMark.done : (i == ci ? StepMark.current : StepMark.todo),
                  timeOf: (i) => times[i],
                  detailBuilder: (i) => StepDetail(
                    stepName: a.steps[i].name,
                    category: a.category,
                    recipe: recipe,
                    weighed: a.weighed,
                    onWeighed: app.toggleWeighed,
                  ),
                ),
              ),
              Row(children: [
                Expanded(child: BigButton('한 단계 되돌리기', onPressed: a.steps.first.done ? app.undoStep : null)),
                const SizedBox(width: 8),
                Expanded(child: BigButton(a.isPaused ? '다시 시작' : '일시정지', onPressed: app.togglePause)),
              ]),
              const SizedBox(height: 8),
              BigButton('연습 끝내기', style: BigButtonStyle.danger, onPressed: () async {
                if (await confirmDialog(context, '지금까지 기록으로 연습을 끝낼까?', ok: '끝내기')) app.finishNow();
              }),
              const SizedBox(height: 14),
              SectionCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text('이 품목 주의할 점', style: TextStyle(color: c.muted, fontSize: 15)),
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [BulletList(item.tips)],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (ci >= 0)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: SizedBox(
                width: double.infinity,
                child: BigButton('「${a.steps[ci].name}」 완료', style: BigButtonStyle.accent, onPressed: app.completeStep),
              ),
            ),
          ),
      ],
    );
  }

  Widget _clockSection(BuildContext context, int now) {
    final c = context.colors, a = session;
    final t = now == 0 ? app.nowMs() : now;
    final el = a.elapsedMs(t), rem = a.limitMs - el;
    final weighRem = a.weighMin * 60000 - el;
    return Column(
      children: [
        Center(
          child: TimerDial(
            fraction: rem / a.limitMs,
            timeText: formatClock(rem),
            subText: '경과 ${formatClock(el)} · 제한 ${a.totalMin}분',
            over: rem < 0,
          ),
        ),
        if (!a.weighingDone)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: weighRem < 0 ? c.alarmSoft : c.crustSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: weighRem < 0 ? c.alarm : c.crust, fontWeight: FontWeight.w500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('계량 남은 시간'),
                  Text(formatClock(weighRem),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
