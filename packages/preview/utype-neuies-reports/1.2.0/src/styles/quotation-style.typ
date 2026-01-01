#import "/src/constants/document-settings-constants.typ": (
  PARAGRAPH-FIRST-LINE-INDENT,
  ONE-AND-HALF-LINE-PARAGRAPH-LEADING-SIZE,
)

// Alıntı içeriği. [Quotation content.]
#let _quotation-content(quotation: none) = (
  sym.quote.l.double
    + h(0pt, weak: true)
    + quotation.body
    + h(0pt, weak: true)
    + sym.quote.r.double
    + if quotation.attribution != none {
      if type(quotation.attribution) == label {
        [ #cite(quotation.attribution)]
      } else {
        [ (#quotation.attribution)]
      }
    }
)

// Alıntı stili. [Quotation style.]
#let quotation-style(content) = {
  // Satır içi alıntıların atfının stili. [The style of the attribution of in-line quotations.]
  show quote.where(block: false): it => {
    _quotation-content(quotation: it)
  }

  // Blok alıntıların atfının stili. [The style of the attribution of block quotations.]
  show quote.where(block: true): it => {
    block(
      // Alıntılara soldan iç boşluk eklendi. [Padding was added to the left of the quotations.]
      inset: (left: PARAGRAPH-FIRST-LINE-INDENT),
      spacing: auto,
      breakable: false,
      fill: none,
      sticky: false,
      _quotation-content(quotation: it),
    )
  }

  // Alıntılar sola hizalandı. [Quotations are alinged left.]
  show quote.where(block: true): set align(left)

  // Satır içi alıntılardaki satır aralığı. [Line spacing of in-line quotations.]
  show quote.where(block: true): set par(
    first-line-indent: (amount: PARAGRAPH-FIRST-LINE-INDENT, all: false),
    leading: ONE-AND-HALF-LINE-PARAGRAPH-LEADING-SIZE,
  )

  content
}
