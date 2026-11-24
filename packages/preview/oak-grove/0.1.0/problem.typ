#import "@preview/elembic:1.1.1" as e
#import "meta.typ": prefix
#import "solution.typ": solution
#import "config.typ": config
#import "utils.typ": istype

#let problem = e.types.declare(
  "problem",
  prefix: prefix,
  fields: (
    e.field("name", str, required: true),
    e.field("id", e.types.union(str, none), default: none, named: false),
    e.field(
      "sol",
      e.types.union(none, e.types.array(e.types.union(solution, content, auto)), solution, content, auto),
      doc: "Use `auto` to obtain the solution code from a separate file.",
      default: none,
      named: false,
    ),
    e.field("descr", content, required: false, named: true),
    e.field(
      "descr-sol",
      content,
      doc: "Content to be insert right after the problem header in the solutions section, but before any solutions of this problem.",
      required: false,
      named: true,
    ),
    e.field("tags", e.types.union(str, e.types.array(str), none), default: none, named: true),

    e.field("color", e.types.option(color), named: true, default: none),
    e.field("author", e.types.option(str), named: true, default: none),
  ),
  construct: default-constructor => (..args) => {
    let args-pos = args.pos()

    let name = args-pos.first()
    let id
    let sol
    let second = args-pos.at(1, default: none)
    let third = args-pos.at(2, default: none)
    if type(second) == str {
      id = second
      if type(third) != none {
        sol = third
      }
    } else if second != none {
      sol = second;
      if type(third) == str {
        id = third;
      }

    }

    return default-constructor(name, id, sol, ..args.named())
  }
)
