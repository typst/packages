#import "@preview/mantys:0.1.4": *
#import "@preview/tidy:0.2.0"
#import "@preview/cmarker:0.1.1"

#import "/lib.typ": *

#show link: it => {
  set text(fill: blue)
  it
}

#show raw: it => {
  set text(size: 10pt, font: "JetBrains Mono")
  it
}

#set page(paper: "a4")

#let infos = toml("../typst.toml")
#show: mantys.with(
  ..infos,
  title: "kǒuhú",
  subtitle: "口胡",
  date: datetime.today(),
  abstract: [
    #link("https://typst.app/universe/package/kouhu")[`kouhu`] (口胡 in Chinese) is typst package aimed at generating Chinese lipsum text (a.k.a. blind text). It provides a set of built-in text samples containing both Simplified and Traditional Chinese characters. You can choose from generated fake text, classic or modern Chinese literature, or specify your own text.

    The idea of `kouhu` is inspired by #link("https://ctan.org/pkg/zhlipsum")[`zhlipsum`] LaTeX package and #link("https://typst.app/universe/package/roremu")[`roremu`] Typst package.
    All builtin text samples are excerpted from `zhlipsum` (w/o non-UTF-8 paragraphs). Please refer to #link("http://mirrors.ctan.org/macros/latex/contrib/zhlipsum/zhlipsum-en.pdf")[its documentation] for their detailed description.
    #text(font: "Noto Serif CJK SC", size: 10pt, (
      for k in builtin-text-list().keys() {[
        + #raw(k): #kouhu(builtin-text: k, indices: 1, length: 70)
        #parbreak()
      ]}
    ))
  ],
  examples-scope: (kouhu: kouhu, builtin-text-list: builtin-text-list),
  titlepage: titlepage.with(toc: false),
  index: none
)

= Usage

#tidy-module(
  read("../lib.typ"),
  name: "Kouhu",
  show-outline: false,
  include-examples-scope: true,
  extract-headings: 1,
  tidy: tidy
)

= GitHub README

#cmarker.render(read("../README.md"), h1-level: 2)
