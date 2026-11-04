// DOM smoke only; actual browser and Roblox rendering are separate checks.
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert');
const html=fs.readFileSync('assets/review.html','utf8'),code=html.match(/<script>([\s\S]*)<\/script>/)[1];
let calls=0;const fields={};for(const key of ['species','level','side','pose','caption'])fields['#'+key]={value:key==='level'?'15':key==='side'?'front':key==='pose'?'idle':'',textContent:'',append(o){if(!this.value)this.value=o.value}};
fields['#sprite']={getContext(){return {clearRect(){},drawImage(_,x,y,w,h){assert(x>=0&&y>=0&&w===64&&h===64);calls++}}}};
const env={document:{querySelector:k=>fields[k],createElement:()=>({})},Image:class{complete=true},setInterval(){}};vm.createContext(env);vm.runInContext(code,env);
for(const level of ['1','7','15'])for(const side of ['front','back'])for(const pose of ['idle','attack','damage','faint']){fields['#level'].value=level;fields['#side'].value=side;fields['#pose'].value=pose;vm.runInContext('for(const d of defs){species.value=d.id;draw()}',env)}
assert(calls===720);assert(fields['#caption'].textContent.includes('Estágio'));console.log('PASS review smoke: 720 seleções espécie/nível/vista/pose, sem exceção JS (DOM simulado)');
