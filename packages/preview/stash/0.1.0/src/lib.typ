// State variable for all user-created stashes (stored as a dict).
#let stashes = state("stashes", (:))

// Create a stash by adding new key-value pair to the dict.
#let create-stash(
  name
) = {
  let insert-return(
    dict,
    key,
    value,
  ) = {
    dict.insert(key, value)
    return dict
  }

  let stash = (
    name: name,
    contents: ()
  )
  
  return stashes.update(x => insert-return(x, name, stash))
}

// Update the `stashes` dict with new content.
#let add-to-stash(
  name,
  content,
) = {
  let push-return(
    dict,
    name,
    content,
  ) = {
    dict.at(name).contents.push(content)
    return dict
  }

  return stashes.update(x => push-return(x, name, content))
}

// Print the stored content in a cycle.
#let print-stash(
  name
) = {
  for content in stashes.final().at(name).contents [
    #content
  ]
}
