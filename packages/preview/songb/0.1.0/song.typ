// SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
//
// SPDX-License-Identifier: EUPL-1.2+

#let verseNumber = counter("verse-number")

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

#let song(
  title: none,
  title-index: none,
  singer: none,
  singer-index: none,
  references: (),
  line-color: rgb(0xd0, 0xd0, 0xd0),
  header-display: (number, title, singer) => grid(
    columns: (auto,1fr),
    inset: 4pt,
    align: horizon,
    grid.cell(fill: rgb(0xd0, 0xd0, 0xd0),align: top, inset:(rest:4pt, /*right: 10pt*/), heading(outlined: false,str(number))),
    [
      #heading(title)
      #if singer != none {
        strong(singer) + "\n"
      }
    ],
  ),
  doc,
) = context {
  verseNumber.update(1)
  counter(heading).step()
  let number = counter(heading).get().first()+1
  [#metadata((
    name: title,
    sortable: if title-index != none { title-index } else { _to-string(title) },
    references: references,
    counter: number,
  ))<song>]
  if singer != none {
    [#metadata((
      name: singer,
      sortable: if singer-index != none { singer-index } else { _to-string(singer) },
      references: references,
      counter: number,
    ))<singer>]
  }

  header-display(number, title, singer)

  if references.len() > 0 {
    v(-8pt)
    emph(references.join("\n"))
  }

  doc

  line(length: 100%,stroke: line-color)
}

#let chorus(body) = {
  text(weight: "bold",body)
}
#let verse(body) = context{
  let start = verseNumber.get()
  enum(start: start.first(), par(body))
  verseNumber.step()
}

#let index-by-letter(label, letter-highlight: (letter) => {
  box(fill:rgb(0xd0, 0xd0, 0xd0), inset: 4pt,text(size: 1.2em,emph(letter)))+v(-.75em)
  // text(size: 1.2em,fill:rgb(0x76, 0x76, 0x76),emph[~#letter])+"\n"
}) = context {
  let letters = (:)
  for indexed in query(label) {
    let (name, counter, sortable) = indexed.value
    if sortable == none or sortable == "" {
      continue
      // panic(name)
    }
    let letter = upper(sortable.first())
    if letter < "A" or letter > "Z" {
      letter = "#"
    }

    let names = letters.at(letter, default: (:))
    let entry = names.at(sortable,default: (name:name,counters:()))
    entry.counters.push((
      counter:counter,
      location:indexed.location(),
    ))
    names.insert(sortable, entry)
    letters.insert(letter,names)
  }

  for letter in letters.keys().sorted() {
    letter-highlight(letter)
    let names = letters.at(letter)
    for name in names.keys().sorted() {
      let entry = names.at(name)
      let counters = entry.counters
      link(counters.first().location,
        entry.name+box(width: 1fr,text(fill:rgb(0x76, 0x76, 0x76),repeat[~.]))+" "
      )
      let first = true
      for c in counters {
        let txt = if not first{
          ", "
        } + str(c.counter)
        link(c.location,txt)
        first = false
      }
      "\n"
    }
    // v(.25em)
  }
}
