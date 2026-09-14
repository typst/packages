#import "@preview/pc-letter:0.1.0"

#let letter = pc-letter.init(
  author: (
      name: "Arsène Lupin",
      address: ("8 Rue Crevaux", "75116 Paris"),
      phone: "01 47 51 73 82",
      email: "lupin@example.org"
  ),
  date: datetime(day: 25, month: 5, year: 2025),
  place-name: "Paris",
  style: (
    locale: (
      lang: "fr",
      region: "FR",
    ),
    medium: "digital",
    alignment: (valediction: right),
  ),
)

#show: letter.letter-style

#(letter.falzmarken)()

#(letter.address-field)[
  Assane Diop\
  c/o Benjamin Férel\
  Marché Biron\
  85 Rue des Rosiers\
  93400 Saint-Ouen-sur-Seine
]

#(letter.reference-field)[JST-17/SH]

= Objet : Votre demande concernant un certain détective anglais

Monsieur,

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Titre d'unu partie inférieure:

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

Avec mes remerciements, je vous prie de trouver ici, Monsieur, l’expression de mes sentiments distingués.

#(letter.valediction)(signature: text(size: 2.5em, font: ("French Script MT", "Syne Tactile"), "A. Lupin"))[]

#(letter.enclosed-field)("Plan du site", "Notes manuscrites")

#(letter.cc-field)("Claire Laurent")
