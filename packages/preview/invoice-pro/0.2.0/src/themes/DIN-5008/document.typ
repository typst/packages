#import "@preview/letter-pro:3.0.0": (
  address-duobox, address-tribox, annotations-box, header-simple,
  letter-generic, recipient-box, sender-box,
)

#let to-string(it) = {
  if it == none { return "" }
  if type(it) == str { return it }
  if type(it) != content { return str(it) }
  if it.has("text") { return it.text }
  if it.has("children") {
    return it.children.map(to-string).join()
  }
  if it.has("body") { return to-string(it.body) }
  if it == [ ] { return " " }
  return ""
}

#let extract-city-name(zip-city-string) = {
  let pattern = regex("^\\s*\\d*")
  to-string(zip-city-string).trim(pattern)
}

#let letter-document(
  form: "A",
  font: "Liberation Sans",

  hole-mark: true,
  folding-marks: true,

  margin: (:),
) = (ctx, body) => {
  // NYI
  let annotations = none
  // END NYI

  let format = "DIN-5008-" + form
  let subject = ctx.subject
  let reference-signs = ctx.references

  let margin = (
    left: margin.at("left", default: 25mm),
    right: margin.at("right", default: 20mm),
    top: margin.at("top", default: 20mm),
    bottom: margin.at("bottom", default: 20mm),
  )

  let sender = (
    name: ctx.sender.name,
    address: ctx.sender.address,
    city: ctx.sender.city,
    extra: ctx.sender.at("extra", default: none),
  )

  set document(
    title: subject,
    author: sender.at("name", default: ""),
  )

  set text(font: font)

  let header = pad(
    left: margin.left,
    right: margin.right,
    top: margin.top,
    bottom: 5mm,
    {
      set text(10pt)

      grid(
        columns: (1fr, 1fr),
        subject,
        {
          set align(right)
          if sender.name != none [#strong(sender.name) \ ]
          if sender.address != none [#sender.address \ ]
          if sender.city != none [#sender.city \ ]
        },
      )
    },
  )

  let recipient-content = [
    #ctx.recipient.name \
    #ctx.recipient.address \
    #ctx.recipient.city
  ]

  let sender-box = sender-box(
    name: sender.name,
    [#sender.address, #sender.city],
  )
  let annotations-box = annotations-box(annotations)
  let recipient-box = recipient-box([#recipient-content])

  let address-box = address-tribox(sender-box, annotations-box, recipient-box)
  if annotations == none {
    address-box = address-duobox(
      align(bottom, pad(bottom: .65em, sender-box)),
      recipient-box,
    )
  }

  letter-generic(
    format: format,

    header: header,

    folding-marks: folding-marks,
    hole-mark: hole-mark,

    address-box: address-box,
    reference-signs: reference-signs,
    margin: margin,
  )[
    #grid(
      columns: (1fr, auto),
      heading(subject),
      {
        let cityname = extract-city-name(sender.city)
        if cityname != none [#cityname, ]

        if type(ctx.invoice-date) == datetime {
          strong((ctx.locale.format.date)(ctx.invoice-date))
        } else {
          strong[#ctx.invoice-date]
        }
      },
    )

    #set text(hyphenate: true)
    #set par(justify: true)
    #body
  ]
}
