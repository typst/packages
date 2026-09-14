#let setup-toot(..args) = {
  let config = {
    let user-config = args.named()
    let serving = json(bytes(sys.inputs.at("toot-serving", default: "false")))
    let root = if serving { "" } else { user-config.at("root", default: "") }
    if root.len() > 0 and not root.starts-with("/") {
      root = "/" + root
    }
    if not root.ends-with("/") {
      root = root + "/"
    }

    let styling = user-config.at("styling", default: (:))
    let snippets = user-config.at("snippets", default: ())
    assert(
      snippets
        .filter(s => (
          type(s) != dictionary or "trigger" not in s or "expansion" not in s
        ))
        .len()
        == 0,
      message: "Each snippet must have a `trigger` and an `expansion` field.",
    )

    (
      root: root,
      prev: sys.inputs.at("toot-prev", default: ""),
      next: sys.inputs.at("toot-next", default: ""),
      page-id: sys.inputs.at("toot-page-id", default: ""),
      build: json(bytes(sys.inputs.at("toot-build", default: "false"))),
      serving: serving,
      accent-color: styling.at("accent-color", default: "gray"),
      snippets: snippets,
      outline: user-config.at("outline", default: []),
      general-head-extra: user-config.at("head-extra", default: none),
      name: user-config.at("name", default: []),
      universe-url: user-config.at("universe-url", default: ""),
    )
  }

  let replace-typ-suffix(filename) = {
    let suffix = regex(".typ(#|$)")
    filename.replace(suffix, match => ".html" + match.captures.first())
  }

  let to-web-dest(filename) = {
    config.root + replace-typ-suffix(filename)
  }

  let i-link(dest, body) = link(to-web-dest(dest), body)

  let toot-page(body, head-extra: none) = context if (
    // `target` itself only exists if the html feature is activated
    "target" in std and target() == "html"
  ) {
    html.html({
      html.head({
        html.meta(charset: "utf-8")
        html.meta(
          name: "viewport",
          content: "width=device-width, initial-scale=1.0",
        )
        if document.title == none {
          html.title(config.name)
        } else {
          html.title(document.title)
        }
        html.style(
          ":root { --accent-color: " + config.accent-color.to-hex() + "; } ",
        )
        if config.build {
          html.link(rel: "stylesheet", href: to-web-dest("resources/style.css"))
          html.script(defer: true, src: to-web-dest("resources/control.js"))
        } else {
          html.style(read("resources/style.css"))
        }
        config.general-head-extra
        head-extra
      })
      html.body({
        html.div(
          id: "outline",
          class: "hidden",
          {
            show link: it => html.a(href: to-web-dest(it.dest), it.body)
            config.outline
          },
        )
        html.header({
          html.button(
            id: "outline-toggle",
            image(width: 2em, "assets/hamburger.svg"),
          )
          strong(config.name)
          parbreak()
          link(config.universe-url)[#sym.arrow.r Universe]
        })
        html.main({
          body
        })
        html.footer({
          if config.build and config.prev == "" {
            html.span() // empty element so that the flex layout still works
          } else {
            html.a(
              href: to-web-dest(config.prev),
              image(width: 2em, "assets/left.svg"),
            )
          }
          if config.build and config.next == "" {
            html.span() // empty element so that the flex layout still works
          } else {
            html.a(
              href: to-web-dest(config.next),
              image(width: 2em, "assets/right.svg"),
            )
          }
        })
        if not config.build {
          html.script(read("resources/control.js"))
        }
      })
    })
  } else { body }

  let example-counter = counter("toot-example")

  let example(
    columns: 1,
    border-color: gray,
    hide-code: false,
    hide-output: false,
    code,
  ) = context {
    let code-text = code.text
    for snippet in config.snippets {
      code-text = code-text.replace(snippet.trigger, snippet.expansion)
    }
    let light-dark-setup = ```typ
    #show: body => {
      let theme = if sys.inputs.at("theme", default: "light") == "light" {
        (bg: white, fg: black)
      } else {
        (bg: luma(50), fg: white)
      }
      set page(fill: theme.bg)
      set text(fill: theme.fg)

      body
    }
    ```.text
    code-text = code-text.replace("// LIGHT DARK", light-dark-setup)

    if not hide-code {
      let shown-lines = ()
      let show-flag = false
      for line in code-text.split("\n") {
        if line.trim() == "// START" {
          show-flag = true
        } else if line.trim() == "// STOP" {
          show-flag = false
        } else if show-flag {
          shown-lines.push(line)
        }
      }
      raw(
        block: code.block,
        lang: code.lang,
        shown-lines.join("\n", default: ""),
      )
    }

    if not hide-output {
      let example-id = "example" + str(example-counter.get().first())
      example-counter.step()
      [#metadata((
          code: code-text,
          id: example-id,
          bordercolor: border-color,
          columns: columns,
        )) <toot-example>]
      if config.build {
        html.picture({
          for theme in ("light", "dark") {
            html.source(
              media: "(prefers-color-scheme: " + theme + ")",
              srcset: (
                (
                  src: to-web-dest(
                    config.page-id + "-" + example-id + "-" + theme + ".svg",
                  ),
                ),
              ),
            )
          }
          html.img(
            alt: config.page-id + "-" + example-id,
            src: to-web-dest(
              config.page-id + "-" + example-id + "-light" + ".svg",
            ),
          )
        })
      } else {
        par[_image is not displayed in this build mode_]
      }
    }
  }

  (toot-page: toot-page, example: example, i-link: i-link)
}
