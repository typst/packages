
#import "./palette.typ": *
#import "./utils.typ": *
#import "./counters.typ": current-heading-number
#import "./web.typ": web-end-marker


// Data for the different kinds of maths highlighted environments.
#let maths_hl_envs_data = (
  definition: (
    title: "definición",
    bg: palette.math_hl_env_bg,
    numbering: "1",
  ),
  axiom: (
    title: "axioma",
    bg: palette.ax_env_bg,
    numbering: "1",
  ),
  theorem: (
    title: "teorema",
    bg: palette.math_hl_env_bg,
    numbering: "1",
  ),
  proposition: (
    title: "proposición",
    bg: palette.math_hl_env_bg,
    numbering: "1",
  ),
  lemma: (
    title: "lema",
    bg: palette.math_hl_env_bg,
    numbering: "1",
  ),
  corollary: (
    title: "corolario",
    bg: palette.math_hl_env_bg,
    numbering: "1",
  ),
)


// TODO Unify highlighted environments and exercise-like environments, including remarks,
// etc.


// Numbering pattern that the wrapping figure exposes (for references).
#let env_figure_numbering(number, numbering-pattern) = {
  if number == auto {
    numbering-pattern
  } else if number == none {
    none
  } else {
    n => number
  }
}


#let env_auto_number(kind, numbering-pattern) = context {
  let env-number = counter(figure.where(kind: kind)).display(numbering-pattern)
  if kind == "axiom" {
    env-number
  } else {
    [#current-heading-number(1).#env-number]
  }
}


#let env_number(kind, number, numbering-pattern) = {
  if number == auto {
    env_auto_number(kind, numbering-pattern)
  } else {
    number
  }
}


// Wraps an environment body in a labelable (referenceable) figure.
#let env_figure(kind, cfg, number, env-numbering, inner) = figure(
  kind: kind,
  supplement: [#capitalize(cfg.title)],
  numbering: env_figure_numbering(number, env-numbering),
  outlined: false,
  inner,
)


#let maths_hl_envs(
  kind,
  body,
  number: auto,
  title: none,
  numbering: none,
  bg: none,
  counter-value: none,
) = {
  let cfg = maths_hl_envs_data.at(kind)
  let env-numbering = if numbering != none { numbering } else { cfg.numbering }
  let suffix = env_title_suffix(
    number: env_number(kind, number, env-numbering),
    title: title,
  )

  let inner = context {
    if target() == "html" {
      html.div(class: "math-environment math-environment--" + kind)[
        #if counter-value != none {
          counter(figure.where(kind: kind)).update(counter-value)
        }
        #set enum(numbering: env-numbering)
        #html.div(class: "environment-heading")[
          #emph[#strong[#capitalize(cfg.title)#suffix]].---#sym.space
        ]
        #body
      ]
    } else {
      block(
        width: 100%,
        fill: if bg != none { bg } else { cfg.bg },
        inset: 8pt,
        radius: 4pt,
      )[
        #if counter-value != none {
          counter(figure.where(kind: kind)).update(counter-value)
        }
        #set align(left)
        #set par(justify: true)
        #set enum(numbering: env-numbering)
        #text[*_#capitalize(cfg.title)#suffix.---_* ]
        #body
      ]
    }
  }

  env_figure(kind, cfg, number, env-numbering, inner)
}


#let make_math_env(kind) = {
  (body, number: auto, title: none, numbering: none, bg: none) => {
    maths_hl_envs(kind, body, number: number, title: title, numbering: numbering, bg: bg)
  }
}

#let definition = make_math_env("definition")
#let theorem = make_math_env("theorem")
#let proposition = make_math_env("proposition")
#let lemma = make_math_env("lemma")
#let corollary = make_math_env("corollary")


// Axioms use a global counter that is never reset by the template. Setting
// `num` forces both the displayed value and the counter state, so the next
// automatically numbered axiom continues at `num + 1`.
#let axiom = (body, num: auto, title: none, numbering: none, bg: none) => {
  maths_hl_envs(
    "axiom",
    body,
    number: num,
    title: title,
    numbering: numbering,
    bg: bg,
    counter-value: if num != auto and num != none { num } else { none },
  )
}


// Data of exercise-like environments.
#let exr_like_envs_data = (
  example: (
    title: "ejemplo",
    numbering: "1",
    final_marker: $corner.r.b$,
  ),
  exercise: (
    title: "ejercicio",
    numbering: "1",
    final_marker: $corner.r.b$,
  ),
  problem: (
    title: "problema",
    numbering: "1",
    final_marker: $corner.r.b$,
  ),
)


// Generic exercise-like environments function.
#let exr_like_envs(kind, body, number: auto, title: none, numbering: none, final_marker: none) = {
  let cfg = exr_like_envs_data.at(kind)
  let env-numbering = if numbering != none { numbering } else { cfg.numbering }
  let suffix = env_title_suffix(
    number: env_number(kind, number, env-numbering),
    title: title,
  )
  let marker = if final_marker != none { final_marker } else { cfg.final_marker }

  let inner = context {
    if target() == "html" {
      html.div(class: "exercise-environment exercise-environment--" + kind)[
        #set enum(numbering: env-numbering)
        #html.div(class: "environment-heading")[
          #strong[#emph[#capitalize(cfg.title)#suffix.---]]#sym.space
        ]
        #body
        #web-end-marker(marker)
      ]
    } else {
      block(width: 100%)[
        #set align(left)
        #set par(justify: true)
        #set enum(numbering: env-numbering)
        #text[*_#capitalize(cfg.title)#suffix.---_* ]
        #body
        #h(1fr) #marker
      ]
    }
  }

  env_figure(kind, cfg, number, env-numbering, inner)
}


#let make_exr_env(kind) = {
  (body, number: auto, title: none, numbering: none, final_marker: none) => {
    exr_like_envs(
      kind,
      body,
      number: number,
      title: title,
      numbering: numbering,
      final_marker: final_marker,
    )
  }
}

#let example = make_exr_env("example")
#let exercise = make_exr_env("exercise")
#let problem = make_exr_env("problem")


#let proof(it, ref: none) = context {
  if target() == "html" {
    html.elem("details", attrs: (class: "proof"))[
      #html.summary(
        class: "proof__toggle",
        aria-label: "Mostrar u ocultar la demostración",
      )[
        #strong[\[#env_parenthetical(ref)#html.span(
          class: "proof__toggle-marker",
          aria-hidden: true,
        )[]\]]
      ]
      #html.div(class: "proof__content")[
        #it
      ]
    ]
  } else {
    block[
      #text[*_Demostración#env_parenthetical(ref).~--- _*]
      #it
      #h(1fr)
      #text[$qed$]
    ]
  }
}


#let remark-layout(kind, label, it) = context {
  if target() == "html" {
    html.aside(class: "remark remark--" + kind)[
      #html.div(class: "remark__heading")[#text(weight: "bold", style: "italic", label).]
      #it
      #web-end-marker($corner.r.b$)
    ]
  } else {
    block[#text(weight: "bold", style: "italic", label). #it #h(1fr) $corner.r.b$]
  }
}

#let remark(it) = remark-layout("observation", [Observación], it)
#let remark_notat(it) = remark-layout("notation", [Notación], it)
#let remark_term(it) = remark-layout("terminology", [Terminología], it)


// TODO Entorno de tipo enum para los pasos en una demostración. Vea
// <https://forum.typst.app/t/can-you-make-a-horizontal-enum-list/877/3>.
/*
#let proof_steps(it) = enum(
  body-indent: 0em, #it
)
*/

// I think that it is not necessary.
// #let st = math.class("relation", "|")
