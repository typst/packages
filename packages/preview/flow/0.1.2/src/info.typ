// Metadata info and the works.
// Also contains a typecheck machine for absolutely no reason
// other than being a cool sideproject and
// forcing myself to use strings instead of contents for e.g. content warnings.

#import "gfx.typ"
#import "palette.typ": *
#import "tyck.typ"

// Panics if known typo'd metadata fields are contained.
#let _check-typos(it) = {
  let typos = (
    "alias": "aliases",
    "aliase": "aliases",
    "content-warning": "cw",
    "content-warnings": "cw",
  )

  for key in it.keys() {
    if key in typos.keys() {
      panic(
        "metadata key `" + key + "` passed to template, which is a typo. "
        + "use `" + typos.at(key) + "` instead."
      )
    }
  }
}

// TODO: add function that goes through value and converts it into a schema using the functions above

#let _schema = {
  import tyck: *
  _attrs(
    aliases: _any(str, _array(str)),
    author: _any(str, _array(str)),
    cw: _any(str, _array(str)),
    tags: _any(str, _array(str)),
    translation: _dict(str, str),
    keywords: _any(
      // shorthand for bolding all listed keywords
      _array(str),
      // the explicit version which allows using any function for modification
      _dict(str, function),
      // TODO: one day, implement auto which searches through all keywords
    ),
    lang: str,
  )
}

#let _check(it) = {
  _check-typos(it)
  tyck.validate(it, _schema)
}

// Puts some well-known metadata fields into an array if they stand alone.
// Returns the modified metadata.
#let _normalize(it) = {
  let arrayize = ("aliases", "author", "cw", "tags")

  for (name, data) in it {
    if type(data) != array and name in arrayize {
      it.at(name) = (data,)
    }
  }

  it
}

#let preprocess(it) = {
  _check(it)
  _normalize(it)
}

#let queryize(it) = [
  #metadata(it) <info>
]

// Accepts a dictionary where
// the key denotes the metadata field name and
// the value its, well, actual data.
#let render(it) = {
  let field(name, data) = {
    if "cw" in lower(name) {
      par(
        leading: 1.5em,
        data
          .map(gfx.invert)
          .join(h(0.5em)),
      )
    } else if type(data) == array {
      data.join[, ]
    } else if type(data) == dictionary {
      grid.cell(
        render(data),
        stroke: (left: gamut.sample(20%)),
      )
    } else {
      [#data]
    }
  }

  grid(
    columns: 2,
    align: (right, left),
    inset: (x, y) => {
      if x == 0 {
        (right: 0.5em)
      } else {
        (left: 0.5em)
      }
    },
    row-gutter: 1em,
    ..it
    .pairs()
    .filter(((name, _)) => name not in ("keywords", "title"))
    .map(
      ((name, data)) => (fade(name), field(name, data))
    )
    .join()
  )
}

