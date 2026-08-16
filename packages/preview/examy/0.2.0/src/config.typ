#import "types.typ": *

/// API documentation for `config` below, consumed by docs/generate-api.typ
/// (keyed by export name). The properties are introspected from the
/// element declaration; `config` is never called like a function (its
/// properties are set with `e.set_`), so no call signature is shown.
#let DOCS = (
  config: (
    kind: "element",
    show-signature: false,
    desc: "Package options. Set them with a show rule: `#show: e.set_(config, show-solutions: false, ...)`.",
  ),
)

#let config = e.element.declare(
  "config",
  prefix: PREFIX,
  doc: "Global configuration for an exam",
  display: it => panic(
    "Config should not be displayed directly; instead use `e._set` to set properties on it.",
  ),
  fields: (
    e.field(
      "show-solutions",
      e.types.option(bool),
      doc: "Whether to show solutions",
    ),
    e.field(
      "institution",
      e.types.option(content),
      doc: "The institution name, shown by `maketitle`",
    ),
    e.field(
      "exam-name",
      e.types.option(content),
      doc: "The name of the exam, shown by `maketitle`",
    ),
    e.field(
      "term",
      e.types.option(content),
      doc: "The term of the exam (e.g. Fall 2026), shown by `maketitle`",
    ),
    e.field(
      "duration",
      e.types.option(duration),
      doc: "The length of the exam, shown by `maketitle`",
    ),
    e.field(
      "show-rubric",
      e.types.option(bool),
      doc: "Whether to show a rubric",
    ),
    e.field(
      "solution-background-color",
      color,
      doc: "The background color to use for solution boxes",
      default: blue.lighten(90%),
    ),
    e.field(
      "solution-text-color",
      color,
      doc: "The text color to use for solution boxes",
      default: blue.darken(20%),
    ),
  ),
)
