#import "../ebnf.typ": *

== `_validate-opt-key`

#[
  #context {
    let keys = ("sym-prod", "sym-opt", "sym-some", "sym-any", "sym-rounded")

    let counter = 1
    for k in keys {
      [=== Test #counter: key = #repr(k)]
      repr(_validate-opt-key(k))
      counter += 1
    }
  }
]
