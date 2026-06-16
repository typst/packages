<h1 align="center">gairm-import</h1>

<p align="center">
  <a href="https://typst.app/universe/package/gairm-import"><img alt="gairm-import on Typst Universe" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fgairm-import&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/releases"><img alt="Latest GitHub release version of gairm-import" src="https://img.shields.io/github/v/release/smur89/gairm-import?style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/actions/workflows/build.yml"><img alt="GitHub Actions build workflow status on the gairm-import main branch" src="https://img.shields.io/github/actions/workflow/status/smur89/gairm-import/build.yml?style=flat-square"></a>
  <a href="LICENSE"><img alt="MIT license badge linking to the gairm-import LICENSE file" src="https://img.shields.io/github/license/smur89/gairm-import?style=flat-square"></a>
  <a href="https://github.com/smur89/gairm-import/stargazers"><img alt="Number of GitHub stargazers for gairm-import" src="https://img.shields.io/github/stars/smur89/gairm-import?style=flat-square"></a>
</p>

<p align="center">
  Strict <a href="https://jsonresume.org/">JSON Resume</a> loader for Typst — validate a canonical <code>resume.json</code> against the <a href="https://jsonresume.org/schema">published schema</a>, then hand the normalised dict to any compatible CV template.
</p>

<p align="center">
  <sub><em>"gairm" is the Irish word for vocation — this package imports the data that describes one.</em></sub>
</p>

[JSON Resume](https://jsonresume.org/) is a portable JSON-based resume format —
one `resume.json` file rendered by many themes across many output formats.
This package brings that ecosystem to Typst: load and validate a canonical
`resume.json`, then hand the normalised dict to any compatible Typst CV
template. Strict to the published [schema](https://jsonresume.org/schema)
(canonical source at [jsonresume/resume-schema](https://github.com/jsonresume/resume-schema/blob/v1.0.0/schema.json)):
unknown fields are rejected, free-text fields are coerced to Typst `content`,
and renderer-specific extensions belong in the consuming template — not here.

## Install

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": validate, coerce, parse
```
<!-- x-release-please-end -->

## A minimal `resume.json`

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

The full canonical schema covers thirteen sections:
`basics`, `work`, `volunteer`, `education`, `awards`, `certificates`,
`publications`, `skills`, `languages`, `interests`, `references`, `projects`,
`meta`. The `$schema` top-level metadata field is also accepted. See
[jsonresume.org/schema](https://jsonresume.org/schema) for every field.

## Usage

`parse` is the one-call entry point. The recommended form is
`parse(path("resume.json"))` — the [`path`](https://typst.app/docs/reference/foundations/path/)
value resolves against your own `.typ` (not the `@preview` cache), so
you can use the natural relative path:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": parse

#let resume = parse(path("resume.json"))
```
<!-- x-release-please-end -->

A parsed dict, a `json("…")` wrap, or a Typst-root-relative `"/…"`
string are also accepted — useful on older callers or when you've
already loaded the document yourself:

```typst
// json() resolves the path against your .typ; parse takes the dict.
#let resume = parse(json("resume.json"))

// Typst-root-relative path string, resolved by parse itself.
#let resume = parse("/resume.json")
```

The returned dict is a 1:1 mirror of the canonical schema — every kind comes
from the upstream JSON Schema document. Format-annotated fields are gated by
a regex (see [Format validation](#format-validation)); everything else
passes through as JSON-native types. For example:

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
instead and pass it via the `schema:` keyword — see [Two schemas](#two-schemas).

Pass the model into any compatible renderer — e.g. [`altacv`](https://typst.app/universe/package/altacv):

<!-- Known-ugly: two fences instead of one because release-please's block
     wrap would also bump altacv:1.1.1 on every release. See
     https://github.com/typst/packages/pull/5069#discussion_r3420827761 -->

```typst
#import "@preview/altacv:1.1.1": alta, palettes
```

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": parse

#alta(
  parse(path("resume.json")),
  preferences: (accent: palettes.navy),
)
```
<!-- x-release-please-end -->

`alta(cv, labels: (:), preferences: (:))` takes the JSON-Resume-shaped dict
positionally; `labels` and `preferences` are optional dicts merged over the
template defaults. See the [altacv README](https://github.com/smur89/alta-typst#readme)
for the full surface.

### Handling validation errors yourself

Each error is a record `(path: ("basics", "email"), message: "expected string, got integer.")`. A typical step-by-step is:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": validate, coerce

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

## Errors

`validate` returns a list of `(path, message)` records — empty list
means the input is valid. `parse` validates first and aborts compilation
with a combined report on the first invocation that finds issues, so every
problem in the document surfaces in one error:

```text
error: assertion failed: gairm-import: found 3 problems in the input:
  - basics.email: expected string, got integer.
  - work[0].positon: unknown key "positon". Did you mean "position"?
  - meta.foo: unknown key "foo". Valid keys: canonical, version, lastModified.
```

When a typo is within edit distance 2 of a valid key, the message
surfaces a short "Did you mean …?" hint; otherwise it falls back to
the full valid-keys list shown for `meta.foo`.

JSON `null` is treated as if the key were absent — no validation
error, dropped from the coerced model. Null elements inside arrays
are dropped the same way. This matches the convention used by most
JSON Resume emitters, where `"summary": null` is semantically
equivalent to omitting the key. Unknown keys are still flagged even
when their value is `null`, so typos do not slip through silently.

Root null is rejected: if the entire input document is `null`,
`validate`, `coerce`, and `parse` panic with
`gairm-import: input must be a dict, got null.` The null-as-absent
policy applies to leaf positions inside a document, not to the
document itself.

## Two schemas

The package exports two values of the canonical schema:

- **`resume-schema`** — a faithful 1:1 translation of the vendored
  upstream JSON Schema document. Every kind comes from the source;
  nothing is rewritten. This is the default when you call
  `parse(data)` / `validate(data)` / `coerce(data)`.
- **`resume-schema-strict`** — adds two layered opinions on top via
  the lens API:
  - free-text fields (`basics.summary`, `work[].summary`,
    `work[].highlights[]`, etc.) are typed as Typst `content` so
    they splice directly into markup
  - iso8601 `$ref` fields (`startDate`, `endDate`, …) are validated
    as ISO-8601 dates (the upstream document doesn't carry a
    `format` annotation on them, just a regex inside a definition)

Pass `schema: resume-schema-strict` to opt in:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": parse, resume-schema-strict

#let resume = parse(path("resume.json"), schema: resume-schema-strict)
```
<!-- x-release-please-end -->

The faithful default is the source-of-truth view; the strict variant
is a renderer-ergonomics overlay. If you want a different mix, build
your own by lensing over `resume-schema` — see
[Targeted edits with lenses](#targeted-edits-with-lenses).

## Format validation

Fields the canonical schema annotates with `format: "uri"`,
`format: "email"`, or `format: "date"` are gated by a regex during
`validate` / `parse`. The patterns are deliberately permissive —
they reject obvious malformations without claiming full RFC
compliance — and each emits a path-qualified message with a
canonical example:

```text
basics.email:           expected an email (e.g. "name@example.com").
basics.url:             expected a URI (e.g. "https://example.com").
certificates[0].date:   expected an ISO-8601 date (e.g. "2024-01-15").
```

`format: "date-time"` is supported too via the `datetime-string` kind:
the canonical JSON Resume document doesn't currently carry any
`date-time` annotations, so the kind only fires when a caller
translates their own JSON Schema with `schema-from-json-schema`, or
lens-overrides a field. `date-string` accepts `YYYY` / `YYYY-MM` /
`YYYY-MM-DD`; `datetime-string` requires the full `YYYY-MM-DDTHH:MM:SS`
shape with an optional fractional component and an optional `Z` or
`±HH:MM` offset. The two are separate kinds on purpose — widening the
date regex to also match datetime values would mislabel pure-date fields.

Most date fields in JSON Resume (`work[].startDate`, `awards[].date`,
`meta.lastModified`, …) use `$ref: "#/definitions/iso8601"` rather
than `format: "date"`. The translator can't pick formats up from a
`$ref` alone, so those fields stay as plain `str` in `resume-schema`.
Switch to `resume-schema-strict` to validate them as dates, or build
your own override list with `lens-put(lens(path), schema, date-string)`.

Coercion is pass-through: format-checked values flow through to the
model as plain strings, so renderers receive
`model.basics.email == "name@example.com"` unchanged.

For ad-hoc constraints outside the four built-in formats, build a
`pattern-string(re, expected: …)` and target it via a lens or splice it
into an extension schema. JSON Schema's `pattern` keyword on a plain
string maps to this kind too — see [Supported JSON Schema keywords](#starting-from-a-json-schema-document)
for the precedence rule when both `format` and `pattern` are present:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": (
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

Typst's regex `match` finds a match anywhere in the string, so anchor
the pattern yourself if you need a full-string match — `^…$` is the
common case.

## Building an extension schema

`parse` is strict against the canonical schema by design — unknown keys
are rejected. Renderers that need their own fields (alta-typst's
`preferences`, `labels`, `focusAreas`; numeric language `rating`; publication
`type` grouping; …) can build a JSON-Resume+ schema with the public
combinators and pass it to `parse` / `validate` / `coerce` via the
`schema:` keyword:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": (
  resume-schema, parse, object, array-of, str-type, content-type,
)

// Splice the canonical shape and add renderer-specific fields.
#let altacv-schema = object((
  ..resume-schema.shape,
  preferences: object((
    accent: str-type,
    headerLayout: str-type,
  )),
  labels: object((
    work: str-type,
    education: str-type,
  )),
  focusAreas: array-of(content-type),
))

#let model = parse(path("resume.json"), schema: altacv-schema)
// render model with the renderer's own theme…
```
<!-- x-release-please-end -->

When to reach for which API:

- **`parse(data)`** — one call, aborts compilation with a combined report on
  validation issues. Defaults to the canonical schema; pass `schema: …` to use
  an extension.
- **`validate(data)` / `coerce(data)`** — return data instead of aborting, so
  you can present errors yourself (see the [step-by-step above](#handling-validation-errors-yourself)).
  Same `schema:` default.

`resume-schema.shape` is a plain dict, so `..resume-schema.shape` is the only
operator you need to extend it. Per-section combinators (`work-item`,
`volunteer-item`, …) are intentionally not exposed yet — splice the canonical
top-level fields whole and add your own siblings.

### Targeted edits with lenses

Splicing `..resume-schema.shape` works for top-level additions but is awkward
when the field you want to touch is three or four levels deep (`work` items'
`highlights` element schema, `basics.email`, …). For those cases, lenses target
a path inside the schema and return a new schema with the targeted node
replaced or transformed:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": (
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

Path segments: object keys as strings, the literal `"items"` to enter an
array's element schema. Composition (`lens-then(a, b)`) concatenates paths,
so `lens-then(lens(("work",)), lens(("items", "highlights")))` is the same
lens as `lens(("work", "items", "highlights"))`. The empty path `lens(())`
is the identity lens.

Operations:

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

Operations are functional — every `lens-put` / `lens-over` / `add-field` /
`remove-field` / `set-required` / `unset-required` returns a NEW schema and leaves the input untouched, so you
can build an extension schema by chaining edits without disturbing the
canonical one. (Operations are top-level functions rather than methods because
Typst parses `lens.put(…)` as a type-method lookup, not a closure call.)

### Inspecting a schema

When an extension schema misbehaves, `describe-schema`, `paths-of-kind`,
and `kind-at` answer the three usual questions — *what does this thing
look like?*, *where do my date strings live?*, *what kind is at this
path?* — without `repr(schema)` or hand-walking `.shape`:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": (
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

Array segments in returned path tuples use `"items"` so they plug
straight into `lens(path)`; the `[]` suffix in `describe-schema`'s
output is human-friendly visual only. Keys sort alphabetically so
diffs across schema versions stay stable.

The real leverage comes from folding `paths-of-kind` together with
`lens-put` to bulk-edit every field of a kind in one pass — the list
of paths is derived from the schema, so new fields an upstream JSON
Resume bump introduces are covered automatically:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": (
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

### Starting from a JSON Schema document

`schema-from-json-schema(parsed-schema)` translates a JSON Schema (draft 7
subset) into a Typst schema dict. Use it when you already have an authoritative
`.json` schema and don't want to keep a parallel Typst copy in sync:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.7.0": (
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

Supported JSON Schema keywords: `type` (`string`/`number`/`integer`/`array`/
`object`), `format` (`uri` → `uri-string`, `email` → `email-string`,
`date` → `date-string`, `date-time` → `datetime-string`),
`pattern` → `pattern-string` (on plain string schemas only — when both
`format` and `pattern` are present on the same node, `format` wins and
`pattern` is dropped; compose two gates yourself via a lens if you
need both), `enum` → `enum-of`, `const` → `const-of`,
`properties`, `required`, `items`, internal `$ref`
(`#/definitions/…` / `#/$defs/…`). Out of scope:
`allOf` / `anyOf` / `oneOf` / `not`,
`if` / `then` / `else`, `dependencies` (and the `dependentRequired` /
`dependentSchemas` variants), open object schemas (`type: "object"` without
`properties`), `type: [...]` union arrays, external `$ref`, and string formats
other than the four listed above — every one of these panics with a clear
"unsupported" message rather than silently dropping the constraint.

## Scope

The canonical surface — `parse`, `validate`, `coerce` —
implements **only** the [JSON Resume schema](https://jsonresume.org/schema) and
rejects unknown fields. Renderer-specific extensions are layered on top by the
consuming template via the BYO API above; requests for renderer-specific
fields in the canonical schema itself will be redirected to the relevant
template repo.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Releases are cut by
[release-please](https://github.com/googleapis/release-please) from
conventional-commit titles on `main`.

## License

[MIT](LICENSE).
