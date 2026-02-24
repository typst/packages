#import "components.typ": * // import components

#let red-frame-heading(config, it) = {
  set text(
    font: config._sans_font,
    weight: 500,
    tracking: 0.07em,
    size: config._main_size,
    fill: config._color_palette.red,
  )
  block(it, spacing: 1em)
}

#let red-frame(config) = (
  fill: config._color_palette.red-light,
  width: 100%,
  inset: 1em,
  radius: (top-left: 0pt, rest: 1em),
  breakable: true,
)

#let _env_state = state("env", (:))

#let _reset_env_counting() = _env_state.update(it => it.keys().map(k => (k, 0)).to-dict())

#let accent-frame-heading(config, it) = {
  set text(
    font: config._sans_font,
    weight: 500,
    tracking: 0.07em,
    size: config._main_size,
    fill: config._color_palette.accent,
  )
  block(it, spacing: 1em, sticky: true)
}

#let accent-frame(config) = (
  fill: config._color_palette.accent-light,
  width: 100%,
  outset: 0pt,
  inset: 1em,
  sticky: true,
  breakable: true,
  // radius: 5pt,
)

#let accent-topdeco(config) = {
  block(
    height: 3pt,
    width: 100%,
    fill: config._color_palette.accent,
    outset: 0pt,
    below: 0pt,
    sticky: true,
    breakable: false,
  )
}

#let accent-bottomdeco(config) = {
  block(height: 3pt, width: 100%, fill: config._color_palette.accent, outset: 0pt, above: 0pt, breakable: false)
}


#let dash-frame-heading(config, it) = {
  set text(font: config._sans_font, weight: 500, tracking: 0.07em, size: config._main_size, fill: black)
  block(it, spacing: 1em)
}

#let dash-frame(config) = (
  stroke: (left: (thickness: 1.2pt, paint: config._color_palette.accent, dash: "densely-dashed")),
  width: 100%,
  inset: (right: 0pt, rest: 0.75em),
  breakable: true,
)

#let solid-frame(config) = (
  fill: config._color_palette.accent-light,
  stroke: (left: (thickness: .5em, paint: config._color_palette.accent)),
  width: 100%,
  outset: 0pt,
  inset: 1em,
  sticky: true,
  breakable: true,
  // radius: 5pt,
)


#let plain-frame-heading(it) = {
  text(style: "italic", it)
}

#let plain-frame(config) = {
  (width: 100%)
}


#let environment(
  config,
  kind,
  name,
  supplement,
  topdeco: (..) => none,
  bottomdeco: (..) => none,
  frame,
  heading,
  title,
  body,
  label: none,
  numbered: true,
) = [
  #_env_state.update(it => it + (str(kind): it.at(kind, default: 0) + 1))
  #show figure.where(kind: kind): set block(breakable: true)
  #show figure.where(kind: kind): set par(spacing: config._envskip)
  #let name = upper(name)
  #figure(
    kind: kind,
    supplement: supplement,
    placement: none,
    caption: none,
    {
      set align(left)
      topdeco(config)
      block(
        breakable: true,
        ..frame(config),
        [
          #heading(if numbered {
            let num = context [#current_chapter().index.at(0).#_env_state.get().at(kind)]
            [#name#h(.3em) #num #h(.5em) #title]
          } else {
            name + h(.5em) + title
          })
          #body
        ],
      )
      bottomdeco(config)
    },
  ) #label
]


#let _remark(config, ..args) = environment(
  config,
  "remark",
  "REMARK",
  "Remark",
  red-frame,
  red-frame-heading.with(config),
  none,
  ..args,
)

#let _example(config, title: none, ..args) = environment(
  config,
  "example",
  config.i18n.example,
  config.i18n.example,
  dash-frame,
  dash-frame-heading.with(config),
  title,
  ..args,
)

#let _proposition(config, title: none, ..args) = environment(
  config,
  "proposition",
  config.i18n.proposition,
  config.i18n.proposition,
  topdeco: accent-topdeco,
  bottomdeco: accent-bottomdeco,
  accent-frame,
  accent-frame-heading.with(config),
  title,
  ..args,
)

#let _highlighteq(config, body) = {
  $
    #box(fill: config._color_palette.accent-light, stroke: config._color_palette.accent + 0.5pt, inset: 1em, body)
  $
}

#let _definition(config, title: none, ..args) = environment(
  config,
  "definition",
  config.i18n.definition,
  config.i18n.definition,
  solid-frame,
  accent-frame-heading.with(config),
  title,
  ..args,
)

#let _proof(config, title: none, body) = {
  let title = if title != none [(#title)]
  let _body = {
    title + body + h(1fr) + text(config._color_palette.accent, config._qed_symbol)
  }
  if "children" in body.fields() {
    let children = body.children
    let last = children.pop()
    if last.func() == math.equation {
      children.push(last + place(right + bottom, text(config._color_palette.accent, config._qed_symbol)))
      _body = [].func()(title + children)
    }
  }
  environment(
    config,
    numbered: false,
    "proof",
    config.i18n.proof.name,
    config.i18n.proof.supplement,
    plain-frame,
    plain-frame-heading,
    none,
    _body,
  )
}
