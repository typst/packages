// Interlinks between notes.
// Not intended to be used for yields.

#import "palette.typ": *
#import "hacks.typ"

// TODO: actually implement link. probably gotta be some URL scheme handler magic
// don't forget to write docs
/// Link to another note.
#let xlink(target, display: auto) = {
  display = if display == auto {
    target
  }

  show: text.with(fill: reference.other-file)
  show: underline

  display
}

#let process(body, ..args) = {
  show: hacks.only-main(
    regex("\[..+?\]"),
    it => {
      let it = it.text.slice(1, -1)
      xlink(it)
    }
  )

  body
}

