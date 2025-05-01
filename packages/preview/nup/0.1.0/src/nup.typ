#import "@preview/shadowed:0.2.0": shadowed

#let include-page(x, shadow: true, shadow-args: (:), rect-args: (:)) =  {
  let cell = grid.cell(
    image(x, width: auto, height: auto),
  )
  if shadow { 
  let default-args = (
  fill: white,
  radius: 0pt,
  inset: 0pt,
  clip: false,
  shadow: 4pt,
  color: luma(50%))
  
  shadowed(
    ..default-args, 
    ..shadow-args)[#cell]
    
} else { 
  rect(stroke: none, inset: 0pt, ..rect-args)[#cell]
}
}
  
#let nup(layout, pages, gutter: 0.1cm, shadow: true, shadow-args: (:), rect-args: (:), page-args: (:)) = {

  let  default-page = (paper:"a4", margin:1cm, flipped:true, 
                       background:rect(width:100%, height:100%, fill: luma(95%)))

  set page(..default-page, ..page-args)
  
  let (nrow, ncol) = layout.split("x")
  let n = pages.len()
  context {
align(center + horizon,
grid(
  columns: (auto, )*int(ncol),
  rows:   ((page.width - 2*page.margin - (int(nrow)-1)*gutter)/int(nrow), )*int(nrow),
  gutter: gutter,
  ..pages.map(include-page.with(shadow: shadow, shadow-args: shadow-args, rect-args: rect-args))
)
)
}
}
