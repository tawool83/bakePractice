import 'package:flutter/material.dart';

import '../theme.dart';

/// 흰 배경의 둥근 카드
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Material로 감싸야 안쪽 InkWell·ListTile의 터치 효과가 보인다
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: c.paper,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(side: BorderSide(color: c.line), borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: padding,
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// 회색 소제목
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.padding = const EdgeInsets.only(bottom: 8)});
  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Text(text, style: TextStyle(fontSize: 15, color: context.colors.muted, fontWeight: FontWeight.w500)),
      );
}

/// 난이도 점 5개
class DifficultyDots extends StatelessWidget {
  const DifficultyDots(this.level, {super.key});
  final int level;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '난이도 $level/5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(shape: BoxShape.circle, color: i <= level ? c.crust : c.line),
            ),
        ],
      ),
    );
  }
}

/// 점 목록 (주의할 점, 단계 설명)
class BulletList extends StatelessWidget {
  const BulletList(this.lines, {super.key, this.fontSize = 15});
  final List<String> lines;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: TextStyle(fontSize: fontSize)),
                  Expanded(child: Text(l, style: TextStyle(fontSize: fontSize, height: 1.45))),
                ],
              ),
            ),
        ],
      );
}

/// 가로 꽉 찬 큰 버튼. [style]: primary(진한 색), accent(갈색), ghost(테두리), danger(빨간 글씨)
enum BigButtonStyle { primary, accent, ghost, danger }

class BigButton extends StatelessWidget {
  const BigButton(this.label, {super.key, required this.onPressed, this.style = BigButtonStyle.ghost});
  final String label;
  final VoidCallback? onPressed;
  final BigButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const pad = EdgeInsets.symmetric(vertical: 16, horizontal: 12);
    final text = Text(label, textAlign: TextAlign.center);
    switch (style) {
      case BigButtonStyle.primary:
      case BigButtonStyle.accent:
        final bg = style == BigButtonStyle.primary ? c.ink : c.crust;
        final fg = style == BigButtonStyle.primary ? c.paper : Colors.white;
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg, foregroundColor: fg, shape: shape, padding: pad,
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          child: text,
        );
      case BigButtonStyle.ghost:
      case BigButtonStyle.danger:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: style == BigButtonStyle.danger ? c.alarm : c.ink,
            side: BorderSide(color: c.line), shape: shape, padding: pad,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          child: text,
        );
    }
  }
}

/// 예/아니요 확인 창
Future<bool> confirmDialog(BuildContext context, String message, {String ok = '확인'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(ok)),
      ],
    ),
  );
  return r ?? false;
}
