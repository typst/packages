#let default-theme = (
  margin: 22pt,

  font: "Inria Sans",
  font-size: 11pt,
  accent-color: blue,
  body-color: rgb("222"),

  header-accent-color: none, // inherit
  header-body-color: none, // inherit

  main-accent-color: none, // inherit
  main-body-color: none, // inherit
  main-width: 5fr,
  main-gutter-width: 64pt,

  aside-accent-color: none, // inherit
  aside-body-color: none, // inherit
  aside-width: 3fr,
  aside-gutter-width: 48pt,
)


#let cv(
  title: "",
  subtitle: "",
  theme: (),
  aside: [],
  main,
) = {
  // Function to pick a key from the theme, or a default if not provided.
  let th(key, default: none) = {
    return if key in theme and theme.at(key) != none {
      theme.at(key)
    } else if default != none and default in theme and theme.at(default) != none {
      theme.at(default)
    } else if default != none {
      default-theme.at(default)
    } else {
      default-theme.at(key)
    }
  }

  set page(
    margin: (
      top: 2 * th("margin"),
      bottom: th("margin"),
      left: th("margin"),
      right: th("margin"),
    ),
  )

  // Fix for https://github.com/typst/typst/discussions/2919
  show heading.where(level: 1): set text(size: th("font-size"))
  show heading.where(level: 2): set text(size: th("font-size"))

  set text(font: th("font"))
  set text(size: th("font-size"))

  set par(linebreaks: "simple", leading: 0.4em)
  set block(above: 10pt, below: 8pt, spacing: 10pt)

  {
    show heading.where(level: 1): set text(size: 3.0em)
    show heading.where(level: 2): set text(size: 1.6em, weight: "regular")
    show heading.where(level: 1): set text(fill: th("header-accent-color", default: "accent-color"))
    show heading.where(level: 2): set text(fill: th("header-body-color", default: "body-color").lighten(30%))

    stack(
      spacing: th("margin"),
      heading(level: 1, title),
      heading(level: 2, subtitle),
      v(th("margin"))
    )
  }

  show heading.where(level: 1): set text(size: 1.2em, fill: th("accent-color"))
  show heading.where(level: 2): set text(size: 1.0em, fill: th("body-color"))

  grid(
    columns: (th("main-width"), th("margin"), th("aside-width")),

    // Content.
    {
      set grid(columns: (th("main-gutter-width"), 1fr))
      show heading.where(level: 1): set text(fill: th("main-accent-color", default: "accent-color").lighten(30%))
      show heading.where(level: 2): set text(fill: th("main-body-color", default: "body-color"))
      set text(fill: th("main-body-color", default: "body-color").lighten(40%))
      set rect(fill: th("main-accent-color", default: "accent-color"))

      main
    },

    // Empty space.
    {},

    // Aside.
    {
      set grid(columns: (th("aside-gutter-width"), 1fr))
      show heading.where(level: 1): set text(fill: th("aside-accent-color", default: "accent-color").lighten(30%))
      show heading.where(level: 2): set text(fill: th("aside-body-color", default: "body-color"))
      set text(fill: th("aside-body-color", default: "body-color").lighten(40%))
      set rect(fill: th("aside-accent-color", default: "accent-color"))

      aside
    },
  )
}


#let section(
  theme: (),
  title,
  body,
) = {
  set grid(columns: (theme.gutter-size, 1fr)) if "gutter-size" in theme
  show heading.where(level: 1): set text(fill: theme.accent-color) if "accent-color" in theme
  show heading.where(level: 2): set text(fill: theme.body-color) if "body-color" in theme
  set rect(fill: theme.accent-color.darken(40%)) if "accent-color" in theme
  set text(fill: theme.body-color) if "body-color" in theme

  v(6pt)
  heading(level: 1, title)
  rect(height: 2pt, width: 100%,)
  body
}


#let entry(
  theme: (),
  right: none,
  gutter,
  title,
  body,
) = {
  set grid(columns: (theme.gutter-size, 1fr)) if "gutter-size" in theme
  show heading.where(level: 2): set text(fill: theme.body-color) if "body-color" in theme
  set text(fill: theme.body-color) if "body-color" in theme

  grid(
    {
      set text(tracking: -0.5pt, style: "italic")
      context {
        set text(fill: text.fill.lighten(40%))
        gutter
      }
    },
    {
      let hasTitle = title != none
      let hasRight = right != none

      if hasTitle or hasRight {
        grid(
          columns: (1fr, auto),
          {
            heading(
              level: 2,
              context {
                set text(fill: text.fill.darken(40%))
                title
              }
            )
          },
          context {
            set text(fill: text.fill.darken(40%))
            right
          },
        )
      }
      if body != none {
        set par(justify: true)
        set block(above: 6pt)
        body
      }
    }
  )
}


#let progress-bar(
  progress,
) = {
  // Fix for https://github.com/typst/typst/issues/3826
  if progress == 0% {
    progress = 0.1%
  }

  set block(above: 0pt, below: 0pt, spacing: 0pt)
  set par(leading: 0em)

  context {
    let light-accent = rect.fill.lighten(30%)

    rect(
      height: 6pt,
      width: 100%,
      stroke: light-accent,
      fill: gradient.linear(
        (light-accent, 0%),
        (light-accent, progress),
        (white, progress),
        (white, 100%),
      ),
    )
  }
}
