/* 알림: 진동, 알림음(WebAudio), 화면 꺼짐 방지(Wake Lock) */
let ac=null,wl=null;
function initAudio(){try{if(!ac)ac=new (window.AudioContext||window.webkitAudioContext)();if(ac.state==='suspended')ac.resume();}catch(e){}}
function alertUser(n){
  try{navigator.vibrate&&navigator.vibrate(n>1?[300,150,300,150,300]:[250,120,250]);}catch(e){}
  if(!S.prefs.sound||!ac)return;
  for(let i=0;i<n+1;i++){const o=ac.createOscillator(),g=ac.createGain();o.frequency.value=880;o.connect(g);g.connect(ac.destination);
    const t=ac.currentTime+i*0.35;g.gain.setValueAtTime(0.0001,t);g.gain.exponentialRampToValueAtTime(0.3,t+0.02);g.gain.exponentialRampToValueAtTime(0.0001,t+0.25);o.start(t);o.stop(t+0.3);}
}
async function wake(){try{if('wakeLock' in navigator&&!wl){wl=await navigator.wakeLock.request('screen');wl.addEventListener('release',()=>{wl=null;});}}catch(e){}}
function unwake(){try{wl&&wl.release();}catch(e){}wl=null;}
document.addEventListener('visibilitychange',()=>{if(document.visibilityState==='visible'&&S.active&&!S.active.pauseStart)wake();});

