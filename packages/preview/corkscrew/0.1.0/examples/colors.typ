#import "/src/corkscrew.typ" as chx
#set page(height: auto, width: 40em, margin: 2em)
#set block(width: 2em, height: 2em)
#set grid(gutter: 0.25em)
#show grid: set block(width: 100%)
#import "new.typ": cool-scale, wild-scale

// everything below goes in the README example

#grid(
  columns: 12 * (2em,),
  ..chx
    .colors(12)
    .map(
      it => block(fill: it),
    )
)
#grid(
  columns: 12 * (2em,),
  ..chx
    .colors(12, func: cool-scale)
    .map(
      it => block(fill: it),
    )
)
#grid(
  columns: 12 * (2em,),
  ..chx
    .colors(12, func: wild-scale)
    .map(
      it => block(fill: it),
    )
)
