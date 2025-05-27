#import "@preview/showybox:2.0.4": *
#import "theme-color.typ": theme-color

#let callout(
  icon: none,
  title: none,
  title-fg: theme-color.red,
  title-bg: theme-color.red.lighten(85%),
  body-fg: theme-color.black,
  body-bg: theme-color.orange.lighten(85%),
  border: theme-color.white + 0pt,
  ..bodies) = {
  set text(size: 0.9em)
  showybox(
    frame: (
      title-color: title-bg,
      body-color: body-bg,
      border-color: border.paint,
      thickness: border.thickness,
    ),
    title: if title == none { "" } else if icon != none { 
      show: pad.with(left: .8em)
      box(width: 0em, move(icon, dx: -1.2em))
      title
    } else { title },
    title-style: (
      color: title-fg,
    ),
    ..bodies.pos().map(body => {
      if title == none and icon != none {
        show: pad.with(left: .8em)
        box(width: 0em, move(icon, dx: -1.2em))
        body
      } else { body }
    })
  )
}

#let tip = callout.with(
  icon: "💡"
)

#let example = callout.with(
  title-fg: theme-color.white,
  title-bg: theme-color.lime.darken(10%),
  body-bg: theme-color.lime.lighten(85%),
)

#let important = callout.with(
  title-fg: theme-color.white,
  title-bg: theme-color.purple,
  body-bg: theme-color.purple.lighten(85%),
)

#let warning = callout.with(
  title-fg: theme-color.white,
  title-bg: theme-color.orange,
  body-bg: theme-color.orange.lighten(85%),
)

#let caution = callout.with(
  title-fg: theme-color.white,
  title-bg: theme-color.red,
  body-bg: theme-color.red.lighten(85%),
)

#let note = callout.with(
  title-fg: theme-color.white,
  title-bg: theme-color.blue.darken(10%),
  body-bg: theme-color.blue.lighten(85%),
)

#let refer = callout.with(
  title-fg: theme-color.white,
  title-bg: theme-color.pink,
  body-bg: theme-color.pink.lighten(85%),
)

// Callout with icons

#let example-i = example.with(
  icon: "🧩",
)

#let important-i = important.with(
  icon: "🚩",
)

#let warning-i = warning.with(
  icon: "⚠️",
)

#let caution-i = caution.with(
  icon: "❗",
)

#let note-i = note.with(
  icon: "✏️",
)

#let refer-i = refer.with(
  icon: "🔖",
)
