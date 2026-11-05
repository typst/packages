#import "/data/config.typ": default-print-config
#import "/utils/utils.typ": show-if-has-match

#let heh-outline-page(
  print-config-fn: default-print-config,
) = {
  let print-config = print-config-fn()
  let outlines = print-config.outlines

  if (outlines != none and outlines != ()) {
    for o in outlines {
      show-if-has-match(
        selector: o.target,
        to-show: outline.with(title: o.title, target: o.target),
      )
    }
    pagebreak()
  }
}
