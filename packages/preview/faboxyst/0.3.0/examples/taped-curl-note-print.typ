// Print-mode grayscale proof for the taped paper note.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #taped-curl-note(
      body: [• You can replace this sample text.#linebreak()• Capture one useful idea.#linebreak()• Return to it when needed.],
      width: 5.9cm,
      height: 6.8cm,
    )
  ]
]
