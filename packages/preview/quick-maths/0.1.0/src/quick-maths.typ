// Element function for sequences
#let sequence = $a b$.body.func()

// Convert content to an array of its children
#let to-children(content) = {
  if type(content) == str {
    content.clusters().map(char => [#char])
  } else if content.has("children") {
    content.children
  } else if content.has("text") {
    to-children(content.text)
  } else if content.func() == math.equation {
    to-children(content.body)
  }
}

// Convert shorthands in the given sequence to their respective replacements.
#let convert-sequence(seq, shorthands) = {
  let is-sequence = type(seq) == content and seq.func() == sequence
  if not is-sequence { return seq }
  
  let children = seq.children.map(c => convert-sequence(c, shorthands))
  if children.len() == 0 {
    return seq
  }
  
  for shorthand in shorthands {
    let components = to-children(shorthand.first())
    let start = 0
    
    while start < children.len() {
      let pos = children.slice(start).position(c => c == components.first())
      if pos == none {
        break
      } else {
        pos = start + pos // Position of first matching character
        start = pos + 1 // Start index for finding next match 

        // Check whether all components of the shorthand match
        let matches = range(components.len()).all(i => {
          let child = children.at(pos+i, default: none)
          child == components.at(i)
        })
        
        if matches {
          // Remove shorthand and insert replacement
          for i in range(components.len()) { children.remove(pos) }
          children.insert(pos, shorthand.last())
        }
      }
    }
  }
  
  return children.join()
}

// A template that converts the given shorthands to their respective replacement.
//
// Parameters:
// - shorthands: One or more tuples of the form `(shorthand, replacement)`.
// - body: The body to apply the template on.
//
// Returns: The body with evaluated shorthands. 
#let shorthands(..shorthands, body) = {
  let shorthands = shorthands.pos()

  show math.equation: eq => {
    show sequence: seq => {
      let new = convert-sequence(seq, shorthands)
      if new != seq { new } else { seq }
    }

    eq
  }

  body
}
