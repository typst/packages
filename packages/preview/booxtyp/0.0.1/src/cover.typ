#import "colors.typ": color-schema

#let cover(
  title,
  image-content,
  authors: (),
  bar-color: color-schema.orange.primary,
) = {
  // Set page
  set page(margin: (x: 0pt, y: 0pt))

  // Cover image
  set image(width: 100%, height: 40%)
  image-content

  // Remove the whitespace between the image and the rectangle
  v(-14pt)

  // Rectangle
  rect(width: 100%, height: 10%, fill: bar-color)

  block(inset: 12pt)[
    // Book title
    #text(weight: "extrabold", size: 32pt)[
      #title
    ]

    // Some space
    #v(12pt)

    // Authors
    #text(weight: "bold", size: 16pt, fill: color-schema.gray.primary)[
      #authors.join(v(0pt))
    ]
  ]

  // Reset page counter
  counter(page).update(0)
}
