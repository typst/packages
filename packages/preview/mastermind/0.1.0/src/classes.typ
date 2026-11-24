#import "@preview/cetz:0.5.2"

#let class(center, name, type: none, attributes: (), methods: ()) = {
  return (
    name: name,
    type: type,
    attributes: attributes,
    methods: methods,
    center: center,
  )
}

