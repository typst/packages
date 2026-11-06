# elembic
Framework for custom elements and types in Typst. **Supports Typst 0.11.0 or later.**

**Read the book:** https://pgbiel.github.io/elembic

**Mirrors:** [GitHub (pgbiel/elembic)](https://github.com/PgBiel/elembic); [Codeberg (pgbiel/elembic)](https://codeberg.org/PgBiel/elembic)

## About

Elembic lets you create [**custom elements,**](https://pgbiel.github.io/elembic/elements/creating/index.html) which are **reusable and customizable document components,** with support for **typechecked fields, [show and set rules](https://pgbiel.github.io/elembic/elements/styling/index.html)** (without using any `state` by default!), **[reference and outline support,](https://pgbiel.github.io/elembic/elements/creating/labels-refs.html)** as well as features not present in Typst elements today such as **[revokable rules](https://pgbiel.github.io/elembic/elements/styling/revoke.html)** and **[nested element selectors](https://pgbiel.github.io/elembic/elements/filters/within.html)**. In addition, Elembic lets you create [**custom types,**](https://pgbiel.github.io/elembic/types/custom-types/index.html) which also support **typechecked fields** but also [**custom casting**](https://pgbiel.github.io/elembic/types/custom-types/casts.html), and can be used in element fields or by themselves in arbitrary Typst code.

Elembic's name comes from "element" + ["alembic"](https://en.wikipedia.org/wiki/Alembic), to indicate that one of Elembic's goals is to experiment with different approaches for this functionality, and to help shape a future update to Typst that includes native custom elements, which will eventually remove the need for using this package.

Its documentation is at the Elembic Handbook: [https://pgbiel.github.io/elembic](https://pgbiel.github.io/elembic)

This library has a few limitations which are [appropriately noted in the book.](https://pgbiel.github.io/elembic/about/limitations.html)

## Who is elembic for?

Elembic is especially suited for:
1. **Packages:** elembic's elements allows creating reusable components which can be freely customized by your package's end users. With typechecking and other features, elembic's got you covered in terms of flexibility. See the ["Simple Theorems" example](https://pgbiel.github.io/elembic/examples/simple-theorems.html) for a sample.
2. **Templates:** elembic's elements can be used for fine-grained configuration of parts of your template. See the ["Simple Thesis" example](https://pgbiel.github.io/elembic/examples/simple-thesis.html) for a sample.

## Installation

Just import the latest elembic version from the package manager and you're ready to go!

```typ
#import "@preview/elembic:1.1.0" as e

// See the full example below
#show: e.set_(element, stroke: red)
// ...
```

## Example

### Custom element

```typ
#import "@preview/elembic:1.1.0" as e: field, types

#let bigbox = e.element.declare(
  "bigbox",
  prefix: "@preview/my-package,v1",
  doc: "A fancy and customizable box.",
  display: it => block(fill: it.fill, stroke: it.stroke, inset: 5pt, it.body),
  fields: (
    field("body", types.option(content), doc: "Box contents", required: true),
    field("fill", types.option(types.paint), doc: "Box fill"),
    field("stroke", types.option(stroke), doc: "Box border", default: red)
  )
)

#bigbox[abc]

#show: e.set_(bigbox, fill: red)

#bigbox(stroke: blue + 2pt)[def]
```

!['abc' with no fill and a thin red stroke, followed by 'def' with red fill and blue thicker stroke](https://github.com/user-attachments/assets/c852cfcd-c0de-446a-999b-5ecaa44809b7)

### Custom type

```typ
#import "@preview/elembic:1.1.0" as e: field, types

#let person = e.types.declare(
  "person",
  prefix: "@preview/my-package,v1",
  doc: "Relevant data for a person.",
  fields: (
    field("name", str, doc: "Person's name", required: true, named: true),
    field("age", int, doc: "Person's age", default: 40),
    field("preference", types.any, doc: "Anything the person likes", default: none)
  ),
  casts: (
    (from: dictionary),
    (from: str, with: person => name => person(name: name)),
  )
)

#assert.eq(
  e.repr(person(name: "John", age: 50, preference: "soup")),
  "person(age: 50, name: \"John\", preference: \"soup\")"
)

// Manually invoke typechecking and cast
#assert.eq(
  types.cast((name: "abc", age: 99), person),
  (true, person(name: "abc", age: 99))
)

#assert.eq(
  types.cast("abc", person),
  (true, person(name: "abc"))
)

// Can then use 'person' as the type of an element's field, for example
```

## Source structure

- `pub/`: Contains public re-exports of each module (so we can keep some things private)
- `data`: Functions and constants related to extracting data from elements and types
- `element`: Functions related to creating and using elements and their rules (set rules, revoke rules and so on)
- `filters`: Functions to create and match element filters
- `types`: Functions and constants related to Elembic's custom type system
- `fields`: Functions related to element and type field parsing

## License

Licensed under MIT or Apache-2.0, at your option.
