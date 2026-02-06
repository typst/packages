/** glossary.typ
 *
 * Write the glossary (sanasto) of your work here, into the typst
 * [dictionary] glossary_words. Each entry in the dictionary
 * needs to contain the keys name and description. The glossary
 * will be sorted according to the entry keys.
 *
 * [dictionary]: https://typst.app/docs/reference/foundations/dictionary/
 *
***/

#import "../preamble.typ": *

#let glossary_words = (
	scalar: (
		name: $s$,
		description: [
			Lower-case italic letters denote scalars.
		]
	),
	vector: (
		name: $vector(v)$,
		description: [
			Bold upright lower-case letters denote vectors.
		]
	),
	matrix: (
		name: $matrix(M)$,
		description: [
			Upright bold capital letters denote matrices.
		]
	),
	tut: (
		name: "TUT",
		description: "Tampere University of Technology"
	),
	tuni: (
		name: "TUNI",
		description: "Tampere University"
	),
	julia: (
		name: "Julia",
		description: [
			A high-level, dynamically typed general-purpose
			programming language. Julia is compiled via LLVM into
			native code which makes it fast.
		]
	),
)
