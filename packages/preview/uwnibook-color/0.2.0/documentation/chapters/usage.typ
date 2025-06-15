#import "@preview/cheq:0.2.2": checklist
#import "@preview/zebraw:0.5.5": zebraw
#import "@preview/treet:0.2.0": *
#import "../packages.typ": components, note
#show: checklist
#show: zebraw.with(numbering: false)

= 說明書



== 快速入門

=== 使用範本

君可以 shell 命令復刻簡單範本。

```sh
  typst init @preview/uwnibook-color:0.2.0
```

範本內已有 uwnibook-color 模板之基礎。循理衍其文章，行快而便也。惟範本素而不飾，本冊 @chap:example 各例悉備，可以效也。

=== 結構
範本結構如是：

#[
  #set par(first-line-indent: 0pt)
  `./`

  #tree-list(marker-font: "Maple Mono NF")[
    - *`main.typ`*
    - `uwni-book.typ`
    - `citation.bib`
    - `chapters/`
      - `preamble.typ`
      - `1_intro.typ`
      - `appendix.typ`
  ]
]

於 `./` 目錄，行下列命令以成書#note[或以 IDE 揷件 #link("https://github.com/Myriad-Dreamin/tinymist")[Tinymist]]

```sh
typst compile main.typ
```

`main.typ` 全書之本也，開之，所見如此

#raw(read("../../boilerplate/main.typ"), lang: "typst", block: true)



/ 序: `#preamble(content)`
/ 目次: `#outline()`
/ 正文: `#mainbody(content)`
/ 附錄: `#appendix(content)`
/ 索引: `#make-index()`

體例凡三級，曰「章」，1 級 Heading 也。曰「節」，2 級 Heading 也。曰「小節」，3 級 Heading 也。餘者莫為飾。


== 基本特性
TODO, 写文档的复杂度超出了我的预料（ 暂时可参考后文的用法
=== 雙面式樣

=== 辭彙索引
=== 環境與引用

== 進階功能與預設

=== 以備付梓
- [ ] 出血及裁線以備付梓

== 解惑
- 惑於 Typst，參閱
  - 官方文檔 https://typst.app/docs/
  - 抑可入中文交流群 https://qm.qq.com/q/iDkMOD4kh4

- 惑於本書版
  - 於 GitHub Issue 垂詢
  - 入中文交流群
