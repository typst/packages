#let _unique-frame-metadata-tag = "_THIS-IS-METADATA-USED-FOR-FRAME-IT-FRAMES"

// Encode info as invisible metadata so when rendered in outline, only the title is seen
#let encode-title-and-info(title, info) = (
  metadata(_unique-frame-metadata-tag) + metadata(info) + title
)
#let retrieve-info-from-code(code) = code.children.at(1).value
#let code-has-info-attached(code) = (
  "children" in code.fields().keys()
    and code.children.first().fields().at("value", default: "")
      == _unique-frame-metadata-tag
)

