// SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
//
// SPDX-License-Identifier: CC0-1.0

#import "../song.typ": song as s, chorus, verse, index-by-letter
#import "../autobreak.typ": autobreak

#set page("a5")

#columns(2)[
  = Songs
  #index-by-letter(<song>)
#colbreak()
  = Singers
  #index-by-letter(<singer>)
]

#pagebreak()

#let song(
  title: none,
  title_index: none,
  singer: none,
  singer_index: none,
  references: (),
  doc)={
  autobreak(
    s(
    title:title,
    title_index:title_index,
    singer:singer,
    singer_index:singer_index,
    references:references,
    doc)
  )
  v(-1.2em)
}

#song(
  title: "First song",
)[

#verse[
  Premier couplet
]

#chorus[
  Refrain
]

#verse[
  Deuxième couplet
]

Bridge

#verse[
  Troisième couplet
]
]

#song(
  title: "Second song",
)[

#verse[
  Premier couplet
]

#chorus[
  Refrain
]

#verse[
  Deuxième couplet
]

Bridge

#verse[
  Troisième couplet
]
]


#counter(heading).update(99)

#song(
  title: "French song",
  singer: "Joe Dassin",
)[

#verse[
  Premier couplet
]

#chorus[
  Refrain
]

#verse[
  Deuxième couplet
]

Bridge

#verse[
  Troisième couplet
]

#lorem(255)
]

#song(
  title: "German song",
)[

#verse[
  Premier couplet
]

#chorus[
  Refrain
]

#verse[
  Deuxième couplet
]

Bridge

#verse[
  Troisième couplet
]
]

#context[#metadata((
  name: "Additional <song>",
  sortable: "Additional",
  references: none,
  counter: counter(heading).get().first()+1,
))<song>]
#context[#metadata((
  name: "Additional <singer>",
  sortable: "Additional",
  references: none,
  counter: counter(heading).get().first()+1,
))<singer>]
#song(
  title: "German song",
  singer: "Max Mustermann",
  references: ("again to test repetition in the index",)
)[]

#song(
  title: "Pseudo German song",
  title_index: "German song",
  references: ("with a title_index of \"German song\"","to set it up somewhere else in the index",)
)[]


#song(
  title: "Hidden song",
  title_index: "",
  references: ("with an empty title_index to hide from the index",)
)[
  With a reference
]

#song(
  title: ['74 --- '75],
  singer: [O' Connells],
  singer_index: "#",
)[
  Typography should not be lost in the index!\
  Another paragraph

  And a last one\
  And a last one\
  And a last one\
]
#song(
  title: "song with a lowercase",
)[]
#song(
  title: "1, 2, 3",
  singer: "Max Mustermann",
)[]
#song(
  title: "Et 1, et 2, et 3 zéro!",
  title_index: "#1 et 2",
  singer: "Max Mustermann",
)[]


#song(
  title: [
    The German song
  ],
  title_index: "German song (The)",
)[]