#import "layout.typ": *

#let init-theorem(it) = {
  // 1. Suppress default figure layout for theorems so we only see your custom styling
  show figure.where(kind: "theorem"): it => align(
    left,
    it.body,
  )

  // 2. Reset the shared theorem counter every time a top-level section (Heading 1) begins
  show heading.where(level: 1): it => {
    counter(figure.where(kind: "theorem")).update(0)
    it
  }

  // 3. Custom reference logic for @tag and @tag[!]
  show ref: it => {
    let el = it.element
    if (
      el != none
        and el.func() == figure
        and el.kind == "theorem"
    ) {
      let loc = el.location()

      // Calculate the "x.x" numbering string
      let h1 = counter(heading).at(loc).at(0, default: 0)
      let thm-num = counter(figure.where(kind: "theorem"))
        .at(loc)
        .at(0)
      let num-str = if h1 == 0 { str(thm-num) } else {
        str(h1) + "." + str(thm-num)
      }

      // Handle @tag[!]
      if it.supplement == [!] {
        if el.caption != none {
          // Return the title as the clickable link
          return link(loc, el.caption.body)
        } else {
          // Fallback if no title was provided
          return link(loc, [#el.supplement #num-str])
        }
      } else {
        // Standard @tag will now use the full-name (supplement)
        return link(loc, [#el.supplement #num-str])
      }
    }
    return it
  }
  it
}

// Make a theorem environment.
#let make-environment(
  full-name,
  short-name,
  accent-color,
) = {
  return (..args) => {
    let pos = args.pos()
    let title = none
    let body = none

    if pos.len() == 1 {
      body = pos.at(0)
    } else if pos.len() == 2 {
      title = pos.at(0)
      body = pos.at(1)
    } else {
      panic(
        "Theorem environments expect exactly 1 or 2 positional arguments.",
      )
    }

    figure(
      kind: "theorem",
      supplement: full-name, // Injects the full name (e.g., "Theorem") into the reference
      caption: title,
      outlined: false,
    )[
      #context {
        let loc = here()
        let h1 = counter(heading).at(loc).at(0)
        let thm-num = counter(figure.where(kind: "theorem"))
          .at(loc)
          .at(0)
        let num-str = str(h1) + "." + str(thm-num)

        theorem-render(
          short-name,
          title,
          num-str,
          body,
          color: accent-color,
        )
      }
    ]
  }
}

#let theorem = make-environment(
  "Theorem",
  "THM",
  rgb("#1e3a8a"),
)
#let lemma = make-environment(
  "Lemma",
  "LEM",
  rgb("#065f46"),
)
#let proposition = make-environment(
  "Proposition",
  "PROP",
  rgb("#5b21b6"),
)
#let corollary = make-environment(
  "Corollary",
  "COR",
  rgb("#0e7490"),
)
#let definition = make-environment(
  "Definition",
  "DEF",
  rgb("#991b1b"),
)
#let example = make-environment(
  "Example",
  "EX",
  rgb("#475569"),
)
#let remark = make-environment(
  "Remark",
  "REM",
  rgb("#854d0e"),
)

#let proof(..args) = {
  let pos = args.pos()
  let title = none
  let body = none

  if pos.len() == 1 {
    body = pos.at(0)
  } else if pos.len() == 2 {
    title = pos.at(0)
    body = pos.at(1)
  } else {
    panic(
      "Proof environment expect exactly 1 or 2 positional arguments.",
    )
  }
  block(
    width: 100%,
    breakable: true,
  )[
    _Proof#if title != none { [ #title] }._ #body #h(1fr) #sym.square
  ]
}
