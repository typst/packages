#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/pointless-size:0.1.3": zh
#import "@preview/itemize:0.2.0" as el
#import "@preview/numblex:0.2.0": numblex
#import "@preview/kouhu:0.2.0": kouhu
#import "@preview/rexllent:0.4.1": xlsx-parser

#let calc-headings(headings) = {
  let max-page-num = calc.max(..headings.map(i => i.location().page()))
  let first-headings = (none,) * max-page-num
  let last-heading = context query(heading.where(level: 1).before(here())).at(-1).body
  let target-headings = (none,) * max-page-num
  //! 该循环排除了一页出现两个一级标题的情况
  for h in headings {
    if first-headings.at(h.location().page() - 1) == none {
      first-headings.at(h.location().page() - 1) = h.body
    }
  }
  for i in range(target-headings.len()) {
    target-headings.at(i) = {
      if i + 1 <= first-headings.len() and first-headings.at(i) != none {
        first-headings.at(i)
      } else {
        last-heading
      }
    }
  }
  target-headings
}
#let paper-title = state("title", "")
#let pn-style = state("pn-style", "roman")

//! 双语标题标记：写在标题旁（如 `= 绪论 #en[Introduction]`），
//! 供英文目录自动提取英文标题；正文与中文目录不受影响（不渲染任何内容）
#let en(body) = metadata(("en-title", body))

//! 参考文献/附录/致谢等位于 bibliography 之后的双语一级标题专用：
//! Typst 0.14.2 实测——bibliography 之后，标题体内只要含 metadata
//!（如 #en[..]）就会触发"layout did not converge within 5 attempts"
//!（bibliography 的引文收集与标题内 metadata 位置反复重排）；
//! metadata 作为标题兄弟节点则不触发。故此处标题体内不放 #en，
//! 英文标题以兄弟 metadata("en-next", …) 紧随标题之后，
//! 英文目录按"同页、标题正下方邻近"匹配（实测 context 内构造的标题
//! 其 .location() 与目录查到的元素 location 不相等，en-assoc 精确
//! 匹配对此类标题失效；邻近匹配不依赖 location 恒等，稳定可靠）。
//! 用法：#back-heading([参#h(0.5em)考…献], [References])
#let back-heading(zh-body, en-body) = [
  #heading(level: 1)[#zh-body]
  #metadata(("en-next", en-body))
]

//! 在 content 树中递归查找第一个 #en[...] 标记。
//! 0.14.2 的 query 不支持在 content 片段内检索，故手动遍历
#let find-en-title(node) = {
  if type(node) != content { return none }
  if node.func() == metadata {
    let v = node.value
    if v.len() == 2 and v.at(0) == "en-title" { return node }
  }
  //! content 容器：sequence 的 children 为数组，样式包装等的 body 为 content
  for field in ("children", "body") {
    if node.has(field) {
      let inner = node.at(field)
      if type(inner) == content {
        let found = find-en-title(inner)
        if found != none { return found }
      } else if type(inner) == array {
        for child in inner {
          let found = find-en-title(child)
          if found != none { return found }
        }
      }
    }
  }
  none
}

//! 全角句读/闭合标点按 Word 远东版式排版（docx: compressPunctuation + useFELayout）：
//! Typst 对这些标点的 CJK 胶版两端对齐时可压 0.5em（实测 12pt 行步进压到 8.39pt），
//! Word 仅压约 0.05em，导致 Typst 每行多塞字、换行系统性偏晚。
//! 包 lang:"en" 关掉 zh 标点压缩胶版，字形仍为 SimSun/SimHei/FangSong 全角；
//! 开括号（【《「『侧两引擎实测仅差 0.22pt，保留 Typst 行为，故不列入。
#let show-word-punct(body) = {
  show regex("[，。、；：！？）】》」』”’]"): it => text(lang: "en", it.text)
  body
}

#let typeset-fore(doc) = {
  show: show-cn-fakebold
  show: show-word-punct
  show: el.default-enum-list.with(bottom-edge: "baseline")

  //! 设置标题序号
  set heading(
    numbering: numblex(
      "
    {[1   ]:d==1;[1]:d==2;[1]:d==3}
    {[.1   ]:d==2;[.1]:d==3}
    {[.1   ]:d==3;}
    {        （[1]）:d==4}
    {        [①]:d==5}
    ",
    ),
  )

  //! 设置标题格式
  show heading: set text(weight: "regular")
  //! H1 块样式走 show-set 而非 show 函数体内的 set：函数体内的 set 位于
  //! realization 链最深处，任何内层作用域（摘要/目录等前置部分）都盖不过，
  //! 曾被迫用 v/页边距补偿；show-set 可被内层作用域的同名 show-set 覆盖
  show heading.where(level: 1): set block(
    //! 文本区顶 102.9（正文网格相位），inset 4.0 → H1 ink top 106.9（REF）。
    //! inset 是盒内边距页顶不消失，只保留 docGrid 标题相位 4pt；段距一律走
    //! spacing（block↔block 相邻折叠取大、页顶自动抑制），不用流内 v。
    inset: (top: 4pt, right: 0em, bottom: 0em, left: 0em),
    //! docx 标题1 直接格式 after=312 twips（15.6pt，一个 docGrid 行），
    //! 经行盒边折算后 H1→正文墨顶差 42.9（REF 实测）；before 文档为 0。
    //! 注意 Typst 0.14 block spacing 只接受标量（before/after 同值、折叠取大、
    //! 页顶 before 自动抑制），非对称部分由 inset 承担
    spacing: 30pt,
  )
  show heading.where(level: 1): it => {
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(-3),
      // top-edge: 1.4em,
      // bottom-edge: 0.5em,
    )
    //! 第一个一级标题之前（含自身）就一个，所以大于1就分页；
    //! 每个一级标题出现时按章重置图/表/代码/算法与公式计数器（编号"章号.序号"）
    let reset-counters = {
      for k in (image, table, raw, "algorithm") {
        counter(figure.where(kind: k)).update(0)
      }
      counter(math.equation).update(0)
    }
    if query(heading.where(level: 1).before(here())).len() > 1 {
      pagebreak()
      it + reset-counters
    } else {
      it + reset-counters
    }
  }
  show heading.where(level: 2): it => {
    set block(
      //! docx 标题2 before=156 twips（半 docGrid 行 7.8pt）、after=0，经网格
      //! 吸附实测（墨底→墨顶）：P→H2 18.9、H2→P 11.3、H2→H3 20.7；
      //! H2 页顶墨顶 107.4（段前距被页首抑制）。
      //! 机制：spacing 在 0.14 只接受标量（before/after 同值、相邻折叠取大、
      //! 页顶 before 自动抑制），故段前距走 spacing 14.6（页顶正确消失），多出
      //! 的段后用 inset bottom 收回（5.1→0）；inset top 只留页顶相位 4.5
      inset: (top: 4.5pt, right: 0em, bottom: 0pt, left: 0em),
      spacing: 14.6pt,
    )
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(4),
    )
    it
  }
  show heading.where(level: 3): it => {
    set block(
      //! docx 标题3 before=156 twips（半 docGrid 行 7.8pt）、after=0，网格吸附
      //! 实测（墨底→墨顶）：P→H3 16.0、H3→P 8.5（= 普通正文行间距，after=0）。
      //! 机制：after 要小，故 spacing 标量降到 11（H3→P 命中），before 不足部分
      //! 用 inset top 补到 8.1（与 H2 不同方向：H2 段前走 spacing 因页顶必须抑制；
      //! H3 极少独占页顶，inset top 的页顶残留仅 ~3pt）。
      //! 旧 inset bottom 11.3 曾使 H3→P 达 22.5（标题后空一块），已去除
      inset: (top: 8.1pt, right: 0em, bottom: 0pt, left: 0em),
      spacing: 11pt,
    )
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(-4),
    )
    it
  }
  show heading.where(level: 4): it => {
    set block(
      // inset: (top: -1em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      // spacing: 1em,
    )
    set text(
      font: ("Times New Roman", "SimSun"),
      size: zh(-4),
      top-edge: 0em,
      bottom-edge: 0em,
    )
    it
  }
  show heading.where(level: 5): it => {
    set block(
      // inset: (top: 0em, right: 0em, bottom: 0em, left: 0em),
      // outset: 1em,
      // spacing: 1em,
    )
    set text(
      font: ("Times New Roman", "SimSun"),
      size: zh(-4),
      top-edge: 0em,
      bottom-edge: 0em,
    )
    it
  }

  //! 为每个标题建立英文标题显式关联：扫描标题体内的 #en[...]，
  //! 重新发出携带标题自身 location 的 metadata，供英文目录按 location 精确匹配。
  //! 定义在分级规则之后（更外层）以收到原始标题；分页导致的位置排序反转不影响显式关联
  show heading: it => {
    let marker = find-en-title(it.body)
    if marker == none {
      it
    } else {
      [
        #it
        #metadata(("en-assoc", it.location(), marker.value.at(1)))
      ]
    }
  }

  //! 设置段落格式：行节奏固定 19.56pt（top-edge 0.86em + leading 0.77em，
  //! 与 docx docGrid 实测 19.53 一致）。spacing 与 leading 同值：
  //! 自定义 edge 后段落边界节奏 = top-edge + spacing，同值则段落间节奏不中断
  //! （视觉上段距为 0，无额外空行）
  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    leading: 0.77em,
    spacing: 0.77em,
  )

  //! 设置正文格式：行盒上下边按 0.86/0.14em 切分，中英文字行盒同为 1em，
  //! Times New Roman 与宋体行距统一
  set text(
    font: ("Times New Roman", "SimSun"),
    size: zh(-4),
    lang: "zh",
    region: "cn",
    top-edge: 0.86em,
    bottom-edge: 0.14em,
  )

  //! 设置figure格式：图/表/代码/算法按 kind 分开计数，编号为"章号.序号"。
  //! 编号在 kind 级 set 规则中全局设置（不能写在 `show figure: it => { set..; it }`
  //! 的函数体内——已构造的 figure 元素不会重读该样式，否则题注/引用/目录会退回"图 1"）。
  //! 保留 Typst 在 supplement 与编号间自动插入的空格，
  //! 使题注、正文引用、图表目录统一显示为"图 2.1"（"图"字与编号间有间隔，与 docx 模板一致）
  let figure-numbering(
    k,
  ) = _ => [#counter(heading.where(level: 1)).display("1").#counter(figure.where(kind: k)).display("1")]
  set figure.caption(separator: "  ")
  show figure.where(kind: image): set figure(numbering: figure-numbering(image), supplement: [图])
  show figure.where(kind: table): set figure(numbering: figure-numbering(table), supplement: [表])
  show figure.where(kind: raw): set figure(numbering: figure-numbering(raw), supplement: [代码])
  show figure.where(kind: "algorithm"): set figure(numbering: figure-numbering("algorithm"), supplement: [算法])

  //! 其中插入图片格式：图片段/图注段在 docx 中都是普通正文段（无段距），
  //! 视觉间距由 docGrid 行格吸附产生——REF 实测正文→图 27.1、图注→正文 25.7
  //!（图注下方约一空行），图在页顶时图前距消失（图顶 = 内容区顶 102.9）。
  //! 故间距走 figure 块的 spacing 标量（页顶 before 自动抑制、相邻块折叠取大），
  //! 不能在图前塞流内 v（页顶不消失，会把整图顶低 ~13pt）。图注→正文 REF 26.1
  //!（图注下一空行），提高 spacing 同时让文中图 before 趋近 REF 27.1，实测迭代
  show figure.where(kind: image): it => {
    set block(spacing: 29pt)
    it
  }
  show figure.where(kind: image): set figure.caption(position: bottom)

  //! 其中插入表格格式：题注在上。
  //! REF 实测：上文墨底→题注 25.7、题注墨底→顶线 2.9、底线→下文 22.8，
  //! 两表相邻（中间无正文）时底线→题注同样是 22.8；
  //! 表题在页顶时落在 102.6（前置间隔消失）。
  //! 非对称实现（探针实测）：show 函数体内注入的弱 v 会"替换"该块的前侧
  //! 间距（手写在正文流里则是叠加，二者不同），而块的后侧间距不受影响。
  //! 故 figure spacing 22.8 专门承担表后→下文（gap C 实测 22.8=REF）；
  //! 表前由弱 v 给出：墨底→块边差 2.9，v(28.6)−2.9=25.7（REF）；
  //! 相邻两表底线即块边、无墨边差，v 取 22.8 即得 22.8。
  //! 相邻判定不靠 query 计数（before(here()) 会包含当前表自身），
  //! 也不靠题注位置差固定阈值（混淆矩阵类大表整块高达 117pt）：
  //! 每张表在末尾放置 metadata 标记（携自身稳定 location），标记落在
  //! 间距折叠后、下一块之前——相邻时距下一题注仅 ~2.5pt，
  //! 隔一行正文即 ≥38pt，故阈值 12pt 干净可分（探针 V11 实测）。
  //! 弱间距在页顶/页底自动塌陷：表被挤到次页时 v 留在上页底消失，
  //! 页顶题注仍是 102.9——等价于 REF 题注前那个空段落。
  //! 题注墨底→顶线 2.9 由 figure gap 5.4pt 折合。
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 5.4pt)
  show figure.where(kind: table): it => context {
    set block(spacing: 22.8pt, breakable: true)
    //! 找前表末尾的相邻标记（"tbl-marker", loc）。
    //! 标记位置在间距折叠后、下一块之前：两表相邻时距本块题注仅 ~2.5pt，
    //! 中间隔一行正文即 ≥38pt——阈值 12pt 干净可分。
    //! 标记必须走 metadata 携自身稳定 location，不能用 state 存坐标：
    //! 坐标→v 决策→间距→坐标会形成自反馈，实测全文"布局不收敛"。
    let vamt = 28.6pt
    let last-marker = none
    for m in query(metadata.where().before(here())) {
      if m.value.len() == 2 and m.value.at(0) == "tbl-marker" {
        last-marker = m.value.at(1)
      }
    }
    if last-marker != none and last-marker.page() == here().page() {
      if here().position().y - last-marker.position().y < 12pt {
        vamt = 22.8pt
      }
    }
    v(vamt, weak: true)
    it
    //! 末尾标记：context 内 here() 即标记自身位置（稳定身份，不随迭代漂移）
    context metadata(("tbl-marker", here()))
  }
  show table: set text(size: zh(5))

  //! 其中插入交叉引用：保留默认"中西文自动间距"，编号末尾数字与后续中文之间
  //! 自然形成小空格（如"如图 2.1 所示"），与 docx 模板一致
  show ref: it => context {
    let el = it.element
    //! 引用主体：图/表/代码/算法用默认渲染；公式用目标位置计数器重建，
    //! 必须 counter.at 而非 .display（后者在引用处求值会少 1）
    if el == none or el.func() != math.equation {
      it
    } else {
      let chap = counter(heading.where(level: 1)).at(el.location()).first()
      let num = counter(math.equation).at(el.location()).first()
      link(el.location(), numbering((c, n) => [式（#c.#n）], chap, num))
    }
  }
  set math.equation(
    numbering: _ => text(
      font: "Times New Roman",
    )[(#counter(heading.where(level: 1)).display("1").#counter(math.equation).display("1"))],
  )
  show math.equation.where(block: true): it => {
    v(1em)
    it
    v(1em)
  }

  //! 其中插入代码格式（用文末的 code() 函数生成代码清单，
  //! 代码左对齐、整体左缩进 2 字符，编号"章号.序号"，caption 在上方，引用时 supplement 为"代码"）
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): it => {
    v(1em)
    it
  }
  //! par 设置只对块级代码生效；行内代码（如 `pd.read_excel`）必须保持行内，
  //! 否则会把所在段落切碎成多行
  show raw.where(block: true): set par(first-line-indent: 0em, justify: false)
  show raw: set text(font: ("Courier New", "SimSun"), size: zh(5))
  //! Typst 内建 typ 语法高亮把代码中的标题行（= …）渲染为加粗+下划线，
  //! 下划线在论文代码清单里易被误认为格式要求标记，剥除下划线、保留加粗与其余着色
  show raw: it => {
    show underline: u => u.body
    it
  }

  //! 其中插入伪代码格式（用文末的 algorithm() 函数生成，
  //! 算法框整体居中、框内文字左对齐，编号"章号.序号"，caption 在上方，引用时 supplement 为"算法"）
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): it => {
    v(1em)
    it
  }

  //! 设置脚注格式
  show footnote.entry: set text(
    font: ("Times New Roman", "SimSun"),
    size: zh(-5),
  )
  set footnote.entry(
    indent: 0em,
    separator: line(
      length: 30%,
      stroke: 0.5pt,
    ),
  )
  set footnote(numbering: "①")

  //! 设置参考文献格式
  show bibliography: it => {
    set text(size: zh(5))
    it
  }
  doc
}
#let typeset-back(doc) = {
  //! 正文中文加粗用 cuti 伪粗（包内中文字体仅随 Regular 字重，西文加粗仍由
  //! Times New Roman Bold 承担），与前置部分 typeset-fore 保持一致
  show: show-cn-fakebold
  show: show-word-punct
  pn-style.update("arabic")
  counter(page).update(1)
  set page(
    margin: (
      //! 文本区顶取 102.9pt：复刻 docGrid 网格相位（续页首行在 103.0，REF）；
      //! 章首页由 H1 show 的 inset 把标题定在 106.9
      top: 102.9pt,
      //! 底边对齐 docGrid 行格：内容区高 = 34 行 × 19.56 = 665.0（102.9→767.9）。
      //! docx pgMar bottom=1418（几何底 771.1），正文行吸附 linePitch=312 网格，
      //! 第 34 行（墨顶 748.4、墨迹底 ~760.4）为最深合法行；内容高锁整数格后，
      //! 第 35 行几何上放不下，偏相内容（公式/表格残差）同样落到下一页，不撞页码。
      bottom: 74.1pt,
      left: 2.5cm,
      right: 2.5cm,
    ),
    //! 眉区底部锚点 = 文本区顶 − ascent：ascent 13.7pt 时眉线 89.2、眉文 72.4（REF）
    header-ascent: 13.7pt,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #v(3.6pt)
      #head-text
      #v(-1.7pt)
      #line(length: 100%, stroke: 0.75pt)
    ],
    //! docx w:footer=1134（盒底距纸底 56.7pt）：Typst footer 盒顶固定在文本区底，
    //! descent 加大只会把盒顶下移，故保持 0。内容底 767.9（34 行格），
    //! 盒内 v(5.1pt) 把页码锚到 780.8 基线（REF）
    footer-descent: 0pt,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      //! 页码基线落 780.8（REF）
      #v(5.1pt)
      #counter(page).display("1")
    ],
  )
  doc
}

#let cover(
  zh-title1: [中文标题1],
  zh-title2: [中文标题2],
  en-title1: [title1],
  en-title2: [title2],
  author: [作者],
  mentor: [导师],
  degree: [学位],
  academy: [学院],
  subject: [专业],
  research: [研究方向],
  year: datetime.today().display("[year]"),
  month: 4,
) = {
  paper-title.update(zh-title1 + zh-title2)
  //! 封面整体绝对定位（白底，与 docx 一致；黄色为实体皮纸颜色）
  set page(margin: 0pt)
  //! 存档扫描件整体偏左上（装订皮面扫描所致）：实测封面墨迹包围盒
  //! x 37.4..513.3 / y 52.5..749.9。垂直整体下移 oy 居中；水平方向
  //! ox 仅作用于左右角元素（logo/信息块），行级元素改为各自页面水平居中
  let ox = 22.3pt
  let oy = 19.7pt
  let distr(width: auto, body) = {
    block(
      width: width,
      stack(
        dir: ltr,
        ..body.clusters().map(x => [#x]).intersperse(1fr),
      ),
    )
  }
  let number_to_chinese(num) = {
    let chinese_digits = (
      "〇",
      "一",
      "二",
      "三",
      "四",
      "五",
      "六",
      "七",
      "八",
      "九",
    )
    let num_str = str(num)
    let result = ""
    for num_digit in num_str {
      let num_digit = int(num_digit)
      result += chinese_digits.at(num_digit)
    }
    return result
  }

  //! 封面logo：校徽定标 scale 0.40，印出 234.7×52.7，与存档件重合
  place(
    dx: 37.4pt + ox,
    dy: 52.5pt + oy,
    image("./assets/硕士毕业论文封面logo.png", width: 234.7pt),
  )

  //! 出版信息：黑体五号（批注 #0）；右上角四行同处一个 block、共用一个行节奏，
  //! 每行的标签与下划线在同一水平位（下划线 = 基线 +1.1pt 的 Word 下划线位）。
  //! Word 原件为浮动文本框，行距 line=360 auto（实测行节奏 23.4pt，取 23.3）；
  //! 学校代码/密级/中图分类号分散对齐，UDC 右对齐；下划线长 60.1pt
  {
    set text(font: ("Times New Roman", "SimHei"), size: zh(5))
    let info-rows = (
      ("学校代码", true),
      ("密级", true),
      ("中图分类号", true),
      ("UDC", false),
    )
    for (i, (label, spread)) in info-rows.enumerate() {
      //! 标签墨顶 = dy − 1.8（SimHei 行盒度量），首行墨顶 59.8
      let row-dy = 61.6pt + oy + 23.3pt * i
      place(dx: 393.4pt + ox, dy: row-dy, if spread {
        distr(width: 54.4pt, label)
      } else {
        block(width: 54.4pt, align(right, label))
      })
      //! 下划线随标签同节奏下移（dy + 8.5 ≈ 基线 +1.1），四线顶 y 70.1/93.4/116.7/140.0
      place(dx: 453.2pt + ox, dy: row-dy + 8.5pt, line(length: 60.1pt, stroke: 0.6pt))
    }
  }

  //! 硕士学位论文：方正小标宋简体 45pt（批注 #3），
  //! 块宽 571.2pt 居中（存档件视觉中心 285.8；v2 改为页面几何中心）
  place(center + top, dy: 226.8pt + oy)[
    #block(
      width: 571.2pt,
      align(center, text(
        font: "FZXiaoBiaoSong-B05S",
        size: 45pt,
        tracking: 10pt,
      )[硕士学位论文]),
    )
  ]

  //! MASTER DISSERTATION：华文中宋一号 26pt，同一中心
  place(center + top, dy: 288.5pt + oy)[
    #block(
      width: 571.2pt,
      align(center, text(font: "STZhongsong", size: zh(1))[MASTER DISSERTATION]),
    )
  ]

  //? 论文题目（中英）：列宽 76/373pt、行高 31.9pt，
  //? 横线仅第二列单元格底部 0.5 磅（批注 #8）；
  //? 填入值汉字用楷体、西文与数字统一 Times New Roman（封面所有填入项同此）
  place(center + top, dy: 383.3pt + oy)[
    #table(
      columns: (76pt, 373pt),
      rows: 31.9pt,
      inset: 0pt,
      align: center + horizon,
      stroke: none,
      text(font: ("Times New Roman", "SimHei"), size: zh(-3))[论文题目],
      text(font: ("Times New Roman", "KaiTi"), size: zh(3))[#zh-title1],
      table.hline(stroke: 0.5pt, start: 1),
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[（中文）],
      text(font: ("Times New Roman", "KaiTi"), size: zh(3))[#zh-title2],
      table.hline(stroke: 0.5pt, start: 1),
      text(font: ("Times New Roman", "SimHei"), size: zh(-3))[论文题目],
      text(font: "Times New Roman", size: zh(4))[#en-title1],
      table.hline(stroke: 0.5pt, start: 1),
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[（英文）],
      text(font: "Times New Roman", size: zh(4))[#en-title2],
      table.hline(stroke: 0.5pt, start: 1),
    )
  ]

  //? 作者信息：4 列 (73/144/68/160pt)、行高 30.4pt（界桩 56/129/273/341/501）；
  //? 作者/学位/专业值楷体小三，导师/学院/方向值黑体四号（批注 #10），
  //? 值内西文与数字统一 Times New Roman。
  //? Word 30pt 固定行盒把文字压在底部；存档件实测墨顶 587.5、墨底距线 6.0
  //? （首线 606.0），故表 dy 575.2、内容区底部内缩 5.6pt（inset 3.6 时墨底距线
  //? 仅 4.0、三行整体偏下 2pt）
  place(center + top, dy: 575.2pt + oy)[
    #table(
      columns: (73pt, 144pt, 68pt, 160pt),
      rows: 30.4pt,
      inset: (bottom: 5.6pt),
      align: center + bottom,
      stroke: none,
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[
        #distr(width: 4em, "作者")
      ],
      text(font: ("Times New Roman", "KaiTi"), size: zh(-3))[#author],
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[
        #distr(width: 4em, "导师")
      ],
      text(font: ("Times New Roman", "KaiTi"), size: zh(-3))[#mentor],
      table.hline(stroke: 0.5pt, start: 1, end: 2),
      table.hline(stroke: 0.5pt, start: 3),
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[
        #distr(width: 4em, "申请学位")
      ],
      text(font: ("Times New Roman", "KaiTi"), size: zh(-3))[#degree],
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[
        #distr(width: 4em, "学院名称")
      ],
      text(font: ("Times New Roman", "KaiTi"), size: zh(-3))[#academy],
      table.hline(stroke: 0.5pt, start: 1, end: 2),
      table.hline(stroke: 0.5pt, start: 3),
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[
        #distr(width: 4em, "学科专业")
      ],
      text(font: ("Times New Roman", "KaiTi"), size: zh(-3))[#subject],
      text(font: ("Times New Roman", "SimHei"), size: zh(4))[
        #distr(width: 4em, "研究方向")
      ],
      text(font: ("Times New Roman", "KaiTi"), size: zh(-3))[#research],
      table.hline(stroke: 0.5pt, start: 1, end: 2),
      table.hline(stroke: 0.5pt, start: 3),
    )
  ]

  //? 年月：小二、正常排（不紧排）；存档件实测数字（二〇二五/六）为楷体，
  //? 「年」「月」为黑体，与数字间各空约 8pt。
  //? 页面水平居中；墨顶 734（存档件实测；底部扫描有卷边，水平以页面居中为准）
  place(center + top, dy: 735pt + oy)[
    #block(
      width: 595.3pt,
      align(center, text(font: "KaiTi", size: zh(-2))[
        #number_to_chinese(year)#h(8pt)#text(font: ("Times New Roman", "SimHei"))[年]#h(8pt)#number_to_chinese(month)#h(8pt)#text(font: ("Times New Roman", "SimHei"))[月]
      ]),
    )
  ]
}

#let declaration() = {
  show: show-cn-fakebold
  show: show-word-punct
  set page(margin: (
    top: 3.5cm,
    bottom: 2.5cm,
    left: 2.5cm,
    right: 2.5cm,
  ))
  set par(
    justify: true,
    first-line-indent: 1.01cm,
    leading: 17pt,
  )

  //! 独创性声明标题
  v(23pt)
  align(
    center,
    text(
      font: ("Times New Roman", "SimHei"),
      size: zh(2),
      tracking: 4pt,
    )[
      #strong("独创性声明")
    ],
  )

  //! 独创性声明正文
  v(19pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(-3))
  [本人声明所呈交的论文是我个人在导师指导下进行的研究工作及取得的研究成果。尽我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写的研究成果，也不包含为获得江西财经大学或其他教育机构的学位或证书所使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示了谢意。]

  //! 签名与日期
  v(3 * 17.5pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(4))
  par(
    justify: true,
    first-line-indent: 6.75cm,
    leading: 15pt,
  )[
    签名：#underline("                  ")日期：#underline("                  ")
  ]

  //! 使用授权标题
  v(2 * 19.5pt)
  align(
    center,
    text(
      font: ("Times New Roman", "SimHei"),
      size: zh(2),
    )[
      #strong("关于论文使用授权的说明")
    ],
  )

  //! 使用授权正文
  v(19pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(-3))
  [本人完全了解江西财经大学有关保留、使用学位论文的规定，即：学校有权保留送交论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。

    *（保密的论文在解密后遵守此规定）*]

  //! 签名、导师签名与日期
  v(3 * 17pt)
  set text(font: ("Times New Roman", "SimSun"), size: zh(4))
  par(
    justify: true,
    first-line-indent: 1.5cm,
    leading: 15pt,
  )[
    签名：#underline("                  ")导师签名：#underline("                  ")日期：#underline("                  ")
  ]
}

#let abstract(
  zh-abstract: [中文摘要],
  zh-keywords: [关键词1，关键词2，关键词3],
  en-abstract: [Abstract],
  en-keywords: [keyword1; keyword2; keyword3],
) = {
  //! bottom-edge 是题注编号文字的 text 参数，只接受 "baseline"/"descender"/"bounds"/长度；
  //! 写 "auto" 在 0.14.2 会报错（abstract 内无列表时不触发，含列表时触发）
  show: el.default-enum-list.with(bottom-edge: "baseline")
  set page(
    margin: (
      //! 文本区顶 102.9pt：docGrid 续页相位 103.0（REF，前置部分与正文统一）
      top: 102.9pt,
      bottom: 2.5cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
    //! 眉区底部锚点 = 文本区顶 − ascent：ascent 13.7pt 时眉线 89.2、眉文 72.4（REF）
    header-ascent: 13.7pt,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #v(3.6pt)
      #head-text
      #v(-1.7pt)
      #line(length: 100%, stroke: 0.75pt)
    ],
    //! docx w:footer=1134（盒底距纸底 56.7pt）：Typst footer 盒顶固定在文本区底，
    //! descent 加大只会把盒顶下移，故保持 0，纵向偏移由 footer 内 v(2.0pt) 完成
    footer-descent: 0pt,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      //! 顶部 v(2.0)：页码基线落 780.8（REF；原贴文本区底 778.8）
      #v(2.0pt)
      #counter(page).display("I")
    ],
  )
  show heading.where(level: 1): it => {
    //! 标题位置：外层 typeset-fore 的 set block 对这里的标题同样生效（inset 4.0），
    //! 文本区顶 102.9，再前置 v(0.5pt) → 标题行盒 107.4（REF 107.4）
    set align(center)
    set text(
      font: ("Times New Roman", "SimHei"),
      size: zh(-3),
      //   top-edge: 1.5em,
    )
    v(0.5pt)
    it
    //! 标题下间距直接用全局 H1 的 spacing 30pt（REF 首行墨顶 149.8）；
    //! 不再叠 v：全局 spacing 升到 30pt 后 v(16.4) 与之叠加会多出约 17pt
  }
  set heading(level: 1, numbering: none)
  //! 与 typeset-fore 同节奏（19.56pt），spacing 与 leading 同值以维持段间节奏
  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    leading: 0.77em,
    spacing: 0.77em,
  )
  counter(page).update(1)

  [
    = 摘#h(2em)要 #en[Abstract]

    #zh-abstract
    //! 与末行空整整一行（首尾行顶距 = 2 个行节奏 39.1，REF 39.0）后排关键词
    #v(18.1pt)
    //! 标签与正文须在同一 markup 连续结构内：分写两个独立表达式会产生词间空格
    //!（实测标签后多 3pt 空隙）
    #text(font: ("Times New Roman", "SimHei"), size: zh(
      -4,
    ))[关键词：#text(font: ("Times New Roman", "FangSong"), size: zh(-4))[#zh-keywords]]

    #heading(outlined: false)[Abstract]
    #en-abstract
    #v(18.1pt)
    *Key Words:* #en-keywords
  ]
}

//! 目录条目：点线引导 + 页码（前置部分 roman / 正文部分 arabic）
#let outline-entry(it) = {
  link(
    it.element.location(),
    it.indented(
      it.prefix(),
      [
        #it.body()
        #box(width: 1fr, repeat([.]))
        #context {
          let loc = it.element.location()
          let style = pn-style.at(loc)
          let num = counter(page).at(loc).first()
          if style == "roman" { numbering("I", num) } else { numbering("1", num) }
        }
      ],
      gap: 0em,
    ),
  )
}

//! 英文目录条目：提取标题旁 #en[...] 标注的英文标题，未标注的标题回退显示原文
#let outline-entry-en(it) = {
  context {
    let en-text = none
    //! 匹配标题 show 规则生成的显式关联 metadata（携带标题自身 location，
    //! 避免分页导致标题与体内 #en[...] 的位置排序反转）
    for m in query(metadata) {
      let v = m.value
      if v.len() == 3 and v.at(0) == "en-assoc" and v.at(1) == it.element.location() {
        en-text = v.at(2)
      }
    }
    if en-text == none {
      //! back-heading 的后置标题：兄弟 en-next metadata 邻近匹配。
      //! 后置 H1 前必有 pagebreak（全局 H1 show），标题独占页顶，
      //! 其 en-next 紧跟其后——同页、标题下方 80pt 内的 en-next 唯一
      let hloc = it.element.location()
      let hy = hloc.position().y
      for m in query(metadata) {
        let v = m.value
        if v.len() == 2 and v.at(0) == "en-next" {
          let ml = m.location()
          if ml.page() == hloc.page() {
            let dy = ml.position().y - hy
            if dy > -5pt and dy < 80pt {
              en-text = v.at(1)
            }
          }
        }
      }
    }
    link(
      it.element.location(),
      it.indented(
        it.prefix(),
        [
          #if en-text != none { en-text } else { it.body() }
          #box(width: 1fr, repeat([.]))
          #context {
            let loc = it.element.location()
            let style = pn-style.at(loc)
            let num = counter(page).at(loc).first()
            if style == "roman" { numbering("I", num) } else { numbering("1", num) }
          }
        ],
        gap: 0em,
      ),
    )
  }
}

#let multi-outline() = {
  set page(
    margin: (
      //! 文本区顶 103.4pt：续页相位 103.0（REF，+0.4 容差）；比摘要页高 0.5，
      //! 使目录类标题行盒落在 107.4（REF 实测；内层 inset 会被全局 H1 show 覆盖，
      //! 故只能在此整体抬高）
      top: 103.4pt,
      //! 同 typeset-back：内容底对齐行格 767.9（bottom 74.1），与正文页一致；
      //! REF 目录最深条目 ~740，放容后若多排条目也在 767 前、不撞页码
      bottom: 74.1pt,
      left: 2.5cm,
      right: 2.5cm,
    ),
    //! 眉区底部锚点 = 文本区顶 − ascent：ascent 14.2pt 时眉线 89.2、眉文 72.4（REF）
    header-ascent: 14.2pt,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #v(3.6pt)
      #head-text
      #v(-1.7pt)
      #line(length: 100%, stroke: 0.75pt)
    ],
    //! docx w:footer=1134（盒底距纸底 56.7pt）：Typst footer 盒顶固定在文本区底
    //! 767.9，descent 加大会把盒顶下移故保持 0；盒内 v(5.1pt) 锚到 780.8 基线
    footer-descent: 0pt,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      //! 页码基线落 780.8（REF）
      #v(5.1pt)
      #counter(page).display("I")
    ],
  )
  //! 目录类标题仅改对齐：垂直位置由上边距 103.4 统一保证（行盒 107.4）。
  //! 不能用前置 v：全局 H1 show 已在标题前插 pagebreak，分页符后紧跟弱 v 会生成空白页；
  //! 也不能用内层 set block inset：会被全局 H1 show 的 set block 覆盖
  show heading.where(level: 1): set align(center)
  set heading(level: 1, numbering: none)

  //! 目录/TOC 标题→首条为紧凑间距（REF：标题墨底 122.4 → 首条墨顶 133.8，
  //! 折合 block spacing 13.5pt）。用内层 show-set 覆盖全局 H1 块样式的 spacing
  //!（inset 等其余属性继承全局 show-set）；pagebreak 逻辑仍由全局 H1 show
  //! 完成，不受影响
  show outline.entry: outline-entry
  [
    #show heading.where(level: 1): set block(spacing: 13.5pt)
    #heading(level: 1)[目#h(2em)录 #en[TOC]]
    #outline(
      title: none,
      depth: 3,
    )
  ]

  //! 英文目录：标题仅作本页页名，不进入任何目录（独立插入，不参与中文目录）
  show outline.entry: outline-entry-en
  [
    #show heading.where(level: 1): set block(spacing: 13.5pt)
    #heading(level: 1, outlined: false)[TABLE OF CONTENTS]
    #outline(
      title: none,
      depth: 3,
    )
  ]

  //! 图/表/公式目录（标题均进入中英文总目录）：标题→首条与摘要同款空一行
  //! 节奏（REF 27.4pt），直接走全局 H1 的 spacing 30pt，不叠 v
  show outline.entry: outline-entry
  [
    #heading(level: 1)[图目录 #en[List of Figures]]
    #outline(
      title: none,
      depth: 3,
      target: figure.where(kind: image),
    )

    #heading(level: 1)[表目录 #en[List of Tables]]
    #outline(
      title: none,
      depth: 3,
      target: figure.where(kind: table),
    )

    #heading(level: 1)[公式目录 #en[List of Equations]]
    #outline(
      title: none,
      depth: 3,
      target: math.equation,
    )
  ]
}

//! 代码清单环境：代码块左对齐、整体左缩进 2 字符（figure 默认会将内容居中，
//! 故用通栏 block 包裹并左对齐），编号"章号.序号"（计入 raw 类型，不与图表混编）。
//! 用法：
//! #code(
//!   ```python
//!   print("hello")
//!   ```,
//!   caption: [代码名称],
//! ) <code1> 之后用 @code1 引用，自动显示为"代码x.y"
//! supplement/编号由 typeset-fore 中 kind 为 raw 的全局 set 规则提供
#let code(body, caption: [代码标题]) = figure(
  block(
    width: 100%,
    inset: (left: 2em),
  )[
    #set align(left)
    #body
  ],
  kind: raw,
  caption: caption,
)

//! 伪代码环境：三线风格算法框，算法框整体居中、框内文字左对齐
//! （figure 默认将内容居中，表格去掉通栏 block 后框宽随内容收缩，与三线表同风格），
//! 编号"章号.序号"（计入 algorithm 类型，不与图表混编）。
//! 用法：
//! #algorithm(
//!   caption: [算法名称],
//!   input: [输入说明（可省略）],
//!   output: [输出说明（可省略）],
//!   [算法步骤，用 \ 换行],
//! ) <alg1> 之后用 @alg1 引用
//! supplement/编号由 typeset-fore 中 kind 为 "algorithm" 的全局 set 规则提供
#let algorithm(body, caption: [算法标题], input: none, output: none) = figure(
  kind: "algorithm",
  table(
    columns: 1,
    stroke: (top: 0.75pt, bottom: 0.75pt, x: none, y: none),
    inset: (x: 1em, y: 0.35em),
    align: left,
    if input != none [*输入：*#input],
    if output != none [*输出：*#output],
    body,
  ),
  caption: caption,
)

//! 三线表起始页状态：tlt() 在表格紧前更新，续页表头里的 context
//! 据此判断"当前页晚于起始页"从而显示续表标记（表头.header 每页重复、逐页重估）
#let tlt-page = state("tlt-page", 0)

//! 设置三线表格式（data 为读取好的文件内容，须在调用处用
//! `read("./tables/xxx.xlsx", encoding: none)` 读取，以保证路径相对使用者文件解析）
#let tlt(data) = {
  //! 先只做解析（parse-table-style: false 时 rexllent 给出 columns/rows 计数），
  //! 表格骨架（续表标记行、顶线、表头、底线）在本地重组以支持跨页续表：
  //! 标记行与顶线放进 table.header，分页后随表头每页重复
  let t = xlsx-parser(
    data,
    parse-table-style: false,
    parse-alignment: false,
    parse-stroke: false,
    parse-fill: true,
    //! 不采信 xlsx 自带字体：表头是否加粗/字号全由本库统一（表头加粗、
    //! 全文五号），避免不同 xlsx 文件的格式差异渲染出不一致的表格
    parse-font: false,
    parse-header: true,
    parse-formatted-cell: true,
    align: horizon,
  )
  //! table 构造时会把计数参数规范化为 auto 轨道数组（parse-table-style: false
  //! 时传给 table 的是列数/行数），故用 len() 取回计数
  let n = if type(t.columns) == int { t.columns } else { t.columns.len() }
  let m = if type(t.rows) == int { t.rows } else { t.rows.len() }
  //! 起始页更新紧贴表格：本表任意续页表头读到的都是本表起始页
  context tlt-page.update(here().page())
  //! 单元格文字垂直居中：全局 top-edge 0.86em 使墨迹在 1.8em 固定行高内
  //! 偏低 ~1pt（实测行内墨上/下 5.0/2.9，REF 为 4.2/3.7 居中）。
  //! 此处 top/bottom-edge 互换 0.1em，行盒总高 1.77em 不变、多行格行距不变
  set text(top-edge: 0.76em, bottom-edge: 0.24em)
  //! 表头行统一加粗：重组后 y=0 是续表标记行、y=1 才是表头行；
  //! 字号由全局 show table 的五号供给，无需在此重复设置
  show table.cell.where(y: 1): set text(weight: "bold")
  table(
    columns: n,
    //! 行轨道：首行=续表标记行（首页空、自动塌缩 0 高），其后 m 行 1.8em
    rows: (auto,) + (1.8em,) * m,
    //! 表头行（网格 y=1）下边线 0.75pt（REF 实测 0.72）；
    //! 末数据行（y=m）底边 1.5pt 即表底线——作为表格外边界，
    //! 分页时自动复制到每个片段底部（REF 实测：跨页片段末行后有尾线）
    stroke: (_, y) => {
      if y == 1 {
        return (bottom: 0.75pt)
      }
      if y == m {
        return (bottom: 1.5pt)
      }
    },
    table.header(
      //! 续表标记：宋体小四、右对齐至表格右缘（REF：续页首行、无编号）
      table.cell(
        colspan: n,
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        align: right,
        context if here().page() > tlt-page.get() {
          //! 固定高盒：文字钉在续页行顶（REF 字顶 103.0=文本区顶），
          //! 盒高 15.9 → 顶线距行顶 15.9（REF 15.8）；首页条件不成立、
          //! 无盒，标记行自动塌缩为 0 高
          box(height: 15.9pt, width: 100%, inset: 0pt)[
            #align(right)[
              //! 显式恢复全局 edge：tlt 作用域的单元格居中 edge 不适用此钉顶标记
              #text(
                font: ("Times New Roman", "SimSun"),
                size: zh(-4),
                top-edge: 0.86em,
                bottom-edge: 0.14em,
              )[续表]
            ]
          ]
        },
      ),
      //! 顶线 1.5pt（REF 实测 1.44），位于标记行与表头行之间；
      //! 在 table.header 内，分页后随表头在续页重复
      table.hline(y: 1, stroke: 1.5pt),
      ..t.children.at(0).children,
    ),
    ..t.children.slice(1),
  )
}
