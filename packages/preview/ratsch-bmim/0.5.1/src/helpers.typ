#import "data.typ": *
#import "options.typ": *

#let abstract(body) = context {
  // abstract environment for the article class
  let opts = options.final()
  set par(leading: .5em)
  set text(font: opts.fonts.sans, spacing: 80%, size: 1.1em)
  text(weight: "semibold", fill: opts.theme.primary)[#opts.spell.abstract.]
  text(style: "normal")[#body]
}

// Index of the last of `elements` (in document order) on a page before
// `page`, -1 if there is none. A binary search, as headers and footers ask
// this on every page: the elements come from a query without here(), which
// Typst computes only once.
#let last-before-page(elements, page) = {
  let (lo, hi) = (0, elements.len())
  while lo < hi {
    let mid = calc.quo(lo + hi, 2)
    if elements.at(mid).location().page() < page { lo = mid + 1 } else { hi = mid }
  }
  lo - 1
}

// Last heading on or before the current page: of the given `level`, or with
// a level up to `depth`. Like utils.current-heading of touying, which filters
// all headings of the document on every slide.
#let current-heading(level: none, depth: 6) = {
  let sel = if level != none { heading.where(level: level) } else {
    selector.or(..range(1, depth + 1).map(l => heading.where(level: l)))
  }
  let headings = query(sel)
  let i = last-before-page(headings, here().page() + 1)
  if i >= 0 { headings.at(i) }
}

#let page-is-chap-start() = {
  let chapters = query(heading.where(level: 1))
  let i = last-before-page(chapters, here().page() + 1)
  i >= 0 and chapters.at(i).location().page() == here().page()
}

// Long or short form of a value given as either `x` or `(long, short)`.
// A single-element array `(x,)` is treated like `x`.
#let long(x) = if type(x) == array { x.first() } else { x }
#let short(x) = if type(x) == array { x.last() } else { x }

#let chapter-break(oneside, to: "odd") = if oneside {
  pagebreak(weak: true)
} else {
  pagebreak(to: to, weak: true)
}

// Heading rules shared by book-like variants (lecture, thesis): reduce the
// spacing between consecutive headings and scale the levels 2 to 5.
#let book-headings(spacing-after: 0.2em, body) = {
  // Clever trick to reduce spacing between consecutive headings
  // See https://github.com/typst/typst/issues/2953
  // The location of the previous heading is kept in a state; a query of all
  // previous headings for each heading took quadratic time.
  let previous = state("bmim-previous-heading", none)
  show heading: it => {
    context {
      let prev = previous.get()
      if prev != none {
        let prev-pos = prev.position()
        let it-pos = it.location().position()
        if (it-pos.page == prev-pos.page
          and it-pos.x == prev-pos.x
          and it-pos.y - prev-pos.y < 60pt) { // threshold
          // amount to reduce spacing, could make this dependent on it.level
          v(-0.3em)
        }
      }
    }
    previous.update(it.location())
    [#it #v(spacing-after)]
  }
  show heading.where(level:2): set text(size: 1.4em)
  show heading.where(level:3): set text(size: 1.2em)
  show heading.where(level:4): set text(size: 1.1em)
  show heading.where(level:5): it => text(
    weight: 700,
    it.body) + [.]
  body
}

#let chapter-heading(inset: 2em, weight: auto, style) = it => context {
  if query(<appendix>).any(e => e == it) { return }
  set text(weight: weight) if weight != auto
  set block(inset: (y: inset))
  show: strong
  show: block
  if it.numbering == none { it.body; return }
  style(it, numbering(it.numbering, ..counter(heading).get()))
}

// Name of the institute (option 'institute') in the language of the document,
// none without an institute
#let institute-name(opts) = {
  let inst = opts.institute
  if inst == none { none } else if type(inst) == dictionary { inst.at("name", default: none) } else {
    institutes.at(inst).name.at(opts.lang)
  }
}

// White logo of the institute (option 'institute') at the place `place` (see
// institute-places) with the given `height`, scaled and shifted by scale and
// dy of the institute; an own logo (content) is shown as given, none without
// an institute (the colored bar then runs through to the UMIT TIROL logo)
#let place-institute-logo(opts, place, height: auto) = {
  assert(place in institute-places, message: "Unknown place '" + place + "' of the institute logo")
  let inst = opts.institute
  if inst == none { return none }
  if type(inst) == dictionary { return inst.at("logo", default: none) }
  let entry = institutes.at(inst)
  // a single value, or a dictionary per place with `rest` for the others
  let at-place(key, default) = {
    let value = entry.at(key, default: default)
    if type(value) == dictionary {
      value.at(place, default: value.at("rest", default: default))
    } else { value }
  }
  let height = if height == auto { auto } else { height * (at-place("scale", 100%) / 100%) }
  let logo = image("./../assets/" + entry.logo, height: height)
  let dy = at-place("dy", 0%)
  if dy == 0% or height == auto { logo } else {
    box(move(dy: height * (dy / 100%), logo))
  }
}

// Language part of the file names of the UMIT TIROL logos and footers
#let umit-lang(opts) = if opts.lang == "de" { "gr" } else { "en" }

// UMIT TIROL logo in the language of the document, `color` "white" or
// "blue", `subtitle` with the line below the name ("Die Tiroler
// Privatuniversität"); `args` (e.g. height) are passed to image
#let umit-logo(color: "white", subtitle: true, ..args) = context {
  assert(color in ("white", "blue"), message:
    "Argument 'color' of umit-logo must be one of [\"white\", \"blue\"], but was set to " + repr(color))
  assert(type(subtitle) == bool, message:
    "Argument 'subtitle' of umit-logo must be true or false, but was set to " + repr(subtitle))
  let opts = options.final()
  let variant = if not subtitle { "wo" } else { umit-lang(opts) }
  image("./../assets/logo_umit_" + color + "_" + variant + ".svg", ..args)
}

// White logo of an institute: `institute` is a key of institutes (data.typ),
// auto: the one of the option 'institute'; `args` (e.g. height) are passed to
// image. An own institute of the option (dictionary) gives its logo as given,
// none (also of the option) gives none.
#let institute-logo(institute: auto, ..args) = context {
  let inst = if institute == auto { options.final().institute } else { institute }
  if inst == none { return none }
  if type(inst) == dictionary { return inst.at("logo", default: none) }
  assert(inst in institutes, message:
    "Argument 'institute' of institute-logo must be one of [" +
    institutes.keys().map(repr).join(", ") + "], but was set to " + repr(inst))
  image("./../assets/" + institutes.at(inst).logo, ..args)
}

#let pick-logo(logo, key) = if type(logo) == dictionary {
  logo.at(key, default: auto)
} else {
  logo
}

// Chapters (level 1 headings) start on a new (two-sided: odd) page
#let chapters-on-new-page(oneside, body) = {
  show heading.where(level: 1): it => {
    chapter-break(oneside)
    it
  }
  body
}

// Pages inserted by pagebreak(to: "odd") or (to: "even") stay empty, without
// header and footer
#let empty-pages-plain(body) = {
  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(header: none, footer: none)
  body
}

// Lists of the option `lists` and the option `frontmatter` after the table of
// contents of the book-like variants (lecture, thesis, workbook), each on a
// new (two-sided: odd) page.
#let front-lists = context {
  let opts = options.final()
  for entry in opts.lists {
    let (kind, title) = if type(entry) == dictionary {
      (entry.kind, entry.title)
    } else {
      (entry, (image: opts.spell.lof, table: opts.spell.lot, raw: opts.spell.lol)
        .at(repr(entry)))
    }
    heading(numbering: none, outlined: true, title)
    outline(title: none, target: figure.where(kind: kind, outlined: true))
    chapter-break(opts.oneside)
  }
  if opts.frontmatter != none {
    opts.frontmatter
    chapter-break(opts.oneside)
  }
}

// Front matter (roman page numbers, starting with the table of contents) and
// main part (arabic page numbers from 1 on, chapters on a new page) of the
// book-like variants. This happens in the variant and not with
// `#show: mainmatter` in the document, so it also works in the article mode of
// the slides, where touying neither enters `context` nor allows `set page` in
// the content.
#let book-matter(oneside, body) = {
  set page(numbering: "i")
  context heading(numbering: none, outlined: false, options.final().spell.toc)
  outline(title: none)
  chapter-break(oneside)
  front-lists

  set page(numbering: "1")
  counter(page).update(1)
  show: chapters-on-new-page.with(oneside)
  body
}

#let mainmatter(content) = context {
  show: chapters-on-new-page.with(options.final().oneside)
  set page(numbering: "1")
  counter(page).update(1)

  content
}

// Set to true from the start of the backmatter (appendix) on
#let backmatter-state = state("bmim-backmatter", none)

#let backmatter(content, to: "odd") = context {
  let opts = options.final()
  set heading(numbering: "A.1", supplement: opts.spell.appendix)
  counter(heading).update(0)
  backmatter-state.update(true)
  {
    show heading: none
    chapter-break(opts.oneside, to: to)
    [#heading(numbering: none)[#opts.spell.appendix] <appendix>]
  }
  content
}

#let translated-month(dt, lang) = {
  if lang == "de" {
    months.at(dt.month() - 1)
  } else {
    dt.display("[month repr:long]")
  }
}

#let print-date(date) = {
  let opts = options.final()
  if type(date) != datetime {
    date
  } else if opts.lang == "de" {
    [#date.day(). #translated-month(date, opts.lang) #date.year()]
  } else {
    [#translated-month(date, opts.lang) #date.day(), #date.year()]
  }
}

// English ordinal suffix of a day: 1st, 2nd, 3rd, 4th, ..., 11th, 12th, 13th, 21st
#let ordinal-suffix(day) = {
  if calc.rem(day, 100) in (11, 12, 13) { "th" }
  else if calc.rem(day, 10) == 1 { "st" }
  else if calc.rem(day, 10) == 2 { "nd" }
  else if calc.rem(day, 10) == 3 { "rd" }
  else { "th" }
}

// Date with the time if the datetime has one, e.g. for the badge of the flyer:
// "5. November 2026, 17.00 Uhr" or "5th November 2026, 17:00"
#let print-date-time(date, end: none) = {
  let opts = options.final()
  let time(date) = if opts.lang == "de" {
    date.display("[hour].[minute]")
  } else {
    date.display("[hour]:[minute]")
  }
  let unit = if opts.lang == "de" [ Uhr]
  let print(date) = {
    if type(date) != datetime { return date }
    let day = if opts.lang == "de" {
      print-date(date)
    } else {
      [#date.day()#super(ordinal-suffix(date.day())) #translated-month(date, opts.lang) #date.year()]
    }
    if date.hour() == none { day } else [#day, #time(date)#unit]
  }
  if end == none { return print(date) }
  let same-day = (
    type(date) == datetime and type(end) == datetime
      and date.year() == end.year() and date.month() == end.month() and date.day() == end.day()
      and date.hour() != none and end.hour() != none
  )
  if same-day {
    // e.g. "5th November 2026, 17:00–18:30"
    let day = print(datetime(year: date.year(), month: date.month(), day: date.day()))
    [#day, #time(date)–#time(end)#unit]
  } else {
    [#print(date) – #print(end)]
  }
}

#let print-semester(date) = {
  let opts = options.final()
  if type(date) != datetime {
    none
  } else if date.month() > 3 and date.month() < 10 {
    [#opts.spell.summer-term #date.year()]
  } else {
    let start = if date.month() <= 3 { date.year() - 1 } else { date.year() }
    [#opts.spell.winter-term #start/#(start + 1)]
  }
}

#let is-empty(value) = value in (none, "", (), (:), [])

// Show rule of references to elements marked with the metadata `mark` (tasks,
// enum items): a link with the supplement (auto: `supplement`) and the number
// `num(loc)` at the location of the element; other references stay as they are
#let marked-ref(it, mark, supplement, num) = {
  let el = it.element
  if el == none or el.func() != metadata or el != mark { return it }
  let supp = if it.supplement == auto { supplement } else { it.supplement }
  let loc = el.location()
  let n = num(loc)
  link(loc, if is-empty(supp) { n } else { box[#supp~#n] })
}

#let show-marks(m, ys) = context {
  if m == none { return }
  let y = if type(ys) == array { ys } else { (ys,) }
  let p = m.pages
  if p != "both" and ((p == "odd") != calc.odd(counter(page).get().first())) {
    return
  }
  let l = line(length: m.length, stroke: m.stroke)
  for _y in y { place(top + left, dx: m.xdist, dy: _y, l) }
}

// --- vCard and iCalendar, e.g. as data of a QR code

// Escape a text value (vCard 3.0, iCalendar): backslash, semicolon, comma and
// line breaks
#let escape-text(value) = {
  assert(type(value) == str, message:
    "vCard and iCalendar values must be strings, but got " + repr(value)
  )
  value
    .replace("\\", "\\\\")
    .replace(";", "\;")
    .replace(",", "\\,")
    .replace("\n", "\\n")
}

// Lines longer than 75 octets must be folded: CRLF followed by a space, which
// counts towards the next line. `len` counts the octets of the UTF-8 string.
#let fold-line(line) = {
  if line.len() <= 75 { return line }
  let parts = ()
  let current = ""
  let limit = 75
  for c in line.clusters() {
    if current.len() + c.len() > limit {
      parts.push(current)
      current = ""
      limit = 74
    }
    current += c
  }
  parts.push(current)
  parts.join("\r\n ")
}

// Lines separated by CRLF, the last one included
#let join-lines(lines) = lines.map(fold-line).join("\r\n") + "\r\n"

// Assert that `dict` is a dictionary with known keys and the required keys
#let assert-keys(dict, of, known, required: ()) = {
  assert(type(dict) == dictionary, message:
    "Argument of " + of + " must be a dictionary, but was " + repr(dict)
  )
  for key in dict.keys() {
    assert(key in known, message:
      "Unknown key '" + key + "' of " + of + ", known keys are [" +
      known.map(repr).join(", ") + "]"
    )
  }
  for key in required {
    assert(dict.at(key, default: none) != none, message:
      "Key '" + key + "' of " + of + " must be set"
    )
  }
}

// `dict` with all `keys`, the missing ones none; unknown keys are an error
#let with-defaults(dict, of, keys) = {
  assert-keys(dict, of, keys)
  keys.map(key => (key, none)).to-dict() + dict
}

// Contact as vCard 3.0. All keys are optional, but one of firstname and
// lastname is needed:
// (title: "Dr.-Ing.", firstname: .., lastname: .., role: .., organization: ..,
//  address: (street: .., zip: .., town: .., country: ..),
//  telephone: .., email: .., url: ..)
#let build-vcard(contact) = {
  assert-keys(contact, "build-vcard", (
    "title", "firstname", "lastname", "role", "organization", "address",
    "telephone", "email", "url",
  ))
  let get(key) = contact.at(key, default: none)
  let esc(key) = if get(key) == none { "" } else { escape-text(get(key)) }
  assert(get("firstname") != none or get("lastname") != none, message:
    "Key 'firstname' or 'lastname' of build-vcard must be set"
  )

  let lines = ("BEGIN:VCARD", "VERSION:3.0")
  // N: family name; given name; additional names; prefix; suffix
  lines.push("N:" + esc("lastname") + ";" + esc("firstname") + ";;" + esc("title") + ";")
  lines.push("FN:" + escape-text(
    ("title", "firstname", "lastname").map(get).filter(x => x != none).join(" ")
  ))
  if get("organization") != none { lines.push("ORG:" + esc("organization")) }
  if get("role") != none { lines.push("TITLE:" + esc("role")) }
  if get("address") != none {
    let adr = get("address")
    assert-keys(adr, "the address of build-vcard", ("street", "zip", "town", "country"))
    let part(key) = escape-text(adr.at(key, default: ""))
    // ADR: post office box; extended address; street; town; region; zip; country
    lines.push("ADR;TYPE=WORK:;;" + part("street") + ";" + part("town") + ";;" +
      part("zip") + ";" + part("country"))
  }
  if get("telephone") != none { lines.push("TEL;TYPE=WORK:" + esc("telephone")) }
  if get("email") != none { lines.push("EMAIL;TYPE=INTERNET:" + esc("email")) }
  if get("url") != none { lines.push("URL:" + esc("url")) }
  lines.push("END:VCARD")
  join-lines(lines)
}

// Date line of an iCalendar event: with time, or an all-day event for a
// datetime without time
#let vcalendar-date(key, date) = {
  assert(type(date) == datetime, message:
    "Key '" + lower(key.slice(2)) + "' of build-vcalendar must be a datetime, " +
    "but was set to " + repr(date)
  )
  if date.hour() == none {
    key + ";VALUE=DATE:" + date.display("[year][month][day]")
  } else {
    key + ":" + date.display("[year][month][day]T[hour][minute][second]")
  }
}

// Event as iCalendar (RFC 5545). `name` and `start` are required, `start`
// and `end` are datetimes, without time an all-day event:
// (name: .., start: datetime, end: datetime, location: .., description: ..,
//  uid: ..)
#let build-vcalendar(event) = {
  assert-keys(event, "build-vcalendar",
    ("name", "start", "end", "location", "description", "uid"),
    required: ("name", "start"),
  )
  let get(key) = event.at(key, default: none)
  let start = vcalendar-date("DTSTART", event.start)
  // a unique id is required, derived from the start and the name by default
  let uid = if get("uid") != none { get("uid") } else {
    start.split(":").last() + "-" + lower(event.name).replace(regex("[^a-z0-9]+"), "-") + "@ratsch-bmim"
  }

  let lines = (
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//ratsch-bmim//typst//EN",
    "BEGIN:VEVENT",
    "UID:" + escape-text(uid),
    // creation time of the event, required
    "DTSTAMP:" + datetime.today().display("[year][month][day]") + "T000000Z",
    "SUMMARY:" + escape-text(event.name),
    start,
  )
  if get("end") != none { lines.push(vcalendar-date("DTEND", event.end)) }
  if get("location") != none { lines.push("LOCATION:" + escape-text(event.location)) }
  if get("description") != none { lines.push("DESCRIPTION:" + escape-text(event.description)) }
  lines += ("END:VEVENT", "END:VCALENDAR")
  join-lines(lines)
}
