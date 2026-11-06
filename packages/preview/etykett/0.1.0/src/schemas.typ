#import "@preview/valkyrie:0.2.2" as z

#let dimension = z.dictionary((
  width: z.length(),
  height: z.length(),
))

#let inset = z.either(
  z.length(default: 0pt),
  z.dictionary(
    (
      left: z.length(default: 0pt),
      right: z.length(default: 0pt),
      top: z.length(default: 0pt),
      bottom: z.length(default: 0pt),
    ),
    pre-transform: (self, it) => {
      let x = it.remove("x", default: none)
      if x != none {
        if "left" not in it { it.left = x }
        if "right" not in it { it.right = x }
      }
      let y = it.remove("y", default: none)
      if y != none {
        if "top" not in it { it.top = y }
        if "bottom" not in it { it.bottom = y }
      }
      let rest = it.remove("rest", default: none)
      if rest != none {
        if "left" not in it { it.left = rest }
        if "right" not in it { it.right = rest }
        if "top" not in it { it.top = rest }
        if "bottom" not in it { it.bottom = rest }
      }
      it
    },
  ),
)

#let sheet = z.dictionary((
  paper: z.either(
    z.schemas.papersize(),
    dimension,
  ),
  margins: inset,
  flipped: z.boolean(default: false),
  gutters: z.either(
    z.length(default: 0pt),
    z.dictionary((
      x: z.length(default: 0pt),
      y: z.length(default: 0pt),
    )),
    post-transform: (self, it) => {
      if type(it) != dictionary {
        (x: it, y: it)
      } else {
        it
      }
    },
  ),
  rows: z.integer(),
  columns: z.integer(),
))

#let sublabels = z.dictionary((
  rows: z.integer(default: 1),
  columns: z.integer(default: 1),
))
