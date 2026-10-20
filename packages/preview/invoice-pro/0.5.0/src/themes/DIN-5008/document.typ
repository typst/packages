#import "../../loom-wrapper.typ": eval-content
#import "../../utils/text.typ": plain-text
#import "@preview/letter-pro:3.0.0": (
  address-duobox, address-tribox, annotations-box, header-simple,
  letter-generic, recipient-box, sender-box,
)

#let extract-city-name(zip-city-string) = {
  let pattern = regex("^\\s*\\d*")
  plain-text(zip-city-string).trim(pattern)
}

// The value of a sender field, unless it is missing or the placeholder
// ("#sender.name") the root context puts in its place.
#let _field(dict, key) = {
  let value = dict.at(key, default: none)
  if value in (none, "", []) { return none }
  if type(value) == str and value == "#sender." + key { return none }
  value
}

#let letter-document(
  form: "A",
  font: "Liberation Sans",

  hole-mark: true,
  folding-marks: true,

  margin: (:),
  footer: none,
) = (ctx, body) => {
  let format = "DIN-5008-" + form
  let subject = ctx.subject
  let reference-signs = ctx.references

  let extras = ctx.sender.extra

  let recipient-extras = ctx.recipient.extra
  let annotations = if recipient-extras == () { none } else {
    if type(recipient-extras) == array {
      recipient-extras
        .map(r => [#r.at(0, default: none): #r.at(1, default: none)])
        .join(", ")
    } else {
      recipient-extras
    }
  }

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

  let document-keywords = ("Invoice",)
  if ctx.zugferd != none {
    document-keywords.push("ZUGFeRD")
    document-keywords.push("Factur-X")
  }

  // PDF metadata takes plain text: names and subjects may be styled content
  // or, for names, several lines. The author is the seller name of the
  // e-invoice (BT-27).
  let author-name = _field(ctx.sender, "name-inline")
  if author-name == none { author-name = _field(ctx.sender, "name") }
  let author = plain-text(author-name)
  let description = plain-text(subject)
  set document(
    title: subject,
    author: if author == "" { () } else { author },
    date: if type(ctx.invoice-date) == datetime { ctx.invoice-date } else {
      auto
    },
    description: if description == "" { none } else { description },
    keywords: document-keywords,
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
        block(width: 100%, height: 5.5cm, {
          set align(right)
          if sender.name != none [#strong(sender.name) \ ]
          if sender.address != none [#sender.address \ ]
          if sender.city != none [#sender.city \ ]

          parbreak()

          if type(extras) == array {
            block(
              breakable: false,
              grid(
                columns: 2,
                align: (left + horizon, right + horizon),
                column-gutter: .4em,
                row-gutter: .75em,
                ..extras
                  .map(a => {
                    (
                      [#a.at(0, default: none):],
                      a.at(1, default: none),
                    )
                  })
                  .flatten()
              ),
            )
          } else {
            extras
          }
        }),
      )
    },
  )

  let recipient-content = [
    #ctx.recipient.name \
    #ctx.recipient.address \
    #ctx.recipient.city
  ]

  let sender-box = sender-box(
    name: ctx.sender.name-inline,
    [#ctx.sender.address-inline, #ctx.sender.city-inline],
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

  let letter-generic-args = (
    format: format,
    header: header,
    folding-marks: folding-marks,
    hole-mark: hole-mark,
    address-box: address-box,
    reference-signs: reference-signs,
    margin: margin,
  )
  if footer != none {
    letter-generic-args.insert("footer", eval-content(ctx, footer))
  }

  letter-generic(
    ..letter-generic-args,
  )[
    #grid(
      columns: (1fr, auto),
      heading(subject),
      {
        let cityname = if ctx.sender.at("city-name", default: none) != none {
          ctx.sender.city-name
        } else {
          extract-city-name(sender.city)
        }
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
