// Sample document — exercises every component in lib.typ.

#import "/src/lib.typ": *

// ── document-level setup (copy into every worksheet) ──────────────────────

#set page(
  paper: "us-letter",
  margin: (x: 0.85in, top: 1in, bottom: 1in),
  header: [
    #set text(size: 9pt, style: "italic")
    #grid(
      columns: (1fr, 1fr),
      [Worksheet Title],
      align(right)[Subtitle],
    )
    #v(-6pt)
    #line(length: 100%, stroke: 0.4pt + black)
  ],
  footer: context [
    #set align(center)
    #set text(size: 9pt)
    #counter(page).display()
  ],
)

#set text(size: 11pt, font: "New Computer Modern")
#set par(justify: true)

#set heading(numbering: "1.1.")
#show heading.where(level: 1): it => {
  block(above: 18pt, below: 12pt)[
    #text(size: 14pt, weight: "bold", fill: kernelblue)[
      #counter(heading).display() #it.body
    ]
  ]
}
#show heading.where(level: 2): it => {
  block(above: 16pt, below: 8pt)[
    #text(size: 11pt, weight: "bold")[
      #counter(heading).display() #it.body
    ]
  ]
}

#set math.equation(numbering: none)

// ── title ─────────────────────────────────────────────────────────────────

#align(center)[
  #text(size: 20pt, weight: "bold")[Worksheet Title] \
  #v(2pt)
  #text(size: 13pt, weight: "bold")[Subtitle or topic area]
]
#v(4pt)

// ── opening description ───────────────────────────────────────────────────

#emph[
  Opening description goes here.
]

#v(8pt)

// ── kernelbox ──────────────────────────────────────────────────────────────
// For: the small set of facts everything else is derived from.

#kernelbox[
  + *First kernel fact.* A short, memorable statement.
  + *Second kernel fact.* Another one.
]

// ── definition ────────────────────────────────────────────────────────────
// For: introducing vocabulary before it's needed.

#definition("Kernel")[
  The minimal set of facts you commit to memory; everything else is
  derived from them rather than memorised separately.
]

// ── stepbox ───────────────────────────────────────────────────────────────
// For: a worked derivation. Title names the move, not the result.

#stepbox([Divide both sides by $cos^2(theta)$])[
  Starting from $sin^2(theta) + cos^2(theta) = 1$, divide every term by $cos^2(theta)$:
  $ (sin^2(theta))/(cos^2(theta)) + (cos^2(theta))/(cos^2(theta)) &= 1/(cos^2(theta)) \
    tan^2(theta) + 1 &= sec^2(theta) $
]

// ── appbox ────────────────────────────────────────────────────────────────
// For: showing where the material actually appears.
// Title is the first argument, body is second.

#appbox("In practice")[
  This identity lets you integrate $tan^2 x$ by rewriting it as
  $sec^2 x - 1$, which is on the standard antiderivative list.
]

#appbox("In signal processing")[
  A specific title can be passed when the application is concrete enough to name.
]

// ── workspace ─────────────────────────────────────────────────────────────
// For: space to work. Set the title to "" for no title.

#workspace(lines: 8, title: [Now derive $1 + cot^2(theta) = csc^2(theta)$ the same way.])

// ── problems ──────────────────────────────────────────────────────────────
// Auto-numbered. Reset with #problem-counter.update(0) if needed.

= Practice Problems

#problem(hint: "This is a hint, it's meant to be difficult to read.")[
  A straightforward problem to build confidence.
]
#answer[
  Answer to the problem would go here.
]

// ── nobreak ───────────────────────────────────────────────────────────────
// For: ensuring that related content stays on the same page.
#nobreak[
#problem[
  A problem requiring two or three steps.
]

#workspace(lines: 7, title: "")
]

#problem[
  A harder problem that requires connecting two ideas from this worksheet.

  (a) Try this #h(2em) (b) Then try this #h(2em) (c) Then try this
]
#answer[
  (a) 100

  (b) 200

  (c) 300
]
#workspace(lines: 7, title: "")

// ── blanks ────────────────────────────────────────────────────────────────
// For: fill-in-the-blank style questions inline.

The derivative of $sin(x)$ is #blanks(2cm), and the derivative of $cos(x)$ is #blanks(2cm).

#render-answers()
