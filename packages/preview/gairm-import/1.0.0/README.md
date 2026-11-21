<h1 align="center">gairm-import</h1>

<p align="center">
  <a href="https://typst.app/universe/package/gairm-import"><img alt="gairm-import on Typst Universe" src="https://img.shields.io/badge/Typst_Universe-gairm--import-239DAE?logo=typst&style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/releases"><img alt="Latest GitHub release version of gairm-import" src="https://img.shields.io/github/v/release/smur89/gairm-import?style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/actions/workflows/build.yml"><img alt="GitHub Actions build workflow status on the gairm-import main branch" src="https://img.shields.io/github/actions/workflow/status/smur89/gairm-import/build.yml?style=flat-square"></a>
  <a href="LICENSE"><img alt="MIT license badge linking to the gairm-import LICENSE file" src="https://img.shields.io/github/license/smur89/gairm-import?style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/stargazers"><img alt="Number of GitHub stargazers for gairm-import" src="https://img.shields.io/github/stars/smur89/gairm-import?style=flat-square"></a>
</p>

<p align="center">
  <strong>Validate JSON against a schema, get typed Typst values.</strong>
  <br>
  Check a JSON document against a JSON Schema (draft&nbsp;7 subset) or a
  schema built in Typst, see every problem at once, and get back a
  normalised Typst value ready to render. Bring your own schema, such as
  <a href="https://jsonresume.org/schema">JSON Resume</a>'s.
</p>

<p align="center">
  <sub><em>"gairm" is Irish for vocation. The package was originally a JSON Resume loader.</em></sub>
</p>

## Contents

- [Quick start](#quick-start)
- [API at a glance](#api-at-a-glance)
- [Input forms](#input-forms)
- [Errors](#errors)
- [Null handling](#null-handling)
- [Validating a JSON Resume](#validating-a-json-resume)
- [Contributing](#contributing)
- [License](#license)

## Quick start

Requires Typst `0.15.0` or later. Given this `book.json`:

```json
{
  "title": "The Pocket Atlas of Imaginary Places",
  "author": "Aoife Brennan",
  "year": 1998,
  "tags": ["atlas", "fiction"]
}
```

build its schema in Typst and parse it:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:1.0.0": (
  parse, object, array-of, string, number,
)

#let book-schema = object(
  (
    title:  string(),
    author: string(),
    year:   number(),
    tags:   array-of(string()),
  ),
  required-keys: ("title", "author", "year", "tags"),
)

#let book = parse(book-schema, path("book.json"))

= #book.title
#book.author, #book.year: #book.tags.join(", ")
```
<!-- x-release-please-end -->

The result mirrors the document: `book.title` is a string, `book.year` a
number and `book.tags` an array of strings. Or translate a JSON Schema
document you already have:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:1.0.0": parse, schema-from-json-schema

#let book-schema = schema-from-json-schema(json("book-schema.json"))
#let book = parse(book-schema, path("book.json"))
```
<!-- x-release-please-end -->

The translator takes a draft 7 subset and panics on anything it cannot
honour rather than dropping it; [REFERENCE.md](REFERENCE.md#json-schema-translation)
lists the keywords it supports and how it differs from draft 7.

## API at a glance

| Group | Names |
|---|---|
| [Run](REFERENCE.md#running) | `parse`, `validate`, `coerce`, `format-errors` |
| [Schemas](REFERENCE.md#json-schema-translation) | `schema-from-json-schema` |
| [Constructors](REFERENCE.md#constructors) | `string`, `number`, `integer`, `boolean`, `null`, `markup`, `unknown`, `array-of`, `object`, `map`, `any-of`, `one-of`, `not-of`, `if-of`, `nullable`, `enum-of`, `const-of` |
| [Edits](REFERENCE.md#schema-paths-and-edits) | `schema-get`, `schema-put`, `schema-update`, `add-field`, `remove-field`, `set-required`, `unset-required` |
| [Inspect](REFERENCE.md#introspection) | `describe-schema`, `find-paths` |
| [Pointers](REFERENCE.md#json-pointer) | `path-to-pointer`, `pointer-to-path` |

`parse` validates and coerces in one call and panics with every problem
found. `validate` returns the problems as a list, and `coerce` builds the
model without validating first, panicking only where the data leaves no
model. All three take the schema, then the data, and `strict-null:`
(default `false`), so `parse.with(schema)` is a parser for one schema.

## Input forms

`parse`, `validate` and `coerce` take the document, or where to read it:

| You pass | It is read as |
|---|---|
| `path("book.json")` | JSON, resolved from your file |
| bytes, such as `read("book.json", encoding: none)` | JSON |
| a dictionary, such as `json("book.json")` | the document itself |
| any other value: an array, a number, a string | the document itself, whatever root the schema takes |

A string is the document, not a path: a `.json` filename or JSON text the
schema rejects panics with a hint to use `path(..)` or
`read(.., encoding: none)`. `schema-from-json-schema` takes the first
three forms only.

## Errors

`parse` reports every problem in one panic. The book from
[Quick start](#quick-start), whose schemas require all four fields, with
a numeric author, a misspelt `year` and a number among its tags:

```json
{
  "title": "The Pocket Atlas of Imaginary Places",
  "author": 1998,
  "yaer": 1998,
  "tags": ["atlas", 3]
}
```

```text
error: panicked with: gairm-import: found 4 problems in the input:
  - author: expected string, got integer.
  - yaer: unknown key "yaer". Did you mean "year"?
  - tags[1]: expected string, got integer.
  - year: missing required key "year".
```

To present problems yourself, call `validate`, which returns them as
records. The first line above is `(path: ("author",), code: "type",
message: "expected string, got integer.", expected: "string", got:
"integer")`. A record's `path` is where in the document the problem is;
for a missing key, `required` or `dependent`, it is the key that is
missing.

Branch on `code`, not on the message;
[REFERENCE.md](REFERENCE.md#error-records) lists every code and what
`expected` and `got` hold for each.

`format-errors(errors)` turns the records into `parse`'s report, reading
only `path` and `message`. With `book-schema` from
[Quick start](#quick-start):

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:1.0.0": validate, coerce, format-errors

#let doc = json("book.json")
#let errors = validate(book-schema, doc)
#if errors.len() > 0 {
  [Book has #errors.len() issue(s).]
  raw(format-errors(errors))
} else {
  let book = coerce(book-schema, doc)
  // render book …
}
```
<!-- x-release-please-end -->

## Null handling

By default JSON `null` means "absent", as most JSON emitters intend
(`"summary": null` is the same as no summary). Pass `strict-null: true` to
`parse`, `validate` or `coerce` when `null` must mean something: it is then
an ordinary value that a schema accepts or rejects.

| Input | Default | `strict-null: true` |
|---|---|---|
| required key missing | `required` | `required` |
| key holding `null`, field not nullable | `required` if required, else dropped from the model | `type`, "got null" |
| key holding `null`, field `nullable(X)` | `required` if required, else dropped | accepted, kept as `none` |
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
#import "@preview/gairm-import:1.0.0": parse, object, string, nullable

#let schema = object(
  (name: string(), nickname: nullable(string())),
  required-keys: ("name", "nickname"),
)
#parse(schema, (name: "Ada", nickname: none), strict-null: true)
// → (name: "Ada", nickname: none)
```
<!-- x-release-please-end -->

## Validating a JSON Resume

[JSON Resume](https://jsonresume.org/schema) publishes its schema as a JSON
Schema document. Download
[`schema.json`](https://cdn.jsdelivr.net/npm/@jsonresume/schema@1.7.1/schema.json)
beside your file as `resume.schema.json`, and translate it:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:1.0.0": parse, schema-from-json-schema

#let resume-schema = schema-from-json-schema(json("resume.schema.json"))
#let resume = parse(resume-schema, path("resume.json"))
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
array of strings. Pass the result to any renderer that takes JSON Resume
data, such as [`altacv`](https://typst.app/universe/package/altacv):

<!-- Bump this altacv pin by hand when altacv publishes a new version: release-please only owns gairm-import's. -->

```typst
#import "@preview/altacv:1.9.0": alta, altacv
#show: altacv.with()
#alta(resume)
```

Upstream sets `additionalProperties: true` at the top level and on every
section's items, so a misspelt `positon` is kept rather than reported.
[REFERENCE.md](REFERENCE.md#a-stricter-json-resume) shows how to close
the objects, check full dates and make the free-text fields `content`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE).
