// Gallery renders for heading styles
#import "@preview/beautitled:0.1.0": *

#set page(width: 16cm, height: 16cm, margin: 0.9cm)
#set text(font: "Linux Libertine", size: 10pt)

#let style-sample(name) = [
  #reset-counters()
  #beautitled-setup(
    style: name,
    show-chapter-number: true,
    show-section-number: true,
    show-subsection-number: true,
    chapter-prefix: "Chapter",
    section-prefix: "Section",
  )

  #chapter[Sample Chapter]
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.

  #section[Core Concepts]
  Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

  #subsection[Key Terms]
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
]

#style-sample("titled")
#pagebreak()
#style-sample("classic")
#pagebreak()
#style-sample("modern")
#pagebreak()
#style-sample("elegant")
#pagebreak()
#style-sample("bold")
#pagebreak()
#style-sample("creative")
#pagebreak()
#style-sample("minimal")
#pagebreak()
#style-sample("vintage")
#pagebreak()
#style-sample("schoolbook")
#pagebreak()
#style-sample("notes")
#pagebreak()
#style-sample("clean")
#pagebreak()
#style-sample("technical")
#pagebreak()
#style-sample("academic")
#pagebreak()
#style-sample("textbook")
#pagebreak()
#style-sample("scholarly")
#pagebreak()
#style-sample("classical")
#pagebreak()
#style-sample("educational")
#pagebreak()
#style-sample("structured")
#pagebreak()
#style-sample("magazine")
