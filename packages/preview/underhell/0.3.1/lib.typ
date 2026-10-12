// ============================================================
// 地狱之下模板库 / UnderHell Template Library
// 提供架空世界风格的文档排版组件 / Fictional-world styled document components
// ============================================================

// 主题色定义 / Theme color definitions
#let darkred = rgb("#540808")   // 深红色:用于标题、强调线条 / Dark red: for headings, accent lines
#let darkyellow = rgb("#fcba03") // 暗黄色:用于二级标题下划线 / Dark yellow: for level-2 heading underline
#let 品牌 = smallcaps("地狱之下") // 品牌文本(小型大写)/ Brand text (smallcaps)

// 页脚内容生成器 / Footer content generator
// 是否为网页编译(--input web=true)/ Whether compiling for web output
#let is_web() = "web" in sys.inputs and sys.inputs.web == "true"
#let is-web-target() = is_web()

// 嵌套缩进:按标题层级把正文递归包装为逐级左缩进的块,
// 实现"N 级标题及其下内容缩进 N-1 级"(参考 TwilightBook / 论坛方案)。
// / Nested indent: wrap body by heading depth so each level's content is
// indented one more step (based on the TwilightBook approach).
#let 是标题(it) = it.func() == heading

// 嵌套缩进+参考线:按标题层级递归包装为逐级左缩进的块,
// 每层左侧绘制一条参考线(参考 TwilightBook nest-block / 论坛方案)。
// / Nested indent with a left guide line per level (recursive wrapper).
#let 嵌套参考线(body, depth: 1, inset: 2em, line-stroke: none) = {
  let 包装 = (标题, 内容) => {
    block(
      stroke: (left: line-stroke),
      inset: (left: inset),
    )[
      #标题
      #嵌套参考线(depth: depth + 1, 内容, inset: inset, line-stroke: line-stroke)
    ]
  }
  let 标题 = none
  let 章节 = ()
  for it in body.at("children", default: ()) {
    if 是标题(it) and it.at("depth") < depth {
      if 标题 != none {
        包装(标题, 章节.join())
        标题 = none
        章节 = ()
      }
      it
    } else if 是标题(it) and it.at("depth") == depth {
      if 标题 != none {
        包装(标题, 章节.join())
        标题 = none
        章节 = ()
      }
      标题 = it
    } else if 标题 != none {
      章节.push(it)
    } else {
      it
    }
  }
  if 标题 != none {
    包装(标题, 章节.join())
  }
}

// 网页模式样式表:仿标准 PDF 视觉(由 web 模式注入 <style>)
// / Web stylesheet: mirrors the standard PDF look (injected by web mode).
#let read_web_css() = read("web.css")


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
// 元素系统 / Element system
// 每个核心概念用一个"元素"(即普通元素系统的名称)作为 ID。
// 普通元素系统直接读取 ID 的值本身;其他元素系统为同一元素提供不同名词。
// 数据以 CSV(宽表)存储(如 文档/元素系统.csv):首行是各元素系统名,
// 首列是元素 id,单元格为该元素在对应系统下的名词,无名词则留空。
// 由文档通过 csv() 读取后传入 地狱之下模板(元素系统数据:) 注入。
// 当前系统缺失某元素时自动回退到普通名词(即 ID)。
// Each core concept is identified by an "元素" (the common-system name).
// The 普通 system reads the ID value directly; other systems provide
// alternative terms. Data is a wide-format CSV (e.g. 文档/元素系统.csv):
// header row = system names, first column = element ids, cells = the term
// under that system (empty if none), read by the document with csv() and
// injected via 地狱之下模板(元素系统数据:). Missing elements fall back to
// the common term (the ID) automatically.
// ------------------------------------------------------------

// 元素系统状态:当前系统名,默认普通系统 "普通";数据数组
// Element-system state: current system name (default "普通") and data array
#let 元素系统-state = state("元素系统", "普通")
#let 元素系统数据-state = state("元素系统数据", none)

// 在数据中查找 ID 在当前系统中的名词;未找到返回 none
// Look up the term for an ID in a given system within data; none if absent
// 数据为宽表:首行是表头(列名),首列是元素 id,单元格为该元素在对应系统中的名词(可为空)。
// Data is a wide table: header row = system names, first column = element ids,
// cells = that element's term under each system (may be empty).
#let _元素系统查询(id, system, data) = {
 if data == none or data.len() == 0 {
  return none
 }
 // 确定系统所在列索引 / Find the column index of the system
 let header = data.at(0)
 let col = none
 for j in range(header.len()) {
  if header.at(j) == system {
   col = j
   break
  }
 }
 if col == none {
  return none
 }
 // 将 id 规范化为字符串用于比较(content 取 .text 得字符串,字符串原样)
 // Normalize id to a string for comparison (content -> .text string, string as-is)
 let id-key = if type(id) == content { id.text } else { id }
 // 逐行查找元素 id / Scan rows for the element id
 for row in data.slice(1) {
  if row.len() > col and row.at(0) == id-key {
   let term = row.at(col)
   if term != "" {
    return term
   }
  }
 }
 none
}

// 查询某元素在当前元素系统下的名词。
// CSV 为宽表,首列是元素 id;另有"默认"列存放默认显示名(可与 id 不同,
// 留空则回退到 id)。普通系统("普通")读取"默认"列;
// 其他系统查对应列,缺失时依次回退到"默认"列、id。
// 返回的文本以深红色标出,默认使用标题字体(header),可用 font 参数覆盖。
// Query the term for an element in the current system.
// The CSV is a wide table: first column is the element id, plus a "默认"
// column holding the default display name (may differ from id; empty falls
// back to id). The 普通 system reads the "默认" column; other systems look
// up their column, falling back to "默认", then id.
#let _元素字体 = state("元素字体", none)
#let _正文字体-st = state("正文字体-state", ("LXGW WenKai Mono",))
#let _目录字体 = state("目录字体", ("SetoFont", "瀬戸フォント"))
// 评论字体 = 瘦金书(FZZhaoJiShouJinShuS)。判断 PDF 是否真正用上它,
// 以 Chrome/系统阅读器为准:它们能正确显示内嵌的该字库(CID/GB1 子集)。
// VS Code 的 pdf.js 预览会对该子集回退为本机楷体,把评论显示成与正文一致,
// 属查看器行为而非文档缺陷,勿据此判断字体未生效。
// / Comment font = Shoujin. Judge by Chrome/system viewers only; VS Code's pdf.js
// preview falls back this CID subset to a system Kaiti, so don't trust it here.
#let _评论字体 = state("评论字体", ("FZZhaoJiShouJinShuS", "方正赵佶瘦金书 简"))

// 当前语言的正文字标点映射(由 地狱之下模板 按 lang 写入);空表则不替换。
// 文档顶层用 `#show text` 读取它做渲染期替换;数字两侧与链接不受影响。
// / Current language's body-punctuation map (set per lang); read by a doc-level
// show text at render time.
#let _语言标点 = state("语言标点", (:))

#let 设定元素(id, font: none, level: none) = {
 context {
  let cur = 元素系统-state.get()
  let data = 元素系统数据-state.get()
  // 默认显示名:读"默认"列,空则回退到 id / Default name from "默认" column, fallback id
  let 默认名 = {
   let t = _元素系统查询(id, "默认", data)
   if t == none { id } else { t }
  }
  // 当前系统名词:普通系统直接用默认名;其他系统查表,缺失回退默认名
  let t = _元素系统查询(id, cur, data)
  let term = if cur == "普通" { 默认名 } else if t == none { 默认名 } else { t }
  let f = if font != none { font } else { _元素字体.get() }
  // 将 id 规范化为字符串 / Normalize id to string
  let id-str = if type(id) == content { id.text } else { id }
  if level != none {
   // 标题+锚点模式:生成带可引用标签的编号标题。
   // Typst 中 @ 引用只能指向带编号的 located 元素(如 heading),而内联文本
   // 无法承载可引用标签,故 eval 生成含静态 `<id>` 的 heading,样式由下方
   // show heading 规则统一应用。
   // / Heading+anchor mode: a numbered heading with a referenceable label.
   // In Typst @ references only target numbered, located elements (e.g.
   // heading), so we eval a heading embedding a literal `<id>` tag.
   let term-str = if type(term) == content { term.text } else { str(term) }
   // 用等号记号(=×level)构造标题,而非 #heading(level:) 显式调用:
   // set heading(offset:) 只对记号标题生效,对显式 level 的 heading 无效,
   // 故此处改用记号,使 #导入 的偏移能正确叠加到设定元素层级上。
   // / Build the heading with marker syntax (=×level) instead of an explicit
   // #heading(level:) call, because set heading(offset:) only applies to
   // marker headings — explicit-level headings ignore it. This lets the
   // offset from #导入 actually take effect on the 设定元素 level.
   let 记号 = ("=" * level)
   let src = 记号 + " " + term-str + (if id-str == "" { "" } else { " <" + id-str + ">" })
   eval(src, mode: "markup")
  } else {
   // 普通模式:渲染内联文本(不换行)。labels 由调用方在想被引用处显式添加。
   // / Normal mode: render inline text (no line break).
   if is_web() {
    html.elem("span", attrs: (class: "uh-element",))[#term]
   } else if f != none {
    box[
     #text(fill: darkred, font: f)[#term]
    ]
   } else {
    box[
     #text(fill: darkred)[#term]
    ]
   }
  }
 }
}

#let 元素(id, font: none) = {
 context {
  let cur = 元素系统-state.get()
  let data = 元素系统数据-state.get()
  // 默认显示名:读"默认"列,空则回退到 id / Default name from "默认" column, fallback id
  let 默认名 = {
   let t = _元素系统查询(id, "默认", data)
   if t == none { id } else { t }
  }
  // 当前系统名词:普通系统直接用默认名;其他系统查表,缺失回退默认名
  let t = _元素系统查询(id, cur, data)
  let term = if cur == "普通" { 默认名 } else if t == none { 默认名 } else { t }
  let f = if font != none { font } else { _元素字体.get() }
  // 将 id 规范化为字符串 / Normalize id to string
  let id-str = if type(id) == content { id.text } else { id }
  // 检测该概念是否有已定义标签:有则链接指向其定义处;
  // 无定义时:HTML 编译(传 --input html=true 且用 --features html)用
  // <span title="未定义"> 的悬停弹窗提示;PDF 则照常渲染深红词,不做处理。
  // / Check whether a label for this concept exists: link to it if so.
  // Otherwise: on HTML output (--input html=true with --features html) show
  // a hover popup via <span title="未定义">; on PDF just render the term.
  let 已定义 = query(label(id-str)).len() > 0
  let is-html = "html" in sys.inputs and sys.inputs.html == "true"
  if 已定义 and is_web() {
   // 网页模式:链接 + 深红/楷体样式 class(与 PDF 视觉一致)
   link(label(id-str), html.elem("span", attrs: (class: "uh-element",))[#term])
  } else if 已定义 {
   if f != none {
    link(label(id-str))[
     #set text(fill: darkred, font: f)
     #term
    ]
   } else {
    link(label(id-str))[
     #set text(fill: darkred)
     #term
    ]
   }
  } else if is-html or is_web() {
   // 未定义网页分支:class 应用特殊格式样式,title 提供悬停"未定义"提示
   html.elem("span", attrs: (class: "uh-element", title: "未定义",))[#term]
  } else {
   // PDF 下未定义概念照常渲染词;附一个未附着 label 以触发编译期 warning,
   // 提示该概念尚无定义小节(HTML 分支用弹窗提示,不在此报 warning)。
   // / Render the term normally on PDF; attach an unattached label to raise
   // a compile-time warning that the concept has no definition (the HTML
   // branch uses a tooltip instead and does not warn here).
   if f != none {
    box[
     #label(id-str)
     #set text(fill: darkred, font: f)
     #term
    ]
   } else {
    box[
     #label(id-str)
     #set text(fill: darkred)
     #term
    ]
   }
  }
 }
}

// 评论:默认以删除线显示,字体与标题相同(header);
// 编译时传 `--input 隐藏评论=true` 可整体隐藏。
// / Comment: shown struck-through by default, in the header font;
// pass `--input 隐藏评论=true` at compile time to hide it entirely.
#let 评论(body) = {
 if "隐藏评论" in sys.inputs and sys.inputs.隐藏评论 == "true" {
  []
 } else if is_web() {
  // 网页:仿 wikidot "行评论浮泡" — 正文一个带角标的小触发点,
  // 悬停/聚焦时在旁边弹出浮泡面板显示评论内容。
  // / Web: mimics a wikidot "line-comment bubble" — a small inline
  // trigger; hovering/focusing reveals a floating panel with the comment.
  html.elem("span", attrs: (class: "uh-comment",))[
   #html.elem("span", attrs: (class: "uh-comment-trigger", tabindex: "0",))[💬]
   #html.elem("span", attrs: (class: "uh-comment-panel",))[#body]
  ]
 } else {
  context {
   let f = _评论字体.get()
   if f != none {
    text(fill: gray, font: f)[#body]
   } else {
    text(fill: gray)[#body]
   }
  }
 }
}

// 设置当前元素系统 / Set the current element system
#let 设置元素系统(name) = 元素系统-state.update(name)

// 待办:以标题字体、醒目橙色标注待办事项;编译时传 `--input 隐藏TODO=true`
// 可整体隐藏。每次使用会登记一页(位置)与该 TODO 内容,
// 供 `#TODO表格` 汇总成「ID / 位置 / TODO」清单。
// / TODO: mark pending items in the header font, highlighted orange;
// pass `--input 隐藏TODO=true` at compile time to hide them entirely.
// Each use records its location and content for `#TODO表格`.
#let TODO(body) = {
 if "隐藏TODO" in sys.inputs and sys.inputs.隐藏TODO == "true" {
  []
 } else {
  context {
   // 登记用一个可定位的 metadata 元素:query 可靠、不依赖 state
   // (网页导出里 state 连续 update 的可见性不可靠)。
   let n = query(selector(metadata).before(here())).filter(m => m.value.键 == "uh-todo").len() + 1
   let 锚 = "todo-" + str(n)
   let f = _评论字体.get()
   let styled = if f != none {
    text(fill: orange, font: f)[#body]
   } else {
    text(fill: orange)[#body]
   }
   let 登记 = metadata((键: "uh-todo", 序号: n, 内容: body, 页面: here().page()))
   // metadata 需进入文档流才可被 query 定位(不可见)
   if is_web() {
    [
     #登记
     #html.elem("span", attrs: (class: "uh-todo", id: 锚,))[
      #styled#label(锚)
     ]
    ]
   } else {
    [#登记#styled#label(锚)]
   }
  }
 }
}

// TODO表格:直接收集正文里全部 #TODO(登记 metadata),渲染
// 编号/位置/内容 三列表格;位置列为跳转到该 TODO 正文的链接。
// / TODO table: collects every #TODO registered in the body (a locatable
// metadata element per call) and renders an ID/location/content table;
// the location column links back to the TODO's position.
#let TODO表格() = {
 context {
  let items = query(metadata).filter(m => m.value.键 == "uh-todo")
  if items.len() == 0 {
   [当前无 #TODO。]
  } else {
   table(
    columns: (auto, auto, 1fr),
    table.header([编号], [位置], [TODO 内容]),
    ..items.enumerate().map(kv => {
     let (k, it) = kv
     let n = it.value.序号
     let 锚 = "todo-" + str(n)
     let 位置 = if is_web() {
      html.elem("a", attrs: (href: "#" + 锚,))[跳转 ↗]
     } else {
      link(label(锚))[
       #text(font: _正文字体-st.get(), size: 0.85em)[第 #(it.value.页面) 页]
      ]
     }
     ([#n], [#位置], [#text(font: _评论字体.get())[#it.value.内容]])
    }).flatten(),
   )
  }
 }
}

// 设置元素系统数据// 设置元素系统数据// 设置元素系统数据// 设置元素系统数据// 设置元素系统数据(CSV 读取结果)/ Set element-system data (csv() result)
#let set-元素系统数据(data) = 元素系统数据-state.update(data)

// ------------------------------------------------------------
// 元素总表:以表格展示所有元素在各元素系统下的名称
// Element-system table: show every element's term under each system
//  data  - 可选,元素系统数据(宽表 CSV);缺省从模板状态读取
//      Optional element-system data (wide CSV); defaults to template state
//  用法 / Usage:
//   #元素总表()   # 使用模板注入的数据 / use injected data
// ------------------------------------------------------------
#let 元素总表(data: none) = {
 context {
  let d = if data == none { 元素系统数据-state.get() } else { data }
  if d == none or d.len() == 0 {
   return none
  }
  let header = d.at(0)
  // 首列是元素 id,其后各列是元素系统 / First column is id, rest are systems
  let systems = header.slice(1)
  // 数据行数组:每个元素一行;系统列取该列名词,空则显示 — / Data array
  let rows = ()
  // 表头行(浅灰底加粗)/ Header row
  rows.push(table.header([*元素*], ..systems.map(s => text(weight: "bold", s))))
  for r in d.slice(1) {
   if r.len() > 0 {
    // 元素名列:有定义的元素渲染为指向其定义标题的链接
    // / Element name cell: link to its definition if it exists
    let id = r.at(0)
    let id-str = if type(id) == content { id.text } else { id }
    if query(label(id-str)).len() > 0 {
     rows.push(link(label(id-str))[#text(fill: darkred)[#id]])
    } else {
     rows.push(id)
    }
    for j in range(1, r.len()) {
     let cell = r.at(j)
     rows.push(if cell == "" or cell == none { text(fill: rgb("#888888"))[—] } else { cell })
    }
   }
  }
  table(
   columns: (1fr,) + systems.map(_ => 1fr),
   stroke: (x: 0.5pt + rgb("#bbbbbb"), y: 0.5pt + rgb("#bbbbbb")),
   inset: 8pt,
   align: center,
   ..rows,
  )
 }
}

// ------------------------------------------------------------
// 地狱之下模板:文档主模板 / Main document template
// 用作 #show: 地狱之下模板.with(...) 应用整篇文档样式
// Used via #show: 地狱之下模板.with(...) to apply document-wide styling
//
// 参数 / Parameters:
//  title    - 文档标题(封面大标题)/ Document title (cover headline)
//  author    - 作者 / Author
//  subtitle   - 副标题 / Subtitle
//  cover    - 封面背景图 / Cover background image
//  font-size  - 正文字号(默认 12pt)/ Body font size (default 12pt)
//  paper    - 纸张尺寸(默认 a4)/ Paper size (default a4)
//  logo     - 右下角 logo 图 / Logo image at bottom-right
//  fancy-author - 是否使用花式作者展示(带火焰图案)/ Fancy author display with fire splash
//  add-title  - 封面是否显示标题 / Whether to show title on cover
//  bg      - 正文背景,"default" 使用默认背景,或传入自定义图 / Body background
//  lang     - 语言代码(如 "en"/"zh"/"it"),决定加载哪个 languages/*.toml
//         Language code, determines which languages/*.toml to load
//  print    - 打印模式:去除背景图/封面图、双栏、宽边距、纯黑文字、简化页脚
//         默认自动读取编译时输入变量 --input print=true;
//         文档也可显式传入 print: true/false 覆盖
//         Print mode: no background/cover images, two columns, wider margins,
//         pure black text, simplified footer (for ink-saving physical print).
//         Defaults to reading --input print=true at compile time;
//         documents can override with print: true/false
//  screen    - 小屏模式:A5 单栏、保留背景与彩色装饰、窄边距、较小字号
//         适合手机/平板等窄屏设备阅读
//         默认自动读取编译时输入变量 --input screen=true;
//         Screen mode: A5 single column, keeps background & colors, narrow margins,
//         smaller font size. For reading on phones/tablets.
//         Defaults to reading --input screen=true at compile time
//  元素系统    - 元素系统名称,决定 #元素(...) 的取词来源
//         默认自动读取编译时输入变量 --input 元素系统=xxx,缺省为 "普通"
//         文档也可显式传入 元素系统: "xxx" 覆盖
//         Element system name; selects which system #元素(...) draws from.
//         Defaults to reading --input 元素系统=xxx at compile time,
//         falling back to "普通". Documents can override with 元素系统: "xxx"
//  元素系统数据  - 元素系统数据文件位置,由文档在初始化时传入 csv() 读取结果。
//         所有元素系统集中在同一个 CSV(列: id, system, term);
//         如 csv("元素系统.csv")。缺省不注入。
//         Element-system data file location: pass the csv() result here,
//         all systems live in one CSV (columns: id, system, term),
//         e.g. csv("元素系统.csv"). Not injected by default.
// ------------------------------------------------------------
#let 地狱之下模板(title: "",
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
       web: "web" in sys.inputs and sys.inputs.web == "true",
       元素系统: if "元素系统" in sys.inputs and sys.inputs.元素系统 != "" { sys.inputs.元素系统 } else { "普通" },
       元素系统数据: none,
 body) = {
 // 设置文档元数据 / Set document metadata
 set document(author: author, title: title)
 // 段落间距(无首行缩进)/ Paragraph spacing (no first-line indent)
 set par(spacing: 0.7em, first-line-indent: (amount: 0em, all: false))
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
 // 元素使用标题字体(毛笔小楷)呈现,与正文等宽格线不复用。
 // Elements use the header font (段宁毛笔小楷) — no longer locked to the body grid.
 _元素字体.update(if header-fonts != none { header-fonts } else { none })
 // 评论字体(从 toml)/ Comment fonts from toml
 let comment-fonts = if "comment" in fonts-cfg { fonts-cfg.comment } else { none }
 _评论字体.update(comment-fonts)
 // 位置列等小代码用正文字体表 / Minor mono text uses body font list
 _正文字体-st.update(body-fonts)
 // 目录字体(从 toml)/ Outline fonts from toml
 let outline-fonts = if "outline" in fonts-cfg { fonts-cfg.outline } else { none }
 _目录字体.update(outline-fonts)
 // 斜体字体列表(支持回退)/ Italic font list (with fallback)
 let italic-fonts = if "italic" in fonts-cfg { fonts-cfg.italic } else { none }

// 非 en 时更新语言状态 / Update language state when not English
 if lang != "en" {
  language.update(lang-toml)
 }

 // 写入当前语言的正文字标点映射,供顶层 show text 渲染按语言替换
 _语言标点.update(if "标点" in lang-toml { lang-toml.at("标点") } else { (:) })

 // 设置当前元素系统 / Set the current element system
 元素系统-state.update(元素系统)
 // 注入元素系统数据(若有)/ Inject element-system data if provided
 if 元素系统数据 != none {
  元素系统数据-state.update(元素系统数据)
 }

 // 标题始终使用深红(打印/普通/小屏均保持红色) / Headings always darkred
 let heading-fill = darkred

 // 一级标题样式:小型大写、深红(打印模式也为深红)/ Level-1 heading: smallcaps, always darkred
 show heading.where(level: 1): it => block(text(
  ..header-font-args,
  size: 1.5em,
  fill: darkred,
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

 // 三级标题样式:深红色、小一号、无下划线 / Level-3 heading: darkred, slightly smaller
 show heading.where(level: 3): it => block(text(
  ..header-font-args,
  size: 1.3em,
  fill: heading-fill,
  weight: "regular",
 )[#smallcaps(it)])

 // 四级标题样式:左色条 + 深红色 / Level-4 heading: left bar accent
 show heading.where(level: 4): it => block[
  #box(
   inset: (left: 8pt),
   stroke: (left: if print { 0pt } else { 3pt + darkyellow }),
   width: 100%,
  )[#text(..header-font-args, size: 1.15em, fill: heading-fill, weight: "regular")[#it]]
 ]

 // 五级标题样式:左侧圆点(垂直居中)+ 深红(正则体)/ Level-5 heading: left dot (vertically centered) + darkred
 show heading.where(level: 5): it => block[
  #grid(
   columns: (auto, 1fr),
   column-gutter: 0.6em,
   align: (center, left),
   [#box(circle(radius: 1.5pt, fill: heading-fill))],
   text(..header-font-args, size: 1em, fill: heading-fill, weight: "regular")[#it],
  )
 ]

 // 六级标题样式:深红、小号、前置 — 符号 / Level-6 heading: darkred, small, "—" prefix
 show heading.where(level: 6): it => block[
  #text(..header-font-args, size: 0.95em, fill: heading-fill, weight: "regular")[
   — #it
  ]
 ]

 // 正文背景图:打印模式禁用;小屏/普通模式保留 / Body background
 let bg-img = if print or bg == none {
  none
 } else if bg == "default" {
  image("img/background.jpg", width: 110%)
 } else {
  bg
 }

 // 小屏模式字号在下方 text-args 中统一设置 / Screen font size set in text-args below
 // 小屏模式使用适中字号(A5 页面)/ Screen mode uses moderate font size for A5

 // 根据模式构造页面参数(必须在 if 块外 set,否则词法作用域不延伸)
 // Build page args based on mode (must set outside if block due to lexical scoping)
 let page-args = if web {
  // 网页模式:单栏、无页码、无页面背景(视觉样式由注入的 CSS 提供)
  // Web mode: single column, no page number, no page background (styles via CSS)
  (
   flipped: false,
   margin: (top: 0pt, bottom: 0pt, left: 0pt, right: 0pt),
   numbering: none,
   columns: 1,
   background: none,
   footer: none,
  )
 } else if print {
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
   footer: context {
    let f = footer.get()
    footer.update(footer-content)
    f
   },
  )
 }
 // 小屏模式使用 A5 纸张 / Screen mode uses A5 paper
 let actual-paper = if screen { "a5" } else { paper }
 set page(actual-paper, ..page-args)

 // 副标题非空时追加换行,便于排版 / Append newline to subtitle if non-empty
 if subtitle.len() > 0 {
  subtitle = subtitle + "
"
 }

 // 封面页 / Front page
 if web {
  // 网页模式:不渲染整页封面,仅一个标题块(样式仿 PDF 封面)
  // Web mode: no full-page cover, just a heading block styled like the PDF cover
  html.elem("header", attrs: (class: "uh-cover",))[
   // 右上角固定导航:PDF 下载(GitHub 最新 release)+ 仓库链接
   #html.elem("nav", attrs: (class: "uh-site",))[
    #html.elem("a", attrs: (class: "uh-site-link", href: "https://github.com/kych-net/UnderHell/releases/latest", title: "下载 PDF(GitHub 最新发行版)", target: "_blank",))[PDF]
    #html.elem("a", attrs: (class: "uh-site-link", href: "https://github.com/kych-net/UnderHell", title: "GitHub 仓库", target: "_blank",))[GitHub]
    #html.elem("a", attrs: (class: "uh-site-link", href: "https://gitcode.com/CrossDark/UnderHell", title: "GitCode 仓库", target: "_blank",))[GitCode]
   ]
   #if add-title {
    html.elem("h1", attrs: (class: "uh-title",))[#upper(title)]
   }
   #if subtitle.len() > 0 {
    html.elem("p", attrs: (class: "uh-subtitle",))[#subtitle #if not fancy-author {"by " + author}]
   }
  ]
 } else if print {
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
 // 注意:set/show 不能放在 if 块内(词法作用域不延伸到块外),改用参数字典构造后一次性 set
 // Note: set/show inside an if block is lexically scoped and won't leak out; build args first
 // 小屏模式使用适中字号 / Screen mode uses moderate font size
 let actual-font-size = if screen { 13pt } else { font-size }
 let text-args = (size: actual-font-size, lang: lang, fill: black)
 if body-fonts != none {
  text-args.font = body-fonts
 }
 set text(..text-args)

// 斜体使用独立字体(如等距更紗黑體),优先级低于用户自定义
 // Italic text uses its own font (e.g. Sarasa Mono SC); user rules take precedence.
 // 注意:仅设置 font,不显式设 style——emph 自带 italic,显式 style 会干扰字体选变体
 // Note: set only font, not style; emph already carries italic, an explicit style
 // would break font-variant selection (e.g. pick Regular instead of Italic).
 let italic-args = if italic-fonts != none {
  (font: italic-fonts)
 } else {
  (:)
 }
 show emph: set text(..italic-args)

 // 网页模式:注入仿 PDF 的样式表(单栏、羊皮纸底色、深红标题、楷体正文),
 // 并按标题层级递归缩进内容(N 级标题及其下内容缩进 N-1 级)。
 // Web mode: inject PDF-like stylesheet and nest content by heading level.
 if web {
  html.elem("style", "/*UH_WEB_CSS*/")

  // 修 typst html 导出 align() 内容丢失:重建其正文
  show align: it => it.body

  // 按标题层级缩进(论坛方案思想;HTML 导出不映射 block inset,
  // 故用 html.elem 的 div+style 实现缩进):每级 2 个空格宽(半角空格
  // 实测 ≈2pt@12pt,即每级 4pt):N 级标题缩 (N-1) 级,其下内容缩 N 级。
  // / Indent by heading level: 2 space characters per level (≈4pt at 12pt).
  show heading: it => context {
    let 层 = it.level
    // 用所在计数深度作为最终层级:offset 会把标题抬到原始层级之上,
    // 单看 it.level 会漏掉被抬到五级以上的情况——统一用 max 覆盖。
    // / Use the counter depth as the final level: offset can push a title above
    // its declared level, so it.level alone misses pushed-deep ones.
    let 深 = counter(heading).at(here()).len()
    let 放 = calc.max(层, calc.max(深, 0))
    let 编号 = if it.numbering != none { numbering(it.numbering, ..counter(heading).at(here())) } else { "" }
    if 放 >= 5 {
      // 手动重建头内容,绕开 Typst 导出对高层的错层/丢内容;编号自算,
      // 样式交给 web.css(.lv-N)。六级加前缀破折号。x 级标题直接输出 <hx>。
      // / Rebuild the heading ourselves to dodge export issues on high levels;
      // emit a real <hN> for the true final level, no clamping. Styles live in web.css.
      let 标 = 放
      let 前缀 = if 放 == 6 { "— " } else { "" }
      html.elem("h" + str(标), attrs: (class: "lv-" + str(标),))[
       #text(..header-font-args, size: (if 标 == 5 { 1em } else if 标 == 6 { 0.95em } else { 0.9em }), fill: heading-fill, weight: "regular")[#前缀#编号 #it.body]
      ]
    } else {
      html.elem("div", attrs: (style: "margin-left: " + str(4 * (放 - 1)) + "pt",))[#it]
    }
  }
  show selector.or(par, enum, list, table): it => context {
    let h = query(selector(heading).before(here())).at(-1, default: none)
    if h == none {
      it
    } else {
      html.elem("div", attrs: (style: "margin-left: " + str(4 * h.level) + "pt",))[#it]
    }
  }

  body
  // 页面底部:ICP 备案号(链接到工信部备案系统)
  html.elem("footer", attrs: (class: "uh-icp",))[
   #html.elem("a", attrs: (href: "https://beian.miit.gov.cn/", target: "_blank",))[
    京ICP备2026033372号-1
   ]
  ]
 } else {
  // 双栏 PDF(普通/打印):按标题层级缩进(每级 2 个空格宽,≈4pt),
  // 不添加参考线(论坛方案:标题与段落/列表/表格分别包 block inset)。
  // / Two-column PDFs: indent by heading level (2 spaces ≈ 4pt per level),
  // without guide lines (forum approach: wrap heading & par/enum/table).
  show heading: it => {
    block(inset: (left: 4pt * (it.level - 1)), it)
  }
  // 非段落块(列表/枚举/表格)保持原缩进逻辑 / Non-paragraph blocks keep original indent
  show selector.or(par, enum, list, table): it => context {
    let h = query(selector(heading).before(here())).at(-1, default: none)
    if h == none {
      it
    } else {
      block(inset: (left: 4pt * h.level), it)
    }
  }

  body
 }

}

// ------------------------------------------------------------
// 网格:把内容按等宽中文字体的格子对齐——每个格子宽高各 1em,
// 一个汉字占 1 格,两个拉丁字母/数字占 1 格(需 LXGW WenKai Mono 等宽字体)。
// 行距取 0 使每行恰好 1 格高(该字体上行+下行=1em)。显示网格:true 时叠加浅灰格线。
// / Grid: align content to 1em cells — a CJK char fills one cell, two Latin
// letters/digits fill one cell (needs a mono CJK font like LXGW WenKai Mono).
// Zero leading makes each line exactly one cell tall. Draw faint lines when true.
//  内容     - 传入的正文内容 / Content to lay out
//  显示网格  - true 时绘制格线 / Draw grid lines when true
//  格线      - 格线粗细(显示网格 时为真时生效)/ Grid-line weight
// ------------------------------------------------------------
#let 网格(内容, 显示网格: false, 格线: 0.4pt) = context {
  let em = measure(text[地]).width
  layout(size => {
    // 可容纳的格子列数:向下取整,让整段占满整数格宽 / Cell columns, floored
    let 列数 = calc.max(1, calc.floor(size.width / em))
    let 行长 = 列数 * em
    // 内容体:定宽为整数格宽;行距 0 → 每行恰好 1 格高
    // Content block of whole-cell width; zero leading → one row per cell
    let 内容体 = block(width: 行长)[
      #set par(leading: 0em)
      // 半角空格只有 0.5em,会断格;强制每个空格占满 1 格保持整格对齐
      // A half-width space is 0.5em and breaks the cell; force it to fill 1em
      #show regex(" "): box(width: 1em)
      #内容
    ]
    let 高度 = measure(内容体).height
    let 行数 = calc.max(1, calc.round(高度 / em))
    // 格线表:叠加在内容下方(仅显示网格 时为真时渲染)/ Grid overlay behind content
    let 线 = if 显示网格 {
      place(
        top + left,
        table(
          columns: (em,) * 列数,
          rows: (em,) * 行数,
          inset: 0pt,
          stroke: (x: 格线 + gray, y: 格线 + gray),
          ..range(列数 * 行数).map(_ => []),
        ),
      )
    } else { none }
    block(width: 行长)[
      #线
      #内容体
    ]
  })
}

// ------------------------------------------------------------
// uhtab:生成地狱之下风格的表格区块 / UnderHell style table block
//  name   - 表格标题 / Table title
//  columns - 列宽配置(默认 (1fr, 4fr))/ Column widths
//  breakable - 是否允许跨页 / Whether the block can break across pages
//  contents - 表格内容(按行展开)/ Table contents (spread as rows)
// ------------------------------------------------------------
#let 表格(name, columns: (1fr, 4fr), breakable: true, ..contents) = [
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
 // 行和列同时斑马纹:相邻行、相邻列颜色交错 / Zebra striping on both rows & columns
 // 奇偶(row+col)决定底色,使水平与垂直相邻单元格均不同色
 fill: (col, row) => if calc.even(row+col) { rgb("#aaaaaa00") } else { rgb("#aaffaa33") },
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
#let 顶部图(figure) = [ #place(top + center, dy: -7em, dx:0em, float: true, scope: "parent", clearance: -6em, figure) ]
// bottomfig:在父块底部浮动放置图片 / Float figure at bottom of parent block
// 先清除页脚以避免重叠 / Suppress footer first to avoid overlap
#let 底部图(figure) = [ // Suppress the footer first
 #context footer.update("")
 #place(bottom + center, dy: 7em, dx:0em, float: true, scope: "parent", clearance: -6em, figure)
]


// ------------------------------------------------------------
// breakoutbox:信息框(顶部+底部边框)/ Callout box
//  title  - 标题(可空)/ Title (can be empty)
//  contents - 框内内容 / Box contents
//  breakable - 是否允许跨页,默认开启 / Whether the block can break across pages
// ------------------------------------------------------------
#let 提示框(title, contents, breakable: true) = {
 if "web" in sys.inputs and sys.inputs.web == "true" {
  return html.elem("div", attrs: (class: "uh-tipbox",))[
   #if title != none { html.elem("div", attrs: (class: "uh-tipbox-title",))[#title] }
   #contents
  ]
 }
 block(
 breakable: breakable,
 inset: 10pt,
 width: 100%,
 stroke: (top: 2pt, bottom: 2pt),
 fill: rgb("#ddeedd"),
)[
 #set par(first-line-indent: 0em, spacing: 0.6em)
 #if title != none {
  align(left, smallcaps[*#title*])
 }

 #align(left)[#contents]
]
 }

// ------------------------------------------------------------
// 属性值换算工具 / Ability modifier utilities
// ------------------------------------------------------------

// bonus:根据属性值计算修正值字符串 / Compute modifier string from ability score
// 规则:(score - 10) / 2 向下取整,>=10 为正 / Rule: floor((score-10)/2), "+" if >= 10
#let 修正值(i) = {
 let b = ""
 if i >= 10 {
  b = "+"
 }
 b + str(calc.floor((i - 10)/2))
}

// stat-to-str:格式化为 "值 (修正)" / Format as "score (modifier)"
#let 属性转串(a) = {
 (str(a) + " (" + 修正值(int(a)) + ")")
}

// ------------------------------------------------------------
// stats-table:六维属性表(STR/DEX/CON/INT/WIS/CHA)/ Six-ability stats table
//  stats - 字典,键为属性名,值为数值 / Dict of ability name -> score
//  color - 属性名的强调色,默认深红 / Accent color for ability names
// ------------------------------------------------------------
#let 属性表(stats, color: darkred) = {
 let content = ()
 // 第一行:属性名(强调色、加粗)/ First row: ability names (accent, bold)
 for k in stats.keys() {
  content.push([#text(fill: color, weight: 700, k)])
 }
 // 第二行:数值(修正)/ Second row: score (modifier)
 for k in stats.values() {
  content.push([#text(fill: black, 属性转串(k))])
 }
 // 6 列等宽,无描边,居中对齐 / 6 equal columns, no stroke, centered
 table(stroke: none, columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr), inset: 0pt, row-gutter: 5pt, align: center, ..content)
}

// ------------------------------------------------------------
// boxed-text:带黄色侧边的文本框 / Text box with yellow side strokes
//  header  - 标题文本(三级标题)/ Title (level-3 heading)
//  contents - 框内正文 / Box body content
//  breakable - 是否允许跨页,默认开启 / Whether the block can break across pages
// ------------------------------------------------------------
#let 侧标框(header, contents, breakable: true) = block(
 breakable: breakable,
 inset: 10pt,
 fill: rgb("#fefff9"),
 stroke: (right: 1pt + darkyellow, left: 1pt + darkyellow),
 width: 100%,
)[
 #set par(spacing: .6em, first-line-indent: 1.5em)
 #set text(size: 0.83em)
 #heading(outlined: false, level: 3, header)
 #v(0.5em)
 #contents
]

// ------------------------------------------------------------
// statbox:怪物/生物属性框 / Monster/creature stat block
//  stats - 字典,包含 name/description/ac/hp/speed/stats/skillblock/traits
//      以及可选的 actions/reactions/limited_usage/equip/legendary_act
//  theme - 可选主题字典,定制配色:title(标题栏底色,可渐变)/accent(强调色)/
//      soft(浅底色)/border(边框色);缺省为经典深红风格
//  breakable - 是否允许跨页,默认开启 / Whether the block can break across pages
//      Dict with creature info and optional action sections
// ------------------------------------------------------------
#let 属性框(stats, theme: (:), breakable: true) = {
 // 主题解析:缺省为经典深红/白底 / Resolve theme, default classic darkred
 let 标题色 = theme.at("title", default: darkred)
 let 强调色 = theme.at("accent", default: darkred)
 let 浅底色 = theme.at("soft", default: white)
 let 边框色 = theme.at("border", default: darkred)

 // 标题栏文字色:默认白色,可经 theme.title-fg 覆盖 / Title text color, default white
 let 标题文字色 = theme.at("title-fg", default: white)

 block(breakable: breakable, inset: 0pt, fill: 浅底色, stroke: 1pt + 边框色, width: 100%)[
  // 标题栏横幅 / Title banner
  box(
   width: 100%,
   inset: (x: 12pt, y: 7pt),
   fill: if type(标题色) == color { 标题色 } else { gradient.linear(..标题色) },
  )[
   #set text(fill: 标题文字色)
   #heading(outlined: false, level: 3, stats.name)
  ]

  #pad(x: 12pt, y: 8pt)[
   #set par(spacing: .6em)
   #set text(size: 0.83em)

   // 描述(斜体)/ Description (italic)
   _ #stats.description _

   #line(stroke: 1.5pt + 强调色, length: 100%)
   // AC/HP/Speed 标签使用当前语言配置 / AC/HP/Speed labels from current language
   #context [
    #text(fill: 强调色)[*#language.get().stats.ac*] #stats.ac 
    #text(fill: 强调色)[*#language.get().stats.hp*] #stats.hp 
    #text(fill: 强调色)[*#language.get().stats.speed*] #stats.speed 
   ]

   #line(stroke: 1.5pt + 强调色, length: 100%)
   // 六维属性表 / Six-ability stats table
   #属性表(stats.stats, color: 强调色)
   #line(stroke: 1.5pt + 强调色, length: 100%)

   // 技能块(感知、语言、挑战等级等)/ Skill block (senses, languages, challenge, etc.)
   #for skill in stats.skillblock {
    [#text(fill: 强调色)[*#skill.at(0)*] #skill.at(1) ]
   }
   #line(stroke: 1.5pt + 强调色, length: 100%)
   // 特性 / Traits (表格形式)
   #if stats.traits.len() > 0 {
    table(
     stroke: none,
     columns: (1fr, 4fr),
     inset: (x: 8pt, y: 4pt),
     align: (left, left),
     ..stats.traits.map(trait => (
      [#text(fill: 强调色, weight: 700)[#trait.at(0)]],
      trait.at(1),
     )).flatten(),
    )
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
       #text(size: 1.3em, fill: 强调色)[#box(width:100%, inset: (bottom: 3pt), stroke: (bottom: 1pt+darkyellow))[#smallcaps(section)]]
       #for action in stats.at(section) {
        [_*#text(fill: 强调色)[#action.at(0)].*_ #action.at(1)  ]
       }
      ]
     }
    }
   }
  ]
 ]
}

// ------------------------------------------------------------
// npcbox:NPC 信息框 / NPC info block
//  npc - 字典,包含 name/race/class/alignment/stats(可选)
//     以及 description/background/roleplay(可选,标签使用语言配置)
//     Dict with NPC info; description/background/roleplay use localized labels
//  breakable - 是否允许跨页,默认开启 / Whether the block can break across pages
// ------------------------------------------------------------
#let 人物框(npc, breakable: true) = block(
 breakable: breakable,
 inset: 12pt,
 fill: white,
 stroke: 1pt,
 width: 100%,
)[
 #set par(spacing: .6em)
 #set text(size: 0.83em)
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
   属性表(npc.stats)
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
      #text(fill: darkred, weight: 700)[#smallcaps(label)] 
      #npc.at(key)
     ]
    }
   }
  }
]

// ------------------------------------------------------------
// spell:法术条目 / Spell entry
//  spl - 字典,包含 name/spell-type/properties(属性列表)/description
//     Dict with name, spell-type, properties (list), description
// ------------------------------------------------------------
#let 法术(spl) = [
 #set par(spacing: .6em, first-line-indent: 0em)
 #heading(outlined: false, level: 3, spl.name)

 // 法术类型(斜体)/ Spell type (italic)
 _#spl.spell-type _
 #v(0.5em)
 // 属性列表(施法时间、范围、持续时间、成分等)/ Property list
 #for prop in spl.properties {

    [*#prop.at(0):* #prop.at(1)  ]


   }
 #v(0.5em)

 #spl.description

]

// ------------------------------------------------------------
// appendix:附录功能 / Appendix helper
//  title     - 附录总标题(默认 "附录")/ Appendix master title
//  numbering-fmt - 附录标题编号格式(默认 "A.1.",即附录 A 及其子标题 A.1, A.1.1)/
//          Appendix heading numbering format
//  body     - 附录正文内容 / Appendix body content
//
// 用法 / Usage:
//  #appendix[
//   = 附录子标题
//   内容...
//  ]
// 也可通过 include 引入附录文件 / Or include an appendix file:
//  #appendix[#include "附录文件.typ"]
// ------------------------------------------------------------
#let 附录(title: "附录", numbering-fmt: "A.1.", body) = [
 // 切换标题编号为字母格式(附录 A, A.1, A.1.1 ...)/
 // Switch heading numbering to letter format
 #set heading(numbering: numbering-fmt)
 // 重置标题计数器,使附录从 A 开始 / Reset heading counter so appendix starts at A
 #counter(heading).update(0)
 // 附录分区名:不作为标题,不占用编号;附录正文从一级标题开始
 // Appendix part label: not a heading, does not consume a number; body starts at level-1 headings
 #align(left)[#text(size: 3em, weight: "bold", fill: darkred, font: "Comic Sans MS")[#title]]
 #v(0.6em)
 #body
]

// ------------------------------------------------------------
// trademarks:版权声明 / Copyright notice
// 用于文档末尾的版权声明 / Used at the end of the document for copyright notice
// ------------------------------------------------------------
#let 版权声明 = text(size: 0.9em, style: "italic")[
 #品牌 及其相关标识均为本项目原创内容。本作品中的所有设定、角色、地名及世界观均为虚构,如有雷同纯属巧合。

All original material in this work is copyright by the respective authors and published under the MIT License.
]

// ------------------------------------------------------------
// 世界纲要:单栏居中页 / World Overview: single-column centered page
//  display - 是否显示:显式传入 true/false 可覆盖;
//      缺省时:打印模式(print)隐藏,其余模式(普通/小屏)显示;
//      亦可用编译时输入 --input 纲要=true/false 覆盖
//      Default: hidden in print mode, shown otherwise; override with display
// ------------------------------------------------------------
#let 世界纲要(body, display: none) = {
 let show-p = if display != none {
  display
 } else if "web" in sys.inputs and sys.inputs.web == "true" {
  // 网页构建:纲要默认隐藏(正文即纲);"--input 纲要=true" 可显式显示
  "纲要" in sys.inputs and sys.inputs.纲要 == "true"
 } else if "纲要" in sys.inputs {
  sys.inputs.纲要 == "true"
 } else if "print" in sys.inputs {
  sys.inputs.print != "true"
 } else {
  true
 }
 if show-p {
  if "web" in sys.inputs and sys.inputs.web == "true" {
   // 网页:直接输出正文(无页面包装)
   body
  } else {
  page(columns: 1, margin: (left: 30mm, right: 30mm, top: 30mm, bottom: 30mm))[
   #set text(size: 1.1em)
   #show heading: set align(center)
   #show par: set align(center)
   #body
  ]
  }
 }
}

// ------------------------------------------------------------
// 目录:单栏居中页 / Table of contents: single-column centered page
// ------------------------------------------------------------
#let 目录() = {
 if "web" in sys.inputs and sys.inputs.web == "true" {
  // 网页:浮动目录 — 宽屏固定左侧,窄屏吸顶(CSS 控制)
  html.elem("aside", attrs: (class: "uh-toc",))[
   #html.elem("button", attrs: (class: "uh-toc-head", "aria-expanded": "false"))[目录]
   #html.elem("div", attrs: (class: "uh-toc-body",))[
    #outline()
   ]
  ]
 } else {
  context {
   let f = _目录字体.get()
   page(columns: 1, margin: (left: 30mm, right: 30mm, top: 30mm, bottom: 30mm))[
    #text(font: f)[
     #align(center)[
      #text(fill: darkred, weight: "bold", size: 1.6em)[目录]
     ]
     #outline(title: none)
    ]
   ]
  }
 }
}

// 导入:用 #include 引入另一个 .typ 文件,并通过 heading offset
// 整体增加其标题层级(默认 +1)。被导入文件自行 #import 所需函数,
// 不注入作用域、不解析文件文本。`路径` 以仓库根(--root)为基准,
// 如 "文档/内容/怪动植物.typ";offset 只支持非负值(增加层级)。
// / Import another .typ via #include, bumping all its heading levels by
// `偏移` (default +1). The imported file imports its own helpers; no scope
// injection, no source-text parsing. `路径` is relative to the repository
// root (--root), e.g. "文档/内容/怪动植物.typ". Note: offset must be >= 0
// (it only deepens headings), so the imported file should be written deeper.
#let 导入(路径, 偏移: 1) = {
  set heading(offset: 偏移)
  include "/" + 路径
}

// ------------------------------------------------------------
// 引用:块引用(左深红侧边条 + 可选出处标注)
// Blockquote with a left dark-red accent bar and optional citation.
//  body      - 引文内容 / Quoted content
//  出处       - 来源标注(可为 content 或 none),显示在框内右下方
//             Citation shown right-aligned at the bottom (content or none)
//  breakable - 是否允许跨页,默认开启 / Whether it can break across pages
// ------------------------------------------------------------
#let 引用(body, 出处: none, breakable: true) = {
 if "web" in sys.inputs and sys.inputs.web == "true" {
  return html.elem("div", attrs: (class: "uh-quote",))[
   #if 出处 != none {
    html.elem("div", attrs: (class: "uh-quote-cite",))[— #出处]
   }
   #set par(first-line-indent: 0em, spacing: 0.6em)
   #body
  ]
 }
 block(
  breakable: breakable,
  inset: (left: 14pt, top: 5pt, right: 8pt, bottom: 5pt),
  width: 100%,
  stroke: (left: 2.5pt + darkred),
  fill: rgb("#fefff9"),
 )[
  #set par(first-line-indent: 0em, spacing: 0.6em)
  #body
  #if 出处 != none [
   #v(0.4em)
   #align(right)[#text(fill: rgb("#888888"), size: 0.88em)[— #出处]]
  ]
 ]
}
