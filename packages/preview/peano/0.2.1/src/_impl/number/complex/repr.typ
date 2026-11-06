// -> number/complex/repr.typ

#import "@preview/oxifmt:1.0.0": strfmt
#import "init.typ": from

#let /*pub*/ to-str(z) = {
  let z = from(z)
  strfmt("{re:}{im:+}i", re: z.re, im: z.im)
}