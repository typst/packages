#import "@preview/pc-letter:0.4.0"

#let letter = pc-letter.init(
  author: (
      name: "Melania Lupu",
      address: ("Strada Mimozei, Nr. 13", "Sector 2, București"), 
      phone: "031 123 45 67",
      email: "melania.lupu@example.org",
  ),
  date: datetime(day: 25, month: 5, year: 2025),
  place-name: "București",
  style: (
    locale: (lang: "ro", region: "RO"),
    medium: "digital",
    alignment: (valediction: right),
  ),
)

#show: letter.letter-style

#(letter.falzmarken)()

#(letter.address-field)[
  Maior Aurel Cristescu\
  Inspectoratul General al Miliției\
  Șoseaua Ștefan cel Mare, Nr. 13-15\
  Sector 2, București
]

#(letter.reference-field)[JST-17/SH]

= Subiect: Micile mele observații privind cazul din strada Mântuleasa

Stimate Domnule Maior,

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Un indiciu suplimentar:

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

#(letter.valediction)(signature: text(size: 2.5em, font: ("Edwardian Script ITC", "Brush Script MT", "cursive"), "Melania"))[Cu stimă,]

#(letter.enclosed-field)("Schița Muzeului", "Scrisori diverse")

#(letter.cc-field)("Locotenent Azimioară")
