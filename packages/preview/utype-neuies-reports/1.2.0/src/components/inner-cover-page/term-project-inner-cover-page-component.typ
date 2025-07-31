#import "/src/styles/inner-cover-page-style.typ": inner-cover-page-style
#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/components/inner-cover-page/double-logo-organization-info-heading-component.typ": (
  double-logo-organization-info-heading-component,
)
#import "/src/components/report-title-text-component.typ": report-title-text-component
#import "/src/components/fullname-component.typ": fullname-component
#import "/src/components/orcid-with-prefix-component.typ": orcid-with-prefix-component
#import "/src/components/advisor-with-orcid-component.typ": advisor-with-orcid-component
#import "/src/components/inner-cover-page/city-name-with-year-component.typ": city-name-with-year-component

// Dönem Projesi İç Kapak sayfası bileşeni. [Term Project Inner Cover page component.]
#let term-project-inner-cover-page-component(
  language: none,
  department: none,
  program: none,
  report-type: none,
  date: none,
  report-title: none,
  author: none,
  advisor: none,
  second-advisor: none,
  thesis-study-funding-organization: none,
) = {
  // İç Kapak sayfası stilini uygula. [Apply the style of the Inner Cover page.]
  show: inner-cover-page-style

  // Çift logolu başlık. [Double logo heading.]
  double-logo-organization-info-heading-component(language: language)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(3.75cm)

  // Ana Bilim Dalı bilgisi. [Department information.]
  department

  // Bir miktar boşluk bırak. [Leave some space.]
  v(0.2cm)

  // Bilim Dalı bilgisi. [Program information.]
  program

  // Bir miktar boşluk bırak. [Leave some space.]
  v(1.5cm)

  /// Rapor türü bilgisi. [Report type information.]
  report-type

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2.75cm)

  // Dile göre rapor başlığını seç. [Select the report title according to the language.]
  let report-title = if language == LANGUAGES.TR-TR {
    report-title.tur
  } else if language == LANGUAGES.EN-US {
    report-title.eng
  }
  // Rapor başlığı. [Report title.]
  report-title-text-component(report-title: report-title)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2.75cm)

  // Yazar bilgilerini ekle. [Add author information.]
  fullname-component(first-name: author.first-name, last-name: author.last-name)
  linebreak()
  orcid-with-prefix-component(orcid: author.orcid)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2.5cm)

  // Danışman bilgilerini ekle. [Add advisor information.]
  translator(key: language-keys.ADVISOR)
  linebreak()
  advisor-with-orcid-component(advisor: advisor)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2.5cm)

  // Şehir adı ve yıl bilgisini ekle. [Add city name and year information.]
  city-name-with-year-component(date: date)
}
