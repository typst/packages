#import "/src/utils/translate.typ": translate
#import "/src/utils/preprocess-items.typ": preprocess-items
#import "/src/components/item-row.typ": item-row
#import "/src/components/item-list.typ": item-list
#import "/src/components/header.typ": header
#import "/src/components/vat-section.typ": vat-section
#import "/src/components/payment-info.typ": payment-info
#import "/src/utils/get-invoice-number.typ": get-invoice-number
#import "/src/utils/get-reference-number.typ": get-reference-number
#import "/src/config.typ": DEFAULT-COLORS

/// Invoice component.
///
/// Works with show rules:
///
/// ```typst
/// #show: invoice(...)
/// ```
///
/// Or directly called:
/// ```typst
/// #invoice(...)
/// ```
///
/// -> content
#let invoice(
  lang: "en",
  date: datetime.today(),
  /// Footnotes, displayd as is.
  /// For example, it can contain contacts, reverse charge if payer pays VAT, etc.
  footnotes: [],
  /// Days to due date
  payment-terms: 14,
  invoice-number: auto,
  logo: none,
  seller: none,
  recipient: none,
  /// Default VAT rate
  vat-rate: decimal("0.255"),
  iban: none,
  bic: none,
  /// ISO 11649 reference number that begins with RF, only digits after RF are supported.
  /// Leading zeros after check digits are removed.
  reference-number: auto,
  /// Show bank barcode
  barcode: true,
  show-barcode-text: true,
  /// Show EPC QR code
  qrcode: true,
  font: auto,
  colors: DEFAULT-COLORS,
  items,
) = {
  set text(lang: lang, size: 12pt)
  set text(font: font) if (font != auto)
  set page(footer: footnotes)

  show table.cell: c => if c.y == 0 {
    align(bottom, strong(c))
  } else { c }

  if invoice-number == auto {
    invoice-number = get-invoice-number(date)
  }

  if reference-number == auto {
    reference-number = get-reference-number(invoice-number)
  }

  let items = preprocess-items(items, vat-rate)
  let sum = items.map(item => item.total-price).sum()
  let due-date = date + duration(days: payment-terms)

  header(
    invoice-number,
    date,
    recipient: recipient,
    seller: seller,
    logo: logo,
  )

  item-list(items, colors: colors)

  grid(
    columns: (1fr, 3fr),
    align: (left, right),
    [], vat-section(items, colors: colors),
  )
  payment-info(
    beneficiary: seller.name,
    amount: sum,
    due-date: due-date,
    reference-number: reference-number,
    iban: iban,
    bic: bic,
    barcode: barcode,
    show-barcode-text: show-barcode-text,
    qrcode: qrcode,
    colors: colors,
  )
}
