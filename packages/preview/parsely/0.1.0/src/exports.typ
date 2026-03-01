#import "parse.typ": parse
#import "match.typ": match, slot, tight, loose
#import "render.typ": render, render-spans
#import "util.typ" as util: walk, node-depths, stringify
#import "common.typ"


#let render-debug(it, grammar) = {
  let (tree, rest) = parse(it, grammar)
  box(render-spans(tree, grammar))
  text(red, rest)
}