// Helios, a minimal theme for academic presentations with Polylux
// Copyright (C) 2026 Daniel Schoenig
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This code is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public
// License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.


// This theme is inspired by the `metropolis-polylux` theme
// (https://github.com/polylux-typ/metropolis) and the Metropolis theme
// for Beamer (https://github.com/matze/mtheme). Code for the `outline`
// and `focus` functions was taken from the `metropolis-polylux` theme.


#import "@preview/polylux:0.4.0": *


#let it(body) = { 
  text(style: "italic", body)
}

#let col-acc = state("col-acc", rgb("#D45E00"))

#let hypothesis(title, content, accent: none, fill: luma(245)) = context {
  let hyp-acc = if accent == none {col-acc.get()} else {accent}
  block(
    inset: (left: 1em, right: 1em, rest: 0.75em), 
    stroke: (left: 0.2em + hyp-acc),
    width: 100%,
    fill: fill
    )[
      #text(size: 1.1em, strong(title))

      #content
  ]
}


#let outline = toolbox.all-sections((sections, _current) => {
  enum(tight: false, ..sections)
})


#let slide-title-header = toolbox.next-heading(h => {
  set align(top)
  set text(size: 1.5em, weight: "bold", stretch: 50%)
  v(1.5em)
  h
})


#let make-footer(section: true, number: true) = context {
  set text(size: 0.75em, fill: text.fill, number-type: "lining")
  show: pad.with(top: 0.5em, bottom: 1em)
  set align(bottom)
  if section == true {
    toolbox.current-section
  } else if section != none and section != false {
    section
  }
  if number == true {
    h(1fr)
    toolbox.slide-number
  }
}


#let make-section(name, shortname: none, caps: true) = slide({
  set page(header: none, footer: none)
  show: pad.with(left: 5%, top: 30%)
  set text(size: 2.25em, weight: "extralight")
  let section = { 
    if caps == true {
      upper(name)
    } else {
      name
    }
  }
  if shortname == none {
    toolbox.register-section(name)
  } else {
    toolbox.register-section(shortname)
  }
  section
})


#let invert-slide(body) = context {
  set page(fill: text.fill)
  set text(fill: page.fill)
  body
}


#let focus(body) = context {
  set page(header: none, footer: none, margin: 2.5em)
  set text(fill: text.fill, size: 1.5em, weight: "extralight")
  set align(horizon)
  show: pad.with(left: 5%)
  body
}


#let img-slide(img,
               invert: false,
               section: false,
               number: false,
               foreground: none,
               slide-fill: none,
               content) = context {
  slide[
    // #let img = image(path)
    #let section = if section == true {true} else {none}

    #if invert == true [
      #show: invert-slide
      #if slide-fill != none [
        #page(background: img,
              foreground: foreground,
              fill: slide-fill,
              footer: make-footer(section: section, number: number),
              content)
      ] else [
        #page(background: img,
              foreground: foreground,
              footer: make-footer(section: section, number: number),
              content)
      ]
    ] else [
      #if slide-fill != none [
        #page(background: img,
              foreground: foreground,
              fill: slide-fill,
              footer: make-footer(section: section, number: number),
              content)
      ] else [
        #page(background: img,
              foreground: foreground,
              footer: make-footer(section: section, number: number),
              content)
      ]
    ]

  ]
}


#let setup(
  text-font: "IBM Plex Sans",
  math-font: "IBM Plex Math",
  code-font: "IBM Plex Mono",
  colour-fg: rgb(21,20,26),
  colour-bg: white,
  // colour-accent: rgb("#099D72"),
  colour-accent: rgb("#D45E00"),
  // accent: rgb("#0172B1"),
  // accent: rgb("#00830E"),
  text-size: 16pt,
  section: true,
  number: true,
  lang: "en",
  body,
) = {

  set page(
    paper: "presentation-16-9",
    fill: colour-bg,
    margin: (top: 6em, left: 3em, right: 3em, bottom: 3em),
    footer: make-footer(section: section, number: number),
    header: slide-title-header,
  )
  set text(
    font: text-font,
    weight: "light",
    // size: text-size,
    size: text-size,
    // fill: black.lighten(10%),
    fill: colour-fg,
    lang: lang,
  )
  set par(leading: 0.7em)
  // set list(spacing: 1em)
  // set enum(spacing: 1em)
  set strong(delta: 200)
  show math.equation: set text(font: math-font)
  show raw: set text(font: code-font)
  show emph: it => text(fill: colour-accent, weight: "regular", it.body)
  show heading.where(level: 1): it => none
  show heading.where(level: 2): it => [
    #set text(size: 0.95em, weight: "medium")
    #v(0.25em)
    #block(it)
    #v(0.5em)
  ]
  show heading.where(level: 3): it => [
    #set text(size: 1em, weight: "light", style: "italic")
    #v(0.25em)
    #block(it)
    #v(0.5em)
  ]

  col-acc.update(old => colour-accent)

  body
  
}

