/* 이벤트 처리와 앱 시작 */
/* 과제 뽑기 (셔플 애니메이션 후 준비 화면으로) */
function draw(){
  const items=CATS[S.cat].items;let pool=items;
  if(S.prefs.fresh){const mn=Math.min(...items.map(i=>countFor(S.cat,i.id)));pool=items.filter(i=>countFor(S.cat,i.id)===mn);}
  const pick=pool[Math.floor(Math.random()*pool.length)];
  const reduce=window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if(reduce){S.prepId=pick.id;S.prepOpen=null;S.view='prep';save();render();return;}
  $('#app').innerHTML='<div class="card shuffle" id="sh" aria-live="polite"></div>';
  let n=0;const iv=setInterval(()=>{const r=items[Math.floor(Math.random()*items.length)];$('#sh').textContent=r.name;
    if(++n>12){clearInterval(iv);$('#sh').textContent=pick.name;setTimeout(()=>{S.prepId=pick.id;S.prepOpen=null;S.view='prep';save();render();},450);}},70);
}
document.addEventListener('click',e=>{
  const t=e.target.closest('[data-tab],[data-act]');if(!t)return;
  if(t.dataset.tab){if(S.active&&S.active.endAt===undefined){S.view='run';}else{S.view=t.dataset.tab;}save();render();return;}
  const act=t.dataset.act;
  if(act==='cat'){S.cat=t.dataset.cat;save();render();}
  else if(act==='draw'){draw();}
  else if(act==='pick'){S.prepId=t.dataset.id;S.prepOpen=null;S.view='prep';save();render();}
  else if(act==='home'){S.view='home';save();render();}
  else if(act==='open'){const i=+t.dataset.i;
    if(S.view==='run'){S.active.open=S.active.open===i?null:i;}else{S.prepOpen=S.prepOpen===i?null:i;}save();render(true);}
  else if(act==='start'){
    const tt=Math.max(30,Math.min(300,parseInt($('#tt').value)||180)),tw=Math.max(1,Math.min(30,parseInt($('#tw').value)||10));
    S.prefs.times[S.cat+':'+S.prepId]={total:tt,weigh:tw};startSession(S.cat,S.prepId);}
  else if(act==='next'){const a=S.active,i=curIdx(a);if(i<0)return;a.steps[i].at=elapsed(a);
    if(curIdx(a)<0){a.endAt=elapsed(a);S.view='result';unwake();}else{a.open=curIdx(a);}save();render(S.view==='run');
    if(S.view==='run'){const c=document.querySelector('li.cur');c&&c.scrollIntoView({block:'center',behavior:window.matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth'});}}
  else if(act==='undo'){const a=S.active;let i=curIdx(a);i=i<0?a.steps.length-1:i-1;if(i>=0){a.steps[i].at=null;save();render();}}
  else if(act==='pause'){const a=S.active;if(a.pauseStart){a.pausedMs+=Date.now()-a.pauseStart;a.pauseStart=null;wake();}else{a.pauseStart=Date.now();unwake();}save();render();}
  else if(act==='finish'){if(confirm('지금까지 기록으로 연습을 끝낼까?')){const a=S.active;a.endAt=elapsed(a);if(a.pauseStart){a.pausedMs+=Date.now()-a.pauseStart;a.pauseStart=null;}S.view='result';unwake();save();render();}}
  else if(act==='saveRes'){const a=S.active,it=findItem(a.cat,a.itemId);let prev=0;
    S.history.push({date:Date.now(),cat:a.cat,itemId:a.itemId,name:it.name,limitMin:a.totalMin,usedMs:a.endAt,
      steps:a.steps.filter(s=>s.at!==null).map(s=>{const d=s.at-prev;prev=s.at;return {name:s.name,d};}),
      checks:[...document.querySelectorAll('.ck')].map(c=>c.checked),memo:$('#memo').value.trim()});
    S.active=null;S.view='history';save();render();}
  else if(act==='discard'){if(confirm('이번 연습 기록을 버릴까?')){S.active=null;S.view='home';save();render();}}
  else if(act==='clear'){if(confirm('연습 기록을 전부 지울까? 되돌릴 수 없어.')){S.history=[];save();render();}}
});
document.addEventListener('input',e=>{
  const el=e.target;
  if(el.dataset.act==='recipe'){S.prefs.recipes=S.prefs.recipes||{};S.prefs.recipes[S.cat+':'+S.prepId]=el.value;save();}
  if(el.dataset.bj){const box=el.closest('.sd'),v=k=>parseFloat(box.querySelector('[data-bj="'+k+'"]').value);
    const c=v('c'),w=v('w'),d=v('d'),out=box.querySelector('.bjout');
    out.textContent=(isFinite(c)&&isFinite(w)&&isFinite(d)&&w>c)?'비중 '+((d-c)/(w-c)).toFixed(2):'비중 -';}
});
document.addEventListener('change',e=>{
  if(e.target.dataset.wi!==undefined&&S.active){const i=+e.target.dataset.wi;S.active.weighed=S.active.weighed||[];S.active.weighed[i]=e.target.checked;save();render(true);return;}
  const act=e.target.dataset.act;
  if(act==='fresh'){S.prefs.fresh=e.target.checked;save();}
  if(act==='sound'){S.prefs.sound=e.target.checked;save();if(e.target.checked)initAudio();}
});

setInterval(tick,250);
if(S.active&&!S.active.pauseStart&&S.active.endAt===undefined)wake();
render();
