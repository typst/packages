// The building blocks for a CV written in markup inside the `altacv`
// template (#370): what Typst has no element for, over the components
// `alta()` draws with. Re-exported from `lib.typ`.

#import "data/defaults.typ": _default-preferences
#import "data/cv.typ": (
  _authors, _date-sides, _identifier-refs, _identifier-url, _identifiers,
  _owner-keys, _skill-levels, _term-rating,
)
#import "design/icon-set.typ": _icon-glyphs, _network-icons
#import "icons.typ": _check-icon
#import "data/validation.typ": _check-preference
#import "util/checks.typ": (
  _check, _check-keys, _check-rating, _check-type, _dict-rule, _enum-rule,
  _list-rule, _positive-int-rule, _quote, _type-rule,
)
#import "context.typ": _labels, _max-rating-state
#import "primitives.typ": _divider, _photo
#import "components/bibliography.typ": _bib-entry
#import "components/columns.typ": _columns
#import "components/entry.typ": _entry
#import "components/header.typ": _page-header
#import "components/keywords.typ": _keyword-rows, _label-rows
#import "components/ratings.typ": _rating-mark

// A block's optional body, from its `..body` sink (Typst has no
// optional positional parameter): the one positional argument, or
// `none`. A named argument there is a misspelt parameter, which
// Typst would reject were there no sink.
#let _body(fn, args) = {
  let named = args.named().keys()
  if named.len() > 0 {
    panic(fn + ": unexpected argument(s) " + named.map(_quote).join(", "))
  }
  let pos = args.pos()
  if pos.len() > 1 {
    panic(fn + " takes one body, got " + str(pos.len()))
  }
  pos.at(0, default: none)
}

// Where an entry sits: `parent`, the most recent section or group
// heading before here (entries' own headings don't count), and
// `sibling`, whether an entry precedes it under that heading, by the
// mark `_entry` leaves on each, titled or not: `alta()`'s too, so one
// after `#alta(cv)` continues its last section. One query, walked back
// from here to the parent.
#let _entry-place() = {
  let sibling = false
  for found in query(
    selector(heading).or(<alta-internal-entry-mark>).before(here()),
  ).rev() {
    if found.func() != heading {
      sibling = true
    } else if found.at("label", default: none) != <alta-internal-entry> {
      return (parent: found, sibling: sibling)
    }
  }
  (parent: none, sibling: false)
}

/// An entry: a role, a qualification, a project. Its facts are named
/// arguments; its prose (a list of highlights) is the body.
/// Its heading sits one level below the section or group before it, and
/// the theme's divider separates it from the entry before it in the
/// same section or group. It needs a section (`=`) or group (`==`)
/// heading before it; one right after `#alta(cv)` continues that CV's
/// last section, so start your own with `= ...`.
/// An entry doesn't break across pages: it moves to the next whole,
/// and one taller than a page overflows it, so split long prose over
/// several entries.
///
/// - title (content, str, none): The role or qualification.
/// - url (str, none): A link for the title.
/// - org (content, str, none): The organisation, in the accent.
/// - org-url (str, none): A link for the organisation.
/// - subtitle (array): A small line under the heading (a referee's
///   attribution): groups of facts, an array of arrays, the facts in a
///   group joined by the theme's item separator and the groups by its
///   fact separator: `(("Manager", "Acme"), ("2024",))`.
/// - roles (array): Further roles, after the organisation.
/// - date (content, str, array, none): At the right edge. Content or
///   a string shows as written; a `(start, end)` pair as a period: the
///   two joined by the theme's range separator, a `none` end reading
///   the labels' "Present" (`altacv.with(labels: ..)`'s, over the
///   document language's), a `none` start leaving the end alone;
///   `(none, none)` shows nothing.
/// - location (content, str, array, none): Under the date. An array of
///   parts (a city, a region, a country code) is joined by the theme's
///   item separator.
/// - details (array): Short facts after the roles (a credential ID).
/// - summary (content, str, none): A short summary, set apart before
///   the body in the theme's `preamble` treatment (italic by
///   default).
/// - keywords-lead (array): A line of its own above the keywords
///   (education's area and score), so it doesn't read as one of them:
///   groups of facts, as `subtitle` takes.
/// - keywords (array): A line of keywords ending the entry.
/// - body (content): The highlights, or any other prose; optional.
/// -> content
#let entry(
  title: none,
  url: none,
  org: none,
  org-url: none,
  subtitle: (),
  roles: (),
  date: none,
  location: none,
  details: (),
  summary: none,
  keywords-lead: (),
  keywords: (),
  ..body,
) = {
  let body = _body("entry()", body)
  context {
    if type(date) == array and date.len() != 2 {
      panic(
        "entry() date takes one date or a `(start, end)` pair, got "
          + str(date.len())
          + " dates",
      )
    }
    let (parent, sibling) = _entry-place()
    if parent == none {
      panic(
        "entry() needs a section heading (`= Experience`) or a group heading (`== Talks`) before it",
      )
    }
    // The template styles an entry's heading at level 2 or 3 only.
    if parent.level >= 3 {
      panic(
        "entry() sits under `=` sections and `==` groups; a `===` heading isn't styled as either",
      )
    }
    // `alta()` joins a section's entries with the divider, so none
    // precedes the first of a section or group. The divider sits in the
    // entry's unbreakable block, so an entry pushed to the next page
    // takes it along rather than leaving a rule at the page's foot.
    // At a page top the divider keeps its space, the rule hidden, where
    // `alta()`'s drops both: dropping it moved what follows, which moved
    // the next divider, and a CV of a few pages ran out of Typst's five
    // layout passes. Hidden, it moves nothing.
    let labels = _labels()
    // Full width, so justified prose stretches to the column, not to
    // the entry's widest line.
    block(width: 100%, breakable: false, {
      if sibling { _divider(true, at-top: hide) }
      _entry(
        // The icons' alt text, in the document's language under the
        // template's labels.
        labels,
        title: title,
        url: url,
        org: org,
        org-url: org-url,
        subtitle: subtitle,
        roles: roles,
        // A pair as `alta()` reads a period, its open end the language's
        // "Present"; else one side, as written: `_range` joins only the
        // present sides.
        period: if type(date) == array {
          let (start, end) = date
          _date-sides(start, end, d => d, labels.present)
        } else { (date,) },
        location: if type(location) == array { location } else { (location,) },
        details: details,
        summary: summary,
        body: body,
        keywords-lead: keywords-lead,
        keywords: keywords,
        level: parent.level + 1,
      )
    })
  }
}

// Content's text, for alt text, which takes a string: `document.title`
// is content, `[Jane Doe]` set from a string. One case per kind of
// element, the first that matches returning.
#let _plain(it) = {
  if type(it) == str { return it }
  if it.has("text") { return _plain(it.text) }
  if it.has("children") { return it.children.map(_plain).join(default: "") }
  if it.has("body") { return _plain(it.body) }
  if it.func() == smartquote { return if it.double { "\"" } else { "'" } }
  if it.func() in ([ ].func(), linebreak) { return " " }
  // A gap (`h(0.3em)`, `h(1fr)`) reads as a space; a negative kern,
  // pulling its neighbours together, as nothing.
  if it.func() == h {
    let a = it.amount
    let gap = if type(a) == fraction { a > 0fr } else {
      let r = 0% + 0pt + a
      r.ratio > 0% or r.length.abs > 0pt or r.length.em > 0
    }
    return if gap { " " } else { "" }
  }
  ""
}

// An `auto` contact alt, as `alta()`'s contacts read: a profile its
// network, a location the localised word, and email, phone and a
// homepage (`link`) nothing, their text saying what they are.
#let _contact-alt(icon, labels) = if icon == "location" {
  labels.location
} else if icon in _network-icons and icon != "link" { icon }

/// One contact-bar entry for `cv-header`: an icon, its text, and an
/// optional link.
///
/// - icon (str): A key of the icon set (`icon()`'s names: `"email"`,
///   `"phone"`, `"github"`, …).
/// - value (content, str): The text shown.
/// - url (str, none): Where it links (`mailto:…`, a URL).
/// - alt (str, none, auto): Read aloud before it. `auto` reads a
///   profile network's icon (`"github"`) as its name, `"location"` as
///   the localised word for it, and nothing for the rest (`"email"`,
///   `"phone"`, `"link"`), whose text says what it is.
/// -> dictionary
#let contact(icon, value, url: none, alt: auto) = {
  // `icon()`'s check, so an unknown name panics the same way.
  _check-icon("contact() icon", icon)
  // `_contact-bar`'s record; `icon` resolves an `auto` alt in context
  // (`cv-header`, `_contact-alt`), where the document's language is
  // known.
  (icon: icon, glyph: _icon-glyphs.at(icon), value: value, url: url, alt: alt)
}

/// The CV's header: your name (rendered with Typst's `title`
/// element), a tagline, an objective, the contact bar, and an optional
/// photo and QR code. Its text follows the surrounding alignment:
/// `#align(center, cv-header(..))` centres it.
///
/// - name (auto, content, str): Your name. `auto` is the document's
///   title (`#set document(title: ..)`).
/// - tagline (content, str, none): Under the name.
/// - objective (content, str, none): A short goal, under the tagline.
/// - contacts (array): `contact(..)` entries, wrapping as one row of
///   the contact bar. A `linebreak()` among them starts a new row
///   (`adapter.basics-contacts` puts one before the profiles).
/// - photo (content, none): The photo: content, typically an
///   `image(..)`, loaded in your file, so its path is yours.
/// - photo-position (alignment): `left`, `right`, `top` or `bottom`.
/// - photo-size (auto, length, ratio, relative): The photo's side.
///   `auto` is the `photo-size` preference's default, `6em`.
/// - photo-shape (auto, str): The photo's frame: `"circle"`,
///   `"rounded"` or `"square"`. `auto` is `"circle"`.
/// - qr (str, none): A URL to encode as a QR code, opposite the photo.
/// - uppercase (bool): Set the name in capitals.
/// -> content
#let cv-header(
  name: auto,
  tagline: none,
  objective: none,
  contacts: (),
  photo: none,
  photo-position: right,
  photo-size: auto,
  photo-shape: auto,
  qr: none,
  uppercase: true,
) = {
  _check-type(
    "cv-header() name",
    name,
    (content, str, type(auto)),
    "content, a string or auto",
  )
  _check("cv-header() photo-position", photo-position, _enum-rule((
    left,
    right,
    top,
    bottom,
  )))
  _check-type(
    "cv-header() photo",
    photo,
    (content, type(none)),
    "content or none",
  )
  // The photo's `key` (`size`, `shape`): `auto` reads `alta()`'s
  // default `image-{key}`, anything else is checked as that preference.
  let photo-option(key, value) = if value == auto {
    _default-preferences.at("photo-" + key)
  } else {
    _check-preference(
      "photo-" + key,
      value,
      name: "cv-header() photo-" + key,
    )
    value
  }
  let photo-size = photo-option("size", photo-size)
  let photo-shape = photo-option("shape", photo-shape)
  context {
    let name = if name != auto { name } else { document.title }
    if name == none {
      panic(
        "cv-header() shows the document's title as your name: `#set document(title: \"Jane Doe\")` first, or pass `name:`",
      )
    }
    let labels = _labels()
    _page-header(
      name: name,
      tagline: tagline,
      objective: objective,
      // A row per run between `linebreak()`s, each wrapping between
      // entries as `alta()`'s rows do; an empty run, none.
      contacts: contacts
        .split(linebreak())
        .filter(row => row != ())
        .map(row => row.map(c => (
          c
            + (
              alt: if c.alt == auto { _contact-alt(c.icon, labels) } else {
                c.alt
              },
            )
        ))),
      // The surrounding alignment's horizontal part: `start`, unless
      // an `align` around the header says otherwise.
      text-align: align.alignment.x,
      uppercase: uppercase,
      // Framed as `alta()` frames `basics.image`; `alt` is the
      // person's name.
      photo: if photo != none {
        _photo(photo, photo-size, _plain(name), shape: photo-shape)
      },
      photo-position: photo-position,
      qr-url: qr,
      title: true,
    )
  }
}

/// A publication, as a bibliography item: the title (linked), the
/// authors (yours set apart: the document's author), the source and
/// date, and persistent identifiers. Consecutive publications stack
/// closely, so a group of them reads as one list.
///
/// - title (content, str): The title; required.
/// - url (str, none): Its link; with none, the first linkable
///   identifier's (DOI, then arXiv, then PMID).
/// - authors (array): Author names (strings or content, shown as
///   their text), in order. The one matching an owner, ignoring case
///   and surrounding spaces, is set apart.
/// - owners (auto, array): The names to set apart among the authors,
///   in the theme's `owner` treatment (bold by default). `auto` is
///   the document's author (`#set document(author: ..)`).
/// - source (content, str, none): The publisher or venue.
/// - citation (dictionary): Where in the source: `volume`, `issue`
///   and `pages`, each an optional string (`none` leaves it out), set
///   after the source in the theme's `citation` style, `12(3), 45–60`.
/// - date (content, str, none): When, as written.
/// - identifiers (dictionary): ID strings by scheme (`doi`, `arxiv`,
///   `pmid` link; others, `isbn` say, show unlinked).
/// - body (content): A summary; optional.
/// -> content
#let publication(
  title: none,
  url: none,
  authors: (),
  owners: auto,
  source: none,
  citation: (:),
  date: none,
  identifiers: (:),
  ..body,
) = {
  let body = _body("publication()", body)
  // Required, as a publication can't render without one; named, as
  // `entry`'s is, so it has a default Typst won't enforce. A title
  // passed positionally lands in the body.
  if title == none and body != none {
    panic(
      "publication() takes its title as `title:`; the positional argument is the summary body",
    )
  }
  _check(
    "publication() title",
    title,
    _type-rule((str, content), "a string or content"),
  )
  // `alta()`'s readers are lenient, dropping what they can't read;
  // arguments written by hand panic instead.
  _check(
    "publication() authors",
    authors,
    _list-rule((str, content), "an array of strings or content"),
  )
  _check(
    "publication() identifiers",
    identifiers,
    _dict-rule((str,), "a dictionary of strings"),
  )
  _check-keys("publication() citation", citation, ("volume", "issue", "pages"))
  _check(
    "publication() citation",
    citation,
    _dict-rule((str, type(none)), "a dictionary of strings"),
  )
  if owners != auto {
    _check(
      "publication() owners",
      owners,
      _list-rule((str,), "auto or an array of strings"),
    )
  }
  context {
    // `alta()`'s readers, over the arguments in its CV shape; an
    // author given as content is matched and shown as its text.
    let refs = _identifier-refs(_identifiers(identifiers))
    // `document.author` is an array of strings: Typst wraps an author
    // set as a string, and leaves it empty when unset.
    let owners = _owner-keys(
      if owners == auto { document.author } else { owners },
    )
    // One unbreakable block per item, as `alta()` lays them out.
    // Full width, as `entry`'s, so a justified summary stretches.
    block(width: 100%, breakable: false, _bib-entry(
      title,
      url: if url != none { url } else { _identifier-url(refs) },
      authors: _authors(authors.map(_plain), owners),
      publisher: source,
      citation: citation,
      date: date,
      identifiers: refs,
      summary: if body not in (none, []) { body },
    ))
  }
}

/// A skill group's row: its name as a category tag, then its keywords as
/// tags, with an optional level: a number or a term such as "Expert"
/// shows as dots, any other text as written.
///
/// - name (content, str, none): The group's name; `none` leaves out
///   the category tag.
/// - keywords (array): Its keywords, each a tag.
/// - level (int, float, str, content, none): Its level, after the name:
///   a number as that many dots, from 0 to `max` in steps of 0.5; a
///   rating term (`"Beginner"`, `"Intermediate"`, `"Advanced"`,
///   `"Expert"`, …) as its share of `max` dots; anything else as
///   written.
/// - max (auto, int): The dots in the row; `auto` is `rating()`'s: the
///   `max-rating` of the last `alta()` before it, else 5.
/// -> content
#let skill-row(name, keywords, level: none, max: auto) = {
  let row(max) = {
    _check("skill-row() max", max, _positive-int-rule)
    let numeric = type(level) in (int, float)
    if numeric { _check-rating("skill-row() level", level, max) }
    _keyword-rows((
      (
        name: name,
        keywords: keywords,
        mark: _rating-mark(
          if numeric { level } else {
            _term-rating(level, _skill-levels, max)
          },
          max,
          fallback: level,
        ),
      ),
    ))
  }
  if max == auto { context row(_max-rating-state.get()) } else { row(max) }
}

/// The CV's columns: `left` beside `right`, the left taking `ratio` of
/// the width the theme's column gutter leaves. A plain `grid` works
/// too.
///
/// - left (content, str, none): The left column.
/// - right (content, str, none): The right column; `none` puts `left`
///   alone, full width.
/// - ratio (int, float): The left column's share, in (0, 1]; 1 stacks
///   both in one column, `left` first.
/// -> content
#let cv-columns(
  left,
  right,
  ratio: _default-preferences.column-ratio,
) = {
  for (name, column) in (left: left, right: right) {
    _check-type(
      "cv-columns() " + name,
      column,
      (content, str, type(none)),
      "content, a string or none",
    )
  }
  _check-preference("column-ratio", ratio, name: "cv-columns() ratio")
  // Stacked, each column its own paragraph, so two runs of text don't
  // run together.
  if ratio == 1 or right == none {
    (left, right).filter(c => c != none).join(parbreak())
  } else { _columns((left,), (right,), ratio) }
}

/// A labelled line: "Music: Trad, Jazz". The label in the theme's
/// `label` treatment (bold by default), then the theme's label
/// separator and the items.
///
/// - label (content, str, none): The label, in the emphasis colour;
///   `none` leaves the items alone.
/// - items (array): The items, joined by the theme's item
///   separator.
/// -> content
#let label-row(label, items) = context block(
  // Rows stack a line apart, as `alta()`'s rows of one paragraph do.
  spacing: par.leading,
  _label-rows(((name: label, keywords: items),)),
)
