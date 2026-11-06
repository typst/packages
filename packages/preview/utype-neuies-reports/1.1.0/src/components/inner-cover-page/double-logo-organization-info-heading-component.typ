#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/constants/path-constants.typ": (
  UNIVERSITY-LOGO-PATH,
  INSTITUTE-LOGO-PATH,
)
#import "/src/components/inner-cover-page/organization-info-heading-component.typ": organization-info-heading-component

// Çift logolu başlık. [Double logo heading.]\
/* Örnek [Example]:\
  |[Üniversite Logosu]| |[Ülke Adı]\n[Üniversite Adı]\n[Enstitü Adı]| |[Enstitü Logosu]|
*/
#let double-logo-organization-info-heading-component(
  language: none,
) = {
  // Dile göre üniversite logusunu seç. [Select the university logo according to the language.]
  let university-logo-path = if language == LANGUAGES.TR-TR {
    UNIVERSITY-LOGO-PATH.TR-TR
  } else if language == LANGUAGES.EN-US {
    UNIVERSITY-LOGO-PATH.EN-US
  }

  // Dile göre enstitü logusunu seç. [Select the institute logo according to the language.]
  let institute-logo-path = if language == LANGUAGES.TR-TR {
    INSTITUTE-LOGO-PATH.TR-TR
  } else if language == LANGUAGES.EN-US {
    INSTITUTE-LOGO-PATH.EN-US
  }

  // Çift logolu başlık. [Double logo heading.]
  grid(
    columns: (1fr, auto, 1fr),
    align: center + horizon,
    column-gutter: 0pt,
    inset: (x: 0.2cm, y: 0.35cm),
    stroke: none,
    fill: none,
    // Üniversite logosu. [University logo.]
    align(left, image(university-logo-path, width: 2.7cm, height: 2.7cm)),
    // Organizasyon bilgisi başlığı. [Organization information heading.]
    organization-info-heading-component(),
    // Enstitü logosu. [Institute logo.]
    align(right, image(institute-logo-path, width: 2.7cm, height: 2.7cm)),
  )

  // Bir miktar boşluk bırak. [Leave some space.]
  v(3.7cm)
}
