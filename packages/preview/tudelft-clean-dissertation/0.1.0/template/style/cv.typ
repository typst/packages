// some set and styling rules for the CV page
#let curriculum-vitae(doc) = {
  // algn the H1 heading to right side
  show heading.where(level: 1): it => align(right, it)
  

  // adjust the way tables are shown (use for date:event format)
  set table(
    stroke: none,
    gutter: 0.2em,
  ) 

  v(1.5cm) // add some whitespace
  [
    #set text(size:1.8em)
    = Curriculum Vitae
  ]
  v(1cm)
  doc
}