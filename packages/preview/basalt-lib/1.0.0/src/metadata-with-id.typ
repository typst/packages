#import "tag.typ": tag 

#let get-metadata(content) = {
  let helper(content) = {
    let rep = repr(content)
    // Probably missing cases.
    if rep.starts-with("sequence") {
      return content.children.map(
        get-metadata
      )
    }
    if rep.starts-with("styled")  {
      return get-metadata(content.child)
    }
    if rep.starts-with("metadata") {
      return content
    }
  }

  return (content,).map(
    helper
  ).flatten().filter(it => {
    it != none
  })
}

#let id-metadata(id, data) = {
  return metadata((
    id: id,
    data: data,
  ))
}

#let metadata-with-id(content) = {
  let rep = repr(content)
  let val = content.value
  return {
    rep.starts-with("metadata")
  } and {
    type(val) == dictionary
  } and {
    val.pairs().len() == 2
  } and {
    val.keys().contains("id")
  } and {
    val.keys().contains("data")
  }
}

#let get-metadata-with-id(content) = {
  return get-metadata(
    content
  ).filter(
    metadata-with-id
  ).map(metadata => {
    metadata.value
  })
}
