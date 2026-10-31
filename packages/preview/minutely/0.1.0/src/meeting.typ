#import "i18n.typ": tr, fmt-date

// Horizontal indent per heading level.
#let step = 1.5em

#let _join(v) = if type(v) == array { v.join(", ") } else if v == none { "" } else { v }

#let _heading-numbering(..n) = {
  let parts = n.pos()
  let fmt = ("1)", "a)", "i)").at(calc.min(parts.len(), 3) - 1)
  numbering(fmt, parts.last())
}

#let _formalia(is-agenda, chair, minute-taker, attendees, extra, approved, attendees-label) = {
  let placeholder = text(luma(40%), emph(tr("placeholder")))
  let or-ph(v) = if v != none and v != "" { v } else { placeholder }
  [
    = #tr("formalia")
    == #tr("chair")
    #or-ph(chair)
    == #tr("minute-taker")
    #or-ph(minute-taker)
    == #if attendees-label != none { attendees-label } else { tr("attendees") }
    #or-ph(_join(attendees))
    #if extra not in (none, "") [
      == #tr("extra-attendees")
      #extra
    ]
    #if not is-agenda [
      == #tr("approval")
      #or-ph(if approved == auto { tr("approved") } else { approved })
    ]
  ]
}

// Base template. Organisation templates wrap this via `.with(...)`.
#let meeting(
  organisation: none,
  meeting-name: "meeting",
  kind: "minutes",            // "minutes"/"referat" or "agenda"/"dagsorden"
  title: auto,
  date: datetime.today(),
  time: none,
  location: none,
  chair: none,
  minute-taker: none,
  attendees: (),
  attendees-label: none,
  extra-attendees: (),
  approved: auto,
  formalia: true,
  author: none,
  logo: none,
  lang: auto,                // auto: "da" if meeting-name/kind is Danish (møde, referat, …), else "en"
  font: "New Computer Modern",
  body,
) = {
  let lang = if lang != auto { lang } else {
    let words = lower(meeting-name + " " + kind)
    let danish = ("møde", "generalforsamling", "referat", "dagsorden")
    if danish.any(w => words.contains(w)) { "da" } else { "en" }
  }
  assert(lang in ("da", "en"), message: "minutely: lang must be \"da\", \"en\" or auto, got " + repr(lang))
  set text(font: font, size: 11pt, lang: lang)
  let is-agenda = lower(kind) in ("agenda", "dagsorden")
  let org = if organisation != none [ #tr("in") #organisation ]
  let title = if title != auto { title } else if is-agenda {
    [#tr("agenda-of") #meeting-name#org]
  } else {
    [#tr("minutes") #meeting-name#org]
  }

  set document(author: if author != none { author } else { () })
  set page(
    paper: "a4",
    margin: (top: 2.6cm, bottom: 2.6cm, x: 2.5cm),
    header: if organisation != none { align(center, text(10pt, organisation)) },
    footer: context {
      set text(9pt)
      grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        fmt-date(date),
        [#tr("page") #counter(page).display() #tr("of") #counter(page).final().first()],
        if author != none { author },
      )
    },
  )
  set par(justify: true, leading: 0.62em, spacing: 1.05em, first-line-indent: 0pt)
  set list(marker: ([•], [–], [∗]), indent: 0pt, body-indent: 0.5em)
  set enum(indent: 0pt)
  set heading(numbering: _heading-numbering)

  // Body is padded by `step`; headings are pulled back so level 1 sits at the margin.
  show heading: it => block(above: if it.level == 1 { 1.3em } else { 1.0em }, below: 0.6em, {
    set text(weight: "bold", size: 11pt)
    pad(left: (it.level - 2) * step, {
      if it.numbering != none { counter(heading).display(it.numbering); h(0.6em) }
      it.body
    })
  })

  assert(type(logo) != str, message: "logo must be content, e.g. logo: image(\"logo.png\"), a path string cannot be resolved from inside the package")
  // Title block
  grid(
    columns: (1fr, if logo != none { 2.6cm } else { 0pt }),
    {
      text(16pt, weight: "bold", title)
      linebreak()
      v(0.2em)
      text(12pt, weight: "bold")[
        #fmt-date(date)#if time != none [ #tr("at") #time]#if location != none [ #tr("in") #location]
      ]
    },
    if logo != none { place(top + right, dy: -0.5cm, logo) },
  )
  v(0.8em)

  pad(left: step, {
    if formalia {
      _formalia(is-agenda, chair, minute-taker, attendees, _join(extra-attendees), approved, attendees-label)
    }
    body
  })
}
