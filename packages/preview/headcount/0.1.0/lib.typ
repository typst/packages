#let reset-counter(counter, levels: 1) = it => {
  if it.level <= levels { counter.update((0,)) }
  it
}

#let normalize-length(array, length) = {
  if array.len() > length {
    array = array.slice(0, length)
  } else if array.len() < length {
    array += (length - array.len())*(0,)
  }

  return array
}

#let dependent-numbering(style, levels: 1) = n => { numbering(style, ..normalize-length(counter(heading).get(), levels), n) }
