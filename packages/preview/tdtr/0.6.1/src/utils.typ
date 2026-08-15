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
      return (label.value,)
    } else {
      return ()
    }
  }

  label.children.fold((), (acc, child) => acc + collect-metadata(child))
}

/*
  collect all labels from content
  - `input`: the content to collect labels from
  - `output`: an array of label values
*/
#let collect-label(label) = {
  if type(label) != content {
    return ()
  }

  for (k, v) in label.fields() {
    if k == "children" {
      for child in v {
        (..collect-label(child),)
      }
    } else if k == "label" {
      (str(v),)
    } else {
      collect-label(v)
    }
  }
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
    items = (
      items
        + list.item(
          text(fill: gray, [.] + emph(k))
            + if k == "children" {
              for child in v {
                list-from-content(child)
              }
            } else {
              list-from-content(v)
            },
        )
    )
  }
  root = root + list.item(text(fill: red)[#body.func()] + items)

  root
}

/*
  array set function with auto filling empty arrays
  - `input`:
    - `arr`: input array to be set
    - `indices`: an array of indices specifying the position to be set
    - `value`: value to be set
  - `output`:
    - `ret`: output array having been set
*/
#let array-set(arr, indices, value) = {
  if (indices.len() == 0) {
    arr = value
  } else {
    // fill in empty arrays until in bound
    let index = indices.at(0)
    for i in range(arr.len(), index + 1) {
      arr = arr + ((),)
    }
    arr.at(index) = array-set(arr.at(index), indices.slice(1), value)
  }
  arr
}
