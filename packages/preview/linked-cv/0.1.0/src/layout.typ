#import "colours.typ": colours
#import "typography.typ"

#let layout(
  firstname,
  lastname,
  doc,
) = {
  set page(
    paper: "a4",
    margin: (
      left: 1.25cm,
      right: 1.25cm,
      top: 1.0cm,
      bottom: 1.25cm,
    ),
    footer: context [
      #set align(center)
      #typography.footer[
        #firstname #lastname · Curriculum Vitae
        #h(1fr)
        #counter(page).display("1")
      ]
    ],
    footer-descent: 0.5cm,
  )

  context {
    let body-font = typography.get-body-font()
    let headings-font = typography.get-headings-font()

    set text(
      font: body-font,
      size: 9pt,
      fill: colours.text,
      fallback: false,
    )

    set par(
      justify: false,
      leading: 0.65em,
    )

    set list(
      indent: 0em,
      body-indent: 1em,
      marker: place(dy: 0.25em, text(size: 0.33em, "■")),
    )

    show heading.where(level: 1): it => {
      set text(size: 16pt, weight: "bold", font: headings-font, fill: colours.text)
      it.body
    }

    doc
  }
}
