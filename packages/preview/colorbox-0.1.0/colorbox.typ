#let colorbox(
  frame: (
    upper-color: black,
    lower-color: white,
    border-color: black,
    radius: 5pt, 
    width: 2pt, 
    dash: "solid"
  ),
  title-style: (
    color: white,
    weight: "bold",
    align: left
  ),
  body-style: (
    color: black,
    align: left
  ),
  title: "",
  body
) = {
  /*
   * Main container of the colorbox
   */
  rect(
    fill: frame.at("border-color", default: black),
    radius: frame.at("radius", default: 5pt),
    inset: 0pt,
    stroke: (
      paint: frame.at("border-color", default: black),
      dash: frame.at("dash", default: "solid"),
      thickness: frame.at("width", default: 2pt)
    )
  )[
    /*
     * Set rect spacing to avoid asimetric spacing 
     * inside rect's main container. And set par
     * spacing to avoid the previous rule to affect
     * text blocks.
     */
    #show rect: set block(spacing: 1pt)
    #show par: set block(spacing: 0.65em)

    /*
     * Title of the colorbox. We'll check if it is
     * empty. If so, skip its drawing and only put
     * the body
     */
    #if title != "" {      
      rect(
        inset:(x: 1em, y: 0.5em),
        width: 100%,
        fill: frame.at("upper-color", default: black),
        radius: (top: frame.at("radius", default: 5pt)))[
          #align(
            title-style.at("align", default: left),
            text(
              title-style.at("color", default: white),
              weight: title-style.at("weight", default: "bold"),
              title
            )
          )
      ]
    } // Otherwise, don't put a title

    /*
     * Body of the colorbox
     */
    #rect(
      fill: frame.at("lower-color", default: white),
      width: 100%, 
      inset:(x: 1em, y: 0.75em),
      radius: 
        if title != "" {
          (bottom: frame.at("radius", default: 5pt))
        } else {
          frame.at("radius", default: 5pt)
        }
    )[
      // Content
      #align(
        body-style.at("align", default: left),
        text(body-style.at("color", default: black), body)
      )
    ]
  ]
}
