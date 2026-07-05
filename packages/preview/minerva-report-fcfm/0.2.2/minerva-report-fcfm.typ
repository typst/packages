/** minerva-article.typ
 *
 * Este archivo contiene la estructura y estilos usados por el template.
 * Para definir tus propios comandos agrégalos a preamble.typ.
 *
 **/

/******************************************************************************
 *           Estado
 *
 * Variables de estado utilizadas por el template.
 *****************************************************************************/
#import "state.typ" as state
#let state = state

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
    state.is-main.update(true)
    it
    counter(page).update(0)
  })
}

/******************************************************************************
 *           Localización
 *
 * Las siguientes son funciones de utilidad general para mejor
 * soporte del español.
 ******************************************************************************/
/// Arreglo con los nombres de meses en español.
#let meses = ("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio",
              "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

/// Aplica el formato "[day] de [month repr: long] del [year]" en español
/// 
/// fecha (datetime): fecha a dar formato.
/// -> str
#let formato-fecha(fecha) = {
  return str(fecha.day()) + " de " + meses.at(fecha.month()-1) + " de " + str(fecha.year())
}

/// Show rule que cambia el formato de los números para usar coma decimal.
///
/// doc (content): documento a aplicar reglas
/// -> content
#let formato-numeros-es(doc) = {
  // https://github.com/typst/typst/issues/1093#issuecomment-1536620129
  show math.equation: it => {
    show regex("\d+.\d+"): it => {
      show ".": {","+h(0pt)}
      it
    }
    it
  }
  
  doc
}

/// Esta show rule cambia los operadores definidos por Typst para
/// que estén en español.
///
/// - doc (content): Contenido a aplicar las reglas.
/// -> content
#let operadores-es(doc) = {
  show math.op.where(text: [#"inf"]): it => {
    show "inf": "ínf"
    it
  }
  show math.op.where(text: [#"lim"]): it => {
    show "lim": "lím"
    it
  }
  show math.op.where(text: [#"lim\u{2009}inf"]): it => {
    show "lim\u{2009}inf": "lím\u{2009}ínf"
    it
  }
  show math.op.where(text: [#"lim\u{2009}sup"]): it => {
    show "lim\u{2009}sup": "lím\u{2009}sup"
    it
  }
  show math.op.where(text: [#"max"]): it => {
    show "max": "máx"
    it
  }
  show math.op.where(text: [#"min"]): it => {
    show "min": "mín"
    it
  }

  doc
}

/******************************************************************************
 *           Componentes
 *
 * Estas funciones generan componentes para usarse como parte del documento.
 ******************************************************************************/
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

/******************************************************************************
 *           Portadas
 * 
 ******************************************************************************/ 

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
  if type(meta.autores) == str {
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
        image(bytes(meta.departamento.logo), height: 50pt)
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

/******************************************************************************
 *           Headers
 *
 ******************************************************************************/

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
      let loc = here()
      let post-headings = query(selector(heading.where(level: 1, outlined: true)).after(loc))
      let heading-found = none
      if post-headings != () and post-headings.first().location().page() == loc.page() {
        heading-found = post-headings.first()
      } else {
        let prev-headings = query(selector(heading.where(level: 1, outlined: true)).before(loc))

        if prev-headings != () {
          heading-found = prev-headings.last()  
        }
      }

      if heading-found != none and heading-found.numbering != none {
        heading-found.body
      }
    }
  ][
    #set align(right + bottom)
    #context {
      let headings = query(heading.where(outlined: true))
      let first-numbered-heading = headings.at(0, default: none)

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

/******************************************************************************
 *           Footers
 *
 ******************************************************************************/

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
 *           Show rules
 * 
 * Las siguientes funciones están pensadas para utilizarse como show rules de
 * la forma `show: funcion`
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

/// Permite que el documento compile aún si hay referencias rotas,
/// mostrando un mensaje en lugar de la referencia.
///
/// - mensaje (content): Mensaje a mostrar.
/// - doc (content): Documento a aplicar la regla.
/// -> content
#let permite-ref-rotas(mensaje: text(fill: red, "<ref>"), doc) = {
  show ref: it => {
    if it.element == none {
      mensaje
    }
  }
  doc
}

/// Permite que el documento compile aún si hay referencias rotas,
/// pero solo si el archivo que se está compilando no es el `main.typ`.
/// Esto es validado utilizando el estado `state("minerva.is-main")`.
/// 
/// - mensaje (content): Mensaje a mostrar.
/// - doc (content): Documento a aplicar la regla.
/// -> content
#let permite-ref-rotas-fuera-de-main(mensaje: text(fill: red, "<ref>"), doc) = {
  show ref: it => context {
    if state.is-main.get() {
      return it
    }
    if it.element == none {
      mensaje
    }
  }
  doc
}

/// Aplica los estilos por defecto a las figuras con alguno de los `kind`
/// especificados.
///
/// kind-target (array): Lista de strings con los kind a afectar.
/// doc (content): Documento a aplicar las reglas.
/// -> content
#let estilos-figure(kind-target: ("image", "table"), doc) = {
  let style-acc = (it) => it
  for kind in kind-target {
    style-acc = (it) => {
      show figure.where(kind: kind): set block(width: 80%)
      it
    }
  }
  style-acc(doc)
}

/******************************************************************************
 *           Departamentos
 * 
 * Se define en otro archivo por limpieza, y se importa como `module` para
 * tener autocompletado.
 ******************************************************************************/
#import "departamentos.typ" as departamentos
#let departamentos = departamentos


/******************************************************************************
 *           Template
 *
 *****************************************************************************/

/// Función que aplica los estilos del template para infromes.
/// 
/// - meta (dictionary, module): Archivo `meta.typ`.
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

  set document(title: meta.titulo, author: meta.autores, date: datetime.today())
  set page(header: header(meta), footer: footer(meta), margin: margenes)
  set text(lang: "es", region: "cl", hyphenate: true)

  set heading(numbering: "1.")
  set par(leading: 0.5em, justify: true, linebreaks: "optimized")
  
  set math.equation(numbering: "(1)")

  show figure.where(kind: table): set block(width: 80%)
  show figure.where(kind: image): set block(width: 80%)
  
  if portada != none {
    set page(header: [], footer: [], ..portada-set-extra)
    portada(meta)
  }

  set page(numbering: "1")

  if showrules {
    show: primer-heading-en-nueva-pag
    show: operadores-es
    
    doc
  }
}

/// Esta show rule es para utiliza en archivos que no sean `main.typ`,
/// con la idea es permitir que estos archivos sean compilables por separado.
/// Esto es útil para mantener el proyecto ordenado, como también si el documento
/// es demasiado grande como para que la webapp compile en tiempo real.
/// Esta show rules no tienen ningún efecto si el archivo a compilar es `main.typ`.
///
/// - doc (content): Documento a aplicar la regla.
/// -> content
#let subfile(doc) = {
  show: permite-ref-rotas-fuera-de-main
  
  doc
}
