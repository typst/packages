#import "/data/config.typ": default-print-config

#let heh-blank-page(
  print-config-fn: default-print-config,
) = {
  let print-config = print-config-fn()
  let show-blank-page = print-config.show-blank-page

  if (show-blank-page) {
    pagebreak()
  }
}
