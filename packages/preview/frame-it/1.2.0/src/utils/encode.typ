#let _unique-frame-metadata-tag = "_THIS-IS-METADATA-USED-FOR-FRAME-IT-FRAMES"

// Encode info as invisible metadata so when rendered in outline, only the title is seen
#let encode-title-and-info(title, tags, body, supplement, custom-arg, style) = {
  let info = (
    title: title,
    tags: tags,
    body: body,
    supplement: supplement,
    custom-arg: custom-arg,
    style: style,
  )
  // Add "" so when title is `none`, result still has type 'sequence'
  metadata((_unique-frame-metadata-tag, info)) + "" + title
}
#let retrieve-info-from-code(code) = code.children.first().value.at(1)
#let code-has-info-attached(code) = (
  code != none
    and "children" in code.fields()
    and code.children.first() != none
    and code
      .children
      .first()
      .fields()
      .at("value", default: ())
      .at(0, default: "")
      == _unique-frame-metadata-tag
)

