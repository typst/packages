// The showcase — compile THIS to see every Scholia device (light theme).
// The body lives in body.typ; dark.typ / book.typ wrap the same body with
// different options. (body.typ has no wrapper, so it can be shared without
// double-applying `scholia`.)
#import "@preview/scholia:0.1.0": *
#show: scholia
#include "body.typ"
