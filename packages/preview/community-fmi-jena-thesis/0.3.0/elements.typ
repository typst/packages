// Colours, translations and the elements you can use in your text: boxes for
// definitions and examples, numbered example sentences, todos and side notes.
//
// The look of these elements is adapted from grape-suite by Tristan Pieper
// (https://github.com/piepert/grape-suite), which is licensed as follows:
//
//   MIT License
//
//   Copyright (c) 2024 Tristan Pieper
//
//   Permission is hereby granted, free of charge, to any person obtaining a copy
//   of this software and associated documentation files (the "Software"), to deal
//   in the Software without restriction, including without limitation the rights
//   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//   copies of the Software, and to permit persons to whom the Software is
//   furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//   copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//   SOFTWARE.

// The colour of the Faculty of Mathematics and Computer Science.
#let fmi-teal = rgb("#007a8b")

// All colours of the template, derived from one primary colour.
#let palette(primary) = (
  primary: primary,
  // Lines of the task and solution boxes.
  primary-light: primary.lighten(25%),
  // Box titles and todos.
  primary-dark: primary.darken(35%),
  // Box backgrounds and the todo highlight.
  tint: primary.lighten(90%),
  tint-strong: primary.lighten(80%),
  // Table lines and the background of inline code.
  stroke: primary.lighten(70%),
  fill: primary.lighten(95%),
)

// The elements below are used outside of `fsu`, so they read the colours from a state
// that `fsu` sets. Needs context.
#let colors-state = state("fmi-colors", palette(fmi-teal))
#let get-colors() = colors-state.final()

// Whether todos and side notes are shown. `fsu` sets this from `show-todos`.
#let show-todos-state = state("fmi-show-todos", true)

// Strings the template inserts itself, by language. Anything that is not German
// falls back to English.
#let translations = (
  en: (
    abstract: "Abstract",
    preface: "Preface",
    abbreviations: "Abbreviations",
    bibliography: "Bibliography",
    appendix: "Appendix",
    figures: "List of Figures",
    tables: "List of Tables",
    listings: "List of Listings",
    declaration: "Declaration of Academic Integrity",
    place-and-date: "Place and date",
    signature: "Signature",
    definition: "Definition",
    example: "Example",
    notice: "Notice",
    hint: "Hint",
    task: "Task",
    solution: "Solution",
    todo: "To do",
    page: "p.",
  ),
  de: (
    abstract: "Zusammenfassung",
    preface: "Vorwort",
    abbreviations: "Abkürzungsverzeichnis",
    bibliography: "Literaturverzeichnis",
    appendix: "Anlagen",
    figures: "Abbildungsverzeichnis",
    tables: "Tabellenverzeichnis",
    listings: "Quelltextverzeichnis",
    declaration: "Eigenständigkeitserklärung",
    place-and-date: "Ort, Datum",
    signature: "Unterschrift",
    definition: "Definition",
    example: "Beispiel",
    notice: "Anmerkung",
    hint: "Hinweis",
    task: "Aufgabe",
    solution: "Lösung",
    todo: "To do",
    page: "S.",
  ),
)

// Look up a translated string for the current text language. Needs context.
#let translate(key) = translations.at(text.lang, default: translations.en).at(key)

// A tinted box with a thick line on its left and a small title.
// The colours are keys of the palette.
#let important-box(
  body,
  title: none,
  bar: "primary",
  fill: "tint",
  title-color: "primary-dark",
  dotted: false,
) = context {
  let c = get-colors()
  block(
    width: 100%,
    inset: 1em,
    fill: c.at(fill),
    stroke: (left: (thickness: 4pt, paint: c.at(bar), dash: if dotted { "dotted" } else { "solid" })),
    {
      if title != none {
        block(sticky: true, text(size: 0.8em, fill: c.at(title-color), strong(title)))
      }
      body
    },
  )
}

// Makes a box function like `definition`. `name` is shown as the title of the box
// and used when referencing it, e.g. "Definition 2".
//
// The box function takes:
// - `title`: shown after the name, e.g. "Definition 2 — Graph".
// - `figured`: numbers the box, so that you can reference it with a label.
//
// Figured boxes are figures, so `fsu` makes them breakable across pages.
#let make-box(kind, name, ..style) = (title: none, figured: false, body) => {
  let full-title(number) = name + if number != none [ #number] + if title != none [ --- #title]
  if not figured {
    important-box(title: full-title(none), ..style, body)
  } else {
    // The box is the content of the figure, so that a label after the box refers to
    // the figure.
    let number = context counter(figure.where(kind: kind)).display()
    figure(kind: kind, supplement: name, align(left, important-box(title: full-title(number), ..style, body)))
  }
}

// The figure kinds of the numbered boxes.
#let box-kinds = ("definition", "notice", "example", "hint", "task", "solution")

#let definition = make-box("definition", context translate("definition"))
#let notice = make-box("notice", context translate("notice"), dotted: true)
#let example = make-box(
  "example",
  context translate("example"),
  bar: "primary-dark",
  fill: "tint-strong",
  dotted: true,
)
#let hint = make-box("hint", context translate("hint"), bar: "primary-dark", fill: "tint-strong")
#let task = make-box("task", context translate("task"), bar: "primary-light")
#let solution = make-box("solution", context translate("solution"), bar: "primary-light", dotted: true)

// A numbered example sentence, as in linguistics: "(1) Some sentence."
// Reference it with a label, which shows its number, e.g. "(1)".
// A function, because references would drop the parentheses of the pattern "(1)".
#let sentence-numbering(n) = numbering("(1)", n)
#let sentence(body) = figure(kind: "fmi-sentence", supplement: none, numbering: sentence-numbering, grid(
  columns: (1cm, 1fr),
  column-gutter: 0.5em,
  context counter(figure.where(kind: "fmi-sentence")).display(sentence-numbering),
  align(left, body),
))

// A highlighted note for things that still need to be done. All todos are listed after
// the table of contents. Hidden with `show-todos: false`.
#let todo(..body) = context if show-todos-state.final() {
  let c = get-colors()
  let body = body.pos().join()
  [#metadata(body)<fmi-todo>]
  highlight(
    fill: c.tint,
    text(fill: c.primary-dark, strong(translate("todo") + if body != none [:]) + if body != none [ #body]),
  )
}

// The list of all todos, each linked to its page.
#let list-todos() = context {
  let todos = query(<fmi-todo>)
  if show-todos-state.final() and todos.len() > 0 {
    let c = get-colors()
    set text(fill: c.primary-dark)
    strong(translate("todo") + ":")
    list(..todos.map(it => link(it.location(), {
      strong[#translate("page") #counter(page).at(it.location()).first()]
      if it.value != none [: #it.value]
    })))
  }
}

// A short note in the outer page margin, next to the line where it is used.
// Hidden with `show-todos: false`.
#let sidenote(body) = context if show-todos-state.final() [#metadata(body)<fmi-sidenote>]

// Draws the side notes of the current page into the outer margin. `fsu` uses this as
// the page background. `margin` is the page margin, as passed to `page`.
#let sidenote-layer(margin) = context {
  let notes = query(<fmi-sidenote>).filter(it => it.location().page() == here().page())
  if notes.len() > 0 {
    let margin-at(..keys) = {
      if type(margin) != dictionary { return margin }
      for key in keys.pos() {
        if key in margin { return margin.at(key) }
      }
      2.5cm
    }

    // With `inside` and `outside` margins, the outer margin is on the left on even pages.
    let two-sided = type(margin) == dictionary and "outside" in margin
    let on-left = two-sided and calc.even(counter(page).get().first())
    let width = if two-sided { margin-at("outside", "x", "rest") } else { margin-at("right", "x", "rest") }
    let gap = 0.25cm
    let dx = if on-left { gap } else { page.width - width + gap }

    let c = get-colors()
    for note in notes {
      place(top + left, dx: dx, dy: note.location().position().y, block(width: width - 2 * gap, {
        set par(justify: false, leading: 0.5em)
        set text(size: 0.7em, fill: c.primary)
        set align(if on-left { right } else { left })
        note.value
      }))
    }
  }
}

// Formats `body` as a quotation, indented and slightly smaller, with its `source`
// below it.
#let blockquote(body, source: none) = quote(block: true, attribution: source, body)
