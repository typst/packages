#let is-frame(figure) = {
  import "utils/encode.typ": code-has-info-attached
  (
    "caption" in figure.fields()
      and "body" in figure.caption.fields()
      and code-has-info-attached(figure.caption.body)
  )
}

#let lookup-frame-info(figure) = {
  import "utils/encode.typ": retrieve-info-from-code

  assert(
    is-frame(figure),
    message: "You can only provide figures to `lookup-frame-info`"
      + "which represent frame-it–frames",
  )

  let (
    title,
    tags,
    body,
    supplement,
    custom-arg,
    style,
  ) = retrieve-info-from-code(figure.caption.body)

  (
    title: title,
    tags: tags,
    body: body,
    supplement: supplement,
    color: custom-arg,
  )
}
