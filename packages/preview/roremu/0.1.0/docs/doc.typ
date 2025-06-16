#import "@preview/tidy:0.2.0"

#set text(font: "Noto Serif CJK JP", size: 10pt)
#show raw: set text(font: ("Fira Code", "Noto Sans Mono CJK JP"))

#set heading(numbering: "1.1")
#set page(paper: "jis-b5")

#show link: it => {
  set text(fill: blue)
  underline(it)
} 

#let show-module = tidy.show-module

// = テンプレート
#let title(body) = {
  set text(font: "Noto Serif CJK JP", size: 20pt)
  align(center, body)
}

#let package_info = toml("../typst.toml")
#let name = package_info.package.name
#let version = package_info.package.version


#title(raw(name + " v" + version))


#outline(title: "目次")

= 概要
このパッケージは日本語のダミーテキストを生成するためのライブラリです。現在は夏目漱石『#link("https://ja.wikipedia.org/wiki/%E5%90%BE%E8%BC%A9%E3%81%AF%E7%8C%AB%E3%81%A7%E3%81%82%E3%82%8B", "吾輩は猫である")』（#link("https://www.aozora.gr.jp/cards/000148/card789.html", "青空文庫版")より一部抜粋、ルビ抜き）を元にして、特定な文字数の文章を生成できます。

= 使い方
```typst
import "@preview/roremu:0.1.0": roremu
#roremu(100)
```

== 例
#include("../test/test.typ")

= API Reference
== 関数
#let docs = tidy.parse-module(read("../src/lib.typ"))
#show-module(docs)
