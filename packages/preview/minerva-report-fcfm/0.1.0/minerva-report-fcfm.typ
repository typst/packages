/** minerva-article.typ
 *
 * Este archivo contiene la estructura y estilos usados por el template.
 * Para definir tus propios comandos agrégalos a preamble.typ.
 *
 **/

/******************************************************************************
 *           Funciones base
 *
 * La idea es que si necesitas extender personalizar el template,
 * sobrescribir el header o crear una portada, etc. Deberías extender
 * su respectivo base. La razón de esto es que ciertas funcionalidades
 * del template requieren estado. Además estos base settean estilos
 * que ayudan a que haya coherencia visual.
 *****************************************************************************/

#let base-header(it) = {
  metadata((marker: "PAGE-START"))
  set block(spacing: 0pt, clip: false)
  set par(leading: 0.4em)
  it
}

#let base-footer(it) = {
  set block(spacing: 0pt, clip: false)
  set par(leading: 0.4em)
  it
  metadata((marker: "PAGE-END"))
}

#let base-front-page(it, ..args) = {
  return page(..args, {
    it
    counter(page).update(0)
  })
}

/** Localización
 *
 * Las siguientes son funciones de utilidad general para mejor
 * soporte del español.
 **/
/// Arreglo con los nombres de meses en español.
#let meses = ("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio",
              "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

/// Aplica el formato "[day] de [month repr: long] del [year]" en español
/// 
/// fecha (datetime): fecha a dar formato.
/// -> str
#let formato-fecha(fecha) = {
  return str(fecha.day()) + " de " + meses.at(fecha.month()) + " de " + str(fecha.year())
}

/// Show rule que cambia el formato de los número para usar coma decimal.
///
/// doc (content): documento a aplicar reglas
/// -> content
#let formato-numeros(doc) = {
  // https://github.com/typst/typst/issues/1093#issuecomment-1536620129
  show regex("\d+.\d+"): it => {
    if it.func() == heading {
      show ".": ","
    }
    it
  }
  
  show math.equation: it => {
    show regex("\d+.\d+"): it => {
      show ".": {","+h(0pt)}
      it
    }
    it
  }
  
  doc
}

/** Elements
 *
 * Estas funciones generan elementos para usarse como parte del documento.
 */
/// Repite un contenido `count` veces con `padding` entre ellos.
/// Si `count` es `auto`, se utiliza tanto espacio como haya disponible.
/// - body    (content, str, int): Contenido a repetir.
/// - padding (length)           : Espaciado entre repeticiones.
/// - count   (int, auto)        : Cantidad de repeticiones.
/// -> content
#let rep(padding: 0pt, count: auto, body) = context {
  if count != auto {
    stack(dir: ltr, spacing: padding, ..range(count + 1).map(_ => body))
  } else {
    layout(size => context {
      let width = measure(body).width
      let real-count = calc.quo((size.width - width).pt(), (width + padding).pt())
      stack(dir: ltr, spacing: padding, ..range(count-real + 1).map(_ => body))
    })
  }
}

/// Crea un resumen que no aparece en el índice (outline).
/// 
/// - body (content): Cuerpo del resumen.
/// -> content
#let resumen(body) = [
  #heading(level: 1, numbering: none, outlined: false)[Resumen]
  #body
  #pagebreak(weak: true)
]

#let abstract = resumen

/********************************
 *  Portadas
 * 
 *******************************/ 

/// Diseño de portada básico, perfecto para informes y tareas.
/// 
/// - meta (dictionary): Contenidos del archivo **meta.typ**
/// - titulo-centrado (bool): Si es que el título debería ir centrado respecto
///   a la página. Por defecto `false`.
/// -> content
#let portada1(
  meta,
  titulo-centrado: false,
) = {
  let miembros = (:)
  if type(meta.autores) == "string" {
    miembros.insert("Integrante", meta.autores)
  } else if meta.autores.len() > 0 {
    miembros.insert(
      if meta.autores.len() == 1 {
        "Integrante"
      } else {
        "Integrantes"
      },
      meta.autores
    )
  }
  miembros = miembros + meta.equipo-docente

  let header = base-header[
    #grid(columns: (auto, 1fr), rows: auto)[
      #set align(left + bottom)
      #for nombre in meta.departamento.nombre [#nombre \ ]
    ][
      #set align(right + bottom)
      #if meta.departamento.logo != none {
        image.decode(meta.departamento.logo, height: 50pt)
      }
    ]
    #v(8pt)
    #line(length: 100%, stroke: 0.4pt)
  ]

  let member-table-args = ()
  for (categoria, nombres) in miembros {
    member-table-args.push[#categoria:]
    member-table-args.push[
      #if type(nombres) == array {
        for nombre in nombres [#nombre \ ]
      } else {
        nombres
      }
    ]
  }

  let titulo = align(center, {
      set text(size: 25pt)
      if meta.titulo != none {
        meta.titulo
        linebreak()
      }
      if meta.subtitulo != none {
        meta.subtitulo
        linebreak()
      }
      if meta.tema != none {
        meta.tema
      }
    })
  
  let member-table = grid(columns: (1fr, auto), rows: auto)[][
      #grid(columns: 2, rows: auto, row-gutter: 10pt, column-gutter: 5pt, ..member-table-args)
  
      #for (nombre, fecha) in meta.fechas [
        Fecha de #nombre: #fecha \
      ]
      #meta.lugar
    ];
  
  let member-table-wrapper = {
    if titulo-centrado {
      (it) => place(bottom+right, align(top+left, it))
    } else {
      (it) => it
    }
  }

  return base-front-page(header: header)[
    #v(1fr)
    #titulo
    #v(1fr)
    #member-table-wrapper(grid(columns: (1fr, auto), rows: auto, [], member-table))
  ]
}

/** Headers
 *
 */

/// El header por defecto.
/// - meta (dictionary): Contenidos del archivo **meta.typ**
/// - romano-hasta-primer-header (bool): Si es true, las páginas antes del 
///   primer heading con numbering utilizan números romanos en minúsculas.
///   Por defecto es `true`.
/// -> content
#let header1(
  meta,
  romano-hasta-primer-heading: true
) = base-header[
  #set text(weight: 1) // typst bug?
  #grid(columns: (auto, 1fr), rows: auto)[
    #set align(left + bottom)
    #context {
      let here = here()
      let prev-headings = query(selector(heading.where(level: 1)).before(here), here)
      let post-headings = query(selector(heading.where(level: 1)).after(here), here)
      let heading-found = none
      if post-headings != () and post-headings.first().location().page() == here.page() {
        heading-found = post-headings.first()
      } else if prev-headings != () {
        heading-found = prev-headings.last()
      }

      if heading-found != none and heading-found.numbering != none {
        heading-found.body
      }
    }
  ][
    #set align(right + bottom)
    #context {
      let headings = query(heading)
      let first-numbered-heading = none
      for heading in headings {
        if heading.numbering != none {
          first-numbered-heading = heading
        }
      }

      let numbering = "i"
      if first-numbered-heading != none {
        if here().page() == first-numbered-heading.location().page() {
          counter(page).update(1)
        }
        if first-numbered-heading.location().page() <= here().page() {
          numbering = "1"
        }
      }

      context {
        counter(page).display(numbering)
      }
    }
  ]
  #v(8pt)
  #line(length: 100%, stroke: 0.4pt)
]

/** Footers
 *
 */

/// El footer por defecto.
/// - meta (dictionary): Contenido del archivo **meta.typ**'
/// -> content
#let footer1(meta) = base-footer[
  #set text(style: "italic", weight: 1)

  #line(length: 100%, stroke: 0.4pt)
  #v(8pt)
  #grid(columns: (auto, 1fr), rows: auto)[
    #set align(left + top)
    #meta.curso
  ][
    #set align(right + top)
    #meta.titulo
  ]
]

/******************************************************************************
 *     Show rules
 * 
 * Las siguientes funciones están pensadas para utilizarse como show rules de
 * la forma:
 * 
 *****************************************************************************/

/// Hace que el primer heading con numbering esté en una página nueva. Esta
/// show rule es aplicada por defecto en el template. Puede ser desactivada
/// usando el parámetro `showrules: false` en la show rule del template.
/// Puede ser reactivada agregando esta línea:
/// ```typ
/// show: primer-heading-en-nueva-pag
/// ```
///
/// - doc (content): Documento a aplicar la regla.
/// -> content
#let primer-heading-en-nueva-pag(doc) = {
  show heading: it => context {
    if counter(heading).get() == (1,) {
      pagebreak(weak: true)
      it
    } else {
      it
    }
  }
  doc
}

/**
 *
 */
#import "departamentos.typ" as departamentos
#let departamentos = departamentos


/******************************************************************************
 *      Template
 *****************************************************************************/

/// Función que aplica los estilos del template para infromes.
/// 
/// - meta (dictionary, module): Archivo `meta.typ`
/// - fuente (str): Fuente a usar en el texto.
/// - portada (function): Portada a usar.
/// - header (function): Header a usar.
/// - footer (function): Footer a usar.
/// - margenes-portada (dictionary): Márgenes de la portada.
/// - margenes (dictionary): Márgenes del documento.
/// - showrules (bool): Si es `true` se aplicarán showrules irreversibles.
///   Si se requiere más personalización se recomiendo desactivar.
/// - doc (content): Documento a aplicar el template.
/// -> content
#let report(
  meta,
  fuente: "",
  portada: portada1,
  header: header1,
  footer: footer1,
  margenes-portada: (top: 3.5cm),
  margenes: (top: 3.5cm),
  showrules: true,
  doc
) = {
  let portada-set-extra = (:)
  if margenes-portada != (:) {
    portada-set-extra.insert("margin", margenes-portada)
  }

  let author = meta.autores
  if type(meta.autores) == array {
    author = meta.autores.at(0)
  }

  set text(lang: "es", region: "cl", hyphenate: true)
  set heading(numbering: "1.")
  set par(leading: 0.5em, justify: true, linebreaks: "optimized")
  set document(author: author, date: datetime.today())
  set math.equation(numbering: "(1)")
  
  set page(header: header(meta), footer: footer(meta), margin: margenes)
  
  if portada != none {
    set page(header: [], footer: [], ..portada-set-extra)
    portada(meta)
  }

  set page(numbering: "1")

  if showrules {
    show: primer-heading-en-nueva-pag
    
    doc
  }
}
