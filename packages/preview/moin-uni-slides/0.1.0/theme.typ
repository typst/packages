#import "@preview/polylux:0.4.0": *

#let uni-red = rgb(213, 12, 47)
#let uni-blue = rgb(0, 50, 109)
#let box-grey = rgb(216, 216, 216)

#let theme(title: "", author: "", date: datetime.today(), lang: "de", body) = {
  set document(author: author, date: date, title: title)
  
  set text(size: 18pt, font: "Arial", lang: lang, top-edge: 0.84em)

  let background = {
    // Header
    place(
      top + left,
      dx: 1.23cm,
      dy: 0.8cm,
      grid(
        columns: (20.63cm, 6.23cm, auto),
        image(
          height: 1.32cm,
          "images/UniBremen_Logo_Rot-Schwarz_Web_NICHT_VERAENDERN.png"
        ),
        block(
          width: 4.28cm,
          height: 1.24cm,
          text(
            size: 9pt,
            weight: "bold",
            top-edge: "cap-height",
            title
          )
        ),
        block(
          width: 5.15cm,
          height: 1.24cm,
          text(
            size: 9pt,
            top-edge: "cap-height",
            [#author \ Bremen #date.display("[day].[month].[year]")]
          )
        )
      )
    )
    // Progressbar
    place(
      bottom + left,
      toolbox.progress-ratio(ratio => 
        rect(
          width: ratio * 100%,
          height: 0.5em,
          fill: uni-blue,
          stroke: none,
        )
      )
    )
  }

  let footer = align(right, text(top-edge: "cap-height", toolbox.slide-number))
  
  set page(
    background: background,
    footer: footer,
    margin: (top: 4.71cm, bottom: 1.73cm, left: 5.63cm, right: 2.837cm),
    width: 33.867cm,
    height: 19.05cm,
  )

  show heading: it => context {
    let all_h1 = query(heading)
    
    let first_on_page = all_h1.find(h => h.location().page() == here().page())
    
    if it.location() == first_on_page.location() {
      set text(size: 36pt, top-edge: 0.48em)
      pad(
        bottom: 1.74cm,
        block(it)
      )
    } else {
      block(it)
    }
  }

  set list(marker: n => {
    if n == 0 [➔]
    else [-]
  })

  body
}

#let important(body) = {
    set text(fill: uni-red)
    body
}