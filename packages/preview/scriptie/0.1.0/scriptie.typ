// Copyright © Kauri Pälsi 2026
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 

#import "translations.typ": translations

/// Titlepage for the script
#let titlepage(title: context translations.at(text.lang, default: translations.default).default-title, author:(), version:none, contact: none, subtitle: none, date: none) = context {
  set page(foreground: none)
  set document(title: title, author: author, keywords: translations.at(text.lang, default:translations.default).file-keywords)
  set par(leading: 0em)
  align(center+horizon)[
  #v(1fr)
  *#underline(title)*

  #v(1em)
  by
  #v(-0.5em)
  #author.join("\n")
  #v(0.5em)
  #if version != none [#version\ ]
  #if date == none {
  datetime.today().display(translations.at(text.lang, default:translations.default).date-format)
  } else if type(date) == datetime {
  date.display(translations.at(text.lang).date-format)
  } else {
    date
  }
  #v(0.5em)
  #subtitle
  #v(1fr)
  #align(right, contact)
  ]
  pagebreak()
  counter(page).update(1)
}

/// Parenthetical within a line of dialogue
#let pa(body) = [#[(#body)]<scriptie-parenthetical>]

#let _speaker(name,..extension) = [
    #(upper(name) +
    for ext in extension.pos() {
      [ (#ext)]
    })<scriptie-speaker>
]

/// Centered "text sign" or "ASCII art" in the script
#let sign(content) = align(center,block(breakable:false, width:100cm, content))

/// Dialogue. Extensions (e.g. V.O.) can be added after the speaker/character before the line being spoken
#let dialogue(speaker,..extensions, line) = {
let c = counter("scriptie-contd")
c.update(0)
let head = context {
  c.step()
  _speaker(speaker, ..(if c.get().first() != 0 {(translations.at(text.lang, default: translations.default).contd,)} else {()})+extensions.pos())
}
show grid: set block(spacing: 1em)
// show grid.cell: set block(spacing: 0pt, sticky: true)
show grid.cell: set block(spacing: 0pt)
set par(spacing: 0pt, first-line-indent: 1.2em)
[#grid(
grid.header("",head, repeat:true),
"",block(line)
)<scriptie-dialogue>]
}

/// Scene
#let scene(logline) = {
    counter("scriptie-scene").step()
    let number = context numbering("1",counter("scriptie-scene").get().at(0))
    [*#number<scriptie-scene_num_l>#number<scriptie-scene_num_r>#block(sticky:true, above: 3em, below:2em, (upper(logline)))*]
}

/// Large heading to separate arcs, acts etc.
#let part(name) = {
    counter("scriptie-part").step()
  [#context [\===== #(translations.at(text.lang, default: translations.default).part-title) #(counter("scriptie-part").get().at(0)): #name =====]<scriptie-part>]
}

/// Transition
#let transition(trans) = {
  block(spacing:1em, width:100%, align(right,strong(upper(trans))))
}

/// Page with just text, optionally with different margins
#let plainpage(content,margin:none,header:none) = {
  let do-header = if header == none {margin==none} else {header}
  set page(foreground: none) if not do-header
  set page(margin:margin) if margin != none
  pagebreak(weak:true)
  block(width:100cm,height:100%,content.text)
  pagebreak(weak:true)
}

/// Format the script
#let script(document,
  size:(x:6in,y:9in),
  margin:(left:3fr,right:2fr,top:1fr,bottom:1fr),
  indent:(character:(2in,4in),parenthetical:(1.5in,2.5in),dialogue:(1in,3.5in)),
  scene-numbering: (left:2cm,right:1cm),
  page-numbering: (dx:-1in,dy:0.8in),
  page-size: ("a4",)
) = {
  let margin = {
    let x = 100%-size.x;
    let y = 100%-size.y;
    let wx = margin.left+margin.right;
    let wy = margin.bottom+margin.top;
    (left:x*(margin.left/wx), right:x*(margin.right/wx), top:y*(margin.top/wy), bottom:y*(margin.bottom/wy))
  }
  indent.character.at(0) -= indent.dialogue.at(0)
  indent.parenthetical.at(0) -= indent.dialogue.at(0)

  set page(margin: margin, ..page-size)
  let textsettings = (size:12pt, top-edge: 0.8em, bottom-edge: -0.2em, font:("Courier Prime","Courier","DejaVu Sans Mono"), weight:"regular")
  set text(..textsettings)
  set par(leading: 0mm, spacing: 1em)
  show heading: set text(..textsettings)
  show heading: set block(spacing: 0pt)
  show raw: set text(..textsettings)
  set page(foreground: if page-numbering != none {place(right,context [#counter(page).get().first().],..page-numbering,)})

  show <scriptie-parenthetical>: it => block(sticky: true, grid(columns: indent.parenthetical,[],it)) //bug #5296
  show <scriptie-speaker>: it => grid(columns:indent.character,[],it)
  show <scriptie-dialogue>: set grid(columns:indent.dialogue)
  show <scriptie-scene_num_r>: it => if scene-numbering.right != none {place(dx:100%+scene-numbering.right,it)} else {[]}
  show <scriptie-scene_num_l>: it => if scene-numbering.left != none {place(dx:-scene-numbering.left,it)} else {[]}
  show <scriptie-part>: it => {
    pagebreak(weak: true)
    align(center, block(above:1in,below:1in, it))
  }
  show "…": "..."
  show "–": "--"
  document
}

/// Format the script using the following quick syntax:
/// = Part
/// == Scene
/// /Character (0 or 1 extensions): (with any number of parentheticals) Line.
/// ```
/// PRE-FORMATTED
///      TEXT
/// ```
#let qscript(
  ..args
  ) = {
  show list.item: it => transition(it.body)
  show terms.item: it => {
    let s = state("scriptie-parse-exts",none)
    s.update(none)
    let ext_re = regex("\s*\((.*?)\)\s*")
    let paren_re = regex("\((.*?)\)")
    show "()": ""
    dialogue(
    {show ext_re: it => {s.update((it.text.match(ext_re).captures.first()))}; it.term},
     (context s.get()),
    {show paren_re: it => pa(it.text.match(paren_re).captures.first())
    it.description})
  }
  show heading.where(level:2): scene
  show heading.where(level:1): it => part(it.body)
  show raw: sign
  script(..args)
}
