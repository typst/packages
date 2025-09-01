#import "@preview/pointless-size:0.1.1": zh



#let thesis-figure(image, caption:"", note: none, label: none) = {
  // Use a 五号字 size for text
  set text(size: zh(5))
  block(breakable: true)[
    #figure(
      image,
      caption: [#caption],
      placement: none,
      kind: "image",
      outlined: true,
      supplement: [图],
    )

    #if note != none {
      block(above: 6pt, below: 6pt)[#note]
    }
  ]
}



// #let thesis-figure-bak(image_path, caption, width: 100%, note: none, label: none) = {
//   // Use a 五号字 size for text
//   set text(size: zh(5))
//   show figure.where(kind: image): set block(breakable: true)
//   align(center, figure(
//     image(image_path, width: if image_path.ends-with(".svg") { 100% } else { width }),
//     caption: [#caption],
//     placement: none,
//     kind: image,
//     outlined: true,
//     supplement: [图],
//   ))
}




