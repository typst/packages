#let bibx(bib, main: false) = {
  counter("bibs").step()

  context if main {
    [#bib <bib-main>]
  } else if query(<bib-main>) == () and counter("bibs").get().first() == 1 {
    bib
  }
}
