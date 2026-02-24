# Typstの日本語テンプレート

Typstの日本語テンプレートを作成しました．修正点があればissueにあげるか，pull
requestを送ってください．

## Typstのインストール

ここでは，VSCodeを用いたインストール方法を記載します．その他の方法は，

- Web版を使いたい場合 : [公式ページ](https://typst.app/)
- Terminal上で使いたい場合 : [GitHub](https://github.com/typst/typst)

を参照してください．

VSCodeにどちらかの拡張機能を入れます．

- Typst LSP (公式)
- Tinymist Typst (おすすめ)

このテンプレートを使用する場合は次のフォントをインストールしてもらうか，別のフォントを指定する必要があります．再起動が必要かもしれません．

- [原ノ味フォント](https://github.com/trueroad/HaranoAjiFonts)
- [katex-fonts](https://github.com/KaTeX/katex-fonts/tree/master)

具体的な使い方は[公式ドキュメント](https://typst.app/docs/)か解説ブログをご覧ください。

## このテンプレートの使い方

次のように`import`を使ってこのテンプレートを読み込みます．

```typst
#import "@preview/jastylest:0.1.0"
```

## ダウンロードする場合

importには絶対パスを指定できないので，パッケージとしてあげます．詳しくは[こちら](https://github.com/typst/packages?tab=readme-ov-file#local-packages)を参照してください．

1. dataディレクトリに`typst/packages/local/japanese-template/0.1.0/typst.toml`を作成します．
1. 以下のコードを入力します．
1. `typst.toml`と同じディレクトリ内にこのリポジトリを`package`という名前でシンボリックリンクを作成します．

```toml
[package]
name = "jastylest"
version = "0.1.0"
entrypoint = "package/jastylest.typ"
authors = ["raygo"]
```

シンボリックリンクの作り方は

- Windows(コマンドプロンプト管理者実行) : `mklink /D package <このディレクトリ>`
- macOS/Linux : `ln -s <このディレクトリ> package`

## Tinymistの使い方

詳しくは[こちら](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)を参照してください．

- 右上の虫眼鏡がついているアイコンをクリックするとプレビューが開きます．
- typstファイルの先頭にある`Export PDF`をクリックするとPDFに変換されます．
- 設定ファイルに`"tinymist.formatterMode": "typstyle"`を書き込むとフォーマットされます．

## サンプル

- ドキュメントを作成したい場合は，[document.typ](./template/document.typ)を参考にしてください．
- スライドを作成したい場合は，[slide.typ](./template/slide.typ)を参考にしてください．
