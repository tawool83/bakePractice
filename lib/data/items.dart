// 품목 데이터: 제과·제빵 공개 품목, 공정 단계, 주의할 점.
// 품목 추가·수정은 이 파일에서 한다.
// 단계 이름을 바꾸면 step_guide.dart의 정규식 매칭도 함께 확인할 것.

import '../models/bake_item.dart';

const String kWeighStep = '재료 계량';
const List<String> _end = ['제출', '정리·청소'];
const String _prep = '틀·유산지 준비, 오븐 예열';

const List<BakeItem> pastryItems = [
  BakeItem(
    id: 'pound', name: '파운드케이크', method: '크림법', difficulty: 3,
    steps: [kWeighStep, _prep, '버터 풀고 설탕·소금 넣어 크림화', '계란 조금씩 넣으며 크림화', '가루 섞기', '비중 측정·기록', '팬닝', '굽기 (껍질 생기면 가운데 칼집)', ..._end],
    tips: ['반죽기 사용이 허용되는 품목', '굽다가 껍질이 생길 때 가운데를 갈라 줘야 모양이 잡혀'],
  ),
  BakeItem(
    id: 'brownie', name: '브라우니', method: '1단계 변형 반죽법', difficulty: 1,
    steps: [kWeighStep, '원형 유산지 재단, 오븐 예열', '견과류 미리 굽기', '초콜릿·버터 중탕으로 녹이기', '계란·설탕 섞기', '초콜릿 혼합 후 가루 섞기', '견과류 넣고 빠르게 팬닝', '굽기', ..._end],
    tips: ['초콜릿 온도가 너무 높지 않게 관리', '마지막 팬닝이 늦으면 반죽이 굳어버려', '견과류 전처리 잊지 말기'],
  ),
  BakeItem(
    id: 'fruit', name: '과일케이크', method: '크림법 + 별립법', difficulty: 4,
    steps: [kWeighStep, _prep, '과일·견과 전처리 (체리 썰고 물기 제거)', '버터 크림화, 노른자 넣기', '흰자 머랭 만들기', '머랭·가루·과일 섞기', '팬닝', '굽기', ..._end],
    tips: ['체리 물기를 충분히 빼야 반죽이 붉게 물들지 않아', '잘랐을 때 과일이 고르게 퍼져 있어야 감점이 적어', '본반죽이 되직해서 머랭 섞기가 까다로워'],
  ),
  BakeItem(
    id: 'spongeA', name: '버터스펀지케이크 (공립법)', method: '공립법', difficulty: 3,
    steps: [kWeighStep, _prep, '전란·설탕 중탕하며 휘핑 (과열 주의)', '가루 섞기', '녹인 버터 섞기', '비중 측정·기록', '팬닝', '굽기', ..._end],
    tips: ['중탕할 때 계란이 익지 않게 온도계로 확인', '가루를 너무 세게 섞으면 거품이 꺼지고 비중은 되돌릴 수 없어'],
  ),
  BakeItem(
    id: 'spongeB', name: '버터스펀지케이크 (별립법)', method: '별립법', difficulty: 3,
    steps: [kWeighStep, _prep, '노른자 반죽 만들기', '흰자 머랭 만들기', '머랭·가루 나눠 섞기', '녹인 버터 섞기', '비중 측정·기록', '팬닝', '굽기', ..._end],
    tips: ['계란 분리할 때 노른자가 섞이지 않게', '머랭 덩어리가 남으면 속에 기포 구멍이 생겨'],
  ),
  BakeItem(
    id: 'jelly', name: '젤리롤케이크', method: '공립법', difficulty: 3,
    steps: [kWeighStep, _prep, '전란·설탕 중탕하며 휘핑', '가루 섞기', '비중 측정·기록', '팬닝', '굽기', '시트에 잼 바르기', '말기', ..._end],
    tips: ['말 때 시트가 터지면 감점', '유산지 떼는 과정도 조심'],
  ),
  BakeItem(
    id: 'softroll', name: '소프트롤케이크', method: '별립법', difficulty: 3,
    steps: [kWeighStep, _prep, '노른자 반죽 만들기', '흰자 머랭 만들기', '머랭·가루 섞기', '비중 측정·기록', '팬닝', '굽기', '시트에 잼 바르기', '말기', ..._end],
    tips: ['충전물은 잼', '머랭과 반죽을 고르게 섞되 거품이 꺼지지 않게'],
  ),
  BakeItem(
    id: 'chiffon', name: '시퐁케이크', method: '시퐁법', difficulty: 3,
    steps: [kWeighStep, '시퐁 틀에 물 분무, 오븐 예열', '노른자 반죽 (식용유·물 포함)', '흰자 머랭 만들기', '머랭 섞기', '비중 측정·기록', '팬닝', '굽기', '충분히 식힌 뒤 틀에서 분리', ..._end],
    tips: ['유산지 없이 굽고 손으로 떼어내야 해', '가루·유지 넣는 타이밍이 다른 스펀지류보다 빨라', '식히는 시간이 촉박하니 역산해서 계획'],
  ),
  BakeItem(
    id: 'heukmi', name: '흑미롤케이크', method: '공립법', difficulty: 5,
    steps: [kWeighStep, _prep, '전란·설탕 중탕하며 휘핑', '쌀가루 섞기', '비중 측정·기록', '팬닝', '굽기', '생크림 손으로 휘핑', '미지근할 때 크림 바르고 말기', ..._end],
    tips: ['현행 최고 난이도. 시트가 찢어지면 실격', '너무 뜨겁거나 차가울 때 말면 잘 찢어져', '힘을 빼고 말고, 면포에 물을 넉넉히', '생크림은 기계 없이 단단하게 휘핑'],
  ),
  BakeItem(
    id: 'tart', name: '타르트', method: '크림법', difficulty: 4,
    steps: [kWeighStep, '타르트 반죽 만들기 (크림법)', '반죽 냉장 휴지', '충전물 만들기 (크림법), 오븐 예열', '반죽 밀어 틀에 깔기', '충전물 채우고 토핑', '굽기', ..._end],
    tips: ['크림법을 두 번 해야 해서 체력 소모가 커', '반죽은 글루텐이 덜 생기게 최소한으로 치대기'],
  ),
  BakeItem(
    id: 'buttercookie', name: '버터쿠키', method: '크림법', difficulty: 2,
    steps: [kWeighStep, '팬 준비, 오븐 예열', '버터 크림화 (수작업)', '계란 넣고 가루 섞기', '짤주머니로 모양 짜기 (장미형·8자형)', '굽기', ..._end],
    tips: ['기계 사용 불가, 손으로만', '짤주머니를 오래 쥐면 손 열로 버터가 녹아', '실패한 모양은 반죽에 다시 넣고 짜도 돼', '크기가 균일해야 해'],
  ),
  BakeItem(
    id: 'muffin', name: '초코머핀', method: '크림법', difficulty: 2,
    steps: [kWeighStep, '머핀틀 준비, 오븐 예열', '버터 크림화, 계란 조금씩', '가루·초코칩 섞기', '균일하게 팬닝', '굽기', ..._end],
    tips: ['초코칩이 고르게 퍼지고 윗면이 갈라지면 좋아', '팬닝 양을 일정하게'],
  ),
  BakeItem(
    id: 'shortbread', name: '쇼트브레드쿠키', method: '크림법', difficulty: 4,
    steps: [kWeighStep, '버터 크림화, 계란 넣기', '가루 섞어 반죽', '반죽 냉장 휴지, 오븐 예열', '밀어 펴고 쿠키틀로 찍기', '계란물 바르고 포크 무늬', '굽기', ..._end],
    tips: ['손 열로 버터가 녹지 않게 빠르게', '남는 반죽을 최소로, 덧가루는 적당히', '포크 무늬까지 채점 대상'],
  ),
  BakeItem(
    id: 'choux', name: '슈', method: '호화법', difficulty: 3,
    steps: [kWeighStep, '팬 준비, 오븐 예열', '물·버터·소금 끓이기', '밀가루 넣고 호화', '계란으로 되기 조절', '짜기 (팬닝)', '물 분무', '굽기 (아랫불 먼저 세게)', ..._end],
    tips: ['공정은 단순한데 반죽 상태 판단이 전부', '굽는 중간에 오븐 문 열지 않기', '부풀어 갈라지고 속이 비어야 성공'],
  ),
  BakeItem(
    id: 'madeleine', name: '마드레느', method: '1단계 변형 반죽법', difficulty: 1,
    steps: [kWeighStep, '틀에 버터·밀가루 칠, 오븐 예열', '가루·설탕에 계란 섞기', '녹인 버터 식혀 섞기, 레몬 제스트', '반죽 휴지', '균일하게 팬닝', '굽기', ..._end],
    tips: ['쉬운 대신 크기 균일이 득점 포인트', '배꼽이 잘 올라오면 좋아'],
  ),
  BakeItem(
    id: 'dacquoise', name: '다쿠와즈', method: '머랭법', difficulty: 3,
    steps: [kWeighStep, '팬·틀 준비, 오븐 예열', '단단한 머랭 만들기', '아몬드가루·분당 섞기', '짜기', '분당 뿌리기 (여러 번)', '굽기', '식힌 뒤 버터크림 샌드', ..._end],
    tips: ['머랭을 단단하게', '표면이 갈라지도록 분당을 여러 번 고르게'],
  ),
  BakeItem(
    id: 'madeira', name: '마데라컵케이크', method: '크림법', difficulty: 2,
    steps: [kWeighStep, '머핀틀 준비, 오븐 예열', '호두 굽기·건포도 전처리', '버터 크림화, 계란 조금씩', '가루·과일 섞기', '균일하게 팬닝', '굽기', '퐁당 바르고 추가로 굽기', ..._end],
    tips: ['충전물이 고르게 퍼져야 해', '퐁당 바르는 타이밍 놓치지 않기'],
  ),
  BakeItem(
    id: 'cheese', name: '치즈케이크', method: '크림법 + 별립법', difficulty: 2,
    steps: [kWeighStep, '비중컵에 버터·설탕 코팅, 오븐 예열', '버터·크림치즈 크림화, 노른자 넣기', '우유·럼·레몬즙 넣기', '약한 흰자 머랭 만들기', '머랭·가루 섞기', '비중 측정·기록', '팬닝', '중탕으로 굽기', ..._end],
    tips: ['머랭은 약하게. 세게 치면 과하게 부풀어', '시험장에 따라 흰자를 손으로 쳐야 할 수도 있어', '제출할 때 컵에서 깨끗하게 빠져야 해'],
  ),
  BakeItem(
    id: 'walnut', name: '호두파이', method: '블렌딩법', difficulty: 4,
    steps: [kWeighStep, '파이 반죽 (찬 버터를 가루에 섞기)', '반죽 냉장 휴지', '호두 굽기, 오븐 예열', '충전물 만들고 거품 가라앉히기', '반죽 밀어 틀에 깔고 가장자리 성형', '호두·충전물 채우기', '굽기', ..._end],
    tips: ['충전물 거품이 남으면 구울 때 부풀어 터져', '충전물이 넘치거나 흐르지 않게'],
  ),
  BakeItem(
    id: 'chocoroll', name: '초코롤케이크', method: '공립법', difficulty: 3,
    steps: [kWeighStep, _prep, '전란·설탕 중탕하며 휘핑', '가루·코코아 섞기 (뭉침 주의)', '녹인 버터·우유 섞기', '비중 측정·기록', '팬닝', '굽기', '가나슈 만들기', '가나슈 바르고 말기', ..._end],
    tips: ['코코아가 뭉치기 쉬우니 체 쳐서 고르게', '말 때 시트가 터지지 않게'],
  ),
];

/// 제빵 공통 공정. 품목마다 다른 부분만 끼워 넣는다.
List<String> breadSteps({
  List<String> pre = const [],
  String shape = '성형',
  List<String> shape2 = const [],
  List<String> post = const [],
  String bake = '굽기',
  List<String> after = const [],
}) =>
    [
      kWeighStep, '반죽 (반죽온도 측정)', '1차 발효',
      ...pre,
      '분할', '둥글리기', '중간 발효', shape,
      ...shape2,
      '팬닝', '2차 발효',
      ...post,
      bake,
      ...after,
      ..._end,
    ];

final List<BakeItem> breadItems = [
  BakeItem(id: 'plain', name: '식빵 (비상스트레이트법)', method: '비상스트레이트법', difficulty: 1,
      steps: breadSteps(shape: '성형 (삼봉형)'), tips: const ['비상스트레이트법 조건(반죽온도·발효)은 문제지 요구사항대로', '반죽만 잘 나오면 가장 무난한 편']),
  BakeItem(id: 'milk', name: '우유식빵', method: '스트레이트법', difficulty: 1,
      steps: breadSteps(shape: '성형 (삼봉형)'), tips: const ['토핑 없는 식빵류라 반죽 상태와 공정 순서가 핵심']),
  BakeItem(id: 'rice', name: '쌀식빵', method: '스트레이트법', difficulty: 1,
      steps: breadSteps(shape: '성형'), tips: const ['토핑 없는 식빵류, 반죽 상태에 집중']),
  BakeItem(id: 'pullman', name: '풀만식빵', method: '스트레이트법', difficulty: 1,
      steps: breadSteps(shape: '성형 후 뚜껑 있는 틀에 넣기'), tips: const ['뚜껑 달린 틀에서 육면체 모양을 내는 게 목표']),
  BakeItem(id: 'butterroll', name: '버터롤', method: '스트레이트법', difficulty: 2,
      steps: breadSteps(shape: '번데기 모양 성형'), tips: const ['성형 크기와 모양을 일정하게']),
  BakeItem(id: 'twist', name: '단과자빵 (트위스트형)', method: '스트레이트법', difficulty: 2,
      steps: breadSteps(shape: '8자형 등 꼬기 성형'), tips: const ['8자형은 연습량이 많이 필요해', '모양이 일정해야 해']),
  BakeItem(id: 'bagel', name: '베이글', method: '스트레이트법', difficulty: 2,
      steps: breadSteps(shape: '링 모양 성형 (구멍 넉넉히)', post: ['끓는 물에 데치기']),
      tips: const ['구멍을 작게 만들면 구울 때 막혀서 감점', '데칠 때 유산지를 빨리 떼고 앞면이 위로 오게']),
  BakeItem(id: 'grissini', name: '그리시니', method: '스트레이트법', difficulty: 3,
      steps: breadSteps(shape: '가늘고 길게 밀어 성형'),
      tips: const ['제출 개수가 가장 많고 시간이 짧아 타임오버가 잦아', '오븐 공간이 부족하면 나눠서 발효·굽기 계획을 미리 짜기']),
  BakeItem(id: 'rye', name: '호밀빵', method: '스트레이트법', difficulty: 3,
      steps: breadSteps(post: ['칼집 내기']), tips: const ['칼집 모양이 중요해']),
  BakeItem(id: 'wholewheat', name: '통밀빵', method: '스트레이트법', difficulty: 3,
      steps: breadSteps(shape: '성형 후 오트밀 묻히기'), tips: const ['오트밀을 붙인 채로 발효']),
  BakeItem(id: 'buttertop', name: '버터톱식빵', method: '스트레이트법', difficulty: 3,
      steps: breadSteps(shape: '성형', post: ['윗면 칼집 내고 버터 짜기']),
      tips: const ['반죽이 질어서 덧가루를 잘 써야 해', '표면이 울퉁불퉁하면 구운 모양에 그대로 나와']),
  BakeItem(id: 'mocha', name: '모카빵', method: '스트레이트법', difficulty: 4,
      steps: breadSteps(pre: ['토핑 쿠키 반죽 만들기 (크림법)'], shape: '성형 (건포도 고르게)', shape2: ['토핑 반죽 밀어 덮기']),
      tips: const ['토핑 반죽은 휴지 후 덧가루를 넉넉히', '토핑이 바닥까지 닿으면 감점되기 쉬워']),
  BakeItem(id: 'soboro', name: '단과자빵 (소보로빵)', method: '스트레이트법', difficulty: 4,
      steps: breadSteps(pre: ['소보로 토핑 만들기'], shape: '둥글게 성형', shape2: ['물 묻혀 토핑 묻히기']),
      tips: const ['토핑이 고르게, 떨어지지 않게 붙이기']),
  BakeItem(id: 'sausage', name: '소시지빵', method: '스트레이트법', difficulty: 4,
      steps: breadSteps(pre: ['속재료 준비 (양파 썰기 등)'], shape: '소시지 감싸고 자르기 (잎·꽃 모양)', post: ['토핑 올리기']),
      tips: const ['자를 때 끝을 조금 남기고 포개기', '발효 중 소시지가 튀어나오지 않게']),
  BakeItem(id: 'chestnut', name: '밤식빵', method: '스트레이트법', difficulty: 4,
      steps: breadSteps(pre: ['토핑 준비'], shape: '밤 넣고 말아 성형', post: ['토핑 올리기']),
      tips: const ['토핑 양 조절에 실패하면 배분이 틀어져']),
  BakeItem(id: 'cream', name: '단과자빵 (크림빵)', method: '스트레이트법', difficulty: 4,
      steps: breadSteps(pre: ['충전물 준비'], shape: '크림 넣고 성형·칼집'),
      tips: const ['굽다가 크림이 새면 사실상 불합격', '성형 공정이 많아 시간에 쫓기기 쉬워']),
  BakeItem(id: 'redbean', name: '단팥빵 (비상스트레이트법)', method: '비상스트레이트법', difficulty: 4,
      steps: breadSteps(shape: '팥앙금 싸서 성형'), tips: const ['봉합을 확실히 해서 앙금이 새지 않게']),
  BakeItem(id: 'corn', name: '옥수수식빵', method: '스트레이트법', difficulty: 5,
      steps: breadSteps(shape: '성형 (삼봉형)'), tips: const ['반죽이 매우 질어서 난이도가 높아', '덧가루는 필요한 만큼만, 반죽이 찢어지지 않게']),
  BakeItem(id: 'donut', name: '빵도넛', method: '스트레이트법', difficulty: 5,
      steps: breadSteps(shape: '8자형·꽈배기형 성형', bake: '튀기기'),
      tips: const ['튀기는 시간을 꼭 남겨두기, 시간 배분 실패가 흔해', '튀기다 성형이 풀리지 않게']),
  BakeItem(id: 'sweetroll', name: '스위트롤', method: '스트레이트법', difficulty: 5,
      steps: breadSteps(shape: '밀어 펴고 계피설탕 뿌려 말기', shape2: ['잎 모양 등으로 자르기']),
      tips: const ['늘려가며 말다가 찢어지기 쉬워', '2차 발효가 길어지면 말린 부분이 튀어나와']),
];

List<BakeItem> itemsOf(BakeCategory cat) => cat == BakeCategory.pastry ? pastryItems : breadItems;

BakeItem? findItem(BakeCategory cat, String id) {
  for (final it in itemsOf(cat)) {
    if (it.id == id) return it;
  }
  return null;
}

/// 품목별 기본 시험시간(분). 큐넷 공개문제 기준으로 채워 나갈 것.
int defaultTotalMinutes(BakeCategory cat, String id) =>
    cat == BakeCategory.bread && id == 'grissini' ? 150 : 180;

const int defaultWeighMinutes = 10;
