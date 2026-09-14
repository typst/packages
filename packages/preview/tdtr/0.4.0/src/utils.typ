/// some utils not directly related to tree graph

/*
  collect all metadata objects from content
  - `input`: the content to collect metadata from
  - `output`: an array of metadata values
*/
#let collect-metadata(label) = {
  if type(label) != content {
    return ()
  }

  if not label.has("children") {
    if label.func() == metadata {
      return (label.value, )
    } else {
      return ()
    }
  }

  label.children
    .fold((), (acc, child) => acc + collect-metadata(child))
}

/*
  convert content into a list representation
  - `input`:
    - `body`: the content to convert
    - `root`: only used for recursion, should not be set by users
  - `output`: the list representation of the tree
*/
#let list-from-content(body, root: []) = {
  let typ = type(body)
  if typ == str {
    return list.item(text(fill: blue)[\"#body\"])
  } else if typ == label {
    return list.item(text(fill: blue)[<#str(body)>])
  } else if typ != content {
    return list.item(text(fill: blue)[#body])
  }

  let items = []
  let fields = body.fields()
  for (k, v) in fields {
    items = items + list.item(text(fill: gray, [.] + emph(k)) + if k == "children" {
      for child in v {
        list-from-content(child)
      }
    } else {
      list-from-content(v)
    })
  }
  root = root + list.item(text(fill: red)[#body.func()] + items)

  root
}
