// Utility functions provided by this template.

#let thesis-draft-state = state("thesis-draft", true)
#let thesis-color-state = state("thesis-color", true)


#let default-fonts = (
  body: "Times New Roman",
  sans: "Arial",
  mono: "Courier New"
)


// === TODO FUNCTIONS ===
#let todo(content, color: red) = {
  rect(
    fill: color.lighten(80%),
    stroke: color,
    radius: 3pt,
    inset: 5pt,
    width: 100%,
  )[*TODO:* #content]
}

#let todo-missing(content) = todo(content, color: rgb(204, 0, 204))
#let todo-check(content) = todo(content, color: rgb(204, 0, 0))
#let todo-revise(content) = todo(content, color: rgb(204, 102, 0))
#let todo-citation(content) = todo(content, color: rgb(204, 204, 0))
#let todo-language(content) = todo(content, color: rgb(102, 102, 204))
#let todo-question(content) = todo(content, color: rgb(0, 204, 0))
#let todo-note(content) = todo(content, color: rgb(51, 51, 51))

// === LAYOUT HELPERS ===
#let unnumbered-chapter(body) = {
  heading(level: 1, numbering: none, outlined: false, body)
}

// === CUSTOM FIGURE TYPES ===
#let algorithm(content, caption: none) = {
  figure(
    align(left)[
      #rect(
        width: 100%,
        stroke: 0.5pt + gray,
        inset: 10pt,
        content
      )
    ],
    caption: caption,
    supplement: "Algorithm",
  )
}

// === HIGHLIGHTING ===
#let important(content) = context {
  if thesis-color-state.get() {
    highlight(fill: yellow.lighten(60%), content)
  } else {
    emph(content)  // italic in non-colored mode
  }
}

// === CUSTOM BOXES ===
#let definition(title: "Definition", content) = context {
  if thesis-color-state.get() {
    rect(
      width: 100%,
      stroke: blue,
      radius: 3pt,
      inset: 10pt,
    )[
      #text(weight: "bold", fill: blue)[#title.] #content
    ]
  } else {
    rect(
      width: 100%,
      stroke: 0.5pt + gray,
      radius: 0pt,
      inset: 10pt,
    )[
      #text(weight: "bold")[#title.] #content
    ]
  }
}

#let theorem(title: "Theorem", content) = context {
  if thesis-color-state.get() {
    rect(
      width: 100%,
      stroke: green.darken(20%),
      radius: 3pt,
      inset: 10pt,
    )[
      #text(weight: "bold", fill: green.darken(20%))[#title.] #content
    ]
  } else {
    rect(
      width: 100%,
      stroke: 0.5pt + gray,
      radius: 0pt,
      inset: 10pt,
    )[
      #text(weight: "bold")[#title.] #content
    ]
  }
}

// === ABBREVIATIONS ===
// Common abbreviations used throughout the thesis
#let ie = [_i.e._]
#let eg = [_e.g._]
#let cf = [_cf._]
#let etal = [_et al._]
