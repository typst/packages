// Boxed environments: Challenge/Objective,
// Definition/Corollary (shaded, like the LaTeX package shadethm) and the kaotheorems family.
#import "metrics.typ" as m
#import "state.typ": *
#import "i18n.typ": tr
#import "theme.typ": make-theme, tint

// Numbering within sections: Definition 2.1.3
#let section-numbering(pattern) = (..nums) => {
  let h = counter(heading).get()
  numbering(pattern, h.at(0, default: 0), h.at(1, default: 0), ..nums)
}

// Vertical metrics of the grey Challenge box (measured in a kaobook PDF):
// title baseline 11.7pt below the top, rule 7.4pt below it, body baseline
// 11.84pt below the rule, box bottom 7.48pt below the last baseline.
#let pad-x = 6.8pt
#let title-inset = (top: 11.7pt - 0.75 * m.size.normalsize, bottom: 7.4pt - 0.25 * m.size.normalsize)
#let body-inset = (top: 11.84pt - 0.75 * m.size.normalsize, bottom: 7.48pt - 0.25 * m.size.normalsize)
#let box-spacing = 15.2pt

// --- Titled box: "Challenge I", "Objective 1" ------------------------------------
// tinted: grey/tinted box, bold title, thin rule, italic body (default)
// bar:    white box with a thick rule on the left, coloured title
// banner: title on a full-colour bar in white, tinted body
#let titled-box(it, color: black, style: "tinted") = {
  let title = [#it.supplement #context it.counter.display(it.numbering)]
  if it.caption != none { title = [#title: #it.caption.body] }
  let body = align(left, emph(it.body))
  if style == "tinted" {
    block(width: 100%, fill: tint(color), breakable: true, above: box-spacing, below: box-spacing, {
      block(width: 100%, inset: (x: pad-x, ..title-inset), below: 0pt, align(left, text(fill: color, strong(title))))
      line(length: 100%, stroke: 0.4pt + color)
      block(width: 100%, inset: (x: pad-x, ..body-inset), above: 0pt, body)
    })
  } else if style == "bar" {
    block(
      width: 100%,
      stroke: (left: 2pt + color),
      inset: (left: pad-x + 1pt, right: pad-x, top: title-inset.top, bottom: body-inset.bottom),
      breakable: true,
      above: box-spacing,
      below: box-spacing,
      {
        block(width: 100%, below: body-inset.top + title-inset.bottom, align(left, text(fill: color, strong(title))))
        body
      },
    )
  } else {
    block(width: 100%, breakable: true, above: box-spacing, below: box-spacing, {
      block(
        width: 100%,
        fill: color,
        inset: (x: pad-x, ..title-inset),
        below: 0pt,
        sticky: true,
        align(left, text(fill: white, strong(title))),
      )
      block(width: 100%, fill: tint(color, colour: 92%), inset: (x: pad-x, ..body-inset), above: 0pt, body)
    })
  }
}

// --- Theorem box: "Definition 2.1.3 (Name) text ..." -------------------------------
#let theorem-box(it, color: black, style: "tinted", italic: true) = {
  let head = [#it.supplement #context it.counter.display(it.numbering)]
  if it.caption != none { head = [#head (#it.caption.body)] }
  let body = if italic { emph(it.body) } else { it.body }
  let inset = (x: pad-x, top: 5pt, bottom: 4pt)
  if style == "tinted" {
    block(
      width: 100%,
      fill: tint(color, grey: 97%, colour: 92%),
      inset: inset,
      breakable: true,
      above: box-spacing,
      below: box-spacing,
      align(left, [#text(fill: color, strong(head))#h(0.5em)#body]),
    )
  } else if style == "bar" {
    block(
      width: 100%,
      stroke: (left: 2pt + color),
      inset: (..inset, left: pad-x + 1pt),
      breakable: true,
      above: box-spacing,
      below: box-spacing,
      align(left, [#text(fill: color, strong(head))#h(0.5em)#body]),
    )
  } else {
    block(width: 100%, breakable: true, above: box-spacing, below: box-spacing, {
      block(
        width: 100%,
        fill: color,
        inset: (x: pad-x, top: 4pt, bottom: 3pt),
        below: 0pt,
        sticky: true,
        align(left, text(fill: white, strong(head))),
      )
      block(width: 100%, fill: tint(color, grey: 97%, colour: 92%), inset: inset, above: 0pt, align(left, body))
    })
  }
}

#let box-rules(appendix: false, theme: make-theme(), body) = {
  let numbering = section-numbering(if appendix { "A.1.1" } else { "1.1.1" })
  let style = theme.box-style
  show figure.where(kind: "kao-challenge"): set figure(numbering: "I")
  show figure.where(kind: "kao-objective"): set figure(numbering: "1")
  show figure.where(kind: "kao-def"): set figure(numbering: numbering)
  show figure.where(kind: "kao-thm"): set figure(numbering: numbering)
  show figure.where(kind: "kao-ex"): set figure(numbering: numbering)
  show figure.where(kind: "kao-challenge"): titled-box.with(color: theme.challenge, style: style)
  show figure.where(kind: "kao-objective"): titled-box.with(color: theme.objective, style: style)
  show figure.where(kind: "kao-def"): theorem-box.with(color: theme.definition, style: style)
  show figure.where(kind: "kao-thm"): theorem-box.with(color: theme.definition, style: style)
  show figure.where(kind: "kao-ex"): theorem-box.with(color: theme.definition, style: style, italic: false)
  body
}

// Creates a boxed environment. `title` is optional: `#definition(title: [AL])[...]`.
// `key` selects the translated name ("definition", "lemma", ...).
#let _env(kind, key) = (body, title: none) => figure(
  body,
  kind: kind,
  supplement: tr(key),
  caption: title,
  outlined: false,
  placement: none,
)

#let challenge = _env("kao-challenge", "challenge")
#let objective = _env("kao-objective", "objective")
// Definition and corollary share one counter.
#let definition = _env("kao-def", "definition")
#let corollary = _env("kao-def", "corollary")
// Theorem, lemma and proposition share one counter.
#let theorem = _env("kao-thm", "theorem")
#let lemma = _env("kao-thm", "lemma")
#let proposition = _env("kao-thm", "proposition")
#let example = _env("kao-ex", "example")
#let remark = _env("kao-ex", "remark")
