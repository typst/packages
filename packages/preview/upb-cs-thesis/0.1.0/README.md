# upb-cs-thesis

Typst thesis template for the **Faculty of Automatic Control and Computers** at [UNSTPB](https://upb.ro) (Universitatea Națională de Știință și Tehnologie Politehnica București).

Provides a cover page and document settings following the faculty's formatting requirements, with full bilingual support (English and Romanian).

## Usage

```typ
#import "@preview/upb-cs-thesis:0.1.0": upb-thesis, abstract, synopsis

#show: upb-thesis.with(
  langs: ("en", "ro"),
  title: "My Thesis Title",
  subtitle: "Optional Subtitle",
  author: "First Last",
  advisor: "Prof. Dr. First Last",
  year: "2026",
  logo-left: image("images/logo-poli-color9.png", width: 3cm),
  logo-right: image("images/sigla_cs.png", width: 5cm),
)

#abstract[
  Your abstract here.
]

= Introduction

...
```

## API

### `upb-thesis`

Top-level show rule. Renders the cover page and applies document settings to the body.

```typ
#show: upb-thesis.with(
  langs: ("en", "ro"),
  title: "My Thesis Title",
  subtitle: "Optional Subtitle",
  author: "First Last",
  advisor: "Prof. Dr. First Last",
  year: "2026",
  logo-left: image("images/logo-poli-color9.png", width: 3cm),
  logo-right: image("images/sigla_cs.png", width: 5cm),
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `langs` | array | `("en",)` | Language codes for cover pages — one cover rendered per entry. Supported values: `"en"`, `"ro"` |
| `title` | string | `""` | Thesis title |
| `subtitle` | string \| none | `none` | Optional subtitle |
| `author` | string | `""` | Author's full name |
| `advisor` | string | `""` | Thesis advisor's full name |
| `year` | string | `"2026"` | Year displayed on the cover |
| `project-type` | dictionary \| none | `none` | Override the project type label per language, e.g. `(en: "BACHELOR'S THESIS", ro: "LUCRARE DE LICENȚĂ")`. Defaults to `"DIPLOMA PROJECT"` / `"PROIECT DE DIPLOMĂ"` |
| `logo-left` | content | `none` | Left logo (e.g. university logo) |
| `logo-right` | content | `none` | Right logo (e.g. faculty/department logo) |

### `abstract` / `synopsis`

Render a bold-titled section for the abstract or synopsis.

```typ
#abstract[Your abstract text.]
#synopsis[Your synopsis text.]
```

### Advanced

`cover-page` and `project-settings` are exported for users who need to compose the template manually or override the defaults.
