#{
  import "@preview/litfass:0.1.1" 
  import "@preview/ccicons:1.0.1": *
  let poster = litfass.render.poster

  import litfass.tiling: *

  set page(paper: "a4")
  set text(8pt)

  let toprow = vs(
    cut: 33%,
    cbx([#lorem(70) #parbreak() #lorem(30)], title: [Foo]),
    vs(
      cut: 50%,
      cbx([
        #figure(
          image("Litfassseaule.JPG"),
          caption: [
            Litfass column at Hamburg Neustadt-Süd Großneumarkt  #box-footnote[
              URL: #link("https://commons.wikimedia.org/wiki/File:Hamburg_Neustadt-Süd_Großneumarkt_Litfaßsäule.JPG", [https://commons.wikimedia.org/wiki/File:Hamburg] + "\u{00AD}" + [\_Neustadt-Süd\_Großneumarkt] + "\u{00AD}" + [\_Litfaß] + "\u{00AD}" + [säule.JPG])
              \
              LICENCE: Susanne Mu, #ccicon("cc-by-sa/3.0", link:true)
            ]
          ]
        )
      ]),
      cbx(
        [
          #lorem(50)

          Lorem ipsum dolor sit amet, consectetur #box-footnote[You can]
          adipiscing elit, sed do eiusmod tempor incididunt #box-footnote[place random footnotes]
          ut labore et dolore magnam aliquam #box-footnote[throughout a box!]
          quaerat voluptatem.
        ],
        title: [Bar]
      )
    )
  )

  let botrow = vs(
    cut: 33%, 
    cbx(lorem(50), title: [Bar]),
    vs(
      cut: 50%,
      cbx(lorem(51), title: [This is a long title that takes up more space]),
      cbx(lorem(50), title: [Important], theme: (box: (title: (background: red))))
    )
  )

  let body = hs(
    cut: 40%,
    toprow,
    hs(
      cut: 60%,
      cbx(
        grid(
          columns: (1fr, 1fr),
          gutter: 1em,
          lorem(200),
          lorem(200)
        ),
        title: [Big Center Block]),
      botrow 
    ),
    theme: (box: (background: 95%))
  )


  let title = cbx(
    [ 
      #set align(center)
      #set text(fill: white)
      #text(2.5em, weight: "bold")[Super Important Research About Complex Stuff]
      #v(-1em)
      #block(width: 70%, grid(
        columns: (1fr, 1fr),
        [
          #set par(spacing: 0.25em)
          Max Markov \
          #text(0.9em)[_Statistical University_ \
          Circle, Flatland]
        ],
        [
          #set par(spacing: 0.25em)
          Ernst Litfaß \
          #text(0.9em)[Berlin, Germany]
        ]
      ))
    ],
    theme: (box: (background: litfass.themes.basic.box.title.background), padding: 0em)
  )
  let layout = hs(
    cut: 9em,
    title,
    body
  )

  poster(layout)
}
