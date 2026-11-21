#import "@preview/quick-maths:0.2.1": shorthands
#import "style.typ"

/// Custom math functions
//Q: should I nest it in `math-notes-prelude` ?
#let rw(x) = $op("rw") [#x]$
#let rel(x) = $op("rel") [#x]$
#let simp(x) = $op("simp") [#x]$
#let ball(x,y) = $op("ball") [#x, #y]$
#let DL = math.op("DL")
#let Met = math.op([*Met*]) // for metric space
#let LD = math.op("LD")
#let Vect = math.op("Vect")
#let False = math.op("False")
#let True = math.op("True")
#let Prop = math.op("Prop")
#let sorry = math.op("sorry")
#let tab = $wide$
#let goal = $tack.r$
#let thus = $therefore$
#let hence = $therefore$
#let smul = $circle.filled.small$
#let span = math.op("span")
#let use = math.op("use")
#let ring = math.op("ring")
#let Im = math.op("Im") // by default they use a symbol for this, which is not commonly used in practice
#let self = $bold("self")$
#let grad = $attach(limits("grad"), t: stretch(arrow,size:#2.5em))$ // black magic to have a larger arrow
#let rank = math.op("rank") //Q: not sure we need this when we have `rg` defined
#let rg = math.op("rg")
#let eps = $epsilon$
#let surj = $arrow.r.twohead$
#let inj = $arrow.r.hook$
#let after = $space circle.small space$
#let Maj(x) = $op("Maj") (#x)$
#let Sub(x) = $op("Sub") (#x)$
#let GL(x) = $op("GL") (#x)$
#let ch(x) = $cosh(#x)$
#let sh(x) = $sinh(#x)$
//#let End(x) = $op("End") (#x)$
#let End(x) = $cal(L)(#x, #x)$
#let Open(x) = $op("Open") (#x)$
#let el(x,y) = $(#x#h(0pt):#h(0pt)#y)$
#let meq(x) = $eq.triple^(mod #x)$
#let mne(x) = $eq.triple.not^(mod #x)$
#let gcd(x,y) = $op("gcd") (#x, #y)$
#let dist(x,y) = $op("dist") (#x, #y)$
#let def(x) = $space^(#x:=)$
#let match(..arms) = math.display(math.cases(gap: 0.6em, ..arms.pos().map(arm => {
  let kids = arm.children
  let arrows = kids.enumerate().filter(((_, k)) => k == $->$.body).map(((i, _)) => i)
  assert(arrows.len() == 1, message: "match arm must be `case -> then`, got: " + repr(arm))
  let i = arrows.first()
  $#kids.slice(0, i).join() & quad -> quad & #kids.slice(i + 1).join()$
})))
#let ang(..a) = math.lr($chevron.l #a.pos().join($, $) chevron.r$) // explicit `lr`: auto-scaling doesn't reach into a nested equation

#let ig(body, var, lo: none, hi: none) = {
  let sym = math.integral
  if lo != none or hi != none {
    sym = math.attach(sym, b: lo, t: hi)
  }
  $#sym #body dif #var$
}

#let box(..lines) = rect(
  stroke: 0.5pt,
  radius: 3pt,
  inset: 6pt,
  stack(
    dir: ttb,
    spacing: 0.4em,
    ..lines.pos().map(x => math.equation(x, block: false))
  )
)

#let math-notes-prelude(doc) = [
  #show: shorthands.with(($..=$, $..#h(0pt)=#h(0pt)$))
  #show: style.lints
  #show math.equation: set block(breakable: true)
  // multi-line inline math sits on its last row's baseline by default; move it to the first row's
  #show math.equation.where(block: false): it => {
    let kids = if it.body.has("children") { it.body.children } else { (it.body,) }
    let i = kids.position(k => k.func() == linebreak)
    if i == none { return it }
    context {
      // depth below baseline: a 100pt box pins the ascent, text edges at baseline contribute nothing
      let desc = c => measure(text(top-edge: "baseline", bottom-edge: "baseline", [#c#std.box(height: 100pt)])).height - 100pt
      let first = math.equation(block: false, kids.slice(0, i).join())
      std.box(baseline: measure(it).height - desc(it) - (measure(first).height - desc(first)), it)
    }
  }

  #doc
]
