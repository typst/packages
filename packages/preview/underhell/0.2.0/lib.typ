// ============================================================
// typst-dnd5e 主题库 / Theme Library
// 提供 D&D 5e 风格的文档排版组件 / D&D 5e styled document components
// ============================================================

// 主题色定义 / Theme color definitions
#let darkred = rgb("#540808")     // 深红色:用于标题、强调线条 / Dark red: for headings, accent lines
#let darkyellow = rgb("#fcba03")  // 暗黄色:用于二级标题下划线 / Dark yellow: for level-2 heading underline
#let dnd = smallcaps("Dungeons & Dragons")  // D&D 商标文本(小型大写)/ D&D trademark text (smallcaps)

// 页脚内容生成器 / Footer content generator
// 第 1 页之后显示页脚图片与页码 / Show footer image and page number after page 1
#let footer-content = context {
      if here().page() > 1 {
        place(left+bottom, image("img/footer.svg", width: 100%))
        align(center)[#here().page()]
      }
    }
// 页脚状态:允许在文中动态修改页脚 / Footer state: allows dynamic modification within the document
#let footer = state("footer", footer-content)

// 语言状态:存储当前语言的 TOML 配置 / Language state: stores current language TOML config
// 默认加载英文配置 / Loads English config by default
#let language = state("language", toml("languages/en.toml"))

// ------------------------------------------------------------
// dndmodule:文档主模板 / Main document template
// 用作 #show: dndmodule.with(...) 应用整篇文档样式
// Used via #show: dndmodule.with(...) to apply document-wide styling
//
// 参数 / Parameters:
//   title        - 文档标题(封面大标题)/ Document title (cover headline)
//   author       - 作者 / Author
//   subtitle     - 副标题 / Subtitle
//   cover        - 封面背景图 / Cover background image
//   font-size    - 正文字号(默认 12pt)/ Body font size (default 12pt)
//   paper        - 纸张尺寸(默认 a4)/ Paper size (default a4)
//   logo         - 右下角 logo 图 / Logo image at bottom-right
//   fancy-author - 是否使用花式作者展示(带火焰图案)/ Fancy author display with fire splash
//   add-title    - 封面是否显示标题 / Whether to show title on cover
//   bg           - 正文背景,"default" 使用默认背景,或传入自定义图 / Body background
//   lang         - 语言代码(如 "en"/"zh"/"it"),决定加载哪个 languages/*.toml
//                  Language code, determines which languages/*.toml to load
//   print        - 打印模式:去除背景图/封面图、双栏、宽边距、纯黑文字、简化页脚
//                  默认自动读取编译时输入变量 --input print=true;
//                  文档也可显式传入 print: true/false 覆盖
//                  Print mode: no background/cover images, two columns, wider margins,
//                  pure black text, simplified footer (for ink-saving physical print).
//                  Defaults to reading --input print=true at compile time;
//                  documents can override with print: true/false
//   screen       - 小屏模式:A5 单栏、保留背景与彩色装饰、窄边距、较小字号
//                  适合手机/平板等窄屏设备阅读
//                  默认自动读取编译时输入变量 --input screen=true;
//                  Screen mode: A5 single column, keeps background & colors, narrow margins,
//                  smaller font size. For reading on phones/tablets.
//                  Defaults to reading --input screen=true at compile time
// ------------------------------------------------------------
#let dndmodule(title: "",
              author: "",
              subtitle: "",
              cover: none,
              font-size: 12pt,
              paper: "a4",
              logo: none,
              fancy-author: false,
              add-title: true,
              bg: "default",
              lang: "en",
              print: "print" in sys.inputs and sys.inputs.print == "true",
              screen: "screen" in sys.inputs and sys.inputs.screen == "true",
  body) = {
  // 设置文档元数据 / Set document metadata
  set document(author: author, title: title)
  // 段落间距与首行缩进 / Paragraph spacing and first-line indent
  set par(spacing: 0.7em, first-line-indent: (amount: 1.5em, all: false))
  // set heading(numbering: "1.1")

  // 读取语言 TOML,提取字体配置(优先级低于用户在文章中自定义的字体)
  // Load language TOML and extract font config (lower priority than user's custom fonts)
  let lang-toml = if lang == "en" {
    toml("languages/en.toml")
  } else {
    toml("languages/" + lang + ".toml")
  }
  // 解析 [fonts] 段,缺省则使用空字典 / Parse [fonts] section, default to empty dict
  let fonts-cfg = if "fonts" in lang-toml { lang-toml.fonts } else { (:) }
  // 正文字体列表(支持回退)/ Body font list (with fallback)
  let body-fonts = if "body" in fonts-cfg { fonts-cfg.body } else { none }
  // 标题字体列表(支持回退)/ Header font list (with fallback)
  let header-fonts = if "header" in fonts-cfg { fonts-cfg.header } else { none }
  // 构造 text() 的命名参数包,无配置时为空字典 / Build named args for text(); empty dict if none
  let header-font-args = if header-fonts != none { (font: header-fonts) } else { (:) }

  // 非 en 时更新语言状态 / Update language state when not English
  if lang != "en" {
    language.update(lang-toml)
  }

  // 打印模式:标题用纯黑而非深红,省墨且对比度高;小屏模式保留深红
  // Print mode: headings in pure black; screen mode keeps dark red
  let heading-fill = if print { black } else { darkred }

  // 一级标题样式:小型大写、深红色(打印模式为黑色)/ Level-1 heading: smallcaps
  show heading: it => block(text(
    ..header-font-args,
    size: 1.5em,
    fill: heading-fill,
    weight: "regular",
    // style: "italic",
    smallcaps(it),
  ))

  // 二级标题样式:带黄色下划线(打印模式去掉下划线)/ Level-2 heading
  show heading.where(
    level: 2
  ): it => block(text(
    ..header-font-args,
    size: 1.5em,

    fill: heading-fill,
    weight: "regular",

  )[
    #box(width: 100%, inset: (bottom: 4pt), stroke: (bottom: if print { 0pt } else { 1pt + darkyellow }))[#smallcaps(it)]
  ])

  // 正文背景图:打印模式禁用;小屏/普通模式保留 / Body background
  let bg-img = if print or bg == none {
    none
  } else if bg == "default" {
    image("img/background.jpg", width: 110%)
  } else {
    bg
  }

  // 小屏模式字号在下方 text-args 中统一设置 / Screen font size set in text-args below

  // 根据模式构造页面参数(必须在 if 块外 set,否则词法作用域不延伸)
  // Build page args based on mode (must set outside if block due to lexical scoping)
  let page-args = if print {
    // 打印模式:双栏、宽边距(装订余量)、无背景、简化页脚(仅页码)
    // Print mode: two columns, wider margins (binding), no background, simple footer
    (
      flipped: false,
      margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
      numbering: "1",
      number-align: center,
      columns: 2,
      background: none,
      footer: context {
        if here().page() > 1 {
          align(center)[#here().page()]
        }
      },
    )
  } else if screen {
    // 小屏模式:单栏、窄边距、保留背景、简化页脚
    // Screen mode: single column, narrow margins, keep background, simple footer
    (
      flipped: false,
      margin: (left: 10mm, right: 10mm, top: 15mm, bottom: 15mm),
      numbering: "1",
      number-align: center,
      columns: 1,
      background: bg-img,
      footer: context {
        if here().page() > 1 {
          align(center)[#here().page()]
        }
      },
    )
  } else {
    (
      flipped: false,
      margin: (left: 15mm, right: 15mm, top: 30mm, bottom: 30mm),
      numbering: "1",
      number-align: start,
      columns: 2,
      background: bg-img,
      footer: context { footer.get()
        footer.update(footer-content)
      },
    )
  }
  // 小屏模式使用 A5 纸张 / Screen mode uses A5 paper
  let actual-paper = if screen { "a5" } else { paper }
  set page(actual-paper, ..page-args)

  // 副标题非空时追加换行,便于排版 / Append newline to subtitle if non-empty
  if subtitle.len() > 0 {
    subtitle = subtitle + "\n"
  }

  // 封面页 / Front page
  if print {
    // 打印模式封面:纯白背景,黑色文字,无装饰图 / Print cover: white bg, black text
    page(background: none, margin: (top: 40mm, bottom: 20mm), columns: 1)[
      #if add-title {
        place(top + center, text(fill: black, size: 48pt, weight: 800, upper(title)))
      }
      #if subtitle.len() > 0 {
        place(bottom + center, dy: -1cm,
          text(fill: black, size: 18pt)[#subtitle #if not fancy-author {"by " + author}]
        )
      }
    ]
  } else if screen {
    // 小屏模式封面:保留背景图与彩色标题,缩小字号 / Screen cover: keep bg, smaller text
    page(background: cover, margin: (top: 20mm, bottom: 10mm), columns: 1)[
      #if add-title {
        place(top + center,
          box(fill: rgb("#00000066"), inset: 8%, text(fill: white, size: 36pt, weight: 800, upper(title)))
        )
      }
      #if subtitle.len() > 0 {
        place(
          bottom + center,
          dy: -0.2cm,
          box(width: 85%, fill: rgb("#00000066"), inset: (left:8pt, right:8pt, top:8pt, bottom: 8pt), text(fill: white, size: 14pt)[#subtitle #if not fancy-author {"by " + author}]
        ))
      }
    ]
  } else {
    // FRONT PAGE / 封面页(单栏)
    page(background: cover, margin: (top: 10mm, bottom: 5mm),
  columns: 1)[
    #if add-title {
      // 顶部居中大标题 / Top-center large title
      place(
        top + center,
        box(fill: rgb("#00000066"), inset: 10%, text(fill: white, size: 60pt, weight: 800, upper(title)))
      )
     }

      #if subtitle.len() > 0 {
      // 底部副标题(可选作者名)/ Bottom subtitle (with optional author)
      place(
        bottom + center,
        dy: -0.2cm,
        box(width: 80%, fill: rgb("#00000066"), inset: (left:10pt, right:10pt, top:10pt, bottom: 10pt), text(fill: white, size:20pt)[#subtitle #if not fancy-author {"by " + author}]
      ))}

      #if logo != none {
        // 右下角 logo / Logo at bottom-right
        place(dx: 91%, dy: 100%-2.5cm,
          logo // image("img/DMsGuildLogo.jpg", width: 13%)
        )
      }

      #if fancy-author {
        // 花式作者展示:火焰图案 + 作者名 / Fancy author: fire splash + author name
        place(dx: -10%, dy: 73%, image("img/fire_splash.svg", width: 60%))
        place(dx: -10% + 0.7cm, dy: 73% + 0.7cm)[#text(size: 18pt, fill: white, weight: 700)[by #author]]
      }
    ]
  }

  // 应用正文字体(来自语言 TOML,优先级低于用户在文章中 set text(font: ...) 的自定义)
  // Apply body fonts from language TOML; user's #set text(font: ...) in body overrides this
  // 注意:set 不能放在 if 块内(词法作用域不延伸到块外),改用参数字典构造后一次性 set
  // Note: set inside an if block is lexically scoped and won't leak out; build args first
  // 小屏模式使用较大字号 / Screen mode uses smaller font size
  let actual-font-size = if screen { 16pt } else { font-size }
  let text-args = (size: actual-font-size, lang: lang, fill: black)
  if body-fonts != none {
    text-args.font = body-fonts
  }
  set text(..text-args)

  body

}


// ------------------------------------------------------------
// dndtab:生成 D&D 风格的表格区块 / D&D style table block
//   name     - 表格标题 / Table title
//   columns  - 列宽配置(默认 (1fr, 4fr))/ Column widths
//   breakable - 是否允许跨页 / Whether the block can break across pages
//   contents  - 表格内容(按行展开)/ Table contents (spread as rows)
// ------------------------------------------------------------
#let dndtab(name, columns: (1fr, 4fr), breakable: false, ..contents) = [
  #block(breakable: breakable)[
  // 标题:小型大写 + 1.3em 字号 / Title: smallcaps, 1.3em size
  *#smallcaps(text(size: 1.3em)[#name])*
  #v(-1em)
  #table(
  columns: columns,
  // 第 0 列居中,其余列左对齐 / Column 0 centered, others left-aligned
  align: (col, row) =>
   if col == 0 { center }
    else { left },
  // 隔行变色(斑马纹)/ Alternating row colors (zebra striping)
  fill: (col, row) => if calc.odd(row+1) { rgb("#aaaaaa00") } else { rgb("#aaffaa33") },
  inset: 10pt,
  stroke: none,
  // align: horizon,
  ..contents
  )
]]


// ------------------------------------------------------------
// 浮动图片辅助函数 / Floating figure helpers
// ------------------------------------------------------------

// topfig:在父块顶部浮动放置图片 / Float figure at top of parent block
#let topfig(figure) = [ #place(top + center, dy: -7em, dx:0em, float: true, scope: "parent", clearance: -6em, figure) ]
// bottomfig:在父块底部浮动放置图片 / Float figure at bottom of parent block
// 先清除页脚以避免重叠 / Suppress footer first to avoid overlap
#let bottomfig(figure) = [ // Suppress the footer first
  #context footer.update("")
  #place(bottom + center, dy: 7em, dx:0em, float: true, scope: "parent", clearance: -6em, figure)
]


// ------------------------------------------------------------
// breakoutbox:浮动信息框(顶部+底部边框)/ Floating callout box
//   title    - 标题(可空)/ Title (can be empty)
//   contents - 框内内容 / Box contents
// ------------------------------------------------------------
#let breakoutbox(title, contents) = [#place(auto, float: true)[
  #set par(first-line-indent: 0em, spacing: 0.6em)
  #box(inset: 10pt, width: 100%, stroke: (top: 2pt, bottom: 2pt), fill: rgb("#ddeedd"))[
    #if title.len() > 0 {
      align(left, smallcaps[*#title*])
    }

    #align(left)[#contents]
  ]
]]

// ------------------------------------------------------------
// 属性值换算工具 / Ability modifier utilities
// ------------------------------------------------------------

// bonus:根据属性值计算修正值字符串 / Compute modifier string from ability score
// D&D 5e 规则:(score - 10) / 2 向下取整,>=10 为正 / Rule: floor((score-10)/2), "+" if >= 10
#let bonus(i) = {
  let b = ""
  if i >= 10 {
    b = "+"
  }
  b + str(calc.floor((i - 10)/2))
}

// stat-to-str:格式化为 "值 (修正)" / Format as "score (modifier)"
#let stat-to-str(a) = {
  (str(a) + " (" + bonus(int(a)) + ")")
}

// ------------------------------------------------------------
// stats-table:六维属性表(STR/DEX/CON/INT/WIS/CHA)/ Six-ability stats table
//   stats - 字典,键为属性名,值为数值 / Dict of ability name -> score
// ------------------------------------------------------------
#let stats-table(stats) = {
  let content = ()
  // 第一行:属性名(深红、加粗)/ First row: ability names (dark red, bold)
  for k in stats.keys() {
    content.push([#text(fill: darkred, weight: 700, k)])
  }
  // 第二行:数值(修正)/ Second row: score (modifier)
  for k in stats.values() {
    content.push([#text(fill: black, stat-to-str(k))])
  }
  // 6 列等宽,无描边,居中对齐 / 6 equal columns, no stroke, centered
  table(stroke: none, columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr), inset: 0pt, row-gutter: 5pt, align: center, ..content)
}

// ------------------------------------------------------------
// boxed-text:带黄色侧边的文本框 / Text box with yellow side strokes
//   header   - 标题文本(三级标题)/ Title (level-3 heading)
//   contents - 框内正文 / Box body content
// ------------------------------------------------------------
#let boxed-text(header, contents) = [
  #box(inset: 10pt, fill: rgb("#fefff9"), stroke: (right: 1pt + darkyellow, left: 1pt + darkyellow), width: 100%)[
    #set par(spacing: .6em, first-line-indent: 1.5em)
    #set text(size: 10pt)
    #heading(outlined: false, level: 3, header)
    #v(0.5em)
    #contents
  ]
]

// ------------------------------------------------------------
// statbox:怪物/生物属性框 / Monster/creature stat block
//   stats - 字典,包含 name/description/ac/hp/speed/stats/skillblock/traits
//           以及可选的 actions/reactions/limited_usage/equip/legendary_act
//           Dict with creature info and optional action sections
// ------------------------------------------------------------
#let statbox(stats) = [
  #box(inset: 12pt, fill: white, stroke: 1pt, width: 100%)[
    #set par(spacing: .6em)
    #set text(size: 10pt)
    #heading(outlined: false, level: 3, stats.name)

    // 描述(斜体)/ Description (italic)
    _ #stats.description _

    #line(stroke: 2pt + darkred, length: 100%)
    // AC/HP/Speed 标签使用当前语言配置 / AC/HP/Speed labels from current language
    #context [
      #text(fill: darkred)[*#language.get().stats.ac*] #stats.ac\
      #text(fill: darkred)[*#language.get().stats.hp*] #stats.hp\
      #text(fill: darkred)[*#language.get().stats.speed*] #stats.speed\
    ]

    #line(stroke: 2pt + darkred, length: 100%)
    // 六维属性表 / Six-ability stats table
    #stats-table(stats.stats)
    #line(stroke: 2pt + darkred, length: 100%)

    // 技能块(感知、语言、挑战等级等)/ Skill block (senses, languages, challenge, etc.)
    #for skill in stats.skillblock {
      [#text(fill: darkred)[*#skill.at(0)*] #skill.at(1)\ ]
    }
    #line(stroke: 2pt + darkred, length: 100%)
    // 特性 / Traits
    #for trait in stats.traits {
      [ _*#trait.at(0).*_ #trait.at(1)]
    }

    // 动作段落(标签来自语言配置)/ Action sections (labels from language config)
    #context {
      let sections = (
        language.get().sections.actions,
        language.get().sections.reactions,
        language.get().sections.limited_usage,
        language.get().sections.equip,
        language.get().sections.legendary_act,
      )
      for section in sections {
        // 仅当 stats 中存在该段落时渲染 / Render only if section exists in stats
        if section in stats.keys() {
          block[
            #set par(spacing: 1em)
            #text(size: 1.3em, fill: darkred)[#box(width:100%, inset: (bottom: 3pt), stroke: (bottom: 1pt+darkyellow))[#smallcaps(section)]]
            #for action in stats.at(section) {
              [_*#action.at(0).*_ #action.at(1) \ ]
            }
          ]
        }
      }
    }
  ]
]

// ------------------------------------------------------------
// npcbox:NPC 信息框 / NPC info block
//   npc - 字典,包含 name/race/class/alignment/stats(可选)
//         以及 description/background/roleplay(可选,标签使用语言配置)
//         Dict with NPC info; description/background/roleplay use localized labels
// ------------------------------------------------------------
#let npcbox(npc) = [
  #box(inset: 12pt, fill: white, stroke: 1pt, width: 100%)[
    #set par(spacing: .6em)
    #set text(size: 10pt)
    #heading(outlined: false, level: 3, npc.name)

    // 种族/职业/阵营(斜体,逗号分隔)/ Race/class/alignment (italic, comma-joined)
    #{
      let parts = ()
      if "race" in npc.keys() { parts.push(npc.race) }
      if "class" in npc.keys() { parts.push(npc.class) }
      if "alignment" in npc.keys() { parts.push(npc.alignment) }
      if parts.len() > 0 {
        emph(parts.join(", "))
      }
    }

    #line(stroke: 2pt + darkred, length: 100%)

    // 可选的六维属性表 / Optional six-ability stats table
    #if "stats" in npc.keys() {
      stats-table(npc.stats)
      line(stroke: 2pt + darkred, length: 100%)
    }

    // 描述/背景/角色扮演段落(标签来自语言配置)/ Localized description/background/roleplay sections
    #context {
      let labels = language.get().npc
      let sections = (
        ("description", labels.description),
        ("background", labels.background),
        ("roleplay", labels.roleplay),
      )
      for (key, label) in sections {
        if key in npc.keys() {
          block(spacing: 0.8em)[
            #text(fill: darkred, weight: 700)[#smallcaps(label)] \
            #npc.at(key)
          ]
        }
      }
    }
  ]
]

// ------------------------------------------------------------
// spell:法术条目 / Spell entry
//   spl - 字典,包含 name/spell-type/properties(属性列表)/description
//         Dict with name, spell-type, properties (list), description
// ------------------------------------------------------------
#let spell(spl) = [
  #set par(spacing: .6em, first-line-indent: 0em)
  #heading(outlined: false, level: 3, spl.name)

  // 法术类型(斜体)/ Spell type (italic)
  _#spl.spell-type _
  #v(0.5em)
  // 属性列表(施法时间、范围、持续时间、成分等)/ Property list
  #for prop in spl.properties {

       [*#prop.at(0):* #prop.at(1) \ ]


      }
  #v(0.5em)

  #spl.description

]

// ------------------------------------------------------------
// appendix:附录功能 / Appendix helper
//   title         - 附录总标题(默认 "附录")/ Appendix master title
//   numbering-fmt - 附录标题编号格式(默认 "A.1.",即附录 A 及其子标题 A.1, A.1.1)/
//                   Appendix heading numbering format
//   ..body        - 附录正文内容 / Appendix body content
//
// 用法 / Usage:
//   #appendix[
//     == 附录子标题
//     内容...
//   ]
// 也可通过 include 引入附录文件 / Or include an appendix file:
//   #appendix[#include "附录文件.typ"]
// ------------------------------------------------------------
#let appendix(title: "附录", numbering-fmt: "A.1.", ..body) = [
  // 切换标题编号为字母格式(附录 A, A.1, A.1.1 ...)/
  // Switch heading numbering to letter format
  #set heading(numbering: numbering-fmt)
  // 重置标题计数器,使附录从 A 开始 / Reset heading counter so appendix starts at A
  #counter(heading).update(0)
  // 附录总标题 / Appendix master heading
  #heading(level: 1, title)
  ..body
]

// ------------------------------------------------------------
// trademarks:商标与版权声明 / Trademark and copyright notice
// 用于文档末尾的法定声明 / Used at the end of the document for legal notice
// ------------------------------------------------------------
#let trademarks = text(size: 0.9em, style: "italic")[
  #dnd D&D, Wizards of the Coast, Forgotten Realms, Ravenloft, Eberron, the dragon ampersand, Ravnica and all other Wizards of the Coast product names, and their respective logos are trademarks of Wizards of the Coast in the USA and other countries.

This work contains material that is copyright Wizards of the Coast and/or other authors. Such material is used with permission under the Community Content Agreement for Dungeon Masters Guild.

All other original material in this work is copyright 2023 by the author and published under the Community Content Agreement for Dungeon Masters Guild.
]
