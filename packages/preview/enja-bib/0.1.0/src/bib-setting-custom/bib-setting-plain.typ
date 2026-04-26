#import "../bib-style.typ"
#import "../bib-setting-fucntion.typ": *

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 引用スタイル設定 (ここにある変数名は変えたり消したりしないよう注意)
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// 著者・年が同じ文献がある場合に番号を付与するため，その番号を付与する位置を指定する特殊文字列
#let year-doubling = "%year-doubling"

// アルファベット順にソートを行うか
#let bib-sort = true

// 引用されている順番にソートを行うか
#let bib-sort-ref = true

// 引用されている文献だけでなく全ての文献を表示するか
#let bib-full = true

// citeのスタイル設定
#let bib-cite-author = author-set-cite
#let bib-cite-year = all-return

// vancouverスタイル設定
#let bib-vancouver = "[1]"
#let vancouver-style = true

// 重複著者・年号文献の year-doubling に表示する文字列
#let bib-year-doubling = "a"


// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// bib-vancouver = "manual"のときの設定 (ここにある変数名は変えたり消したりしないよう注意)
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#let bib-vancouver-manual = bib-vancouver-manual-default

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 各引用の表示形式設定 (ここにある変数名は変えたり消したりしないよう注意)
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// -------------------- cite --------------------
#let bib-cite  = ([\[], bib-citen-default, [, ], [\]])

// -------------------- citet --------------------
#let bib-citet = ([], bib-citet-default, [; ], [])

// -------------------- citep --------------------
#let bib-citep = ([(], bib-citep-default, [; ], [)])

// -------------------- citen --------------------
#let bib-citen = ([\[], bib-citen-default, [, ], [\]])

// -------------------- citefull --------------------
#let bib-citefull = ([], bib-citefull-default, [; ], [])


// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 各要素の表示形式設定
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// -------------------- article (英語) --------------------

#let bibtex-article-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-article-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-article-journal-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-article-volume-en = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-article-number-en = (none,"No. ",all-return, "", ", ", ").")

#let bibtex-article-pages-en = (none,"",page-set, "", ", ", (), ".")

#let bibtex-article-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-article-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-article-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-article-en = (
  ("author", bibtex-article-author-en),
  ("title", bibtex-article-title-en),
  ("journal", bibtex-article-journal-en),
  ("volume", bibtex-article-volume-en),
  ("number", bibtex-article-number-en),
  ("pages", bibtex-article-pages-en),
  ("month", bibtex-article-month-en),
  ("year", bibtex-article-year-en),
  ("note", bibtex-article-note-en)
)

// -------------------- article (日本語) --------------------

#let bibtex-article-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-article-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-article-journal-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-article-volume-ja = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-article-number-ja = (none,"No. ",all-return, "", ", ", ").")

#let bibtex-article-pages-ja = (none,"",page-set, "", ", ", (), ".")

#let bibtex-article-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-article-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-article-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-article-ja = (
  ("author", bibtex-article-author-ja),
  ("title", bibtex-article-title-ja),
  ("journal", bibtex-article-journal-ja),
  ("volume", bibtex-article-volume-ja),
  ("number", bibtex-article-number-ja),
  ("pages", bibtex-article-pages-ja),
  ("month", bibtex-article-month-ja),
  ("year", bibtex-article-year-ja),
  ("note", bibtex-article-note-ja)
)

// -------------------- book (英語) --------------------

#let bibtex-book-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-book-title-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-book-volume-en = (none,"Vol. ",all-return, "", ". ", (), ".")

#let bibtex-book-series-en = (" of ","",all-emph, "", ". ", ("volume"), ".")

#let bibtex-book-publisher-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-book-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-book-edition-en = (none,"",all-return, " edition", ", ", (), ".")

#let bibtex-book-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-book-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-book-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-book-en = (
  ("author", bibtex-book-author-en),
  ("title", bibtex-book-title-en),
  ("volume", bibtex-book-volume-en),
  ("series", bibtex-book-series-en),
  ("publisher", bibtex-book-publisher-en),
  ("address", bibtex-book-address-en),
  ("edition", bibtex-book-edition-en),
  ("month", bibtex-book-month-en),
  ("year", bibtex-book-year-en),
  ("note", bibtex-book-note-en)
)

// -------------------- book (日本語) --------------------

#let bibtex-book-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-book-title-ja = (none,"",remove-str-brace, "", ", ", (), ".")

#let bibtex-book-series-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-book-volume-ja = (none,"第",all-return, "巻", ". ", (), "巻.")

#let bibtex-book-publisher-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-book-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-book-edition-ja = (none,"第",all-return, "版", ", ", (), "版.")

#let bibtex-book-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-book-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-book-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-book-ja = (
  ("author", bibtex-book-author-ja),
  ("title", bibtex-book-title-ja),
  ("series", bibtex-book-series-ja),
  ("volume", bibtex-book-volume-ja),
  ("publisher", bibtex-book-publisher-ja),
  ("address", bibtex-book-address-ja),
  ("edition", bibtex-book-edition-ja),
  ("month", bibtex-book-month-ja),
  ("year", bibtex-book-year-ja),
  ("note", bibtex-book-note-ja)
)

// -------------------- booklet (英語) --------------------

#let bibtex-booklet-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-booklet-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-booklet-howpublished-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-booklet-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-booklet-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-booklet-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-booklet-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-booklet-en = (
  ("author", bibtex-booklet-author-en),
  ("title", bibtex-booklet-title-en),
  ("howpublished", bibtex-booklet-howpublished-en),
  ("address", bibtex-booklet-address-en),
  ("month", bibtex-booklet-month-en),
  ("year", bibtex-booklet-year-en),
  ("note", bibtex-booklet-note-en)
)

// -------------------- booklet (日本語) --------------------

#let bibtex-booklet-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-booklet-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-booklet-howpublished-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-booklet-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-booklet-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-booklet-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-booklet-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-booklet-ja = (
  ("author", bibtex-booklet-author-ja),
  ("title", bibtex-booklet-title-ja),
  ("howpublished", bibtex-booklet-howpublished-ja),
  ("address", bibtex-booklet-address-ja),
  ("month", bibtex-booklet-month-ja),
  ("year", bibtex-booklet-year-ja),
  ("note", bibtex-booklet-note-ja)
)

// -------------------- inbook (英語) --------------------

#let bibtex-inbook-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-inbook-title-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-inbook-volume-en = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-inbook-series-en = (" of ","",all-emph, "", ", ", ("volume"), ".")

#let bibtex-inbook-chapter-en = (none,"chapter ",all-return, "", ", ", (), ".")

#let bibtex-inbook-pages-en = (none,"",page-set, "", ". ", (), ".")

#let bibtex-inbook-publisher-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-edition-en = (none,"",all-return, " edition", ", ", (), ".")

#let bibtex-inbook-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-inbook-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-inbook-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inbook-en = (
  ("author", bibtex-inbook-author-en),
  ("title", bibtex-inbook-title-en),
  ("volume", bibtex-inbook-volume-en),
  ("series", bibtex-inbook-series-en),
  ("chapter", bibtex-inbook-chapter-en),
  ("pages", bibtex-inbook-pages-en),
  ("publisher", bibtex-inbook-publisher-en),
  ("address", bibtex-inbook-address-en),
  ("edition", bibtex-inbook-edition-en),
  ("month", bibtex-inbook-month-en),
  ("year", bibtex-inbook-year-en),
  ("note", bibtex-inbook-note-en)
)

// -------------------- inbook (日本語) --------------------

#let bibtex-inbook-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-inbook-title-ja = (none,"",remove-str-brace, "", ", ", (), ".")

#let bibtex-inbook-series-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-volume-ja = (none,"第",all-return, "巻", ", ", (), "巻.")

#let bibtex-inbook-chapter-ja = (none,"第",all-return, "章", ", ", (), "章.")

#let bibtex-inbook-pages-ja = (none,"",page-set, "", ". ", (), ".")

#let bibtex-inbook-publisher-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-edition-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-inbook-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-inbook-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inbook-ja = (
  ("author", bibtex-inbook-author-ja),
  ("title", bibtex-inbook-title-ja),
  ("series", bibtex-inbook-series-ja),
  ("volume", bibtex-inbook-volume-ja),
  ("chapter", bibtex-inbook-chapter-ja),
  ("pages", bibtex-inbook-pages-ja),
  ("publisher", bibtex-inbook-publisher-ja),
  ("address", bibtex-inbook-address-ja),
  ("edition", bibtex-inbook-edition-ja),
  ("month", bibtex-inbook-month-ja),
  ("year", bibtex-inbook-year-ja),
  ("note", bibtex-inbook-note-ja)
)

// -------------------- incollection (英語) --------------------

#let bibtex-incollection-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-incollection-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-incollection-editor-en = (none,"In ",author-set3, ", editor", ", ", (), ", editor.")

#let bibtex-incollection-booktitle-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-incollection-volume-en = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-incollection-series-en = (" of ","",all-emph, "", ", ", ("volume"), ".")

#let bibtex-incollection-chapter-en = (none,"chapter ",all-return, "", ", ", (), ".")

#let bibtex-incollection-pages-en = (none,"",page-set, "", ". ", (), ".")

#let bibtex-incollection-publisher-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-edition-en = (none,"",all-return, " edition", ", ", (), ".")

#let bibtex-incollection-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-incollection-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-incollection-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-incollection-en = (
  ("author", bibtex-incollection-author-en),
  ("title", bibtex-incollection-title-en),
  ("editor", bibtex-incollection-editor-en),
  ("booktitle", bibtex-incollection-booktitle-en),
  ("volume", bibtex-incollection-volume-en),
  ("series", bibtex-incollection-series-en),
  ("chapter", bibtex-incollection-chapter-en),
  ("pages", bibtex-incollection-pages-en),
  ("publisher", bibtex-incollection-publisher-en),
  ("address", bibtex-incollection-address-en),
  ("edition", bibtex-incollection-edition-en),
  ("month", bibtex-incollection-month-en),
  ("year", bibtex-incollection-year-en),
  ("note", bibtex-incollection-note-en)
)

// -------------------- incollection (日本語) --------------------

#let bibtex-incollection-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-incollection-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-incollection-editor-ja = (none,"",author-set3, "（編）", ", ", (), ", （編）.")

#let bibtex-incollection-booktitle-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-series-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-volume-ja = (none,"第",all-return, "巻", ", ", (), "巻.")

#let bibtex-incollection-chapter-ja = (none,"第",all-return, "章", ", ", (), "章.")

#let bibtex-incollection-pages-ja = (none,"",page-set, "", ". ", (), ".")

#let bibtex-incollection-publisher-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-edition-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-incollection-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-incollection-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-incollection-ja = (
  ("author", bibtex-incollection-author-ja),
  ("title", bibtex-incollection-title-ja),
  ("editor", bibtex-incollection-editor-ja),
  ("booktitle", bibtex-incollection-booktitle-ja),
  ("series", bibtex-incollection-series-ja),
  ("volume", bibtex-incollection-volume-ja),
  ("chapter", bibtex-incollection-chapter-ja),
  ("pages", bibtex-incollection-pages-ja),
  ("publisher", bibtex-incollection-publisher-ja),
  ("address", bibtex-incollection-address-ja),
  ("edition", bibtex-incollection-edition-ja),
  ("month", bibtex-incollection-month-ja),
  ("year", bibtex-incollection-year-ja),
  ("note", bibtex-incollection-note-ja)
)

// -------------------- inproceedings (英語) --------------------

#let bibtex-inproceedings-author-en = (none,"",author-set3, "", ", ", (), ".")

#let bibtex-inproceedings-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-inproceedings-editor-en = (none,"In ",author-set3, ", editor", ", ", (), ", editor.")

#let bibtex-inproceedings-booktitle-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-inproceedings-volume-en = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-series-en = (" of ","",all-emph, "", ", ", ("volume"), ".")

#let bibtex-inproceedings-pages-en = (none,"",page-set, "", ". ", (), ".")

#let bibtex-inproceedings-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-inproceedings-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-inproceedings-organization-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-publisher-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-inproceedings-note-en = (none,"",all-return, "", ". ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inproceedings-en = (
  ("author", bibtex-inproceedings-author-en),
  ("title", bibtex-inproceedings-title-en),
  ("editor", bibtex-inproceedings-editor-en),
  ("booktitle", bibtex-inproceedings-booktitle-en),
  ("volume", bibtex-inproceedings-volume-en),
  ("series", bibtex-inproceedings-series-en),
  ("pages", bibtex-inproceedings-pages-en),
  ("address", bibtex-inproceedings-address-en),
  ("month", bibtex-inproceedings-month-en),
  ("year", bibtex-inproceedings-year-en),
  ("organization", bibtex-inproceedings-organization-en),
  ("publisher", bibtex-inproceedings-publisher-en),
  ("note", bibtex-inproceedings-note-en)
)

// -------------------- inproceedings (日本語) --------------------

#let bibtex-inproceedings-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-inproceedings-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-inproceedings-editor-ja = (none,"",author-set3, "（編）", ", ", (), ", editor.")

#let bibtex-inproceedings-booktitle-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-series-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-volume-ja = (none,"第",all-return, "巻", ", ", (), "巻.")

#let bibtex-inproceedings-pages-ja = (none,"",page-set, "", ", ", (), ".")

#let bibtex-inproceedings-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-inproceedings-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-inproceedings-organization-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-publisher-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-inproceedings-note-ja = (none,"",all-return, "", ". ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inproceedings-ja = (
  ("author", bibtex-inproceedings-author-ja),
  ("title", bibtex-inproceedings-title-ja),
  ("editor", bibtex-inproceedings-editor-ja),
  ("booktitle", bibtex-inproceedings-booktitle-ja),
  ("series", bibtex-inproceedings-series-ja),
  ("volume", bibtex-inproceedings-volume-ja),
  ("pages", bibtex-inproceedings-pages-ja),
  ("address", bibtex-inproceedings-address-ja),
  ("month", bibtex-inproceedings-month-ja),
  ("year", bibtex-inproceedings-year-ja),
  ("organization", bibtex-inproceedings-organization-ja),
  ("publisher", bibtex-inproceedings-publisher-ja),
  ("note", bibtex-inproceedings-note-ja)
)


// -------------------- conference (英語) --------------------

#let bibtex-conference-author-en = (none,"",author-set3, "", ", ", (), ".")

#let bibtex-conference-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-conference-editor-en = (none,"In ",author-set3, ", editor", ", ", (), ", editor.")

#let bibtex-conference-booktitle-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-conference-volume-en = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-conference-series-en = (" of ","",all-emph, "", ", ", ("volume"), ".")

#let bibtex-conference-pages-en = (none,"",page-set, "", ". ", (), ".")

#let bibtex-conference-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-conference-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-conference-organization-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-publisher-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-conference-note-en = (none,"",all-return, "", ". ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-conference-en = (
  ("author", bibtex-conference-author-en),
  ("title", bibtex-conference-title-en),
  ("editor", bibtex-conference-editor-en),
  ("booktitle", bibtex-conference-booktitle-en),
  ("volume", bibtex-conference-volume-en),
  ("series", bibtex-conference-series-en),
  ("pages", bibtex-conference-pages-en),
  ("address", bibtex-conference-address-en),
  ("month", bibtex-conference-month-en),
  ("year", bibtex-conference-year-en),
  ("organization", bibtex-conference-organization-en),
  ("publisher", bibtex-conference-publisher-en),
  ("note", bibtex-conference-note-en)
)

// -------------------- conference (日本語) --------------------

#let bibtex-conference-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-conference-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-conference-editor-ja = (none,"",author-set3, "（編）", ", ", (), ", editor.")

#let bibtex-conference-booktitle-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-series-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-volume-ja = (none,"第",all-return, "巻", ", ", (), "巻.")

#let bibtex-conference-pages-ja = (none,"",page-set, "", ", ", (), ".")

#let bibtex-conference-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-conference-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-conference-organization-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-publisher-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-conference-note-ja = (none,"",all-return, "", ". ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-conference-ja = (
  ("author", bibtex-conference-author-ja),
  ("title", bibtex-conference-title-ja),
  ("editor", bibtex-conference-editor-ja),
  ("booktitle", bibtex-conference-booktitle-ja),
  ("series", bibtex-conference-series-ja),
  ("volume", bibtex-conference-volume-ja),
  ("pages", bibtex-conference-pages-ja),
  ("address", bibtex-conference-address-ja),
  ("month", bibtex-conference-month-ja),
  ("year", bibtex-conference-year-ja),
  ("organization", bibtex-conference-organization-ja),
  ("publisher", bibtex-conference-publisher-ja),
  ("note", bibtex-conference-note-ja)
)


// -------------------- manual (英語) --------------------

#let bibtex-manual-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-manual-title-en = (none,"",all-emph, "", ". ", (), ".")

#let bibtex-manual-organization-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-edition-en = (none,"",all-return, " edition", ", ", (), ".")

#let bibtex-manual-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-manual-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-manual-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-manual-en = (
  ("author", bibtex-manual-author-en),
  ("title", bibtex-manual-title-en),
  ("organization", bibtex-manual-organization-en),
  ("address", bibtex-manual-address-en),
  ("edition", bibtex-manual-edition-en),
  ("month", bibtex-manual-month-en),
  ("year", bibtex-manual-year-en),
  ("note", bibtex-manual-note-en)
)

// -------------------- manual (日本語) --------------------

#let bibtex-manual-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-manual-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-manual-organization-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-edition-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-manual-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")
#let bibtex-manual-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-manual-ja = (
  ("author", bibtex-manual-author-ja),
  ("title", bibtex-manual-title-ja),
  ("organization", bibtex-manual-organization-ja),
  ("address", bibtex-manual-address-ja),
  ("edition", bibtex-manual-edition-ja),
  ("month", bibtex-manual-month-ja),
  ("year", bibtex-manual-year-ja),
  ("note", bibtex-manual-note-ja)
)

// -------------------- mastersthesis (英語) --------------------

#let bibtex-mastersthesis-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-mastersthesis-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-mastersthesis-school-en = (none,"Master's thesis, ",all-return, "", ", ", (), ".")

#let bibtex-mastersthesis-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-mastersthesis-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-mastersthesis-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-mastersthesis-note-en = (none,"",all-return, "", ". ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-mastersthesis-en = (
  ("author", bibtex-mastersthesis-author-en),
  ("title", bibtex-mastersthesis-title-en),
  ("school", bibtex-mastersthesis-school-en),
  ("address", bibtex-mastersthesis-address-en),
  ("month", bibtex-mastersthesis-month-en),
  ("year", bibtex-mastersthesis-year-en),
  ("note", bibtex-mastersthesis-note-en)
)

// -------------------- mastersthesis (日本語) --------------------

#let bibtex-mastersthesis-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-mastersthesis-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-mastersthesis-school-ja = (none,"修士論文, ",all-return, "", ", ", (), ".")

#let bibtex-mastersthesis-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-mastersthesis-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-mastersthesis-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-mastersthesis-note-ja = (none,"",all-return, "", ". ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-mastersthesis-ja = (
  ("author", bibtex-mastersthesis-author-ja),
  ("title", bibtex-mastersthesis-title-ja),
  ("school", bibtex-mastersthesis-school-ja),
  ("address", bibtex-mastersthesis-address-ja),
  ("month", bibtex-mastersthesis-month-ja),
  ("year", bibtex-mastersthesis-year-ja),
  ("note", bibtex-mastersthesis-note-ja)
)


// -------------------- misc (英語) --------------------

#let bibtex-misc-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-misc-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-misc-howpublished-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-misc-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-misc-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-misc-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-misc-en = (
  ("author", bibtex-misc-author-en),
  ("title", bibtex-misc-title-en),
  ("howpublished", bibtex-misc-howpublished-en),
  ("month", bibtex-misc-month-en),
  ("year", bibtex-misc-year-en),
  ("note", bibtex-misc-note-en)
)

// -------------------- misc (日本語) --------------------

#let bibtex-misc-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-misc-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-misc-howpublished-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-misc-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-misc-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-misc-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-misc-ja = (
  ("author", bibtex-misc-author-ja),
  ("title", bibtex-misc-title-ja),
  ("howpublished", bibtex-misc-howpublished-ja),
  ("month", bibtex-misc-month-ja),
  ("year", bibtex-misc-year-ja),
  ("note", bibtex-misc-note-ja)
)

// -------------------- online (英語) --------------------

#let bibtex-online-author-en = (none,"",author-set3, "", ", ", (), ".")

#let bibtex-online-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-online-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-online-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-online-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-online-en = (
  ("author", bibtex-online-author-en),
  ("title", bibtex-online-title-en),
  ("month", bibtex-online-month-en),
  ("year", bibtex-online-year-en),
  ("note", bibtex-online-note-en)
)

// -------------------- online (日本語) --------------------

#let bibtex-online-author-ja = (none,"",author-set3, "", ", ", (), ".")

#let bibtex-online-title-ja = (none,"",remove-str-brace, "", ", ", (), ".")

#let bibtex-online-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-online-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-online-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-online-ja = (
  ("author", bibtex-online-author-ja),
  ("title", bibtex-online-title-ja),
  ("month", bibtex-online-month-ja),
  ("year", bibtex-online-year-ja),
  ("note", bibtex-online-note-ja)
)

// -------------------- phdthesis (英語) --------------------

#let bibtex-phdthesis-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-phdthesis-title-en = (none,"",all-emph, "", ". ", (), ".")

#let bibtex-phdthesis-school-en = (none,"Phd thesis, ",all-return, "", ", ", (), ".")

#let bibtex-phdthesis-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-phdthesis-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-phdthesis-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-phdthesis-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-phdthesis-en = (
  ("author", bibtex-phdthesis-author-en),
  ("title", bibtex-phdthesis-title-en),
  ("school", bibtex-phdthesis-school-en),
  ("address", bibtex-phdthesis-address-en),
  ("month", bibtex-phdthesis-month-en),
  ("year", bibtex-phdthesis-year-en),
  ("note", bibtex-phdthesis-note-en)
)


// -------------------- phdthesis (日本語) --------------------

#let bibtex-phdthesis-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-phdthesis-title-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-phdthesis-school-ja = (none,"博士論文, ",all-return, "", ", ", (), ".")

#let bibtex-phdthesis-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-phdthesis-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-phdthesis-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-phdthesis-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-phdthesis-ja = (
  ("author", bibtex-phdthesis-author-ja),
  ("title", bibtex-phdthesis-title-ja),
  ("school", bibtex-phdthesis-school-ja),
  ("address", bibtex-phdthesis-address-ja),
  ("month", bibtex-phdthesis-month-ja),
  ("year", bibtex-phdthesis-year-ja),
  ("note", bibtex-phdthesis-note-ja)
)

// -------------------- proceedings (英語) --------------------

#let bibtex-proceedings-editor-en = (none,"",author-set3, ", editor", ". ", (), ", editor.")

#let bibtex-proceedings-title-en = (none,"",all-emph, "", ", ", (), ".")

#let bibtex-proceedings-volume-en = (none,"Vol. ",all-return, "", ", ", (), ".")

#let bibtex-proceedings-series-en = (" of ","",all-emph, "", ", ", ("volume"), ".")

#let bibtex-proceedings-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-proceedings-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-proceedings-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-proceedings-publisher-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-proceedings-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-proceedings-en = (
  ("editor", bibtex-proceedings-editor-en),
  ("title", bibtex-proceedings-title-en),
  ("volume", bibtex-proceedings-volume-en),
  ("series", bibtex-proceedings-series-en),
  ("address", bibtex-proceedings-address-en),
  ("month", bibtex-proceedings-month-en),
  ("year", bibtex-proceedings-year-en),
  ("publisher", bibtex-proceedings-publisher-en),
  ("note", bibtex-proceedings-note-en)
)

// -------------------- proceedings (日本語) --------------------

#let bibtex-proceedings-editor-ja = (none,"",author-set3, "（編）", ". ", (), "（編）.")

#let bibtex-proceedings-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-proceedings-series-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-proceedings-volume-ja = (none,"第",all-return, "巻", ", ", (), "巻.")


#let bibtex-proceedings-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-proceedings-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-proceedings-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-proceedings-publisher-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-proceedings-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-proceedings-ja = (
  ("editor", bibtex-proceedings-editor-ja),
  ("title", bibtex-proceedings-title-ja),
  ("series", bibtex-proceedings-series-ja),
  ("volume", bibtex-proceedings-volume-ja),
  ("address", bibtex-proceedings-address-ja),
  ("month", bibtex-proceedings-month-ja),
  ("year", bibtex-proceedings-year-ja),
  ("publisher", bibtex-proceedings-publisher-ja),
  ("note", bibtex-proceedings-note-ja)
)

// -------------------- techreport (英語) --------------------

#let bibtex-techreport-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-techreport-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-techreport-type-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techreport-number-en = (" ","",all-return, "", ", ", ("type"), ".")

#let bibtex-techreport-institution-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techrepot-address-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techreport-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-techreport-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-techreport-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-techreport-en = (
  ("author", bibtex-techreport-author-en),
  ("title", bibtex-techreport-title-en),
  ("type", bibtex-techreport-type-en),
  ("number", bibtex-techreport-number-en),
  ("institution", bibtex-techreport-institution-en),
  ("address", bibtex-techrepot-address-en),
  ("month", bibtex-techreport-month-en),
  ("year", bibtex-techreport-year-en),
  ("note", bibtex-techreport-note-en)
)

// -------------------- techreport (日本語) --------------------

#let bibtex-techreport-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-techreport-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-techreport-type-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techreport-number-ja = (" ","",all-return, "", ", ", ("type"), ".")

#let bibtex-techreport-institution-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techrepot-address-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techreport-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-techreport-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")

#let bibtex-techreport-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-techreport-ja = (
  ("author", bibtex-techreport-author-ja),
  ("title", bibtex-techreport-title-ja),
  ("type", bibtex-techreport-type-ja),
  ("number", bibtex-techreport-number-ja),
  ("institution", bibtex-techreport-institution-ja),
  ("address", bibtex-techrepot-address-ja),
  ("month", bibtex-techreport-month-ja),
  ("year", bibtex-techreport-year-ja),
  ("note", bibtex-techreport-note-ja)
)

// -------------------- unpublished (英語) --------------------

#let bibtex-unpublished-author-en = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-unpublished-title-en = (none,"",title-en, "", ". ", (), ".")

#let bibtex-unpublished-note-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-unpublished-month-en = (none,"",all-return, "", ". ", (), ".")

#let bibtex-unpublished-year-en = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")



// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-unpublished-en = (
  ("author", bibtex-unpublished-author-en),
  ("title", bibtex-unpublished-title-en),
  ("note", bibtex-unpublished-note-en),
  ("month", bibtex-unpublished-month-en),
  ("year", bibtex-unpublished-year-en)
)

// -------------------- unpublished (日本語) --------------------

#let bibtex-unpublished-author-ja = (none,"",author-set3, "", ". ", (), ".")

#let bibtex-unpublished-title-ja = (none,"",remove-str-brace, "", ". ", (), ".")

#let bibtex-unpublished-note-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-unpublished-month-ja = (none,"",all-return, "", ". ", (), ".")

#let bibtex-unpublished-year-ja = (" ","",all-return, "%year-doubling", ". ", ("month"), "%year-doubling.")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-unpublished-ja = (
  ("author", bibtex-unpublished-author-ja),
  ("title", bibtex-unpublished-title-ja),
  ("note", bibtex-unpublished-note-ja),
  ("month", bibtex-unpublished-month-ja),
  ("year", bibtex-unpublished-year-ja)
)

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 関数の設定（以下は何も変更しないよう注意）
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#let bib-init = bib-style.bib-init.with(bib-cite: bib-cite)

#let bibliography-list = bib-style.bibliography-list.with(
  year-doubling: year-doubling,
  bib-sort: bib-sort,
  bib-sort-ref: bib-sort-ref,
  bib-full: bib-full,
  bib-vancouver: bib-vancouver,
  vancouver-style: vancouver-style,
  bib-year-doubling: bib-year-doubling,
  bib-vancouver-manual: bib-vancouver-manual,
)

#let bib-tex  = bib-style.bib-tex.with(
  year-doubling:  year-doubling,
  bibtex-article-en:  bibtex-article-en,
  bibtex-article-ja:  bibtex-article-ja,
  bibtex-book-en:  bibtex-book-en,
  bibtex-book-ja:  bibtex-book-ja,
  bibtex-booklet-en:  bibtex-booklet-en,
  bibtex-booklet-ja:  bibtex-booklet-ja,
  bibtex-inbook-en:  bibtex-inbook-en,
  bibtex-inbook-ja:  bibtex-inbook-ja,
  bibtex-incollection-en:  bibtex-incollection-en,
  bibtex-incollection-ja:  bibtex-incollection-ja,
  bibtex-inproceedings-en:  bibtex-inproceedings-en,
  bibtex-inproceedings-ja:  bibtex-inproceedings-ja,
  bibtex-conference-en:  bibtex-conference-en,
  bibtex-conference-ja:  bibtex-conference-ja,
  bibtex-manual-en:  bibtex-manual-en,
  bibtex-manual-ja:  bibtex-manual-ja,
  bibtex-mastersthesis-en:  bibtex-mastersthesis-en,
  bibtex-mastersthesis-ja:  bibtex-mastersthesis-ja,
  bibtex-misc-en:  bibtex-misc-en,
  bibtex-misc-ja:  bibtex-misc-ja,
  bibtex-online-en:  bibtex-online-en,
  bibtex-online-ja:  bibtex-online-ja,
  bibtex-phdthesis-en:  bibtex-phdthesis-en,
  bibtex-phdthesis-ja:  bibtex-phdthesis-ja,
  bibtex-proceedings-en:  bibtex-proceedings-en,
  bibtex-proceedings-ja:  bibtex-proceedings-ja,
  bibtex-techreport-en:  bibtex-techreport-en,
  bibtex-techreport-ja:  bibtex-techreport-ja,
  bibtex-unpublished-en:  bibtex-unpublished-en,
  bibtex-unpublished-ja:  bibtex-unpublished-ja,
  bib-cite-author:  bib-cite-author,
  bib-cite-year:  bib-cite-year,
)

#let bib-file = bib-style.bib-file.with(
  year-doubling:   year-doubling,
  bibtex-article-en:   bibtex-article-en,
  bibtex-article-ja:   bibtex-article-ja,
  bibtex-book-en:   bibtex-book-en,
  bibtex-book-ja:   bibtex-book-ja,
  bibtex-booklet-en:   bibtex-booklet-en,
  bibtex-booklet-ja:   bibtex-booklet-ja,
  bibtex-inbook-en:   bibtex-inbook-en,
  bibtex-inbook-ja:   bibtex-inbook-ja,
  bibtex-incollection-en:   bibtex-incollection-en,
  bibtex-incollection-ja:   bibtex-incollection-ja,
  bibtex-inproceedings-en:   bibtex-inproceedings-en,
  bibtex-inproceedings-ja:   bibtex-inproceedings-ja,
  bibtex-conference-en:   bibtex-conference-en,
  bibtex-conference-ja:   bibtex-conference-ja,
  bibtex-manual-en:   bibtex-manual-en,
  bibtex-manual-ja:   bibtex-manual-ja,
  bibtex-mastersthesis-en:   bibtex-mastersthesis-en,
  bibtex-mastersthesis-ja:   bibtex-mastersthesis-ja,
  bibtex-misc-en:   bibtex-misc-en,
  bibtex-misc-ja:   bibtex-misc-ja,
  bibtex-online-en:   bibtex-online-en,
  bibtex-online-ja:   bibtex-online-ja,
  bibtex-phdthesis-en:   bibtex-phdthesis-en,
  bibtex-phdthesis-ja:   bibtex-phdthesis-ja,
  bibtex-proceedings-en:   bibtex-proceedings-en,
  bibtex-proceedings-ja:   bibtex-proceedings-ja,
  bibtex-techreport-en:   bibtex-techreport-en,
  bibtex-techreport-ja:   bibtex-techreport-ja,
  bibtex-unpublished-en:   bibtex-unpublished-en,
  bibtex-unpublished-ja:   bibtex-unpublished-ja,
  bib-cite-author:   bib-cite-author,
  bib-cite-year:   bib-cite-year,
)

#let bib-item = bib-style.bib-item

#let citet = bib-style.bib-cite-func.with(bib-cite: bib-citet)

#let citep = bib-style.bib-cite-func.with(bib-cite: bib-citep)

#let citen = bib-style.bib-cite-func.with(bib-cite: bib-citen)

#let citefull = bib-style.bib-cite-func.with(bib-cite: bib-citefull)
