#import "@preview/elembic:1.1.1" as e
#import "meta.typ": prefix

#let solution = e.types.declare(
  "solution",
  prefix: prefix,
  fields: (
    e.field("title", e.types.union(content, none), default: none, named: true),
    e.field("descr", e.types.union(content, none), default: none, required: false, named: true),
    e.field(
      "body",
      doc: "Either a raw text block OR `auto` to obtain the code from a file. If you want to put content other than code, use `descr`.",
      e.types.union(content, auto),
      required: true,
      named: false,
    ),
    e.field(
      "lang",
      e.types.option(str),
      doc: "String used for the file extension of the solution (if using auto) and syntax highlighting. If `none`,
            the default language specified in `config` is used.",
      named: true,
      default: none,
    ),
  ),
)
