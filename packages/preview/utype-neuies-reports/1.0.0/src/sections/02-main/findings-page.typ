#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Bulgular sayfası. [Findings page.]
#let findings-page() = [
  // Bölüm başlığını ekle. [Add section heading.]
  #heading(level: 1, upper(translator(key: language-keys.FINDINGS))) <bölüm-bulgular>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/04-findings/findings-text.typ"

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  #pagebreak(weak: true)
]
