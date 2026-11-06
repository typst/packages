#import "extra.typ"

/// Split the word and validate the variant number.
/// -> dict
#let kipisi(
  /// Word to split in the format `"word/n"` for the `n`'th variant of `"word"`
  /// -> str
  word
) = {
  let elems = word.split("/")
  let sem = (base: elems.at(0), var: none)
  for elem in elems.slice(1) {
    // If it's `int`able, we interpret it as a variant number
    let int-like = elem.clusters().all(c => "0" <= c and c <= "9")
    if int-like {
      if sem.var != none { panic("Duplicate int markers") }
      sem.insert("var", int(elem))
      continue
    }
    // Otherwise it's just a string in the options
    panic("Unimplemented: cannot segment '" + word + "'")
  }
  sem
}

