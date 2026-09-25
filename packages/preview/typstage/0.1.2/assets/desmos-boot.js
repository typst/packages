// Das Bootskript des Desmos-Rahmens.
//
// Es spricht dasselbe Protokoll wie das GeoGebra-Skript daneben, weil die
// Brücke nichts über den Inhalt eines Rahmens weiß: Der Kern schickt
// `{typstage:1, jobs:[…]}`, der Rahmen meldet sich mit `{typstage:1, ready:…}`.
// Was ein Auftrag bedeutet, entscheidet allein diese Datei.
//
// Der Unterschied zu GeoGebra liegt im Rücksetzen. Dort wird ein Base64-Abzug
// genommen und zurückgespielt; Desmos bringt `getState`/`setState` selbst mit,
// und beides ist synchron. Das Skript ist deshalb kürzer und braucht keinen
// Warteschritt.
(function(){
var calc=null,base=null,live=false,q=[],running={};

// ── Eine Zahl über die Zeit ziehen ────────────────────────────────────────
//
// Desmos animiert Regler selbst, aber nur mit seiner eigenen Geschwindigkeit
// und ohne Ziel. Eine Tween, die von A nach B läuft und dann steht, gibt es
// dort nicht -- also hier, Bild für Bild, wie im GeoGebra-Skript.
function tween(w){
 var from0=w.from==null?wert(w.name):w.from,dur=w.duration||600,t0=null;
 if(running[w.name])cancelAnimationFrame(running[w.name]);
 if(w.from!=null)setz(w.name,w.from);
 function frame(now){
  if(t0===null)t0=now;
  var p=dur>0?Math.min(1,(now-t0)/dur):1;
  var e=w.easing==="linear"?p:(p<0.5?2*p*p:1-Math.pow(-2*p+2,2)/2);
  setz(w.name,from0+(w.to-from0)*e);
  if(p<1)running[w.name]=requestAnimationFrame(frame);else delete running[w.name];
 }
 running[w.name]=requestAnimationFrame(frame);
}
function stopTweens(){for(var n in running)cancelAnimationFrame(running[n]);running={};}

// Ein Regler ist bei Desmos ein Ausdruck `a=1`. Lesen geht über den
// Helferausdruck-Zustand, schreiben über `setExpression`.
function wert(n){
 try{
  var hs=calc.getExpressions();
  for(var i=0;i<hs.length;i++){
   if(hs[i].id===n&&hs[i].latex){
    var m=/=\s*(-?[0-9.]+)\s*$/.exec(hs[i].latex);
    if(m)return parseFloat(m[1]);
   }
  }
 }catch(e){}
 return 0;
}
function setz(n,v){
 try{calc.setExpression({id:n,latex:n+"="+v});}catch(e){}
}

function apply(j,sofort){
 var bad=[];
 // `set` ist ein Wörterbuch id -> LaTeX. Ein Ausdruck ohne `=` ist eine
 // Kurve, einer mit `=` ein Regler; Desmos entscheidet das selbst.
 if(j.set)for(var k in j.set){
  try{calc.setExpression({id:k,latex:j.set[k]});}catch(e){bad.push(k);}
 }
 // `expr` reicht ganze Ausdrucksobjekte durch, für alles, was `set` nicht
 // kann -- Farbe, Reglergrenzen, Stil in einem Zug.
 if(j.expr)for(var i=0;i<j.expr.length;i++){
  try{calc.setExpression(j.expr[i]);}catch(e){bad.push(j.expr[i].id||"?");}
 }
 if(j.rm)for(var i=0;i<j.rm.length;i++){
  try{calc.removeExpression({id:j.rm[i]});}catch(e){}
 }
 if(j.vis)for(var i=0;i<j.vis.ids.length;i++){
  try{calc.setExpression({id:j.vis.ids[i],hidden:j.vis.on===false});}catch(e){}
 }
 if(j.style){var t=j.style;
  for(var i=0;i<t.ids.length;i++){
   var o={id:t.ids[i]};
   if(t.color!=null)o.color=t.color;
   if(t.lineStyle!=null)o.lineStyle=t.lineStyle;
   if(t.lineWidth!=null)o.lineWidth=t.lineWidth;
   if(t.lineOpacity!=null)o.lineOpacity=t.lineOpacity;
   if(t.pointStyle!=null)o.pointStyle=t.pointStyle;
   if(t.pointSize!=null)o.pointSize=t.pointSize;
   if(t.fill!=null)o.fill=t.fill;
   if(t.fillOpacity!=null)o.fillOpacity=t.fillOpacity;
   if(t.label!=null)o.label=t.label;
   if(t.showLabel!=null)o.showLabel=t.showLabel;
   if(t.dragMode!=null)o.dragMode=t.dragMode;
   try{calc.setExpression(o);}catch(e){}
  }
 }
 if(j.view){var v=j.view;
  if(v.bounds)try{calc.setMathBounds({left:v.bounds[0],right:v.bounds[1],
                                      bottom:v.bounds[2],top:v.bounds[3]});}catch(e){}
  if(v.settings)try{calc.updateSettings(v.settings);}catch(e){}
 }
 // Desmos' eigene Regleranimation. `playing:false` hält sie an.
 if(j.anim)for(var i=0;i<j.anim.ids.length;i++){
  var a={id:j.anim.ids[i],playing:j.anim.playing!==false};
  if(j.anim.bounds)a.sliderBounds=j.anim.bounds;
  try{calc.setExpression(a);}catch(e){}
 }
 if(j.tween){if(sofort)setz(j.tween.name,j.tween.to);else tween(j.tween);}
 if(bad.length)try{parent.postMessage({typstage:1,failed:bad,who:__ID__},"*");}catch(e){}
}
function play(jobs,sofort){for(var i=0;i<(jobs||[]).length;i++)apply(jobs[i],sofort);}

function run(m){
 if(!m||m.typstage!==1)return;
 // Der Kern hat den Rahmen neu bemessen. Desmos hängt an seinem Container und
 // merkt das meist selbst; `resize()` ist die Zusage, dass es auch dann sitzt,
 // wenn nur der Zoom sich geändert hat und kein `resize` fällt.
 if(m.mass){if(calc)try{calc.resize();}catch(e){}return;}
 if(!live){q.push(m);return;}
 if(m.stop){stopTweens();return;}
 if(m.reset&&base!=null){
  stopTweens();
  try{calc.setState(base);}catch(e){}
  play(m.jobs,true);
  return;
 }
 play(m.jobs,false);
}
addEventListener("message",function(e){run(e.data);});
addEventListener("resize",function(){if(calc)try{calc.resize();}catch(e){}});

// ── Aufbau ────────────────────────────────────────────────────────────────
(function start(){
 if(typeof Desmos==="undefined"){setTimeout(start,50);return;}
 var el=document.getElementById("ts-dsm");
 calc=Desmos.GraphingCalculator(el,__PARAMS__);
 // Ein benannter Griff auf den Rechner. GeoGebra stellt sein `ggbApplet`
 // von Haus aus global bereit; hier ist es dieselbe Zusage, und ohne sie
 // steckt der Rechner in einer Closure, an die weder ein Deck noch eine
 // Probe herankommt.
 window.tsDesmos=calc;
 __BOOTVIEW__
 base=calc.getState();
 live=true;
 var r=q;q=[];for(var i=0;i<r.length;i++)run(r[i]);
 // Ohne `spiegel`: der Rahmen lässt sich bedienen, meldet seinen Stand aber
 // nicht zurück. Der Kern nimmt dann in der Sprecheransicht den anderen Weg
 // für den Zeiger, und das ist für ein Dokument ohne Rückmeldung richtig.
 try{parent.postMessage({typstage:1,ready:__ID__},"*");}catch(e){}
})();
})();
