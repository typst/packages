# iarticle - i18n-aware article/report templates

This package provides two templates, mirroring the LaTeX `article` vs.
`report` distinction:

- **`iarticle`** - flat, starts at "section", no chapters, no forced
  page breaks, no auto table of contents by default. For papers and
  other short documents.
- **`ireport`** - "chapter" is the top level (each one starts a new
  page), sections nest under it, table of contents included by
  default. For longer, structured documents.

Both localize their own generated text (chapter/section/appendix
labels, figure/table captions, "Contents", "References", "Abstract")
based on `lang` - see `l10n/`. Supported locales:

| `lang` | locale | l10n file      |
| ------ | ------ | -------------- |
| `en`   | en     | `l10n/en.typ`  |
| `ja`   | ja     | `l10n/ja.typ`  |

`region` is also accepted and forwarded to Typst's own `text` state
(it affects Typst's built-in, language-level behavior independent of
this package's string tables); it doesn't currently pick between
locales, since neither `en` nor `ja` is script-ambiguous the way e.g.
Chinese would be. A future locale that needs region to disambiguate
(Simplified vs. Traditional Chinese, say) can add that without
changing this API - see `_locale-for` in `lib.typ`.

## To use:

```typst
#import "@preview/iarticle:0.1.1": ireport

#show: ireport.with(
    lang: "ja",
    title: "座席予約システム基本設計書"
)

= はじめに
本システムは座席予約機能を提供します。
予約管理システムと顧客管理システムのデータベースを参照します。

= アーキテクチャ
アーキテクチャについて説明します。
```

For a shorter, section-only document, use `iarticle` instead:

```typst
#import "@preview/iarticle:0.1.1": iarticle

#show: iarticle.with(
    lang: "en",
    title: "A Short Paper",
    abstract: [This paper is about...],
)

= Introduction
...
```

See [`samples/`](samples/) for fuller examples, including figures,
tables, citations, and `appendix(..)` - `report-{en,ja}.typ` for
`ireport`, `article-{en,ja}.typ` for `iarticle`. (`samples/` is
excluded from the published package bundle - see `exclude` in
`typst.toml` - to keep it small, so it won't be present in a local
`@preview` install; it's still browsable here and in the repository.)

## Fonts

`iarticle`/`ireport` take `serif-font`/`sans-font` parameters (font
fallback lists, resolved per character, so mixed Latin/CJK text keeps
working). Left as `auto` (the default), the stack used depends on the
resolved locale (the same `lang` resolution as the string table above):
a Latin-only base for `en`, plus a Japanese CJK addition for `ja`. This
is also why an English document doesn't warn about missing CJK fonts,
but a Japanese one does if none are found. Override
`serif-font`/`sans-font` at the call site rather than editing this
template; to extend the shipped defaults instead of replacing them
outright:

```typst
#import "@preview/iarticle:0.1.1": iarticle
#import "@preview/iarticle:0.1.1": default-latin-serif-font, default-cjk-serif-font

#show: iarticle.with(
  lang: "ja",
  serif-font: default-latin-serif-font
    + ("Hiragino Mincho ProN",)
    + default-cjk-serif-font.at("ja"),
)
```

## Local development

Run `install_for_test.sh` once to register this checkout as
`@preview/iarticle:0.1.1`, then compile anything under `samples/`.

Scaffold a new project from `template/` the same way an end user would:

```sh
typst init @preview/iarticle:0.1.1 my-project
```

