Typst port of the `kulemt` LaTeX class, the master's thesis template of the
KU Leuven Faculty of Engineering Science. Same cover, title, copyright and
transparency pages as the LaTeX version, and the same option names.

## Usage

```typ
#import "@preview/kulemt:2.2.0": template

#show: template.with(
  title: "The best master's thesis ever",
  academic-year: 2025,
  authors: ("First Author",),
  promotors: ("Prof. dr. ir. Knows Better",),
  assessors: ("Ir. Kn. Owsmuch",),
  supervisors: ("Ir. An Assistent",),
  degree: (
    name: "Master of Science in Electrical Engineering",
    options: ("option Electronics and Chip Design",),
  ),
  language: "en",
  english-master: true,
)

= Introduction

Your text here.
```

To start from the full template instead, with example chapters, a bibliography
and an appendix already wired up:

```sh
typst init @preview/kulemt:2.2.0
```

## Your programme

`degree` is free text, and getting it right is your responsibility. Copy the
official wording for your programme and option from the faculty's programme
list and paste it verbatim. Nothing is looked up and nothing is checked. Each
option carries its own `option ` or `hoofdoptie ` prefix, exactly as the
faculty lists it.

`english-master`, not `language`, decides the language of the cover, title and
copyright pages and which faculty logo is used. That matches kulemt.

## Options

Layout, mirroring the kulemt class options: `bind`, `twoside`,
`twoside-lr-equal`, `cover-page-only`, `front-pages-only`, `article`,
`electronic-version`, and `font-size`, which is 10pt or 11pt only, as in
kulemt.

Front and back matter: `preface`, `abstract`, `dutch-summary`, `abbreviations`,
`symbols`, `bibliography`, `appendices`, and `list-of-figures`,
`list-of-tables` and `list-of-listings`. Figures and tables share one section,
like `\listoffiguresandtables`.

The transparency statement is on by default through `transparency-statement`.
Fill it in from your document with `transparency-ticks`,
`transparency-answers` and `transparency-uses` instead of editing the form by
hand.

The rest: `subtitle`, `faculty`, `address`, `logo`, `link-color`, `cite-color`
and `url-color`.

## Licensing

The package is under the LPPL 1.3c. The `template/` directory is under MIT-0,
so a thesis written from this template carries no attribution or license-text
obligation. See [LICENSE](LICENSE).

`src/` is derived from
[modern-se-kul-thesis](https://typst.app/universe/package/modern-se-kul-thesis/)
by Benjamin Eeckhout, used under the MIT license.
