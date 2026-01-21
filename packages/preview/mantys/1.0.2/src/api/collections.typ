#import "types.typ" as t
#import "values.typ" as v
#import "links.typ" as l
#import "commands.typ" as c

#let typ = (
  l
    ._builtin-map
    .keys()
    .fold(
      (:),
      (d, cmd) => {
        d.insert(cmd, c.builtin(cmd))
        d
      },
    )
    + (
      t: (t._type-map + t._type-aliases)
        .pairs()
        .fold(
          (:),
          (d, (n, v)) => {
            d.insert(n, t.dtype(v))
            d
          },
        ),
    )
    + (
      v: (
        "false": v.value(false),
        "true": v.value(true),
        "none": v.value(none),
        "auto": v.value(auto),
        "dict": v.value((:)),
        "arr": v.value(()),
      ),
    )
)
