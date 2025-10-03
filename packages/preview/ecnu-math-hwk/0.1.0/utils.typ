#import "@preview/itemize:0.1.2" as el

#let cn-font-serif = "Source Han Serif SC"
#let en-font-serif = "New Computer Modern"
#let cn-font-sans = "Source Han Sans SC"
#let en-font-sans = "New Computer Modern Sans"

#let translation = (
  problem: (
    zh: "问题",
    en: "Problem",
  ),
  proof: (
    zh: "证明",
    en: "Proof.",
  ),
  solution: (
    zh: "解答",
    en: "Solution.",
  ),
)

#let scr(it) = text(
  stylistic-set: 1,
  box($cal(it)$),
)

#let span = math.op("span")
#let Var = math.op("Var")
#let Cov = math.op("Cov")
#let Pr = math.op("Pr")
#let ind = math.op("ind")
#let rank = math.op("rank")
#let tr = math.op("tr")
#let diag = math.op("diag")
#let null = math.op("null")
#let eigen = math.op("eigen")
#let dim = math.op("dim")
#let char = math.op("char")
#let Gal = math.op("Gal")
#let Aut = math.op("Aut")
#let Inv = math.op("Inv")
#let End = math.op("End")
#let oint = math.integral.cont
#let oiint = math.integral.surf
#let oiiint = math.integral.vol
#let iint = math.integral.double
#let iiint = math.integral.triple
#let argmin = math.op("argmin", limits: true)
#let argmax = math.op("argmax", limits: true)
#let End = math.op("End")

#let pmat = math.mat.with(delim: "(")
#let bmat = math.mat.with(delim: "[")
#let detm = math.mat.with(delim: "|")


#let problem-counter = counter("problem")

#let thmtitle(t, color: luma(0)) = {
  underline(
    text(font: (en-font-sans, cn-font-sans), weight: 600)[#t],
    stroke: color + 2pt,
    offset: 1pt,
    evade: false,
  )
}

#let problem(body) = context {
  problem-counter.step()
  counter(math.equation).update(0)

  thmtitle(color: red.transparentize(30%))[#context translation.problem.at(
      text.lang,
    ) #context problem-counter.display()]
  body
}

#let proof(body) = context {
  thmtitle(color: rgb("#614de4").transparentize(30%), translation.proof.at(text.lang))
  body
  h(1fr)
  $square.filled$
}

#let solution(body) = context {
  thmtitle(color: rgb("#614de4").transparentize(30%), translation.solution.at(text.lang))
  body
  h(1fr)
}


#let show-math-format(body) = {
  show math.equation: it => {
    show regex("\p{script=Han}"): set text(font: cn-font-serif, weight: "light")
    it
  }

  // 默认矩阵是方
  set math.mat(delim: "[")
  set math.vec(delim: "[")
  // 增加大括号和文字的间距
  set math.cases(gap: 0.5em)

  // 给带有 label 的公式编号
  show math.equation: it => {
    if it.fields().keys().contains("label") {
      math.equation(
        block: true,
        numbering: n => {
          numbering("(1.1)", counter("problem").get().first(), n)
        },
        it,
      )
    } else {
      it
    }
  }

  show ref: it => context {
    let el = it.element
    if el != none and el.func() == math.equation {
      let fmt = "Eq"
      if text.lang == "zh" { fmt = "式" }
      link(el.location(), numbering(
        fmt + " (1.1)",
        counter("problem").get().first(),
        counter(math.equation).at(el.location()).at(0) + 1,
      ))
    } else {
      it
    }
  }
  body
}

#let show-common-format(body) = {
  show "。": ". "
  show raw: set text(font: ("Consolas Nerd Font", cn-font-sans), weight: 400)

  show ref: el.ref-enum
  show: el.default-enum-list
  set enum(numbering: "(1)", full: true)

  body
}
