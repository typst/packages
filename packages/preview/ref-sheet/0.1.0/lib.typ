#let cheatsheet(
  title: [], 
  authors: (),
  write_title: false,
  font_size: 5.5pt,
  line_skip: 5.5pt,
  x_margin: 30pt,
  y_margin: 0pt,
  num_columns: 5,
  column_gutter: 4pt,
  numbered_units: false,
  body) = {

    let color_index = (
      rgb("ff595e"),
      rgb("ff751f"),
      rgb("E0A500"),
      rgb("B1B62B"),
      rgb("82BC24"),
      rgb("36949d"),
      rgb("1982c4"),
      rgb("4267ac"),
      rgb("565aa0"),
      rgb("6a4c93")
    )
      
    
    set page(paper: "a4",
             flipped: true,
             margin: (x: x_margin, y: y_margin))

    set text(size: font_size)

    set heading(numbering: "1.1")
             
    show heading: it => {
      let index = counter(heading).at(it.location()).first()
      let hue = color_index.at(calc.rem(index - 1, color_index.len()))
      let color = hue.darken(8% * (it.depth - 1))

      set text(white, size: font_size)
      block(
        radius: 1.0mm,
        inset: 1.0mm,
        width: 90%,
        above: line_skip,
        below: line_skip,
        fill: color,
        it
      )
    }

    let new_body = {
      if write_title {
        par[#title by #authors]
      }
      body
    }
    
    columns(num_columns, gutter: column_gutter, new_body)
}