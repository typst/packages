#import "@preview/subpar:0.2.2"

// colours of Ghent University corporate identity
#let color-primary = rgb("#1e64c8") // = rgb(30, 100, 200)
#let color-secondary = rgb("#ffd200")
#let color-tertiary = rgb("#e9f0fa")

#let default-figure-fill = state("default-figure-fill", color-tertiary)
#let default-figure-inset = state("default-figure-inset", 0.5em)

#let addchapternumber(..num) = {
  let chapters = query(heading.where(level: 1).before(here()))
  if chapters.len() == 0 {
    numbering("1", ..num)
  } else if chapters.last().numbering == none {
    numbering("1", ..num)
  } else {
    numbering(
      chapters.last().numbering.split(".").first() + ".1",
      counter(heading).get().first(),
      ..num,
    )
  }
}


#let defaultsubpargrid = subpar.grid.with(
  show-sub: it => {
    set figure.caption(position: top)
    show figure.caption: it => align(left, it)
    set block(inset: 0pt, fill: none) 
    set figure(placement: none)
    it
  },
  numbering-sub: (..num) => text(weight: "semibold", numbering("a.", num
    .pos()
    .last())),
  numbering-sub-ref: (ifig, isubfig) => {
    addchapternumber(ifig) + numbering("a", isubfig)
  },
  numbering: addchapternumber,
)


#let figureblock(breakable: false, fill: auto, inset: auto, body) = context {
  let thefill = fill
  let theinset = inset
  if thefill == auto { thefill = default-figure-fill.get() }
  if theinset == auto { theinset = if thefill == none { 0pt } else { default-figure-inset.get() } }
  show figure.caption: set block(breakable: false) if breakable
  if theinset == 0pt and thefill == none {
    show figure: set block(breakable: breakable)
    body
  } else {
    show figure: set block(breakable: breakable, fill: thefill, inset: theinset)
    show figure.caption: set block(
      fill: none,
      inset: 0pt,
    ) 
    show table: set block(fill: none, inset: 0pt)
    show grid: set block(fill: none, inset: 0pt)
    show image: set block(fill: none, inset: 0pt)
    body
  }
}

#let myfigure(
  outline-caption: auto,
  caption: none,
  outlined: true,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  ..args,
) = {
  let thefigure
  if outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => (
        v - 1
      )) 
      figure(..args, caption: outline-caption)
    } 
    thefigure = [#figure(..args, caption: caption, outlined: false) #label]
  } else if label != none {
    thefigure = [#figure(..args, caption: caption) #label]
  } else {
    thefigure = figure(..args, caption: caption)
  }
  figureblock(breakable: breakable, fill: fill, inset: inset, thefigure)
}


#let mysubpargrid(
  outline-caption: auto,
  caption: none,
  outlined: true,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  ..args,
) = context {
  let thefigure
  set figure(
    placement: none,
  ) if breakable 
  if outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => v - 1)
      defaultsubpargrid(..args, caption: outline-caption)
    } 
    thefigure = defaultsubpargrid(
      ..args,
      label: label,
      caption: caption,
      outlined: false,
    )
  } else {
    thefigure = defaultsubpargrid(..args, label: label, caption: caption)
  }
  figureblock(breakable: breakable, fill: fill, inset: inset, thefigure)
}

