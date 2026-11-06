#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Ekler sayfası. [Appendices page.]
#let appendices-page() = [
  // Başlık numarlandırmasını 1'den başlat. [Start heading numbering from 1.]
  #counter(heading).update(1)

  // Bölüm başlığını ekle. [Add a chapter heading.]
  #heading(level: 1, upper(translator(key: language-keys.APPENDICES))) <bölüm-ekler>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/03-back/appendices/appendices-text.typ"

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  #pagebreak(weak: true)
]
