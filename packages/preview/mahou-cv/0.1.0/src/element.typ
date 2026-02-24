#import "theme.typ": theme-state

#let progress-bar(
  progress,
  color: none,
) = {
  set block(above: 0pt, below: 0pt, spacing: 0pt)
  set par(leading: 0em)
  set rect(fill: color) if color != none

  context {
    rect(height: 6pt, width: 100%, stroke: rect.fill, fill: gradient.linear(
      (rect.fill, 0%),
      (rect.fill, progress),
      (white, progress),
      (white, 100%),
    ))
  }
}

#let section(
  title,
  color: none,
  content,
) = {
  context {
    let _color
    if color == none {
      _color = rect.fill
    } else {
      _color = color
    }

    show heading.where(level: 2): set text(fill: _color)
    set rect(fill: _color.darken(30%))

    v(6pt)
    heading(level: 2, title)
    rect(height: 2pt, width: 100%)
  }

  content
}

#let label(
  label,
  color: none,
  content,
) = {
  layout(size => [
    #grid(
      columns: (0.15 * size.width, 1fr),
      column-gutter: 8pt,
      align: (left, left),
      context {
        set text(fill: color) if color != none
        set text(fill: text.fill.lighten(40%))
        set text(tracking: -0.5pt, style: "italic")
        label
      },
      content,
    )
  ])
}

#let item(
  title,
  caption: none,
  color: none,
  content,
) = {
  set text(fill: color) if color != none

  let hasTitle = title != none
  let hasCaption = caption != none


  stack(
    spacing: 8pt,
    if hasTitle or hasCaption {
      stack(
        dir: ltr,
        context {
          set text(fill: text.fill.darken(40%))
          [=== #title]
        },
        h(1fr),
        context {
          set text(fill: text.fill.darken(40%))
          caption
        },
      )
    },
    {
      set par(justify: true)
      content
    },
  )
}

#let cv(
  name,
  bio,
  main,
  aside,
) = {
  context {
    let theme = theme-state.get()

    set page(margin: theme.margin)
    set text(font: theme.font, fill: theme.color.body)
    set rect(fill: theme.color.accent)
    show heading.where(level: 1): set text(fill: theme.color.accent, size: 2.5em)
    show heading.where(level: 2): set text(fill: theme.color.accent)

    {
      let _accent
      let _body
      if theme.color.header != none {
        _accent = theme.color.header.accent
        _body = theme.color.header.body
      } else {
        _accent = theme.color.accent
        _body = theme.color.body
      }

      set text(fill: _body)
      set rect(fill: _accent)
      show heading.where(level: 1): set text(fill: _accent)
      show heading.where(level: 2): set text(fill: _accent)

      pad(y: 0.7 * theme.margin)[
        #stack(spacing: theme.margin, [= #name], text(size: 1.7em)[#bio])
      ]
    }

    let main = {
      let _accent
      let _body
      if theme.color.main != none {
        _accent = theme.color.main.accent
        _body = theme.color.main.body
      } else {
        _accent = theme.color.accent
        _body = theme.color.body
      }

      set text(fill: _body)
      set rect(fill: _accent)
      show heading.where(level: 1): set text(fill: _accent)
      show heading.where(level: 2): set text(fill: _accent)

      main
    }

    let aside = {
      let _accent
      let _body
      if theme.color.aside != none {
        _accent = theme.color.aside.accent
        _body = theme.color.aside.body
      } else {
        _accent = theme.color.accent
        _body = theme.color.body
      }

      set text(fill: _body)
      set rect(fill: _accent)
      show heading.where(level: 1): set text(fill: _accent)
      show heading.where(level: 2): set text(fill: _accent)

      aside
    }

    grid(
      columns: (theme.main-width, theme.aside-width),
      gutter: theme.margin,
      main, aside,
    )
  }
}
