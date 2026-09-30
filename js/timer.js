/* 타이머 갱신: 남은 시간 다이얼, 계량 시간, 30분·10분·종료 알림 */
function tick(){
  const a=S.active;if(!a||S.view!=='run')return;
  const el=elapsed(a),limit=a.totalMin*60000,rem=limit-el;
  const r=$('#remain');if(!r)return;
  r.textContent=fmt(rem);
  $('#elap').textContent='경과 '+fmt(el)+' · 제한 '+a.totalMin+'분';
  const C=2*Math.PI*88,frac=Math.max(0,Math.min(1,rem/limit));
  $('#arc').setAttribute('stroke-dashoffset',String(C*(1-frac)));
  $('#dial').classList.toggle('over',rem<0);
  if(a.steps[0].at===null){const wr=a.weighMin*60000-el;$('#wt').textContent=fmt(wr);$('#weigh').classList.toggle('late',wr<0);
    if(wr<=0&&!a.fired.includes('w')){a.fired.push('w');save();alertUser(1);}}
  [[30,'30'],[10,'10'],[0,'0']].forEach(([m,k])=>{if(rem<=m*60000&&limit>m*60000&&!a.fired.includes(k)){a.fired.push(k);save();alertUser(m===0?2:1);}});
}
