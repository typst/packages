#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/components/abstract-page-component.typ": abstract-page-component

// Türkçe özet için özet sayfası. [Abstract page for Turkish abstract.]
#let turkish-abstract-page(
  department: none,
  program: none,
  report-type: none,
  report-title: none,
  author: none,
  keywords: none,
) = {
  // Dil kodunu al. [Get the language code.]
  let language-code = LANGUAGES.TR-TR.language-code

  // Metin dilini Türkçe olarak ayarla. [Set the text language to Turkish.]
  set text(lang: LANGUAGES.TR-TR.language-code)

  abstract-page-component(
    // Context ile ilgili bir sorun olup, İçindekiler sayfasında başlık sorunlu gözüktüğü için metnin diline göre otomatik ayarlamak yerine elle belirtildi. [The problem of the context, and the title page has a problem due to the automatic setting of the text according to the language, so it was set manually.]
    page-title: translator(key: language-keys.ABSTRACT, language-code: language-code),
    university-name: translator(key: language-keys.UNIVERSITY-NAME-TITLE-CASE),
    institute-name: translator(key: language-keys.INSTITUTE-NAME-TITLE-CASE),
    department: department,
    program: program,
    report-type: report-type,
    report-title: report-title.tur,
    author: author,
    abstract-text-content-file-path: "/template/sections/01-front/abstract-text-tur.typ",
    keywords-title: translator(key: language-keys.KEYWORDS),
    keywords: keywords,
  )
}
