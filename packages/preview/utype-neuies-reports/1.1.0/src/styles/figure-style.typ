#import "/src/constants/document-settings-constants.typ": ALTERNATE-FONT-SIZE, SINGLE-LINE-PARAGRAPH-LEADING-SIZE
#import "/src/constants/separator-constants.typ": FIGURE-CAPTION-SEPARATOR
#import "/src/constants/numbering-constants.typ": FIGURE-NUMBERING
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Figür stili. [Figure style.]
#let figure-style(content) = {
  // Tablo figürünün stili. [Table figure style.]
  show figure.where(kind: table): set figure(
    supplement: translator(key: language-keys.TABLE-FIGURE-REFERENCE-SUPPLEMENT),
    placement: none,
    gap: 0.5em,
  )

  // Tablo figürünün başlık stili. [Table figure caption style.]
  show figure.where(kind: table): set figure.caption(
    position: top,
    separator: FIGURE-CAPTION-SEPARATOR,
  )

  // Tablo figürlerin üstündeki ve altındaki boşlukları ayarlama. [Set spacing above and below table figures.]
  show figure.where(kind: table): set block(above: 1.5em, below: 1em)

  // Görsel figürünün stili. [Image figure style.]
  show figure.where(kind: image): set figure(
    supplement: translator(key: language-keys.IMAGE-FIGURE-REFERENCE-SUPPLEMENT),
    placement: none,
    gap: 0.5em,
  )

  // Şekil figürünün başlık stili. [Image figure caption style.]
  show figure.where(kind: image): set figure.caption(
    position: bottom,
    separator: FIGURE-CAPTION-SEPARATOR,
  )

  // Şekil figürlerin üstündeki ve altındaki boşlukları ayarlama. [Set spacing above and below image figures.]
  show figure.where(kind: image): set block(above: 1.5em, below: 1em)

  // Kod figürünün stili. [Table figure style.]
  show figure.where(kind: raw): set figure(
    supplement: translator(key: language-keys.RAW-FIGURE-REFERENCE-SUPPLEMENT),
    placement: none,
    gap: 0.5em,
  )

  // Kod figürünün başlık stili. [Table figure caption style.]
  show figure.where(kind: raw): set figure.caption(
    position: top,
    separator: FIGURE-CAPTION-SEPARATOR,
  )

  // Kod figürlerin üstündeki ve altındaki boşlukları ayarlama. [Set spacing above and below raw figures.]
  show figure.where(kind: raw): set block(above: 1.5em, below: 1.5em)

  // Figür başlıklarının stili. [Figure caption style.]
  show figure.caption: it => {
    set text(size: ALTERNATE-FONT-SIZE)
    set par(leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE)
    (
      text(
        weight: "bold",
        it.supplement + " " + context it.counter.display(it.numbering) + it.separator,
      )
        + text(it.body)
    )
  }

  // Figürlerin numaralandırma stilini ayarlama. [Set numbering style of figures.]
  set figure(
    numbering: n => numbering(FIGURE-NUMBERING, counter(heading).get().first(), n),
    gap: 1em,
  )

  // TODO: Tablo figürlerinin bölünüp bölünmeyeceğini ayarla.
  // Tabloyu bölünebilir yapma. [Make table breakable.]
  // NOT: Figür başlıklarının tekrar etmesi ve tekrar eden başlıkların ana başlıktan farklı olmasını sağlayacak özellikler gelene kadar tablolar bölünemez şeklinde kalmalıdır.
  show figure.where(kind: table): set block(breakable: false)

  content
}
