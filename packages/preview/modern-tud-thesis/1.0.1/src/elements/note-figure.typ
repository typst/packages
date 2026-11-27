#import "/src/elements/colors.typ": colors

#let note-figure(note: none, body, caption: none, ..args) = {
  std.figure( ..args, caption: {
    state("figurenote").update(note)
    caption
  },
    body 
  )
}

#let note-figure-helper(doc) = {
  show figure.caption: it => {
    set par(spacing: .75em, leading: .5em)
    it
    context state("figurenote").get()
    state("figurenote").update("")
  }
  doc
}
