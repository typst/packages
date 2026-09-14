# Gwanak SNU Thesis Typst Template Specs

This document defines the currently implemented template behavior. It is a standalone specification that does not depend on external references or past implementation history.

## 1. Public entrypoint

The only public entrypoint is `snu-thesis` from `lib.typ`.

```typst
#import "@preview/gwanak-snu-thesis:0.1.0": snu-thesis
```

Representative usage:

```typst
#show: snu-thesis.with(
  body-language: "ko",
  cover-language: "ko",
  approval-language: "ko",
  degree: "master",
  bibliography: bibliography("bibliography/references.bib", style: "apa", title: none),
  title: [Thesis Title],
  title-alt: [English Thesis Title],
)
```

## 2. Supported inputs

| Axis | Values | Behavior |
|---|---|---|
| `body-language` | `"ko"`, `"en"` | 본문 언어, heading prefix, outline label, 초록 기본 순서. |
| `cover-language` | `"ko"`, `"en"`, `none` | 표지 표시 언어. `none`이면 `body-language`를 따릅니다. |
| `approval-language` | `"ko"` | 석사/박사 인준지 언어. |
| `degree` | `"bachelor"`, `"master"`, `"phd"` | 학위별 표지 문구와 인준지 요구 여부. |
| `bibliography` | content or `none` | 사용자가 구성한 heading-free bibliography content. |
| `appendices` | array/content or `none` | 부록 출력과 부록별 counter reset. |
| `fonts` | array | 문서 전체에 적용되는 font family 후보. |
| `paper-size` | `"default"`, Typst paper string, dictionary | Page size. `"default"` resolves to `190mm × 260mm`; strings are passed to Typst `paper`; dictionaries must include `width` and `height`. |
| `page-margin` | dictionary or `none` | Page margin override for cover, approval, frontmatter, body, references, and appendices. |
| `draft` | `true`, `false` | Body-review mode. Skips all frontmatter and renders body, references, and appendices only. |

필수 metadata:

| Input | `bachelor` | `master` / `phd` |
|---|---:|---:|
| `title` | required | required |
| `title-alt` | required | required |
| `author` | required | required |
| `student-number` | required | required |
| `grad-date-ko` | required | required |
| `grad-date-en` | required | required |
| `abstract-ko` | required | required |
| `abstract-en` | required | required |
| `advisor` | optional | required |
| `submission-date` | optional | required |
| `approval-date` | optional | required |
| `committee` | not required | required |

When `draft: true`, frontmatter-only metadata is not required because it is not rendered. `body-language`, `degree`, `paper-size`, `page-margin`, `bibliography`, `appendices`, and body content remain active.

Removed API names are rejected by Typst argument checking: `language`, `bibliography-file`, `bibliography-style`, `profile`.

## 3. Page model

| Area | Width | Height | Left | Right | Top | Bottom |
|---|---:|---:|---:|---:|---:|---:|
| Default cover/title page | `190mm` | `260mm` | `30mm` | `30mm` | `20mm` | `15mm` |
| Default approval page | `190mm` | `260mm` | `30mm` | `30mm` | `20mm` | `15mm` |
| Default body | `190mm` | `260mm` | `30mm` | `30mm` | `20mm` | `15mm` |

Page size:

- `paper-size: "default"` uses explicit `190mm × 260mm`.
- `paper-size: "a4"` and other strings are passed to Typst as `paper`.
- `paper-size: (width: ..., height: ...)` uses explicit dimensions.
- `page-margin: (...)` overrides the default margin for every rendered page class.

Page numbering:

- Cover, title page, approval page: hidden.
- Frontmatter after approval: lowercase roman, reset to `i` at the primary abstract.
- Body onward: arabic, reset to `1` at the body start.
- Page number position: bottom center.

## 4. Typography

Document-wide text setup:

```typst
#set text(
  size: 11pt,
  font: fonts,
  lang: body-language,
  script: auto,
  top-edge: 0.8em,
  bottom-edge: -0.2em,
)
#set par(
  justify: true,
  first-line-indent: (amount: 0.5in, all: true),
  spacing: 1.04em,
  leading: 1.04em,
)
```

Meaning:

- Main text size: `11pt`.
- Paragraphs are justified.
- Paragraph first-line indent: `0.5in`.
- Line box: `top-edge: 0.8em`, `bottom-edge: -0.2em`.
- Line leading: `1.04em`.
- Paragraph spacing: `1.04em`.

Footnotes:

- Marker numbering: `1)`.
- Entry text size: `9pt`.
- Separator line between body and footnote area.

Default font stack:

```typst
(
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

Font policy:

- The default stack contains Korean serif/batang families only.
- No Latin-only fallback is included by default.
- Typst warns when a listed family is not installed; the next installed candidate is used.
- Users can pass `fonts` or CLI `--font-path` for local control.
- The initialized Universe template passes `fonts: ("NanumMyeongjo",)` explicitly to reduce local warning noise on common Korean setups.

## 5. Heading style

| Typst heading | Korean body | English body | Style |
|---|---|---|---|
| level 1 | `제 N 장 제목` | `Chapter N Title` | New page, centered, `16pt bold`, `10mm` below. |
| level 2 | `제 N 절 제목` | `Section N Title` | Left aligned, `14pt bold`. |
| level 3+ | numeric Typst numbering | numeric Typst numbering | Numeric fallback. |

Level 1 headings are treated as thesis chapters.

## 6. Document order

1. Outer cover
2. Inner title page
3. Approval page, only for `master` / `phd`
4. Primary abstract
5. Contents
6. List of tables, when `show-table-list: true`
7. List of figures, when `show-figure-list: true`
8. Body
9. References, when `bibliography != none`
10. Appendices, when `appendices != none`
11. Secondary abstract
12. Acknowledgement, when `acknowledgement != none`

Draft document order when `draft: true`:

1. Body
2. References, when `bibliography != none`
3. Appendices, when `appendices != none`

Default abstract order:

| `body-language` | Primary | Secondary |
|---|---|---|
| `ko` | `국문초록` | `Abstract` |
| `en` | `Abstract` | `국문초록` |

`abstract-languages: (primary: ..., secondary: ...)` may override the order. The two languages must differ.

## 7. Cover and title page

Cover and title page use the same renderer.

Degree wording:

| Language / degree | Text |
|---|---|
| `ko` + `bachelor` | `{academic-ko}사 학위논문` |
| `ko` + `master` | `{academic-ko}석사 학위논문` |
| `ko` + `phd` | `{academic-ko}박사 학위논문` |
| `en` + `bachelor` | `Bachelor's Thesis of {academic-en}` |
| `en` + `master` | `Master's Thesis of {academic-en}` |
| `en` + `phd` | `Ph.D. Dissertation of {academic-en}` |

Layout order:

| Order | Item | Size |
|---:|---|---:|
| 1 | Degree wording | `14pt` |
| 2 | Main title `title` | `22pt bold` |
| 3 | Companion title `title-alt` | `16pt` |
| 4 | Graduation date | `14pt` |
| 5-ko | Korean university + school (`서울대학교` + `school-ko`) | `16pt` |
| 6-ko | Department/major line (`major-ko`) | `14pt` |
| 7-ko | Author display name | `16pt` |
| 5-en | English school line (`school-en`) | `14pt` |
| 6-en | English university (`Seoul National University`) | `14pt` |
| 7-en | English major line (`major-en`) | `14pt` |
| 8-en | Author display name | `16pt` |

`cover-language: "en"` renders an English-primary cover and treats `title-alt` as the companion title slot. The template does not validate script content.

The renderer owns the fixed university name. Affiliation fields have these meanings:

- `school-ko`: Korean school/intermediate affiliation line excluding `서울대학교`; graduate default is `대학원`.
- `major-ko`: Korean department/major line excluding university and school.
- `school-en`: English school/intermediate affiliation line excluding `Seoul National University`; for official-style English covers, use a complete line such as `Graduate School of Engineering`.
- `major-en`: English major line excluding university and school; the renderer does not append `Major`.

Korean graduate covers and approval pages render `서울대학교` followed by `school-ko`, then `major-ko`; graduate examples use `school-ko: "대학원"`. Bachelor examples are outside the graduate cover/approval spec and may set `school-ko` to a college such as `공과대학`. English covers render `school-en`, then `Seoul National University`, then `major-en`, matching the provided English Ph.D. template order (`Graduate School of ○○○○` → `Seoul National University` → `○○○○ Major`). Do not include fixed university names in these fields. There is no separate `school-en-sub` field.

When frontmatter is rendered, `school-ko` must not contain `서울대학교`, and `school-en` must not contain `Seoul National University`; fixed university names are renderer-owned and duplicated inputs fail fast.

## 8. Approval page and committee

The approval page is rendered only for `master` and `phd`.

Committee model:

```typst
committee: (
  chair: "위원장 이름",
  vice-chair: "부위원장 이름",
  members: (), // master: (); phd: exactly two names
)
```

Signer rules:

| Degree | Signers |
|---|---|
| `master` | chair + vice-chair + advisor = 3 |
| `phd` | chair + vice-chair + two members + advisor = 5 |

- `advisor` is appended as the last signer.
- `advisor` / `advisor-display` must not duplicate `chair`, `vice-chair`, or `members` exactly.
- `approval-language` must be `"ko"`.

Korean approval pages render `서울대학교` followed by `school-ko`, then `major-ko`, then author.

For `bachelor`, the default output has no approval page and does not require `committee`, `advisor`, `submission-date`, or `approval-date`.

## 9. Abstract and acknowledgement

Abstract page:

- Heading is visible in the outline.
- Heading style: centered, `16pt bold`.
- Heading gap: `20mm`.
- Bottom metadata block includes keyword and student-number rows.
- Labels:
  - Korean: `주요어`, `학번`
  - English: `Keywords`, `Student Number`

Acknowledgement page:

- Heading is visible in the outline.
- Heading style: centered, `16pt bold`.
- Heading gap: `20mm`.
- Labels:
  - Korean: `감사의 글`
  - English: `Acknowledgement`

The template does not validate keyword count.

## 10. Contents, tables, and figures lists

| Language | Contents | Tables | Figures |
|---|---|---|---|
| `ko` | `목    차` | `표    목    차` | `그 림 목 차` |
| `en` | `Contents` | `List of Tables` | `List of Figures` |

Behavior:

- Each list starts on its own page.
- Table list targets `figure.where(kind: table)`.
- Figure list targets `figure.where(kind: image)`.
- `show-table-list` and `show-figure-list` control output.
- Outline entries use dotted leaders.
- The same `fonts` stack is applied to generated outline entries.

## 11. References

References are rendered only when `bibliography != none`.

Template-owned heading:

| Body language | Heading |
|---|---|
| `ko` | `참 고 문 헌` |
| `en` | `References` |

Contract:

- The user passes Typst bibliography content.
- The passed bibliography should be heading-free, typically `bibliography(..., title: none)`.
- Citation style stays inside the user's `bibliography(...)` call.

## 12. Appendices

Recommended array input:

```typst
appendices: (
  (
    title: [시뮬레이션 결과],
    body: [부록 본문],
  ),
)
```

Single appendix heading:

| Language | Heading |
|---|---|
| `ko` | `부록: 제목` |
| `en` | `Appendix: Title` |

Multiple appendix headings:

| Language | Heading |
|---|---|
| `ko` | `부록 A: 제목`, `부록 B: 제목` |
| `en` | `Appendix A: Title`, `Appendix B: Title` |

Per-appendix counter behavior:

- Reset at each appendix start:
  - image figure counter
  - table figure counter
  - math equation counter
- Prefix examples:
  - Appendix A: `Figure A1`, `Table A1`, `(A1)`
  - Appendix B: `Figure B1`, `Table B1`, `(B1)`

