#let invoice(
  // -- Sender --
  sender: (:),

  // -- Recipient --
  recipient: (:),

  // -- Items --
  currency: (),
  date: none,
  due: none,
  items: (:),
  number: none,
  payment: (),
  taxes: (),

  // -- Document --
  language: "en",
  paper: (
    size: "a4",
    margins: (
      x: none,
      y: none,
    ),
  ),

  // -- Fonts --
  font-size: 11pt,
  leading-ratio: 1.75,
  font-face: "Roboto Flex",
  cjk-font-face: "Noto Sans CJK JP",

  // -- Colors --
  background-color: rgb("#ffffff"),
  foreground-color: rgb("#000000"),

  // -- Body --
  body,
) = {
  // -- Unpack date fields --
  // `date` may be a datetime, a format string, or an array containing either
  // or both (in any order). Without a datetime there is nothing to show, so
  // every date-dependent part (issue date, due date, document metadata) is
  // left out; the date is never filled in from the current day, so output
  // stays reproducible. A missing format defaults to year-month-day.
  let date-items = if date == none {
    ()
  } else if type(date) == array {
    date
  } else {
    (date,)
  }
  for item in date-items {
    assert(
      type(item) in (datetime, str),
      message: "date: expected a datetime, a format string, or an array of those, found "
        + str(type(item)),
    )
  }
  let date-value = date-items.find(item => (
    type(item) == datetime
  ))
  let has-date = date-value != none
  let date-format = {
    let found = date-items.find(item => type(item) == str)
    if found != none { found } else { "[year]-[month]-[day]" }
  }

  // ── Type scale (major third × 1.25) --
  let type-scale = 1.25
  let caption-size = font-size * calc.pow(type-scale, -1)
  let lead-size = font-size * calc.pow(type-scale, 1)
  let title-size = font-size * calc.pow(type-scale, 4)

  // ── Derived colors --
  let secondary-foreground-color = color.mix(
    (foreground-color, 5),
    (background-color, 3),
    space: oklab,
  )

  // ── Baseline grid --
  let line-height = font-size * leading-ratio
  let margins = paper.at("margins", default: (:))
  let margin-x = margins.at("x", default: none)
  let margin-y = margins.at("y", default: none)
  let margin-horizontal = if margin-x != none {
    margin-x
  } else {
    line-height * 4
  }
  let margin-vertical = if margin-y != none {
    margin-y
  } else {
    line-height * 3
  }

  // ── Metadata --
  if sender.at("name", default: none) != none {
    set document(author: sender.at("name"))
  }
  set document(date: if has-date { date-value } else { none })
  set document(title: "Invoice")

  // ── Text --
  set text(
    font: (
      font-face,
      cjk-font-face,
    ),
    size: font-size,
    fill: secondary-foreground-color,
    ligatures: true,
    discretionary-ligatures: true,
    variations: (
      wdth: 70,
      GRAD: -100,
      XTRA: 425,
    ),
    lang: language,
  )
  let uppercase(body) = text(
    variations: (wdth: 50),
    upper(strong(body)),
  )
  show strong: set text(
    fill: foreground-color,
    variations: (
      wght: 800,
    ),
  )

  // ── Paragraphs --
  set par(
    leading: line-height - font-size,
    spacing: line-height,
    justify: true,
    justification-limits: (
      spacing: (
        min: 100% * 2 / 3,
        max: 100% * 3 / 2,
      ),
      tracking: (
        min: -0.01em,
        max: 0.01em,
      ),
    ),
  )

  // ── Page --
  set page(
    paper: paper.at("size", default: "a4"),
    fill: background-color,
    margin: (
      x: margin-horizontal,
      y: margin-vertical,
    ),
    header: none,
    footer: context {
      // Page number, only shown if the letter runs long
      if counter(page).final().first() > 1 {
        v(line-height / 2)

        align(
          right,
          text(
            size: caption-size,
            fill: secondary-foreground-color,
            counter(page).display(
              "1 / 1",
              both: true,
            ),
          ),
        )
      }
    },
    footer-descent: line-height,
  )

  // ── "INVOICE" + Sender block --
  grid(
    columns: (1fr, auto),
    column-gutter: line-height,
    // -- "INVOICE" --
    text(
      fill: foreground-color,
      size: title-size,
      variations: (
        wght: 1000,
        wdth: 151,
        YOPQ: 100,
      ),
      upper("Invoice"),
    ),
    // -- Sender block --
    {
      if sender != (:) {
        align(right, {
          if sender.at("name", default: none) != none {
            text(
              variations: (wght: 800),
              fill: foreground-color,
              sender.at("name"),
            )
            linebreak()
          }
          if sender.at("address", default: none) != none {
            text(
              size: caption-size,
              fill: secondary-foreground-color,
              sender
                .at("address")
                .split(",")
                .map(s => s.trim())
                .join(linebreak()),
            )
            linebreak()
          }
          for (label, value) in sender.pairs() {
            if label != "name" and label != "address" {
              text(
                size: caption-size,
                fill: secondary-foreground-color,
                label + ": " + str(value),
              )
              linebreak()
            }
          }
        })
        v(line-height)
      }
    },
  )

  // ── Recipient block + Date --
  if recipient != (:) or has-date or number != none {
    grid(
      columns: (1fr, auto),
      column-gutter: line-height,
      // -- Recipient block --
      {
        if recipient != (:) {
          for (label, value) in recipient.pairs() {
            if label == "name" {
              text(
                size: caption-size,
                variations: (wght: 800),
                fill: foreground-color,
                value,
              )
              linebreak()
            } else if label == "address" {
              text(
                size: caption-size,
                fill: secondary-foreground-color,
                value
                  .split(",")
                  .map(s => s.trim())
                  .join(linebreak()),
              )
              linebreak()
            } else {
              text(
                size: caption-size,
                fill: secondary-foreground-color,
                label + ": " + str(value),
              )
              linebreak()
            }
          }
        }
      },
      // -- Invoice details --
      align(right, {
        if number != none {
          text(
            size: caption-size,
            "Invoice Number: ",
          )
          text(
            size: caption-size,
            strong(number),
          )
          linebreak()
        }
        if has-date {
          text(
            size: caption-size,
            "Date Issued: ",
          )
          text(
            size: caption-size,
            strong(date-value.display(date-format)),
          )
          linebreak()
        }
        if has-date and due != none {
          let due-date = if type(due) == int {
            date-value + duration(days: due)
          } else {
            due
          }
          text(
            size: caption-size,
            "Due Date: ",
          )
          text(
            size: caption-size,
            strong(due-date.display(date-format)),
          )
        }
      }),
    )
    v(line-height)
  }

  // -- Currency --
  let currency = if type(currency) == str {
    (symbol: currency)
  } else if type(currency) == dictionary {
    currency
  } else {
    (:)
  }
  let currency-name = currency.at("name", default: none)
  let currency-symbol = currency.at("symbol", default: "")
  let currency-decimal = currency.at("decimal", default: ".")
  let currency-thousands = currency.at("thousands", default: ",")
  let currency-decimals = currency.at("decimals", default: 2)

  // ── Invoice totals --
  let subtotal = items
    .pairs()
    .map(((description, amount)) => amount)
    .sum(default: 0)
  let taxes = if type(taxes) == dictionary {
    taxes
  } else {
    (:)
  }
  let tax-amounts = taxes
    .values()
    .map(rate => calc.round(
      subtotal * rate / 100,
      digits: currency-decimals,
    ))
  let total-tax = tax-amounts.fold(0, (total, amount) => (
    total + amount
  ))
  let total = subtotal + total-tax
  // -- Format monetary amounts --
  let money = value => {
    let factor = calc.pow(
      10,
      currency-decimals,
    )
    let rounded = (
      calc.round(
        value * factor,
      )
        / factor
    )
    let negative = rounded < 0
    let raw = str(calc.abs(rounded))
    let parts = raw.split(".")
    let integer = parts.at(0)
    let fraction = if currency-decimals > 0 {
      if parts.len() > 1 {
        parts.at(1)
      } else {
        ""
      }
    } else {
      ""
    }
    // Add trailing zeroes.
    let fraction = if currency-decimals > 0 {
      (
        fraction
          + "0"
            * (
              currency-decimals - fraction.len()
            )
      )
    } else {
      ""
    }
    // Add thousands separators.
    let integer = if currency-thousands != none {
      let chars = integer.clusters()
      let groups = ()
      let current = ()
      for char in chars.rev() {
        current.push(char)
        if current.len() == 3 {
          groups.push(
            current.rev().join(),
          )
          current = ()
        }
      }
      if current.len() > 0 {
        groups.push(
          current.rev().join(),
        )
      }
      groups.rev().join(currency-thousands)
    } else {
      integer
    }
    let number = if currency-decimals > 0 {
      integer + currency-decimal + fraction
    } else {
      integer
    }
    (if negative { "−" } else { "" }) + currency-symbol + number
  }

  // ── Invoice items and totals --
  grid(
    columns: (
      1fr,
      auto,
    ),
    column-gutter: line-height / 2,
    align: (
      left,
      right,
    ),
    inset: (x, y) => (
      top: line-height / type-scale,
      bottom: 0pt,
    ),
    // Header rule
    grid.hline(stroke: 0.5pt),
    // Header
    uppercase("Description"),
    uppercase("Amount"),
    // Items
    ..items
      .pairs()
      .map(((description, amount)) => (
        description,
        money(amount),
      ))
      .flatten(),
    // Subtotal separator
    grid.cell(
      colspan: 2,
      line(
        length: 100%,
        stroke: 0.5pt,
      ),
    ),
    // Subtotal
    grid.cell(
      align: right,
      "Subtotal",
    ),
    money(subtotal),
    // Taxes
    ..taxes
      .keys()
      .enumerate()
      .map(((i, label)) => (
        grid.cell(
          align: right,
          label + " (" + (str(taxes.at(label)) + "%)"),
        ),
        money(tax-amounts.at(i)),
      ))
      .flatten(),
    // Total
    grid.cell(
      align: right,
      text(
        variations: (
          wght: 800,
          wdth: 50,
        ),
        uppercase(
          if currency-name != none {
            "Total (" + currency-name + ")"
          } else {
            "Total"
          },
        ),
      ),
    ),
    grid.cell(
      uppercase(money(total)),
    ),
  )

  // ── Document body --
  text(size: caption-size, body)

  // ── Payment information --
  v(1fr)
  let payments = if type(payment) == dictionary {
    (payment,)
  } else {
    payment
  }
  if payments.len() > 0 {
    grid(
      columns: payments.map(payment => payment.at(
        "width",
        default: 1fr,
      )),
      inset: (x, y) => if y == 0 {
        (top: line-height)
      },
      stroke: (x, y) => if y == 0 {
        (top: 0.5pt)
      },
      ..payments.map(payment => align(
        left,
        {
          text(
            variations: (wght: 800, wdth: 50),
            uppercase(payment.at(
              "heading",
              default: "Payment information",
            )),
          )
          v(0pt)
          for (label, value) in payment.pairs() {
            if label != "heading" and label != "width" {
              if value == "" {
                text(
                  fill: secondary-foreground-color,
                  size: caption-size,
                  label,
                )
              } else if type(value) == content {
                value
              } else {
                text(
                  fill: secondary-foreground-color,
                  size: caption-size,
                  label + ": ",
                )
                text(
                  size: caption-size,
                  strong(str(value)),
                )
              }
              linebreak()
            }
          }
        },
      )),
    )
  }
}

