#import "@preview/tudelft-thesis-novanext:0.1.0": *
#import "@preview/lilaq:0.6.0" as lq
#show: lq.theme.skyline

#{
  pagebreak(to: "even", weak: true)
  set page(
    header: [],
    footer: [],
    background: context place(
      image(
        "tud-bieb.jpg",
        width: 2 * page.width,
        height: 1 * page.height,
      )
    )
  )
  {
    v(1fr)
    show cite: set text(white)
    cite(<tud-bieb>, form: "prose")
  }
  show heading: set text(fill: white)
  pagebreak()
  set page(background: context{
    place(
      dx: -page.width,
      image("tud-bieb.jpg",
      width: 2 * page.width,
      height: page.height,
      ),
    )
    place(
      rect(width: page.width, height: page.height, fill: gradient.linear(dir: ltr, black.transparentize(100%), black.transparentize(50%)))
    )
  })
  [= Appendix]
}

Various plot types are possible.#footnote[https://lilaq.org/docs/plot-types]

== Section

#figure({
    let x = lq.linspace(0, 10)
    lq.diagram(
      lq.plot(x, x => calc.sin(x + 0.541))
    )
  },
  caption: [Some line plot]
)

= One more chapter
Various themes are available.#footnote[https://lilaq.org/themes]
== Section

#figure(
lq.diagram(
  lq.quiver(
    lq.arange(-2, 3),
    lq.arange(-2, 3),
    (x, y) => (x + y, y - x)
  )
),
caption: [Some quiver plot]
)