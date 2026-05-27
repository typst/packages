#import "@preview/jastylest:0.2.0"
#import jastylest.katex-font: * // ここを消すと標準のcal, frakが使えます

#show: jastylest.article.with(
  // seriffont: "New Computer Modern",
  // seriffont-cjk: "Harano Aji Mincho",
  // sansfont: "Arial",
  // sansfont-cjk: "Harano Aji Gothic",
  // paper: "a4",
  // font-size: 11pt,
  // cols: 1, // columns
)

#jastylest.title(
  titlepage: false, // タイトルページを作成
  title: [jarticleの使い方],
  office: [電気通信大学 情報・ネットワーク工学専攻],
  // suboffice: [第一研究室],
  // teacher: [AA教授],
  // personal: [0000000],
  author: [raygo],
  // date: datetime.today().display("[year]年[month repr:numerical padding:none]月[day padding:none]日"),
)

#outline()

= スタイル設定
```typst #show: jastylest.article.with("ここに設定") ```
のようにして、スタイルやタイトルを設定できます。

== フォント
フォントはデフォルトでNew Computer Modern・Harano Aji Mincho・Arial・Hrano Aji Gothicが設定されています。各自インストールしてもらうか、設定で変更してください。数式の一部はKaTeXフォントを使用しています。インストールをしない場合は`katex-font`は使用できません。
$ cal(M) scr(A) frak(T) H $

= 機能
Typstの機能で日本語とEnglishの間には微妙な隙間が入ります。しかし、数式$a b$では隙間が入りません。これはTypstの仕様です。これを無理やり回避する実装を行っています。

$beta$-簡約など、ハイフンを入れると隙間が入りません。また、半角(丸括弧)の両端にも隙間を入れました。



