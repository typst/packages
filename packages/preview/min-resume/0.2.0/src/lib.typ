// Minimal Résumé
// TODO: Implement web résumé (HTML) when stable

/**#v(1fr)#outline()#v(1.2fr)#pagebreak()
= Quick Start
```typ
#import "@preview/min-resume:0.2.0": resume
#show: manual.resume(
  name: "Name",
  title: "Academic Title and/or Occupation",
  photo: image("photo.png"),
  personal: "Relevant personal info",
  birth: (1997, 05, 19),
  address: "Public Address",
  email: "example@email.com",
  phone: "+1 (000) 000-0000",
)
```

= Description
Generate a modern and straightforward résumé that meets today's Human Resources
demands for assertiveness. There are no colorful designs, images, creative fonts,
or anything that distracts from reading the document: it's just plain black
sans-serif text on white paper. In fact, someone who sees only the resulting
résumé might think it was written in Word — but it was actually created with all
of Typst's benefits and conveniences.

The package was created with Brazilian trends and practices for Human Resources
in mind; thus, if any information is missing or unnecessary for you, feel free
to adapt it to your needs.

= Options
:show.with resume:
**/
#let resume(
  name: none, /// <- string | content <required>
    /// Full name. |
  title: none, /// <- string | content
    /// Academic title or occupation. |
  photo: none, /// <- image | content
    /// Photo or other identification (like a `#linkedin` QR code). |
  info: none, /// <- string | content
    /// Basic personal information. |
  birth: none, /// <-  array | dictionary
    /// `(year, month, day)`\ Birthday date. |
  address: none, /// <- string | content <required>
    /// Public address (no street nor house number). |
  email: none, /// <- string
    /// Email address. |
  phone: none, /// <- string
    /** Phone number, started by #url("https://www.countrycode.org/")[
        country code.] |**/
  data: (), /// <- yaml | dictionary
    /// Generate YAML-based document (see @data section). |
  cfg: (:), /// <- dictionary
    /// Custom settings (see @cfg section). |
  body
) = context {
  assert.ne(name, none, message: "#resume(name) required")
  assert.ne(address, none, message: "#resume(address) required")
  assert.eq(type(cfg), dictionary, message: "#resume(cfg) must be dictionary")
  assert.eq(type(data), array, message: "#resume(data) must be array")
  
  import "@preview/nexus-tools:0.1.0": storage, default, get, its
  import "@preview/transl:0.2.0": transl
  
  /**
  == Custom Settings <cfg>
  :arg cfg: "let"
  **/
  let cfg = (
    country-code: false, /// <- boolean
      /// Show the `+` country code in final result. |
    letter-show: true, /// <- boolean
      /// Show `#letter` content. |
    lists: par, /// <- par | list | enum
      /// Display `#list` content as inline, unnumbered, or numbered topics. |
    entry-period: true, /// <- boolean
      /// Show period between dates of `#entry(time)` commands. |
    entry-dates: "MMM/yyyy", /// <- string
      /// Date pattern used in `#entry`. |
    data-assets: (:), /// <- dictionary
      /// `(name: asset)`\ Expose assets inside YAML-based document scope. |
    transl: yaml("assets/lang.yaml"), /// <- yaml | toml | dictionary
      /// Translation data (see `src/assets/lang.yaml` file). |
    typst-defaults: false, /// <- boolean
      /// Revert back Typst defaults instead of those defined by _min-resume_. |
  ) + cfg
  let birth = birth
  let photo = photo
  let phone = phone
  let font-size = default(
    when: text.size == 11pt and not cfg.typst-defaults,
    value: 12pt,
    otherwise: text.size,
    false
  )
  let font-title = default(
    when: text.font == "libertinus serif",
    value: (font: ("tex gyre adventor", "century gothic")),
    cfg.typst-defaults
  )
  
  storage.add("cfg", cfg, namespace: "min-resume")
  
  transl(data: cfg.transl)
  
  set document(
    title: name + " - " + title,
    author: name,
    date: datetime.today(),
  )
  set page(
    ..default(
      when: page.margin == auto,
      value: (margin: 2cm),
      cfg.typst-defaults
    ),
    header: context if locate(here()).page() > 2 {
      // Name and title in header after 1st page
      align(
        right,
        text(font-size - 2pt)[#name\ #title]
      )
    },
  )
  set par(
    ..default(
      when: not par.justify,
      value: (justify: true),
      cfg.typst-defaults
    ),
    ..default(
      when: par.leading == 0.65em,
      value: (leading: 0.6em),
      cfg.typst-defaults
    ),
  )
  set text(
    size: font-size,
    ..default(
      when: text.font == "libertinus serif",
      value: (font: ("Tex Gyre Heros", "Arial")),
      cfg.typst-defaults
    ),
    ..default(
      when: text.hyphenate == auto,
      value: (hyphenate: true),
      cfg.typst-defaults
    ),
  )
  set terms(separator: [: ], tight: true)
  set underline(offset: 3pt)
  
  show quote: set pad(x: 1em)
  show heading: set text(
    size: font-size + 1pt,
    ..font-title,
  )
  show heading: set block(
    above: par.spacing,
    below: par.spacing,
  )
  show heading: it => upper(it)
  
  // Main header
  {
    set align(center)
    
    text(upper(name), size: 1.2em, weight: "bold", ..font-title)
    linebreak()
    title
  }
  v(0.5em)
  
  // Personal info
  let personal
  
  if photo != none {photo = block(photo, height: 4.8em, inset: 0pt, outset: 0pt)}
  if info != none {
    personal += info
    personal += if birth != none {", "} else {"."}
  }
  if birth != none {
    let birth = get.date(..birth)
    let curr = datetime(
      year: datetime.today().year(),
      month: birth.month(),
      day: birth.day()
    )
    let age = datetime.today().year() - birth.year()
    
    if curr > datetime.today() {age -= 1}
    
    personal += str(age) + " "
    personal += transl("years-old") + "."
  }
  if info != none or birth != none {personal += linebreak()}
  personal += address + "." + linebreak()
  if email != none {personal += link("mailto:" + email) + linebreak()}
  if phone != none {
    assert(
      phone.starts-with("+"),
      message: "Telephone country code required (e.g.: +1 000 000-0000)"
    )
    
    let url = "https://wa.me/" + phone.replace(regex("[^0-9]"), "")
    
    if cfg.country-code == false {phone = phone.replace(regex("^\+\d+"), "")}
    
    personal += link(url, phone.trim())
  }
  
  grid(
    columns: (4.8em, 1fr),
    photo,
    align(right, personal),
  )
  
  // #resume(data) content
  if data != (:) {
    assert.eq(type(data), array, message: "#resume(data) must be array")

    import "lib.typ" as self
    
    let eval = eval.with(
      scope: dictionary(self) + cfg.data-assets,
      mode: "markup"
    )
      
    for elem in data {
      assert.eq(
        type(elem), dictionary,
        message: "All #resume(data.elem) must be dictionary"
      )
      assert.eq(
        elem.len(), 1,
        message: "Element data." + elem.keys().at(0) + " has more than 1 key"
      )
      
      let kind = elem.keys().join()
      let data = elem.at(kind)
      
      if kind == "hide" {continue}
      
      if kind == "header" {heading(level: 1, data)}
      else if kind == "code" {eval(data)}
      else if kind == "entry" {
        if data.at("skills", default: "") != "" and type(data.skills) == str {
          data.skills = eval(data.skills)
        }
        self.entry(..data)
      }
      else if kind == "list" {
        if type(data) == str {data = eval(data)}
        self.list(data)
      }
      else if kind == "linkedin" {self.linkedin(data)}
      else if kind == "letter" {self.letter(eval(data.remove("body")), ..data)}
      else {panic("Invalid data kind: " + kind)}
    }
  }
  
  body
  
  storage.namespace("min-resume")
  
  // Letter
  context if not its.empty( storage.final("letter", (:)) ) {
    let stored = storage.final("letter", (:))
    
    if cfg.letter-show {
      import "@preview/datify:1.0.0": custom-date-format
      
      if stored.to == none {stored.to = transl("hr-dept") + "."}
      
      pagebreak()
      
      grid(
        columns: (1fr, 1fr),
        gutter: 10pt,
        stored.to,
        {
          set align(right)
          
          name
          linebreak()
          if title != none {
            title
            linebreak()
          }
          address
        }
      )
      
      v(2em)
      
      custom-date-format(
        datetime.today(),
        pattern: "long",
        lang: text.lang,
      ) + "."
      
      parbreak()
      
      stored.body
    }
  }
}


/// = Commands

/**
== Letter
:letter:
**/
#let letter(
  to: none, /// <- string | content
    /// Letter receiver.
  body
) = context {
  import "@preview/nexus-tools:0.1.0": storage

  let data = (to: to, body: body)
  
  storage.add("letter", data, append: true, namespace: "min-resume")
}


/**
== Custom List
:list:
Generate custom lists of topics; by default, an inline bullet list (see 
`cfg.lists` option in @cfg).
**/
#let list(body) = context {
  import "@preview/nexus-tools:0.1.0": storage
  import "origin.typ"
  
  let mode = storage.get("cfg", namespace: "min-resume").lists
  let items = ()
  let sep = [ #sym.bullet ]
  
  if type(body) == str {return body}
  if type(body) == array {items = (..body,)}
  else if body.has("text") {return body.text}
  else {
    for child in body.children {
      if child.has("body") {
        items.push(child.body)
      }
    }
  }
  
  if mode == par {items.join(sep)}
  else if mode == list or mode == origin.list {origin.list(..items)}
  else if mode == enum {enum(..items)}
  else {
    panic("Invalid #resume(cfg.lists) mode: " + repr(mode))
  }
}


/**
== Data Entry
:entry:
Insert a professional experience or academic degree.
**/
#let entry(
  title: none, /// <- string | content
    /// Occupation or course name. |
  organization: none, /// <- string | content
    /// Organization related to the entry (enterprise, university, etc.). |
  location: none, /// <- string | context
    /// Organization location. |
  time: (:), /// <- dictionary of arrays | dictionary of datetimes | array
    /** `(from: (yyyy, mm, dd), to: (yyyy, mm, dd))   (yyyy, mm, dd)`\
        Start and end of entry; omit end date to insert a current one. |**/
  skills: none, /// <- list | string
    /// Related skills and topics (the same as `#list`).
) = context {
  assert.ne(title, none, message: "#entry(title) required")
  assert.ne(organization, none, message: "#entry(organization) required")
  assert.ne(time, (:), message: "#entry(time) required")
  assert(type(time) in (array, dictionary), message: "#entry(time) must be array or dictionary")
  
  import "@preview/transl:0.2.0": transl
  import "@preview/nexus-tools:0.1.0": get, storage
  import "@preview/datify:1.0.0": custom-date-format
  
  let cfg = storage.get("cfg", namespace: "min-resume")
  let today = datetime.today()
  let time = time
  
  strong(title) + ", "
  emph(organization + ".")
  linebreak()
  
  if type(time) == array {time = (from: time)}
  if not "to" in time {time.insert("to", today)}
  if type(time.from) == datetime {time.from = (time.from,)}
  if type(time.to) == datetime {time.to = (time.to,)}
  
  assert("from" in time, message: "#entry(time.from) required")
  assert("to" in time, message: "#entry(time.to) required")
  
  time.from = get.date(..time.from)
  time.to = get.date(..time.to)
  
  // Insert the equivalent of "Since" if the end date was less than 1 month ago.
  if (today - time.to).weeks() < 4 {transl("Since", mode: str) + " "}
  
  // Start date
  custom-date-format(time.from, pattern: cfg.entry-dates)
  
  // Insert the end date if it is more than 1 month after the start date.
  if (today - time.to).weeks() > 4 {
    " " + transl("to") + " "
    
    custom-date-format(time.to, pattern: cfg.entry-dates)
  }
  
  // Calculates the duration of the entry period.
  if cfg.entry-period {
    let weeks = (time.to - time.from).weeks()
    let years = int(weeks / 52)
    let rounded = datetime(
      year: time.from.year() + years,
      month: time.from.month(),
      day: time.from.day(),
    )
    let months = int( (time.to - rounded).weeks() / 4.343 )
    // FIXME: months calculation inaccurate by a couple of days
    //let months = ( (weeks - (years * 52)) / 4.33 )
    
    if years > 0 or months > 0 {
      " ("
      
      if years > 0 {
        let key = "year" + if years > 1 {"s"}
        
        str(years) + " "
        transl(key)
        
        if months > 0 {" " + transl("and") + " "}
      }
      if months > 0 {
        let key = "month" + if months > 1 {"s"}
        
        str(months) + " "
        transl(key)
      }
      
      ")"
    }
  }
  "."
  
  if location != none {" " + location + "."}
  linebreak()
  
  if skills != none {text(size: 1em - 1pt, list(skills))}
  
  parbreak()
}


/**
== Linkedin QR Code
:linkedin:

user <- string
  _www.linkedin.com/in/#underline[user]_\ Linkedin username.
**/
#let linkedin(user) = {
  import "@preview/tiaoma:0.3.0": qrcode
  
  set align(center)
  
  let url = "https://www.linkedin.com/in/" + user
  let img = {
    qrcode(
      url,
      options: (
        scale: 1.3,
        option-1: 3
      )
    )
    
    place(
      center + horizon,
      block(
        height: 0.7cm,
        width: 0.7cm,
        image("assets/linkedin.png")  
      )
    )
  }
  
  block(
    link(url, img),
    width: 100%,
    above: 1fr,
    below: 1fr
  )
}