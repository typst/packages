// Ana hattın girdilerindeki doldurma stili. [Outline entry's fill style.]
#let outline-entry-fill-style(content) = {
  // Ana hattaki girdi satırlarının içeriğindeki doldurma stili. [Outline entry content's fill style.]
  set outline.entry(fill: repeat(justify: true, gap: 0.1em)[.])

  content
}
