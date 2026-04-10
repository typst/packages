#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Yöntem sayfası. [Methodology page.]
#let methodology-page() = [
  // Bölüm başlığını ekle. [Add section heading.]
  #heading(level: 1, upper(translator(key: language-keys.METHODOLOGY))) <bölüm-yöntem>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/03-methodology/methodology-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.RESEARCH-DESIGN)) <başlık-araştırmanın-modeli>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/03-methodology/research-design-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(
    level: 2,
    translator(key: language-keys.RESEARCH-POPULATION-AND-SAMPLE),
  ) <başlık-araştırmanın-evreni-ve-örneklemi>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/03-methodology/research-population-and-sample-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(
    level: 2,
    translator(key: language-keys.DATA-COLLECTION-TOOLS),
  ) <başlık-veri-toplama-araçları-ve-veya-teknikleri>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/03-methodology/data-collection-tools-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.DATA-COLLECTION-PROCESS)) <başlık-verilerin-toplanması>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/03-methodology/data-collection-process-text.typ"

  // Alt başlığı ekle. [Add sub-heading.]
  #heading(level: 2, translator(key: language-keys.DATA-ANALYSIS))<başlık-verilerin-analizi>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/03-methodology/data-analysis-text.typ"

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  #pagebreak(weak: true)
]
