/* 연습 세션: 경과 시간 계산, 세션 시작, 현재 단계 */
function elapsed(a){const now=Date.now();return now-a.startAt-a.pausedMs-(a.pauseStart?now-a.pauseStart:0);}
function startSession(cat,id){
  const it=findItem(cat,id),t=timesFor(cat,id);
  S.active={cat,itemId:id,startAt:Date.now(),pausedMs:0,pauseStart:null,totalMin:t.total,weighMin:t.weigh,
    steps:it.steps.map(n=>({name:n,at:null})),fired:[],open:0,weighed:[]};
  S.view='run';save();initAudio();wake();render();
}
function curIdx(a){return a.steps.findIndex(s=>s.at===null);}

