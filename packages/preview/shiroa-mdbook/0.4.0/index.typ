
#import "mod.typ": *

#let cssList = ();

// ---

#h.html.with(
  lang: "en",
  dir: "ltr",
  data-has-sidebar: "",
  data-has-toc: "",
)({
  include "head.typ"
  h.body({
    include "page.typ"
  })
})

// todo: global([data-has-sidebar][data-has-toc]) v.s. :root[data-has-sidebar][data-has-toc]
