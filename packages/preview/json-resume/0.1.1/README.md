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
#import "@preview/json-resume:0.1.1": validate-resume, coerce-resume, parse-resume // x-release-please-version
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

`parse-resume` is the one-call entry point. It accepts either a parsed dict
or a Typst-root-relative path string:

```typst
#import "@preview/json-resume:0.1.1": parse-resume // x-release-please-version

// Path relative to your own .typ — let Typst's json() resolve it.
#let resume = parse-resume(json("resume.json"))

// Or a Typst-root-relative path string, resolved by parse-resume itself.
#let resume = parse-resume("/resume.json")
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
#import "@preview/json-resume:0.1.1": parse-resume // x-release-please-version

#alta(
  parse-resume(json("resume.json")),
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
#import "@preview/json-resume:0.1.1": validate-resume, coerce-resume // x-release-please-version

#let raw = json("resume.json")
#let errors = validate-resume(raw)
#if errors.len() > 0 {
  [Resume has #errors.len() issue(s).]
} else {
  let model = coerce-resume(raw)
  // render model …
}
```

## Errors

`validate-resume` returns a list of `(path, message)` records — empty list
means the input is valid. `parse-resume` calls `validate-resume` first and
aborts compilation with a combined report on the first invocation that finds
issues, so every problem in the document surfaces in one error:

```text
error: assertion failed: json-resume: found 3 problems in the input:
  - basics.email: expected string, got integer.
  - work[0].positon: unknown key "positon". Valid keys: name, location, description, position, url, startDate, endDate, summary, highlights.
  - meta.foo: unknown key "foo". Valid keys: canonical, version, lastModified.
```

## Scope

This package implements **only** the canonical JSON Resume schema.
Template-specific extensions (theme colours, header decorations, label
overrides, …) are layered on top by the consuming renderer. Requests for
renderer-specific fields will be redirected to the relevant template repo.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Releases are cut by
[release-please](https://github.com/googleapis/release-please) from
conventional-commit titles on `main`.

## License

[MIT](LICENSE).
