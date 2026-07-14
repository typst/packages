/// حزمة na-arabox لإنشاء صناديق عربية تدعم RTL.
#let na-arabox(
  title: none,
  title-align: center,
  title-dx: 0pt,
  title-fill: black,
  title-stroke: black,
  title-text: white,
  title-radius: 4pt,
  fill: luma(240),
  stroke: black,
  radius: 4pt,
  body-inset: (left: 10pt, right: 10pt, top: 18pt, bottom: 10pt),
  body
) = {
  set text(dir: rtl)
  
  block(
    breakable: true,
    fill: fill,
    stroke: 1pt + stroke,
    radius: radius,
    width: 100%,
    inset: (top: 0pt, x: 0pt, bottom: 0pt), 
    [
      #if title != none {
        place(top + title-align, dy: -0.9em, dx: title-dx,
          block(
            fill: title-fill,
            stroke: 0.5pt + title-stroke,
            radius: title-radius,
            inset: (x: 8pt, y: 8pt), 
            text(weight: "bold", fill: title-text, size: 0.9em, title)
          )
        )
      }
      #block(
        width: 100%,
        inset: body-inset,
        body
      )
    ]
  )
}
