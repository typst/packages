#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/components/abstract-page-component.typ": abstract-page-component

// İnglizce özet için özet sayfası. [Abstract page for English abstract.]
#let english-abstract-page(
  department: none,
  program: none,
  report-type: none,
  report-title: none,
  author: none,
  keywords: none,
) = {
  // Dil kodunu al. [Get the language code.]
  let language-code = LANGUAGES.EN-US.language-code

  // Metin dilini İngilizce olarak ayarla. [Set the text language to English.]
  set text(lang: LANGUAGES.EN-US.language-code)

  abstract-page-component(
    // Context ile ilgili bir sorun olup, İçindekiler sayfasında başlık sorunlu gözüktüğü için metnin diline göre otomatik ayarlamak yerine elle belirtildi. [The problem of the context, and the title page has a problem due to the automatic setting of the text according to the language, so it was set manually.]
    page-title: translator(key: language-keys.ABSTRACT, language-code: language-code),
    university-name: translator(key: language-keys.UNIVERSITY-NAME-TITLE-CASE),
    institute-name: translator(key: language-keys.INSTITUTE-NAME-TITLE-CASE),
    department: department,
    program: program,
    report-type: report-type,
    report-title: report-title.eng,
    author: author,
    abstract-text-content-file-path: "/template/sections/01-front/abstract-text-eng.typ",
    keywords-title: translator(key: language-keys.KEYWORDS),
    keywords: keywords,
  )
}
