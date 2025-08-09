// courtesy of https://github.com/jbirnick/typst-headcount/blob/d796ab0294d608f9746f3609a71d80b9a93499b8/lib.typ
#let normalize-length(array, length) = {
  if array.len() > length {
    array = array.slice(0, length)
  } else if array.len() < length {
    array += (length - array.len())*(0,)
  }

  return array
}

#let dependent-numbering(style, levels: 1) = n => { numbering(style, ..normalize-length(counter(heading).get(), levels), n) }


// courtesy of https://github.com/jneug/typst-tools4typst/blob/32f774377534339f7bd073133fded363cb4a200f/src/get.typ#L176-L196
// removed type() == "string" comparison
#let dict-merge(..dicts) = {
  if dicts.pos().all(v => std.type(v) == dictionary) {
  // if all-of-type("dictionary", ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

