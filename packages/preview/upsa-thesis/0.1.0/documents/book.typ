/// Este archivo es el responsable de generar los documentos finales para la entrega de trabajos de grado.
#import "@preview/upsa-thesis:0.1.0": (
  bime-abstract, book-front-cover, book-spine-cover, generate-biblatex, generate-hayagriva, print-layout-state,
)

/// El documento principal siendo la tesis en sí, es necesario para que se definan los datos de la tesis y que los demás documentos puedan acceder a ellos.
#document(
  "thesis.pdf",
  {
    include "thesis.typ"
    // Se necesita actualizar el formato específico de impresión a duplex o simplex si en el documento principal no se especifica.
    print-layout-state.update("duplex")
  },
)


/// Resumen del tema para el formulario de defensa: máximo 250 palabras, una plana, distinto del abstract del informe. Por consigna no menciona capítulos, antecedentes, justificación, objetivos ni conclusiones: solo de qué se trata el trabajo.
#document(
  "abstract.pdf",
  bime-abstract(
    // En el caso de que tu abstracto de la tesis sea más extenso o no esté conforme a las indicaciones de la BIME, body permite sobreescribirlo con un texto alternativo. Por defecto, se usa el abstracto de la tesis.
    // body: []
  ),
)

/// Genera la carátula de la tesis.
#document("front-cover.pdf", book-front-cover())
/// Genera el lomo de la tesis.
#document("spine-cover.pdf", book-spine-cover())

/// Genera la referencia bibliográfica en formato BibLaTeX para que otros tesistas/estudiantes puedan referenciar tu trabajo fácilmente.
#generate-biblatex(
  /// El nombre del autor es opcional pero recomendable reescribirlo en formato académico (Apellidos, Nombres) para evitar problemas de normalización. La plantilla trata de normalizarlo automáticamente pero pueden ocurrir errores de interpretación.
  author: "...",
)

/// Genera la referencia pero en formato YAML Hayagriva (de Typst).
#generate-hayagriva(
  /// Mismo caso que BibLaTeX.
  // author: "",
  /// El número de clasificación es opcional ya que la Biblioteca de la UPSA lo asigna después de la entrega del trabajo.
  call-number: "Th005.3 Ov1; CD005.3 Ov1",
)
