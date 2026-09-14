
#import "colours.typ" as colours 

#let default-fonts = ("TeX Gyre Bonum", "KingHwa_OldSong")
#let default-fontsize = 10pt

#let theme-fonts = state("theme_fonts", default-fonts)
#let theme-size = state("theme_size", default-fontsize)

#let dndred = colours.dndred
#let dndtrans = dndred.transparentize(100%)

#let conf(
  content,
  fonts: default-fonts,
  fontsize: default-fontsize
) = {

  theme-fonts.update(default-fonts)
  theme-size.update(fontsize)

  set text(
    font: fonts,
    size: fontsize
  )

  set par(spacing: 0.9em, first-line-indent: 0pt)

  set heading(outlined: false)

  show heading.where(level : 1): hd => [
    #set text(size: 1.2*fontsize, weight: "regular", fill: dndred)
    #smallcaps(hd.body)
    #line(
      start: (0pt, -fontsize),
      length: 66%,
      stroke: 1pt + gradient.linear(dndred, dndtrans)
    )
    #v(-fontsize/2)
  ]

  show heading.where(level: 2): hd => [
    #set text(weight: "regular", fill: dndred)
    #smallcaps(hd)
    #line(
      start: (0pt, -fontsize),
      length: 66%,
      stroke: 1pt + gradient.linear(dndred, dndtrans)
    )
    #v(-fontsize*0.75)
  ]
  show heading.where(level: 3) : hd => text(
    size: fontsize, weight: "bold", style: "italic",
    hd.body + [.]
  )

  content
}

/// An italic block quote for the flavour text of this item
#let flavourtext(content) = [
  #set text(style: "italic")
  #block(inset: (left: 1em), content)
]

/// If you need any small text
#let smalltext(content) = context {
  v(-theme-size.get()*0.5)
  set text(size: theme-size.get() * 0.9, style: "italic", fill: dndred)
  content
}
