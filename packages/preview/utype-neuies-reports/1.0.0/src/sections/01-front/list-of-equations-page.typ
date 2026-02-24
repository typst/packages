#import "/src/styles/list-of-equations-style.typ": list-of-equations-style

// Matematiksel Denklem Listesi sayfası. [Equation List page.]
#let list-of-equations-page() = {
  // Matematiksel Denklem listelerinin stilini uygula. [Apply the style of the equation figure lists.]
  list-of-equations-style(outline())

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
