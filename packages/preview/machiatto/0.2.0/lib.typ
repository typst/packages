#import "@preview/suboutline:0.3.0": *

#let acknowledgement(fill: color.linear-rgb(245, 225, 164), content) = {
  align(center + horizon)[
    #box(
      fill: fill,
      stroke: 1pt + black,
      radius: 10pt,
      inset: (x: 2em, y: 2em),
    )[
      #text(size: 24pt, weight: "bold")[Acknowledgments]

      #content
    ]
  ]
}

#let minitoc(
) = {
  v(5pt)
  suboutline(
    indent: 0pt,
  )
}

#let doc(
  title: "",
  author: "",
  paper-size: "a4",
  license: none,
  ack: none,
  preface: none,
  toc: true,
  chapter-pagebreak: true,
  bibliography: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: author, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "New Computer Modern", lang: "en")
  show math.equation: set text(weight: 400)

  align(center + horizon)[
    #block(inset: 100pt, radius: 5pt, stroke: 1pt)[
      #text(2.5em, weight: 700, title)

      *#author*
    ]
  ]
  pagebreak()

  if (license != none) {
    license
    pagebreak()
  }

  // License

  // Acknowledgement

  acknowledgement(ack)
  pagebreak()

  if (preface != none) {
    preface
    pagebreak()
  }

  if (toc) {
    outline()
    pagebreak()
  }

  // Main body.

  set page(paper: paper-size)
  set par(leading: 0.7em, spacing: 1.35em, justify: false, linebreaks: "simple")

  // Configure page numbering and footer.

  set page(
    footer: context {
      // Get current page number.

      let i = counter(page).at(here()).first()

      // Align right for even pages and left for odd.

      let is-odd = calc.odd(i)
      let aln = if is-odd {
        right
      } else {
        left
      }

      // Are we on a page that starts a chapter?

      let target = heading.where(level: 1)
      if query(target).any(it => it.location().page() == i) {
        return align(aln)[#i]
      }

      // Find the chapter of the section we are currently in.

      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()
        let gap = 1.75em
        let chapter = upper(text(size: 0.68em, current.body))
        if current.numbering != none {
          if is-odd {
            align(aln)[#chapter #h(gap) #i]
          } else {
            align(aln)[#i #h(gap) #chapter]
          }
        }
      }
    },
  )

  // Configure equation numbering.

  set math.equation(numbering: "(1)")

  {
    // Configure heading numbering.
    set heading(numbering: "1.")

    // Start chapters on a new page.

    show heading.where(level: 1): it => {
      if chapter-pagebreak {
        pagebreak(weak: true)
      }
      it
    }
    body
  }

  if bibliography != none {
    pagebreak()
    show std-bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.

    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bibliography
  }
}

#let def(title: none, fill: color.rgb("E0F2F1"), body) = {
  block(
    width: 100%,
    inset: 10pt,
    fill: fill,
    radius: 5pt,
    stroke: 1pt,
    [
      #text(weight: "bold")[#underline(stroke: 1pt)[Definition: #title]]

      #body
    ],
  )
}

#let todo(body) = {
  block(
    width: 100%,
    inset: 10pt,
    fill: yellow,
    radius: 4pt,
    [
      #text(weight: "bold")[TODO]

      #body
    ],
  )
}

#let note(body) = {
  block(
    width: 100%,
    inset: 10pt,
    fill: color.rgb("FFECB3"),
    radius: 4pt,
    stroke: 1pt,
    [
      #text(weight: "bold")[Note:]

      #body
    ],
  )
}

#let frame(title: none, body, fill: none, line-numbers: true, line-number-color: gray) = {
  let stroke = black + 1pt
  let radius = 5pt

  box(stroke: stroke, radius: radius)[
    #if title != none {
      block(
        stroke: stroke,
        fill: fill,
        inset: 0.5em,
        width: 100%,
        below: 0em,
        radius: (top-left: radius, top-right: radius),
        align(center)[*#title*],
      )
    }
    #block(
      width: 100%,
      inset: (x: 0em, y: 0.5em),
      {
        if line-numbers {
          // Split the body into lines
          let lines = body.text.split("\n")
          // Create a table with line numbers and code

          table(
            columns: (auto, 1fr),
            inset: (x: 0.4em, y: 0.3em),
            stroke: (y: 0.5pt + rgb(220, 220, 220)),
            ..lines.enumerate().map(((i, line)) => {
              (
                align(right)[#text(fill: line-number-color)[#(i + 1)]],
                align(left)[#raw(lang: body.lang, line)]
              )
            }).flatten(),
          )
        } else {
          body
        }
      },
    )
  ]
}

#let code-file(title: "", file-content: "", lang: "", fill: color, line-numbers: true, line-number-color: gray) = {
  frame(
    title: title,
    fill: fill,
    line-numbers: line-numbers,
    line-number-color: line-number-color,
    [#raw(file-content, lang: lang)],
  )
}

#let code-snippet(title: "", file-content: "", subtitle: none, lang: "", fill: color, line-numbers: true, line-number-color: gray, from: 0, to: int) = {
  // 1. Read the entire file as a string
  let content = file-content

  // 2. Split on newlines → array of lines

  let lines = content.split("\n")

  // 3. Take only the lines in [from, to)

  let selection = lines.slice(from, to)

  // 4. Re-join into one multi-line string

  let snippet = selection.join("\n")

  // 5. Return as a raw block (verbatim)

  if (subtitle != none) {
    title = title + " - " + subtitle
  }
  frame(
    title: title,
    fill: fill,
    line-numbers: line-numbers,
    line-number-color: line-number-color,
    [#raw(snippet, lang: lang)],
  )
}

#let terminal(
  title: none,
  // Title for the terminal
  content,
  // The body content
  fill: color.luma(15%),
  // Background color of the terminal
  text-color: white,
  // Text color for the terminal content
  title-color: luma(240),
  // Title bar text color
  title-bg-color: color.black,
  // Title bar background color
  radius: 6pt,
  // Corner radius
) = {
  let stroke = black + 1pt // Border color and width

  // Outer box for the terminal

  box(stroke: stroke, radius: radius)[
    // Title bar (if title is provided)
    #if title != none {
      box(
        fill: title-bg-color,
        inset: 0.5em,
        radius: (top-left: radius, top-right: radius),
        width: 100%,
        align(center)[#text(fill: title-color)[*#title*]],
      )
    }
    // Terminal content area
    #box(
      fill: fill,
      inset: (x: 1em, y: 0.7em),
      radius: (bottom-left: radius, bottom-right: radius),
      width: 100%,
      text(fill: text-color)[#content],
    )
  ]
}

#let info-box(body, title: "Info:") = {
  rect(
    stroke: (
      "left": 1pt + color.maroon,
    ),
    fill: color.rgb("eeeeee"),
    [
      *#title*
      #body
    ],
  )
}
