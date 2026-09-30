/* 상태(S)와 localStorage 저장. 저장 형식을 바꾸면 KEY 버전을 올릴 것 */
const KEY='bake-practice-v1';
function load(){try{const v=localStorage.getItem(KEY);return v?JSON.parse(v):null;}catch(e){return null;}}
const S=Object.assign({cat:'pastry',prefs:{sound:true,fresh:true,times:{}},history:[],active:null,view:'home',prepId:null},load()||{});
S.prefs=Object.assign({sound:true,fresh:true,times:{}},S.prefs||{});
function save(){try{localStorage.setItem(KEY,JSON.stringify(S));}catch(e){}}

