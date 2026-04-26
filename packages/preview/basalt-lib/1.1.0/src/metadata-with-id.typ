#import "error-handling.typ": check-required-argument
#import "tag.typ": tag 

#let get-metadata(body) = {
  check-required-argument(get-metadata, body, "body", content)

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

  return (body,).map(
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

#let metadata-with-id(body) = {
  check-required-argument(metadata-with-id, body, "body", content)

  let rep = repr(body)
  let val = body.value
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

#let get-metadata-with-id(body) = {
  check-required-argument(get-metadata-with-id, body, "body", content)

  return get-metadata(
    body
  ).filter(
    metadata-with-id
  ).map(metadata => {
    metadata.value
  })
}
