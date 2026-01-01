#import "/src/styles/list-of-code-figures-style.typ": list-of-code-figures-style

// Kod Listesi sayfası. [List of Code Figures page.]
#let list-of-code-figures-page() = {
  // Kod listelerinin stilini uygula. [Apply the style of the code figure lists.]
  list-of-code-figures-style(outline())

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
