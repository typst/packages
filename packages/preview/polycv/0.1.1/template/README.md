# My CV & cover letter

Created from the [polycv](https://github.com/bbinet/polycv) Typst template.
It's data-driven: you fill in the YAML (or TOML) files and compile. For everyday
changes you don't edit the `.typ` files - but they're yours to tweak for advanced
options (colours, fonts...); see the [polycv README](https://github.com/bbinet/polycv#advanced-template-parameters).
Only the polycv package itself is off-limits.

## Prerequisites

- [Typst](https://github.com/typst/typst) (or the [web app](https://typst.app))
- Fonts **IBM Plex Sans** and **Font Awesome 7 Free** as system fonts (local CLI only)

## Files

| File | What it is |
| --- | --- |
| `cv.yml` | Your CV data (personal info, experience, skills...) |
| `letter.yml` | A cover letter |
| `cv.typ`, `letter.typ`, `application.typ` | Entrypoints you compile (edit only for advanced options) |
| `.toml` variants | Same data in TOML, if you prefer it to YAML |
| `FIELDS.md` | Every available field, its type and a one-line description |

Pick **one** format and delete the other (`.yml` or `.toml`); mixing works but
is noise. For TOML, add `--input fmt=toml` when you compile.

## Build

```sh
typst compile cv.typ            # -> cv.pdf
typst compile letter.typ        # -> letter.pdf
typst compile application.typ   # CV + letter in one PDF
```

An optional `Makefile` is included for local use: `make` builds every
`cv*`/`letter*` whose source changed (and, when you edit a base, only the
variants that inherit it), and `make watch` live-previews them all.

## Bilingual & per-company CVs

The filename prefix before the first `-` picks the template: `cv-*.yml` uses
`cv.typ`, `letter-*.yml` uses `letter.typ`. So a bilingual CV is just two
files, `cv-en.yml` and `cv-fr.yml` - both build automatically (set
`meta: locale` in each).

To customize a CV for one company without duplicating everything, create a
file that **inherits** from a base and overrides only what differs:

```yaml
# cv-acme.yml
inherit: cv.yml          # path relative to this file
cv:
  summary: A summary rewritten for Acme.
  experience:
    - ~                  # ~ (null) keeps the parent entry untouched
    - highlights:
        - ~
        - A highlight that speaks to Acme's needs.
```

The template deep-merges your file over the resolved parent (dicts by key,
arrays by index, `null`/`~` keeps the parent value). Inheritance chains.

## Validation

Your data is validated against the schema **when you compile**: an invalid field
stops the build and names it (e.g. `/meta/locale`), so mistakes surface right
away, everywhere - including the Typst web app. Nothing extra to install.

Editors help too: the `# yaml-language-server: $schema=...` header lets an editor
with the [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
(or [Tombi](https://tombi-toml.github.io/tombi/) for TOML) extension underline
the exact line and autocomplete every field as you type.

See [`FIELDS.md`](FIELDS.md) for the full list of fields.
