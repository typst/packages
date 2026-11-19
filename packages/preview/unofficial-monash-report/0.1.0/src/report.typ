#import "design.typ": *
#import "options.typ": validate, require, present
#import "common.typ": document-style
#import "page.typ": running-head, current-config
#import "cover.typ": cover
#import "frontmatter.typ": frontmatter
#let report(body, ..args) = {
  require("arguments", args.pos().len() == 0, "named options after the body")
  require("body", type(body) == content, "content")
  let o = validate("report", args.named()) + (mode: "report")
  document-style(o, [
    #cover(o)
    #if present(o.abstract) or o.keywords.len() > 0 or o.outline {
      set page(numbering: "i", header: none)
      counter(page).update(1)
      frontmatter(o)
      pagebreak()
    }
    #set page(numbering: "1", header: running-head(o))
    #counter(page).update(1)
    #body
  ])
}
#let appendix(body) = context {
  require("body", type(body) in (str, content), "str or content")
  require("appendix", current-config().mode == "report", "used inside report")
  set heading(numbering: "A.1")
  counter(heading).update(0)
  body
}
