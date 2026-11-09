// touying-ufac-unofficial — the information of the deck: the fields of Touying's `config-info` that the theme reads, their
// aliases in the words of a course (`subject`, `semester`, …), the flavors of presentation (`flavor`) and `#info`,
// which shows any of them anywhere in a slide.
#import "@preview/touying:0.7.4": utils, config-info, config-store
#import "utils.typ": _words, _children, _is-space, _given, _list, _logos

/// The defaults of the theme for `config-info`: no `short-title`, `short-subtitle`, date nor contact; the institution
/// and the logo are UFAC's (`auto`); exercises and examples numbered "1.N".
/// -> dictionary
#let _info-defaults = config-info(title: [], short-title: none, subtitle: [], short-subtitle: none, author: none,
  date: none, institution: auto, logo: auto, contact: none, counter-prefix: [1.])

/// The name behind `auto` in `institution`.
/// -> content
#let _ufac-name = [Universidade Federal do Acre]

/// The items of a list in running text: "A", "A e B", "A, B e C" (the "e" in the language of the deck).
///
/// #test(
///   `_join-names("en", ([A],)) == [A]`,
///   `_join-names("en", ([A], [B])).children.len() == 5`,
///   `_join-names("pt", ()) == none`,
/// )
/// -> content | none
#let _join-names(
  /// Language code. -> str
  lang,
  /// The items. -> array
  xs,
) = {
  let xs = xs.filter(_given).map(x => [#x])
  if xs.len() == 0 { none } else if xs.len() == 1 { xs.first() } else {
    xs.slice(0, -1).join([, ]) + [ #_words(lang).and ] + xs.last()
  }
}

/// The language of the deck, from the store (Portuguese for a stand-in `self` without it).
/// -> str
#let _lang-of(
  /// Touying's `self`. -> dictionary
  self,
) = self.at("store", default: (:)).at("lang", default: "pt")

/// The authors as they are shown: an author written as free content (lines broken with `\` and labels in emphasis)
/// comes as it was written; otherwise the author or the array of authors.
/// -> array
#let _author-list(
  /// Touying's `self`. -> dictionary
  self,
) = {
  let shown = self.info.at("author-display", default: none)
  if shown != none { (shown,) } else { _list(self.info.at("author", default: none)).filter(_given) }
}

/// The authors in running text ("A, B e C"), or the free content as it was written.
/// -> content | none
#let _authors(
  /// Touying's `self`. -> dictionary
  self,
) = _join-names(_lang-of(self), _author-list(self))

/// The names of the authors for the footer and the PDF, in running text: of an author written as free content, the
/// names of its first group (those who present, without the advisors).
/// -> content | none
#let _author-names(
  /// Touying's `self`. -> dictionary
  self,
) = _join-names(_lang-of(self), _list(self.info.at("author", default: none)).filter(_given))

/// The institutions, one or an array; `auto` is the Universidade Federal do Acre: `(auto, [Graduate Program])`.
/// -> array
#let _institution-list(
  /// Touying's `self`. -> dictionary
  self,
) = _list(self.info.at("institution", default: auto)).map(x => if x == auto { _ufac-name } else { x })

/// The institutions separated by a dot.
/// -> content | none
#let _institution(
  /// Touying's `self`. -> dictionary
  self,
) = { let xs = _institution-list(self).map(x => [#x]); if xs.len() > 0 { xs.join[ #sym.dot.c ] } }

/// The date: `none` shows nothing, `auto` is today, a `datetime` is written in full in the language of the deck (or in
/// Touying's `datetime-format`, when the deck gives one) and a text is shown as it is.
///
/// #test(
///   `_date((info: (date: datetime(year: 2026, month: 3, day: 9)), store: (lang: "pt"))) == "9 de março de 2026"`,
///   `_date((info: (date: datetime(year: 2026, month: 3, day: 9)), store: (lang: "en"))) == "March 9, 2026"`,
///   `_date((info: (date: [2026.1]), store: (lang: "pt"))) == [2026.1]`,
///   `_date((info: (date: none), store: (lang: "pt"))) == none`,
/// )
/// -> content | str | none
#let _date(
  /// Touying's `self`. -> dictionary
  self,
) = {
  let d = self.info.at("date", default: none)
  if d == auto { d = datetime.today() }
  if type(d) != datetime { return d }
  let f = self.at("datetime-format", default: auto)
  if f != auto { return d.display(f) }
  let w = _words(_lang-of(self))
  w.date.replace("{day}", str(d.day())).replace("{month}", w.months.at(d.month() - 1)).replace("{year}", str(d.year()))
}

/// The contact, one or an array (an e-mail, a page), separated by a dot.
/// -> content | none
#let _contact(
  /// Touying's `self`. -> dictionary
  self,
) = {
  let xs = _list(self.info.at("contact", default: none)).filter(_given).map(x => [#x])
  if xs.len() > 0 { xs.join[ #sym.dot.c ] }
}

// ---------- aliases and kinds ----------
/// The aliases of `config-info` in the words of a course, and the field of Touying behind each one: the name of the
/// course is the `title`, its code the `short-title`, the unit the `short-subtitle` (in a thesis defense, the program:
/// `course`), the topic of the unit the `subtitle`, and the semester or the year the `date`.
///
/// #test(`_aliases.subject == "title"`, `_aliases.semester == "date"`)
/// -> dictionary
#let _aliases = (
  subject: "title",
  subject-code: "short-title",
  unit: "short-subtitle",
  unit-title: "subtitle",
  course: "short-subtitle",
  semester: "date",
  year: "date",
)

/// A `config-info` with the aliases replaced by their fields (`subject: [X]` becomes `title: [X]`) and a year given as a
/// number turned into text. A date from `semester` or `year` is short, and also goes to the footer (`date-short`). Two
/// names of one field (`subject` and `title`, `semester` and `year`) are an error. Other configs are left alone.
///
/// #test(
///   `_resolve-aliases(config-info(subject: [X])).info.title == [X]`,
///   `_resolve-aliases(config-info(year: 2026)).info == (date: "2026", date-short: true)`,
/// )
/// -> any
#let _resolve-aliases(
  /// A config of Touying (or anything else). -> any
  config,
) = {
  if type(config) != dictionary or "info" not in config { return config }
  let info = config.info
  for field in _aliases.values().dedup() {
    let names = (field,) + _aliases.keys().filter(k => _aliases.at(k) == field)
    let used = names.filter(k => k in info)
    if used.len() > 1 {
      // the config of a deck of 0.2.0, where `title` was the topic and `subject` the name of the course
      let hint = if field == "title" and "subject" in used {
        ("; in a deck of 0.2.0, keep subject and rename title to unit-title and subtitle to unit")
      } else { "" }
      panic("config-info: " + used.join(" and ") + " are the same field (" + field + "); give only one of them" + hint)
    }
  }
  for (alias, field) in _aliases {
    if alias in info {
      let v = info.remove(alias)
      info.insert(field, if type(v) == int { str(v) } else { v })
      if alias in ("semester", "year") { info.insert("date-short", true) }
    }
  }
  config.info = info
  config
}

/// The flavors of presentation (`config-info(flavor:)`) and what each one recommends: the layout of the cover, the tag
/// of the cover (the `short-title`, by its key in `lang.toml`) and, for the flavors without units, numbers of exercises
/// and examples without a prefix (`counter-prefix: none`, "Exercise 1"): the prefix stands for the unit of a course.
/// A deck without a `flavor` is a `"lecture"`. The deck can always change any of them.
///
/// #test(`_flavors.lecture.layout == "line"`, `_flavors.tcc.short-title == "tcc"`,
///   `"counter-prefix" not in _flavors.lecture`, `_flavors.coursework.counter-prefix == none`)
/// -> dictionary
#let _flavors = (
  // a lecture of a course: one teacher and the date on one line; the tag is the code of the course
  lecture: (layout: "line"),
  // a paper for a course: the students and the teacher in groups, at the bottom; no unit, so no prefix
  coursework: (layout: "stack", counter-prefix: none),
  // thesis defenses: the student, the advisor and the co-advisor at the top; the tag says what the work is
  tcc: (layout: "top", short-title: "tcc", counter-prefix: none),
  dissertation: (layout: "top", short-title: "dissertation", counter-prefix: none),
  thesis: (layout: "top", short-title: "thesis", counter-prefix: none),
)

/// An author written as free content (lines broken with `\`, a line only in emphasis is a label, `_Advisor_`) is kept
/// as it was written for the cover (`author-display`), and the `author` becomes the names of its first group, until the
/// second label, as text: those who present, without the advisors. An array of authors becomes an array of texts.
/// Touying passes the author to `set document(author:)`, which only takes strings, and would cut a free content at its
/// first line break.
/// -> any
#let _fix-author(
  /// A config of Touying (or anything else). -> any
  config,
) = {
  if type(config) != dictionary or "info" not in config { return config }
  let plain(x) = if type(x) == content { utils.markup-text(x).trim() } else { x }
  let au = config.info.at("author", default: none)
  if type(au) == array { config.info.author = au.map(plain) }
  else if type(au) == content and _children(au).any(c => c.func() in (linebreak, emph)) {
    let lines = ((),)
    for c in _children(au) {
      if c.func() == linebreak { lines.push(()) } else { lines.at(-1).push(c) }
    }
    let lines = lines.map(l => l.filter(c => not _is-space(c))).filter(l => l.len() > 0)
    let is-label(l) = l.len() == 1 and l.first().func() == emph
    let names = ()
    for l in lines {
      if is-label(l) { if names.len() > 0 { break } } else { names.push(plain(l.join())) }
    }
    config.info.author-display = au
    config.info.author = names.filter(x => x != "")
  }
  config
}

/// The configs of a deck ready for Touying: the aliases replaced, the authors fixed and the recommendations of the
/// `flavor` (`"lecture"` when the deck gives none). The priority, from the highest: what the deck writes (the arguments
/// of `title-slide` and the fields of `config-info`, by Touying's name or by an alias), then the `flavor`, then the
/// theme. The tag and the prefix of the flavor go in a `config-info` before those of the deck, which replace them; the
/// layout goes in the store, where `title-slide` reads it only for `auto`.
/// -> dictionary
#let _prepare-configs(
  /// Language code of the deck. -> str
  lang,
  /// The positional configs given to the theme. -> array
  configs,
) = {
  let configs = configs.map(_resolve-aliases).map(_fix-author)
  let infos = configs.filter(c => type(c) == dictionary and "info" in c).map(c => c.info)
  // the name before the flavors; Touying would keep it as an unknown field, and the deck would be a lecture
  let old = infos.filter(i => "kind" in i).map(i => i.kind)
  // the flavors removed before 0.3.0 was published, by either name: the way to do the same, not a flavor that is gone
  let removed = (
    course: "a lecture with #title-slide(cover-layout: \"top\", author-label: [Instructors])",
    talk: "a lecture with config-info(counter-prefix: none)",
  )
  for f in old + infos.filter(i => "flavor" in i).map(i => i.flavor) {
    assert(not (type(f) == str and f in removed), message: "config-info: the flavor " + repr(f) + " was removed; use "
      + removed.at(if type(f) == str { f } else { "" }, default: ""))
  }
  assert(old.len() == 0, message: "config-info: kind is now flavor (flavor: " + repr(old.at(0, default: none)) + ")")
  // the options of the cover written in config-info, which Touying would keep as unknown fields
  assert(infos.all(i => "cover-style" not in i), message: "config-info: cover-style goes in ufac-theme(cover-style: ..)")
  assert(infos.all(i => "cover-layout" not in i), message: "config-info: cover-layout goes in title-slide(cover-layout: ..)")
  assert(infos.all(i => "author-label" not in i), message: "config-info: author-label goes in title-slide(author-label: ..)")
  let flavor = infos.filter(i => "flavor" in i).map(i => i.flavor).at(-1, default: "lecture")
  assert(flavor in _flavors, message: "config-info: unknown flavor " + repr(flavor) + "; use "
    + _flavors.keys().map(k => "\"" + k + "\"").join(", "))
  let f = _flavors.at(flavor)
  let w = _words(lang)
  let before = ()
  if "short-title" in f { before.push(config-info(short-title: w.at(f.short-title))) }
  if "counter-prefix" in f { before.push(config-info(counter-prefix: f.counter-prefix)) }
  (before: before, configs: configs, after: (config-store(cover-layout: f.layout),))
}

// ---------- #info ----------
/// The information of the deck (`info`, `store`, `colors`, `datetime-format`), saved by the `init` of the theme for
/// `#info` to read in `context` anywhere.
/// -> state
#let _deck = state("ufac-deck-info", none)

/// Every information of the deck, ready to show, in a dictionary: what `#info(i => ..)` receives. The aliases are
/// keys too (`i.subject` is `i.title`).
/// -> dictionary
#let _normalized(
  /// Touying's `self`. -> dictionary
  self,
) = {
  let i = (
    title: self.info.title,
    short-title: self.info.at("short-title", default: none),
    subtitle: self.info.subtitle,
    short-subtitle: self.info.at("short-subtitle", default: none),
    author: _authors(self),
    authors: _author-list(self),
    date: _date(self),
    institution: _institution(self),
    institutions: _institution-list(self),
    logo: _logos(self),
    contact: _contact(self),
  )
  i + _aliases.pairs().map(((a, f)) => (a, i.at(f))).to-dict()
}

/// The keys of @info.
/// -> array
#let _info-keys = ("title", "short-title", "subtitle", "short-subtitle", "author", "date", "institution", "logo",
  "contact") + _aliases.keys()

/// A field of the deck, ready to show, anywhere in a slide (inside boxes and tables too):
/// `#info("author")` gives the authors as written, or "A, B and C" for an array; `#info("date")` the date in full;
/// `#info("logo", height: 2em)` the logos. The aliases are keys too: `#info("subject")` is the `title`. With a
/// function, it receives the dictionary of all the information, with the keys above plus `authors` and `institutions`
/// (arrays): `#info(i => [#i.subject-code: #i.subject])`.
///
/// ```typ
/// The course #info("subject"), taught by #info("author").
/// ```
/// -> content
#let info(
  /// `"title"`, `"short-title"`, `"subtitle"`, `"short-subtitle"`, `"author"`, `"date"`, `"institution"`, `"logo"`,
  /// `"contact"` or an alias (`"subject"`, `"semester"`, …); or a function of the dictionary. -> str | function
  key,
  /// Only for `"logo"`: the height of the logos; `auto` is the height in the footer (0.64em). -> auto | length
  height: auto,
  /// Only for `"logo"`: white logos, as on the cover. -> bool
  white: false,
) = {
  assert(type(key) == function or key in _info-keys, message: "info: unknown key " + repr(key) + "; use "
    + _info-keys.map(k => "\"" + k + "\"").join(", ") + " or a function of the dictionary")
  // a `context` on the state and not a `touying-fn-wrapper`: Touying's mark does not go through `context` nor `layout`,
  // which the boxes and the tables use
  context {
    let self = _deck.get()
    assert(self != none, message: "info: only inside a deck of the theme")
    if type(key) == function { return key(_normalized(self)) }
    let key = _aliases.at(key, default: key)
    if key == "logo" {
      let logos = _logos(self, white: white)
      if logos == none { return none }
      let logos = if height == auto { logos } else { text(size: height / 0.64, logos) }
      // centered on the capitals of the line, as the icons: the logos come in a box with an inset, which in a line of
      // text would lift them above the baseline
      let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline")[X]).height
      return box(baseline: (measure(logos).height - cap) / 2, logos)
    }
    _normalized(self).at(key)
  }
}
