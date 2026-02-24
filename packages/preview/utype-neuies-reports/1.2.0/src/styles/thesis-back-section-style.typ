#import "/src/constants/numbering-constants.typ": PAGE-NUMBERING-ARABIC
#import "/src/styles/thesis-back-section-heading-style.typ": thesis-back-section-heading-style

// Tezin arka kısmının stili. [Style of the back section of the thesis.]
#let thesis-back-section-style(content) = {
  // Başlık numarlandırmasını 1'den başlat. [Start heading numbering from 1.]
  counter(heading).update(1)

  // Devam eden ortalanmış Arap rakamlı sayfa numaralandırmasını ayarla. [Set continued centered arabic page numbering.]
  set page(numbering: PAGE-NUMBERING-ARABIC)

  // Başlık stili. [Heading style.]
  show: thesis-back-section-heading-style

  content
}
