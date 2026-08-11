#import "@preview/pc-letter:0.1.0"

#let letter = pc-letter.init(
  author: (
      name: "Thomas Mathias",
      address: ("7B Cae Melyn", "Aberystwyth SY23 2HA"),
      phone: "01970 612 125",
      email: "tom.mathias@example.org"
  ),
  date: datetime(day: 29, month: 10, year: 2013),
  place-name: "Münster",
  style: (
    locale: (
      lang: "cy",
    ),
    medium: "digital",
  ),
)

#show: letter.letter-style

#(letter.falzmarken)()

#(letter.address-field)[
  CS Brian Prosser\
  Gorsaf Heddlu Aberystwyth\
  Heddlu Dyfed-Powys\
  Boulevard Sanit Brieuc\
  Aberystwyth SY23 1PH
]

#(letter.reference-field)[DPP/2013/10/HR-621]

Annwyl Syr,

= Trosglwyddiad i'ch uned yn Aberystwyth

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Eisampl o is-bennawd

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

#(letter.valediction)(
  signature: text(size: 1.5em, font: ("Lucida Handwriting", "Syne Tactile"), "T. Mathias"),
  name: "Tom Mathias"
)[Yr eiddoch yn gywir,]

#(letter.cc-field)("DI Mared Rhys", "DS Siân Owens", "DC Lloyd Elis")

#(letter.enclosed-field)("Cynllun ail-strwythuro'r uned")
