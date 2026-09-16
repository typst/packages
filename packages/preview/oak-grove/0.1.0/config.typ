#import "@preview/elembic:1.1.1" as e
#import "meta.typ": prefix
#import "tag.typ": tag

#let config_t = e.types.declare(
  "config",
  prefix: prefix,
  fields: (
    e.field("tags", e.types.array(tag), named: true, default: ()),
    e.field(
      "link",
      e.types.union(str, function, none),
      doc: "If it's a string, problem IDs will be appended. Use a function that receives the problem as argument and
        returns a string for more advanced behaviour. Use `none` to disable links (default).",
      named: true,
      default: none,
    ),
    e.field("code-size", length, doc: "Font size for code.", named: true, default: 10pt),
    e.field(
      "read-func",
      e.types.option(function),
      doc: "Function that receives a filename as a string and returns the content of the file. Use `none` to disable
        reading code files (default).",
      named: true,
      default: none,
    ),
    e.field(
      "default-lang",
      e.types.option(str),
      doc: "Default programming language in which code solutions are written. This will be the extension used for
        reading files. Can be overridden with the `lang` parameter of `solution`. Cannot be `none` if `read-func` is set.",
      named: true,
      default: none
    ),
  ),
)

#let config = state("__oak_config", none)

#let set-config(..args) = doc => {
  config.update(config_t(..args))

  doc
}