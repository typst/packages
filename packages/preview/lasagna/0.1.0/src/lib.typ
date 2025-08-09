#let view-layer(tags: (), prefix: "lasagna_") = {
  let shown-tags = tags
  if type(shown-tags) == str {
    shown-tags = (shown-tags, )
  }
  let has-common(array1, array2) = array1.filter((elem1) => {array2.contains(elem1)}).len() > 0

  let layer(tags, body) = {

    if type(tags) == str {
      tags = (tags,)
    }
    tags = tags.map(t => prefix + t)

    if has-common(tags, shown-tags) {
      return metadata(tags) + body
    }
    else {
      let new-body = []
      if not body.has("children") {
        return
      }
      for b in body.children {
        if not b.has("children") {
          continue
        }
        let children = b.at("children")
        if children.len() == 0 {
          continue
        }
        let potential-tag = children.first()
        if potential-tag.func() == metadata and has-common(potential-tag.value, shown-tags) {
          new-body += [
            #b
          ]
        }
      }
      return new-body
    }
  }

  return layer
}

