#import "@preview/elembic:1.1.1" as e
 #import "append.typ": append

#let proof = e.element.declare(
	"proof",
	prefix: "@preview/lemming,v0",
	doc: "A proof environmet",
	template: it => context if sys.version >= version(0, 15) and target() == "html" {
		html.elem("math-proof", attrs: (style: "display: block"), it)
	} else {
		block(width: 100%, breakable: true, it)
	},
	display: it => {
		emph(it.supplement)
		it.separator
		append(it.body, it.qed)
	},
	fields: (
		e.field("body", content, required: true),
		e.field("supplement", content, doc: "The term before the proof body.", default: "Proof", named: true),
		e.field("separator", content, doc: "The symbol between proof supplement and body.", default: [. ], named: true),
		e.field("qed", e.types.option(content), doc: "The Symbol to insert after the body.", default: $square$),
	)

)