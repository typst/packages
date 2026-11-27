// src/styles.typ
// 可個別套用的排版規則、common-style 與 plain-links

#import "fonts.typ": font-hei, font-kai, font-song, show-cn-fakebold-smart
#import "title.typ": normalize-authors
#import "heading.typ": heading-number, heading-path, in-outline

// ============================================================
// § 可個別套用的排版規則
//
//   每個函式都以 `show: xxx` 或 `show: xxx.with(...)` 套用，只影響其後的內容，
//   可依需要挑選、調整順序或替換其中幾項。
//   common-style 則依下列順序全部套用。
//
//   document-style   PDF 標題與作者 / PDF title and authors
//   page-style       紙張、邊距、頁碼 / Paper, margins, page numbers
//   text-style       字型、語言、CJK 粗體 / Fonts, language, CJK bold
//   par-style        段落 / Paragraphs
//   quote-style      區塊引用 / Block quotes
//   list-style       編號與項目清單 / Numbered and bulleted lists
//   figure-style     圖說 / Figure captions
//   footnote-style   註腳 / Footnotes
//   heading-style    標題編號與外觀 / Heading numbering and display
//   ref-style        交互參照 / Cross-references
// ============================================================

// PDF 中繼資料：標題與作者
#let document-style(title: "", authors: (), body) = {
  let author-names = normalize-authors(authors).map(a => {
    if type(a) == dictionary { a.at("name", default: "") } else { str(a) }
  })
  set document(title: title, author: author-names)
  body
}

// 頁面：紙張、邊距、頁尾置中頁碼
#let page-style(paper: "a4", margin: (x: 3cm, y: 2.5cm), body) = {
  set page(paper: paper, margin: margin, numbering: "1", number-align: center)
  body
}

// 字型與語言；CJK 粗體依字型改用真粗體或 cuti 偽粗體
#let text-style(font: font-song, size: 12pt, body) = {
  set text(font: font, size: size, lang: "zh", region: "tw")
  show: show-cn-fakebold-smart
  set underline(offset: .2em, stroke: .05em, evade: false)
  body
}

// 段落：筆記預設不縮排；衍生模板可傳入 first-line-indent 等參數
#let par-style(first-line-indent: 0em, leading: 1.1em, spacing: 1.6em, body) = {
  set par(first-line-indent: first-line-indent, leading: leading, justify: true, spacing: spacing)
  body
}

// 區塊引用
#let quote-style(font: font-kai, body) = {
  show quote.where(block: true): set text(font: font)
  body
}

// 編號清單：依層級採臺灣公文常用格式 1. → (1) → A. → (A) → a. → (a)
#let list-style(body) = {
  set enum(
    full: true,
    numbering: (..nums) => {
      let n = nums.pos()
      let pats = ("1.", "(1)", "A.", "(A)", "a.", "(a)")
      numbering(pats.at(calc.min(n.len(), pats.len()) - 1), n.last())
    },
  )
  set list(marker: ([•], [▪], [◆]))
  body
}

// 圖說：楷體；圖片的圖說置於上方
#let figure-style(font: font-kai, body) = {
  show figure.caption: set text(font: font)
  show figure.where(kind: image): set figure.caption(position: top)
  body
}

// 註腳：文內標籤黑體上標；頁底懸掛縮排
#let footnote-style(font: font-song, label-font: font-hei, body) = {
  show footnote: set text(font: label-font)

  show footnote.entry: it => {
    set text(font: font, weight: "regular")
    set par(leading: 0.9em, spacing: 0.9em)

    let loc = it.note.location()

    // 以 grid 切兩欄實現懸掛縮排；以 block 的 bottom inset 控制註腳間距
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      grid(
        columns: (1.25em, 1fr),
        // Left: number, right: 內文
        text(font: label-font)[#super[#counter(footnote).display(at: loc)]], it.note.body,
      ),
    )
  }

  body
}

// 標題：編號見 heading-number；外觀如下
//   - large: 是否在最上層多加一層「Ch. 1」（由 large-note.typ 使用）
//   - 第一層：置中，有無編號皆同；large 時第一層為「章」，另起新頁，有編號者字級大一號
//   - 其餘層級：靠左
//   - 間距：標題下方的間距等於內文段距（par.spacing）。標題後接內文時與原本相同；
//     標題緊接下一個標題時（例如「壹、」之後直接是「一、」），兩者之間也有一個段距。
//   - 標題內的註腳：請用 hfn 而非 footnote，否則目次會再產生一個註腳（見 heading.typ）。
//     本函式於 outline 前後記錄「位於目次內」，hfn 據此在目次中不輸出。
//
// 段距在套用 heading-style 之處以當時的內文字級換算為絕對長度，否則 em 會以標題字級
// 計算。因此請在 text-style、par-style 之後套用（common-style 即是如此）；其後才改的
// 字級或段距不會反映在標題間距上。
#let heading-style(font: font-hei, large: false, body) = context {
  show heading: set text(font: font, weight: "bold")
  show heading: set block(below: par.spacing.to-absolute())

  set heading(numbering: (..nums) => heading-number(nums.pos(), large: large))

  // 供 hfn 判斷是否位於目次內；包在 outline 外層，故不受 outline.entry 的自訂影響
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  show heading: it => {
    let numbered = it.numbering != none
    // 只輸出編號與標題文字，不交回 it：交回 it 會改用 Typst 內建的標題排版，
    // 標題下方的間距較小，其後第一段也會失去首行縮排。
    let displayed = {
      if numbered { counter(heading).display(it.numbering) }
      it.body
    }
    set par(first-line-indent: 0em)
    if it.level == 1 {
      if large { pagebreak(weak: true) }
      set text(size: 1.25em) if large and numbered
      set align(center)
      displayed
    } else {
      set align(left)
      displayed
    }
  }

  body
}

// 交互參照：@label 指向有編號的標題時，輸出完整層級路徑，例如「壹、二、(三)」；
// 以 @label[見] 傳入的補充文字會接在路徑前面。頁碼參照 ref(form: "page") 與
// 其餘參照（含文獻引用）原樣交回。large 須與 heading-style 一致。
#let ref-style(large: false, body) = {
  show ref: it => {
    if it.form != "normal" { return it }
    let el = it.element
    if el == none or el.func() != heading or el.numbering == none { return it }
    let path = heading-path(counter(heading).at(el.location()), large: large)
    let supplement = if it.supplement == auto { none } else { it.supplement }
    link(el.location(), [#supplement#path])
  }
  body
}

// ============================================================
// § 基本排版規則（全部套用）
//
//   以 `show: common-style.with(...)` 套用。入口檔可在其後再寫
//   set 規則覆寫（例如段落縮排），較內層的 set 規則優先；
//   需要更細的控制時，改為個別套用上列函式。
//
//   - large: 是否在最上層多加一層「Ch. 1」（由 large-note.typ 使用）
//   - fonts: 覆寫字型的 dictionary，可用的鍵為 song、hei、kai，值為字型清單；
//            未列出的鍵使用預設。例如 fonts: (song: ("Libertinus Serif", "Noto Serif CJK TC"))。
//            song 用於內文與註腳，hei 用於標題與註腳編號，kai 用於區塊引用與圖說。
//            若要保留預設的降級順序，只在前面加字型：("My Font", ..font-song)。
//            title-block 與 inquote 不經過 common-style，請另以各自的 font 參數指定。
// ============================================================
#let common-style(title: "", authors: (), large: false, fonts: (:), body) = {
  for key in fonts.keys() {
    assert(
      key in ("song", "hei", "kai"),
      message: "common-style: unknown key `" + key + "` in fonts; expected song, hei or kai",
    )
  }
  let song = fonts.at("song", default: font-song)
  let hei = fonts.at("hei", default: font-hei)
  let kai = fonts.at("kai", default: font-kai)

  show: document-style.with(title: title, authors: authors)
  show: page-style
  show: text-style.with(font: song)
  show: par-style
  show: quote-style.with(font: kai)
  show: list-style
  show: figure-style.with(font: kai)
  show: footnote-style.with(font: song, label-font: hei)
  show: heading-style.with(font: hei, large: large)
  show: ref-style.with(large: large)
  body
}

// ============================================================
// § 移除超連結樣式
//
//   引用（Typst 原生 cite，或衍生模板所用 citrus 的 cite）會被包成
//   指向參考文獻的 link，在註腳中顯示為超連結。以 `show: plain-links` 套用後，
//   其後內容的連結一律只輸出文字。請在 outline 之後才套用，
//   以免目錄失去頁內跳轉。
// ============================================================
#let plain-links(body) = {
  show link: it => it.body
  body
}
