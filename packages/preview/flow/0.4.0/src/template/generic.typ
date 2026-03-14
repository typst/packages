#import "common.typ": *

/// The args sink is used as metadata.
/// It'll exposed both in a table in the document and via `typst query`.
/// See the manual for details.
#let generic(body, ..args) = {
  let (data, title) = _shared(args)

  show: _styling.with(..data)
  show: keywords.process.with(cfg: data.at(
    "keywords",
    default: none,
  ))
  show: maybe-do(
    data.at("xlink", default: true),
    xlink.process,
  )
  show: maybe-do(
    data.at("checkbox", default: true),
    checkbox.process,
  )

  set document(
    title: title,
    author: data.at("author", default: ()),
  )

  info.queryize(data)
  body
}

