#import "@preview/elembic:1.1.1" as e
#import e.types as t

#let secondary-gutter = t.smart(t.union(length, t.array(length), function))
#let primary-gutter = t.smart(t.union(length, function, t.array(secondary-gutter)))
#let gutter-like = t.union(secondary-gutter, primary-gutter)
#let length-like = t.smart(t.union(length, ratio, fraction))
#let grid-size-specifier = t.union(length-like, t.array(length-like), int)
#let rescale-fit = e.types.union(..("stretch", "cover").map(e.types.literal))
