#import "config.typ": margin-presets

// Turn one person or a list of people into a list.
// `option` is the argument name that errors show.
#let people(value, option) = {
  let list = if type(value) == dictionary { (value,) } else { value }
  let example = option + ": ((name: \"Nama\", id: \"1001\"),)"
  assert(
    type(list) == array,
    message: "jilid: `"
      + option
      + "` must be a list of people, e.g. `"
      + example
      + "`.",
  )
  for p in list {
    assert(
      type(p) == dictionary and "name" in p,
      message: "jilid: each entry of `"
        + option
        + "` must be `(name: .., id: ..)`, e.g. `"
        + example
        + "`. Got "
        + repr(p)
        + ".",
    )
  }
  list
}

#let content-arg(value, option, example) = assert(
  value == none or type(value) == content,
  message: "jilid: `"
    + option
    + "` must be content, e.g. `"
    + example
    + "`, not a path string.",
)

// Check the arguments outside the option groups.
// `config.rules` checks the option groups.
#let check-args(
  logo: none,
  bibliography: none,
  cover-details: (),
  margin: none,
) = {
  content-arg(logo, "logo", "logo: image(\"logo.png\")")
  content-arg(
    bibliography,
    "bibliography",
    "bibliography: bibliography(\"refs.bib\")",
  )
  for row in cover-details {
    assert(
      type(row) == array and row.len() == 2,
      message: "jilid: each `cover-details` entry must be a (label, value) pair, e.g. `(([Mitra Kolaborator], [Nama Mitra]),)`. Note the trailing comma for a single entry.",
    )
  }
  assert(
    type(margin) != str or margin in margin-presets,
    message: "jilid: `margin` must be \"print\", \"digital\" or a `page.margin` value such as `2.5cm` or `(x: 2cm, y: 3cm)`.",
  )
}
