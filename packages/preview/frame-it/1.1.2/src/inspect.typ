#import "utils/encode.typ": retrieve-info-from-code, code-has-info-attached

#let lookup-frame-info(figure) = {
  assert(
    code-has-info-attached(figure.caption.body),
    message: "You can only provide figures to `lookup-frame-info`"
      + "which represent frame-it–frames",
  )

  let (
    title,
    tags,
    body,
    supplement,
    custom-arg,
  ) = retrieve-info-from-code(figure.caption.body)

  (
    title: title,
    tags: tags,
    body: body,
    supplement: supplement,
    color: custom-arg,
  )
}

#let is-frame(figure) = code-has-info-attached(figure.caption.body)
