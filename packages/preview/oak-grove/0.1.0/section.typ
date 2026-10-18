#import "@preview/elembic:1.1.1" as e
#import "meta.typ": prefix
#import "problem.typ": problem

#let section = e.types.declare(
  "section",
  prefix: prefix,
  fields: (
    e.field("name", str, required: true),
    e.field("problems", e.types.array(problem), named: false),
    e.field("descr", content, required: false, named: true),
    e.field("descr-sol", content, required: false, named: true),
  )
)