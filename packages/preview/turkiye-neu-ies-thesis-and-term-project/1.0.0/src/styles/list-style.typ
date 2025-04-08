#import "/src/constants/numbering-constants.typ": LIST-NUMBERING

// Liste stili. [List style.]
#let list-style(content) = {
  let body-indent-size = 0.4cm
  let indent-size = 0.5cm
  // Numaralı liste stili [Numbered list style]
  set enum(
    body-indent: body-indent-size,
    full: false,
    indent: indent-size,
    number-align: end + top,
    numbering: LIST-NUMBERING,
    reversed: false,
    spacing: auto,
    start: auto,
    tight: true,
  )

  // Madde işaretli liste stili [Bulleted list style]
  set list(
    body-indent: body-indent-size,
    indent: indent-size,
    marker: (sym.circle.filled, sym.circle.stroked, sym.square.filled),
    spacing: auto,
    tight: true,
  )

  content
}
