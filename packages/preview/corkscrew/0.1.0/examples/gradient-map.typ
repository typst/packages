#import "/src/corkscrew.typ" as chx
#set page(height: auto, width: 40em, margin: 2em)
#import "new.typ": cool-scale, wild-scale

// everything below goes in the README example

#set block(width: 100%, height: 4em)
#block(fill: gradient.linear(..chx.gradient-map(chx.cubehelix)))
#block(fill: gradient.linear(..chx.gradient-map(cool-scale)))
#block(fill: gradient.linear(..chx.gradient-map(wild-scale)))
