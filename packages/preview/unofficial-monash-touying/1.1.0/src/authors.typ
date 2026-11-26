// Authors with affiliations. `config-info(author: ..)` takes content, a
// string, or an array whose items are names or `(name: .., affiliation: ..)`
// dictionaries; `affiliation` is a position in the `institution` array, or
// an array of positions.

#import "@preview/touying:0.8.0": utils

#let _prefix = "unofficial-monash-touying: "

#let _hint = (
  " Write `author: ((name: \"Ann Lee\", affiliation: 1), (name: \"Bo Chen\", "
    + "affiliation: (1, 2)))` with `institution: ([First], [Second])`."
)

/// Whether `author` uses the dictionary form.
#let has-affiliations(author) = (
  type(author) == array and author.any(item => type(item) == dictionary)
)

/// The institutions as an array, whatever form `institution` has.
#let institution-list(institution) = if institution == none { () } else if (
  type(institution) == array
) { institution } else { (institution,) }

// One author as `(name: .., marks: (..))`.
#let _entry(item, count) = {
  if type(item) != dictionary { return (name: item, marks: ()) }
  if "name" not in item {
    panic(_prefix + "an author dictionary needs a `name`." + _hint)
  }
  for key in item.keys() {
    if key not in ("name", "affiliation") {
      panic(_prefix + "an author has no key `" + key + "`; use `name` and `affiliation`." + _hint)
    }
  }
  let affiliation = item.at("affiliation", default: ())
  let marks = if type(affiliation) == array { affiliation } else { (affiliation,) }
  for mark in marks {
    if type(mark) != int or mark < 1 or mark > count {
      panic(
        _prefix + "author affiliation " + repr(mark) + " does not match an institution; `institution` has "
          + str(count) + " item(s), numbered from 1." + _hint,
      )
    }
  }
  (name: item.name, marks: marks)
}

/// The authors as an array of `(name: .., marks: (..))`.
#let author-entries(author, institution) = {
  let count = institution-list(institution).len()
  let items = if type(author) == array { author } else { (author,) }
  items.map(item => _entry(item, count))
}

/// The names alone, as strings where possible, for the footer and the PDF
/// metadata.
#let author-names(author) = {
  let items = if type(author) == array { author } else { (author,) }
  items.map(item => {
    let name = if type(item) == dictionary { item.at("name", default: "") } else { item }
    if type(name) == content { utils.markup-text(name) } else { name }
  })
}

#let _mark(numbers) = super(typographic: false, size: .62em, numbers.map(str).join(","))

/// Whether the cover numbers its institutions: only when there are several
/// and some author points at one.
#let shows-marks(entries, institutions) = (
  institutions.len() > 1 and entries.any(entry => entry.marks.len() > 0)
)

/// The author line of the cover.
#let author-line(entries, marked) = {
  let names = entries.map(entry => {
    // A box keeps a name and its number on one line.
    if marked and entry.marks.len() > 0 {
      box[#entry.name#_mark(entry.marks)]
    } else { entry.name }
  })
  names.join(", ")
}

/// The institutions of the cover, one numbered line each.
#let institution-lines(institutions) = {
  let lines = institutions.enumerate(start: 1).map(((number, institution)) => {
    [#_mark((number,))#h(.15em)#institution]
  })
  lines.join(linebreak())
}
