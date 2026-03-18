#let cheatsheet(
  title: [], 
  authors: (),
  write-title: false,
  font-size: 5.5pt,
  line-skip: 5.5pt,
  x-margin: 30pt,
  y-margin: 0pt,
  num-columns: 5,
  column-gutter: 4pt,
  numbered-units: false,
  body) = {

    let color-index = (
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
             margin: (x: x-margin, y: y-margin))

    set text(size: font-size)

    set heading(numbering: "1.1")
             
    show heading: it => {
      let index = counter(heading).at(it.location()).first()
      let hue = color-index.at(calc.rem(index - 1, color-index.len()))
      let color = hue.darken(8% * (it.depth - 1))

      set text(white, size: font-size)
      block(
        radius: 1.0mm,
        inset: 1.0mm,
        width: 90%,
        above: line-skip,
        below: line-skip,
        fill: color,
        it
      )
    }

    let new-body = {
      if write-title {
        par[#title by #authors]
      }
      body
    }
    
    columns(num-columns, gutter: column-gutter, new-body)
}