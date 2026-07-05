// Default fonts (Harano Aji ships with TeX Live; see README)
#let latin-covers = regex("[\u{0}-\u{2023}]")  // glyph range drawn by the Latin font
#let font-serif = ((name: "New Computer Modern", covers: latin-covers), "Harano Aji Mincho")
#let font-san = "Harano Aji Gothic"
#let font-mono = "DejaVu Sans Mono"

// Default sizes
#let system-font-size = 8pt
#let name-font-size = 16pt
#let input-font-size = 10pt

// Japanese era table (descending order for lookup)
#let _eras = (
  (name: "令和", start: datetime(year: 2019, month: 5,  day: 1),  offset: 2018),
  (name: "平成", start: datetime(year: 1989, month: 1,  day: 8),  offset: 1988),
  (name: "昭和", start: datetime(year: 1926, month: 12, day: 25), offset: 1925),
  (name: "大正", start: datetime(year: 1912, month: 7,  day: 30), offset: 1911),
  (name: "明治", start: datetime(year: 1868, month: 1,  day: 25), offset: 1867),
)

// Convert datetime → 和暦 string (falls back to 西暦 if before 明治)
#let 和暦date(d) = {
  for era in _eras {
    if d >= era.start {
      return [#era.name#(d.year() - era.offset)年#d.month()月#d.day()日]
    }
  }
  [#d.year()年#d.month()月#d.day()日]
}

// Convert datetime → 西暦 string
#let 西暦date(d) = [#d.year()年#d.month()月#d.day()日]

// ── 設定 ─────────────────────────────────────────────────────
#let _defaults = (
  serif_font: font-serif,
  sans_font: font-san,
  mono_font: font-mono,
  system_size: system-font-size,  // labels and frame captions
  name_size: name-font-size,      // 氏名
  input_size: input-font-size,    // user-entered values
  date: datetime.today(),
  date_style: "和暦",           // "和暦" or "西暦"
)
#let _settings = state("rirekisho-settings", _defaults)

#let _format_date(d, style) = if style == "西暦" { 西暦date(d) } else { 和暦date(d) }

// Render a date following the date_style setting
#let 日付(d) = context _format_date(d, _settings.get().date_style)

#let title = context text(
  font: _settings.get().sans_font,
  tracking: 1em,
  size: 14pt,
  weight: "bold",
  [履歴書],
)

// Stroke constants
#let _outer = 1.5pt
#let _inner = 0.5pt
#let _dashed = stroke(thickness: 0.5pt, dash: "dashed")

// 均等割付
#let kintou(width, s) = {
  let t = if type(s) == str { s } else { s.text }
  box(width: width, t.clusters().join(h(1fr)))
}

// mailto link with break hints
#let _email(address, cfg) = {
  set text(font: cfg.mono_font)
  if address != "" {
    link("mailto:" + address)[#address.replace(".", ".\u{200B}").replace("@", "@\u{200B}")]
  }
}

#let email(address) = context _email(address, _settings.get())

// 年月3列テーブルの共通実装
#let _年月テーブル(header_title, children, cfg) = {
  set text(size: cfg.input_size)
  let _hi = (x: 0.5 * cfg.system_size, y: 1.0 * cfg.system_size)
  table(
    columns: (5em, 3em, 1fr),
    stroke: none,
    inset: (x: 0.5em, y: 1em),
    table.header(
      table.cell(stroke: (top: _outer, left: _outer, right: _inner, bottom: _inner), align: center, inset: _hi, text(
        size: cfg.system_size,
      )[年]),
      table.cell(stroke: (top: _outer, left: none, right: _inner, bottom: _inner), align: center, inset: _hi, text(
        size: cfg.system_size,
      )[月]),
      table.cell(stroke: (top: _outer, left: none, right: _outer, bottom: _inner), align: center, inset: _hi, text(
        size: cfg.system_size,
      )[#header_title]),
    ),
    ..children,
  )
}

// エントリー行（学歴・職歴・資格共通）
#let _エントリー行(年, 月, 内容, bottom: _inner, align: left) = (
  table.cell(stroke: (top: none, left: _outer, right: _inner, bottom: bottom), align: center)[#年],
  table.cell(stroke: (top: none, left: none, right: _inner, bottom: bottom), align: center)[#月],
  table.cell(stroke: (top: none, left: none, right: _outer, bottom: bottom), align: align)[#h(5pt)#内容],
)

// セクションラベル行（学歴・職歴のみ使用）
#let _セクションラベル(label, cfg) = table.cell(
  colspan: 3,
  stroke: (top: none, left: _outer, right: _outer, bottom: _inner),
  align: center,
  inset: (x: 0.5 * cfg.system_size, y: 1.0 * cfg.system_size),
  text(size: cfg.system_size)[#label],
)

// ── ドキュメント設定関数 ────────────────────────────────────
// Usage: #show: 履歴書設定.with(paper: "a4", margin: 1.5cm, sans_font: "Arial")
#let 履歴書設定(
  lang: "ja",
  paper: "a4",
  margin: 1.5cm,
  font: font-serif,       // body (serif) font
  sans_font: font-san,
  mono_font: font-mono,
  system_size: system-font-size,
  name_size: name-font-size,
  input_size: input-font-size,
  base_size: none,       // body text size; defaults to system_size
  date: none,            // datetime; defaults to today
  date_style: "和暦",    // "和暦" or "西暦"
  body,
) = {
  set page(paper: paper, margin: margin)
  set text(lang: lang, font: font, size: if base_size == none { system_size } else { base_size })
  _settings.update(cfg => (
    ..cfg,
    serif_font: font,
    sans_font: sans_font,
    mono_font: mono_font,
    system_size: system_size,
    name_size: name_size,
    input_size: input_size,
    date: if date == none { cfg.date } else { date },
    date_style: date_style,
  ))
  body
}

// 基本情報ブロック
#let 基本情報(
  姓: "",
  名: "",
  姓読み: "",
  名読み: "",
  生年月日: "",
  年齢: 0,
  現住所: (:),
  連絡先: "",
  写真: none,
) = context {
  let cfg = _settings.get()
  show table: set block(breakable: true)
  set text(size: cfg.system_size)

  let 郵便番号1 = 現住所.at("郵便番号", default: "")
  let 住所1 = 現住所.at("住所", default: "")
  let かな1 = 現住所.at("ふりがな", default: "")
  let 電話1 = 現住所.at("電話", default: "")
  let メール1 = 現住所.at("メール", default: "")

  // 連絡先の分解
  let 住所2     = if type(連絡先) == str { 連絡先 } else { 連絡先.at("住所",     default: "") }
  let かな2     = if type(連絡先) == dictionary { 連絡先.at("ふりがな", default: "") } else { "" }
  let 郵便番号2 = if type(連絡先) == dictionary { 連絡先.at("郵便番号", default: "") } else { "" }
  let 電話2     = if type(連絡先) == dictionary { 連絡先.at("電話",     default: "") } else { "" }
  let メール2   = if type(連絡先) == dictionary { 連絡先.at("メール",   default: "") } else { "" }

  let photo_width = 3cm
  let photo_height = 4cm
  let photo_frame_width = 1.25 * photo_width
  let photo_frame_height = 1.25 * photo_height

  // ── 全体を1つのgridにまとめる（2行 × 2列） ────────────────
  grid(
    columns: (1fr, photo_frame_width),
    column-gutter: 0pt,
    row-gutter: 0pt,
    align: top,

    // ────── 行1: 氏名テーブル ＋ 写真 ──────
    table(
      columns: (5em, 1fr, 1fr),
      rows: (10mm, 2em, 3 * cfg.name_size, 3 * cfg.input_size),
      // 合計 4cm で写真高さに合わせる
      stroke: none,
      inset: (x: 4pt, y: 3pt),
      table.cell(colspan: 3, grid(
        columns: (1fr, auto),
        title, grid.cell(align: bottom + right, [#_format_date(cfg.date, cfg.date_style)現在]),
      )),
      // ふりがな行
      table.cell(stroke: (top: _outer, left: _outer, right: _inner, bottom: _dashed), align: center + horizon)[ふりがな],
      table.cell(stroke: (top: _outer, left: none, right: none, bottom: _dashed), align: center + horizon)[#姓読み],
      table.cell(stroke: (top: _outer, left: none, right: _outer, bottom: _dashed), align: start + horizon)[#名読み],
      // 氏名行
      table.cell(stroke: (top: none, left: _outer, right: _inner, bottom: _inner), align: center + horizon, kintou(4em, "氏名")),
      table.cell(stroke: (top: none, left: none, right: none, bottom: _inner), align: center + horizon)[
        #text(cfg.name_size, 姓)
      ],
      table.cell(stroke: (top: none, left: none, right: _outer, bottom: _inner), align: start + horizon)[
        #text(cfg.name_size, 名)
      ],
      // 生年月日行
      table.cell(stroke: (top: none, left: _outer, right: _inner, bottom: _inner), align: center + horizon)[生年月日],
      table.cell(colspan: 2, stroke: (top: none, left: none, right: _outer, bottom: _inner), align: horizon)[
        #h(2em)#text(cfg.input_size, 生年月日) 生 #h(3em) (満 #h(0.5em) #年齢 歳)
      ],
    ),
    align(center + horizon,
      box(
        stroke: _dashed,
        height: photo_height,
        width: photo_width,
        if 写真 == none {
          align(center + horizon)[写真を貼る位置\(縦 40mm, 横 30mm)]
        } else {
          写真
        },
      )
    ),

    // ────── 行3: 住所 ＋ 電話・メール ──────
    table(
      columns: (4 * cfg.input_size, 1fr),
      rows: (2em, 1em, 3 * cfg.input_size),
      inset: (x: 4pt, y: 2pt),
      stroke: none,
      table.cell(stroke: (top: none, left: _outer, right: _inner, bottom: _dashed), align: center + horizon)[ふりがな],
      table.cell(stroke: (top: none, left: none, right: _inner, bottom: _dashed), align: center + horizon)[#かな1],
      table.cell(colspan: 2, stroke: (top: none, left: _outer, right: _inner, bottom: none), {
        pad(x: 0em, y: 0.5em, {if 郵便番号1 == "" { [現住所 (〒 #text(font: cfg.mono_font)[#box(width: 1.8em) - #h(2.4em)])] } else { [現住所 (〒 #text(font: cfg.mono_font, 郵便番号1))] }})
      }),
      table.cell(stroke: (top: none, left: _outer, right: none, bottom: _inner))[],
      table.cell(stroke: (top: none, left: none, right: _inner, bottom: _inner), align: center + horizon, text(size: cfg.input_size, 住所1)),
    ),

    stack(
      table(
        columns: (1fr,),
        rows: 2em,
        stroke: none,
        inset: (x: 4pt, y: 3pt),
        table.cell(stroke: (top: _outer, left: none, right: _outer, bottom: _inner), align: horizon)[電話 #h(2em) #text(font: cfg.mono_font, 電話1)],
      ),
      table(
        columns: (1fr,),
        rows: (1em + 3 * cfg.input_size,),
        stroke: none,
        inset: (x: 4pt, y: 3pt),
        table.cell(stroke: (top: none, left: none, right: _outer, bottom: _inner), {
          pad(x: 0em, y: 0em)[E-mail]
          text(font: cfg.mono_font, size: cfg.system_size, _email(メール1, cfg))
        }),
      ),
    ),

    // ────── 行4: 連絡先 ＋ 連絡先電話・メール ──────
    table(
      columns: (4 * cfg.input_size, 1fr),
      rows: (2em, 1em, 3 * cfg.input_size),
      inset: (x: 4pt, y: 2pt),
      stroke: none,
      table.cell(stroke: (top: none, left: _outer, right: _inner, bottom: _dashed), align: center + horizon)[ふりがな],
      table.cell(stroke: (top: none, left: none, right: _inner, bottom: _dashed), align: center + horizon)[#かな2],
      table.cell(colspan: 2, stroke: (top: none, left: _outer, right: _inner, bottom: none), {
        pad(x: 0em, y: 0.5em, {if 郵便番号2 == "" { [連絡先 (〒 #text(font: cfg.mono_font)[#box(width: 1.8em)-#h(2.4em)])] } else { [連絡先 (〒 #text(font: cfg.mono_font, 郵便番号2))] }})
      }),
      table.cell(stroke: (top: none, left: _outer, right: none, bottom: _outer))[],
      table.cell(stroke: (top: none, left: none, right: _inner, bottom: _outer), align: center + horizon, text(size: cfg.input_size, 住所2)),
    ),

    stack(
      table(
        columns: (1fr,),
        rows: 2em,
        stroke: none,
        inset: (x: 4pt, y: 3pt),
        table.cell(stroke: (top: _inner, left: none, right: _outer, bottom: _inner), align: horizon)[電話 #h(2em) #text(font: cfg.mono_font, 電話2)],
      ),
      table(
        columns: (1fr,),
        rows: (1em + 3 * cfg.input_size,),
        stroke: none,
        inset: (x: 4pt, y: 3pt),
        table.cell(stroke: (top: none, left: none, right: _outer, bottom: _outer), {
          pad(x: 0em, y: 0em)[E-mail]
          text(font: cfg.mono_font, size: cfg.system_size, _email(メール2, cfg))
        }),
      ),
    ),
  )
}

// ── 学歴・職歴ブロック ────────────────────────────────────────
#let 学歴職歴(学歴: (), 職歴: ()) = context {
  let cfg = _settings.get()
  show table: set block(breakable: true)
  let _map(arr, last_bottom: _outer) = arr.enumerate().map(pair => {
    let (i, e) = pair
    _エントリー行(
      e.年, e.月, e.内容,
      align: e.at("align", default: start),
      bottom: if i == arr.len() - 1 { last_bottom } else { _inner },
    )
  }).flatten()
  _年月テーブル(
    [学歴・職歴（各別にまとめて書く）],
    (
      _セクションラベル([学歴], cfg),
      .._map(学歴, last_bottom: _inner),
      _セクションラベル([職歴], cfg),
      .._map(職歴),
    ),
    cfg,
  )
}

// ── 資格欄ブロック ────────────────────────────────────────────
#let 資格欄(資格: ()) = context {
  let cfg = _settings.get()
  _年月テーブル(
    [免許・資格],
    資格.enumerate().map(pair => {
      let (i, e) = pair
      _エントリー行(
        e.年, e.月, e.内容,
        align: e.at("align", default: start),
        bottom: if i == 資格.len() - 1 { _outer } else { _inner },
      )
    }).flatten(),
    cfg,
  )
}

// ── 志望動機ブロック ─────────────────────────────────────────
#let 志望動機(height: 5cm, body) = context {
  let cfg = _settings.get()
  table(
    columns: (1fr,),
    rows: (height,),
    stroke: none,
    inset: (x: 5pt, y: 5pt),
    table.cell(stroke: (top: _outer, left: _outer, right: _outer, bottom: _outer), align: top)[
      #text(size: cfg.system_size)[志望の動機、特技、好きな学科、アピールポイントなど]
      #linebreak()
      #set text(size: cfg.input_size)
      #set par(first-line-indent: (amount: 1em, all: true), justify: true)
      #v(0.75em, weak: true)
      #body
    ],
  )
}

// ── 本人希望ブロック ─────────────────────────────────────────
#let 本人希望(height: 5cm, body) = context {
  let cfg = _settings.get()
  table(
    columns: (1fr,),
    rows: (height,),
    stroke: none,
    inset: (x: 5pt, y: 5pt),
    table.cell(stroke: (top: _outer, left: _outer, right: _outer, bottom: _outer), align: top)[
      #text(size: cfg.system_size)[本人希望記入欄（特に給料・職種・勤務時間・勤務地・その他についての希望があれば記入）]
      #linebreak()
      #set text(size: cfg.input_size)
      #set par(first-line-indent: (amount: 1em, all: true), justify: true)
      #v(0.75em, weak: true)
      #body
    ],
  )
}

// ── 賞罰ブロック ─────────────────────────────────────────────
#let 賞罰(エントリー: ()) = context {
  let cfg = _settings.get()
  _年月テーブル(
    [賞罰・処分歴等],
    エントリー.enumerate().map(pair => {
      let (i, e) = pair
      _エントリー行(
        e.年, e.月, e.内容,
        align: e.at("align", default: start),
        bottom: if i == エントリー.len() - 1 { _outer } else { _inner },
      )
    }).flatten(),
    cfg,
  )
}

// ── 署名欄ブロック ───────────────────────────────────────────
#let 署名欄(signature: none) = context {
  let cfg = _settings.get()
  set text(size: cfg.input_size)
  set par(justify: true)
  table(
    columns: (1fr,),
    stroke: none,
    inset: (x: 5pt, y: 5pt),
    table.cell(stroke: (top: _outer, left: _outer, right: _outer, bottom: _outer), align: top)[
      本書類の記載内容については事実に相違なく、虚偽の記載があった場合には、採用取消や懲戒処分等の対象となりえることについて了承します。
      #v(0.5em)
      #align(end, {
        grid(
          columns: (auto, 0.5em, auto, 2em),
          align: left + horizon,
          row-gutter: 1em,
          grid.cell(colspan: 3)[#_format_date(cfg.date, cfg.date_style)], [],
          [氏名（自署）],
          [],
          if signature != none { box(signature) } else { h(5cm) },
          [],
        )
      })
      #v(0.5em)
    ],
  )
}
