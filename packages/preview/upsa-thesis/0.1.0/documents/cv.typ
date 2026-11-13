#import "@preview/butterick-resume:0.1.2": introduction, template, two-grid

#show: template.with()

#set text(
  lang: "es",
  region: "bo",
  font: "Reforma 1918",
)

#show heading.where(level: 1): set text(font: "Reforma 2018")
#show heading.where(level: 2): set text(font: "Reforma 1918")

#introduction(
  name: text(font: "Reforma 1918")[Nombre y Apellido],
  details: text(font: "Reforma 2018")[
    LinkedIn
    #h(1em)
    GitHub
    #h(1em)
    Correo electrónico
  ],
)

= Educación
#two-grid(
  left: [UPSA],
  right: [2021 -- 2025],
)

_Licenciatura en Ingeniería de Sistemas_

- #lorem(10)
- #lorem(10)
- #lorem(10)

#two-grid(
  left: [Colegio],
  right: [2015 -- 2021],
)

_Bachiller en Humanidades_

- #lorem(10)
- #lorem(10)
- #lorem(10)

= Habilidades técnicas

- #lorem(10)
- #lorem(10)
- #lorem(10)

= Proyectos, premios y reconocimientos

#two-grid(
  left: [TecnoUPSA],
  right: [2026],
)

_Primer lugar..._

- #lorem(10)
- #lorem(10)
- #lorem(10)
