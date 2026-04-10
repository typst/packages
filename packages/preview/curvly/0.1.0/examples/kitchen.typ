#{
  import "@preview/curvly:0.1.0": *

  set page(
    width:10in,
    height:10in,
    margin:.1in,
  )

  set par(spacing:50pt)

  // Center design to the page
  align(center+horizon, {

    set text(25pt, font:"OLD SPORT 02 ATHLETIC NCV", weight:900)
    text-on-arc("WHAT HAPPENS IN THE", 8.6in, 62deg)

    v(-95pt)
    image("frying_pan_paddle.png", width:107pt)

    v(-32pt)
    rotate(
      -8deg,
      block({

      skew(ax: -15deg,text(169pt, font:"BandBox Script", style:"oblique", features:("swsh", "cswh"))[Kitchen])

      place(
        top+left,
        dx:-21pt,
        dy:29pt,
        text(113pt, font:"BandBoxScriptSwashes")[o]
      )
    }))

    parbreak()

    v(118pt)
    text(40pt, font:"OLD SPORT 02 ATHLETIC NCV", tracking:5pt)[STAYS IN THE KITCHEN]
  })
}

