#import "@preview/symbolica:0.1.0" as sym

#set page(width: 150mm, height: auto, margin: 16mm)
#set text(size: 10.5pt)

= Symbolica integration with Rubi steps

#let x = sym.math($x$)
#let integrand = sym.math($x / (x + 1)$)
#let primitive = sym.integrate(integrand, x)
#let explanation = sym.integrate-with-steps(integrand, x)
#let step-notation = sym.notation(
  calls: (
    "symbolica_integrate::rubi_int": ctx => {
      let (body, variable) = ctx.visual-arguments
      $ integral #body dif #variable $
    },
  ),
)
#let show-step(expression) = sym.to-typst(expression, notation: step-notation)

$ integral #sym.to-typst(integrand) dif x
  = #sym.to-typst(primitive) + C $

#for step in explanation.steps [
  #h(step.depth * 1.2em)
  #if step.rule == none [*Transformation*] else [*Rule #step.rule*]
  #if step.description != "" [: #step.description]
  #linebreak()
  #h(step.depth * 1.2em)
  $#show-step(step.input) = #show-step(step.output)$
  #linebreak()
]
