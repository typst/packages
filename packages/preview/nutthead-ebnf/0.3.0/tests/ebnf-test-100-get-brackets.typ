#import "../ebnf.typ": *

== `_get-brackets(kind)`

#[
  #context {
    let keys = ("comment", "curly", "rounded", "square")

    let counter = 1
    for k in keys {
      [=== Test #counter: key = #repr(k)]
      repr(_get-brackets(k))
      counter += 1
    }
  }
]
