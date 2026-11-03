#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography

// Bibliography — matches LaTeX \defbibenvironment (0.74cm min label, right-aligned)
#let makereferences() = {
  heading(level: 1, numbering: none, outlined: true)[参考文献]
  gb7714-bibliography(title: none, full-control: entries => {
    context {
      let widest = entries.fold(0, (acc, e) => if e.order > acc { e.order } else { acc })
      let label-w = measure("[" + str(widest) + "]").width + 4pt
      if label-w < 0.74cm { label-w = 0.74cm }

      for e in entries {
        grid(
          columns: (label-w, 1fr),
          align(right + top, "[" + str(e.order) + "]"),
          e.labeled-rendered,
        )
        parbreak()
      }
    }
  })
}
