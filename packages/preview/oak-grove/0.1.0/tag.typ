#import "@preview/elembic:1.1.1" as e
#import "meta.typ": prefix

#let tag = e.types.declare(
  "tag",
  prefix: prefix,
  fields: (
    e.field("id", str, required: true),
    e.field(
      "name",
      e.types.option(str),
      doc: "The display name for this tag. If `none`, the ID will be used.",
      default: none,
      named: false
    ),
    e.field("color", color, named: false, default: black),
  ),
  construct: default-constructor => (..args) => {
    let args-pos = args.pos()
    if args-pos.len() == 1 or args-pos.len() == 2 and type(args-pos.last()) == color {
      args-pos.insert(1, args-pos.first())
    }
    return default-constructor(..args.named(), ..args-pos)
  }
)

