# rirekisho-ofa

Create a two-page A4 Japanese 履歴書 (rirekisho) for role-focused job
applications. The layout follows the Ministry of Health, Labour and Welfare
(MHLW) form structure while leaving legacy personal-status fields optional.

This package contains generic placeholders only. Keep personal names, contact
details, employment history, photos, and completed application PDFs in a
private project.

## Quick start

Create a project from the published template, then edit `main.typ`:

```sh
typst init @preview/rirekisho-ofa:0.1.0
cd rirekisho-ofa
typst compile main.typ
```

For consistent Japanese rendering, install Noto Sans CJK JP locally. You can
override the package's default font with a locally available family such as Noto
Sans JP. The package does not bundle fonts because Typst packages cannot ship
them.

## API

Import the pinned version and call `rirekisho` with a dictionary:

```typst
#import "@preview/rirekisho-ofa:0.1.0": rirekisho

#let data = (
  name: "氏名",
  name-kana: "シメイ（フリガナ）",
  history: ((year: "YYYY", month: "MM", detail: "学歴・職歴の項目"),),
  qualifications: ((year: "YYYY", month: "MM", detail: "免許・資格"),),
)

#rirekisho(data)
```

Supported fields are `document-date`, `name-kana`, `name`, `birth-date`,
`address`, `phone`, `secondary-contact`, `history`, `qualifications`,
`motivation`, `preferences`, `show-legacy-fields`, `commute-time`,
`dependents`, `spouse`, `spouse-support`, and `font`.

Set `show-legacy-fields: true` only when an employer requests spouse/dependent
status, commute time, or a secondary contact. `font` accepts a Typst font name
or font stack and defaults to Noto Sans CJK JP.

To include a photo, create the image in the calling document and pass that
content through `photo`; do not pass a string path into the package:

```typst
#let data = (
  name: "氏名",
  photo: image("portrait.jpg", width: 34mm, height: 44mm, fit: "cover"),
)
```

The initialized template omits `photo`, which renders the standard empty photo
slot.

## Local development

Register the working tree as a local preview package, then compile both the
example and a freshly initialized template:

```sh
PACKAGE_PATH="$(mktemp -d)"
mkdir -p "$PACKAGE_PATH/preview/rirekisho-ofa"
ln -s "$PWD" "$PACKAGE_PATH/preview/rirekisho-ofa/0.1.0"

TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst compile examples/example.typ /tmp/rirekisho-ofa-example.pdf
TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst init @preview/rirekisho-ofa:0.1.0 /tmp/rirekisho-ofa-init
TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst compile /tmp/rirekisho-ofa-init/main.typ /tmp/rirekisho-ofa-template.pdf
```

The initialized template must compile without edits and produce exactly two A4
pages.

## License and acknowledgements

The template source is MIT licensed; see [LICENSE](LICENSE). It is an original
Typst implementation informed by the MHLW resume-form example and is not an
official government form.

The template was also informed by:

- [hadronic-rirekisho](https://typst.app/universe/package/hadronic-rirekisho/)
- [ShinoharaTa/typst-work-resume](https://github.com/ShinoharaTa/typst-work-resume)
- Hello Work's [rirekisho and shokumu keirekisho guidance](https://www.hellowork.mhlw.go.jp/member/career_doc01.html?openExternalBrowser=1)
- The MHLW's [fair-recruitment guidance](https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/koyou/newpage_56780.html?media=10803&media=713)
