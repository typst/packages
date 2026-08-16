#let acts02 = (
  (
    nombre: [ #lorem(9) ],
    descripcion: [
      #lorem(35)
    ],
    contenido: [
      _#lorem(13)_:
      - #lorem(5)
      - #lorem(5)
      - #lorem(5)
    ],
    gantt: (
      (nombre: [#lorem(7)]),
      (nombre: [#lorem(7)]),
      (nombre: [#lorem(7)]),
    ),
    duracion: 30,
  ),
  (
    nombre: [ #lorem(9) ],
    descripcion: [
      #lorem(35)
    ],
    contenido: [
      #lorem(40)
      #rect(width: 65%, height: 6cm)
    ],
    gantt: (
      (nombre: [#lorem(7)], duracion: 12),
      (nombre: [#lorem(7)], duracion: 18),
      (nombre: [#lorem(7)], duracion: 24),
    ),
  ),
  (
    nombre: [ #lorem(9) ],
    descripcion: [
      #lorem(35)
    ],
    contenido: [
      #lorem(11)
    ],
    gantt: (
      (nombre: [#lorem(7)], duracion: 4),
      (nombre: [#lorem(7)], duracion: 8),
      (nombre: [#lorem(7)], duracion: 13),
      (nombre: [#lorem(7)], duracion: 5),
    ),
  ),
)
