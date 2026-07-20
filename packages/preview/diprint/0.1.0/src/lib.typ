// diprint — arXiv-style paper template for Typst.
// Compiles to HTML and PDF from the same source.

/// The bundled CSS as a string. Use with `asset()` in `--format bundle` exports.
///
/// ```typst
/// #asset("diprint.css", diprint-css())
/// ```
#let diprint-css() = {
  read("diprint.css", encoding: none)
}

/// Format a document in arXiv style.
///
/// - `title` (str, content) — Paper title.
/// - `authors` (array of dicts) — Each dict accepts `name`, `email`, `affiliation`, `orcid`.
/// - `abstract` (content, none) — Paper abstract.
/// - `keywords` (array of str) — Keywords listed below the abstract.
/// - `date` (str, none) — Submission or publication date.
/// - `header-text` (str) — Subtitle text (default: "A Preprint").
/// - `short-title` (str, none) — Running page header. Defaults to `title`.
/// - `use-bundle-css` (bool) — Load CSS via `<link>` instead of inline `<style>`. For `--format bundle` exports.
/// - `font` (str) — Body font for HTML output: `"serif"` (default) or `"sans"`.
/// - `body` (content) — Document body.
#let diprint(
  title: "",
  abstract: none,
  keywords: (),
  authors: (),
  date: none,
  header-text: "A Preprint",
  short-title: none,
  use-bundle-css: false,
  font: "serif",
  body,
) = {
  let author-names = authors.map(a => a.name)
  let running-title = if short-title != none { short-title } else { title }

  set document(title: title, author: author-names)

  set page(
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1.1in),
    numbering: "1",
    number-align: center,
    header: context {
      let page-num = counter(page).get().first()
      if page-num == 1 { return }
      set text(size: 8pt)
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        smallcaps[#running-title],
        smallcaps[#header-text],
      )
    },
    footer: context {
      let page-num = counter(page).get().first()
      if page-num != 1 { return }
      align(center, text(size: 8pt, str(page-num)))
    },
  )

  set text(lang: "en")

  show math.equation: set text(weight: 400)
  show math.equation: set block(spacing: 0.65em)
  set math.equation(numbering: "(1)")

  set heading(numbering: "1.1")
  show heading: it => {
    if it.level == 1 {
      block(spacing: 10pt, it)
    } else if it.level == 2 {
      block(spacing: 8pt, it)
    } else if it.level > 3 {
      text(11pt, weight: "bold", it.body + " ")
    } else {
      it
    }
  }

  show figure: set block(spacing: 12pt)

  show link: underline

  context {
    let is-html = std.target() == "html"

    if is-html {
      if use-bundle-css {
        html.link(rel: "stylesheet", href: "diprint.css")
      } else {
        let css = read("diprint.css")
        html.style(css)
      }

      html.meta(name: "color-scheme", content: "light dark")

      html.elem("article", attrs: (class: "diprint", "data-font": font), {

        html.elem("div", attrs: (class: "header-spacer-top"), [])
        html.elem("hr", attrs: (class: "header-rule"), [])

        html.elem(
          "div",
          attrs: (class: "title-block"),
          block(text(weight: 500, size: 1.75em, title)),
        )

        html.elem("hr", attrs: (class: "header-rule"), [])
        html.elem("div", attrs: (class: "header-spacer-bottom"), [])

        html.elem(
          "div",
          attrs: (class: "subtitle"),
          text(size: 0.85em, smallcaps[#header-text]),
        )

        html.elem("div", attrs: (class: "authors-container"), {
          for author in authors {
            html.elem("div", attrs: (class: "author-entry"), {
              html.elem("div", attrs: (class: "author-name"), {
                if "orcid" in author {
                  html.elem(
                    "a",
                    attrs: (
                      class: "orcid-link",
                      href: "https://orcid.org/" + author.orcid,
                    ),
                    [*#author.name*],
                  )
                } else {
                  [*#author.name*]
                }
              })

              if "email" in author {
                html.elem(
                  "div",
                  attrs: (class: "author-email"),
                  link("mailto:" + author.email)[#author.email],
                )
              }

              if "affiliation" in author {
                html.elem(
                  "div",
                  attrs: (class: "author-affil"),
                  [ #author.affiliation ],
                )
              }
            })
          }
        })

        if date != none {
          html.elem("div", attrs: (class: "date-block"), [ #date ])
        }

        if abstract != none {
          html.elem("div", attrs: (class: "abstract-heading"), [Abstract])
          html.elem("div", attrs: (class: "abstract-content"), {
            set par(justify: true)
            set text(hyphenate: false)
            abstract
          })
        }

        if keywords.len() > 0 {
          html.elem(
            "p",
            attrs: (class: "keywords"),
            [*_Keywords_* ] + keywords.map(str).join(" · "),
          )
        }

        html.elem("hr", attrs: (class: "rule-thin"), [])

        set par(justify: true)
        set text(hyphenate: false)
        body
      })
    } else {
      set text(font: "New Computer Modern")

      line(length: 100%, stroke: 2pt)

      pad(
        bottom: 4pt,
        top: 4pt,
        align(center)[
          #block(text(weight: 500, size: 1.75em, title))
          #v(1em, weak: true)
        ],
      )

      line(length: 100%, stroke: 2pt)

      align(center, text(size: 0.85em, smallcaps[#header-text]))

      pad(
        top: 0.5em,
        x: 2em,
        grid(
          columns: (1fr,) * calc.min(3, authors.len()),
          gutter: 1em,
          ..authors.map(author => align(center)[
            #if "orcid" in author {
              link("https://orcid.org/" + author.orcid)[
                #pad(
                  bottom: -8pt,
                  grid(
                    columns: (8pt, auto, 8pt),
                    rows: 10pt,
                    [],
                    [*#author.name*],
                    [
                      #pad(
                        left: 4pt,
                        top: -4pt,
                        image("orcid.svg", width: 8pt),
                      )
                    ],
                  ),
                )
              ]
            } else {
              [*#author.name*]
            }
            #if "email" in author [
              \ #author.email
            ]
            #if "affiliation" in author [
              \
              #author.affiliation
            ]
          ]),
        ),
      )

      if date != none {
        align(center)[#date]
      }

      if abstract != none {
        pad(
          x: 3em,
          top: 1em,
          bottom: 0.4em,
          [
            #align(center)[
              #heading(
                outlined: false,
                numbering: none,
                text(0.85em, smallcaps[Abstract]),
              )
            ]
            #set par(justify: true)
            #set text(hyphenate: false)
            #align(left, abstract)
          ],
        )
      }

      if keywords.len() > 0 {
        [*_Keywords_* #h(0.3cm)] + keywords.map(str).join(" · ")
      }

      set par(justify: true)
      set text(hyphenate: false)
      body
    }
  }
}

/// Switches heading numbering to appendix style ("Appendix A", "A.1", ...)
/// and resets the heading counter. Call after the main body, before your
/// appendix sections.
///
/// Usage:
///   #show: diprint-appendices
///   = My Appendix
///   ...
#let diprint-appendices(body) = {
  counter(heading).update(0)
  counter("appendices").update(1)

  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let value = "ABCDEFGHIJ".at(vals.at(0) - 1)
      if vals.len() == 1 {
        return "Appendix " + value
      } else {
        return value + "." + nums.pos().slice(1).map(str).join(".")
      }
    },
  )

  [
    #context {
      if std.target() != "html" {
        pagebreak()
      }
    }
    #body
  ]
}
