#import "document_preset.typ": document-preset
#import "../core/utils.typ": sign
#import "../core/i18n.typ": i18n

#let letter-preset(
  sender: (
    name: none,
    address: none,
    uid: none,
    tel: none,
    email: none,
    is-kleinunternehmer: false,
    signature: false,
  ),
  footer-left: none,
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  addressee: (
    gender-marker: none,
    full-name: none,
    short-name: none,
    address: none,
    uid: none,
    signature: false,
  ),
  header-left: none,
  header-right: none,
  body,
) = {
  context {
    let t = i18n()

    show: document-preset.with(
      footer-left: footer-left,
      footer-middle: footer-middle,
      footer-right: footer-right,
      banner-image: banner-image,
    )

    let prev-num-type = text.number-type
    set text(number-type: "lining")

    place(top + right, dx: -0.5cm, dy: 1cm)[
      #set text(size: 14pt)
      #sender.name\
      #sender.address\
      #v(0.5em)
      #if sender.at("is-kleinunternehmer", default: false) and sender.at("uid", default: none) != none {
        [UID: #sender.uid]
      }
    ]

    place(top + left, dx: 0.5cm, dy: 4cm, [
      #set text(size: 14pt)
      #addressee.full-name\
      #addressee.address\
      #v(0.5em)
      #if addressee.at("uid", default: none) != none { [UID: #addressee.uid] }
    ])

    v(7cm)

    place(left, dx: 1.2cm, dy: -1.4em, header-left)
    place(right, dx: -1.2cm, dy: -1.4em, header-right)

    line(start: (1cm, 0cm), length: 100% - 2cm)

    assert(
      addressee.gender-marker in ("f", "F", "m", "M", "o", "O"),
      message: "Gender Marker not recognized. Use only \"[fFmMoO]\"",
    )

    let salutation = if addressee.gender-marker == "f" or addressee.gender-marker == "F" {
      t.letter.salutation-f
    } else if addressee.gender-marker == "m" or addressee.gender-marker == "M" {
      t.letter.salutation-m
    } else if addressee.gender-marker == "o" or addressee.gender-marker == "O" {
      t.letter.salutation-o
    }

    set text(number-type: prev-num-type)

    body
  }
}
