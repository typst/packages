#import "/src/styles/table-of-contents-style.typ": table-of-contents-style

// İçindekiler sayfası. [Table of Contents page.]
#let table-of-contents-page() = {
  // İçindekiler sayfasının stilini uygula. [Apply the style of the table of contents page.]
  table-of-contents-style(outline())

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
