#import "configs.typ": *
#import "locale.typ": *

#let extract-heading(depth) = { counter(heading).get().slice(0, depth).map(it => str(it)).join(".") }

#let generate-counter(counter-depth, it) = {
  context {
    let has-heading1 = query(heading.where(level: 1)).len() != 0
    let has-heading2 = query(heading.where(level: 2)).len() != 0
    let strit = ""
    if type(it) != str and type(it) != content { strit = str(it) } else { strit = it }
    if has-heading1 and has-heading2 and counter-depth == 3 { extract-heading(2) + "." + strit } else if (
      has-heading1 and (counter-depth == 3 or counter-depth == 2)
    ) {
      extract-heading(1) + "." + strit
    } else { strit }
  }
}

#let stydoc(title, author, body) = {
  set document(title: title, author: author)
  body
}

#let stypar(lang: "zh", par-indent: 2em, leading: 1em, spacing: 1.1em, body) = {
  if leading == none {
    leading = localize("par-leading", lang: lang)
  }
  if spacing == none {
    spacing = localize("par-spacing", lang: lang)
  }
  set par(first-line-indent: par-indent, leading: leading, spacing: spacing)
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

#let styheading(lang: "zh", font: font.heading, counter-depth: 2, matheq-depth: 2, body) = {
  // layout styling
  set heading(numbering: "1.1")
  show heading: it => [
    #set text(font: font)
    #set par(first-line-indent: 0em)
    #v(1em)
    #if it.numbering != none { counter(heading).display() }
    #h(0.2em)
    #it.body
    #v(0.5em)
  ]
  show heading.where(level: 1): it => [
    #v(0.5em)
    #set heading(numbering: { localize("number-format", lang: lang) })
    #it
  ]
  // counter initialization
  show heading.where(level: 1, outlined: true): it => {
    if matheq-depth == 2 or matheq-depth == 3 { counter(math.equation).update(0) }
    if counter-depth == 2 or counter-depth == 3 {
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: raw)).update(0)
    }
    it
  }
  show heading.where(level: 2, outlined: true): it => {
    if matheq-depth == 3 { counter(math.equation).update(0) }
    if counter-depth == 3 {
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: raw)).update(0)
    }
    it
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

#let styfigure(counter-depth: 2, font: font.caption, body) = {
  set figure(gap: 0.5cm)
  show figure.where(kind: image): set figure(numbering: it => generate-counter(counter-depth, it))
  show figure.where(kind: table): set figure(numbering: it => generate-counter(counter-depth, it))
  show figure.where(kind: raw): set figure(numbering: it => generate-counter(counter-depth, it))
  show figure: it => [
    #v(2pt)
    #set text(font: font)
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
  set math.equation(numbering: it => { "(" + generate-counter(eq-depth, it) + ")" })
  body
}

#let stynumbering(numbering: "1", body) = {
  set page(numbering: numbering, number-align: center)
  body
}

#let styheader(header: true, font: font.header, title, info, body) = {
  if header {
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
              return align(left)[#smallcaps(title)]
            } else {
              return none
            }
          }
        }
      },
    )
    body
  } else {
    body
  }
}

#let newpara() = {
  par()[#text(size: 0.0em)[#h(0.0em)]]
  v(-12pt)
}

// colors = (black,gray,silver,white,navy,blue,aqua,teal,eastern,purple,fuchsia,maroon,red,orange,yellow,olive,green,lime,)

#let labelset(body) = {
  show label("eq.c"): set math.equation(numbering: none)
  show label("hd.c"): set heading(numbering: none)
  show label("hd.x"): set heading(numbering: none, outlined: false)
  show label("text.black"): set text(fill: black)
  show label("text.gray"): set text(fill: gray)
  show label("text.silver"): set text(fill: silver)
  show label("text.white"): set text(fill: white)
  show label("text.navy"): set text(fill: navy)
  show label("text.blue"): set text(fill: blue)
  show label("text.aqua"): set text(fill: aqua)
  show label("text.teal"): set text(fill: teal)
  show label("text.eastern"): set text(fill: eastern)
  show label("text.purple"): set text(fill: purple)
  show label("text.fuchsia"): set text(fill: fuchsia)
  show label("text.maroon"): set text(fill: maroon)
  show label("text.red"): set text(fill: red)
  show label("text.orange"): set text(fill: orange)
  show label("text.yellow"): set text(fill: yellow)
  show label("text.olive"): set text(fill: olive)
  show label("text.green"): set text(fill: green)
  show label("text.lime"): set text(fill: lime)
  body
}

