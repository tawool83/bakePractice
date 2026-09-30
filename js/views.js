/* 화면 렌더링: 홈, 과제 준비, 연습 중, 결과, 기록 */
function setTabs(){document.querySelectorAll('#tabs button').forEach(b=>{
  const on=(b.dataset.tab==='history')===(S.view==='history');b.setAttribute('aria-current',on?'true':'false');});}

function viewHome(){
  const items=CATS[S.cat].items;
  return `
  <div class="seg" role="group" aria-label="종목">
    ${Object.entries(CATS).map(([k,v])=>`<button data-act="cat" data-cat="${k}" aria-pressed="${S.cat===k}">${v.label}기능사</button>`).join('')}
  </div>
  <button class="draw" data-act="draw"><strong>오늘의 과제 뽑기</strong><span>시험처럼 20개 품목 중 하나를 무작위로 골라줘</span></button>
  <label class="opt"><input type="checkbox" data-act="fresh" ${S.prefs.fresh?'checked':''}> 연습 횟수가 적은 품목에서 우선 뽑기</label>
  <h2>품목 직접 고르기</h2>
  <div class="list">
    ${items.map(it=>{const c=countFor(S.cat,it.id);return `<button class="row" data-act="pick" data-id="${it.id}">
      <span><span class="nm">${esc(it.name)}</span><br><span class="mt">${esc(it.m)}</span></span>
      <span class="right">${dots(it.d)}<span class="cnt ${c?'':'zero'}">${c?c+'회':'미연습'}</span></span></button>`;}).join('')}
  </div>`;
}

function viewPrep(){
  const it=findItem(S.cat,S.prepId),t=timesFor(S.cat,it.id);
  return `
  <div class="card">
    <p class="item-title">${esc(it.name)}</p>
    <div class="meta"><span>${CATS[S.cat].label}</span><span>${esc(it.m)}</span>${dots(it.d)}<span>${countFor(S.cat,it.id)}회 연습</span></div>
    <ul class="tips">${it.tips.map(x=>`<li>${esc(x)}</li>`).join('')}</ul>
  </div>
  <div class="card">
    <div class="fields">
      <div class="field"><label for="tt">시험시간 (분)</label><input id="tt" type="number" inputmode="numeric" min="30" max="300" value="${t.total}"></div>
      <div class="field"><label for="tw">계량시간 (분)</label><input id="tw" type="number" inputmode="numeric" min="1" max="30" value="${t.weigh}"></div>
    </div>
    <p class="note">품목마다 시험시간이 달라. 큐넷 공개문제에 적힌 시간으로 한 번 맞춰두면 다음부터 기억해둘게.</p>
    <label class="opt" style="margin:12px 0 0"><input type="checkbox" data-act="sound" ${S.prefs.sound?'checked':''}> 알림음 켜기 (진동은 항상)</label>
  </div>
  <div class="card recipe">
    <h2>배합표</h2>
    <p class="note" style="margin:0 0 8px">공개문제 배합표를 보고 한 줄에 재료 하나씩 적어둬. 계량 단계에서 체크리스트로 쓸 수 있어.</p>
    <textarea id="recipe" data-act="recipe" placeholder="재료이름 무게&#10;예) 재료A 000g&#10;예) 재료B 00g">${esc(recipeOf(S.cat,it.id))}</textarea>
  </div>
  <div class="card" style="padding:4px 0;overflow:hidden">
    <h2 style="padding:12px 14px 0">공정 미리 보기 <span style="font-size:.8rem">(단계를 누르면 설명)</span></h2>
    ${stepsList(it.steps,S.prepOpen,S.cat,it.id,false)}
  </div>
  <div class="btns">
    <button class="btn primary" data-act="start">연습 시작</button>
    <div class="btns two" style="margin:0"><button class="btn ghost" data-act="draw">다시 뽑기</button><button class="btn ghost" data-act="home">목록으로</button></div>
  </div>`;
}

function viewRun(){
  const a=S.active,it=findItem(a.cat,a.itemId),ci=curIdx(a);
  const tms=[];let prev=0;a.steps.forEach(s=>{if(s.at!==null){tms.push(fmt(s.at-prev));prev=s.at;}else tms.push('');});
  const rows=stepsList(a.steps.map(s=>s.name),a.open,a.cat,a.itemId,true,i=>({cls:a.steps[i].at!==null?'done':(i===ci?'cur':''),tm:tms[i]}));
  const r=88,C=2*Math.PI*r;
  return `
  <p class="run-name">${esc(it.name)}</p>
  <div class="dialbox" id="dial">
    <svg viewBox="0 0 200 200" aria-hidden="true">
      <circle class="dial-bg" cx="100" cy="100" r="${r}" fill="none" stroke-width="10"/>
      <circle class="dial-fg" id="arc" cx="100" cy="100" r="${r}" fill="none" stroke-width="10" stroke-linecap="round" stroke-dasharray="${C}" stroke-dashoffset="0"/>
    </svg>
    <div class="dial-center"><div class="dial-time" id="remain" role="timer">--:--</div><div class="dial-sub" id="elap"></div></div>
  </div>
  ${a.pauseStart?'<p class="paused-flag">일시정지됨</p>':''}
  <div class="weigh" id="weigh" ${a.steps[0].at!==null?'hidden':''}><span>계량 남은 시간</span><b id="wt">--:--</b></div>
  <p class="note" style="margin:0 0 6px">단계를 누르면 방법이 펼쳐져.</p><div class="card" style="padding:4px 0;overflow:hidden">${rows}</div>
  ${ci>=0?`<button class="btn stepbtn" data-act="next">「${esc(a.steps[ci].name)}」 완료</button>`:''}
  <div class="btns two">
    <button class="btn ghost" data-act="undo" ${a.steps[0].at===null?'disabled':''}>한 단계 되돌리기</button>
    <button class="btn ghost" data-act="pause">${a.pauseStart?'다시 시작':'일시정지'}</button>
  </div>
  <div class="btns"><button class="btn danger" data-act="finish">연습 끝내기</button></div>
  <details class="card" style="margin-top:14px"><summary>이 품목 주의할 점</summary><ul class="tips">${it.tips.map(x=>`<li>${esc(x)}</li>`).join('')}</ul></details>`;
}

function viewResult(){
  const a=S.active,it=findItem(a.cat,a.itemId),used=a.endAt,limit=a.totalMin*60000,over=used>limit;
  let prev=0;const durs=a.steps.filter(s=>s.at!==null).map(s=>{const d=s.at-prev;prev=s.at;return {name:s.name,d};});
  const max=Math.max(1,...durs.map(x=>x.d));
  const checks=['시간 안에 완성','모양·크기 균일','굽기 색 적당','공정 순서 안 틀림','위생·정리'];
  return `
  <div class="card">
    <p class="item-title">${esc(it.name)}</p>
    <div class="bigstat ${over?'over':''}">${fmt(used)}</div>
    <p class="note" style="margin-top:4px">제한 ${a.totalMin}분 중 ${over?'<b style="color:var(--alarm)">'+mins(used-limit)+' 초과</b>':mins(limit-used)+' 남기고 끝냄'} · 완료 단계 ${durs.length}/${a.steps.length}</p>
  </div>
  <div class="card"><h2>단계별 걸린 시간</h2><div class="bars">
    ${durs.length?durs.map(x=>`<div class="b"><span>${esc(x.name)}</span><span>${fmt(x.d)}</span><div class="track"><div class="fill" style="width:${Math.max(3,x.d/max*100)}%"></div></div></div>`).join(''):'<p class="note">완료한 단계가 없어.</p>'}
  </div></div>
  <div class="card"><h2>스스로 체크</h2><div class="checks">
    ${checks.map((c,i)=>`<label><input type="checkbox" class="ck" data-i="${i}" ${i===0&&!over&&durs.length===a.steps.length?'checked':''}> ${c}</label>`).join('')}
  </div>
  <label for="memo" class="note" style="display:block;margin:10px 0 6px">메모 (다음에 고칠 점)</label>
  <textarea id="memo" placeholder="예: 머랭 너무 오래 쳐서 비중 높게 나옴"></textarea></div>
  <div class="btns"><button class="btn primary" data-act="saveRes">기록 저장</button><button class="btn ghost" data-act="discard">저장하지 않고 나가기</button></div>`;
}

function viewHistory(){
  const cov=Object.entries(CATS).map(([k,v])=>{const done=v.items.filter(i=>countFor(k,i.id)>0).length;
    return `<h2 style="margin-top:6px">${v.label} 연습 현황 (${done}/${v.items.length})</h2><div class="grid" style="margin-bottom:16px">
      ${v.items.map(i=>{const c=countFor(k,i.id);return `<div class="${c?'':'zero'}"><b>${c}</b>${esc(i.name)}</div>`;}).join('')}</div>`;}).join('');
  const list=S.history.length?`<div class="list hist">${S.history.slice().reverse().map(h=>{
    const over=h.usedMs>h.limitMin*60000,d=new Date(h.date),ok=h.checks.filter(Boolean).length;
    return `<div class="row"><div class="l1"><span class="nm">${esc(h.name)}</span><span class="pill ${over?'bad':''}">${over?'시간 초과':'시간 내'}</span></div>
      <span class="mt">${d.getMonth()+1}/${d.getDate()} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')} · ${fmt(h.usedMs)} / ${h.limitMin}분 · 체크 ${ok}/${h.checks.length}</span>
      ${h.memo?`<span class="memo">${esc(h.memo)}</span>`:''}</div>`;}).join('')}</div>
    <div class="btns"><button class="btn danger" data-act="clear">기록 모두 지우기</button></div>`
    :`<div class="card empty">아직 기록이 없어. 과제를 하나 뽑아서 첫 연습을 해봐.</div>`;
  return cov+'<h2>최근 연습</h2>'+list;
}

function render(keep){
  if(S.active&&S.view!=='run'&&S.view!=='result'&&S.active.endAt===undefined)S.view='run';
  const v=S.view;
  const html=v==='prep'?viewPrep():v==='run'?viewRun():v==='result'?viewResult():v==='history'?viewHistory():viewHome();
  const y=window.scrollY;$('#app').innerHTML=html;setTabs();tick();window.scrollTo(0,keep?y:0);
}

