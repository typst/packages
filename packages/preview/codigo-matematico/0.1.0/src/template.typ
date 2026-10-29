
#import "./palette.typ": *
#import "./settings.typ": *
#import "./utils.typ": *
#import "./counters.typ": *
#import "./layout.typ": *
#import "./refs.typ": *
#import "./environments.typ": *
#import "./blocks.typ": *
#import "./math.typ": *
#import "./tables.typ": *
#import "./web.typ": *




// Template
// ----------------------------------------------------------------------------
#let templ(
  // dark_theme: false,
  sheet: "a4",
  lang: "en",
  title: none,
  authors: (),
  abstract: [],
  parts: false,
  outline_depth: 4,
  env_counter_reset_depth: auto,
  web_css: auto,
  doc,
) = context {
  set text(lang: lang)
  let web = target() == "html"
  set document(
    title: title,
    author: authors.map(author => author.name),
    description: abstract,
  )
  set heading(numbering: "1.")

  let tablet = sheet == "tablet"
  let chapter-depth = if parts { 2 } else { 1 }
  let reset-depth = if env_counter_reset_depth == auto {
    1
  } else {
    env_counter_reset_depth
  }

  set figure(numbering: figure-numbering(chapter-depth))
  set page(..page-settings(sheet, tablet)) if not web

  // Figures are unbreakable blocks by default. The theorem-like environments
  // are wrapped in figures (so they can be labeled and referenced), but they
  // should still be allowed to break across pages.
  show figure: it => {
    if not web and environment-counter-names.contains(it.kind) {
      set block(breakable: true)
      it
    } else {
      it
    }
  }

  set text(..main_body_text_settings) if not web
  set text(fill: palette.fg) if not web

  // show strong: set text(weight: bold_weight)

  show raw: set text(..raw_font_text_settings) if not web

  /*
  show math.equation: it => {
    if it.body.func() == math.sans[].func(){
      it
    } else {
      math.equation(block: it.block, math.sans(it))
    }
  }
  */


  show heading: set text(weight: heading_weight) if not web
  show heading.where(level: 1): set text(size: 14pt) if not web
  show heading.where(level: 2): set text(size: 12pt) if not web
  show heading.where(level: 3): set text(size: 10pt) if not web
  show heading.where(level: 4): set text(size: 8pt) if not web
  show heading.where(level: 5): set text(size: 7pt) if not web

  // show math.equation: set text(font: "New Computer Modern", size: 1.2em, weight: 500)
  show math.equation: set text(size: 1.2em, weight: 500) if not web

  // Typst 0.15.1 does not yet export math.overline to MathML. Use the
  // equivalent overline accent in HTML while preserving the paged rendering.
  show math.overline: it => if web {
    math.accent(it.body, sym.dash)
  } else {
    it
  }

  // show math.equation: set text(font: "New Computer Modern", weight: "regular")
  // show math.equation: set text(size: 1.1em, font: "Lete Sans Math")


  // Code block background.
  show raw.where(block: true): it => if web {
    it
  } else {
    block(
      fill: luma(40),
      inset: 10pt,
      radius: 4pt,
      width: 100%,
      it,
    )
  }

  show figure.caption: set text(
    style: "italic",
    fill: palette.fg,
    size: main_body_text_settings.at("size"),
  )

  show ref: reference-rule

  set par(
    justify: true,
    // first-line-indent: 1em,
    // leading: 0.6em,
  ) if not web

  set table(stroke: 0.4pt + palette.fg) if not web

  // Cambió en la versión 0.14 de Typst y ahora no funciona bien. El antiguo
  // está comentado justo después.
  // Enumerates automatically the labeled non-referenced equations.
  // set math.equation(numbering: "(1)")
  /*
  show math.equation: it => {
      if it.block and not it.has("label") [
        #counter(math.equation).update(v => v - 1)
        #math.equation(it.body, block: true, numbering: none)
      ] else {
        it
      }
  }
  */

  /*
  // Enumerates automatically the labeled non-referenced equations.
  set math.equation(numbering: "(1)")
  show math.equation: it => {
      if it.block and not it.has("label") [
        #counter(math.equation).update(v => v - 1)
        #math.equation(it.body, block: true, numbering: none)#label("")
      ] else {
        it
      }
  }
  */

  /*
  // TODO Try to merge it in the main Typst project for the Spanish language
  // behavior.
  show heading.where(level: 1): set heading(supplement: [Capítulo])
  show heading.where(level: 2): set heading(supplement: [Sección])
  show heading.where(level: 3): set heading(supplement: [Sección])
  show heading.where(level: 4): set heading(supplement: [Sección])
  show heading.where(level: 5): set heading(supplement: [Sección])
  show heading.where(level: 6): set heading(supplement: [Sección])
  */

  // Transforms every instance. I just want in math mode.
  // show "sin": name => { "sen" }
  // show "sin": set text(font: "Open Sans", size: 9pt)
  // show "lim": name => { "lím" }

  // TODO Sigue mal. La centra.
  // show bibliography: set heading(level: 2)

  show outline: set heading(supplement: [Outline])
  show heading: heading-layout(parts, chapter-depth, reset-depth, web: web)

  set footnote.entry(separator: line(
    length: 30% + 0pt,
    stroke: (thickness: 0.5pt, paint: palette.fg),
  )) if not web

  set par(justify: true) if not web

  let rendered = {
    title-page(title, authors, abstract, lang: lang, web: web)
    outline-page(outline_depth, web: web)
    doc
  }

  if web {
    web-document(
      rendered,
      theme: palette_theme,
      css: web_css,
    )
  } else {
    rendered
  }
}


// TODO Hacer una función para introducir cómodamente la hipótesis y la meta
// de inducción del paso inductivo.

  // #table(
  //   columns: 2,
  //   align: (left, left),
  //   stroke: none,
  //   [#sym.bullet hipótesis:],
  //     $m dot n = n dot m$,
  //   [#sym.bullet meta:],
  //     $m dot suc(n) = suc(n) dot m$,
  // )

// TODO Crear entorno de expresión simbólica alternativa de un resultado.
// TODO Crear entorno de expresión alternativa en Lean de un resultado.
// TODO Crear entorno de explicación de notación.
// TODO Crear entorno de explicación de terminología.
