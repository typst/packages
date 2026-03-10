#import "@preview/pc-letter:0.2.0"

#let letter = pc-letter.init(
  author: (
      name: "Georg Wilsberg",
      address: ("Frauenstraße 49/50", "48143 Münster"),
      phone: "0251/385 317",
      email: "wilsberg@example.org",
  ),
  date: datetime(day: 8, month: 2, year: 2020),
  place-name: "Münster",
  style: (
    locale: (lang: "de", region: "DE"),
    medium: "digital",
    alignment: (valediction: right),
  ),
)

#show: letter.letter-style

#(letter.falzmarken)()

#(letter.address-field)[
  Frau Tessa Tilker\
  Livesey, Trelawney & Gunn LLP\
  Birkenenallee 13\
  48143 Münster
]

#(letter.reference-field)[LTG/2020/02/ofo]

= Betreff: Beratende Tätigkeit im Fall Folkerts

Sehr geehrte Frau Tilker,

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Überschrift einer Untersektion:

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

#(letter.valediction)(
  signature: text(size: 1.5em, font: ("Lucida Handwriting", "Syne Tactile"), "Wilsberg")
)[Mit freundlichen Grüßen,]

#(letter.cc-field)("Alex Holtkamp, Ekki Talkötter")

#(letter.enclosed-field)("Ursprüngl. Testament", "Angefochtenes Folgetestament", "Gutachten Steinthal")
