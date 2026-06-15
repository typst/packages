<h1 align="center">json-resume</h1>

<p align="center">
  <a href="https://typst.app/universe/package/json-resume"><img alt="json-resume on Typst Universe" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fjson-resume&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&style=flat-square"></a>
  <a href="https://github.com/smur89/typst-json-resume/releases"><img alt="Latest GitHub release version of json-resume" src="https://img.shields.io/github/v/release/smur89/typst-json-resume?style=flat-square"></a>
  <a href="https://github.com/smur89/typst-json-resume/actions/workflows/build.yml"><img alt="GitHub Actions build workflow status on the json-resume main branch" src="https://img.shields.io/github/actions/workflow/status/smur89/typst-json-resume/build.yml?style=flat-square"></a>
  <a href="LICENSE"><img alt="MIT license badge linking to the json-resume LICENSE file" src="https://img.shields.io/github/license/smur89/typst-json-resume?style=flat-square"></a>
  <a href="https://github.com/smur89/typst-json-resume/stargazers"><img alt="Number of GitHub stargazers for json-resume" src="https://img.shields.io/github/stars/smur89/typst-json-resume?style=flat-square"></a>
</p>

<p align="center">
  Strict <a href="https://jsonresume.org/">JSON Resume</a> loader for Typst — validate a canonical <code>resume.json</code> against the <a href="https://jsonresume.org/schema">published schema</a>, then hand the normalised dict to any compatible CV template.
</p>

[JSON Resume](https://jsonresume.org/) is a portable JSON-based resume format —
one `resume.json` file rendered by many themes across many output formats.
This package brings that ecosystem to Typst: load and validate a canonical
`resume.json`, then hand the normalised dict to any compatible Typst CV
template. Strict to the published [schema](https://jsonresume.org/schema)
(canonical source at [jsonresume/resume-schema](https://github.com/jsonresume/resume-schema/blob/v1.0.0/schema.json)):
unknown fields are rejected, free-text fields are coerced to Typst `content`,
and renderer-specific extensions belong in the consuming template — not here.

Motivated by [smur89/alta-typst#48](https://github.com/smur89/alta-typst/issues/48).

## Install

```typst
#import "@preview/json-resume:0.2.0": validate, coerce, parse // x-release-please-version
```

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

`parse` is the one-call entry point. It accepts either a parsed dict
or a Typst-root-relative path string:

```typst
#import "@preview/json-resume:0.2.0": parse // x-release-please-version

// Path relative to your own .typ — let Typst's json() resolve it.
#let resume = parse(json("resume.json"))

// Or a Typst-root-relative path string, resolved by parse itself.
#let resume = parse("/resume.json")
```

The returned dict mirrors the canonical schema. Free-text fields (`summary`,
`description`, `highlights[]`, `reference`) are coerced to Typst `content`;
everything else stays as JSON-native types. For example:

```text
resume.basics.name            str ("Seán Ó Murchú")
resume.basics.summary         content (wrapped for direct rendering)
resume.work.at(0).position    str
resume.work.at(0).highlights  array of content
resume.skills.at(0).keywords  array of str (tag-like, not coerced)
```

Pass the model into any compatible renderer — e.g. [`altacv`](https://typst.app/universe/package/altacv):

```typst
#import "@preview/altacv:1.1.1": alta, palettes
#import "@preview/json-resume:0.2.0": parse // x-release-please-version

#alta(
  parse(json("resume.json")),
  preferences: (accent: palettes.navy),
)
```

`alta(cv, labels: (:), preferences: (:))` takes the JSON-Resume-shaped dict
positionally; `labels` and `preferences` are optional dicts merged over the
template defaults. See the [altacv README](https://github.com/smur89/alta-typst#readme)
for the full surface.

### Handling validation errors yourself

Each error is a record `(path: ("basics", "email"), message: "expected string, got integer.")`. A typical step-by-step is:

```typst
#import "@preview/json-resume:0.2.0": validate, coerce // x-release-please-version

#let raw = json("resume.json")
#let errors = validate(raw)
#if errors.len() > 0 {
  [Resume has #errors.len() issue(s).]
} else {
  let model = coerce(raw)
  // render model …
}
```

## Errors

`validate` returns a list of `(path, message)` records — empty list
means the input is valid. `parse` validates first and aborts compilation
with a combined report on the first invocation that finds issues, so every
problem in the document surfaces in one error:

```text
error: assertion failed: json-resume: found 3 problems in the input:
  - basics.email: expected string, got integer.
  - work[0].positon: unknown key "positon". Valid keys: name, location, description, position, url, startDate, endDate, summary, highlights.
  - meta.foo: unknown key "foo". Valid keys: canonical, version, lastModified.
```

JSON `null` is treated as if the key were absent — no validation
error, dropped from the coerced model. Null elements inside arrays
are dropped the same way. This matches the convention used by most
JSON Resume emitters, where `"summary": null` is semantically
equivalent to omitting the key. Unknown keys are still flagged even
when their value is `null`, so typos do not slip through silently.

Root null is rejected: if the entire input document is `null`,
`validate`, `coerce`, and `parse` panic with
`json-resume: input must be a dict, got null.` The null-as-absent
policy applies to leaf positions inside a document, not to the
document itself.

## Building an extension schema

`parse` is strict against the canonical schema by design — unknown keys
are rejected. Renderers that need their own fields (alta-typst's
`preferences`, `labels`, `focusAreas`; numeric language `rating`; publication
`type` grouping; …) can build a JSON-Resume+ schema with the public
combinators and pass it to `parse` / `validate` / `coerce` via the
`schema:` keyword:

```typst
#import "@preview/json-resume:0.2.0": ( // x-release-please-version
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

#let model = parse(json("resume.json"), schema: altacv-schema)
// render model with the renderer's own theme…
```

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

```typst
#import "@preview/json-resume:0.2.0": ( // x-release-please-version
  resume-schema, lens, lens-put, lens-over, add-field,
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
```

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

Operations are functional — every `lens-put` / `lens-over` / `add-field` /
`remove-field` returns a NEW schema and leaves the input untouched, so you
can build an extension schema by chaining edits without disturbing the
canonical one. (Operations are top-level functions rather than methods because
Typst parses `lens.put(…)` as a type-method lookup, not a closure call.)

### Starting from a JSON Schema document

`schema-from-json-schema(parsed-schema)` translates a JSON Schema (draft 7
subset) into a Typst schema dict. Use it when you already have an authoritative
`.json` schema and don't want to keep a parallel Typst copy in sync:

```typst
#import "@preview/json-resume:0.2.0": ( // x-release-please-version
  schema-from-json-schema, coerce, object, array-of, content-type,
)

#let canonical = schema-from-json-schema(json("resume-schema.json"))
#let altacv-schema = object((
  ..canonical.shape,
  focusAreas: array-of(content-type),
))

#let model = coerce(json("resume.json"), schema: altacv-schema)
```

Supported JSON Schema keywords: `type` (`string`/`number`/`integer`/`array`/
`object`), `format` (`uri`/`email`/`date`/`date-time` — currently degraded to
plain string until format-aware combinators land), `properties`, `required`,
`items`, internal `$ref` (`#/definitions/…` / `#/$defs/…`). Out of scope:
`allOf` / `anyOf` / `oneOf` / `not`, `enum` / `const`,
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
