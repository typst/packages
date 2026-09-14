#import "./fonts.typ": thesis_font_size, thesis_font
#import "./twoside.typ": *
#let part = figure.with(
  kind: "part",
  // same as heading
  numbering: "第一部分",
  // this cannot use auto to translate this automatically as headings can, auto also means something different for figures
  supplement: "Part",
  // empty caption required to be included in outline
  caption: []
)

#let part-refs = state("part-refs", ())

#let show-part-ref(s) = {
  show ref: it => {
    if it.element != none {
      // Citing a document element like a figure, not a bib key
      // So don't update refs
      it
      return
    }
    part-refs.update(old => {
      if it.target not in old {
        old.push(it.target)
      }
      old
    })

    //I think the following is how the reference index should be obtained correctly.

    let get_ref_id(loc) = {
      //str(part-refs.at(loc).len())
      str(part-refs.at(loc).position(x => (x == it.target)) + 1)
    }


    context {
      "[" + get_ref_id(here()) + "]"
    }
  }
  s
}

#let new-part-ref() = {
  part-ref.update()
}

#let show-part(s) = {
  show: show-part-ref

  // emulate element function by creating show rule
  show figure.where(kind: "part"): it => {
    twoside-pagebreak
    counter(heading).update(0)
    if it.numbering != none {
      [
        #v(0.1fr)
        #set align(center)
        #set text(font: thesis_font.times, size: 48pt)
        #strong(it.counter.display(it.numbering))<mzt:no-header-footer>

        #set text(font: thesis_font.times, size: thesis_font_size.lllarge)
        #strong(it.body)
        #v(0.2fr)
      ]
    }

    twoside-emptypage
    counter(page).update(0)

  }
  s
}

#let show-outline-with-part(s) = {

  show outline.entry: it => {
    if it.element.func() == figure {
      // we're configuring chapter printing here, effectively recreating the default show impl with slight tweaks
      let res = link(it.element.location(),
      // we must recreate part of the show rule from above once again
      if it.element.numbering != none {
        numbering(it.element.numbering, ..it.element.counter.at(it.element.location()))
      } + [ ] + it.element.body
    )

      text(size: thesis_font_size.llarge, weight: "bold", res)
    } else {
      // we're doing indenting here
      h(1.5em * (it.level - 1)) + it
    }
  }
  s
}

#let part-bib = {
  context {
    //https://github.com/typst/typst/issues/1097

    let loc = here()
    let ref-counter = counter("part-refs")
    ref-counter.update(1)
    show regex("^\[(\d+)\]\s"): it => [
      [#ref-counter.display()]
    ]
    for target in part-refs.at(loc) {
      block(cite(target, form: "full"))
      ref-counter.step()
    }
    part-refs.update(())
  }
}

#let part-and-headings = figure.where(kind: "part", outlined: true).or(heading.where(outlined: true))
