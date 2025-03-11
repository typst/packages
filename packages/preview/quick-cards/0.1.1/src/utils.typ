// Following utility methods are from:
// https://github.com/touying-typ/touying/blob/6316aa90553f5d5d719150709aec1396e750da63/src/utils.typ#L157C1-L166C2

#let typst-builtin-sequence = ([A] + [ ] + [B]).func()
#let is-sequence(it) = {
  type(it) == content and it.func() == typst-builtin-sequence
}

#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}

/// Determine if a content is a metadata with a specific kind.
#let is-kind(it, kind) = {
  type(it.value) == dictionary and it.value.at("kind", default: none) == kind
}

/// Determine if a content is a heading in a specific depth.
///
/// -> bool
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and it.depth <= depth
}

// Following utility methods are from:
// https://github.com/typst-community/linguify/blob/b220a5993c7926b1d2edcc155cda00d2050da9ba/lib/utils.typ#L3
#let if-auto-then(val,ret) = {
  if (val == auto){
    ret
  } else { 
    val 
  }
}


// own utils

#let padright(array, targetLength)={
  for value in range(array.len(), targetLength) {
    array.insert(value, none)
  }
  return array
}
#let sequence-to-array(it) = {
  if is-sequence(it) {
    it.children.map(sequence-to-array)
  } else {
    it
  }
}

#let get-all-children(it) = {
  if it == none {
    return none
  }
  
  let children = if is-sequence(it) { it.children } else { (it,) }

  return children.map(sequence-to-array).flatten()
}