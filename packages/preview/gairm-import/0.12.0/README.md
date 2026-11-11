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
  get back a normalised Typst value ready to render. The
  <a href="https://jsonresume.org/schema">JSON Resume</a> schema is built in.
</p>

<p align="center">
  <sub><em>"gairm" is Irish for vocation. The package was originally a JSON Resume loader.</em></sub>
</p>

## Contents

- [What it is](#what-it-is)
- [Quick start](#quick-start)
- [Bring your own schema](#bring-your-own-schema)
- [API at a glance](#api-at-a-glance)
- [Input forms](#input-forms)
- [Errors](#errors)
- [Null handling](#null-handling)
- [The two resume schemas](#the-two-resume-schemas)
- [Reference](#reference)

## What it is

gairm-import checks a JSON document against a schema and returns it as
Typst values. Every problem in the document is reported at once, each with
its path and, for a misspelt key, a "Did you mean …?" hint. The schema can
be a JSON Schema document, one you build with Typst functions, or the
bundled JSON Resume schema, and you can edit any of them with lenses
before use. Requires Typst `0.15.0` or later.

## Quick start

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": parse

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

The result mirrors the document: `resume.basics.name` and
`resume.work.at(0).position` are strings, `resume.work.at(0).highlights` an
array of strings. The bundled schema is JSON Resume **1.7.0**; see
[jsonresume.org/schema](https://jsonresume.org/schema) for every field.
Pass the result to any renderer that takes JSON Resume data, such as
[`altacv`](https://typst.app/universe/package/altacv):

<!-- Two fences (not one): a single fence would let release-please rewrite this altacv pin on every gairm release. Bump it by hand when altacv publishes a new version. See https://github.com/typst/packages/pull/5069#discussion_r3420827761 -->

```typst
#import "@preview/altacv:1.7.0": alta
```

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": parse

#alta(parse(path("resume.json")))
```
<!-- x-release-please-end -->

## Bring your own schema

Nothing in the engine is CV-specific. Translate a JSON Schema document you
already have:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": parse, schema-from-json-schema

#let book-schema = schema-from-json-schema(json("book-schema.json"))
#let book = parse(path("book.json"), schema: book-schema)
```
<!-- x-release-please-end -->

Or build the schema in Typst:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": (
  parse, object, array-of, string, number,
)

#let book-schema = object((
  title:  string(),
  author: string(),
  year:   number(),
  tags:   array-of(string()),
))

#let book = parse(path("book.json"), schema: book-schema)
```
<!-- x-release-please-end -->

The translator takes a draft 7 subset and panics on anything it cannot
honour rather than dropping it; [REFERENCE.md](REFERENCE.md#json-schema-translation)
lists the keywords it supports and how it differs from draft 7.

## API at a glance

| Group | Names |
|---|---|
| Run | `parse`, `validate`, `coerce`, `format-errors` |
| Schemas | `resume-schema`, `resume-schema-strict`, `schema-from-json-schema` |
| Constructors | `string`, `number`, `integer`, `array-of`, `object`, `map`, `any-of`, `one-of`, `not-of`, `if-of`, `nullable`, `enum-of`, `const-of` |
| Constants | `content-type`, `bool-type`, `null-type`, `any-type` |
| Edit | `lens-get`, `lens-put`, `lens-over`, `add-field`, `remove-field`, `set-required`, `unset-required` |
| Inspect | `describe-schema`, `paths-of-kind` |
| Pointers | `path-to-pointer`, `pointer-to-path` |

`parse` validates and coerces in one call and panics with every problem
found. `validate` returns the problems as a list, and `coerce` builds the
model without checking. All three take `schema:` (default `resume-schema`)
and `strict-null:` (default `false`). [REFERENCE.md](REFERENCE.md) covers
the rest, one section per group.

**Deprecated, working until 1.0:** `str-type`, `number-type`,
`integer-type`, the nine format constants (`date-string` …
`time-string`), `pattern-string`, `lens`, `lens-then`, `kind-at`, the
lens-first argument order (`lens-get(at, schema)`), the
`(kind: "lens", path: …)` shape, a kind name string in `paths-of-kind`, and
hand-built nodes of the old kind names (`"str"`, `"pattern-string"`,
`"date-string"` …). [REFERENCE.md](REFERENCE.md#deprecated-names) gives
the replacement for each.

## Input forms

`parse`, `validate` and `coerce` take the document, or where to read it:

| You pass | It is read as |
|---|---|
| `path("resume.json")` | JSON, resolved from your file |
| bytes, such as `read("resume.json", encoding: none)` | JSON |
| a dictionary, such as `json("resume.json")` | the document itself |
| any other value: an array, a number, a string | the document itself, whatever root the schema takes |

A string is data, not a path: inside a package it would resolve from the
package, never your file, so a `.json`-looking string the schema rejects
panics with a hint to use `path(..)`. A `null` document panics.
`schema-from-json-schema` takes the first three forms only.

## Errors

`parse` reports every problem in one panic. A document with a numeric
`basics.email` and two stray keys, parsed with
`schema: resume-schema-strict`:

```text
error: panicked with: gairm-import: found 3 problems in the input:
  - basics.email: expected string, got integer.
  - work[0].positon: unknown key "positon". Did you mean "position"?
  - meta.foo: unknown key "foo". Valid keys: canonical, version, lastModified.
```

The default `resume-schema` reports only the first line, since upstream
lets undeclared keys through there (see
[The two resume schemas](#the-two-resume-schemas)). To present problems
yourself, call `validate`, which returns them as records. The first line
above is `(path: ("basics", "email"), code: "type", message: "expected
string, got integer.", expected: "string", got: "integer")`.

Branch on `code`, not on the message. `expected` and `got` hold the data
behind the message, or `none` where a code has nothing to put there:

| `code` | Meaning | `expected` | `got` |
|---|---|---|---|
| `type` | Wrong JSON type (also: an enum or union none of whose members takes that type) | The type name(s) | The value's type name |
| `required` | A required key is missing | | |
| `unknown-key` | A key the object does not declare | The valid keys | The key |
| `dependent` | A key required by another key's presence is missing | The missing key | The key that requires it |
| `enum` | Not one of the enum's values | The values | The value |
| `format` | Not in the format's shape (date, email, …) | The format's description | The value |
| `pattern` | Does not match the pattern | The pattern's description | The value |
| `length` | String too short or too long | The bound broken: `(min-length: 3)` or `(max-length: 80)` | The length |
| `range` | Number out of range | The bound broken: `(minimum: 1)`, `(exclusive-minimum: 1)`, `(maximum: 10)` or `(exclusive-maximum: 10)` | The number |
| `multiple` | Not a multiple of `multiple-of` | `(multiple-of: 0.1)` | The number |
| `integer` | A fractional number where an integer is expected | | The number |
| `items` | Too few or too many array items | The bound broken: `(min-items: 1)` or `(max-items: 5)` | The item count |
| `unique` | Duplicate array items | | The two duplicate indices |
| `union` | Several alternatives take the value's type but none matches, or more than one `one-of` member matches | The alternatives' kinds | |
| `not` | The value matches a `not-of` schema | | |

`format-errors(errors)` turns the records into `parse`'s report, reading
only `path` and `message`:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": validate, coerce, format-errors

#let doc = json("resume.json")
#let errors = validate(doc)
#if errors.len() > 0 {
  [Resume has #errors.len() issue(s).]
  raw(format-errors(errors))
} else {
  let model = coerce(doc)
  // render model …
}
```
<!-- x-release-please-end -->

## Null handling

By default JSON `null` means "absent", as most JSON Resume emitters intend
(`"summary": null` is the same as no summary). Pass `strict-null: true` to
`parse`, `validate` or `coerce` when `null` must mean something: it is then
an ordinary value that a schema accepts or rejects.

| Input | Default | `strict-null: true` |
|---|---|---|
| required key missing | `required` | `required` |
| key holding `null`, field not nullable | `required` if required, else dropped from the model | `type`, "got null" |
| key holding `null`, field `nullable(X)` | dropped | accepted, kept as `none` |
| unknown key holding `null` | `unknown-key` | `unknown-key` |
| `null` array element | dropped | `type`, or kept if the element is `nullable(X)` (and counted by `min-items` / `unique-items`) |
| dependent-required trigger holding `null` | does not fire | fires |
| object whose keys are all `null` | kept as `(:)` | judged key by key |
| free-form object (no fields, `additional: true`) | passed through as given, nulls and all | the same |
| the whole document is `null` | panics | panics |

`nullable(X)` accepts `null` or whatever `X` accepts, and judges a non-null
value exactly as `X` does:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": parse, object, string, nullable

#let schema = object(
  (name: string(), nickname: nullable(string())),
  required-keys: ("name", "nickname"),
)
#parse((name: "Ada", nickname: none), schema: schema, strict-null: true)
// → (name: "Ada", nickname: none)
```
<!-- x-release-please-end -->

The JSON Resume schema declares no nullable fields, so with
`strict-null: true` either resume schema rejects a `null` in any declared
field. The free-form `custom` objects check nothing, so a `null` there
is kept.

## The two resume schemas

**`resume-schema`**, the default, is a faithful translation of the
vendored upstream document; nothing is rewritten. Upstream sets
`additionalProperties: true` at the top level and on every section's
items, so undeclared keys pass there. Its date fields (`startDate`,
`endDate`, `date`, …) are strings checked by upstream's `iso8601` regex,
and `meta.lastModified` is a plain string.

**`resume-schema-strict`** adds three opinions:

- free-text fields (`basics.summary`, `work[].highlights[]`, …) are Typst
  `content`, so they splice into markup;
- the date fields are `string(format: "date")`, which also takes a Typst
  `datetime`, and `meta.lastModified` is a date-time or a date;
- upstream's `additionalProperties: true` markers are removed, so an
  undeclared key is an error. Typed extras (`additionalProperties` with a
  schema) still pass if they match, and the free-form `custom` objects
  stay open.

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": parse, resume-schema-strict

#let resume = parse(path("resume.json"), schema: resume-schema-strict)
```
<!-- x-release-please-end -->

For a different mix, edit either one with lenses; see
[REFERENCE.md](REFERENCE.md#lenses-and-edits).

## Reference

[REFERENCE.md](REFERENCE.md) documents every constructor and argument,
the formats, lenses and the edits, introspection, JSON Pointer, the JSON
Schema translator and its deviations from draft 7, and the deprecated
names.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Releases are cut by
[release-please](https://github.com/googleapis/release-please) from
conventional-commit titles on `main`.

## License

[MIT](LICENSE).
