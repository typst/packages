# precis-upb-cs

Typst thesis template for the **Faculty of Automatic Control and Computers** at [UNSTPB](https://upb.ro) (Universitatea Națională de Știință și Tehnologie Politehnica București).

Provides a cover page and document settings following the faculty's formatting requirements, with full bilingual support (English and Romanian).

## Usage

```typ
#import "@preview/precis-upb-cs:0.1.0": upb-thesis, abstract, synopsis

#show: upb-thesis.with(
  langs: ("en", "ro"),
  title: (en: "My Thesis Title", ro: "Titlul Tezei Mele"),
  subtitle: (en: "Optional Subtitle", ro: "Subtitlu Opțional"),
  author: "First Last",
  advisor: "Prof. Dr. First Last",
  year: "2026",
  logo-left: image("images/logo-university.png", width: 3cm),
  logo-right: image("images/logo-faculty.png", width: 5cm),
)

#abstract[
  Your abstract here.
]

= Introduction

...
```

A single string can be used when the same title applies to all cover pages.

## API

### `upb-thesis`

Top-level show rule. Renders the cover page and applies document settings to the body.

```typ
#show: upb-thesis.with(
  langs: ("en", "ro"),
  title: (en: "My Thesis Title", ro: "Titlul Tezei Mele"),
  subtitle: (en: "Optional Subtitle", ro: "Subtitlu Opțional"),
  author: "First Last",
  advisor: "Prof. Dr. First Last",
  year: "2026",
  logo-left: image("images/logo-university.png", width: 3cm),
  logo-right: image("images/logo-faculty.png", width: 5cm),
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `langs` | array | `("en",)` | Language codes for cover pages — one cover rendered per entry. Supported values: `"en"`, `"ro"` |
| `title` | string \| dictionary | `""` | Thesis title. Pass a dictionary for per-language titles, e.g. `(en: "My Title", ro: "Titlul Meu")` |
| `subtitle` | string \| dictionary \| none | `none` | Optional subtitle. Pass a dictionary for per-language subtitles, e.g. `(en: "Subtitle", ro: "Subtitlu")` |
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

## Logos

The logo files included in the template (`template/images/logo-university.png` and `template/images/logo-faculty.png`) are the property of [UNSTPB](https://upb.ro) and the Faculty of Automatic Control and Computers, respectively. They are included with permission and may be freely used for creating thesis documents at the faculty. They are **not** covered by the MIT license that applies to the template code.
