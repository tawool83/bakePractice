import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/step_guide.dart';
import '../models/bake_item.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/step_detail.dart';
import '../widgets/steps_list.dart';
import 'home_screen.dart';

/// 과제 준비: 품목 정보, 시간 설정, 배합표, 공정 미리 보기
class PrepScreen extends StatefulWidget {
  const PrepScreen({super.key, required this.app, required this.item});
  final AppController app;
  final BakeItem item;

  @override
  State<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends State<PrepScreen> {
  late final AppController app = widget.app;
  late final TextEditingController _total, _weigh, _recipe;

  @override
  void initState() {
    super.initState();
    final t = app.timesFor(app.category, widget.item.id);
    _total = TextEditingController(text: '${t.total}');
    _weigh = TextEditingController(text: '${t.weigh}');
    _recipe = TextEditingController(text: app.recipeOf(app.category, widget.item.id));
  }

  @override
  void dispose() {
    _total.dispose();
    _weigh.dispose();
    _recipe.dispose();
    super.dispose();
  }

  void _start() => app.startSession(
        totalMin: int.tryParse(_total.text) ?? 180,
        weighMin: int.tryParse(_weigh.text) ?? 10,
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors, it = widget.item;
    final note = TextStyle(fontSize: 13, color: c.muted);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -1, height: 1.2)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(app.category.label, style: note),
                  Text(it.method, style: note),
                  DifficultyDots(it.difficulty),
                  Text('${app.countFor(app.category, it.id)}회 연습', style: note),
                ],
              ),
              const SizedBox(height: 10),
              BulletList(it.tips),
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: _numberField('시험시간 (분)', _total)),
                const SizedBox(width: 10),
                Expanded(child: _numberField('계량시간 (분)', _weigh)),
              ]),
              const SizedBox(height: 10),
              Text('품목마다 시험시간이 달라. 큐넷 공개문제에 적힌 시간으로 한 번 맞춰두면 다음부터 기억해둘게.', style: note),
              CheckboxListTile(
                value: app.prefs.sound,
                onChanged: (v) => app.setSound(v ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text('알림음 켜기 (진동은 항상)', style: TextStyle(color: c.muted, fontSize: 14)),
              ),
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('배합표'),
              Text('공개문제 배합표를 보고 한 줄에 재료 하나씩 적어둬. 계량 단계에서 체크리스트로 쓸 수 있어.', style: note),
              const SizedBox(height: 8),
              TextField(
                controller: _recipe,
                minLines: 5,
                maxLines: null,
                onChanged: (v) {
                  app.setRecipe(v);
                  setState(() {}); // 미리 보기의 계량 단계 갱신
                },
                decoration: const InputDecoration(hintText: '재료이름 무게\n예) 재료A 000g\n예) 재료B 00g'),
              ),
            ],
          ),
        ),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('공정 미리 보기 (단계를 누르면 설명)', padding: EdgeInsets.fromLTRB(14, 12, 14, 4)),
              StepsList(
                steps: it.steps,
                openIndex: app.prepOpen,
                onToggle: app.togglePrepOpen,
                detailBuilder: (i) => StepDetail(
                  stepName: it.steps[i],
                  category: app.category,
                  recipe: parseRecipe(_recipe.text),
                ),
              ),
            ],
          ),
        ),
        BigButton('연습 시작', onPressed: _start, style: BigButtonStyle.primary),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: BigButton('다시 뽑기', onPressed: () => HomeScreen.draw(context, app))),
          const SizedBox(width: 8),
          Expanded(child: BigButton('목록으로', onPressed: app.goHome)),
        ]),
      ],
    );
  }

  Widget _numberField(String label, TextEditingController ctrl) => TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontFeatures: [FontFeature.tabularFigures()]),
        decoration: InputDecoration(labelText: label),
      );
}
