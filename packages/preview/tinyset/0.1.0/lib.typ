#let header(number: 1, class: "Math 3551 - Fall 2024", name: "Your Name") = {
  set text(font: "New Computer Modern Math")
  align(center)[
    #class \
    #name - Homework #number
  ]
}

#let inv(expression) = {$(expression)^(-1)$}
#let implies = $==>$
#let wlog = "without loss of generatlity"
#let atc = [Assume towards $==><==$]
#let Wlog = "Without loss of generatlity"
#let impl = $==>$
#let iff = $<==>$
#let qed = [#v(0.2em)#h(1fr)$square.big$]

// environments
#let ans(body) = {[#par(justify: true)[#body]]}
#let prf(body) = {ans[_Proof:_ #body #qed]}
#let qs(body) = {
  set text(font: "New Computer Modern Math")
  set enum(numbering: "(a)")
  set par(justify: true)
  body
}
#let pt(body) = {
  body
}
