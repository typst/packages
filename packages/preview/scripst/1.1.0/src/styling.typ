#import "configs.typ": *
#import "locale.typ": *

#let stydoc(title, author, body) = {
  set document(title: title, author: author)
  body
}

#let stypar(first-line-indent: 2em, leading: 1.1em, body) = {
  set par(first-line-indent: first-line-indent, leading: leading)
  body
}

#let stytext(font: font.body, lang: "zh", region: "cn", size: 11pt, body) = {
  set text(font: font, lang: lang, region: region, size: size)
  body
}

#let stystrong(font: font.strong, body) = {
  show strong: set text(font: font)
  body
}

#let styemph(font: font.emph, body) = {
  show emph: set text(font: font)
  body
}

#let styheading(lang: "zh", font: font.heading, body) = {
  set heading(numbering: "1.1")
  show heading: it => box(width: 100%)[
    #set text(font: font)
    #v(-0.8em)
    #if it.numbering != none { counter(heading).display() }
    #h(0.2em)
    #it.body
    #v(0.5em)
  ]
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    box(width: 100%)[
      #v(0.3em)
      #set heading(numbering: { localize("number_format", lang: lang) })
      #it
    ]
  }
  body
}

#let stychapter(body) = {
  show heading.where(level: 1): it => align(center)[
    #v(2em)
    #set text(1.5em)
    #it
  ]
  body
}

#let styfigure(body) = {
  set figure(gap: 0.5cm)
  show figure: it => [
    #v(2pt)
    #set text(font: font.caption)
    #it
    #v(-2em)
    #par()[#text(size: 0.0em)[#h(0.0em)]]
    #v(13pt)
  ]
  body
}

#let styimage(body) = {
  show image: it => [
    #it
    #v(-1.1em)
    #par()[#text(size: 0.0em)[#h(1.0em)]]
  ]
  body
}

#let stytable(font: font.body, body) = {
  show table: it => [
    #set text(font: font)
    #it
  ]
  body
}

#let styenum(indent: 2em, body) = {
  set enum(indent: indent)
  show enum: it => [
    #it
    #par()[#text(size: 0.0em)[#h(0.0em)]]
    #v(-12pt)
  ]
  body
}

#let stylist(indent: 2em, body) = {
  set list(indent: indent)
  show list: it => [
    #it
    #par()[#text(size: 0.0em)[#h(0.0em)]]
    #v(-12pt)
  ]
  body
}

#let stytermlist(indent: 2em, body) = {
  set terms(indent: indent)
  show terms: it => [
    #it
    #par()[#text(size: 0.0em)[#h(0.0em)]]
    #v(-12pt)
  ]
  body
}

#let styquote(font: font.quote, body) = {
  show quote: it => [
    #set text(font: font)
    #align(center)[#emph[#it]]
  ]
  body
}

#let styref(color: red, body) = {
  show ref: set text(color)
  body
}

#let styraw(font: font.raw, body) = {
  show raw.where(block: true): block.with(
    width: 100%,
    fill: luma(240),
    inset: 10pt,
    radius: 5pt,
  )
  show raw.where(block: true): set par(leading: 0.7em)
  show raw: set text(font: (font, "simsun"), size: 10pt)
  body
}

#let stylink(color: blue, body) = {
  show link: set text(fill: color)
  body
}

#let stymatheq(eq-depth: 2, body) = {
  set math.equation(
    numbering: it => {
      let section = query(heading.where(level: 1, outlined: true).before(here())).len()
      if eq-depth == 2 {
        numbering("(1.1)", section, it)
      } else {
        numbering("(1)", it)
      }
    },
  )
  body
}

#let stynumbering(numbering: "1", body) = {
  set page(numbering: numbering, number-align: center)
  body
}

#let styheader(font: font.header, title, info, body) = {
  set page(
    header: {
      set text(font: font)
      context {
        if here().position().page == 1 { return }
        let secs = query(heading.where(level: 1))
        let sec = ()
        for s in secs.rev() {
          if s.location().page() <= here().position().page {
            sec = s
            break
          }
        }

        let mksec = sec => {
          let loc = sec.location()
          let text = smallcaps(sec.body.text)
          let num = counter(heading).at(loc).map(str).join("")
          let secnum = num + " " + text
          return secnum
        }

        if sec != none and sec != () {
          let secnum = mksec(sec)
          if info != "" and info != none {
            return grid(columns: (1fr,) * 3, align: (left, center, right))[#smallcaps(title)][#info][#secnum]
          } else if title != "" and title != none {
            return grid(columns: (1fr,) * 2, align: (left, right))[#smallcaps(title)][#secnum]
          } else {
            return align(right)[#secnum]
          }
        } else {
          if info != "" and info != none {
            return grid(columns: (1fr,) * 2, align: (left, right))[#smallcaps(title)][#info]
          } else if title != "" and title != none {
            return align(lest)[#smallcaps(title)]
          } else {
            return none
          }
        }
      }
    },
  )
  body
}

#let newpara() = {
  par()[#text(size: 0.0em)[#h(0.0em)]]
  v(-12pt)
}
