#import "@preview/pinit:0.2.2": *

#set text(size: 24pt)

#show raw: it => {
  show regex("pin\d"): it => pin(eval(it.text.slice(3)))
  it
}

`print(pin1"hello, world"pin2)`

#pinit-highlight(1, 2)