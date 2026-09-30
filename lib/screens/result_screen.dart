import 'dart:math';

import 'package:flutter/material.dart';

import '../models/bake_item.dart';
import '../models/practice.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// 셀프 체크 항목. 순서를 바꾸면 기존 기록의 체크 해석이 달라지니 뒤에 추가만 할 것
const List<String> kSelfChecks = ['시간 안에 완성', '모양·크기 균일', '굽기 색 적당', '공정 순서 안 틀림', '위생·정리'];

/// 연습 결과: 사용 시간, 단계별 소요 시간, 셀프 체크, 메모
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.app, required this.session, required this.item});
  final AppController app;
  final PracticeSession session;
  final BakeItem item;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final List<bool> _checks;
  final _memo = TextEditingController();

  PracticeSession get a => widget.session;
  int get used => a.endAt ?? 0;
  bool get over => used > a.limitMs;

  @override
  void initState() {
    super.initState();
    final allDone = a.currentIndex < 0;
    _checks = List.generate(kSelfChecks.length, (i) => i == 0 && !over && allDone);
  }

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final durs = a.completedDurations();
    final maxD = durs.isEmpty ? 1 : max(1, durs.map((d) => d.ms).reduce(max));
    final note = TextStyle(fontSize: 13, color: c.muted);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.item.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -1)),
              Text(formatClock(used),
                  style: TextStyle(
                      fontSize: 38, fontWeight: FontWeight.w700, height: 1.1,
                      color: over ? c.alarm : c.ink, fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 4),
              Text.rich(TextSpan(style: note, children: [
                TextSpan(text: '제한 ${a.totalMin}분 중 '),
                over
                    ? TextSpan(text: '${formatMinutes(used - a.limitMs)} 초과', style: TextStyle(color: c.alarm, fontWeight: FontWeight.w700))
                    : TextSpan(text: '${formatMinutes(a.limitMs - used)} 남기고 끝냄'),
                TextSpan(text: ' · 완료 단계 ${durs.length}/${a.steps.length}'),
              ])),
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('단계별 걸린 시간'),
              if (durs.isEmpty) Text('완료한 단계가 없어.', style: note),
              for (final d in durs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(child: Text(d.name, style: const TextStyle(fontSize: 14))),
                        Text(formatClock(d.ms), style: const TextStyle(fontSize: 14, fontFeatures: [FontFeature.tabularFigures()])),
                      ]),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: max(0.03, d.ms / maxD),
                          minHeight: 6,
                          backgroundColor: c.line,
                          color: c.crust,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('스스로 체크'),
              for (var i = 0; i < kSelfChecks.length; i++)
                CheckboxListTile(
                  value: _checks[i],
                  onChanged: (v) => setState(() => _checks[i] = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(kSelfChecks[i], style: const TextStyle(fontSize: 15)),
                ),
              const SizedBox(height: 8),
              Text('메모 (다음에 고칠 점)', style: note),
              const SizedBox(height: 6),
              TextField(
                controller: _memo,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(hintText: '예: 머랭 너무 오래 쳐서 비중 높게 나옴'),
              ),
            ],
          ),
        ),
        BigButton('기록 저장', style: BigButtonStyle.primary,
            onPressed: () => widget.app.saveResult(checks: List.of(_checks), memo: _memo.text)),
        const SizedBox(height: 8),
        BigButton('저장하지 않고 나가기', onPressed: () async {
          if (await confirmDialog(context, '이번 연습 기록을 버릴까?', ok: '버리기')) widget.app.discardResult();
        }),
      ],
    );
  }
}
