/* 공통 유틸: DOM 선택, HTML 이스케이프, 시간 포맷, 품목별 연습 횟수·시간 설정 */
const $=s=>document.querySelector(s);
const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function fmt(ms){const neg=ms<0;ms=Math.abs(ms);const t=Math.floor(ms/1000),h=Math.floor(t/3600),m=Math.floor(t%3600/60),s=t%60;
  const p=n=>String(n).padStart(2,'0');return (neg?'+':'')+(h?h+':'+p(m):p(m))+':'+p(s);}
function mins(ms){const m=Math.round(ms/60000);return m>=60?Math.floor(m/60)+'시간 '+(m%60)+'분':m+'분';}
const dots=d=>'<span class="dots" aria-label="난이도 '+d+'/5">'+[1,2,3,4,5].map(i=>'<i class="'+(i<=d?'on':'')+'"></i>').join('')+'</span>';
function countFor(cat,id){return S.history.filter(h=>h.cat===cat&&h.itemId===id).length;}
function timesFor(cat,id){const t=S.prefs.times[cat+':'+id];return t||{total:cat==='bread'&&id==='grissini'?150:180,weigh:10};}

