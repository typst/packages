// Option: prose: "book" (first-line indent + tight paragraphs). Same body as content.typ.
#import "@preview/scholia:0.1.0": *
#show: scholia.with(prose: "book")
#include "body.typ"
