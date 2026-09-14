#import "styling.typ" as styling: divide
#import "bundled-layout.typ": breakable-frames
#import "inspect.typ" as inspect

#let styles = {
  import "styles/boxy.typ": boxy
  import "styles/hint.typ": hint
  import "styles/thmbox.typ": thmbox
  (boxy: boxy, hint: hint, thmbox: thmbox)
}

// DEPRECATED. Use `frames` and `show: frame-style()` instead
#let make-frames(
  kind,
  style: styles.boxy,
  base-color: purple.lighten(60%).desaturate(40%),
  ..frames,
) = {
  import "parse.typ": fill-missing-colors
  import "bundled-layout.typ": bundled-factory

  for (id, supplement, color) in fill-missing-colors(base-color, frames) {
    ((id): bundled-factory(style, supplement, kind, color))
  }
}

#let default-kind = "frame"

#let frames(
  kind: default-kind,
  base-color: purple.lighten(60%).desaturate(40%),
  ..frames,
) = {
  import "parse.typ": fill-missing-colors
  import "layout.typ": frame-factory

  for (id, supplement, color) in fill-missing-colors(base-color, frames) {
    ((id): frame-factory(kind, supplement, color))
  }
}

#let frame(
  kind: default-kind,
  supplement,
  arg,
) = {
  import "layout.typ": frame-factory

  frame-factory(kind, supplement, arg)
}

#let frame-style(kind: default-kind, style) = {
  import "layout.typ" as layout
  layout.frame-style(kind, style)
}

/*
Definition of styling:

let factory(title: content, tags: (content), body: content, supplement: string or content, number, args)
*/
