#let float(
  content,
  align: bottom,
) = {
  place(
    align, float: true,
    box(width: 100%)[
      #if ( align == bottom){line(length: 100%, stroke:0.5pt);v(0.6em)}
      #content
      #if ( align == top){v(0.6em);line(length: 100%, stroke:0.5pt)}
    ]
  )
}