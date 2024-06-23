
#let header-block(
  args
) = block(
  text(weight: 200, 24pt, fill: white, args.header.article-type),
  fill: args.header.article-color,
  width: 100% ,
  inset: 10pt,
  radius: 2pt
)