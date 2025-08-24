// SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
//
// SPDX-License-Identifier: EUPL-1.2+

// from https://typst.app/universe/package/conchord
#let overchord(body, align: start, height: 1em, width: 0pt) = box(place(align, box(width:50em,body)), height: .2em + height, width: width,inset:(top:-.3em))
// todo: prevent collision, by checking (and updating) location

// adapted from https://github.com/typst/typst/issues/2196#issuecomment-1728135476
#let _to-string(content) = {
  if type(content) == str {
    return content
  }
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(_to-string).join("")
  } else if content.has("body") {
    _to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// "": show chords
// "hide": hide chords
#let chord-display = state("chord-display", sys.inputs.at("chord", default:""))

// first argument: chord name
// optional second argument: text below the chord (useful for whitespace for instance)
#let chord(..content) = context {
  if content.pos().len() > 2 {
    panic("Too many contents ("+str(content.pos().len())+") for #chord:"+repr(content))
  }
  let chord = content.pos().first()
  let txt = content.pos().at(1, default:none)

  if chord-display.get() == "hide" {
    return txt
  }
  let previousChords = query(selector(<chord>).before(here()))
  let blank = 0
  if previousChords.len() > 0 {
    let previous = previousChords.last().location()
    if here().page() == previous.page() and calc.abs(here().position().y - previous.position().y) < 20pt {

      let minPad = 2pt
      let missingWhitespace = previous.position().x + measure(previousChords.last()).width - here().position().x + minPad
      if missingWhitespace > 0pt {
        if (missingWhitespace > minPad + 0pt) {
          // a lot is missing: show a dash
          box(width: missingWhitespace,align(center+horizon)[-])
          hide(box(width: 1pt)[.])
        } else {
          // not a lot missing: add a simple space
          hide(box(width: missingWhitespace)[.])
        }
        // repr(here().position().y - previous.position().y)
      }
    }
  }

  let styledChord = text(size: 1em,style:"italic",weight: "regular")[#chord<chord>]

  if txt != none {
    let stxt = _to-string(txt)
    if stxt == "" or stxt == none or stxt == " " {
      txt = [~]
    }
    box(
      stack(
        dir:ttb,
        spacing: 2pt,
        {
          show "#": name => {text(size:1em,"♯")}
          show "b": name => {text(size:1em,"♭")}
          box(styledChord)
        },
        txt
    ))
  } else {
    show "#": name => {text(size:1em,"♯")}
    show "b": name => {text(size:1em,"♭")}
    overchord(styledChord)
  }
}
