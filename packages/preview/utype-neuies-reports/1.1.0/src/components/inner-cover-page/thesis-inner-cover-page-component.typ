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
#import "/src/components/inner-cover-page/thesis-study-funding-organization-component.typ": (
  thesis-study-funding-organization-component,
)
#import "/src/components/inner-cover-page/city-name-with-year-component.typ": city-name-with-year-component

// Tez İç Kapak sayfası bileşeni. [Thesis Inner Cover page component.]
#let thesis-inner-cover-page-component(
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
  v(2.5cm)

  // Dile göre rapor başlığını seç. [Select the report title according to the language.]
  let report-title = if language == LANGUAGES.TR-TR {
    report-title.tur
  } else if language == LANGUAGES.EN-US {
    report-title.eng
  }
  // Rapor başlığı. [Report title.]
  report-title-text-component(report-title: report-title)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2.5cm)

  // Yazar bilgilerini ekle. [Add author information.]
  fullname-component(first-name: author.first-name, last-name: author.last-name)
  linebreak()
  orcid-with-prefix-component(orcid: author.orcid)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(1.5cm)

  // Danışman bilgilerini ekle. [Add advisor information.]
  translator(key: language-keys.ADVISOR)
  linebreak()
  advisor-with-orcid-component(advisor: advisor)

  // Bir miktar boşluk bırak. [Leave some space.]
  v(1cm)

  // Rapor türüne ve ikinci danışmanın olup olmamasına göre ikinci danışman bilgilerini ekle. [Add second advisor information according to the report type and whether there is a second advisor or not.]
  if second-advisor != none {
    // İkinci danışman bilgilerini ekle. [Add second advisor information.]
    translator(key: language-keys.SECOND-ADVISOR)
    linebreak()
    advisor-with-orcid-component(advisor: second-advisor)
  } else {
    // Bir miktar boşluk bırak. [Leave some space.]
    v(1.5cm)
  }

  // Bir miktar boşluk bırak. [Leave some space.]
  v(1cm)

  // Rapor türüne ve tez çalışmasını destekleyen kuruluş olup olmamasına göre tez çalışmasını destekleyen kuruluş bilgilerini ekle. [Add thesis study funding organization information according to the report type and whether there is a thesis study funding organization or not.]
  if thesis-study-funding-organization != none {
    // Tez çalışmasını destekleyen kuruluş bilgilerini ekle. [Add thesis study funding organization information.]
    thesis-study-funding-organization-component(
      language: language,
      thesis-study-funding-organization: thesis-study-funding-organization,
    )

    // Bir miktar boşluk bırak. [Leave some space.]
    v(0.25cm)
  } else {
    // Bir miktar boşluk bırak. [Leave some space.]
    v(1.25cm)
  }

  // Şehir adı ve yıl bilgisini ekle. [Add city name and year information.]
  city-name-with-year-component(date: date)
}
