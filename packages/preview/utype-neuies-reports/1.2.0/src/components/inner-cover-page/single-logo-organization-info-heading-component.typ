#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/constants/path-constants.typ": INSTITUTE-LOGO-PATH
#import "/src/components/inner-cover-page/organization-info-heading-component.typ": organization-info-heading-component

// Tek logolu başlık. [Single logo heading.]\
/* Örnek [Example]:\
  |[Enstitü Logosu]|\n|[Ülke Adı]\n[Üniversite Adı]|\n|[Enstitü Adı]|
*/
#let single-logo-organization-info-heading-component(
  language: none,
) = {
  // Dile göre enstitü logusunu seç. [Select the institute logo according to the language.]
  let institute-logo-path = if language == LANGUAGES.TR-TR {
    INSTITUTE-LOGO-PATH.TR-TR
  } else if language == LANGUAGES.EN-US {
    INSTITUTE-LOGO-PATH.EN-US
  }

  // Tek logolu başlık. [Single logo heading.]
  grid(
    columns: 1fr,
    rows: auto,
    align: center + horizon,
    row-gutter: 10pt,
    inset: (:),
    stroke: none,
    fill: none,
    // Enstitü logosu. [Institute logo.]
    image(institute-logo-path, width: 3.4cm, height: 3.4cm),
    // Organizasyon bilgisi başlığı. [Organization information heading.]
    organization-info-heading-component()
  )
}
