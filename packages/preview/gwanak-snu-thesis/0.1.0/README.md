# Gwanak SNU Thesis Typst Template

> “Gwanak” (관악) refers to Gwanaksan, the mountain beside Seoul National University’s main campus and a common shorthand for the SNU campus.

An unofficial Typst template for Seoul National University theses. It aims to provide a practical starting point that thesis authors can use immediately. This is not an official distribution, so check the latest department and university requirements before final submission.

Language: [Korean](README.ko.md)

## Quick start

```bash
typst init @preview/gwanak-snu-thesis:0.1.0 my-thesis
cd my-thesis
typst compile main.typ
```

## Minimal document

```typst
#import "@preview/gwanak-snu-thesis:0.1.0": snu-thesis

#show: snu-thesis.with(
  body-language: "ko",
  cover-language: "ko",
  approval-language: "ko",
  degree: "master",
  academic-ko: "공학",
  academic-en: "Engineering",
  title: [논문 제목],
  title-alt: [English Thesis Title],
  author: "홍길동",
  student-number: "2026-00000",
  advisor: "김지도",
  grad-date-ko: "2026년 2월",
  grad-date-en: "February 2026",
  submission-date: "2025년 12월",
  approval-date: "2026년 1월",
  committee: (
    chair: "박위원장",
    vice-chair: "이부위원장",
    members: (),
  ),
  abstract-ko: [국문초록을 작성합니다.],
  abstract-en: [Write the English abstract here.],
  bibliography: bibliography("bibliography/references.bib", style: "apa", title: none),
)

= 서론

본문을 작성합니다.
```

## Main options

Most thesis documents only need the fields below. `content` means Typst content in brackets, such as `[논문 제목]`. `string` means quoted text, such as `"홍길동"`.

### Thesis metadata

| Option | Values | Notes |
|---|---|---|
| `title`, `title-alt` | content | Main and alternate-language thesis titles. Both are required outside `draft: true`. |
| `academic-ko`, `academic-en` | string | Academic field used in degree labels, for example `공학` / `Engineering`. |
| `school-ko`, `school-en` | string | User-owned school, college, or graduate-school line. Do not include `서울대학교` or `Seoul National University`; the template renders fixed university names automatically. |
| `major-ko`, `major-en` | string | Department, school, major, or program line printed under the school line. |
| `author` | string | Canonical author name. Required outside `draft: true`. |
| `author-display` | string or `none` | Printed author name when spacing or script differs from `author`. |
| `student-number` | string | Student number printed on abstract pages. Required outside `draft: true`. |
| `advisor` | string or `none` | Canonical advisor name. Required for master and Ph.D. approval pages. |
| `advisor-display` | string or `none` | Printed advisor name when spacing or script differs from `advisor`. |
| `grad-date-ko`, `grad-date-en` | string | Graduation date printed on covers. Required outside `draft: true`. |
| `submission-date`, `approval-date` | string or `none` | Submission and approval dates. Required for master and Ph.D. approval pages. |
| `abstract-ko`, `abstract-en` | content | Korean and English abstracts. Both are required outside `draft: true`. |
| `keywords-ko`, `keywords-en` | array | Keywords shown at the bottom of each abstract page. |

### Rendering and content controls

| Option | Values | Notes |
|---|---|---|
| `body-language` | `"ko"`, `"en"` | Body language, chapter/section labels, outline labels, and default abstract order. |
| `cover-language` | `"ko"`, `"en"`, `none` | Cover language. `none` follows `body-language`. |
| `approval-language` | `"ko"` | Master and Ph.D. approval pages are supported in Korean only. |
| `abstract-languages` | dictionary or `none` | Override abstract order, for example `(primary: "en", secondary: "ko")`. |
| `degree` | `"bachelor"`, `"master"`, `"phd"` | Degree-specific cover wording and approval-page requirements. |
| `committee` | dictionary or `none` | Required for master and Ph.D. theses; see the examples below. |
| `bibliography` | content or `none` | Pass `bibliography(..., title: none)`. The template renders the references heading. |
| `appendices` | array, content, or `none` | `((title: [...], body: [...]),)` is recommended for appendix-local counters. |
| `acknowledgement` | content or `none` | Adds an acknowledgement page after the secondary abstract. |
| `show-table-list`, `show-figure-list` | `true`, `false` | Controls table and figure list pages. |
| `fonts` | array | Font family fallback list applied to the document. |
| `draft` | `true`, `false` | `true` skips all frontmatter and renders only body, references, and appendices. |
| `paper-size` | `"default"`, Typst paper string, dictionary | `default` uses `190mm × 260mm`; strings are passed to Typst; dictionaries use `(width: ..., height: ...)`. |
| `page-margin` | dictionary or `none` | Overrides the default `30mm` left/right, `20mm` top, `15mm` bottom margins. |


Master:

```typst
committee: (
  chair: "위원장 이름",
  vice-chair: "부위원장 이름",
  members: (),
)
```

Ph.D.:

```typst
committee: (
  chair: "위원장 이름",
  vice-chair: "부위원장 이름",
  members: ("위원1", "위원2"),
)
```

The advisor is appended as the last committee signer. The advisor name cannot duplicate `chair`, `vice-chair`, or any `members` entry.

By default, bachelor theses do not require an approval page, `committee`, `advisor`, `submission-date`, or `approval-date`.

For affiliation fields, set only the user-owned school and major lines. The template renders fixed university names automatically:

```typst
school-ko: "대학원",
major-ko: "컴퓨터공학부 데이터사이언스 전공",
school-en: "Graduate School of Engineering",
major-en: "Computer Science and Engineering Major",
```

Korean graduate cover and approval pages render `서울대학교` + `school-ko`, then `major-ko`; use `school-ko: "대학원"` for graduate theses. English cover pages render `school-en` → `Seoul National University` → `major-en`; for official-style English covers, set `school-en` to a complete line such as `Graduate School of Engineering` and `major-en` to the full major line such as `Computer Science and Engineering Major`. Do not include `서울대학교` or `Seoul National University` in any affiliation field; when frontmatter is rendered, the template fails fast if either fixed university name is included in `school-ko` or `school-en`. Bachelor examples are outside the graduate thesis format and set a college line explicitly.

## Draft builds

Use `draft: true` for fast body-only review builds. Draft mode skips covers, approval pages, abstracts, contents, table and figure lists, and acknowledgement. It still renders the body, references, and appendices.

```typst
#show: snu-thesis.with(
  body-language: "ko",
  degree: "master",
  draft: true,
)
```

Draft mode does not require frontmatter-only metadata such as `title`, `student-number`, `abstract-ko`, `committee`, or approval dates.

## Page size and margins

The default `paper-size: "default"` uses `190mm × 260mm`. To use a Typst paper preset, pass its string value.

```typst
paper-size: "a4"
```

For unambiguous custom sizes, pass explicit dimensions.

```typst
paper-size: (width: 182mm, height: 257mm)
```

Override margins with `page-margin`.

```typst
page-margin: (
  left: 25mm,
  right: 25mm,
  top: 20mm,
  bottom: 20mm,
)
```

## Bibliography

Choose the bibliography style yourself. The template only controls the reference heading position and document order.

```typst
bibliography: bibliography("bibliography/references.bib", style: "apa", title: none)
```

Other styles work the same way.

```typst
bibliography: bibliography("bibliography/references.bib", style: "chicago-author-date", title: none)
```

## Fonts

The default font stack uses Korean serif/batang families only.

```typst
fonts: (
  "Noto Serif CJK KR",
  "Source Han Serif K",
  "NanumMyeongjo",
  "AppleMyungjo",
  "Batang",
  "바탕",
  "UnBatang",
  "Baekmuk Batang",
)
```

Typst warns when a listed candidate is not installed. The initialized template pins `fonts: ("NanumMyeongjo",)` to reduce warning noise on common Korean setups. To keep local builds warning-free and deterministic, pass only the font you use.

```typst
#show: snu-thesis.with(
  fonts: ("NanumMyeongjo",),
  // ...
)
```

## License

The library code is licensed under MIT. Files under `template/` are licensed under MIT-0 so generated thesis projects can be modified and redistributed without carrying attribution requirements from the starter scaffold.

## More details

- Implemented spec: [`SPECS.md`](SPECS.md)
- Copy-pasteable examples: [`examples/bachelor.typ`](examples/bachelor.typ), [`examples/master.typ`](examples/master.typ), [`examples/phd.typ`](examples/phd.typ)
