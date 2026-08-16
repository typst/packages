<h1 align="center">gairm-import</h1>

<p align="center">
  <a href="https://typst.app/universe/package/gairm-import"><img alt="gairm-import on Typst Universe" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fgairm-import&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/releases"><img alt="Latest GitHub release version of gairm-import" src="https://img.shields.io/github/v/release/smur89/gairm-import?style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/actions/workflows/build.yml"><img alt="GitHub Actions build workflow status on the gairm-import main branch" src="https://img.shields.io/github/actions/workflow/status/smur89/gairm-import/build.yml?style=flat-square"></a>
  <a href="LICENSE"><img alt="MIT license badge linking to the gairm-import LICENSE file" src="https://img.shields.io/github/license/smur89/gairm-import?style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/stargazers"><img alt="Number of GitHub stargazers for gairm-import" src="https://img.shields.io/github/stars/smur89/gairm-import?style=flat-square"></a>
</p>

<p align="center">
  <strong>JSON Schema → Typst dict coercer.</strong>
  <br>
  Validate a JSON document against a JSON Schema (draft&nbsp;7 subset) and
  return a normalised Typst dict ready for downstream rendering. Ships with
  the <a href="https://jsonresume.org/schema">JSON Resume</a> schema and
  convenience entry points as the canonical bundled example.
</p>

<p align="center">
  <sub><em>"gairm" is Irish for vocation. The package was originally a JSON Resume loader.</em></sub>
</p>

## Contents

- [Highlights](#highlights)
- [Requirements](#requirements)
- [Quick start](#quick-start)
  - [Bring your own schema](#bring-your-own-schema)
  - [API at a glance](#api-at-a-glance)
- [Usage](#usage)
  - [Loading the document](#loading-the-document)
  - [The returned model](#the-returned-model)
  - [Rendering with a template](#rendering-with-a-template)
- [Errors](#errors)
  - [Handling validation errors yourself](#handling-validation-errors-yourself)
  - [Null handling](#null-handling)
- [Schemas and composition](#schemas-and-composition)
  - [Two schemas](#two-schemas)
  - [Format validation](#format-validation)
  - [Building an extension schema](#building-an-extension-schema)
  - [Targeted edits with lenses](#targeted-edits-with-lenses)
  - [Inspecting a schema](#inspecting-a-schema)
  - [JSON Pointer interop](#json-pointer-interop)
  - [Starting from a JSON Schema document](#starting-from-a-json-schema-document)
- [Contributing](#contributing)
- [License](#license)

## Highlights

- Strict validation with path-qualified error reports and "did you mean …?" hints.
- One-call `parse` that validates and coerces in a single step, or split via `validate` and `coerce`.
- Two flavours of the canonical JSON Resume schema: a faithful 1:1 derivation and a renderer-friendly strict variant.
- Bring your own JSON-Schema-shaped document via the `schema:` keyword — the engine is JSON-Schema-driven, not CV-specific.
- Functional, lens-based editing for extension schemas without re-spelling the canonical shape.
- A JSON Schema (draft 7 subset) → Typst schema translator for callers with an existing `.json` schema.

## Requirements

- Typst `0.15.0` or later.

## Quick start

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": parse

#let resume = parse(path("resume.json"))
// hand `resume` to any compatible Typst CV template
```
<!-- x-release-please-end -->

A minimal `resume.json`:

```json
{
  "basics": {
    "name": "Seán Ó Murchú",
    "label": "Senior Software Engineer",
    "email": "sean@example.com",
    "summary": "Backend engineer with eight years of experience."
  },
  "work": [
    {
      "name": "Acme Corp",
      "position": "Senior Software Engineer",
      "startDate": "2022-01",
      "highlights": ["Led the event-sourcing platform migration."]
    }
  ]
}
```

The canonical schema covers thirteen sections: `basics`, `work`, `volunteer`,
`education`, `awards`, `certificates`, `publications`, `skills`, `languages`,
`interests`, `references`, `projects`, `meta`. The `$schema` top-level
metadata field is also accepted. See
[jsonresume.org/schema](https://jsonresume.org/schema) for every field.

### Bring your own schema

gairm-import is JSON-Schema-driven, not CV-specific. Two ways to use a
non-CV shape.

**Translate an existing `.json` schema** with `schema-from-json-schema`
(JSON Schema draft 7 subset — supported keywords listed under
[Starting from a JSON Schema document](#starting-from-a-json-schema-document)):

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": parse, schema-from-json-schema

#let book-schema = schema-from-json-schema(json("book-schema.json"))
#let book = parse(path("book.json"), schema: book-schema)
```
<!-- x-release-please-end -->

**Or build the schema directly in Typst** with the public combinators:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  parse, object, array-of, str-type, number-type,
)

#let book-schema = object((
  title:  str-type,
  author: str-type,
  year:   number-type,
  tags:   array-of(str-type),
))

#let book = parse(path("book.json"), schema: book-schema)
```
<!-- x-release-please-end -->

Both go through the same `validate` / `coerce` / error-reporting
machinery — the JSON Resume schemas are just the bundled default. See
[Schemas and composition](#schemas-and-composition) for the full
schema-building API (lenses for targeted edits, the supported /
out-of-scope JSON Schema keywords, and more).

### API at a glance

The five names a first-time reader will meet. Lens, introspection, and
schema-building helpers are introduced later in [Schemas and composition](#schemas-and-composition).

| Export | Purpose |
|---|---|
| `parse(data, schema: ...)` | Validate and coerce in one call; aborts compilation with a combined report on errors. |
| `validate(data, schema: ...)` | Return a list of `(path, message)` records — empty list means valid. |
| `coerce(data, schema: ...)` | Coerce a (validated) document into the typed model. |
| `resume-schema` | Default schema — faithful 1:1 derivation of the canonical JSON Resume document. |
| `resume-schema-strict` | Renderer-friendly overlay — free-text fields typed as Typst `content`, iso8601 `$ref` fields validated as dates. |
| `schema-from-json-schema(doc)` | Translate an existing JSON Schema (draft 7 subset) document into a Typst schema. Pair with `parse(..., schema: ...)`. |
| `object`, `array-of`, kind primitives | Build a Typst schema directly. See [Schemas and composition](#schemas-and-composition). |

## Usage

### Loading the document

`parse` is the one-call entry point. The recommended form is
`parse(path("resume.json"))` — the
[`path`](https://typst.app/docs/reference/foundations/path/) value resolves
against your own `.typ` (not the `@preview` cache), so you can use the
natural relative path:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": parse

#let resume = parse(path("resume.json"))
```
<!-- x-release-please-end -->

A parsed dict, a `json("…")` wrap, or a Typst-root-relative `"/…"` string
are also accepted — useful on older callers or when you've already loaded
the document yourself:

```typst
// json() resolves the path against your .typ; parse takes the dict.
#let resume = parse(json("resume.json"))

// Typst-root-relative path string, resolved by parse itself.
#let resume = parse("/resume.json")
```

### The returned model

The returned dict is a 1:1 mirror of the canonical schema — every kind comes
from the upstream JSON Schema document. Format-annotated fields are gated by
a regex (see [Format validation](#format-validation)); everything else passes
through as JSON-native types. For example:

```text
resume.basics.name            str
resume.basics.summary         str
resume.basics.email           str (gated as email)
resume.work.at(0).position    str
resume.work.at(0).highlights  array of str
resume.skills.at(0).keywords  array of str
```

For renderer-friendly opinions (free-text fields wrapped as Typst `content`,
iso8601 `$ref` fields validated as dates), import `resume-schema-strict`
instead and pass it via the `schema:` keyword — see
[Two schemas](#two-schemas).

### Rendering with a template

Pass the model into any compatible renderer — e.g. [`altacv`](https://typst.app/universe/package/altacv):

<!-- Two fences (not one): release-please would otherwise bump altacv:1.1.1 on every gairm release. See https://github.com/typst/packages/pull/5069#discussion_r3420827761 -->

```typst
#import "@preview/altacv:1.1.1": alta
```

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": parse

#alta(parse(path("resume.json")))
```
<!-- x-release-please-end -->

If the renderer expects fields outside the canonical JSON Resume shape, build
an extension schema with the public combinators and pass it as `schema:` —
see [Building an extension schema](#building-an-extension-schema).

## Errors

`validate` returns a list of `(path, message)` records — empty list means
the input is valid. `parse` validates first and aborts compilation with a
combined report on the first invocation that finds issues, so every problem
in the document surfaces in one error:

```text
error: assertion failed: gairm-import: found 3 problems in the input:
  - basics.email: expected string, got integer.
  - work[0].positon: unknown key "positon". Did you mean "position"?
  - meta.foo: unknown key "foo". Valid keys: canonical, version, lastModified.
```

When a typo is within edit distance 2 of a valid key, the message surfaces
a short "Did you mean …?" hint; otherwise it falls back to the full
valid-keys list shown for `meta.foo`.

### Handling validation errors yourself

Each error is a record
`(path: ("basics", "email"), message: "expected string, got integer.")`.
To present errors yourself instead of letting `parse` abort compilation,
run the two steps separately:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": validate, coerce

#let raw = json("resume.json")
#let errors = validate(raw)
#if errors.len() > 0 {
  [Resume has #errors.len() issue(s).]
} else {
  let model = coerce(raw)
  // render model …
}
```
<!-- x-release-please-end -->

### Null handling

JSON `null` is treated as if the key were absent — no validation error,
dropped from the coerced model. Null elements inside arrays are dropped the
same way. This matches the convention used by most JSON Resume emitters,
where `"summary": null` is semantically equivalent to omitting the key.
Unknown keys are still flagged even when their value is `null`, so typos do
not slip through silently.

Root null is rejected: if the entire input document is `null`, `validate`,
`coerce`, and `parse` panic with
`gairm-import: input must be a dict, got null.` The null-as-absent policy
applies to leaf positions inside a document, not to the document itself.

## Schemas and composition

### Two schemas

The package exports two values of the canonical schema:

- **`resume-schema`** — a faithful 1:1 translation of the vendored upstream
  JSON Schema document. Every kind comes from the source; nothing is
  rewritten. This is the default when you call `parse(data)` /
  `validate(data)` / `coerce(data)`.
- **`resume-schema-strict`** — adds three layered opinions on top via the
  lens API:
  - free-text fields (`basics.summary`, `work[].summary`,
    `work[].highlights[]`, etc.) are typed as Typst `content` so they
    splice directly into markup
  - iso8601 `$ref` fields (`startDate`, `endDate`, …) are validated as
    ISO-8601 dates (the upstream document doesn't carry a `format`
    annotation on them, just a regex inside a definition)
  - upstream's `additionalProperties: true` markers — declared on every
    section's items, so the faithful default lets undeclared extras pass
    through — are stripped recursively, restoring the "unknown keys are
    rejected" promise (typed extras via `additionalProperties: <schema>`
    are kept)

Pass `schema: resume-schema-strict` to opt in:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": parse, resume-schema-strict

#let resume = parse(path("resume.json"), schema: resume-schema-strict)
```
<!-- x-release-please-end -->

The faithful default is the source-of-truth view; the strict variant is a
renderer-ergonomics overlay. If you want a different mix, build your own by
lensing over `resume-schema` — see
[Targeted edits with lenses](#targeted-edits-with-lenses).

### Format validation

Fields the canonical schema annotates with `format: "uri"`, `format: "email"`,
or `format: "date"` are gated by a regex during `validate` / `parse`. The
patterns are deliberately permissive — they reject obvious malformations
without claiming full RFC compliance — and each emits a path-qualified
message with a canonical example:

```text
basics.email:           expected an email (e.g. "name@example.com").
basics.url:             expected a URI (e.g. "https://example.com").
certificates[0].date:   expected an ISO-8601 date (e.g. "2024-01-15").
```

`format: "date-time"` maps to the separate `datetime-string` kind:
`date-string` accepts `YYYY` / `YYYY-MM` / `YYYY-MM-DD`, while
`datetime-string` requires the full `YYYY-MM-DDTHH:MM:SS` shape (optional
fractional part and `Z` / `±HH:MM` offset). The canonical document carries
no `date-time` annotations, so that kind only fires via
`schema-from-json-schema` or a lens override.

Most date fields in JSON Resume (`work[].startDate`, `awards[].date`,
`meta.lastModified`, …) use `$ref: "#/definitions/iso8601"` rather than
`format: "date"`. The translator can't pick formats up from a `$ref` alone,
so those fields stay as plain `str` in `resume-schema`. Switch to
`resume-schema-strict` to validate them as dates, or build your own override
list with `lens-put(lens(path), schema, date-string)`.

Coercion is pass-through: format-checked values flow through to the model as
plain strings, so renderers receive `model.basics.email == "name@example.com"`
unchanged.

For ad-hoc constraints outside the four built-in formats, build a
`pattern-string(re, expected: …)` and target it via a lens or splice it
into an extension schema. JSON Schema's `pattern` keyword on a plain string
maps to this kind too — see
[Starting from a JSON Schema document](#starting-from-a-json-schema-document)
for the precedence rule when both `format` and `pattern` are present:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  resume-schema, lens, lens-put, pattern-string,
)

// Gate basics.location.countryCode as an ISO 3166-1 alpha-2 code.
#let with-country-code = lens-put(
  lens(("basics", "location", "countryCode")),
  resume-schema,
  pattern-string(
    "^[A-Z]{2}$",
    expected: "an ISO 3166-1 alpha-2 code (e.g. \"US\")",
  ),
)
```
<!-- x-release-please-end -->

Typst's regex `match` finds a match anywhere in the string, so anchor the
pattern yourself if you need a full-string match — `^…$` is the common case.

### Building an extension schema

`parse` is strict against declared fields in the canonical schema: keys that
aren't declared *and* aren't covered by an upstream `additionalProperties`
clause are rejected. (Upstream JSON Resume sets `additionalProperties: true`
on every section's items, so extras in those positions pass through —
[Two schemas](#two-schemas) covers the strict variant that strips them.)

Renderers that expect their own top-level fields in the resume document
(e.g. alta-typst's `focusAreas`) can build a JSON-Resume+ schema with the
public combinators and pass it to `parse` / `validate` / `coerce` via the
`schema:` keyword:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  resume-schema, parse, object, array-of, content-type,
)

// Splice the canonical shape and add a renderer-specific field.
#let altacv-schema = object((
  ..resume-schema.shape,
  focusAreas: array-of(content-type),
))

#let model = parse(path("resume.json"), schema: altacv-schema)
```
<!-- x-release-please-end -->

`resume-schema.shape` is a plain dict, so `..resume-schema.shape` is the
only operator you need to extend it. Per-section combinators (`work-item`,
`volunteer-item`, …) are intentionally not exposed yet — splice the
canonical top-level fields whole and add your own siblings.

### Targeted edits with lenses

Splicing `..resume-schema.shape` works for top-level additions but is
awkward when the field you want to touch is three or four levels deep
(`work` items' `highlights` element schema, `basics.email`, …). For those
cases, lenses target a path inside the schema and return a new schema with
the targeted node replaced or transformed:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  resume-schema, lens, lens-put, lens-over, add-field,
  set-required, unset-required,
  str-type, content-type, number-type, object,
)

// Widen basics.summary from content (rich) to str (plain) — useful if
// you want the summary rendered as plain text instead of formatted:
#let plain-summary = lens-put(
  lens(("basics", "summary")), resume-schema, str-type,
)

// Add a numeric `rating` to every language entry — touches
// resume-schema.shape.languages.elem.shape without re-spelling the wrapper:
#let with-rating = add-field(
  resume-schema, lens(("languages", "items")), "rating", number-type,
)

// Transform an existing node with a function:
#let with-extra-meta = lens-over(
  lens(("meta",)),
  resume-schema,
  meta => object((..meta.shape, source: str-type)),
)

// Make basics.name and basics.email required for your template
// (canonical schema declares no required keys):
#let strict-basics = set-required(
  resume-schema, lens(("basics",)), ("name", "email"),
)

// Relax email back without re-spelling the rest of the required list:
#let mixed-basics = unset-required(
  strict-basics, lens(("basics",)), ("email",),
)
```
<!-- x-release-please-end -->

Path segments match JSON Schema keyword names: object keys as strings, the
literal `"items"` to enter an array's element schema, and the literal
`"additionalProperties"` to enter an object's `additional` (the
additionalProperties schema; only valid when `additional` is a schema dict,
not `true`). Composition (`lens-then(a, b)`) concatenates paths, so
`lens-then(lens(("work",)), lens(("items", "highlights")))` is the same
lens as `lens(("work", "items", "highlights"))`. The empty path `lens(())`
is the identity lens.

| Function | Shape | Behaviour |
|---|---|---|
| `lens(path)` | `path → lens` | Construct a lens from a path tuple |
| `lens-get(l, schema)` | `lens, schema → sub-schema` | Read the targeted node |
| `lens-put(l, schema, value)` | `lens, schema, sub → schema` | Replace the targeted node |
| `lens-over(l, schema, fn)` | `lens, schema, (sub → sub) → schema` | Apply a function to the targeted node |
| `lens-then(a, b)` | `lens, lens → lens` | Compose two lenses (path concatenation) |
| `add-field(schema, parent, key, sub)` | … → schema | Add a key to the object at `parent` |
| `remove-field(schema, parent, key)` | … → schema | Remove a key from the object at `parent` |
| `set-required(schema, parent, keys)` | … → schema | Replace the object's `required-keys` list at `parent` |
| `unset-required(schema, parent, keys)` | … → schema | Drop specific entries from the object's `required-keys` list at `parent` |

Operations are functional — each helper above returns a NEW schema and
leaves the input untouched, so you can chain edits without disturbing the
canonical one. (Operations are top-level functions rather than methods
because Typst parses `lens.put(…)` as a type-method lookup, not a closure
call.)

### Inspecting a schema

When an extension schema misbehaves, `describe-schema`, `paths-of-kind`,
and `kind-at` answer the three usual questions — *what does this thing
look like?*, *where do my date strings live?*, *what kind is at this
path?* — without `repr(schema)` or hand-walking `.shape`:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  resume-schema-strict, describe-schema, paths-of-kind, kind-at,
)

// Tree view of every leaf, with array sections suffixed `[]`.
#describe-schema(resume-schema-strict)
// basics:
//   email    email-string
//   name     str
//   summary  content
//   …
// work[]:
//   highlights[]  content
//   startDate     date-string
//   …

// Every lens-compatible path whose terminal kind matches.
#paths-of-kind(resume-schema-strict, "date-string")
// → (("work", "items", "startDate"), …)

// Kind at a single path — thin wrapper over lens-get.
#kind-at(resume-schema-strict, ("basics", "summary"))  // "content"
```
<!-- x-release-please-end -->

Array segments in returned path tuples use `"items"` so they plug straight
into `lens(path)`; the `[]` suffix in `describe-schema`'s output is
human-friendly visual only. Keys sort alphabetically so diffs across schema
versions stay stable.

The real leverage comes from folding `paths-of-kind` together with
`lens-put` to bulk-edit every field of a kind in one pass — the list of
paths is derived from the schema, so new fields an upstream JSON Resume
bump introduces are covered automatically:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  resume-schema, paths-of-kind, lens, lens-put, pattern-string,
)

// Tighten every uri-string field to a corporate-domain pattern,
// without enumerating the paths by hand.
#let corporate-uri = pattern-string(
  "^https://(corp|docs)\.example\.com/",
  expected: "a corporate URL",
)
#let corporate-schema = paths-of-kind(resume-schema, "uri-string").fold(
  resume-schema,
  (schema, path) => lens-put(lens(path), schema, corporate-uri),
)
```
<!-- x-release-please-end -->

### JSON Pointer interop

Lens paths and validator error paths are `(seg, seg, ...)` tuples — natural
in Typst but they don't directly interoperate with external tooling that
speaks [RFC 6901 JSON Pointer](https://datatracker.ietf.org/doc/html/rfc6901)
(editor extensions for schema-aware completion, schema diff tools, JSON
Schema documentation generators, …). `path-to-pointer` / `pointer-to-path`
cross the boundary:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": path-to-pointer, pointer-to-path

#path-to-pointer(("basics", "email"))            // "/basics/email"
#path-to-pointer(("work", 0, "highlights", 1))   // "/work/0/highlights/1"
#path-to-pointer(("a/b",))                       // "/a~1b"     — `/` escapes as `~1`
#path-to-pointer(("~tilde",))                    // "/~0tilde"  — `~` escapes as `~0`

#pointer-to-path("/work/0/highlights/1")         // ("work", 0, "highlights", 1)
#pointer-to-path("")                             // ()          — whole document
#pointer-to-path("/")                            // ("",)       — empty-string key at root
```
<!-- x-release-please-end -->

**Two addressing schemes share the same encoder.** Validator error paths
(mixed `str` / non-negative `int`) address into **data** — the output is a
real RFC 6901 pointer any JSON-Pointer-aware tool can dereference against
the document. Lens and introspect paths (`str`-only, with `"items"` and
`"additionalProperties"`) address into the **schema** — the output names a
schema location the way JSON Schema tooling does in `$ref`
(e.g. `#/properties/foo/items`), not a data position.

Malformed input panics rather than passing through silently: non-`str`/`int`
or negative segments at encode, invalid `~` escapes at decode.
`pointer → path → pointer` round-trips losslessly; `path → pointer → path`
is lossless except for `str` segments that look like array indices
(`("0",)` decodes back as `(0,)`) — which validator and lens paths never
emit in practice.

### Starting from a JSON Schema document

`schema-from-json-schema(parsed-schema)` translates a JSON Schema (draft 7
subset) into a Typst schema dict. Use it when you already have an
authoritative `.json` schema and don't want to keep a parallel Typst copy
in sync:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.9.0": (
  schema-from-json-schema, coerce, object, array-of, content-type,
)

#let canonical = schema-from-json-schema(path("resume-schema.json"))
#let altacv-schema = object((
  ..canonical.shape,
  focusAreas: array-of(content-type),
))

#let model = coerce(json("resume.json"), schema: altacv-schema)
```
<!-- x-release-please-end -->

**Supported keywords:**

- `type`: `string` / `number` / `integer` / `array` / `object` / `boolean` /
  `null` — `integer` rejects numbers with a non-zero fractional part
  (`1.0` passes, per draft-7 semantics); the matching Typst-side
  primitive is `integer-type`
- `format`: `uri` → `uri-string`, `email` → `email-string`,
  `date` → `date-string`, `date-time` → `datetime-string`
- `pattern` → `pattern-string` (on plain string schemas only; when both
  `format` and `pattern` are present on the same node, `format` wins and
  `pattern` is dropped — compose two gates yourself via a lens if you need
  both)
- `enum` → `enum-of`, `const` → `const-of`
- `properties`, `required`, `items`
- Internal `$ref` (`#/definitions/…` / `#/$defs/…`)
- `anyOf` → `any-of` (at least one member matches), `oneOf` → `one-of`
  (exactly one member matches), `not` → `not-of` (value must not match) —
  the composition keyword must stand alone on its node (annotation-only
  siblings like `title` / `description` excepted); a sibling `type`,
  constraint, or `$ref` panics rather than being silently ignored
- `allOf` — merged at translate time; every member must be an object
  schema (shapes union, `required` union; a duplicate key must carry an
  identical sub-schema; `additionalProperties` must agree across all
  members, with an undeclared member counting as closed). Non-object
  composition (e.g. string + extra constraints) panics
- `type: [X, "null"]` nullable unions (under the engine's null-as-absent
  policy these translate to plain `X`)
- String constraints: `minLength`, `maxLength`
- Number constraints: `minimum`, `maximum`, `exclusiveMinimum`,
  `exclusiveMaximum`, `multipleOf`
- Array constraints: `minItems`, `maxItems`, `uniqueItems`
- `additionalProperties`: a schema, `true`, or `false` — `false` matches
  the strict default; `true` permits extras without validation; a schema
  validates every extra against it (also reachable via the
  `map(value-schema)` combinator)

Constraint keywords are baked onto the kind dict as kebab-case fields and
validated inline.

**Out of scope.** Each keyword below panics with a clear "unsupported"
message rather than silently dropping the constraint:

- `if` / `then` / `else`
- `dependencies` (and the `dependentRequired` / `dependentSchemas` variants)
- Constraint keywords (`minLength`, `minimum`, `minItems`, …) combined with
  `enum` / `const` — membership already pins the exact values, so fold the
  constraint into the value list instead (`type` alongside `enum` / `const`
  remains accepted as redundant)
- `type: "object"` with neither `properties` nor `additionalProperties`
  (fully open)
- `type: [...]` unions with more than one non-null member
- External `$ref`
- String formats other than the four listed above
- `allOf` with non-object members, and schema-bearing sibling keywords
  beside any composition keyword (move them into the members)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Releases are cut by
[release-please](https://github.com/googleapis/release-please) from
conventional-commit titles on `main`.

## License

[MIT](LICENSE).
