#import "/src/htmlx.typ": *

#let _remove-spacer = {
  let valid-values = ("true": true, "false": false)
  let value = sys.inputs.at("moodular-remove-spacer", default: "false")
  assert(value in valid-values, message: "`--input moodular-remove-spacer` must be true or false")
  state("__moodular_remove-spacer", valid-values.at(value))
}

#let remove-spacer(value) = _remove-spacer.update(value)

#let spacer = elem("p", class: "c4l-spacer")

#let container(
  element: "div",
  name,
  aria-label,
  ..args,
) = {
  assert(args.pos().len() <= 1)
  assert(args.named().values().all(v => type(v) == bool))
  let body = args.pos().at(0, default: none)
  let variants = args.named().pairs().filter(array.last).map(array.first)

  let classes = (
    "c4lv-" + name,
    ..variants.map(v => "c4l-" + v + "-variant")
  )

  context if not _remove-spacer.get() { spacer }
  show: elem.with(
    element,
    class: classes.join(" "),
    aria-label: aria-label,
  )

  body
}
