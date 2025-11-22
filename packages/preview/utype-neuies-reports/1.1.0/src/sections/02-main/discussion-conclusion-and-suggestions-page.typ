#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Tartışma, Sonuç ve Öneriler sayfası. [Discussion, Conclusion and Suggestions page.]
#let discussion-conclusion-and-suggestions-page(
  show-separated-sub-headings: true,
) = [
  // Bölüm başlığını ekle. [Add section heading.]
  #heading(
    level: 1,
    upper(translator(key: language-keys.DISCUSSION-CONCLUSION-AND-SUGGESTIONS)),
  ) <bölüm-tartışma-sonuç-ve-öneriler>
  // Sayfa içeriğini ekle. [Add page content.]
  #include "/template/sections/02-main/05-discussion-conclusion-and-suggestions/discussion-conclusion-and-suggestions-text.typ"

  // Kullanıcı isterse alt başlıklara ayırabilir. [If the user wants, they can separate the sub-headings.]
  #if show-separated-sub-headings [
    // Alt başlığı ekle. [Add sub-heading.]
    #heading(level: 2, translator(key: language-keys.DISCUSSION)) <başlık-tartışma>
    // Sayfa içeriğini ekle. [Add page content.]
    #include "/template/sections/02-main/05-discussion-conclusion-and-suggestions/discussion-text.typ"

    // Alt başlığı ekle. [Add sub-heading.]
    #heading(
      level: 2,
      translator(key: language-keys.CONCLUSION),
    ) <başlık-sonuç>
    // Sayfa içeriğini ekle. [Add page content.]
    #include "/template/sections/02-main/05-discussion-conclusion-and-suggestions/conclusion-text.typ"

    // Alt başlığı ekle. [Add sub-heading.]
    #heading(
      level: 2,
      translator(key: language-keys.SUGGESTIONS),
    ) <başlık-öneriler>
    // Sayfa içeriğini ekle. [Add page content.]
    #include "/template/sections/02-main/05-discussion-conclusion-and-suggestions/suggestions-text.typ"

  ]

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  #pagebreak(weak: true)
]
