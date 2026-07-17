// ==========================================
// FIGURAS, TABLAS E IMÁGENES
// ==========================================

#import "counters.typ": numbering-seccion

// Figura auto-numerada con caption abajo
#let figura(body, caption: none) = {
  figure(
    { align(center, body) },
    kind: "image",
    supplement: [Figura],
    numbering: numbering-seccion,
    caption: caption,
  )
}

// Tabla estilo booktabs (LaTeX profesional)
#let tabla(caption: none, columns: auto, ..body) = {
  figure(
    {
      set table(
        stroke: none,
        inset: (x: 10pt, y: 6pt),
        align: horizon,
      )
      table(
        columns: columns,
        table.hline(stroke: 1.2pt),
        ..body,
        table.hline(stroke: 1.2pt),
      )
    },
    kind: "table",
    supplement: [Tabla],
    numbering: numbering-seccion,
    caption: caption,
  )
}

// Atajo para insertar imágenes desde archivo
#let imagen(path, width: 100%, caption: none) = {
  figura(
    image(path, width: width),
    caption: caption,
  )
}

// Imagen a la izquierda, texto a la derecha
#let figura-izq-texto(ruta, caption: none, img-width: 40%, gutter: 5%, texto) = {
  block(width: 100%, below: 1.5em)[
    #grid(
      columns: (img-width, 1fr),
      gutter: gutter,
      align: top,
      figure(image(ruta, width: 100%), kind: "image", supplement: [Figura], numbering: numbering-seccion, caption: caption),
      texto,
    )
  ]
}

// Imagen a la derecha, texto a la izquierda
#let figura-der-texto(ruta, caption: none, img-width: 40%, gutter: 5%, texto) = {
  block(width: 100%, below: 1.5em)[
    #grid(
      columns: (1fr, img-width),
      gutter: gutter,
      align: top,
      texto,
      figure(image(ruta, width: 100%), kind: "image", supplement: [Figura], numbering: numbering-seccion, caption: caption),
    )
  ]
}
