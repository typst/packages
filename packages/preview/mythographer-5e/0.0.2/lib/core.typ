#import "utils.typ"

#let fn-wrapper(fn) = [#metadata((
  kind: "fn-wrapper",
  fn: fn,
))<mark>]

#let show-content-with-warp(self: none, recaller-map: (:), new-start: true, is-first-slide: false, body) = {
  // Extract arguments
  assert(type(self) == dictionary, message: "`self` must be a dictionary")
  let slide-fn = auto
  let children = if utils.is-sequence(body) {
    body.children
  } else {
    (body,)
  }
  // convert all sequence to array recursively, and then flatten the array
  let sequence-to-array(it) = {
    if utils.is-sequence(it) {
      it.children.map(sequence-to-array)
    } else {
      it
    }
  }
  children = children.map(sequence-to-array).flatten()

  let call-slide-fn-and-reset(
    self,
    slide-fn,
  ) = {
    let cont = slide-fn(self)
    cont
  }

  // The current slide content
  let result = ()

  // Iterate over the children
  for child in children {
    // text[#type(child) #child.fields() #linebreak()]

    if utils.is-kind(child, "fn-wrapper") {
      // TIER 1 wrapped
      let cont = call-slide-fn-and-reset(
        self,
        child.value.fn,
      )
      cont
    } else if child.func() == columns {
      columns(child.at("count"))[
        #show-content-with-warp(
        self: self, recaller-map: (:), new-start: true, is-first-slide: false, child.at("body"))
      ]
    } else {
      child
    }
  }
}


