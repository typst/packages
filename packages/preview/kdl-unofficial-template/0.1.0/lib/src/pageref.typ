
#let pageref(label) = context{
  let label-loc = query(label, loc).first().location()
  let page-numbering = label-loc.page-numbering()
  if page-numbering == none { page-numbering = "1" }
  [p.~#link(label-loc, numbering(page-numbering, label-loc.page()))]
}
