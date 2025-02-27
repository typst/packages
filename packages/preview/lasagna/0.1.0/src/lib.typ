#let view_layer(tags: (), prefix: "lasagna_") = {
  let shown_tags = tags
  if type(shown_tags) == str {
    shown_tags = (shown_tags, )
  }
  let has_common(array1, array2) = array1.filter((elem1) => {array2.contains(elem1)}).len() > 0

  let layer(tags, body) = {

    if type(tags) == str {
      tags = (tags,)
    }
    tags = tags.map(t => prefix + t)

    if has_common(tags, shown_tags) {
      return metadata(tags) + body
    }
    else {
      let new_body = []
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
        let potential_tag = children.first()
        if potential_tag.func() == metadata and has_common(potential_tag.value, shown_tags) {
          new_body += [
            #b
          ]
        }
      }
      return new_body
    }
  }

  return layer
}

