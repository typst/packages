#import "@preview/valkyrie:0.2.2" as z

#let autor-schema = z.dictionary(
  (
    nombre: z.string(
      assertions: (
        z.assert.matches(
          regex("^[^,]+, [^,]+$"),
          message: (self, it) => "El nombre debe tener el formato \"Apellido, Nombre\"",
        ),
      ),
    ),
    email: z.string(
      optional: true,
      assertions: (
        z.assert.matches(
          regex("^[^@]+@[^@]+$"), // z.email() no acepta emails institucionales
          message: (self, it) => "Email inválido",
        ),
      ),
      post-transform: (self, it) => (
        user: it.split("@").at(0),
        domain: it.split("@").at(1),
      ),
    ),
    legajo: z.string(optional: true),
    notas: z.array(
      z.content(),
      default: (),
      pre-transform: z.coerce.array,
    ),
  ),
  pre-transform: z.coerce.dictionary(it => (nombre: it)),
  post-transform: (self, it) => (
    ..it,
    nombre: it.nombre.split(", ").at(1),
    apellido: it.nombre.split(", ").at(0),
  ),
)


#let formato-schema = z.dictionary((
  tipografia: z.string(default: "New Computer Modern"),
  margenes: z.choice(("simétricos", "anillado"), default: "simétricos"),
))

#let parse-options(options) = z.parse(
  options,
  z.dictionary((
    institucion: z.string(default: "unlp"),
    unidad-academica: z.string(),
    asignatura: z.content(),
    titulo: z.content(optional: true),
    equipo: z.content(optional: true),
    autores: z.array(
      autor-schema,
      pre-transform: z.coerce.array,
    ),
    titulo-descriptivo: z.string(),
    resumen: z.content(optional: true),
    fecha: z.date(pre-transform: z.coerce.date),
    formato: formato-schema,
  )),
)
