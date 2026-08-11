#import "gfx/mod.typ" as gfx
#import "info.typ"
#import "palette.typ": *

#let callout(
  body,
  /// Color that the callout is highlighted with.
  accent: none,
  /// Icon to show at the left, as fetched `gfx.icons`.
  /// If `accent` is `none` (the default), this is also where the highlight color is taken from instead.
  icon: none,
  /// Who said or wrote down what is in that callout.
  source: none,
  /// How this callout should be titled.
  name: none,
  /// Any other configuration arguments. Forwarded to `text`, useful is `lang`.
  ..args,
) = {
  let accent = if accent != none {
    accent
  } else if icon != none {
    gfx.icons.at(icon).accent
  } else {
    fg
  }

  let body = text(..args)[
    *#name*

    #body

    #if source != none [ \~#info.render(source) ]
  ]
  let body = if icon == none {
    body
  } else {
    let icon = gfx.icons.at(icon).render
    grid(
      columns: (1.5em, 1fr),
      gutter: 0.25em,
      align: (right, left),

      icon(), body,
    )
  }

  block(
    stroke: (left: accent),
    inset: (
      left: if icon == none { 0.5em } else { 0em },
      y: 0.5em,
    ),
    body,
  )
}

// make suitable status names available
// see palette.typ for the full definitions
#let (
  axiom,
  idle,
  corollary,
  define,
  hint,
  lemma,
  pause,
  progress,
  propose,
  question,
  remark,
  theorem,
  urgent,
  complete,
) = {
  gfx.icons.keys().map(name => (name, callout.with(icon: name))).to-dict()
}

