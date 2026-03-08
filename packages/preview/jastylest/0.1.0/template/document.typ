#import "@preview/jastylest:0.1.0"
#import jastylest.katex-font: * // ここを消すと標準のcal, frakが使えます

#show: jastylest.article.with(
  // seriffont: "New Computer Modern",
  // seriffont-cjk: "Harano Aji Mincho",
  // sansfont: "Arial",
  // sansfont-cjk: "Harano Aji Gothic",
  // paper: "a4",
  // font-size: 11pt,
  // cols: 1, // columns
  // titlepage: true, // タイトルページを作成
  title: [jarticleの使い方],
  office: [電気通信大学 情報・ネットワーク工学専攻],
  author: [raygo],
  // date: none, // 初期値：作成日
)

#outline()

= スタイル設定
```typst #show: jastylest.article.with("ここに設定") ```
のようにして、スタイルやタイトルを設定できます。

== フォント
フォントはデフォルトでNew Computer Modern・Harano Aji Mincho・Arial・Hrano Aji Gothicが設定されています。各自インストールしてもらうか、設定で変更してください。数式の一部はKaTeXフォントを使用しています。インストールをしない場合は`katex-font`は使用できません。
$ cal(M) scr(A) frak(T) H $

= 機能
Typstの機能で日本語とenglishの間には微妙な隙間が入ります。しかし、数式$a b$では隙間が入りません。これはTypstの仕様です。これを無理やり回避する実装を行っています。

$beta$-簡約など、ハイフンを入れると隙間が入りません。また、半角(丸括弧)の両端にも隙間を入れました。



