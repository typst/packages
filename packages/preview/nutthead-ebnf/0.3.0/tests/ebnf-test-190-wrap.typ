#import "../ebnf.typ" : *

== Test: `_wrap`

#[
  #context {
    let illum = ("dimmed", "highlighted")
    let qualifier = ("opt", "some", "any")
    let bracket = ("rounded", "curly", "square", "comment")

    let counter = 1
    for i in illum {
      for q in qualifier {
        for b in bracket {
          [=== Test #counter (#repr(i), #q, #b)]
          _wrap(illumination: i, qualifier: q, bracket-type: b)[Wrapped Content]
          counter += 1
        }
      }
    }
  }
]