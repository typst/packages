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

#let page-is-chap-start() = {
  return query(heading.where(level: 1))
    .map(it => it.location().page())
    .contains(here().page())
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
  show heading: it => {
    // Clever trick to reduce spacing between consecutive headings
    // See https://github.com/typst/typst/issues/2953
    let previous-headings = query(selector(heading).before(here(),
      inclusive: false))
    if previous-headings.len() > 0 {
      let prev-pos = previous-headings.last().location().position()
      let it-pos = it.location().position()
      if (it-pos.page == prev-pos.page
        and it-pos.x == prev-pos.x
        and it-pos.y - prev-pos.y < 60pt) { // threshold
        // amount to reduce spacing, could make this dependent on it.level
        v(-0.3em)
      }
    }
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

// Name of the institute (option 'institute') in the language of the document
#let institute-name(opts) = {
  let inst = opts.institute
  if type(inst) == dictionary { inst.at("name", default: none) } else {
    institutes.at(inst).name.at(opts.lang)
  }
}

// White logo of the institute (option 'institute') at the place `place` (see
// institute-places) with the given `height`, scaled and shifted by scale and
// dy of the institute; an own logo (content) is shown as given
#let place-institute-logo(opts, place, height: auto) = {
  assert(place in institute-places, message: "Unknown place '" + place + "' of the institute logo")
  let inst = opts.institute
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

// UMIT TIROL logo in the language of the document, `color` "white" or
// "blue", `subtitle` with the line below the name ("Die Tiroler
// Privatuniversität"); `args` (e.g. height) are passed to image
#let umit-logo(color: "white", subtitle: true, ..args) = context {
  assert(color in ("white", "blue"), message:
    "Argument 'color' of umit-logo must be one of [\"white\", \"blue\"], but was set to " + repr(color))
  assert(type(subtitle) == bool, message:
    "Argument 'subtitle' of umit-logo must be true or false, but was set to " + repr(subtitle))
  let opts = options.final()
  let variant = if not subtitle { "wo" } else if opts.lang == "de" { "gr" } else { "en" }
  image("./../assets/logo_umit_" + color + "_" + variant + ".svg", ..args)
}

// White logo of an institute: `institute` is a key of institutes (data.typ),
// auto: the one of the option 'institute'; `args` (e.g. height) are passed to
// image. An own institute of the option (dictionary) gives its logo as given.
#let institute-logo(institute: auto, ..args) = context {
  let inst = if institute == auto { options.final().institute } else { institute }
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

#let headings-on-odd-page(it) = {
  show heading.where(level: 1): it => {
    pagebreak(to: "odd")
    it
  }
  it
}

#let headings-on-next-page(it) = {
  show heading.where(level: 1): it => {
    pagebreak()
    it
  }
  it
}

#let mainmatter(content) = context {
  let opts = options.final()

  show: if opts.oneside {headings-on-next-page } else { headings-on-odd-page }

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

#let is-empty(value) = {
  let empty-values = (
    array: (),
    dictionary: (:),
    str: "",
    content: [],
  )
  let t = repr(type(value))
  if t in empty-values {
    return value == empty-values.at(t)
  } else {
    return value == none
  }
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
