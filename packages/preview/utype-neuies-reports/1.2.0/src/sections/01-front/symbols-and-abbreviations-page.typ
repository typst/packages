#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Simgeler ve Kısaltmalar sayfası. [Symbols and Abbreviations page.]
#let symbols-and-abbreviations-page(
  have-symbols: true,
  have-abbreviations: true,
) = {
  // Sayfa başlığını ekle. [Add page header.]
  heading(level: 1, upper(translator(key: language-keys.SYMBOLS-AND-ABBREVIATIONS)))

  // Semboller varsa Semboller sayfasını ekle. [Add Symbols page if have symbols.]
  if have-symbols {
    // Sayfa alt başlığını ekle. [Add page sub-header.]
    heading(level: 2, translator(key: language-keys.SYMBOLS))

    // Sayfa içeriğini ekle. [Add page content.]
    include "/template/sections/01-front/symbols-text.typ"

    // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
    pagebreak(weak: true)
  }

  // Kısaltmalar varsa Kısaltmalar sayfasını ekle. [Add Abbreviations page if have abbreviations.]
  if have-abbreviations {
    // Sayfa alt başlığını ekle. [Add page sub-header.]
    heading(level: 2, translator(key: language-keys.ABBREVIATIONS))

    // Sayfa içeriğini ekle. [Add page content.]
    include "/template/sections/01-front/abbreviations-text.typ"

    // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
    pagebreak(weak: true)
  }
}
