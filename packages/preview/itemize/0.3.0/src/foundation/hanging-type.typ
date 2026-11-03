#import "../util/parse-args.typ": *

#let HangingType = (
  "classic": "classic", // default
  "paragraph": "paragraph",
)

#let parse-hanging-type(
  rel-level,
  curr-level,
  level-item,
  hanging-f,
  hanging-f-e,
  hanging-item,
  args-with-tags-item,
) = {
  let hanging-type = if hanging-item != none {
    parse-general-args-with-level(
      hanging-item,
      level-item,
      none,
      0,
      ..args-with-tags-item,
    )
  } else {
    parse-general-args-with-level(
      hanging-f,
      rel-level,
      hanging-f-e,
      curr-level,
      ..args-with-tags-item,
    )
  }
  assert(
    hanging-type in HangingType,
    message: "`hanging-type` should be the following string: "
      + HangingType.keys().map(it => "\"" + it + "\"").join(last: ", ")
      + "\nbut found: "
      + repr(hanging-type),
  )
  return hanging-type
}
