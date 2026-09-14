#let info-page(
  authors,
  title,
  date,
  date-format,
  pdf-version,
) = {

  // ---------- Page Setup ---------------------------------------

  set page(
    margin: (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm),
  )

  // ---------- Info at Bottom of Page ---------------------------------------

  place(
    bottom + left,
    {
      for author in authors {
        text(size: 11pt, [#author.name: #title, © #date.display(date-format)])
        linebreak()
      }
      v(1em)
      text(size: 9pt, fill: luma(100), [Version: #pdf-version])
    }
  )
}
