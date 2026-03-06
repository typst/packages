// Children's Book Template for Typst
// Designed for early readers with large, legible text and full-page illustrations.

#let childrens-book(
  title: "My Book",
  author: "Author Name",
  illustrator: none,
  // Page size: A5 (148mm x 210mm), a compact format well suited for children's books
  page-width: 148mm,
  page-height: 210mm,
  // Typography
  font-family: "New Computer Modern",
  font-size: 18pt,
  line-spacing: 1.4em,
  // Colors
  title-color: rgb("#2b4c7e"),
  text-color: rgb("#333333"),
  body,
) = {
  // Page setup
  set page(
    width: page-width,
    height: page-height,
    margin: (
      top: 15mm,
      bottom: 15mm,
      left: 15mm,
      right: 15mm,
    ),
    numbering: none,
  )

  // Text defaults: large, readable font for early readers
  set text(
    font: font-family,
    size: font-size,
    fill: text-color,
    lang: "en",
  )

  set par(
    leading: line-spacing,
    justify: false,
  )

  // --- Title page ---
  {
    set align(center + horizon)
    block(
      text(size: 36pt, weight: "bold", fill: title-color, title),
    )
    v(8mm)
    text(size: 22pt, fill: title-color.lighten(20%), author)
    if illustrator != none {
      v(5mm)
      text(size: 16pt, fill: title-color.lighten(40%), [Illustrated by #illustrator])
    }
    pagebreak()
  }

  // Turn on page numbers after title page
  set page(
    numbering: "1",
    footer: context {
      let num = counter(page).display("1")
      align(center, text(size: 10pt, fill: luma(120), num))
    },
  )
  counter(page).update(1)

  body
}

// Place a full-page illustration that fills the entire page (ignoring margins).
// `caption` is optional small text at the bottom.
#let full-page-illustration(content, caption: none) = {
  set page(
    margin: 0pt,
    footer: context {
      let num = counter(page).display("1")
      place(bottom + center, dy: -8pt, text(size: 10pt, fill: luma(200), num))
    },
  )
  set align(center + horizon)
  block(
    width: 100%,
    height: 100%,
    clip: true,
    content,
  )
  if caption != none {
    place(
      bottom + center,
      dy: -0.4in,
      text(size: 14pt, fill: white, caption),
    )
  }
  pagebreak()
}

// A text page with generous padding, centered vertically.
#let story-page(body) = {
  set align(left + horizon)
  block(
    width: 100%,
    body,
  )
  pagebreak()
}

// A spread with an illustration on top and text below, for pages
// that combine art and story.
#let illustrated-page(illustration, body) = {
  set align(center)
  v(0.2in)
  block(
    width: 100%,
    height: 45%,
    clip: true,
    illustration,
  )
  v(0.3in)
  set align(left)
  body
  pagebreak()
}

// Book part heading - a large heading that takes up its own page
#let book-part(title, color: rgb("#2b4c7e"), subtitle: none) = {
  set align(center + horizon)
  block(
    text(size: 42pt, weight: "bold", fill: color, title),
  )
  if subtitle != none {
    v(10mm)
    text(size: 20pt, fill: color.lighten(30%), subtitle)
  }
  pagebreak()
}

// "The End" closing page
#let the-end(color: rgb("#2b4c7e"), ending: "The End") = {
  set align(center + horizon)
  text(size: 36pt, weight: "bold", fill: color, ending)
  pagebreak()
}
