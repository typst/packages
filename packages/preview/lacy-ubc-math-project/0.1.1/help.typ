#let font-size = 10pt

#let sections = (
  "introduction",
  "getting-started",
  "setup",
  "author",
  "math",
  "drawing",
  "question",
  "solution",
  "caveats",
)

#let help-setup(body) = {
  show raw.where(block: false): r => box(
    fill: black.transparentize(95%),
    radius: 0.4em,
    inset: 0.35em,
    baseline: 0.35em,
    r,
  )

  body
}

#let help = (:)
#for section in sections {
  help.insert(
    section,
    block(
      width: 100%,
      inset: font-size,
      stroke: blue + 0.5pt,
      [
        #set text(size: font-size)
        #set heading(outlined: false)

        #text(fill: gray)[User Manual]
        #v(font-size * 0.5, weak: true)

        #show: help-setup
        #include "manuals/" + section + ".typ"
        #import "shorthand.typ": hrule
        #hrule

        #context v(par.spacing * -0.5)

        #text(
          size: font-size * 0.8,
          [
            Other helps: #sections.filter(s => s != section).map(s => raw(s)).join(", ").
          ],
        )
      ],
    ),
  )
}
