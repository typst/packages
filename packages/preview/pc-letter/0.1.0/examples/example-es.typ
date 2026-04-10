#import "@preview/pc-letter:0.1.0"

#let letter = pc-letter.init(
  author: (
      name: "Juan García Madero",
      address: ("Andrés Bello Nº 10", "Col. Polanco", "11560 México, CDMX"),
      phone: "032 928 384",
      email: "juangarcia@example.org"
  ),
  date: datetime(day: 6, month: 8, year: 1998),
  style: (
    locale: (lang: "es", region: "MX"),
    medium: "digital",
  ),
  place-name: "Ciudad de México",
)

#show: letter.letter-style

#(letter.falzmarken)()

#(letter.address-field)[
  Ulises Lima\
  Calle Colima 23\
  Col. Roma\
  06700 México, CDMX
]

// #(letter.reference-field)[XY/1928/ABC/28]

Estimado Ulises:

= Nuevos descubrimientos sobre C. Tinajero

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Ejemplo de una subdivisión

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

Cras ac tortor ut odio accumsan mattis. Proin nec vestibulum nulla. Suspendisse pulvinar ultricies rutrum. Praesent bibendum finibus orci.

#(letter.valediction)(
  signature: text(size: 3em, font: ("Freestyle Script", "Syne Tactile"), "Juan G.")
)[Hasta pronto]

#(letter.cc-field)("Arturo Belano")

#(letter.enclosed-field)("El documento encontrado", "La servilleta con notas de la C.T.?")