import 'package:bake_practice/data/items.dart';
import 'package:bake_practice/data/step_guide.dart';
import 'package:bake_practice/models/bake_item.dart';
import 'package:bake_practice/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('품목 데이터', () {
    test('제과·제빵 각각 20개, id 중복 없음', () {
      for (final cat in BakeCategory.values) {
        final items = itemsOf(cat);
        expect(items, hasLength(20));
        expect(items.map((i) => i.id).toSet(), hasLength(20));
      }
    });

    test('모든 품목은 계량으로 시작해 제출·정리로 끝남', () {
      for (final cat in BakeCategory.values) {
        for (final it in itemsOf(cat)) {
          expect(it.steps.first, kWeighStep, reason: it.name);
          expect(it.steps.sublist(it.steps.length - 2), ['제출', '정리·청소'], reason: it.name);
          expect(it.difficulty, inInclusiveRange(1, 5));
        }
      }
    });

    test('제빵 공통 공정에 품목별 단계가 제자리에 들어감', () {
      final bagel = findItem(BakeCategory.bread, 'bagel')!;
      expect(bagel.steps.indexOf('끓는 물에 데치기'), bagel.steps.indexOf('2차 발효') + 1);
      final donut = findItem(BakeCategory.bread, 'donut')!;
      expect(donut.steps, contains('튀기기'));
      expect(donut.steps, isNot(contains('굽기')));
    });

    test('기본 시험시간: 그리시니만 150분', () {
      expect(defaultTotalMinutes(BakeCategory.bread, 'grissini'), 150);
      expect(defaultTotalMinutes(BakeCategory.pastry, 'pound'), 180);
    });
  });

  group('단계 설명', () {
    test('정규식으로 여러 규칙이 합쳐지고 중복은 제거', () {
      final g = stepGuide('버터·크림치즈 크림화, 노른자 넣기', BakeCategory.pastry);
      expect(g, contains('버터(또는 크림치즈)를 먼저 부드럽게 풀기'));
      expect(g, contains('노른자에 설탕을 넣고 색이 밝아질 때까지 젓기'));
      expect(g.toSet(), hasLength(g.length));
    });

    test('계량 설명은 종목에 따라 다름', () {
      expect(stepGuide(kWeighStep, BakeCategory.bread), contains('이스트와 소금은 서로 닿지 않게 따로 두기'));
      expect(stepGuide(kWeighStep, BakeCategory.pastry), isNot(contains('이스트와 소금은 서로 닿지 않게 따로 두기')));
    });

    test('성형 설명은 제빵에만', () {
      expect(stepGuide('성형 (삼봉형)', BakeCategory.bread), isNotEmpty);
      expect(stepGuide('반죽 밀어 틀에 깔고 가장자리 성형', BakeCategory.pastry), isNot(contains('공개문제의 모양 요구대로')));
    });
  });

  group('배합표·비중', () {
    test('"재료 무게" 형식 파싱', () {
      final r = parseRecipe('강력분 1000g\n설탕: 50 g\n\n  소금 20\n버터 약간');
      expect(r.map((e) => e.name), ['강력분', '설탕', '소금', '버터 약간']);
      expect(r.map((e) => e.amount), ['1000g', '50 g', '20', '']);
    });

    test('비중 계산', () {
      expect(specificGravity(cup: 50, cupWater: 250, cupDough: 210), closeTo(0.8, 1e-9));
      expect(specificGravity(cup: 50, cupWater: 50, cupDough: 210), isNull);
      expect(specificGravity(cup: null, cupWater: 250, cupDough: 210), isNull);
    });
  });

  group('시간 표시', () {
    test('formatClock', () {
      expect(formatClock(0), '00:00');
      expect(formatClock(754000), '12:34');
      expect(formatClock(3909000), '1:05:09');
      expect(formatClock(-190000), '+03:10');
    });

    test('formatMinutes', () {
      expect(formatMinutes(45 * 60000), '45분');
      expect(formatMinutes(125 * 60000), '2시간 5분');
    });
  });
}
