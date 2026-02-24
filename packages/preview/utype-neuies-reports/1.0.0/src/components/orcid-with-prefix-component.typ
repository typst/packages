#import "/src/constants/language-free-string-constants.typ": STRING-ORCID
#import "/src/components/orcid-link-component.typ": orcid-link-component

// "STRING-ORCID" ön eki ile ORCID bağlantısını oluşturan bilşen fonksiyondur. [A function that creates a link to ORCID with the prefix "STRING-ORCID".]\
// Örnek [Example]: ORCID: [https://orcid.org/1234-1234-1234-1234]
#let orcid-with-prefix-component(
  orcid: none,
) = [#upper(STRING-ORCID): #orcid-link-component(orcid: orcid)]
