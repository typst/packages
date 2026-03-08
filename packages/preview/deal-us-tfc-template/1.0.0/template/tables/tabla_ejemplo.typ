#set table(fill: (_, y) => if y == 0 { yellow })
#show table.cell.where(y: 0): set text(weight: "bold")

#figure(
  table(
    // Anchura de cada columna. Se puede dar simplemente un número de columnas
    columns:(auto, auto, auto, 2cm),
    // Alineamiento del texto. El alineamiento puede ser horizontal u hor+ver
    align:(left, center+horizon, right+bottom, left),
    [Columna L],[Columna C],[Columna R], [Columna 2cm],
    [Texto de ejemplo],[Texto de ejemplo],[Texto de ejemplo],[Texto de ejemplo],
    [ABC],[DEF],[HIJ],[KLM]
  ),
  caption: "Tabla Typst de ejemplo"
)<table:ejemplo>