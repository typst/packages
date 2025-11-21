/// pc-letter: A simple template for personal correspondence.

#import "locals.typ"

#let _deep-merge-dicts(a, b) = {
  let result = a
  for (key, value) in b {
    if key in a and type(value) == dictionary {
        result.insert(key, _deep-merge-dicts(a.at(key), value))
    } else {
      result.insert(key, value)
    }
  }
  return result
}

#let _default-style = (
  locale: (
    lang: "en",
    region: "GB",
  ),
  medium: "digital",
  text: (
    font: ("Minion Pro", "Gentium", "Libertinus Serif", "Vollkorn", "Times New Roman"),
    size: (
      normal: 11pt,
      small: 10pt,
      tiny: 8pt,
    ),
    fill: (
      headline: rgb("#800022"),
      faded: black.lighten(20%),
    )
  ),
  alignment: (
    address-field: auto,
    date-field: auto,
    headings: auto,
    reference-field: auto,
    valediction: auto,
  ),
  page: (
    fill: auto,
  ),
  date: (
    format: auto,
  ),
  components: (
    place-name: (
      display: auto,
      pattern: "[place-name],"
    ),
    return-address-field: (
      display: auto,
    )
  ),
)

#let _default-author = (
  name: "Sherlock Holmes",
  address: ("221B Baker Street", "London NW1 6XE"),
  phone: "020 7123 4567",
  email: "sherlock@example.org"
)

#let init(
  author: _default-author,
  title: none,
  date: auto,
  place-name: none,
  style: (:)
) = {
  author = _deep-merge-dicts(_default-author, author)
  let tmp-style = _deep-merge-dicts(_default-style, style)
  let tmp-locale = tmp-style.locale.lang + "-" + tmp-style.locale.region
  if tmp-locale in locals.default-styles {
    tmp-style = _deep-merge-dicts(_default-style, locals.default-styles.at(tmp-locale))
  } else if tmp-style.locale.lang in locals.default-styles {
    tmp-style = _deep-merge-dicts(_default-style, locals.default-styles.at(tmp-style.locale.lang))
  } else {
    // If no matching locale is found even at just the lang level, assume "en"
    tmp-style = _deep-merge-dicts(_default-style, locals.default-styles.at("en"))
  }
  style = _deep-merge-dicts(tmp-style, style)
  if style.page.fill == auto {
    if style.medium == "digital" {
      style.page.fill = rgb("#faf9f0")
    } else {
      style.page.fill = none
    }
  }
  if date == auto {
    date = datetime.today()
  }

  let spaced-smallcaps(content) = [
    #set text(tracking: 0.0625em, spacing: 0.5em, features: (smcp: 1, c2sc: 1))
    #content
  ]

  let thin-space() = h(0.125em, weak: true)
  let en-space() = h(0.5em, weak: true)

  let falzmarken() = {
    place(
      top + left,
      dx: -25mm,
      dy: (87mm - 27mm - 10mm),
      line(stroke: 0.2mm + style.text.fill.faded, length: 2em)
    )
    place(
      top + left,
      dx: -25mm + 1em,
      dy: (148.5mm - 27mm - 10mm),
      line(stroke: 0.2mm + style.text.fill.faded, length: 1em)
    )
    place(
      top + left,
      dx: -25mm,
      dy: (192mm - 27mm - 10mm),
      line(stroke: 0.2mm + style.text.fill.faded, length: 2em)
    )
  }

  let phone-number(number) = [
    #set text(spacing: 0.125em)
    #link("tel:" + number)
  ]

  let email-address(email) = link("mailto:" + email)

  let address-field(recipient-address, return-address-field: auto) = [
    #if return-address-field == auto {
      return-address-field = [
        #set text(size: style.text.size.tiny)
        #set align(left + bottom)
        #author.name #sym.bullet #author.address.join(" " + sym.bullet + " ")
      ]
    }
    #let recipient-field = [
        #set par(first-line-indent: 0em)
        #set text(size: style.text.size.small)
        #recipient-address
    ]
    #context {
      let x-offset = 0mm
      if style.alignment.address-field == right {
        x-offset = 210mm - 25mm - 25mm - 2mm
        if (style.components.return-address-field.display 
            and measure(return-address-field).width > measure(recipient-field).width) {
          x-offset -= measure(return-address-field).width
        } else {
          x-offset -= measure(recipient-field).width
        }
      }
      if style.components.return-address-field.display {
        place(
          top + left,
          dx: x-offset,
          dy: (0mm - 10mm),
          rect(
            height: 17.7mm,
            width: 90mm,
            stroke: none,
            [
              #return-address-field
              #context place(
                bottom + left,
                dx: -2mm,
                dy: 1.5mm,
                line(
                  stroke: 0.2mm,
                  length: measure(return-address-field).width + 4mm
                )
              )
            ]
          )
        )
      }
      place(
        top + left,
        dx: x-offset,
        dy: (17.7mm - 10mm),
        rect(
          height: 27.3mm,
          width: 90mm,
          stroke: none,
          recipient-field
        )
      )
    }
  ]

  let reference-field(reference, supplement: locals.get-strings(style.locale).reference) = [
    #let field-alignment = top + style.alignment.reference-field.x
    #let y-offset = 0mm
    #if style.alignment.reference-field.y == horizon {
      y-offset = -10mm
    } else if style.alignment.reference-field.y == top {
      y-offset = -55mm
    }
    #place(
      field-alignment,
      dx: 0mm,
      dy: 65mm - 10mm + y-offset,
      [#supplement #en-space() #reference]
    )
  ]

  let _header = [
    #set align(center)
    #text(
      weight: 500,
      size: 1.125em,
      fill: style.text.fill.headline,
      spaced-smallcaps[#author.name]
    )\
    #set text(size: style.text.size.small, fill: style.text.fill.faded)
    #author.address.join(" " + sym.bullet + " ")\
    #phone-number(author.phone) #sym.bullet #email-address(author.email)
  ]
  let letter-style(body) = [
    #set document(
      author: author.name,
      title: title,
      date: date,
    )
    #set page(
      paper: "a4",
      margin: (
        left: 25mm,
        right: 25mm,
        top: 27mm + 10mm,
        bottom: 30mm
      ),
      header: rect(width: 100%, height: 100%, stroke: none, _header),
      header-ascent: 12mm,
      footer: context { rect(width: 100%, stroke: none, height: 100%, [
        #set align(right)
        #set text(size: style.text.size.small)
        #if counter(page).final().at(0) > 1 {
          locals.get-strings(style.locale).page-xy
            .replace("[X]", str(counter(page).get().at(0)))
            .replace("[Y]", str(counter(page).final().at(0)))
        }
      ]) },
      footer-descent: 10mm,
      fill: style.page.fill,
    )
    #set text(
      size: style.text.size.normal,
      font: style.text.font,
      lang: style.locale.lang,
      region: style.locale.region,
      discretionary-ligatures: false,
      features: (onum: 1),
    )
    #set par(first-line-indent: 2em)
    #show heading: set align(style.alignment.headings)
    #show heading: set block(above: 1em, below: 1em)
    #show heading.where(level: 1): set text(size: style.text.size.normal, weight: "bold")
    #show heading.where(level: 2): set text(size: style.text.size.normal, weight: "regular", style: "italic")
    #let date-y-offset = 0mm
    #if style.alignment.date-field.y == top {
      date-y-offset = -55mm
    } else if style.alignment.date-field.y == horizon {
      date-y-offset = -10mm
    }
    #if style.alignment.date-field.x == none {
      style.alignment.date-field.x = right
    }
    #place(
      top + style.alignment.date-field.x,
      dx: 0mm,
      dy: 65mm - 10mm + date-y-offset,
      [
        #if style.components.place-name.display and place-name != none [
          #style.components.place-name.pattern.replace("[place-name]", place-name)
        ]
        #locals.localise-date(date, style.date.format, style.locale)
      ]
    )
    #v(31.46mm + 45mm - 10mm)
    #body
  ]

  let valediction(valediction, signature: none, name: auto) = [
    #if name == auto {
      name = author.name
    }
    #let _inset = 0mm
    #if style.alignment.valediction == right {
      _inset = (left: 105mm - 25mm - 25mm)
    }
    #set par(first-line-indent: 0em)
    #block(above: 3em, inset: _inset, breakable: false)[
      #valediction
      #if signature != none {
        block(signature)
      } else {
        v(3em)
      }
      #name
    ]
  ]

  let cc-field(..recipients) = [
    #let _inset = 0mm
    #if style.alignment.valediction == right {
      _inset = (left: 105mm - 25mm - 25mm)
    }
    #set par(first-line-indent: 0em)
    #block(inset: _inset, breakable: false)[
      #stack(dir: ltr, spacing: 0.5em)[
        #text(style: "italic", locals.get-strings(style.locale).carbon-copy)
      ][
        #if recipients.pos().len() < 3 {
          recipients.pos().join(", ")
        } else {
          recipients.pos().join(",\n")
        }
      ]
    ]
  ]

  let enclosed-field(..enclosures) = [
    #let _inset = 0mm
    #if style.alignment.valediction == right {
      _inset = (left: 105mm - 25mm - 25mm)
    }
    #set par(first-line-indent: 0em)
    #block(inset: _inset, breakable: false)[
      #if enclosures.pos().len() < 2 {
        stack(dir: ltr, spacing: 0.5em)[
          #text(style: "italic", locals.get-strings(style.locale).enclosed-sg)
        ][
          #enclosures.pos().at(0)
        ]
      } else {
        stack(dir: ltr, spacing: 0.5em)[
          #text(style: "italic", locals.get-strings(style.locale).enclosed-pl)
        ][
          #for enclosure in enclosures.pos() {
            [- #enclosure]
          }
        ]

      }
      
    ]
  ]

  return (
    style: style,
    spaced-smallcaps: spaced-smallcaps,
    thin-space: thin-space,
    en-space: en-space,
    phone-number: phone-number,
    email-address: email-address,
    falzmarken: falzmarken,
    address-field: address-field,
    reference-field: reference-field,
    letter-style: letter-style,
    valediction: valediction,
    cc-field: cc-field,
    enclosed-field: enclosed-field,
  )
}
