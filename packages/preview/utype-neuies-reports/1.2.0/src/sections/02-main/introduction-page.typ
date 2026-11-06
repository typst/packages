#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Giriş sayfası. [Introduction page.]
#let introduction-page() = [
  // Bölüm başlığını ekle. [Add section heading.]
  #heading(level: 1, upper(translator(key: language-keys.INTRODUCTION))) <bölüm-giriş>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/introduction-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.STATEMENT-OF-THE-PROBLEM)) <başlık-problem-durumu>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/statement-of-the-problem-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.THE-PURPOSE-OF-THE-STUDY)) <başlık-araştırmanın-amacı>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/the-purpose-of-the-study-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.THE-SIGNIFICANCE-OF-THE-STUDY)) <başlık-araştırmanın-önemi>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/the-significance-of-the-study-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.ASSUMPTIONS)) <başlık-sayıltılar-ya-da-varsayımlar>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/assumptions-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.LIMITATIONS))<başlık-sınırlılıklar>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/limitations-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.DEFINITIONS))<başlık-tanımlar>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/01-introduction/definitions-text.typ"

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  #pagebreak(weak: true)
]
