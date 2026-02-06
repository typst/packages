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
#let bib-sort-ref = false

// 引用されている文献だけでなく全ての文献を表示するか
#let bib-full = true

// citeのスタイル設定
#let bib-cite-author = author-set-cite
#let bib-cite-year = all-return

// vancouverスタイル設定
#let bib-vancouver = "(1)"
#let vancouver-style = false

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
#let bib-cite  = ([], bib-citet-default, [; ], [])

// -------------------- citet --------------------
#let bib-citet = ([], bib-citet-default, [; ], [])

// -------------------- citep --------------------
#let bib-citep = ([(], bib-citep-default, [; ], [)])

// -------------------- citen --------------------
#let bib-citen = ([(], bib-citen-default, [, ], [)])

// -------------------- citefull --------------------
#let bib-citefull = ([], bib-citefull-default, [; ], [])


// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 各要素の表示形式設定
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// -------------------- article (英語) --------------------

#let bibtex-article-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-article-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-article-journal-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-article-volume-en = (none,"Vol.~",all-return, "", ", ", (), ".")

#let bibtex-article-number-en = (none,"No.~",all-return, "", ", ", (), ".")

#let bibtex-article-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","journal", "volume", "number"), "%year-doubling).")

#let bibtex-article-pages-en = (none,"",page-set, "", ", ", (), ".")

#let bibtex-article-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-article-en = (
  ("author", bibtex-article-author-en),
  ("title", bibtex-article-title-en),
  ("journal", bibtex-article-journal-en),
  ("volume", bibtex-article-volume-en),
  ("number", bibtex-article-number-en),
  ("year", bibtex-article-year-en),
  ("pages", bibtex-article-pages-en),
  ("note", bibtex-article-note-en)
)

// -------------------- article (日本語) --------------------

#let bibtex-article-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-article-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-article-journal-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-article-volume-ja = (none,"Vol.~",all-return, "", ", ", (), ".")

#let bibtex-article-number-ja = (none,"No.~",all-return, "", ", ", (), ".")

#let bibtex-article-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","journal", "volume", "number"), "%year-doubling).")

#let bibtex-article-pages-ja = (none,"",page-set, "", ", ", (), ".")

#let bibtex-article-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-article-ja = (
  ("author", bibtex-article-author-ja),
  ("title", bibtex-article-title-ja),
  ("journal", bibtex-article-journal-ja),
  ("volume", bibtex-article-volume-ja),
  ("number", bibtex-article-number-ja),
  ("year", bibtex-article-year-ja),
  ("pages", bibtex-article-pages-ja),
  ("note", bibtex-article-note-ja)
)

// -------------------- book (英語) --------------------

#let bibtex-book-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-book-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-book-publisher-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-book-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","publisher"), "%year-doubling).")

#let bibtex-book-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-book-en = (
  ("author", bibtex-book-author-en),
  ("title", bibtex-book-title-en),
  ("publisher", bibtex-book-publisher-en),
  ("year", bibtex-book-year-en),
  ("note", bibtex-book-note-en)
)

// -------------------- book (日本語) --------------------

#let bibtex-book-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-book-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-book-publisher-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-book-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","publisher"), "%year-doubling).")

#let bibtex-book-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-book-ja = (
  ("author", bibtex-book-author-ja),
  ("title", bibtex-book-title-ja),
  ("publisher", bibtex-book-publisher-ja),
  ("year", bibtex-book-year-ja),
  ("note", bibtex-book-note-ja)
)

// -------------------- booklet (英語) --------------------

#let bibtex-booklet-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-booklet-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-booklet-howpublished-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-booklet-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","howpublished"), "%year-doubling).")

#let bibtex-booklet-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-booklet-en = (
  ("author", bibtex-booklet-author-en),
  ("title", bibtex-booklet-title-en),
  ("howpublished", bibtex-booklet-howpublished-en),
  ("year", bibtex-booklet-year-en),
  ("note", bibtex-booklet-note-en)
)

// -------------------- booklet (日本語) --------------------

#let bibtex-booklet-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-booklet-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-booklet-howpublished-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-booklet-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","howpublished"), "%year-doubling).")

#let bibtex-booklet-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-booklet-ja = (
  ("author", bibtex-booklet-author-ja),
  ("title", bibtex-booklet-title-ja),
  ("howpublished", bibtex-booklet-howpublished-ja),
  ("year", bibtex-booklet-year-ja),
  ("note", bibtex-booklet-note-ja)
)

// -------------------- inbook (英語) --------------------

#let bibtex-inbook-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-inbook-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-inbook-publisher-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-inbook-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","publisher"), "%year-doubling).")

#let bibtex-inbook-pages-en = (none,"",page-set, "", ", ", (), ".")

#let bibtex-inbook-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inbook-en = (
  ("author", bibtex-inbook-author-en),
  ("title", bibtex-inbook-title-en),
  ("publisher", bibtex-inbook-publisher-en),
  ("year", bibtex-inbook-year-en),
  ("pages", bibtex-inbook-pages-en),
  ("note", bibtex-inbook-note-en)
)

// -------------------- inbook (日本語) --------------------

#let bibtex-inbook-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-inbook-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inbook-publisher-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-inbook-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","publisher"), "%year-doubling).")

#let bibtex-inbook-pages-ja = (none,"",page-set, "", ", ", (), ".")

#let bibtex-inbook-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inbook-ja = (
  ("author", bibtex-inbook-author-ja),
  ("title", bibtex-inbook-title-ja),
  ("publisher", bibtex-inbook-publisher-ja),
  ("year", bibtex-inbook-year-ja),
  ("pages", bibtex-inbook-pages-ja),
  ("note", bibtex-inbook-note-ja)
)

// -------------------- incollection (英語) --------------------

#let bibtex-incollection-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-incollection-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-incollection-booktitle-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-publisher-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-incollection-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","publisher"), "%year-doubling).")

#let bibtex-incollection-pages-en = (none,"",page-set, "", ", ", (), ".")

#let bibtex-incollection-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-incollection-en = (
  ("author", bibtex-incollection-author-en),
  ("title", bibtex-incollection-title-en),
  ("booktitle", bibtex-incollection-booktitle-en),
  ("publisher", bibtex-incollection-publisher-en),
  ("year", bibtex-incollection-year-en),
  ("pages", bibtex-incollection-pages-en),
  ("note", bibtex-incollection-note-en)
)

// -------------------- incollection (日本語) --------------------

#let bibtex-incollection-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-incollection-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-booktitle-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-incollection-publisher-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-incollection-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","publisher"), "%year-doubling).")

#let bibtex-incollection-pages-ja = (none,"",page-set, "", ", ", (), ".")

#let bibtex-incollection-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-incollection-ja = (
  ("author", bibtex-incollection-author-ja),
  ("title", bibtex-incollection-title-ja),
  ("booktitle", bibtex-incollection-booktitle-ja),
  ("publisher", bibtex-incollection-publisher-ja),
  ("year", bibtex-incollection-year-ja),
  ("pages", bibtex-incollection-pages-ja),
  ("note", bibtex-incollection-note-ja)
)

// -------------------- inproceedings (英語) --------------------

#let bibtex-inproceedings-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-inproceedings-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-inproceedings-booktitle-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","booktitle"), "%year-doubling).")

#let bibtex-inproceedings-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inproceedings-en = (
  ("author", bibtex-inproceedings-author-en),
  ("title", bibtex-inproceedings-title-en),
  ("booktitle", bibtex-inproceedings-booktitle-en),
  ("year", bibtex-inproceedings-year-en),
  ("note", bibtex-inproceedings-note-en)
)

// -------------------- inproceedings (日本語) --------------------

#let bibtex-inproceedings-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-inproceedings-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-booktitle-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-inproceedings-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","booktitle"), "%year-doubling).")

#let bibtex-inproceedings-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-inproceedings-ja = (
  ("author", bibtex-inproceedings-author-ja),
  ("title", bibtex-inproceedings-title-ja),
  ("booktitle", bibtex-inproceedings-booktitle-ja),
  ("year", bibtex-inproceedings-year-ja),
  ("note", bibtex-inproceedings-note-ja)
)


// -------------------- conference (英語) --------------------

#let bibtex-conference-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-conference-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-conference-booktitle-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","booktitle"), "%year-doubling).")

#let bibtex-conference-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-conference-en = (
  ("author", bibtex-conference-author-en),
  ("title", bibtex-conference-title-en),
  ("booktitle", bibtex-conference-booktitle-en),
  ("year", bibtex-conference-year-en),
  ("note", bibtex-conference-note-en)
)

// -------------------- conference (日本語) --------------------

#let bibtex-conference-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-conference-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-booktitle-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-conference-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","booktitle"), "%year-doubling).")

#let bibtex-conference-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-conference-ja = (
  ("author", bibtex-conference-author-ja),
  ("title", bibtex-conference-title-ja),
  ("booktitle", bibtex-conference-booktitle-ja),
  ("year", bibtex-conference-year-ja),
  ("note", bibtex-conference-note-ja)
)

// -------------------- manual (英語) --------------------

#let bibtex-manual-author-en = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-manual-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title"), "%year-doubling).")

#let bibtex-manual-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-manual-en = (
  ("author", bibtex-manual-author-en),
  ("title", bibtex-manual-title-en),
  ("year", bibtex-manual-year-en),
  ("note", bibtex-manual-note-en)
)

// -------------------- manual (日本語) --------------------

#let bibtex-manual-author-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-manual-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title"), "%year-doubling).")

#let bibtex-manual-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-manual-ja = (
  ("author", bibtex-manual-author-ja),
  ("title", bibtex-manual-title-ja),
  ("year", bibtex-manual-year-ja),
  ("note", bibtex-manual-note-ja)
)

// -------------------- mastersthesis (英語) --------------------

#let bibtex-mastersthesis-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-mastersthesis-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-mastersthesis-school-en = (none,"Master's thesis, ",set-url, "", ", ", (), ".")

#let bibtex-mastersthesis-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","school"), "%year-doubling).")

#let bibtex-mastersthesis-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-mastersthesis-en = (
  ("author", bibtex-mastersthesis-author-en),
  ("title", bibtex-mastersthesis-title-en),
  ("school", bibtex-mastersthesis-school-en),
  ("year", bibtex-mastersthesis-year-en),
  ("note", bibtex-mastersthesis-note-en)
)

// -------------------- mastersthesis (日本語) --------------------

#let bibtex-mastersthesis-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-mastersthesis-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-mastersthesis-school-ja = (none,"",set-url, "修士論文", ", ", (), "修士論文.")

#let bibtex-mastersthesis-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","school"), "%year-doubling).")

#let bibtex-mastersthesis-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-mastersthesis-ja = (
  ("author", bibtex-mastersthesis-author-ja),
  ("title", bibtex-mastersthesis-title-ja),
  ("school", bibtex-mastersthesis-school-ja),
  ("year", bibtex-mastersthesis-year-ja),
  ("note", bibtex-mastersthesis-note-ja)
)


// -------------------- misc (英語) --------------------

#let bibtex-misc-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-misc-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-misc-howpublished-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-misc-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","howpublished"), "%year-doubling).")

#let bibtex-misc-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-misc-en = (
  ("author", bibtex-misc-author-en),
  ("title", bibtex-misc-title-en),
  ("howpublished", bibtex-misc-howpublished-en),
  ("year", bibtex-misc-year-en),
  ("note", bibtex-misc-note-en)
)

// -------------------- misc (日本語) --------------------

#let bibtex-misc-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-misc-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-misc-howpublished-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-misc-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","howpublished"), "%year-doubling).")

#let bibtex-misc-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-misc-ja = (
  ("author", bibtex-misc-author-ja),
  ("title", bibtex-misc-title-ja),
  ("howpublished", bibtex-misc-howpublished-ja),
  ("year", bibtex-misc-year-ja),
  ("note", bibtex-misc-note-ja)
)

// -------------------- online (英語) --------------------

#let bibtex-online-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-online-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-online-url-en = (none,"available from <",set-url, ">", ", ", (), ">.")

#let bibtex-online-access-en = (none,"(accessed on ",all-return, "%year-doubling)", ", ", (), "%year-doubling).")

#let bibtex-online-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-online-en = (
  ("author", bibtex-online-author-en),
  ("title", bibtex-online-title-en),
  ("url", bibtex-online-url-en),
  ("access", bibtex-online-access-en),
  ("note", bibtex-online-note-en)
)

// -------------------- online (日本語) --------------------

#let bibtex-online-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-online-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-online-url-ja = (none,"<",set-url, ">", ", ", (), ">.")

#let bibtex-online-access-ja = (none,"(参照日 ",all-return, "%year-doubling)", ", ", (), "%year-doubling).")

#let bibtex-online-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-online-ja = (
  ("author", bibtex-online-author-ja),
  ("title", bibtex-online-title-ja),
  ("url", bibtex-online-url-ja),
  ("access", bibtex-online-access-ja),
  ("note", bibtex-online-note-ja)
)

// -------------------- phdthesis (英語) --------------------

#let bibtex-phdthesis-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-phdthesis-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-phdthesis-school-en = (none,"Ph.D. dissertation, ",set-url, "", ", ", (), ".")

#let bibtex-phdthesis-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","school"), "%year-doubling).")

#let bibtex-phdthesis-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-phdthesis-en = (
  ("author", bibtex-phdthesis-author-en),
  ("title", bibtex-phdthesis-title-en),
  ("school", bibtex-phdthesis-school-en),
  ("year", bibtex-phdthesis-year-en),
  ("note", bibtex-phdthesis-note-en)
)


// -------------------- phdthesis (日本語) --------------------

#let bibtex-phdthesis-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-phdthesis-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-phdthesis-school-ja = (none,"",set-url, "博士論文", ", ", (), "博士論文.")

#let bibtex-phdthesis-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","school"), "%year-doubling).")

#let bibtex-phdthesis-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-phdthesis-ja = (
  ("author", bibtex-phdthesis-author-ja),
  ("title", bibtex-phdthesis-title-ja),
  ("school", bibtex-phdthesis-school-ja),
  ("year", bibtex-phdthesis-year-ja),
  ("note", bibtex-phdthesis-note-ja)
)

// -------------------- proceedings (英語) --------------------

#let bibtex-proceedings-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-proceedings-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("title"), "%year-doubling).")

#let bibtex-proceedings-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-proceedings-en = (
  ("title", bibtex-proceedings-title-en),
  ("year", bibtex-proceedings-year-en),
  ("note", bibtex-proceedings-note-en)
)

// -------------------- proceedings (日本語) --------------------

#let bibtex-proceedings-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-proceedings-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("title"), "%year-doubling).")

#let bibtex-proceedings-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-proceedings-ja = (
  ("title", bibtex-proceedings-title-ja),
  ("year", bibtex-proceedings-year-ja),
  ("note", bibtex-proceedings-note-ja)
)

// -------------------- techreport (英語) --------------------

#let bibtex-techreport-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-techreport-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-techreport-institution-en = (none,"",set-url, "", ", ", (), ".")

#let bibtex-techreport-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","institution"), "%year-doubling).")

#let bibtex-techreport-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-techreport-en = (
  ("author", bibtex-techreport-author-en),
  ("title", bibtex-techreport-title-en),
  ("institution", bibtex-techreport-institution-en),
  ("year", bibtex-techreport-year-en),
  ("note", bibtex-techreport-note-en)
)

// -------------------- techreport (日本語) --------------------

#let bibtex-techreport-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-techreport-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-techreport-institution-ja = (none,"",set-url, "", ", ", (), ".")

#let bibtex-techreport-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title","institution"), "%year-doubling).")

#let bibtex-techreport-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-techreport-ja = (
  ("author", bibtex-techreport-author-ja),
  ("title", bibtex-techreport-title-ja),
  ("institution", bibtex-techreport-institution-ja),
  ("year", bibtex-techreport-year-ja),
  ("note", bibtex-techreport-note-ja)
)

// -------------------- unpublished (英語) --------------------

#let bibtex-unpublished-author-en = (none,"",author-set, "", ", ", (), ".")

#let bibtex-unpublished-title-en = (none,"",title-en, "", ", ", (), ".")

#let bibtex-unpublished-year-en = (" ","(",all-return, "%year-doubling)", ", ", ("author","title"), "%year-doubling).")

#let bibtex-unpublished-note-en = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-unpublished-en = (
  ("author", bibtex-unpublished-author-en),
  ("title", bibtex-unpublished-title-en),
  ("year", bibtex-unpublished-year-en),
  ("note", bibtex-unpublished-note-en)
)

// -------------------- unpublished (日本語) --------------------

#let bibtex-unpublished-author-ja = (none,"",author-set, "", ", ", (), ".")

#let bibtex-unpublished-title-ja = (none,"",all-return, "", ", ", (), ".")

#let bibtex-unpublished-year-ja = (" ","(",all-return, "%year-doubling)", ", ", ("author","title"), "%year-doubling).")

#let bibtex-unpublished-note-ja = (none,"",all-return, "", ", ", (), ".")


// 要素を表示する順に並べる
// !! この変数はbib_tex.typで使用されているため，変数名を変更しないように注意 !!
#let bibtex-unpublished-ja = (
  ("author", bibtex-unpublished-author-ja),
  ("title", bibtex-unpublished-title-ja),
  ("year", bibtex-unpublished-year-ja),
  ("note", bibtex-unpublished-note-ja)
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
