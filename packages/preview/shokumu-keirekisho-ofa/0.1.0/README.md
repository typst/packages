# shokumu-keirekisho-ofa

Create a Japanese 職務経歴書 (shokumu keirekisho) for role-focused job
applications. The layout organizes a concise career summary, capabilities,
role history, selected projects, and self-PR.

This package contains generic placeholders only. Keep personal names, employer
details, contact information, photos, and completed application documents in a
private project.

## Quick start

Create a project from the published template, then edit `main.typ`:

```sh
typst init @preview/shokumu-keirekisho-ofa:0.1.0
cd shokumu-keirekisho-ofa
typst compile main.typ
```

For consistent Japanese rendering, install Noto Sans CJK JP locally. You can
override the package's default font with a locally available family such as Noto
Sans JP. The package does not bundle fonts because Typst packages cannot ship
them.

## API

Import the pinned version and call `shokumu-keirekisho` with a dictionary:

```typst
#import "@preview/shokumu-keirekisho-ofa:0.1.0": shokumu-keirekisho

#let data = (
  name: "氏名",
  summary: "応募職種に関連する経験、強み、今後の貢献を簡潔に記入します。",
  skills: ((label: "分野", value: "スキル・知識"),),
  career: ((period: "YYYY年MM月〜", organization: "組織名", role: "役割名", summary: "担当内容・成果", technologies: "技術"),),
)

#shokumu-keirekisho(data)
```

Supported fields are `document-date`, `name`, `professional-links`, `summary`,
`skills`, `career`, `projects`, `credentials`, `self-pr`, and `font`. Each
skill row accepts `label` and `value`; career rows accept `period`,
`organization`, `role`, `summary`, and `technologies`; project rows accept
`title`, `period`, `summary`, and `technologies`.

`font` accepts a Typst font name or font stack and defaults to Noto Sans CJK JP.

## Local development

Register the working tree as a local preview package, then compile both the
example and a freshly initialized template:

```sh
PACKAGE_PATH="$(mktemp -d)"
mkdir -p "$PACKAGE_PATH/preview/shokumu-keirekisho-ofa"
ln -s "$PWD" "$PACKAGE_PATH/preview/shokumu-keirekisho-ofa/0.1.0"

TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst compile examples/example.typ /tmp/shokumu-keirekisho-ofa-example.pdf
TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst init @preview/shokumu-keirekisho-ofa:0.1.0 /tmp/shokumu-keirekisho-ofa-init
TYPST_PACKAGE_PATH="$PACKAGE_PATH" typst compile /tmp/shokumu-keirekisho-ofa-init/main.typ /tmp/shokumu-keirekisho-ofa-template.pdf
```

The initialized template must compile without edits.

## License and acknowledgements

The template source is MIT licensed; see [LICENSE](LICENSE). This is an
original layout informed by publicly available Japanese career-document
guidance and is not an official government form.

The template was also informed by:

- [hadronic-rirekisho](https://typst.app/universe/package/hadronic-rirekisho/)
- [ShinoharaTa/typst-work-resume](https://github.com/ShinoharaTa/typst-work-resume)
- Hello Work's [rirekisho and shokumu keirekisho guidance](https://www.hellowork.mhlw.go.jp/member/career_doc01.html?openExternalBrowser=1)
- Hello Work's [career-history workbook](https://www.hellowork.mhlw.go.jp/doc/shokurekisho_workbook_202205.pdf)
- The MHLW's [fair-recruitment guidance](https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/koyou/newpage_56780.html?media=10803&media=713)
