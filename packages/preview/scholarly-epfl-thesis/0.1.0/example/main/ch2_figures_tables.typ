#import "@preview/scholarly-epfl-thesis:0.1.0": flex-caption

= Tables and Figures

In this chapter we will see some examples of tables and figures.

== Tables

Let's see how to make a well designed table.

#let my-table = "figure(
  table(
    columns: 3,
    align: center,
    table.hline(),
    table.header(
      [name], [weight], [food],
    ),
    table.hline(stroke: 0.5pt),
    [mouse], [10 g], [cheese],
    [cat], [1 kg], [mice],
    [dog], [10 kg], [cats],
    [t-rex], [10 Mg], [dogs],
    table.hline(),
  ),
  caption: [A floating table.]
)"

#eval(my-table) <tab:esempio>

#lorem(20)

@tab:esempio is a floating table and was obtained with the following code:

#raw(block: true, lang: "typst", my-table)

#lorem(40)

== Figures

Let's see now how to put one or several images in your text. caption:
flex-caption([A floating figure with text typeset in "Utopia Latex", a font
provided in the template-folder for typesetting figures with greek characters.
The text has been "outlined" for best compatibility with the repro during the
printing.], [A floating figure]),

#let my-figure = "figure(
  image(\"../images/galleria_stampe.jpg\", width: 50%),
  caption: [A floating figure (the lithograph _Galleria di stampe_, of M.~Escher, obtained from http://www.mcescher.com/).]
)"

#eval(my-figure) <fig:galleria>

#figure(
  image("../images/galleria_stampe.jpg", width: 50%), caption: flex-caption(
    [A floating figure (the lithograph _Galleria di stampe_, of M.~Escher, obtained
      from http://www.mcescher.com/).], [A floating figure],
  ),
)

@fig:galleria is a floating figure and was obtained with the following code:
#raw(block: true, lang: "typst", my-figure)

#lorem(200)

#figure(
  // Typst doesn't yet support including PDFs, but you can convert PDF files to SVG with pdf2svg.
  // https://github.com/typst/typst/issues/145
  image("../images/some_vector_graphics.svg"), caption: flex-caption(
    [A floating figure with text typeset in "Utopia Latex", a font provided in the
      template-folder for typesetting figures with greek characters. The text has been "outlined"
      for best compatibility with the repro during the printing.], [A floating figure],
  ),
) <fig:vector_graphics>

// Subfigures are a work in progress.
// One potential candidate might be `subpar`, but it's still a WIP
// https://github.com/tingerrr/subpar

#show figure.where(kind: "fig1"): set figure(numbering: "(a)", supplement: [], gap: 5pt)

#figure(
  grid(
    columns: 2, gutter: 10pt, row-gutter: 1.5em, figure(
      image("../images/lorem.jpg", width: 100%), caption: [Asia personas duo], kind: "fig1",
    ), figure(
      image("../images/ipsum.jpg", width: 100%), caption: [Pan ma si], kind: "fig1",
    ), figure(
      image("../images/dolor.jpg", width: 100%), caption: [Methodicamente o uno], kind: "fig1",
    ), figure(
      image("../images/sit.jpg", width: 100%), caption: [Titulo debitas], kind: "fig1",
    ),
  ), caption: [Tu duo titulo debitas latente],
)

#lorem(100)

#lorem(100)

#lorem(100)

#lorem(100)
