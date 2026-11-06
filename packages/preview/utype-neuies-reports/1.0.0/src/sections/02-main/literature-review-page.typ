#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Alan Yazın (İlgili Araştırmalar) sayfası. [Literature Review page.]
#let literature-review-page() = [
  // Bölüm başlığını ekle. [Add section heading.]
  #heading(level: 1, upper(translator(key: language-keys.LITERATURE-REVIEW))) <bölüm-ilgili-araştırmalar>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/02-literature-review/literature-review-text.typ"

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  #pagebreak(weak: true)
]
