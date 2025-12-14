#import "../ebnf.typ" : *

= Test: `_validate-key`

#[
  #context {
    let keys = ("sym-prod", "sym-opt", "sym-some", "sym-any", "sym-rounded")

    let counter = 1
    for k in keys {
      [=== Test #counter: key = #repr(k)]
      repr(_validate-key(k))
      counter += 1
    }
  }
]