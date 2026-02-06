#import "@preview/pc-letter:0.4.0"

#let letter = pc-letter.init(
  author: (
      name: "Salvo Montalbano",
      address: ("Via del Mare, 10", "97017 Marinella RG"),
      phone: "334 555 8721",
      email: "montalbano.s@example.org"
  ),
  date: datetime(day: 16, month: 7, year: 2022),
  place-name: "Vigàta",
  style: (
    locale: (lang: "it", region: "IT"),
    medium: "digital",
    alignment: (valediction: right),
  ),
)

#show: letter.letter-style

#(letter.falzmarken)()

#(letter.address-field)[
  Spett.le Sig.ra Sjöström Ingrid\
  Via della Cattedrale, 12\
  92100 Montelusa AG
]

#(letter.reference-field)[22/MS-PAG]

= Oggetto: Uno strano avvenimento nei pressi di Agrigento

Gentile Signora Sjöström,

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Titolo di una sottosezione

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

#(letter.valediction)(signature: text(size: 2.5em, font: ("French Script MT", "Syne Tactile"), "Salvo Montalbano"))[Distinti saluti,]

#(letter.enclosed-field)("Fotografia del luogo", "Dichiarazione del testimone")

#(letter.cc-field)("Nicolò Zito")
