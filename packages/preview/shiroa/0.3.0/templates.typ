#import "template-link.typ": *
#import "template-theme.typ": *
#import "supports-html.typ": *
#import "meta-and-state.typ": is-web-target


// Sizes
#let main-size = if is-web-target() {
  16pt
} else {
  10.5pt
}
#let heading-sizes = if is-web-target() {
  (2, 1.5, 1.17, 1, 0.83).map(it => it * main-size)
} else {
  (26pt, 22pt, 14pt, 12pt, main-size)
}
#let list-indent = 0.5em


#let markup-rules(
  body,
  web-theme: "starlight",
  themes: none,
  main-size: main-size,
  heading-sizes: heading-sizes,
  list-indent: list-indent,
  starlight: "@preview/shiroa-starlight:0.3.0",
) = {
  assert(themes != none, message: "themes must be set")
  let (
    default-theme: (
      dash-color: dash-color,
    ),
  ) = themes


  let is-starlight-theme = web-theme == "starlight"
  let in-heading = state("shiroa:in-heading", false)

  let mdbook-heading-rule(it) = {
    let it = {
      set text(size: heading-sizes.at(it.level))
      if is-web-target() {
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

  let starlight-heading-rule(it) = context if shiroa-sys-target() == "html" {
    import starlight: builtin-icon

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
  show heading: set text(weight: "regular") if is-web-target()
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

#let equation-rules(
  body,
  web-theme: "starlight",
  theme-box: none,
) = {
  import "supports-html.typ": add-styles
  let is-starlight-theme = web-theme == "starlight"
  let in-heading = state("shiroa:in-heading", false)

  /// Creates an embedded block typst frame.
  let div-frame(content, attrs: (:), tag: "div") = html.elem(tag, html.frame(content), attrs: attrs)
  let span-frame = div-frame.with(tag: "span")
  let p-frame = div-frame.with(tag: "p")


  let get-main-color(theme) = {
    if is-starlight-theme and theme.is-dark and in-heading.get() {
      white
    } else {
      theme.main-color
    }
  }

  show math.equation: set text(weight: 400)
  show math.equation.where(block: true): it => context if shiroa-sys-target() == "html" {
    theme-box(tag: "div", theme => {
      set text(fill: get-main-color(theme))
      p-frame(attrs: ("class": "block-equation", "role": "math"), it)
    })
  } else {
    it
  }
  show math.equation.where(block: false): it => context if shiroa-sys-target() == "html" {
    theme-box(tag: "span", theme => {
      set text(fill: get-main-color(theme))
      span-frame(attrs: (class: "inline-equation", "role": "math"), it)
    })
  } else {
    it
  }

  add-styles(
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
    ```,
  )
  body
}

#let code-block-rules(
  body,
  web-theme: "starlight",
  code-font: none,
  themes: none,
  zebraw: "@preview/zebraw:0.6.0",
) = {
  import zebraw: zebraw, zebraw-init

  let with-raw-theme = (theme, it) => {
    if theme.len() > 0 {
      raw(
        align: it.align,
        tab-size: 2,
        block: it.block,
        lang: it.lang,
        syntaxes: it.syntaxes,
        theme: theme,
        it.text,
      )
    } else {
      raw(
        align: it.align,
        tab-size: 2,
        block: it.block,
        lang: it.lang,
        syntaxes: it.syntaxes,
        theme: auto,
        it.text,
      )
    }
  }

  let (
    default-theme: (
      style: theme-style,
      is-dark: is-dark-theme,
      is-light: is-light-theme,
      main-color: main-color,
      dash-color: dash-color,
      code-extra-colors: code-extra-colors,
    ),
  ) = themes
  let (
    default-theme: default-theme,
  ) = themes
  let theme-box = theme-box.with(themes: themes)

  let init-with-theme((code-extra-colors, is-dark)) = if is-dark {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      highlight-color: rgb("#3d59a1"),
      comment-color: rgb("#394b70"),
      lang-color: rgb("#3d59a1"),
      lang: false,
      numbering: false,
    )
  } else {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      lang: false,
      numbering: false,
    )
  }

  /// HTML code block supported by zebraw.
  show: init-with-theme(default-theme)
  set raw(tab-size: 114)

  let in-mk-raw = state("shiroa:in-mk-raw", false)
  let mk-raw(
    it,
    tag: "div",
    inline: false,
  ) = {
    theme-box(tag: tag, theme => {
      show: init-with-theme(theme)
      let code-extra-colors = theme.code-extra-colors
      let use-fg = not inline and code-extra-colors.fg != none
      set text(fill: code-extra-colors.fg) if use-fg
      set text(fill: if theme.is-dark { rgb("dfdfd6") } else { black }) if not use-fg
      set par(justify: false)
      zebraw(
        block-width: 100%,
        // line-width: 100%,
        wrap: false,
        with-raw-theme(theme.style.code-theme, it),
      )
    })
  }

  show raw: set text(font: code-font) if code-font != none
  show raw.where(block: false, tab-size: 114): it => context if shiroa-sys-target() == "paged" {
    it
  } else {
    mk-raw(it, tag: "span", inline: true)
  }
  show raw.where(block: true, tab-size: 114): it => context if shiroa-sys-target() == "paged" {
    rect(width: 100%, inset: (x: 4pt, y: 5pt), radius: 4pt, fill: code-extra-colors.bg, {
      set text(fill: code-extra-colors.fg) if code-extra-colors.fg != none
      set par(justify: false)
      with-raw-theme(theme-style.code-theme, it)
    })
  } else {
    mk-raw(it)
  }
  body
}

#let template-rules(
  body,
  title: none,
  description: auto,
  plain-body: none,
  book-meta: none,
  web-theme: auto,
  extra-assets: (),
  starlight: "@preview/shiroa-starlight:0.3.0",
  mdbook: "@preview/shiroa-mdbook:0.3.0",
) = {
  // Prepares description
  assert(type(description) == str or description == auto, message: "description must be a string or auto")
  let description = if description != auto { description } else {
    let desc = plain-text(plain-body, limit: 512).trim()
    let desc_chars = desc.clusters()
    if desc_chars.len() >= 512 {
      desc = desc_chars.slice(0, 512).join("") + "..."
    }
    desc
  }

  if web-theme == auto {
    web-theme = if is-html-target(exclude-wrapper: true) { "starlight" } else { "mdbook" }
  }

  let template-args = arguments(
    book-meta,
    title: title,
    description: description,
    extra-assets: extra-assets,
    body,
  )

  if web-theme == "starlight" {
    if not is-html-target() {
      panic(
        "Starlight theme is only available with `--mode=static-html`. Either change theme to mdbook or turn mode into `static-html`.",
      )
    }
    import starlight: starlight
    starlight(..template-args)
  } else if web-theme == "mdbook" {
    import mdbook: mdbook
    mdbook(..template-args)
  } else {
    panic("Unknown web theme: " + web-theme)
  }
}

#let paged-load-trampoline() = {
  import "sys.typ": x-current, x-url-base
  let replace-raw(it, vars: (:)) = {
    raw(
      lang: it.lang,
      {
        let body = it.text

        for (key, value) in vars.pairs() {
          body = body.replace("{{ " + key + " }}", value)
        }

        body
      },
    )
  }

  inline-assets(replace-raw(
    vars: (
      rel_data_path: {
        let url-base = x-url-base
        if url-base != none and url-base.ends-with("/") {
          url-base = url-base.slice(0, -1)
        }
        let current = x-current
        if current == none {
          current = ""
        }

        url-base + current.replace(regex(".typ$"), "")
      },
    ),
    ```js
    let appContainer = document.currentScript && document.currentScript.parentElement;
    window.typstRenderModuleReady.then((plugin) => {
        window.typstBookRenderPage(plugin, "{{ rel_data_path }}", appContainer);
    });
    ```,
  ))
}
