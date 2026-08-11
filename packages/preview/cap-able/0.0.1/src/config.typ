// ============================================================
// 配置和辅助函数模块 (Configuration and Helper Functions Module)
// ============================================================
//
// 本模块是 cap-able 包的核心配置层，负责：
// This module is the core configuration layer of cap-able:
//
// 1. 多语言文本支持（25+ 种语言）
//    Multilingual text support (25+ languages)
// 2. 全局状态管理（表格/图片样式、间距、子图）
//    Global state management (table/figure style, spacing, subfigures)
// 3. 辅助工具函数（间距处理、语言检测、章节计算）
//    Utility functions (spacing, language detection, chapter calculation)
// 4. 用户配置入口函数（table-style、figure-style、set-table-width）
//    User-facing configuration functions
//
// ============================================================

#import "@preview/tablem:0.3.0": tablem

// ============================================================
// 辅助内容块 (Helper Content Block)
// ============================================================

// 假段落，用于修复中文等语言在表格/图片/表注后首行缩进丢失的问题。
// Fake paragraph to restore first-line indentation after tables/figures in CJK languages.
//
// 原理：Typst 的 first-line-indent 只在"真实段落"开头生效。通过插入一个不可见
// 的零高度块，欺骗 Typst 将后续内容识别为新段落，从而恢复正确的缩进。
// Principle: Typst's first-line-indent only activates at paragraph starts.
// This invisible zero-height block tricks Typst into treating what follows as a new paragraph.
#let _fakepar = context{box();v(-measure(block()+block()).height)}

// ============================================================
// 语言分类列表 (Language Classification Lists)
// ============================================================

// 需要段落首行缩进的语言：中文、日文、韩文、法文、越南文、泰文
// Languages requiring paragraph first-line indentation: CJK + French, Vietnamese, Thai
#let indent-languages = ("zh", "ja", "ko", "fr", "vi", "th")

// 检测是否为需要段落首行缩进的语言。
// Check if the language requires paragraph first-line indentation.
// 用于决定在表格/图片/表注后是否插入 _fakepar 修复缩进。
// Used to decide whether to insert _fakepar after tables/figures/notes.
// lang-code (str): 语言代码，如 "zh"、"en" / Language code
#let needs-after-indent(
  lang-code
) = {
  lang-code in indent-languages
}

// 从右到左书写的语言：阿拉伯文、希伯来文、波斯文、乌尔都文
// Right-to-left languages: Arabic, Hebrew, Persian, Urdu
// RTL 语言在双语标题中需要调换主语言和英文行的顺序，
// 并为英文行显式设置 dir: ltr。
// RTL languages swap main/English line order in bilingual captions,
// and need explicit dir: ltr on the English line.
#let rtl-languages = ("ar", "he", "fa", "ur")

// 检测是否为从右到左书写的语言。
// Check if the language is written right-to-left (RTL).
// lang-code (str): 语言代码 / Language code
#let is-rtl-lang(
  lang-code
) = {
  lang-code in rtl-languages
}

// ============================================================
// 多语言文本配置 (Multilingual Text Configuration)
// ============================================================
//
// table-lang-config 字典键说明 / Key descriptions for table-lang-config:
//
// - table:                    表格前缀词，如 "表"、"Table"、"Tabelle"
//                             Table prefix word
// - continued-prefix:         续表前缀，如 "续表"、"Continuation of Table"
//                             Continued table prefix
// - continued-suffix:         续表后缀，如 "（续）"、"(continued)"
//                             Continued table suffix
// - figure:                   图片前缀词，如 "图"、"Figure"、"Abbildung"
//                             Figure prefix word
// - fig-continued-prefix:     续图前缀
//                             Continued figure prefix
// - fig-continued-suffix:     续图后缀
//                             Continued figure suffix
// - pre-supplement-number-spacing:
//     前缀词与编号之间的间距。中文/日文为 0em（紧排如"表1"），西文为空格（如"Table 1"）
//     Space between prefix and number. CJK: 0em (tight: "表1"); Western: space ("Table 1")
// - post-supplement-number-spacing:
//     编号与续表后缀之间的间距
//     Space between number and continuation suffix
// - number-title-spacing:
//     编号与主语言标题之间的分隔。中文用全角空格（\u{3000}），西文用 ": " 或 ". "
//     Separator between number and title. CJK: em-space (\u{3000}); Western: ": " or ". "
// - number-title-spacing-en:
//     编号与英文标题之间的分隔（双语标题英文行使用）
//     Separator between number and English title (for bilingual English line)
//
#let table-lang-config = (
  // 英文 / English
  en: (
    table: "Table",
    continued-prefix: "Continuation of Table",
    continued-suffix: "(continued)",
    figure: "Figure",
    fig-continued-prefix: "Continuation of Figure",
    fig-continued-suffix: "(continued)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 简体中文 / Simplified Chinese
  // 特点：前缀与编号紧排（0em），编号与标题用全角空格（U+3000）
  // Feature: prefix-number tight (0em), number-title uses em-space (U+3000)
  zh: (
    table: "表",
    continued-prefix: "续表",
    continued-suffix: "（续）",
    figure: "图",
    fig-continued-prefix: "续图",
    fig-continued-suffix: "（续）",
    pre-supplement-number-spacing: 0em,
    post-supplement-number-spacing: 0em,
    number-title-spacing: [\u{3000}],
    number-title-spacing-en: [#h(0.5em)],
  ),
  // 繁體中文 / Traditional Chinese
  // 使用 #set text(lang: "zh", region: "TW") 啟用
  // Enable with #set text(lang: "zh", region: "TW")
  zh-TW: (
    table: "表",
    continued-prefix: "續表",
    continued-suffix: "（續）",
    figure: "圖",
    fig-continued-prefix: "續圖",
    fig-continued-suffix: "（續）",
    pre-supplement-number-spacing: 0em,
    post-supplement-number-spacing: 0em,
    number-title-spacing: [\u{3000}],
    number-title-spacing-en: [#h(0.5em)],
  ),
  // 德文 / German
  de: (
    table: "Tabelle",
    continued-prefix: "Fortsetzung von Tabelle",
    continued-suffix: "(Fortsetzung)",
    figure: "Abbildung",
    fig-continued-prefix: "Fortsetzung von Abbildung",
    fig-continued-suffix: "(Fortsetzung)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 法文 / French
  // 注：法文排版规范要求冒号前有空格，如 "Tableau 1 : Titre"
  // Note: French typography requires a space before the colon: "Tableau 1 : Titre"
  fr: (
    table: "Tableau",
    continued-prefix: "Suite du Tableau",
    continued-suffix: "(suite)",
    figure: "Figure",
    fig-continued-prefix: "Suite de la Figure",
    fig-continued-suffix: "(suite)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [ : ],
    number-title-spacing-en: [: ],
  ),
  // 西班牙文 / Spanish
  es: (
    table: "Tabla",
    continued-prefix: "Continuación de la Tabla",
    continued-suffix: "(continuación)",
    figure: "Figura",
    fig-continued-prefix: "Continuación de la Figura",
    fig-continued-suffix: "(continuación)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 意大利文 / Italian
  it: (
    table: "Tabella",
    continued-prefix: "Continuazione della Tabella",
    continued-suffix: "(continua)",
    figure: "Figura",
    fig-continued-prefix: "Continuazione della Figura",
    fig-continued-suffix: "(continua)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 葡萄牙文 / Portuguese
  pt: (
    table: "Tabela",
    continued-prefix: "Continuação da Tabela",
    continued-suffix: "(continuação)",
    figure: "Figura",
    fig-continued-prefix: "Continuação da Figura",
    fig-continued-suffix: "(continuação)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 俄文 / Russian
  ru: (
    table: "Таблица",
    continued-prefix: "Продолжение таблицы",
    continued-suffix: "(продолжение)",
    figure: "Рисунок",
    fig-continued-prefix: "Продолжение рисунка",
    fig-continued-suffix: "(продолжение)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 日文 / Japanese（与中文相同规则 / Same rules as Chinese）
  ja: (
    table: "表",
    continued-prefix: "表の続き",
    continued-suffix: "（続き）",
    figure: "図",
    fig-continued-prefix: "図の続き",
    fig-continued-suffix: "（続き）",
    pre-supplement-number-spacing: 0em,
    post-supplement-number-spacing: 0em,
    number-title-spacing: [\u{3000}],
    number-title-spacing-en: [#h(0.5em)],
  ),
  // 韩文 / Korean
  ko: (
    table: "표",
    continued-prefix: "표 계속",
    continued-suffix: "(계속)",
    figure: "그림",
    fig-continued-prefix: "그림 계속",
    fig-continued-suffix: "(계속)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 阿拉伯文（RTL）/ Arabic (RTL)
  ar: (
    table: "جدول",
    continued-prefix: "تابع الجدول",
    continued-suffix: "(تابع)",
    figure: "شكل",
    fig-continued-prefix: "تابع الشكل",
    fig-continued-suffix: "(تابع)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 荷兰文 / Dutch
  nl: (
    table: "Tabel",
    continued-prefix: "Vervolg van Tabel",
    continued-suffix: "(vervolg)",
    figure: "Figuur",
    fig-continued-prefix: "Vervolg van Figuur",
    fig-continued-suffix: "(vervolg)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 波兰文 / Polish
  pl: (
    table: "Tabela",
    continued-prefix: "Kontynuacja Tabeli",
    continued-suffix: "(cd.)",
    figure: "Rysunek",
    fig-continued-prefix: "Kontynuacja Rysunku",
    fig-continued-suffix: "(cd.)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 捷克文 / Czech
  cs: (
    table: "Tabulka",
    continued-prefix: "Pokračování Tabulky",
    continued-suffix: "(pokračování)",
    figure: "Obrázek",
    fig-continued-prefix: "Pokračování Obrázku",
    fig-continued-suffix: "(pokračování)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 瑞典文 / Swedish
  sv: (
    table: "Tabell",
    continued-prefix: "Fortsättning av Tabell",
    continued-suffix: "(forts.)",
    figure: "Figur",
    fig-continued-prefix: "Fortsättning av Figur",
    fig-continued-suffix: "(forts.)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 丹麦文 / Danish
  da: (
    table: "Tabel",
    continued-prefix: "Fortsættelse af Tabel",
    continued-suffix: "(fortsat)",
    figure: "Figur",
    fig-continued-prefix: "Fortsættelse af Figur",
    fig-continued-suffix: "(fortsat)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 挪威文 / Norwegian
  no: (
    table: "Tabell",
    continued-prefix: "Fortsettelse av Tabell",
    continued-suffix: "(forts.)",
    figure: "Figur",
    fig-continued-prefix: "Fortsettelse av Figur",
    fig-continued-suffix: "(forts.)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 芬兰文 / Finnish
  fi: (
    table: "Taulukko",
    continued-prefix: "Taulukon jatko",
    continued-suffix: "(jatkoa)",
    figure: "Kuva",
    fig-continued-prefix: "Kuvan jatko",
    fig-continued-suffix: "(jatkoa)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 土耳其文 / Turkish
  tr: (
    table: "Tablo",
    continued-prefix: "Tablonun Devamı",
    continued-suffix: "(devam)",
    figure: "Şekil",
    fig-continued-prefix: "Şeklin Devamı",
    fig-continued-suffix: "(devam)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 希腊文 / Greek
  el: (
    table: "Πίνακας",
    continued-prefix: "Συνέχεια Πίνακα",
    continued-suffix: "(συνέχεια)",
    figure: "Σχήμα",
    fig-continued-prefix: "Συνέχεια Σχήματος",
    fig-continued-suffix: "(συνέχεια)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 希伯来文（RTL）/ Hebrew (RTL)
  he: (
    table: "טבלה",
    continued-prefix: "המשך טבלה",
    continued-suffix: "(המשך)",
    figure: "תמונה",
    fig-continued-prefix: "המשך תמונה",
    fig-continued-suffix: "(המשך)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 印地文 / Hindi
  hi: (
    table: "तालिका",
    continued-prefix: "तालिका जारी",
    continued-suffix: "(जारी)",
    figure: "चित्र",
    fig-continued-prefix: "चित्र जारी",
    fig-continued-suffix: "(जारी)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 泰文 / Thai（用普通空格，无冒号 / Regular space, no colon）
  th: (
    table: "ตาราง",
    continued-prefix: "ตารางต่อ",
    continued-suffix: "(ต่อ)",
    figure: "รูป",
    fig-continued-prefix: "รูปต่อ",
    fig-continued-suffix: "(ต่อ)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [ ],
    number-title-spacing-en: [ ],
  ),
  // 越南文 / Vietnamese
  vi: (
    table: "Bảng",
    continued-prefix: "Tiếp theo Bảng",
    continued-suffix: "(tiếp theo)",
    figure: "Hình",
    fig-continued-prefix: "Tiếp theo Hình",
    fig-continued-suffix: "(tiếp theo)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [. ],
    number-title-spacing-en: [. ],
  ),
  // 波斯文（RTL）/ Persian (RTL)
  fa: (
    table: "جدول",
    continued-prefix: "ادامه جدول",
    continued-suffix: "(ادامه)",
    figure: "شکل",
    fig-continued-prefix: "ادامه شکل",
    fig-continued-suffix: "(ادامه)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
  // 乌尔都文（RTL）/ Urdu (RTL)
  ur: (
    table: "جدول",
    continued-prefix: "جدول کا تسلسل",
    continued-suffix: "(جاری)",
    figure: "شکل",
    fig-continued-prefix: "شکل کا تسلسل",
    fig-continued-suffix: "(جاری)",
    pre-supplement-number-spacing: [ ],
    post-supplement-number-spacing: 0em,
    number-title-spacing: [: ],
    number-title-spacing-en: [: ],
  ),
)

// ============================================================
// 全局配置状态 (Global Configuration States)
// ============================================================
//
// 所有全局配置通过 Typst 的 state() 机制传递，保证上下文正确性。
// All global config is passed via Typst's state() for context correctness.
// 使用方式：state.get() 必须在 context {...} 块内调用。
// Usage: state.get() must be called inside context {...} blocks.
//
// table-style-config 字段说明 / Field descriptions:
//   caption-above:        标题块上方间距 / Space above caption block
//   caption-below:        标题与表体之间间距 / Space between caption and table body
//   table-below:          整个表格下方间距 / Space below the whole table
//   caption-leading:      标题行距（影响双语标题两行间距）/ Caption line spacing
//   numbering-format:     编号格式，如 "1"、"1.1"、"A.1" / Numbering format
//   use-chapter:          是否包含章节号 / Include chapter number
//   chapter-level:        由 numbering-format 自动计算的章节层级数
//                         Chapter level count, auto-calculated from numbering-format
//   supplement:           主语言前缀词（auto=从语言配置自动获取）
//                         Main language prefix (auto = from lang config)
//   supplement-en:        英文前缀词 / English prefix
//   continued-prefix:     续表前缀（主语言）/ Continued table prefix
//   continued-prefix-en:  续表前缀（英文）/ English continued prefix
//   continued-suffix:     续表后缀（主语言）/ Continued table suffix
//   continued-suffix-en:  续表后缀（英文）/ English continued suffix
//   continued-mode:       续表模式："prefix"（续表X）或"suffix"（表X（续））
//                         Continuation mode: "prefix" or "suffix"
//   continued-show-caption: 续表是否显示标题文本 / Show caption text in continuation
//   caption-size:         标题字号 / Caption font size
//   caption-weight:       标题字重 / Caption font weight
//   pre-supplement-number-spacing:  前缀与编号间距 / Prefix-number spacing
//   post-supplement-number-spacing: 编号与后缀间距 / Number-suffix spacing
//   number-title-spacing:    编号与主语言标题间距 / Number-title separator
//   number-title-spacing-en: 编号与英文标题间距 / Number-English-title separator
//   lang:                 语言覆盖（auto=跟随 text.lang）/ Language override
//   enable-english-caption: 是否生成英文副标题 / Enable English sub-caption
//   body-size:            表格内容字号 / Table body font size
//   body-leading:         表格内容行距 / Table body line spacing
//   cell-inset:           单元格内边距（字典或标量）/ Cell padding
//   note-above:           表注上方间距 / Space above note
//   note-below:           表注下方间距 / Space below note
//   note-size:            表注字号 / Note font size
//   note-leading:         表注行距 / Note line spacing
//   note-justify:         表注是否两端对齐 / Justify note text
//   outline-bilingual:    目录中是否双语显示 / Bilingual captions in outline
//   outline-separator:    目录双语分隔符 / Bilingual separator in outline
//   outline-newline:      目录双语是否换行 / Newline for bilingual in outline
//   after-indent:         首行缩进修复（auto=按语言自动）/ Indentation fix

// 表格全局样式配置状态，由 table-style() 更新，被 cap-table()、bicap()、table-note() 读取。
// Global table style state, updated by table-style(), read by cap-table(), bicap(), table-note().
#let table-style-config = state("table-style-config", (
  caption-above: 1.5em,
  caption-below: 0.5em,
  table-below: 0.5em,
  caption-leading: 0.5em,
  numbering-format: "1",
  use-chapter: true,
  chapter-level: 0,
  supplement: auto,
  supplement-en: auto,
  continued-prefix: auto,
  continued-prefix-en: auto,
  continued-suffix: auto,
  continued-suffix-en: auto,
  continued-mode: "prefix",
  continued-show-caption: auto,
  caption-size: 10.5pt,
  caption-weight: "regular",
  pre-supplement-number-spacing: auto,
  post-supplement-number-spacing: auto,
  number-title-spacing: auto,
  number-title-spacing-en: auto,
  lang: auto,
  enable-english-caption: true,
  body-size: 10.5pt,
  body-leading: 0.45em,
  cell-inset: (x: 3pt, y: 6.5pt),
  note-above: 0.7em,
  note-below: 1em + 1.5pt,
  note-size: 10.5pt,
  note-leading: 6.5pt,
  note-justify: true,
  outline-bilingual: false,
  outline-separator: " / ",
  outline-newline: false,
  after-indent: auto,
))

// 图片全局样式配置状态（合并了样式、间距、子图三部分字段）。
// 由 figure-style() 更新，被 capfig()、capsubfig()、capfnote()、bicap()（图片模式）读取。
// Global figure config (merged: style + spacing + subfigure fields).
// Updated by figure-style(), read by capfig(), capsubfig(), capfnote(), bicap() (figure mode).
#let figure-style-config = state("figure-style", (
  // ─ 编号与标题 / Numbering & caption ─
  numbering-format: "1",
  use-chapter: false,
  chapter-level: 0,
  supplement: auto,
  supplement-en: auto,
  continued-prefix: auto,
  continued-prefix-en: auto,
  continued-suffix: auto,
  continued-suffix-en: auto,
  continued-mode: "prefix",
  continued-show-caption: auto,
  caption-size: 10.5pt,
  caption-weight: "regular",
  pre-supplement-number-spacing: auto,
  post-supplement-number-spacing: auto,
  number-title-spacing: auto,
  number-title-spacing-en: auto,
  lang: auto,
  enable-english-caption: true,
  outline-bilingual: false,
  outline-separator: " / ",
  outline-newline: false,
  after-indent: auto,
  // ─ 图注 / Figure note ─
  note-above: 0.7em,
  note-below: 1em + 1.5pt,
  note-size: 10.5pt,
  note-leading: 6.5pt,
  note-justify: true,
  // ─ 间距 / Spacing ─
  figure-above: 1em,
  figure-below: 1em,
  caption-above: 0.5em,
  caption-leading: 0.5em,
  subcaption-above: 0.3em,
  subcaption-below: 0.5em,
  // ─ 子图布局与标签 / Subfigure layout & labels ─
  gutter: 1em,
  subcaption-pos: "bottom",
  show-subcaption: false,
  show-subcaption-label: true,
  align: "horizon",
  label-mode: none,
  label-style: "(a)",
  label-font: ("Arial",),
  label-size: 12pt,
  label-offset: (4pt, 4pt),
  label-text-color: black,
  label-stroke: none,
  label-bg: none,
  label-bg-shape: "rect",
  label-bg-radius: 2pt,
  label-bg-inset: 3pt,
  label-sep: auto,
))

// 表格宽度全局配置（百分比，1-100）。
// Global table width config (percentage, 1-100).
#let table-width-config = state("table-width", 100)

// 图片宽度全局配置（百分比，1-100），用于 capfnote 默认宽度匹配。
// Global figure width config (percentage, 1-100), used by capfnote auto-width.
#let figure-width-config = state("figure-width", 100)

// ============================================================
// 辅助工具函数 (Utility Functions)
// ============================================================

/// Set table width percentage (1-100) for all subsequent captab calls.
/// -> content
#let set-table-width(
  // 宽度百分比，有效范围 1-100 / Width percentage, valid range 1-100
  percentage: 100
) = {
  // 参数校验：百分比必须在合法范围内 / Validate percentage is in range
  assert(percentage > 0 and percentage <= 100, message: "percentage必须在1-100之间")
  table-width-config.update(percentage)
}

/// Set figure width percentage (1-100) for capfnote auto-width matching.
/// -> content
#let set-figure-width(
  percentage: 100
) = {
  assert(percentage > 0 and percentage <= 100, message: "percentage必须在1-100之间")
  figure-width-config.update(percentage)
}

// 解析语言代码：结合 text.lang 和 text.region 生成完整语言代码。
// 例如 lang="zh", region="TW" → 先查 "zh-TW"，再回退到 "zh"。
// Resolve language code: combine text.lang and text.region.
// e.g. lang="zh", region="TW" → try "zh-TW" first, fall back to "zh".
// 必须在 context 块内调用 / Must be called inside a context block.
#let resolve-lang-code(lang) = {
  let base = if lang == auto { text.lang } else { lang }
  let region = text.region
  if region != none {
    let combined = base + "-" + region
    if combined in table-lang-config { combined } else { base }
  } else {
    base
  }
}

/// 共享语言与缩进修复解析函数。给定含 lang/after-indent 字段的配置，
/// 返回 (lang, should-indent)。供 captab/capfig/captnote/capfnote 复用。
/// Shared language/indent resolution. Given a config dict with lang/after-indent
/// fields, returns (lang, should-indent). Used by captab/capfig/captnote/capfnote.
#let resolve-lang-indent(config) = {
  let lang = resolve-lang-code(config.at("lang", default: auto))
  let should-indent = if config.at("after-indent", default: auto) == auto {
    needs-after-indent(lang)
  } else {
    config.at("after-indent")
  }
  (lang, should-indent)
}

// 从编号格式字符串计算章节层级数。
// Calculate the number of chapter levels from a numbering format string.
// format-str (str): 编号格式字符串，如 "1"、"1.1"、"A.1" / Numbering format string
#let calculate-chapter-levels(
  format-str
) = {
  let count = 0
  let i = 0
  // 逐字符遍历，统计格式占位符数量
  // Iterate char by char, count format placeholder characters
  while i < format-str.len() {
    let char = format-str.at(i)
    // 支持的格式字符：1（阿拉伯数字）、a（小写字母）、A（大写字母）、
    // i（小写罗马数字）、I（大写罗马数字）
    // Supported: 1 (arabic), a (lowercase), A (uppercase), i (roman lc), I (roman uc)
    if char == "1" or char == "a" or char == "A" or char == "i" or char == "I" {
      count += 1
    }
    i += 1
  }
  // 最后一个格式字符代表图/表本身的序号，不计入章节层级
  // The last format char is the figure/table number itself, not a chapter level
  if count > 0 { count - 1 } else { 1 }
}

// 获取文档语言对应的本地化文本，不支持的语言回退到英文。
// Get localized text for the document language, falling back to English if unsupported.
// lang-code (str): 语言代码 / Language code; key (str): 配置字典键名 / Config dict key
#let get-table-text(
  lang-code,
  key
) = {
  if lang-code in table-lang-config {
    table-lang-config.at(lang-code).at(key)
  } else {
    // 语言不在支持列表中，回退到英文 / Language not supported, fall back to English
    table-lang-config.en.at(key)
  }
}

// 处理间距值：length/relative 类型转为 h() 水平间距，内容类型直接输出。
// Handle spacing: convert length/relative to h(); pass content through as-is.
// spacing-value: 间距值（长度或内容块）/ Spacing value (length or content)
#let handle-spacing(
  spacing-value
) = {
  if type(spacing-value) == length or type(spacing-value) == relative {
    h(spacing-value)  // 长度转水平间距 / Convert length to horizontal space
  } else {
    spacing-value     // 内容直接输出 / Output content as-is
  }
}

// ============================================================
// 表格样式配置函数 (Table Style Configuration Function)
// ============================================================

/// Configure global table style for all cap-table, bicap and table-note calls within the body.
/// -> content
#let captab-style(
  // 标题块上方垂直间距 / Space above caption block
  caption-above: 1.5em,
  // 标题与表体之间垂直间距 / Space between caption and table body
  caption-below: 0.5em,
  // 整个表格下方垂直间距 / Space below the whole table
  table-below: 0.5em,
  // 标题行距 / Caption line spacing
  caption-leading: 0.5em,
  // 编号格式字符串，如 "1" 或 "1.1" / Numbering format string
  numbering-format: "1",
  // 是否在编号中包含章节号 / Whether to include chapter number
  use-chapter: true,
  // 主语言表格前缀词（auto=自动）/ Main language table prefix (auto=automatic)
  supplement: auto,
  // 英文表格前缀词 / English table prefix
  supplement-en: auto,
  // 续表前缀（主语言，auto=自动）/ Continued table prefix (main language, auto=automatic)
  continued-prefix: auto,
  // 续表前缀（英文，auto=自动）/ Continued table prefix (English, auto=automatic)
  continued-prefix-en: auto,
  // 续表后缀（主语言，auto=自动）/ Continued table suffix (main language, auto=automatic)
  continued-suffix: auto,
  // 续表后缀（英文，auto=自动）/ Continued table suffix (English, auto=automatic)
  continued-suffix-en: auto,
  // 续表模式："prefix" 或 "suffix" / Continuation mode: "prefix" or "suffix"
  continued-mode: "prefix",
  // 续表是否显示原标题文本（auto=有标题则显示）/ Show caption in continuation
  continued-show-caption: auto,
  // 标题字号 / Caption font size
  caption-size: 10.5pt,
  // 标题字重 / Caption font weight
  caption-weight: "regular",
  // 前缀词与编号间距（auto=按语言自动）/ Prefix-number spacing
  pre-supplement-number-spacing: auto,
  // 编号与续表后缀间距（auto=按语言自动）/ Number-suffix spacing
  post-supplement-number-spacing: auto,
  // 编号与主语言标题间距（auto=按语言自动）/ Number-to-title separator
  number-title-spacing: auto,
  // 编号与英文标题间距（auto=按语言自动）/ Number-to-English-title separator
  number-title-spacing-en: auto,
  // 语言代码覆盖（auto=跟随 text.lang）/ Language code override
  lang: auto,
  // 是否生成英文副标题 / Generate English sub-caption
  enable-english-caption: true,
  // 表格内容字号 / Table body font size
  body-size: 10.5pt,
  // 表格内容行距 / Table body line spacing
  body-leading: 0.45em,
  // 单元格内边距 / Cell padding
  cell-inset: (x: 5pt, y: 5pt),
  // 表注上方间距 / Space above table note
  note-above: 0.5em,
  // 表注下方间距 / Space below table note
  note-below: 1em,
  // 表注字号 / Table note font size
  note-size: 10.5pt,
  // 表注行距 / Table note line spacing
  note-leading: 6.5pt,
  // 表注是否两端对齐 / Justify table note text
  note-justify: true,
  // 目录中是否双语显示标题 / Show bilingual captions in outline
  outline-bilingual: false,
  // 目录双语分隔符 / Bilingual separator in outline
  outline-separator: " / ",
  // 目录双语是否换行显示 / Newline for bilingual captions in outline
  outline-newline: false,
  // 是否修复表格后首行缩进（auto=按语言自动）/ Fix indentation after table
  after-indent: auto,
  // 文档内容 / Document body content
  it
) = {
  // 从 numbering-format 自动计算章节层级数
  // Auto-calculate chapter level count from numbering-format
  let final-chapter-level = calculate-chapter-levels(numbering-format)

  // 更新全局表格配置状态 / Update global table configuration state
  table-style-config.update((
    caption-above: caption-above,
    caption-below: caption-below,
    table-below: table-below,
    caption-leading: caption-leading,
    numbering-format: numbering-format,
    use-chapter: use-chapter,
    chapter-level: final-chapter-level,
    supplement: supplement,
    supplement-en: supplement-en,
    continued-prefix: continued-prefix,
    continued-prefix-en: continued-prefix-en,
    continued-suffix: continued-suffix,
    continued-suffix-en: continued-suffix-en,
    continued-mode: continued-mode,
    continued-show-caption: continued-show-caption,
    caption-size: caption-size,
    caption-weight: caption-weight,
    pre-supplement-number-spacing: pre-supplement-number-spacing,
    post-supplement-number-spacing: post-supplement-number-spacing,
    number-title-spacing: number-title-spacing,
    number-title-spacing-en: number-title-spacing-en,
    lang: lang,
    enable-english-caption: enable-english-caption,
    body-size: body-size,
    body-leading: body-leading,
    cell-inset: cell-inset,
    note-above: note-above,
    note-below: note-below,
    note-size: note-size,
    note-leading: note-leading,
    note-justify: note-justify,
    outline-bilingual: outline-bilingual,
    outline-separator: outline-separator,
    outline-newline: outline-newline,
    after-indent: after-indent,
  ))

  // 仅对 kind: table 的 figure 设置标题位置与间距
  // Scoped to kind: table — caption on top, gap between caption and body
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: caption-below)

  // 章节前缀编号（全局生效；capfig-style 会以相同策略再次设置）
  // Chapter-prefixed numbering (applies globally; capfig-style sets the same strategy)
  set figure(
    numbering: num => {
      if use-chapter {
        let levels = final-chapter-level
        let h = counter(heading).get()
        let chapter-nums = h.slice(0, calc.min(levels, h.len()))
        numbering(numbering-format, ..chapter-nums, num)
      } else {
        numbering("1", num)
      }
    }
  )

  // 覆盖 figure.caption 渲染（仅针对 kind: table 类型）
  // Override figure.caption rendering (only for kind: table)
  // 注意：cap-table() 使用 _make_caption_content() 直接生成标题，不经过此规则
  // Note: cap-table() bypasses this rule via _make_caption_content()
  show figure.caption.where(kind: table): cap => {
    set par(leading: caption-leading)
    text(size: caption-size, weight: caption-weight)[
      #cap.supplement
      #context {
        let current-lang = resolve-lang-code(lang)
        let pre-space = if pre-supplement-number-spacing == auto {
          get-table-text(current-lang, "pre-supplement-number-spacing")
        } else {
          pre-supplement-number-spacing
        }
        handle-spacing(pre-space)
        if use-chapter {
          let levels = final-chapter-level
          let h-counter = counter(heading).get()
          let chapter-nums = h-counter.slice(0, calc.min(levels, h-counter.len()))
          let num = cap.counter.at(cap.location()).first()
          numbering(numbering-format, ..chapter-nums, num)
        } else {
          cap.counter.display()
        }
        let title-space = if number-title-spacing == auto {
          get-table-text(current-lang, "number-title-spacing")
        } else {
          number-title-spacing
        }
        handle-spacing(title-space)
      }
      #cap.body
    ]
  }

  it
}


// ============================================================
// 图片样式配置函数 (Figure Style Configuration Function)
// ============================================================

/// Configure global figure and subfigure style within the body.
/// -> content
#let capfig-style(
  // 编号格式字符串 / Numbering format string
  numbering-format: "1",
  // 是否使用章节号 / Whether to use chapter numbering
  use-chapter: false,
  // 主语言图片前缀词（auto=自动）/ Main language figure prefix
  supplement: auto,
  // 英文图片前缀词 / English figure prefix
  supplement-en: auto,
  // 续图前缀（主语言，auto=自动）/ Continued figure prefix (main language)
  continued-prefix: auto,
  // 续图前缀（英文，auto=自动）/ Continued figure prefix (English)
  continued-prefix-en: auto,
  // 续图后缀（主语言，auto=自动）/ Continued figure suffix (main language)
  continued-suffix: auto,
  // 续图后缀（英文，auto=自动）/ Continued figure suffix (English)
  continued-suffix-en: auto,
  // 续图模式："prefix" 或 "suffix" / Continuation mode
  continued-mode: "prefix",
  // 续图是否显示原标题文本 / Show caption in continued figure
  continued-show-caption: auto,
  // 标题字号 / Caption font size
  caption-size: 10.5pt,
  // 标题字重 / Caption font weight
  caption-weight: "regular",
  // 前缀与编号间距（auto=按语言）/ Prefix-number spacing
  pre-supplement-number-spacing: auto,
  // 编号与后缀间距（auto=按语言）/ Number-suffix spacing
  post-supplement-number-spacing: auto,
  // 编号与主语言标题间距（auto=按语言）/ Number-to-title separator
  number-title-spacing: auto,
  // 编号与英文标题间距（auto=按语言）/ Number-to-English-title separator
  number-title-spacing-en: auto,
  // 语言代码覆盖（auto=跟随 text.lang）/ Language code override
  lang: auto,
  // 是否启用英文副标题 / Enable English sub-caption
  enable-english-caption: true,
  // 目录中是否双语显示 / Show bilingual captions in outline
  outline-bilingual: false,
  // 目录双语分隔符 / Bilingual separator in outline
  outline-separator: " / ",
  // 目录双语是否换行 / Newline for bilingual captions in outline
  outline-newline: false,
  // 首行缩进修复（auto=按语言）/ Indentation fix
  after-indent: auto,
  // 图片上方间距 / Space above figure
  figure-above: 1em,
  // 图片下方间距 / Space below figure
  figure-below: 1em,
  // 标题上方间距（标题与图片之间）/ Space above caption
  caption-above: 0.5em,
  // 标题行距 / Caption line spacing
  caption-leading: 0.5em,
  // 子标题上方间距 / Space above subcaption
  subcaption-above: 0.3em,
  // 子标题下方间距 / Space below subcaption
  subcaption-below: 0.5em,
  // 子图水平间距 / Horizontal gap between subfigures
  gutter: 1em,
  // 子标题位置："top" 或 "bottom" / Subcaption position
  subcaption-pos: "bottom",
  // 是否显示子标题文字 / Show subcaption text
  show-subcaption: false,
  // 子标题是否含标签 / Whether subcaption includes the label
  show-subcaption-label: true,
  // 多子图垂直对齐 / Vertical alignment of subfigures
  align: "horizon",
  // 标签模式：none 或 "overlay" / Label mode: none or "overlay"
  label-mode: none,
  // 标签样式字符串 / Label style string
  label-style: "(a)",
  // 标签字体列表 / Label font list
  label-font: ("Arial",),
  // 标签字号 / Label font size
  label-size: 12pt,
  // 标签偏移量 (dx, dy) / Label offset from top-left
  label-offset: (4pt, 4pt),
  // 标签文字颜色 / Label text color
  label-text-color: black,
  // 标签描边（none=无描边）/ Label stroke
  label-stroke: none,
  // 标签背景色（none=无背景）/ Label background color
  label-bg: none,
  // 背景形状："rect" 或 "circle" / Background shape
  label-bg-shape: "rect",
  // 矩形背景圆角 / Border radius for rect background
  label-bg-radius: 2pt,
  // 背景内边距 / Background padding
  label-bg-inset: 3pt,
  // 子图引用分隔符（auto=自动）/ Subfigure reference separator
  label-sep: auto,
  // 图注上方间距 / Space above figure note
  note-above: 0.7em,
  // 图注下方间距 / Space below figure note
  note-below: 1em + 1.5pt,
  // 图注字号 / Figure note font size
  note-size: 10.5pt,
  // 图注行距 / Figure note line spacing
  note-leading: 6.5pt,
  // 图注是否两端对齐 / Justify figure note text
  note-justify: true,
  // 文档内容 / Document body content
  it,
) = {
  // 从编号格式自动计算章节层级 / Auto-calculate chapter level from numbering format
  let final-chapter-level = calculate-chapter-levels(numbering-format)

  // 合并后的单一状态更新（样式 + 间距 + 子图）
  // Single merged state update (style + spacing + subfigure)
  figure-style-config.update((
    numbering-format: numbering-format,
    use-chapter: use-chapter,
    chapter-level: final-chapter-level,
    supplement: supplement,
    supplement-en: supplement-en,
    continued-prefix: continued-prefix,
    continued-prefix-en: continued-prefix-en,
    continued-suffix: continued-suffix,
    continued-suffix-en: continued-suffix-en,
    continued-mode: continued-mode,
    continued-show-caption: continued-show-caption,
    caption-size: caption-size,
    caption-weight: caption-weight,
    pre-supplement-number-spacing: pre-supplement-number-spacing,
    post-supplement-number-spacing: post-supplement-number-spacing,
    number-title-spacing: number-title-spacing,
    number-title-spacing-en: number-title-spacing-en,
    lang: lang,
    enable-english-caption: enable-english-caption,
    outline-bilingual: outline-bilingual,
    outline-separator: outline-separator,
    outline-newline: outline-newline,
    after-indent: after-indent,
    note-above: note-above,
    note-below: note-below,
    note-size: note-size,
    note-leading: note-leading,
    note-justify: note-justify,
    figure-above: figure-above,
    figure-below: figure-below,
    caption-above: caption-above,
    caption-leading: caption-leading,
    subcaption-above: subcaption-above,
    subcaption-below: subcaption-below,
    gutter: gutter,
    subcaption-pos: subcaption-pos,
    show-subcaption: show-subcaption,
    show-subcaption-label: show-subcaption-label,
    align: align,
    label-mode: label-mode,
    label-style: label-style,
    label-font: label-font,
    label-size: label-size,
    label-offset: label-offset,
    label-text-color: label-text-color,
    label-stroke: label-stroke,
    label-bg: label-bg,
    label-bg-shape: label-bg-shape,
    label-bg-radius: label-bg-radius,
    label-bg-inset: label-bg-inset,
    label-sep: label-sep,
  ))

  // 章节前缀编号（全局生效；captab-style 会以相同策略再次设置）
  // Chapter-prefixed numbering (applies globally; captab-style sets the same strategy)
  set figure(
    numbering: num => {
      if use-chapter {
        let levels = final-chapter-level
        let h = counter(heading).get()
        let chapter-nums = h.slice(0, calc.min(levels, h.len()))
        numbering(numbering-format, ..chapter-nums, num)
      } else {
        numbering("1", num)
      }
    }
  )

  it
}

// ============================================================
// 统一样式配置函数 (Unified Style Configuration Function)
// ============================================================

/// 同时为表格和图片设置全局样式。共享参数会同时作用于两者；
/// 之后再调用 captab-style 或 capfig-style 可对某一类进行覆盖。
/// Configure both table and figure global styles at once. Shared params are applied to
/// both; a subsequent captab-style / capfig-style call can override for one type only.
/// -> content
#let cap-style(
  numbering-format: "1",
  use-chapter: false,
  supplement: auto,
  supplement-en: auto,
  continued-prefix: auto,
  continued-prefix-en: auto,
  continued-suffix: auto,
  continued-suffix-en: auto,
  continued-mode: "prefix",
  continued-show-caption: auto,
  caption-size: 10.5pt,
  caption-weight: "regular",
  caption-leading: 0.5em,
  caption-above: 1.5em,
  pre-supplement-number-spacing: auto,
  post-supplement-number-spacing: auto,
  number-title-spacing: auto,
  number-title-spacing-en: auto,
  lang: auto,
  enable-english-caption: true,
  outline-bilingual: false,
  outline-separator: " / ",
  outline-newline: false,
  after-indent: auto,
  note-above: 0.7em,
  note-below: 1em,
  note-size: 10.5pt,
  note-leading: 6.5pt,
  note-justify: true,
  it,
) = {
  show: captab-style.with(
    numbering-format: numbering-format,
    use-chapter: use-chapter,
    supplement: supplement,
    supplement-en: supplement-en,
    continued-prefix: continued-prefix,
    continued-prefix-en: continued-prefix-en,
    continued-suffix: continued-suffix,
    continued-suffix-en: continued-suffix-en,
    continued-mode: continued-mode,
    continued-show-caption: continued-show-caption,
    caption-size: caption-size,
    caption-weight: caption-weight,
    caption-leading: caption-leading,
    caption-above: caption-above,
    pre-supplement-number-spacing: pre-supplement-number-spacing,
    post-supplement-number-spacing: post-supplement-number-spacing,
    number-title-spacing: number-title-spacing,
    number-title-spacing-en: number-title-spacing-en,
    lang: lang,
    enable-english-caption: enable-english-caption,
    outline-bilingual: outline-bilingual,
    outline-separator: outline-separator,
    outline-newline: outline-newline,
    after-indent: after-indent,
    note-above: note-above,
    note-below: note-below,
    note-size: note-size,
    note-leading: note-leading,
    note-justify: note-justify,
  )
  show: capfig-style.with(
    numbering-format: numbering-format,
    use-chapter: use-chapter,
    supplement: supplement,
    supplement-en: supplement-en,
    continued-prefix: continued-prefix,
    continued-prefix-en: continued-prefix-en,
    continued-suffix: continued-suffix,
    continued-suffix-en: continued-suffix-en,
    continued-mode: continued-mode,
    continued-show-caption: continued-show-caption,
    caption-size: caption-size,
    caption-weight: caption-weight,
    caption-leading: caption-leading,
    caption-above: caption-above,
    pre-supplement-number-spacing: pre-supplement-number-spacing,
    post-supplement-number-spacing: post-supplement-number-spacing,
    number-title-spacing: number-title-spacing,
    number-title-spacing-en: number-title-spacing-en,
    lang: lang,
    enable-english-caption: enable-english-caption,
    outline-bilingual: outline-bilingual,
    outline-separator: outline-separator,
    outline-newline: outline-newline,
    after-indent: after-indent,
    note-above: note-above,
    note-below: note-below,
    note-size: note-size,
    note-leading: note-leading,
    note-justify: note-justify,
  )
  it
}
