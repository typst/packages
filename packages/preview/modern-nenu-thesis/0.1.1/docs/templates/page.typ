// This is important for shiroa to produce a responsive layout
// and multiple targets.
#import "@preview/shiroa:0.2.3": (
  get-page-width, is-html-target, is-pdf-target, is-web-target, plain-text, shiroa-sys-target, target, templates,
)
#import templates: *

#let use-theme = "starlight"
#let is-starlight-theme = use-theme == "starlight"

// Metadata
#let page-width = get-page-width()
#let is-html-target = is-html-target()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target()
#let sys-is-html-target = ("target" in dictionary(std))

/// Creates an embedded block typst frame.
#let div-frame(content, attrs: (:), tag: "div") = html.elem(tag, html.frame(content), attrs: attrs)
#let span-frame = div-frame.with(tag: "span")
#let p-frame = div-frame.with(tag: "p")

// Theme (Colors)
#let themes = theme-box-styles-from(toml("theme-style.toml"), xml: it => xml(it))
#let (
  default-theme: (
    style: theme-style,
    is-dark: is-dark-theme,
    is-light: is-light-theme,
    main-color: main-color,
    dash-color: dash-color,
    code-extra-colors: code-extra-colors,
  ),
) = themes;
#let (
  default-theme: default-theme,
) = themes;
#let theme-box = theme-box.with(themes: themes)

// Fonts
#let main-font = (
  "Charter",
  "Source Han Serif SC",
  // "Source Han Serif TC",
  // shiroa's embedded font
  "Libertinus Serif",
)
#let code-font = (
  "BlexMono Nerd Font Mono",
  // shiroa's embedded font
  "DejaVu Sans Mono",
)

// Sizes
#let main-size = if is-web-target {
  16pt
} else {
  10.5pt
}
#let heading-sizes = if is-web-target {
  (2, 1.5, 1.17, 1, 0.83).map(it => it * main-size)
} else {
  (26pt, 22pt, 14pt, 12pt, main-size)
}
#let list-indent = 0.5em
#let in-heading = state("shiroa:in-heading", false)

#let mdbook-heading-rule(it) = {
  let it = {
    set text(size: heading-sizes.at(it.level))
    if is-web-target {
      heading-hash(it, hash-color: dash-color)
    }

    in-heading.update(true)
    it
    in-heading.update(false)
  }

  block(
    spacing: 0.7em * 1.5 * 1.2,
    below: 0.7em * 1.2,
    it,
  )
}

#let starlight-heading-rule(it) = context if shiroa-sys-target() == "html" {
  // // Render a dash to hint headings instead of bolding it as well.
  // show link: static-heading-link(it)
  // // Render the heading hash
  // heading-hash(it, hash-color: dash-color)

  import "@preview/shiroa-starlight:0.2.3": builtin-icon

  in-heading.update(true)
  html.elem("div", attrs: (class: "sl-heading-wrapper level-h" + str(it.level + 1)))[
    #it
    #html.elem(
      "h" + str(it.level + 1),
      attrs: (class: "sl-heading-anchor not-content", role: "presentation"),
      static-heading-link(it, body: builtin-icon("anchor"), canonical: true),
    )
  ]
  in-heading.update(false)
} else {
  mdbook-heading-rule(it)
}

#let markup-rules(body) = {
  // Set main spacing
  set enum(
    indent: list-indent * 0.618,
    body-indent: list-indent,
  )
  set list(
    indent: list-indent * 0.618,
    body-indent: list-indent,
  )
  set par(leading: 0.7em)
  set block(spacing: 0.7em * 1.5)

  // Set text, spacing for headings
  // Render a dash to hint headings instead of bolding it as well if it's for web.
  show heading: set text(weight: "regular") if is-web-target
  // todo: add me back in mdbook theme!!!
  show heading: if is-starlight-theme {
    starlight-heading-rule
  } else {
    mdbook-heading-rule
  }

  // link setting
  show link: set text(fill: dash-color)

  body
}

#let equation-rules(body) = {
  let get-main-color(theme) = {
    if is-starlight-theme and theme.is-dark and in-heading.get() {
      white
    } else {
      theme.main-color
    }
  }

  show math.equation: set text(weight: 400)
  show math.equation.where(block: true): it => context if shiroa-sys-target() == "html" {
    theme-box(
      tag: "div",
      theme => {
        set text(fill: get-main-color(theme))
        p-frame(attrs: ("class": "block-equation", "role": "math"), it)
      },
    )
  } else {
    it
  }
  show math.equation.where(block: false): it => context if shiroa-sys-target() == "html" {
    theme-box(
      tag: "span",
      theme => {
        set text(fill: get-main-color(theme))
        span-frame(attrs: (class: "inline-equation", "role": "math"), it)
      },
    )
  } else {
    it
  }
  body
}

/// The project function defines how your document looks.
/// It takes your content and some metadata and formats it.
/// Go ahead and customize it to your liking!
#let project(title: "Typst Book", authors: (), kind: "page", description: none, body) = {
  // set basic document metadata
  set document(
    author: authors,
    title: title,
  ) if not is-pdf-target

  // set web/pdf page properties
  set page(
    numbering: none,
    number-align: center,
    width: page-width,
  ) if not (sys-is-html-target or is-html-target)

  // remove margins for web target
  set page(
    margin: (
      // reserved beautiful top margin
      top: 20pt,
      // reserved for our heading style.
      // If you apply a different heading style, you may remove it.
      left: 20pt,
      // Typst is setting the page's bottom to the baseline of the last line of text. So bad :(.
      bottom: 0.5em,
      // remove rest margins.
      rest: 0pt,
    ),
    height: auto,
  ) if is-web-target and not is-html-target

  show: if is-html-target {
    import "@preview/shiroa-starlight:0.2.3": starlight

    let description = if description != none { description } else {
      let desc = plain-text(body, limit: 512).trim()
      if desc.len() > 512 {
        desc = desc.slice(0, 512) + "..."
      }
      desc
    }

    starlight.with(
      include "/github-pages/docs/book.typ",
      title: title,
      site-title: [Shiroa],
      description: description,
      github-link: "https://github.com/Myriad-Dreamin/shiroa",
    )
  } else {
    it => it
  }

  // Set main text
  set text(
    font: main-font,
    size: main-size,
    fill: main-color,
    lang: "zh",
  )


  // markup setting
  show: markup-rules
  // math setting
  show: equation-rules
  // code block setting
  show: code-block-rules.with(
    themes: themes,
    code-font: code-font,
    set-raw-theme: (theme, it) => {
      set raw(theme: theme) if theme.len() > 0
      it
    },
  )

  // Main body.
  set par(justify: true)

  body

  // Put your custom CSS here.
  context if shiroa-sys-target() == "html" {
    html.elem(
      "style",
      ```css
      .inline-equation {
        display: inline-block;
        width: fit-content;
      }
      .block-equation {
        display: grid;
        place-items: center;
        overflow-x: auto;
      }
      .site-title {
        font-size: 1.2rem;
        font-weight: 600;
        font-style: italic;
      }
      ```.text,
    )
  }
}

#let part-style = heading
