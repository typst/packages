#import "/src/utils/translate.typ": translate
#import "/src/utils/preprocess_items.typ": preprocess_items
#import "/src/components/item_row.typ": item_row
#import "/src/components/item_list.typ": item_list
#import "/src/components/header.typ": header
#import "/src/components/vat_section.typ": vat_section
#import "/src/components/payment_info.typ": payment_info
#import "/src/utils/get_invoice_number.typ": get_invoice_number
#import "/src/utils/get_reference_number.typ": get_reference_number
#import "/src/config.typ": DEFAULT_COLORS

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
  payment_terms: 14,
  invoice_number: auto,
  logo: none,
  seller: none,
  recipient: none,
  /// Default VAT rate
  vat_rate: decimal("0.255"),
  iban: none,
  bic: none,
  /// ISO 11649 reference number that begins with RF, only digits after RF are supported.
  /// Leading zeros after check digits are removed.
  reference_number: auto,
  /// Show bank barcode
  barcode: true,
  show_barcode_text: true,
  /// Show EPC QR code
  qrcode: true,
  font: auto,
  colors: DEFAULT_COLORS,
  items,
) = {
  set text(lang: lang, size: 12pt)
  set text(font: font) if (font != auto)
  set page(footer: footnotes)

  show table.cell: c => if c.y == 0 {
    align(bottom, strong(c))
  } else { c }

  if invoice_number == auto {
    invoice_number = get_invoice_number(date)
  }

  if reference_number == auto {
    reference_number = get_reference_number(invoice_number)
  }

  let items = preprocess_items(items, vat_rate)
  let sum = items.map(item => item.total_price).sum()
  let due_date = date + duration(days: payment_terms)

  header(
    invoice_number,
    date,
    recipient: recipient,
    seller: seller,
    logo: logo,
  )

  item_list(items, colors: colors)

  grid(
    columns: (1fr, 3fr),
    align: (left, right),
    [], vat_section(items, colors: colors),
  )
  payment_info(
    beneficiary: seller.name,
    amount: sum,
    due_date: due_date,
    reference_number: reference_number,
    iban: iban,
    bic: bic,
    barcode: barcode,
    show_barcode_text: show_barcode_text,
    qrcode: qrcode,
    colors: colors,
  )
}
