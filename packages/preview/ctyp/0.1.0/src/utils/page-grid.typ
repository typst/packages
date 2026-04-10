#let page-grid(
  width: 42,
  height: 65,
  note-left: auto,
  note-right: auto,
  ..args,
  body
) = {
  let note-left = if type(note-left) == length { note-left } else if type(note-left) == int { note-left * 1em } else { 0em }
  let note-right = if type(note-right) == length { note-right } else if type(note-right) == int { note-right * 1em } else { 0em }
  set page(margin: (
    left: (100% - width * 1em) / 2 + note-left,
    right: (100% - width * 1em) / 2 + note-right,
    y: (100% - height * 1em) / 2,
    ..args.named()
  ))
  body
}