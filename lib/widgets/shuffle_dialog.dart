import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/bake_item.dart';
import '../theme.dart';

/// 품목 이름이 빠르게 바뀌다 [pick]에서 멈추는 추첨 연출. 애니메이션 줄이기 설정이면 건너뛴다.
Future<void> showShuffle(BuildContext context, List<BakeItem> items, BakeItem pick) async {
  if (MediaQuery.of(context).disableAnimations) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ShuffleDialog(items: items, pick: pick),
  );
}

class _ShuffleDialog extends StatefulWidget {
  const _ShuffleDialog({required this.items, required this.pick});
  final List<BakeItem> items;
  final BakeItem pick;

  @override
  State<_ShuffleDialog> createState() => _ShuffleDialogState();
}

class _ShuffleDialogState extends State<_ShuffleDialog> {
  final _rand = Random();
  late String _name = widget.items[_rand.nextInt(widget.items.length)].name;
  Timer? _timer;
  int _n = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 70), (t) {
      if (++_n > 12) {
        t.cancel();
        setState(() => _name = widget.pick.name);
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        setState(() => _name = widget.items[_rand.nextInt(widget.items.length)].name);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      backgroundColor: c.paper,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
        child: Semantics(
          liveRegion: true,
          child: Text(
            _name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: c.crust, letterSpacing: -0.8),
          ),
        ),
      ),
    );
  }
}
