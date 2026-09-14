#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Organizasyon bilgisi başlığı. [Organization information heading.]\
/* Örnek [Example]:\
  [Ülke Adı]\n[Üniversite Adı]\n[Enstitü Adı]
*/
#let organization-info-heading-component() = {
  // Yazı kalın yap. [Bold the text.]
  set text(weight: "bold")

  // Ülke bilgisini ekle. [Add country information.]
  upper(translator(key: language-keys.THE-REPUPLIC-OF-TURKIYE))

  // Bir miktar boşluk bırak. [Leave some space.]
  v(3pt)

  // Üniversite bilgisini ekle. [Add university information.]
  upper(translator(key: language-keys.UNIVERSITY-NAME-UPPER-CASE))

  // Bir miktar boşluk bırak. [Leave some space.]
  v(3pt)

  // Enstitü bilgisini ekle. [Add institute information.]
  upper(translator(key: language-keys.INSTITUTE-NAME-UPPER-CASE))
}
