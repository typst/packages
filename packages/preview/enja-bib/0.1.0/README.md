# enja-bib
日本語／英語文献 Typstパッケージ

A package for handling BibTeX that includes both English and Japanese.
Licensed under MIT.

## 本パッケージの特徴

- 日本語文献と英語文献が混在した文書に対応
    - 日本語文献と英語文献で異なる設定が可能
    - yomiフィールドの利用で，日本語文献のアルファベット順に並び替えが可能
- typstで使用される`bibliography`関数を使用しないため，CSLファイルによる設定が不要（代わりに`bib-style/bib-setting-custom/bib-setting-〇〇.typ`ファイル内で設定）
- 文中のどこでも引用が可能（`citet`，`citep`関数が利用可能）
- 「アルファベット順並び替え／リスト順」「引用文献のみ／全て表示」「バンクーバー／ハーバード方式表示」の切り替えが可能

> それぞれの関数に引数を加えることで，デフォルトのスタイルの一部を簡単に変更できます．
> 変更方法は以下を参照．

## パッケージの使い方

### Typst Universeを使用する方法

1. 自分のtypstファイルの最初の方に以下を追記
    ```typst
    #import "@preview/enja-bib:0.1.0": *
    #import bib-setting-plain: *
    #show: bib-init
    ```

### フォルダを直接コピーする方法

1. `bib-style`フォルダを自分のディレクトリにコピー
1. 自分のtypstファイルの最初の方に以下を追記
    ```typst
    #import "bib-style/lib.typ": *
    #import bib-setting-plain: *
    #show: bib-init
    ```
1. 自分のtypstファイルの中で文献を挿入したい部分に，`bibliography-list`関数を利用して文献を書く
    ```typst
    #bibliography-list(
        ..bib-file(read("mybib_jp.bib")),
    )
    ```

> 現在すぐに使用可能なスタイル一覧
> - `bib-setting-plain`：bibtexの`jplain`を再現したスタイル
> - `bib-setting-jsme`：日本機械学会の引用を再現したスタイル

## それぞれの関数の使い方

### `bibliography-list`関数

この関数の中に，`bib-file`，または`bib-item`関数を入れる．
それぞれの文献ごとにカンマで区切ること．

```typst
#bibliography-list(
  ..bib-file(read("mybib_jp.bib")),
  bib-item(
    label: <Reynolds:PhilTransRoySoc1883>,
    author: "Reynolds",
    year: "1883",
    yomi: "reynolds, o.",
    (
        [Reynolds, O., An experimental investigation of the circumstances which determine whether the motion of water shall be direct or sinuous, and of the law of resistance in parallel channels, Philosophical Transactions of the Royal Society of London (1883],
        [), Vol. 174, pp. 935–982]
    )
  ),
  //...複数の項目を追加可能
)
```

任意引数
- `title` : 文献タイトル（デフォルト：`文　　献`）


### `bib-file`関数

`.bib`形式のファイルを読み込む

例：
```typst
#bibliography-list(
  ..bib-file(read("mybib_jp.bib")),
)
```

`bib-file`関数には，`read`で囲われた`.bib`ファイル名を入れる

> `bib-file`関数は複数文献の配列として返すため，`..`の記述が**必須**であることに注意

### `bib-item`関数

`bib-file`関数の代わりに，文献を直書きする

例：
```typst
#bibliography-list(
  bib-item(
      label: <Reynolds:PhilTransRoySoc1883>,
      author: "Reynolds",
      year: "1883",
      yomi: "reynolds, o.",
      (
          [Reynolds, O., An experimental investigation of the circumstances which determine whether the motion of water shall be direct or sinuous, and of the law of resistance in parallel channels, Philosophical Transactions of the Royal Society of London (1883],
          [), Vol. 174, pp. 935–982]
      )
  ),
)
```

直書き要素には，`content`型か`array`型を利用する．
`array`型では直書き成分を上記のように2つに分けることで，その間に`year-doubling`が設定される．

引数
- `label` : ラベル（引用する際には必須）
- `author` : 著者名（引用時・重複判別に用いられる）
- `year` : 年（引用時・重複判別に用いられる）
- `yomi` : 読み（並び替えに用いられる）

### `citet`，`citep`，`citen`, `citefull`関数

文中で引用するときに使用する関数．`@...`のように書いても引用できるが，
```typst
 #citet(<Reynolds:PhilTransRoySoc1883>)
```
のように書くことで引用も可能．
それぞれの関数は，複数の文献入力にも対応（例：`#citet(<Reynolds:PhilTransRoySoc1883>, <Matsukawa:ICFD2022>)`）

異なる引用形式が必要な場合には，下記の方法に従って新たに設定が可能

---

## 独自のスタイルを適用する方法

`bib-setting-plain`や`bib-setting-jsme`以外の独自のスタイルを設定，或いは一部を変更するには，それぞれの関数に引数を設定します．

### 全体設定

```typst
#bibliography-list(
  year-doubling,
  bib-sort,
  bib-sort-ref,
  bib-full,
  bib-vancouver,
  vancouver-style,
  bib-year-doubling,
  bib-vancouver-manual,
  ...
)
```

- `year-doubling`：著者・年が同じ文献がある場合に番号を付与するため，その番号を付与する位置を指定する特殊文字列（`string`型）
- `bib-sort`：アルファベット順にソートを行うか（`bool`型）
- `bib-sort-ref`：引用されている順番にソートを行うか（`bool`型）
- `bib-full`：引用されている文献だけでなく全ての文献を表示するか（`bool`型）
- `bib-vancouver`：vancouverスタイル設定時の番号付け（`string`型）
- `vancouver-style`：vancouverスタイルにするか（`bool`型）
- `bib-year-doubling`：重複著者・年号文献の year-doubling に表示する文字列（`string`型）
- `bib-vancouver-manual`：`bib-vancouver = "manual"`のときの設定

### 参照設定

```typst
#bib-init(
  bib-cite
)
```

- `bib-cite`：citeを設定する配列(`array`型)

  ```typst
  ([], bib-citet-default, [; ], [])
  ```

  **配列の構造**
  1. 参照時の一番最初に出力する文字(`content`型)
  2. 出力する文字列を生成する関数(`function`型)
  3. 2つ以上の文献で，文献間に出力する文字(`content`型)
  4. 参照時の一番最後に出力する文字(`content`型)

  > 上の例では，`Reynolds (1883); Reynolds (1883)`のように出力されます

  2番目の要素である`function`型には，
  - `bib-citet-default`：文中引用形式
  - `bib-citep-default`：文末引用形式
  - `bib-citen-default`：番号引用形式
  - `bib-citefull-default`：文献スタイルで引用する形式
  - `bib-cite-authoronly`：著者名のみ引用する形式
  - `bib-cite-yearonly`：年のみ引用する形式

  が選択できますが，以下のように独自に設定が可能です．
  以下は，`bib-citet-default`の例です．

  ```typst
  #let bib-citet-default(bib_cite_contents) = {
    return bib_cite_contents.at(0) + [~(] + bib_cite_contents.at(1) + [)]
  }
  ```

  **引数**
  1. `bib_cite_contents`：`cite`を構成する要素．
     (`著者名`, `年号`, `引用番号`, `文献`)が入っている

### `cite`系関数

デフォルトで使用できる引用スタイルは，`citet`，`citep`，`citen`，`citefull`です．
これらを書き換えるには，以下の引数を設定します．

```typst
#citet(
  bib-citet,
)
```

- `bib-citet`：上記の`bib-cite`と同様

### `bib-file`の設定


```typst
#bib-file((
  year-doubling,
  bibtex-article-en,
  bibtex-article-ja,
  bibtex-book-en,
  bibtex-book-ja,
  bibtex-booklet-en,
  bibtex-booklet-ja,
  bibtex-inbook-en,
  bibtex-inbook-ja,
  bibtex-incollection-en,
  bibtex-incollection-ja,
  bibtex-inproceedings-en,
  bibtex-inproceedings-ja,
  bibtex-conference-en,
  bibtex-conference-ja,
  bibtex-manual-en,
  bibtex-manual-ja,
  bibtex-mastersthesis-en,
  bibtex-mastersthesis-ja,
  bibtex-misc-en,
  bibtex-misc-ja,
  bibtex-online-en,
  bibtex-online-ja,
  bibtex-phdthesis-en,
  bibtex-phdthesis-ja,
  bibtex-proceedings-en,
  bibtex-proceedings-ja,
  bibtex-techreport-en,
  bibtex-techreport-ja,
  bibtex-unpublished-en,
  bibtex-unpublished-ja,
  bib-cite-author,
  bib-cite-year,
)
```

- `year-doubling`：全体設定と同様（`string`型）
- `bibtex-...`：各フィールドの設定（`array`型）

    **命名規則**

    `bibtex-(フィールド名)-(言語)`

    **例**

    ```typst
    #let bibtex-article-en = (
        ("author", (none,"",author-set3, "", ". ", (), ".")),
        ("title", (none,"",title-en, "", ". ", (), ".")),
        ("journal", (none,"",all-emph, "", ", ", (), ".")),
        //...出力する項目を順に並べる
    )
    ```

    - 各配列は，出力する項目の順に並べる（上の例では，`author`，`title`，`journal`の順に出力される）
    - `bibtex`内に無い項目は飛ばされる（上の場合，`title`の項目が`bibtex`内にない場合は`author`と`journal`のみが出力される）
    - `bibtex`内にあっても，配列の中に含まれない場合は出力されない（上の例では，`author`，`title`，`journal`のみ出力される）

    **各項目の書き方**

    ```typst
    ("author", (none,"",author-set3, "", ". ", (), "."))
    ```

    1. 項目名（`string`型）
    2. 出力形式を決定する配列（`array`型）

        1. 1つ前の項目がAのとき，前の語尾文字列を削除して置き換える先頭文字列（`content`,`string`型）
        2. 必ず出力される文字列（`content`,`string`型）
        3. 出力される文字列を出力する関数（`function`型）
        4. 最後でない限り必ず出力される語尾文字列（`content`,`string`型）
        5. 1つ後の項目のAに書かれていない，かつ最後でない場合に出力される語尾文字列（`content`,`string`型）
        6. 場合A（`array`型）
        7. 最後の場合に出力される文字列（`content`,`string`型）

- `bib-cite-author`：`cite`の`author`を返す関数（`function`型）

- `bib-cite-year`：`cite`の`year`を返す関数（`function`型）

> それぞれの`function`型には，以下のものがすぐに使用できます．
> - `all-return`：要素の全てを返す関数
> - `all-bold`：要素を太字にして全て返す関数
> - `all-emph`：要素を斜体にして全て返す関数
> - `author-set`：項目を著者型にして返す関数 (例：英語著者名`Reynolds, Osborne` を `Reynolds O.` に変換)
> - `author-set2`：項目を著者型にして返す関数 (例：英語著者名`Reynolds, Osborne` を `O Reynolds` に変換)
> - `author-set3`：項目を著者型にして返す関数 (例：英語著者名`Reynolds, Osborne` を `Osborne Reynolds` に変換)
> - `author-set-cite`：項目をciteの著者型にして返す関数 (例：英語著者名`Reynolds, Osborne` を `Reynolds` に変換)
> - `title-en`：英語のタイトルを先頭だけ大文字にしてそれ以外を小文字にして返す関数
> - `set-url`：URLを付与して返す関数（引数に`color`を設定可能．デフォルトは`blue`）
> - `page-set`：ページ形式にして返す関数（`p.`や`pp.`をつける）
> - `page-set-without-p`：ページ形式にして返す関数（`p.`や`pp.`をつけない）
>
> これらの関数は，独自に作ることもできます．例えば，`all-emph`関数は次のように実装されています．
>
> ```
> #let all-emph(biblist, name) = {
>   return emph(biblist.at(name).sum())
> }
> ```
>
> - `biblist`：`bibtex`形式の文献エントリーの`dictionary`型
> - `name`：今呼ばれている文献エントリー名
