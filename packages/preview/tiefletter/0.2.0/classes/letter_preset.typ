#import "document_preset.typ": document-preset
#import "../core/sign.typ": sign
#import "../core/i18n.typ": letter-translations

/// Letter preset for typed correspondence; builds on document-preset and
/// injects headers, salutations, signature handling, and footer composition.
/// Parameters:
/// - t: translation dictionary (automatically merged with locale strings)
/// - lang: locale code (en-at, en-de, en-us, de-at, de-de)
/// - seller/client: contact dictionaries; seller.signature/client.signature enable signature lines
/// - footer-middle/footer-right/banner-image: optional display elements
/// - header-left/header-right: header content blocks
/// - content: function(t) -> body content for the letter
#let letter-preset(
  t,
  lang: none,
  seller: (
    name: none,
    address: none,
    uid: none,
    tel: none,
    email: none,
    is-kleinunternehmer: false,
    signature: false,
  ),
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  client: (
    gender-marker: none,
    full-name: none,
    short-name: none,
    address: none,
    uid: none,
    signature: false,
  ),
  header-left: none,
  header-right: none,
  content: t => { [] },
) = {
  context {
    let t = (base: none, ..t, ..letter-translations(language: lang))

    let footer-left = box(width: 1fr, align(center, seller.name + "\n" + seller.tel + "\n" + seller.email))

    show: document-preset.with(
      footer-left: footer-left,
      footer-middle: footer-middle,
      footer-right: footer-right,
      banner-image: banner-image,
    )

    context {
      place(top + right, dx: -0.5cm, dy: 1cm)[
        #set text(size: 14pt)
        #seller.name\
        #seller.address\
        #v(0.5em)
        #if seller.at("is-kleinunternehmer", default: false) and seller.at("uid", default: none) != none {
          [UID: #seller.uid]
        }
      ]

      place(top + left, dx: 0.5cm, dy: 4cm, [
        #set text(size: 14pt)
        #client.full-name\
        #client.address\
        #v(0.5em)
        #if client.at("uid", default: none) != none { [UID: #client.uid] }
      ])

      v(7cm)

      place(left, dx: 1.2cm, dy: -1.4em, header-left)
      place(right, dx: -1.2cm, dy: -1.4em, header-right)

      line(start: (1cm, 0cm), length: 100% - 2cm)

      assert(
        client.gender-marker in ("f", "F", "m", "M", "o", "O"),
        message: "Gender Marker not recognized. Use only \"[fFmMoO]\"",
      )

      let salutation = if client.gender-marker == "f" or client.gender-marker == "F" {
        t.salutation-f
      } else if client.gender-marker == "m" or client.gender-marker == "M" {
        t.salutation-m
      } else if client.gender-marker == "o" or client.gender-marker == "O" {
        t.salutation-o
      }

      set text(number-type: "old-style")

      [#salutation #client.short-name,

        #content(t)

        #t.closing]

      box(width: 100%, grid(
        columns: (1fr, 1fr),
        gutter: 5em,
        align: (col, row) => if col == 0 { left } else { right },
        if seller.at("signature", default: false) {
          v(1em)
          [#sign(seller.name)]
        } else {
          [#seller.name]
        },
        if client.at("signature", default: false) {
          v(1em)
          [#sign(client.full-name)]
        },
      ))
    }
  }
}
