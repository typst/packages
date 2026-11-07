#import "typeface.typ": typefaces

// Define la configuración general de la plantilla.
#let settings(
  /// Nombre del estudiante autor del trabajo de grado.
  author-name: none,
  /// Correo electrónico del estudiante autor del trabajo de grado.
  author-email: none,
  /// Número de registro del estudiante autor del trabajo de grado.
  author-university-id: none,
  /// Afiliación factultativa institucional.
  faculty: none,
  /// Acroónimo de la facultad.
  faculty-acronym: none,
  /// Nivel del grado académico a optar.
  degree-level: none,
  /// Programa académico (carrera o especialidad) del grado a optar.
  degree-program: none,
  /// Nombre del/os asesor/es o guía/s del trabajo de grado.
  supervisor: none,
  /// Título del trabajo de grado.
  work-title: none,
  /// Abstracto o resumen del trabajo de grado.
  abstract: none,
  /// Fecha de presentación del trabajo de grado (usualmente solo se necesita el año).
  date: none,
  /// Palabras clave del trabajo de grado.
  keywords: none,
  /// Modalidad del trabajo de grado (por ejemplo: Proyecto de Grado, Tesis, Trabajo Dirigido, etc.)
  modality: none,
  /// Abreviatura de la modalidad del trabajo de grado (por ejemplo: PG, TL, TD, etc.)
  modality-acronym: none,
  /// Nombre de un conjunto predefinido. Si se omiten ambas opciones, se usa Alegreya.
  typeface: none,
  /// Conjunto personalizado con text, display, math y mono. Usar en lugar de typeface.
  typeface-options: none,
  /// El formato de impresión del documento.
  ///
  /// - "screen" para PDF (márgenes simétricos).
  /// - "duplex" para impresión a doble cara.
  /// - "simplex" para impresión a una cara.
  print-layout: "screen",
  /// El tamaño de papel a usar. Por defecto es "us-letter" (carta), pero puede ser cambiado a "a4" (A4) si se desea.
  paper-size: "us-letter",
  /// Si el documento necesita ser dividido en partes (por ejemplo, tesis de doctorado), en lugar de solo capítulos.
  multi-part: false,
  /// Tomos o volúmenes del trabajo de grado, si aplica. Por defecto es "none".
  volumes: none,
  body,
) = context {
  import "info.typ"

  info.supervisor.update(supervisor)
  info.degree-program.update(degree-program)
  info.degree-level.update(degree-level)
  assert(
    abstract != none,
    message: "El resumen o abstracto del trabajo de grado (abstract) es obligatorio.",
  )
  info.work-abstract.update(abstract)

  assert(
    faculty != none,
    message: "La facultad (faculty) es obligatoria.",
  )
  info.faculty.update(faculty)

  assert(
    faculty-acronym != none,
    message: "El acrónimo de la facultad (faculty-acronym) es obligatorio.",
  )
  info.faculty-short.update(faculty-acronym)

  assert(
    modality != none,
    message: "La modalidad del trabajo de grado (modality) es obligatoria.",
  )
  info.thesis-modality.update(modality)

  assert(
    modality-acronym != none,
    message: "El acrónimo de la modalidad del trabajo de grado (modality-acronym) es obligatorio.",
  )
  info.thesis-modality-short.update(modality-acronym)

  info.multi-part.update(multi-part)

  assert(
    date != none and type(date) == std.datetime,
    message: "La fecha de presentación del trabajo de grado (date) es obligatoria y debe ser un objeto de tipo std.datetime, no: "
      + repr(type(date))
      + ".",
  )
  info.work-date.update(date)
  info.volumes.update(volumes)

  let paper-sizes = ("us-letter", "a4")
  assert(
    paper-size in paper-sizes,
    message: "El tamaño de papel (paper-size) debe ser uno de los siguientes: "
      + paper-sizes.join(", ", last: " o ")
      + ".",
  )
  info.paper-size.update(paper-size)

  assert(
    typeface == none or typeface-options == none,
    message: "Usá solo una opción: typeface para un conjunto predefinido o typeface-options para uno personalizado.",
  )

  let font-family = if typeface-options == none {
    if typeface == none { "Alegreya" } else { typeface }
  }
  let selected-typeface = if typeface-options == none {
    assert(
      type(font-family) == str and font-family in typefaces,
      message: "El parámetro typeface debe ser uno de los siguientes: "
        + typefaces.keys().join(", ", last: " o ") + ".",
    )
    typefaces.at(font-family)
  } else {
    assert(type(typeface-options) == dictionary, message: "typeface-options debe ser un diccionario.")
    let roles = ("text", "display", "math", "mono")
    let missing = roles.filter(role => role not in typeface-options)
    assert(missing.len() == 0, message: "Faltan estas claves en typeface-options: " + missing.join(", ", last: " y ") + ".")
    for role in roles {
      let options = typeface-options.at(role)
      let field = "typeface-options." + role
      assert(type(options) == dictionary, message: field + " debe ser un diccionario.")
      assert("font" in options, message: "Falta " + field + ".font.")
      let font = options.font
      assert(
        type(font) == str or (type(font) == array and font.len() > 0 and font.all(name => type(name) == str)),
        message: field + ".font debe ser un nombre de fuente o una lista de nombres.",
      )
      assert(role == "display" or "size" in options, message: "Falta " + field + ".size (por ejemplo, 11pt).")
      if "size" in options {
        assert(type(options.size) == length, message: field + ".size debe ser una longitud (por ejemplo, 11pt).")
      }
    }
    typeface-options
  }

  info.font.update(selected-typeface)
  info.font-family.update(font-family)

  let print-layout-options = ("screen", "duplex", "simplex")
  assert(
    info.print-layout.final() in print-layout-options,
    message: "El formato de impresión (print-layout) debe ser: " + print-layout-options.join(", ", last: " o ") + ".",
  )
  info.print-layout.update(print-layout)
  // let print-layout = info.print-layout.final()

  assert(
    author-name != none,
    message: "El nombre del autor (author-name) es obligatorio.",
  )
  assert(
    type(author-name) == str,
    message: "El nombre del autor (author-name) debe ser un texto (str), no: " + repr(type(author-name)) + ".",
  )
  info.author-name.update(author-name)

  assert(
    author-email != none,
    message: "El correo electrónico del autor (author-email) es obligatorio.",
  )
  info.author-email.update(author-email)

  assert(
    author-university-id != none,
    message: "El número de registro del autor (author-university-id) es obligatorio.",
  )
  info.author-uni-id.update(author-university-id)

  assert(
    work-title != none,
    message: "El título del trabajo de grado (work-title) es obligatorio.",
  )
  info.work-title.update(work-title)

  info.keywords.update(keywords)

  set document(
    title: work-title,
    description: abstract,
    author: author-name,
    keywords: keywords,
  )

  set text(
    lang: "es",
    region: "bo",
  )

  let page-margins(paper-size, print-layout) = {
    let a4 = paper-size == "a4"

    let normal = if a4 { 25mm } else { 1in }
    let binding = if a4 { 35mm } else { 1.4in }

    if print-layout == "screen" {
      normal
    } else if print-layout == "duplex" {
      (
        inside: binding,
        outside: normal,
        top: normal,
        bottom: normal,
      )
    } else {
      (
        left: binding,
        right: normal,
        top: normal,
        bottom: normal,
      )
    }
  }

  set page(
    // Art. 142: Márgenes
    // Los márgenes serán 4 cm para el izquierdo, y 2.5 cm para el resto (incluye la numeración de página [por defecto en Typst])
    margin: page-margins(paper-size, print-layout),
    // Art. 137: Tipo de hoja
    // El tipo de hoja será papel bond blanco, de 75 g, tamaño carta (us-letter) en posición vertical.
    paper: paper-size,
    // Art. 138: Numeración
    // La numeración de las páginas será arábiga correlativa, sin límites, en la esquina inferior derecha, para el desarrollo del trabajo; y romana con minúscula para la presentación, prólogo e índice/s.
    number-align: bottom + right,
  )

  body
}

