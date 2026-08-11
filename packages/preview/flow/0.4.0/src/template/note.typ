#import "common.typ": *
#import "modern.typ": modern

#let _title = title

#let _note-outline = context {
  // When using multiple notes in one document,
  // we want to only show the outline for the headings in the same note
  // notes are delimited by <info> labels (they are before any other content)
  let target = selector(heading.where(outlined: true))
    .after(here())
    .before(selector(<info>).after(here()))

  // Are there any headings? If so, no need to render an outline.
  if query(target).len() == 0 {
    return
  }

  context {
    v(-0.75em)
    outline(target: target)
    separator
  }
}

#let _prelude(body, args) = {
  let (data, title, subtitle) = _shared(args)

  _title(title)

  if subtitle != none {
    v(-1.5em)
    text(1.25em, subtitle)
  } else {
    v(-1em)
  }

  info.render(forget-keys(data, ("keywords", "title", "subtitle", "outline")))
  separator

  if data.at("outline", default: true) {
    _note-outline
  }
}

#let note(body, ..args) = {
  show: modern.with(..args)

  (_maybe-stub(_prelude))(body, args)
  body
}

