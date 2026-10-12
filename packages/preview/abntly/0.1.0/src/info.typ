// The data of the work: `config-info`, which the author gives to the main function (`info: config-info(...)`), the
// state that keeps them for the pages that print them (the cover, the title page, the approval sheet, the catalog
// card), and the people of the work. The body of a document is evaluated before the main function runs, so a page
// cannot see a `let` of it: the data go into a state at the start of the work, and each page reads it with one
// `context`. Every field has its own parameter, so the editor shows them with their documentation.

#import "words.typ": word-raw

// the data of the work, set by the main function at the start of the work; `none` without `info`
#let work = state("abntly-info", none)

// the types of work (`work-type`), the keys of their names in src/lang.toml, with their Portuguese names
#let work-types = ("tcc", "dissertation", "thesis", "master-qualification", "doctorate-qualification")
#let work-types-pt = (tcc: "tcc", dissertacao: "dissertation", tese: "thesis",
  qualificacao-mestrado: "master-qualification", qualificacao-doutorado: "doctorate-qualification")

// the keys of a person, in English or Portuguese
#let person-keys = (name: "name", nome: "name", surname: "surname", sobrenome: "surname", gender: "gender",
  genero: "gender", label: "label", rotulo: "label")

// the last names that go with the one before them into the surname (NBR 6023:2025, 8.1.1.3 b: "ASSAF NETO,
// Alexandre", "GRISARD FILHO, Waldyr")
#let kinship = ("Filho", "Filha", "Neto", "Neta", "Sobrinho", "Sobrinha", "Júnior", "Junior", "Jr.")

// A person of the work as a dictionary (name:, surname:, gender:, label:): from a string or content, the whole name
// in `name`; from a dictionary, its keys in English or Portuguese, the given name in `name` and the surname apart.
#let person(value, field) = {
  if value == none { return none }
  if type(value) in (str, content) { return (name: value, surname: none, gender: "m", label: none) }
  assert(type(value) == dictionary, message: "config-info: " + field + " is a name, as a string or content, or a "
    + "dictionary (name: \"Lucas Lima\", surname: \"Rodrigues\"); got " + repr(value))
  let out = (name: none, surname: none, gender: "m", label: none)
  for (key, v) in value {
    assert(key in person-keys, message: "config-info: " + field + " takes the keys name, surname, gender and label "
      + "(nome, sobrenome, genero, rotulo); got " + repr(key))
    out.insert(person-keys.at(key), v)
  }
  assert(out.name != none, message: "config-info: " + field + " has no name: " + repr(value))
  assert(out.gender in ("m", "f"), message: "config-info: the gender of " + field + " is \"m\" or \"f\"; got "
    + repr(out.gender))
  out
}

// the name of a person in direct order, "Lucas Lima Rodrigues"
#let full-name(p) = if p.surname == none { p.name } else [#p.name #p.surname]

// The name of a person by the surname, "Rodrigues, Lucas Lima" (NBR 6023:2025, 8.1.1), from its two parts (the
// surname, the rest; `none` for content, which cannot be split, and for a single word): the surname apart when the
// author gave it; otherwise the last word of a string, with the one before it when it is a degree of kinship
// ("Assaf Neto"), and the rest after the comma, the particle too ("Nome do Autor" → "Autor, Nome do", as
// "ESPÍRITO SANTO, Miguel Frederico de", 8.1.1.3 c). Content cannot be split: it stays as it is.
#let name-parts(p) = {
  if p.surname != none { return (p.surname, p.name) }
  if type(p.name) != str { return none }
  let words = p.name.split(" ").filter(w => w != "")
  if words.len() < 2 { return none }
  let cut = if words.len() > 2 and words.last() in kinship { words.len() - 2 } else { words.len() - 1 }
  (words.slice(cut).join(" "), words.slice(0, cut).join(" "))
}
#let inverted-name(p) = {
  let parts = name-parts(p)
  if parts == none { p.name } else if p.surname != none [#parts.first(), #parts.last()] else {
    parts.join(", ")
  }
}

// The name of a person as the entry of a reference gives it, "RODRIGUES, Lucas Lima" (NBR 6023:2025, 8.1.1: "pelo
// último sobrenome, em letras maiúsculas, seguido do prenome"): the surname of `inverted-name` in capitals.
#let reference-name(p) = {
  let parts = name-parts(p)
  if parts == none { p.name } else [#upper(parts.first()), #parts.last()]
}

// The label of an advisor, "Orientador", "Orientadora" (gender "f") or the author's own, inside a context.
#let role-label(p, key) = if p.label != none { p.label } else if p.gender == "f" {
  word-raw(key + "-female")
} else { word-raw(key) }

/// Defines the data of the work, for the `info` parameter of `abntly`. These data are used on the cover, the title
/// page, the approval sheet and the catalog card. Fields that are not given are left out of those pages; the title
/// and the author are required by them.
///
/// - title (str, content): Title of the work.
/// - subtitle (str, content, none): Subtitle. It is printed after the title, separated by a colon.
/// - author (str, content, dictionary): Author. It can be the full name or a dictionary with the given name and the
///   surname apart, as in `(name: "Lucas Lima", surname: "Rodrigues")`. The surname is used on the catalog card
///   ("Rodrigues, Lucas Lima"). When the author is given as text, the last word is taken as the surname.
/// - advisor (str, content, dictionary, none): Advisor, in the same format as the author, with the academic title in
///   the name ("Prof. Dr. Nome do Orientador"). In the dictionary, `gender: "f"` gives the label "Orientadora" and
///   `label` sets a custom label.
/// - co-advisor (str, content, dictionary, none): Co-advisor, in the same format as the advisor.
/// - institution (str, content, none): Name of the institution.
/// - program (str, content, none): Course, graduate programme or department.
/// - area (str, content, none): Area of concentration. It is printed under the nature of the work.
/// - year (auto, int, str, content): Year of deposit. With `auto`, the current year.
/// - location (str, content, none): Location (city) of the institution.
/// - version (str, content, none): Version of the work, as in "Versão corrigida". It is printed under the title.
/// - volume (int, str, content, none): Number of the volume, printed beside the year ("2026, v. 2"). Use it when the
///   work has more than one volume.
/// - work-type (str, content, none): Type of the work, used on the catalog card: `"tcc"`, `"dissertation"`,
///   `"thesis"`, `"master-qualification"` or `"doctorate-qualification"`. For another type, give the text as content.
/// - logo (content, none): Mark (logo) of the institution, shown at the top of the cover. Example:
///   `image("logo.svg", width: 2cm)`.
/// -> dictionary
#let config-info(title: none, subtitle: none, author: none, advisor: none, co-advisor: none, institution: none,
  program: none, area: none, year: auto, location: none, version: none, volume: none, work-type: none, logo: none,
  ..args) = {
  assert(args.pos().len() == 0, message: "config-info: takes only named fields; got " + repr(args.pos()))
  if args.named().len() > 0 {
    panic("config-info: unknown field " + repr(args.named().keys().first()) + "; the fields are title, subtitle, "
      + "author, advisor, co-advisor, institution, program, area, year, location, version, volume, work-type, logo")
  }
  for (name, value) in (title: title, subtitle: subtitle, institution: institution, program: program, area: area,
    location: location, version: version) {
    assert(value == none or type(value) in (str, content),
      message: "config-info: " + name + " is a string or content; got " + repr(value))
  }
  assert(year == auto or type(year) in (int, str, content),
    message: "config-info: year is a number, a string or content, or auto (the current year); got " + repr(year))
  assert(volume == none or type(volume) in (int, str, content),
    message: "config-info: volume is a number, a string or content; got " + repr(volume))
  assert(logo == none or type(logo) == content, message: "config-info: logo is content, such as image(\"logo.svg\""
    + ", width: 2cm); got " + repr(logo))
  let kind = if type(work-type) == str { work-types-pt.at(work-type, default: work-type) } else { work-type }
  assert(kind == none or type(kind) == content or kind in work-types,
    message: "config-info: work-type is one of " + work-types.join(", ") + " (or " + work-types-pt.keys().join(", ")
      + "), or content; got " + repr(work-type))
  (
    title: title,
    subtitle: subtitle,
    author: person(author, "author"),
    advisor: person(advisor, "advisor"),
    co-advisor: person(co-advisor, "co-advisor"),
    institution: institution,
    program: program,
    area: area,
    year: if year == auto { datetime.today().year() } else { year },
    location: location,
    version: version,
    volume: volume,
    work-type: kind,
    logo: logo,
  )
}

// The data again through `config-info`, for the main function: the result of `config-info` comes back the same (its
// people are already dictionaries, which `person` takes as they are), and a plain dictionary is checked as one. An
// empty one, the default, is a work without data; `none` is refused.
#let resolve(given) = {
  assert(type(given) == dictionary, message: "abntly: info comes from config-info(...), or is left out (its "
    + "default is the empty dictionary); got " + repr(given))
  if given == (:) { return none }
  config-info(..given)
}

// the title with its subtitle, "Título: subtítulo" (NBR 14724, 4.1.1 d)
#let full-title(data) = if data.subtitle == none { data.title } else [#data.title: #data.subtitle]

// the year with the volume beside it, "2026, v. 2"
#let year-volume(data) = if data.volume == none { [#data.year] } else if type(data.volume) == int {
  [#data.year, v. #data.volume]
} else [#data.year, #data.volume]

// the data, inside a context, with the fields a page needs: a panic names the missing ones
#let get(page, ..needed) = {
  let data = work.get()
  assert(data != none, message: page + ": the data of the work are missing: `#show: abntly.with(info: config-info("
    + "title: [...], author: \"...\"))`")
  for key in needed.pos() {
    assert(data.at(key) != none, message: page + ": config-info has no " + key)
  }
  data
}

// the keywords of each abstract, by the language of its text, which `keywords` writes and the catalog card reads (its
// subjects, the keywords in the language of the work)
#let keywords = state("abntly-keywords", (:))

// the keywords of the language `lang` at the end of the work, inside a context
#let keywords-of(lang) = keywords.final().at(lang, default: ())

// Content as plain text, for the fields of the PDF that take only text (the author, the keywords): its text, its
// spaces and line breaks, its quotes, its bold and italics; `none` for what does not reduce to text (a box, a math
// formula).
#let plain(c) = {
  if type(c) == str { return c }
  if type(c) != content { return none }
  if c.has("text") { return c.text }
  if c.func() in ([ ].func(), linebreak) { return " " }
  if c.func() == smartquote { return if c.double { "\"" } else { "'" } }
  if c.has("children") {
    let parts = c.children.map(plain)
    return if none in parts { none } else { parts.join(default: "") }
  }
  if c.has("child") { return plain(c.child) }
  if c.func() in (strong, emph) { return plain(c.body) }
  none
}

// The metadata of the PDF the data give, as `set document` takes them: the title with the subtitle ("Título:
// subtítulo"); the author, when the name is text; the subject, the nature of the work the title page gives; the
// keywords of every abstract, those of the language of the work first, then the institution and the programme, as
// text and once each. A field without information is left out, not written empty.
#let metadata-of(data, nature, by-lang, lang) = {
  let out = (:)
  if data == none { return out }
  if data.title != none { out.title = full-title(data) }
  let a = data.author
  let name = if a == none { none } else if a.surname == none { plain(a.name) } else {
    let given = plain(a.name)
    let surname = plain(a.surname)
    if given != none and surname != none { given + " " + surname }
  }
  if name != none { out.author = name }
  if nature != none { out.description = nature }
  let words = by-lang.at(lang, default: ()) + by-lang.keys().filter(k => k != lang).map(k => by-lang.at(k)).flatten()
  let words = (words + (data.institution, data.program)).map(plain).filter(k => k != none)
    .map(k => k.replace(regex("\s+"), " ").trim()).filter(k => k != "").dedup()
  if words.len() > 0 { out.keywords = words }
  out
}
