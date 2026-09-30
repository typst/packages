#import "@preview/unify:0.8.1": num, numrange, qty, qtyrange
#import "@preview/physica:0.9.8": *

// Longitud por defecto del resumen de ejemplo (en palabras)
#let resume-len = 138
#let abstract-len = 130

// ── Estados compartidos ──────────────────────────────────────────
#let in-annex = state("in-annex", false)
#let annex-offset-state = state("annex-offset", 0)
#let cur-chapter-num = state("cur-chapter-num", 0)
#let cur-annex-num = state("cur-annex-num", 0)
#let show-chapter-label = state("show-chapter-label", false)

// ── Función auxiliar: anexos ─────────────────────────────────────
// Envuelve contenido para que los títulos de nivel 1 usen numeración
// romana independiente (Anexo I, Anexo II, ...). Al salir, restaura
// el contador para que los capítulos siguientes continúen donde estaban.
// Uso: #anexos[ = Manual de usuario ... = Capturas ... ]
#let anexos(body) = {
  pagebreak()

  // Guardar el contador actual y reiniciarlo para los anexos
  context {
    let saved = counter(heading).get()
    annex-offset-state.update(saved.at(0, default: 0))
    counter(heading).update(0)
    []
  }

  // Sobrescribir la numeración de headings nivel 1 con "Anexo I.", etc.
  show heading.where(level: 1): set heading(numbering: (..n) => {
    "Anexo " + numbering("I", n.at(0)) + "."
  })

  in-annex.update(true)
  cur-annex-num.update(0)
  body
  in-annex.update(false)

  // Restaurar el contador de capítulos al valor anterior a los anexos
  context {
    let offset = annex-offset-state.get()
    counter(heading).update(offset)
    []
  }
}

// ── Plantilla principal ──────────────────────────────────────────
#let tfgei(
  // Metadatos del trabajo
  titulo: "Título do Traballo de Fin de Grado",
  alumno: "D. Nome Alumna/o",
  tutor: "Nome do meu titor",
  tfgnum: "XX-XX",
  area: "Linguaxes e Sistemas Informáticos",
  departamento: "Informática",
  fecha: "Xullo, 20XX",
  // Contenido del resumen y palabras clave
  resumen: lorem(resume-len),
  pclave: lorem(6).replace(" ", ", ").replace(",,", ","),
  // Resumen en inglés (se muestra siempre que no sea none)
  abstract: none,
  kwords: lorem(6).replace(" ", ", ").replace(",,", ","),
  // Agradecimientos (none para omitir)
  agradecimientos: quote(attribution: [Plato], block: true)[#lorem(20)],
  // Idioma: "gl" (gallego) o "es" (castellano)
  idioma: "gl",
  // Salto de página automático antes de cada capítulo
  salto-capitulo: true,
  // Configuración del índice de contenidos
  indice-contenido: (
    enabled: true,
    profundidad: none
  ),
  // Índices secundarios (desactivados por defecto)
  indice-figuras: (
    enabled: false,
    titulo: "",
  ),
  indice-tablas: (
    enabled: false,
    titulo: "",
  ),
  indice-listados: (
    enabled: false,
    titulo: "",
  ),
  // Índices adicionales: true = tras el TOC, false = al final
  indice-pos: true,
  // Activar/desactivar numeración por nivel: ("2": false) oculta nº en subsecciones
  numeracion: (:),
  // Modo del encabezado: 0 = nombre+ título, 1 = capítulo, 2 = alterno par/impar
  encabezado: 0,
  doc,
) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 3cm),
    footer: none,
  )

  // Diccionario de etiquetas de texto según idioma
  let label-defs = (
    gl: (
      memoria: "Memoria do Traballo de Fin de Grao que presenta",
      titulacion: "para a obtención do Título de Graduado en Enxeñaría Informática",
      tfg_num: "Traballo de Fin de Grao Nº:",
      tutor: "Titor/a:",
      area: "Área de coñecemento:",
      departamento: "Departamento:",
      resumen: "Resumo",
      palabras_clave: "Palabras clave:",
      capitulo: "Capítulo",
      anexo: "Anexo",
      indice: "Índice de contenidos",
      indice_figuras: "Índice de figuras",
      indice_tablas: "Índice de tablas",
      indice_listados: "Índice de listados",
      lang: "gl",
    ),
    es: (
      memoria: "Memoria del Trabajo de Fin de Grado que presenta",
      titulacion: "para la obtención del Título de Graduado en Ingeniería Informática",
      tfg_num: "Trabajo de Fin de Grado Nº:",
      tutor: "Tutor/a:",
      area: "Área de conocimiento:",
      departamento: "Departamento:",
      resumen: "Resumen",
      palabras_clave: "Palabras clave:",
      capitulo: "Capítulo",
      anexo: "Anexo",
      indice: "Índice de contenidos",
      indice_figuras: "Índice de figuras",
      indice_tablas: "Índice de tablas",
      indice_listados: "Índice de listados",
      lang: "es",
    ),
    en: (
      abstract: "Abstract",
      keywords: "Keywords:",
      lang: "en",
    ),
  )
  let labels = label-defs.at(idioma, default: label-defs.gl)

  set text(size: 11pt, lang: labels.lang)
  set par(linebreaks: "optimized", justify: true, spacing: 1.8em, leading: 1.2em)

  // Los enlaces se muestran en azul. Si el destino es un string y coincide
  // con el texto del enlace se usa monoespaciada; en otro caso, subrayado normal.
  show link: it => {
    let is-self-ref = type(it.dest) == str and it.body.text.contains(it.dest)
    if is-self-ref {
      text(fill: blue, font: "IBM Plex Mono", size: 10.2pt, underline(it))
    } else {
      text(fill: blue, underline(it))
    }
  }

  // Estado que guarda el nombre del capítulo actual para el encabezado
  let cur-chapter = state("cur-chapter", [])

  // ── Estilo de headings ─────────────────────────────────────────
  // Nivel 1: capítulos y anexos
  set heading(numbering: "1.")
  show heading.where(level: 1): item => {
    cur-chapter.update(item.body)
    let numbered = item.numbering != none
    show-chapter-label.update(numbered)
    // Incrementar el contador manual adecuado (capítulo o anexo)
    if numbered {
      if in-annex.get() {
        cur-annex-num.update(n => n + 1)
      } else {
        cur-chapter-num.update(n => n + 1)
      }
    }
    if salto-capitulo {
      pagebreak(weak: true)
    }
    v(5em)
    if numbered {
      text(black, weight: "bold", size: 20pt)[#context counter(heading).display()]
      " "
    }
    text(black, weight: "bold", 20pt)[#item.body]
    v(-0.6em)
    line(length: 100%)
    v(1.5em)
  }

  // Nivel 2: subsecciones
  show heading.where(level: 2): item => {
    v(20pt)
    if numeracion.at("2", default: true) {
      text(black, weight: "bold", size: 15pt)[#context counter(heading).display()]
      " "
    }
    text(black, weight: "bold", 15pt)[#item.body]
    v(0.1em)
  }

  // Nivel 3: subsubsecciones
  show heading.where(level: 3): item => {
    v(10pt)
    if numeracion.at("3", default: true) {
      text(black, weight: "bold", size: 13pt)[#context counter(heading).display()]
      " "
    }
    text(black, weight: "bold", 13pt)[#item.body]
    v(0.3em)
  }

  // ── Portada ─────────────────────────────────────────────────────
  align(center)[
    #v(25pt)
    #image("logo_uvigo.png", width: 45%)

    #text(size: 17pt)[#strong[E]SCOLA #strong[S]UPERIOR #strong[D]E #strong[E]NXEÑARÍA #strong[I]NFORMÁTICA]
    #v(60pt)
    #text(size: 13pt)[#labels.memoria]
    #v(-10pt)
    #text(size: 15pt, weight: "bold")[#alumno]
    #v(-10pt)
    #text(size: 13pt)[#labels.titulacion]
    #v(10pt)
    #text(size: 15pt, weight: "bold")[#titulo]

    #v(145pt)
    #align(center)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 16pt,
        image("emblema_ing_informatica.png", width: 3.2cm),
        align(left)[
          #stack(
            spacing: 8pt,
            v(5pt),
            [#fecha],
            v(22pt),
            [#strong[#labels.tfg_num]#h(1.5mm) #tfgnum],
            v(22pt),
            [#strong[#labels.tutor]#h(1.5mm)  #tutor],
            [#strong[#labels.area]#h(1.5mm)  #area],
            [#strong[#labels.departamento]#h(1.5mm) #departamento],
          )
        ],
      )
    ]
  ]

  // ── Agradecimientos ────────────────────────────────────────────
  // Se omiten si se usa el valor por defecto (cita de Platón)
  if (agradecimientos != none) {
    let is-default = (
      agradecimientos.func() == quote
      and agradecimientos.has("attribution")
      and agradecimientos.attribution == [Plato]
    )
    if not is-default [
      #pagebreak()
      #align(center + horizon, text(size: 18pt, [#agradecimientos]))
    ]
  }

  // ── Resumen y palabras clave ───────────────────────────────────
  if (resumen != none) {
    pagebreak()
    align(top)[
      #text(fill: black, size: 18pt, weight: "regular")[#labels.resumen]

      #resumen

      #text(weight: "bold")[#labels.palabras_clave]
      #pclave
    ]
  }

  // ── Abstract (inglés) ───────────────────────────────────────────
  if (abstract != none) {
    pagebreak()
    align(top)[
      #text(fill: black, size: 18pt, weight: "regular")[#label-defs.en.abstract]

      #abstract

      #text(weight: "bold")[#label-defs.en.keywords]
      #kwords
    ]
  }

  // ── Índice de contenidos ───────────────────────────────────────
  if indice-contenido.enabled {
    outline(
      title: labels.indice,
      depth: indice-contenido.profundidad,
      indent: 1.2em,
    )
  }

  // ── Generador de índices adicionales ────────────────────────────
  // Se reutiliza tanto para la posición inicial como final.
  let make-indices() = {
    if indice-figuras.enabled or indice-tablas.enabled or indice-listados.enabled {
      context {
        pagebreak()
        if indice-figuras.enabled {
          outline(
            title: indice-figuras.at("titulo", default: labels.indice_figuras),
            target: figure.where(kind: image),
          )
        }
        if indice-tablas.enabled {
          outline(
            title: indice-tablas.at("titulo", default: labels.indice_tablas),
            target: figure.where(kind: table),
          )
        }
        if indice-listados.enabled {
          outline(
            title: indice-listados.at("titulo", default: labels.indice_listados),
            target: figure.where(kind: raw),
          )
        }
      }
    }
  }

  if indice-pos {
    make-indices()
  }

  // ── Configuración de página con encabezado y pie ───────────────
  set page(
    margin: (left: 3cm, right: 2.5cm, top: 2.5cm, bottom: 1.5cm),
    // Pie: número de página a la derecha
    footer: context [
      #set align(right)
      #text(13pt)[#counter(page).display()]
    ],
    // Encabezado: tres modos disponibles (parámetro encabezado)
    header: context {
      set text(10pt)
      let is-annex = in-annex.get()
      let ch-show = show-chapter-label.get()
      let ch-label = if is-annex { labels.anexo } else { labels.capitulo }
      let ch-num-val = if ch-show {
        if is-annex { cur-annex-num.get() } else { cur-chapter-num.get() }
      } else { 0 }
      let ch-num = if ch-num-val > 0 {
        if is-annex { numbering("I", ch-num-val) + "." }
        else { str(ch-num-val) + "." }
      } else { "" }
      // Modo 0: nombre del alumno + título del trabajo
      if encabezado == 0 {
        align(right)[
          #alumno
          #v(-0.9em)
          #titulo
        ]
      // Modo 1: etiqueta del capítulo + nombre, con línea inferior
      } else if encabezado == 1 {
        align(right)[
          #if ch-show [
            #ch-label #ch-num
          ]
          #cur-chapter.get()
        ]
        v(-1em)
        line(length: 100%, stroke: 0.6pt)
      // Modo 2: alterna capítulo (pares) y título (impares), con línea
      } else if encabezado == 2 {
        let page-num = counter(page).get().first()
        if calc.rem(page-num, 2) == 0 {
          align(right)[
            #if ch-show [
              #ch-label #ch-num
            ]
            #cur-chapter.get()
          ]
        } else {
          align(left)[#titulo]
        }
        v(-1em)
        line(length: 100%, stroke: 0.6pt)
      }
    },
  )
  counter(page).update(1)
  doc

  // ── Índices de figuras, tablas y listados (al final) ──────────
  if not indice-pos {
    show outline: set heading(outlined: true)
    show-chapter-label.update(false)
    make-indices()
  }
}
