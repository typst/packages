// ============================================================================
//  uni--bacherlor-thesis  (0.1.0)
//  Un template sobrio y configurable para tesis de pregrado hecho en Typst
//  Autor: Aarón Flores Alberca (@bxcowo)
//  Partiendo de Alejandro Cobos (@Cobos-Bioinfo)
//
//  La siguiente librería está compuesta de 3 funciones:
//    thesis(..)         Función principal de renderizado del documento
//    abbrev-table(..)  Función de creación de tabla de abreviaciones
//    flex-caption(..)  Función de declaración de leyenda para figuras o imágenes
//                      en dos formatos:
//                      - Forma larga para explicación debajo de la misma figura
//                      - Forma corta / reducida para la lista de figuras
//
//  - Tipografía: New Computer Modern (por defecto) / Times New Roman.
//  - Encabezados (Headers): serif negros; el encabezado de nivel 1 usa una
//    fina regla horizontal como motivo que conecta las secciones.
//  - Hipervínculos: color negro (la tesis está pensada para imprimirse), pero
//    mantienen la funcionalidad de clickeo en el PDF.
//  - Citaciones: citas autor-año (APA).
//  - Referencias cruzadas: figuras/tablas como "Fig. N" / "Table N"; sin color
//    ni resaltado, permanecen negras pero clicables en el PDF.
//  - Diseño de página: una sola cara / digital-first, material preliminar en
//    números romanos (I - IV - X - etc) seguido del cuerpo principal en números arábigos (1. - 2. - 3. - etc).
// ============================================================================

// ---------------------------------------------------------------------------
//  Leyendas cortas para la Lista de Figuras / Lista de Tablas.
//  Úsalo en una figura así:
//      ```
//      caption: flex-caption(
//        [Leyenda completa mostrada debajo de la figura ...],  // larga
//        [Título corto mostrado en la Lista de Figuras],       // corta
//      )
//      ```
//  La forma larga se renderiza debajo de la figura; la forma corta se renderiza
//  en las listas. Un `caption: [...]` normal sigue funcionando y se muestra
//  completo en ambos lugares.
// ---------------------------------------------------------------------------

#let _in-outline = state("thesis-in-outline", false)
#let flex-caption(long, short) = context {
  if _in-outline.get() { short } else { long }
}

// Cuando es verdadero, el siguiente encabezado de nivel 1 no fuerza un salto de
// página (se usa para mantener la Lista de Tablas en la misma página que la
// Lista de Figuras).
#let _no-break-before = state("thesis-no-break-before", false)

// Nombres de los meses en español (Typst no localiza `datetime.display`).
#let _meses-es = (
  "enero",
  "febrero",
  "marzo",
  "abril",
  "mayo",
  "junio",
  "julio",
  "agosto",
  "septiembre",
  "octubre",
  "noviembre",
  "diciembre",
)

// Formatea una fecha en español. Acepta un `datetime` (se muestra como
// "<mes> <año>"), una cadena o contenido (se muestra tal cual).
#let _fecha-es(fecha) = {
  if type(fecha) == datetime {
    [#_meses-es.at(fecha.month() - 1) #fecha.year()]
  } else {
    fecha
  }
}

// ---------------------------------------------------------------------------
//  Auxiliar: tabla de abreviaciones a dos columnas.
//  `entries` es un arreglo de pares (corto, largo), p. ej.
//      (("DNA", "Deoxyribonucleic Acid"), ("API", "Application Programming ..."))
// ---------------------------------------------------------------------------
#let abbrev-table(entries) = table(
  columns: (auto, 1fr),
  stroke: none,
  align: (left + top, left + top),
  inset: (x: 0pt, y: 5pt),
  column-gutter: 1.2em,
  ..entries.map(((short, long)) => (strong(short), [#long])).flatten()
)

// ---------------------------------------------------------------------------
//  Template principal
// ---------------------------------------------------------------------------
#let thesis(
  // --- metadatos ---
  titulo: "Título de Tesis",
  subtitulo: none,
  autor: "nombre",
  tipo-tesis: "Tesis de Pregrado", // tipo de documento que se presenta
  programa: none, // programa académico / carrera, p. ej. "Ingeniería de Sistemas"
  facultad: none,
  asesor: none,
  tipografia: "New Computer Modern",
  fecha: datetime.today(), // o datetime(year: .., month: .., day: ..) o "Mes Año"
  ubicacion: none, // p. ej. "Lima" (se imprime junto con la fecha)
  // --- bloques de contenido del material preliminar (none => sección omitida) ---
  certificate: none,
  agradecimientos: none,
  abstract: none,
  keywords: none,
  abreviaciones: none,
  // --- interruptores (toggles) ---
  mostrar-tdc: true, // mostrar tabla de contenidos
  mostrar-lista-figuras: true, // mostrar lista de figuras
  show-lista-tablas: true, // mostrar lista de tablas
  numeracion-encabezados: true, // mostrar numeración de encabezados
  // --- material final (back matter) ---
  bibliografia: none,
  apendices: none,
  // --- cuerpo del documento ---
  body,
) = {
  // ---- documento + página base ----
  set document(author: autor, title: titulo)
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )

  // ---- tipografía ----
  set text(font: tipografia, size: 11pt, lang: "es")
  set par(justify: true, leading: 0.65em)

  // ---- encabezados (clásico: todo serif negro) ----
  show heading.where(level: 1): it => {
    context { if not _no-break-before.get() { pagebreak(weak: true) } }
    v(0.4cm)
    block(below: 0.5em, text(size: 20pt, weight: "bold", it))
    line(length: 100%, stroke: 0.6pt + luma(130))
    v(0.6em)
  }
  show heading.where(level: 2): it => block(
    above: 1.3em,
    below: 0.6em,
    text(size: 14pt, weight: "bold", it),
  )
  show heading.where(level: 3): it => block(
    above: 1.1em,
    below: 0.5em,
    text(size: 12pt, weight: "bold", it),
  )
  show heading.where(level: 4): it => block(
    above: 1.0em,
    below: 0.4em,
    text(size: 11pt, weight: "bold", style: "italic", it),
  )

  // ---- referencias cruzadas: renderiza figuras/tablas como "Fig. N" / "Table N".
  //      Sin color ni resaltado en ningún lugar — la tesis está pensada para
  //      imprimirse, así que los enlaces y referencias permanecen negros
  //      (siguen siendo clicables en el PDF).
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      if el.kind == image {
        let n = counter(figure.where(kind: image)).at(el.location()).first()
        link(it.target)[Fig. #n]
      } else if el.kind == table {
        let n = counter(figure.where(kind: table)).at(el.location()).first()
        link(it.target)[Tabla #n]
      } else {
        it
      }
    } else {
      // encabezados, citaciones, todo lo demás: renderizado por defecto, sin color
      it
    }
  }

  // ---- flex-caption: señaliza a las leyendas cuando se están renderizando en
  //      un índice (Lista de Figuras / Lista de Tablas) para que muestren la
  //      forma corta
  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }

  // ---- figuras y tablas ----
  // contadores separados para imágenes y tablas; leyendas encima de las tablas
  show figure.where(kind: image): set figure(numbering: "1")
  show figure.where(kind: table): set figure(numbering: "1")
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: it => {
    set align(center)
    it
    v(0.4em)
  }
  show figure.caption: set text(size: 9.5pt)

  // reglas de tabla estilo booktabs
  set table(
    stroke: (x, y) => if y == 0 { (bottom: 0.9pt + black) } else { (bottom: 0.4pt + luma(150)) },
    inset: (x: 8pt, y: 5pt),
  )

  // ---- citas en bloque (p. ej. la hipótesis) ----
  show quote.where(block: true): it => block(
    inset: (left: 1.2em, top: 0.4em, bottom: 0.4em),
    stroke: (left: 2pt + luma(180)),
    text(style: "italic", it.body),
  )

  // ---- código / raw ----
  show raw.where(block: true): it => block(
    fill: luma(244),
    inset: 9pt,
    radius: 3pt,
    width: 100%,
    text(size: 9pt, it),
  )
  show raw.where(block: false): it => box(
    fill: luma(244),
    outset: (y: 2pt, x: 1pt),
    radius: 2pt,
    it,
  )

  // =========================================================================
  //  PORTADA  (enmarcada por reglas: la fina regla del encabezado es el motivo
  //  que conecta)
  // =========================================================================
  set page(numbering: "i")
  counter(page).update(1)
  page(header: none, footer: none)[
    #set align(center)
    #set par(justify: false, leading: 0.6em)

    // --- cabecera institucional (arriba) ---
    #v(0.2cm)
    #image("logo/universidad_nacional_de_ingenieria_logo_vector.png", width: 20%)
    #v(0.2cm)
    #text(size: 13pt, weight: "bold")[Universidad Nacional de Ingeniería]
    #linebreak()
    #if facultad != none {
      text(size: 11pt, fill: luma(90))[#facultad]
      linebreak()
    }
    #if programa != none {
      v(0.35cm)
      text(size: 12pt)[#programa]
    }

    #v(1fr)

    // --- título, enmarcado por dos reglas ---
    #line(length: 100%, stroke: 0.8pt + black)
    #v(0.55cm)
    #text(size: 22pt, weight: "bold")[#titulo]
    #if subtitulo != none {
      v(0.5cm)
      text(size: 14pt, style: "italic")[#subtitulo]
    }
    #v(0.55cm)
    #line(length: 100%, stroke: 0.8pt + black)

    #v(0.7cm)
    #text(size: 13pt)[#tipo-tesis]

    #v(1fr)

    // --- autor, asesoría y fecha (abajo) ---
    #text(size: 14pt, weight: "bold")[#autor]
    #v(0.8cm)
    #if asesor != none {
      text(size: 11pt)[Asesor: #asesor]
      linebreak()
    }
    #v(0.8cm)
    #if fecha != none {
      let place = if ubicacion != none { ubicacion + ", " } else { "" }
      text(size: 11pt, fill: luma(80))[#place#_fecha-es(fecha)]
    }
  ]

  // =========================================================================
  //  MATERIAL PRELIMINAR  (números romanos; sin encabezado de página)
  // =========================================================================
  set heading(numbering: none)
  set page(
    header: none,
    footer: context align(center, text(size: 9pt, fill: luma(110), counter(page).display())),
  )

  // Certificado de Dirección — renderizado como contenido crudo del usuario
  // (control total)
  if certificate != none {
    certificate
    pagebreak(weak: true)
  }

  // Agradecimientos
  if agradecimientos != none {
    heading(level: 1, outlined: true)[Agradecimientos]
    agradecimientos
  }

  // Resumen (+ palabras clave opcionales)
  if abstract != none {
    heading(level: 1, outlined: true)[Resumen]
    abstract
    if keywords != none {
      v(1em)
      text(weight: "bold")[Palabras clave: ]
      keywords
    }
  }

  // Tabla de Contenidos
  if mostrar-tdc {
    heading(level: 1, outlined: false)[Índice]
    // poner en negrita las entradas de capítulo (nivel 1); acotado solo a este índice
    {
      show outline.entry.where(level: 1): it => strong(it)
      outline(title: none, depth: 3, indent: auto)
    }
  }

  // Lista de Figuras y Lista de Tablas (mantenidas juntas en una página)
  if mostrar-lista-figuras {
    heading(level: 1, outlined: true)[Índice de Figuras]
    outline(title: none, target: figure.where(kind: image))
  }
  if show-lista-tablas {
    // sigue a la Lista de Figuras en la misma página en lugar de saltar
    if mostrar-lista-figuras {
      v(1.6em)
      _no-break-before.update(true)
    }
    heading(level: 1, outlined: true)[Índice de Tablas]
    _no-break-before.update(false)
    outline(title: none, target: figure.where(kind: table))
  }

  // Lista de Abreviaciones
  if abreviaciones != none {
    heading(level: 1, outlined: true)[Índice de Abreviaciones]
    abbrev-table(abreviaciones)
  }

  // =========================================================================
  //  CUERPO PRINCIPAL  (números arábigos; encabezado de capítulo en curso)
  // =========================================================================
  counter(heading).update(0)
  set heading(numbering: if numeracion-encabezados { "1.1" } else { none })
  set page(
    numbering: "1",
    header: context {
      let cur = here().page()
      let h1 = query(heading.where(level: 1))
      let starts = h1.filter(h => h.location().page() == cur)
      let prior = h1.filter(h => h.location().page() < cur)
      // suprime en la página de apertura de un capítulo; si no, muestra el
      // título en curso
      if starts.len() == 0 and prior.len() > 0 {
        set text(size: 9pt, fill: luma(120))
        prior.last().body
        v(-0.7em)
        line(length: 100%, stroke: 0.4pt + luma(190))
      }
    },
    footer: context align(center, text(size: 9pt, fill: luma(110), counter(page).display())),
  )
  counter(page).update(1)

  body

  // =========================================================================
  //  MATERIAL FINAL
  // =========================================================================
  // Bibliografía (encabezado sin numerar, listado en el índice)
  if bibliografia != none {
    set heading(numbering: none)
    bibliografia
  }

  // Apéndice (después de las referencias; numeración de encabezado A, A.1, ...)
  if apendices != none {
    counter(heading).update(0)
    set heading(numbering: "A.1")
    apendices
  }
}
