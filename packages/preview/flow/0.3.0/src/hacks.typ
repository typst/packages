// Mechanisms that are likely
// to break at some point in future.

#import "util/mod.typ": zip-dicts

/// Thought for use in show rules.
/// A show rule with this as op
/// will not be processed again
/// for the same content.
#let do-not-process(it) = {
  it.text.at(0)
  sym.zws
  it.text.slice(1)
}

/// Applies the given function
/// only in the main body.
/// This notably excludes codeblocks.
///
/// The non-main exclusion only works
/// for pickers matching more
/// than one character.
///
/// `picker` is the intended show rule selector,
/// `op` the show rule transformation.
#let only-main(picker, op) = body => {
  // skip codeblocks
  show raw: it => {
    show picker: do-not-process
    it
  }

  // but do apply to everything else
  show picker: op

  body
}

/// Gets a field from the content or returns the content itself.
#let get-or-self(it, key) = {
  // children is an array, so we ideally return an array to "fake" it
  let default = if key == "children" {
    (it,)
  } else {
    it
  }
  it.fields().at(key, default: default)
}

/// Extracts the approximate text
/// contained in a `content`.
#let reconstruct-text(it) = {
  // idea: take the `text` fields from the children
  // and join them together
  let it = ("body", "children")
    .fold(it, get-or-self)
    // space does not have a text field. it's just empty
    // but we'd still like to have it represented in the return value
    // hence: default to the text = space if a node does not contain text
    .map(seq => (text: " ") + seq.fields())

  zip-dicts(..it)
    .at("text", default: ("",))
    .join()
}
