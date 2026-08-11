#import "@preview/elembic:1.1.1" as e

#let environment-body = e.element.declare(
  "environment.body",
  prefix: "@preview/lemming,v0",
  display: it => it.body,
  template: it => {
    set text(style: "italic")
    it
  },
  fields: (
    e.field("body", content, required: true),
  ),
)

#let default-display = it => block({
  strong(
    it.supplement + if it.numbering != none {
			sym.space.nobreak
			numbering(it.numbering, ..it.counter.get())
		}
  )
  if it.name != none {
    [ (#emph(it.name))]
  }
  strong(it.separator)

  environment-body(it.body)
})


#let counter-update = _ => fields => if fields.numbering != none { fields.counter.step() }
#let reference = fields => if fields.numbering != none {
  fields.supplement
  sym.space.nobreak
  numbering(fields.numbering, ..fields.counter.get())
}

#let environment = e.element.declare(
  "environment",
  prefix: "@preview/lemming,v0",
  doc: "A theorem-like environment",
  display: default-display,
  reference: (
    custom: reference,
  ),
  count: counter-update,
  template: it => {
    set block(width: 100%)
    it
  },
  synthesize: fields => {
    fields

    if fields.at("supplement", default: auto) == auto {
      (supplement: upper(fields.at("kind").at(0, default: "")) + fields.at("kind").slice(1))
    }
    (counter: counter(e.eid(fields) + fields.kind))
  },
  fields: (
    e.field(
      "name",
      e.types.option(content),
      doc: "Additional note for the environment, for example the name of a theorem.",
      required: false,
    ),
    e.field("body", content, required: true),
    e.field("kind", str, doc: "The kind of math environment.", default: "theorem", named: true),
    e.field(
      "supplement",
      e.types.smart(content),
      doc: "The word used for the environment. Defaults to the capizalized kind.",
      default: auto,
      named: true,
    ),
    e.field(
      "separator",
      content,
      doc: "The symbol between between the header and body.",
      default: [. ],
      named: true,
    ),
    e.field(
      "numbering",
      e.types.union(e.types.option(str), function),
      doc: "How to number the environment. Accepts a numbering pattern or function.",
      default: "1.1",
    ),
    e.field("counter", counter, doc: "The counter corresponding to the environment, synthesized field.", synthesized: true, default: counter(figure.where(kind: "theorem"))),
  ),
)


#let counter-name(kind) = {
  e.eid(environment) + kind
}
