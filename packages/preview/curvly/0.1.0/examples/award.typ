#{
  import "@preview/curvly:0.1.0": *

  set page(
    width:2in,
    height:2in,
    margin:.1in,
  )


  set text(black.lighten(35%), font:"Roboto", 20pt, weight:800, features:("smcp","c2sc"))

  place(
    center+horizon,
    rotate(
      117deg,
      text-on-circle("★ Award ★ winning  ", "", 1.8in, 360deg, 0deg,
                  show-design-aids:false,
                  circle-margin:.3em)
      )
  )
}
