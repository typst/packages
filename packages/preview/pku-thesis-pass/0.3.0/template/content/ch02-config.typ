#import "@preview/pku-thesis-pass:0.3.0": booktab, eq-block

本模板提供了丰富的配置选项，在 `config()` 函数中以命名参数的方式传入。下面详细介绍各个配置项的含义和用法。

== 基本信息

#booktab(
  width: 100%,
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  caption: "基本信息配置项",
  [*参数名*],
  [*系统默认值*],
  [*说明*],
  [`author-zh`],
  [`"张三"`],
  [作者中文姓名],
  [`author-en`],
  [`"San Zhang"`],
  [作者英文姓名],
  [`student-id`],
  [`"23000xxxxx"`],
  [学号（非盲审封面显示）],
  [`blind-id`],
  [`"L2023XXXXX"`],
  [盲审编号（盲审封面显示）],
  [`thesis-name`],
  [`"博士研究生学位论文"`],
  [论文类型名称],
  [`header-text`],
  [`"北京大学博士学位论文"`],
  [页眉文本（偶数页显示）],
  [`title-zh`],
  [--],
  [论文中文标题，可用 `\n` 控制换行；盲审模式下 `\n` 会被忽略],
  [`title-en`],
  [--],
  [论文英文标题，可用 `\n` 控制换行；盲审模式下 `\n` 会被忽略],
  [`school`],
  [`"某个院系"`],
  [院系名称],
  [`first-major`],
  [`"某个一级学科"`],
  [一级学科名称],
  [`major-zh`],
  [`"某个专业"`],
  [专业中文名称],
  [`major-en`],
  [`"Some Major"`],
  [专业英文名称],
  [`direction`],
  [`"某个研究方向"`],
  [研究方向],
  [`supervisor-zh`],
  [`"李四"`],
  [导师中文姓名及职称],
  [`supervisor-en`],
  [`"Si Li"`],
  [导师英文姓名],
  [`degree-type`],
  [`"academic"`],
  [学位类型：`"academic"`（学术学位）或 `"professional"`（专业学位）],
  [`year`],
  [`2026`],
  [论文提交年份],
  [`month`],
  [`6`],
  [论文提交月份],
) <config-author>

=== `author-zh`

- #strong[作用]：论文作者的中文姓名，用于非盲审封面及 PDF 文档属性（元数据）的作者字段。
- #strong[可填值]：任意中文字符串。
- #strong[默认值]：`"张三"`。
- #strong[填写示例]：`author-zh: "张三"`
- #strong[注意事项]：盲审模式（`blind: true`）下此值不会写入 PDF 元数据，封面也改显 `blind-id`，以保护作者身份。此值也会在书脊页显示（若启用书脊页），盲审模式下书脊页会自动隐藏作者。

=== `author-en`

- #strong[作用]：论文作者的英文姓名，用于英文摘要页。
- #strong[可填值]：任意英文字符串。
- #strong[默认值]：`"San Zhang"`。
- #strong[填写示例]：`author-en: "San Zhang"`

=== `student-id`

- #strong[作用]：学号，显示在非盲审封面。
- #strong[可填值]：字符串（学号通常为数字与字母）。
- #strong[默认值]：`"23000xxxxx"`。
- #strong[填写示例]：`student-id: "23000xxxxx"`
- #strong[注意事项]：盲审模式（`blind: true`）下自动隐藏，不显示在封面上。

=== `blind-id`

- #strong[作用]：盲审论文编号，显示在盲审封面。
- #strong[可填值]：字符串。
- #strong[默认值]：`"L2023XXXXX"`。
- #strong[填写示例]：`blind-id: "L2023XXXXX"`
- #strong[注意事项]：仅在 `blind: true` 时被使用；非盲审模式下忽略此参数。

=== `thesis-name`

- #strong[作用]：论文类型名称，显示在论文封面。
- #strong[可填值]：字符串，如 `"博士研究生学位论文"` 或 `"硕士研究生学位论文"`。
- #strong[默认值]：`"博士研究生学位论文"`。
- #strong[填写示例]：`thesis-name: "硕士研究生学位论文"`

=== `header-text`

- #strong[作用]：页眉统一文本（偶数页显示）。
- #strong[可填值]：字符串，如 `"北京大学博士学位论文"` 或 `"北京大学硕士学位论文"`。
- #strong[默认值]：`"北京大学博士学位论文"`。
- #strong[填写示例]：`header-text: "北京大学硕士学位论文"`
- #strong[注意事项]：奇数页页眉自动显示当前章节标题，故此参数主要影响偶数页。

=== `title-zh`

- #strong[作用]：论文中文标题，用于封面、书脊页及 PDF 文档属性标题字段。
- #strong[可填值]：字符串，可用 `\n` 控制非盲审封面的换行点。
- #strong[默认值]：`"北京大学学位论文 Typst 模板"`。
- #strong[填写示例]：`title-zh: "北京大学学位论文 \nTypst 模板使用指南"`
- #strong[注意事项]：盲审封面（`blind: true`）会忽略手工插入的 `\n`，将标题合并为连续显示，避免盲审版排版错位。

=== `title-en`

- #strong[作用]：论文英文标题，用于英文摘要页和盲审封面。
- #strong[可填值]：字符串，可用 `\n` 控制换行。
- #strong[默认值]：`"Typst Template for Peking University Thesis"`。
- #strong[填写示例]：`title-en: "A Guide to Using the Typst Template for \nPeking University Theses"`
- #strong[注意事项]：北大模板无英文封面，故该值仅出现在英文摘要和盲审封面；PDF 标题元数据仍取 `title-zh`。

=== `school`

- #strong[作用]：院系名称，显示于非盲审封面。
- #strong[可填值]：中文字符串。
- #strong[默认值]：`"某个院系"`。
- #strong[填写示例]：`school: "信息科学技术学院"`
- #strong[注意事项]：盲审模式（`blind: true`）下封面不显示院系信息。

=== `first-major`

- #strong[作用]：一级学科名称，显示于封面。
- #strong[可填值]：中文字符串。
- #strong[默认值]：`"某个一级学科"`。
- #strong[填写示例]：`first-major: "计算机科学与技术"`

=== `major-zh`

- #strong[作用]：专业中文名称，显示于封面。
- #strong[可填值]：中文字符串。
- #strong[默认值]：`"某个专业"`。
- #strong[填写示例]：`major-zh: "计算机软件与理论"`

=== `major-en`

- #strong[作用]：专业英文名称，用于英文摘要页。
- #strong[可填值]：英文字符串。
- #strong[默认值]：`"Some Major"`。
- #strong[填写示例]：`major-en: "Computer Software and Theory"`

=== `direction`

- #strong[作用]：研究方向，显示于非盲审封面。
- #strong[可填值]：中文字符串。
- #strong[默认值]：`"某个研究方向"`。
- #strong[填写示例]：`direction: "程序设计语言与编译技术"`

=== `supervisor-zh`

- #strong[作用]：导师中文姓名及职称，显示于非盲审封面。
- #strong[可填值]：中文字符串，可含职称。
- #strong[默认值]：`"李四"`。
- #strong[填写示例]：`supervisor-zh: "李四 教授"`
- #strong[注意事项]：盲审模式（`blind: true`）下保密不显示。

=== `supervisor-en`

- #strong[作用]：导师英文姓名，用于英文摘要页。
- #strong[可填值]：英文字符串。
- #strong[默认值]：`"Si Li"`。
- #strong[填写示例]：`supervisor-en: "Prof. Si Li"`
- #strong[注意事项]：盲审模式（`blind: true`）下保密不显示。

=== `degree-type`

- #strong[作用]：学位类型，决定封面学术学位/专业学位☑打在哪里。
- #strong[可填值]：`"academic"`（学术学位）或 `"professional"`（专业学位）。
- #strong[默认值]：`"academic"`。
- #strong[填写示例]：`degree-type: "professional"`

=== `year`

- #strong[作用]：论文提交年份，显示于封面。
- #strong[可填值]：整数（int）。
- #strong[默认值]：`2026`。
- #strong[填写示例]：`year: 2026`

=== `month`
- #strong[作用]：论文提交月份，显示于封面。
- #strong[可填值]：整数（int），范围 1–12。
- #strong[默认值]：`6`。
- #strong[填写示例]：`month: 6`

== 排版配置

#booktab(
  width: 100%,
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  caption: "排版配置项",
  [*参数名*],
  [*系统默认值*],
  [*说明*],
  [`system`],
  [`"windows"`],
  [字体方案：`"windows"`/`"macos"`/`"linux"`],
  [`blind`],
  [`false`],
  [是否为盲审模式，盲审模式隐藏作者、导师等信息],
  [`preview`],
  [`true`],
  [预览模式，链接文本显示为蓝色；生成打印版时设为 `false`],
  [`first-line-indent`],
  [`2em`],
  [首行缩进，Word 模板为 `1.77em`，本模板默认 `2em`],
  [`always-start-odd`],
  [`true`],
  [章节是否总是从奇数页开始],
  [`clean-declaration`],
  [`false`],
  [原创性声明页是否隐藏页眉页脚],
  [`outline-depth`],
  [`3`],
  [目录显示的最大标题层级],
  [`word-count`],
  [`false`],
  [统计正文与附录字数（CJK 字数 / 总字符数），正文中可用 `#total-words` / `#total-characters` 显示统计结果],
  [`achievement-outlined`],
  [`true`],
  ["攻读学位期间发表的论文"页是否出现在目录中；设为 `false` 时该页不进入目录],
  [`supplements`],
  [`(:)`],
  [自定义引用记号和列表标题。可用字段及默认值：\
    引用前缀：`图`（"图"）、`表`（"表"）、`代码`（"代码"）、`公式`（"式"）、`节`（"节"）；\
    `图表`（"图表"，未知 figure kind 的 fallback）；\
    列表页标题：`插图列表`（"插图"）、`表格列表`（"表格"）、`代码列表`（"代码"）、`公式列表`（"公式"）、`符号表`（"主要符号对照表"）、`成果表`（"攻读学位期间发表的论文"）。\
    示例：`supplements: (图: "Figure", 插图列表: "List of Figures")`],
  [`use-latexref`],
  [`false`],
  [LaTeX 引用兼容：`@fig:xxx` 等带前缀的引用解析失败时，自动剥离前缀后重试 `@xxx`。\
    适合从 LaTeX 迁移的文档（LaTeX 习惯用 `\ref{fig:xxx}`），开启后无需改动原有标签写法。\
    详见 "进阶"一章的 @latexref 小节],
  [`latexref-prefixes`],
  [`("fig:", ..)`],
  [`use-latexref` 为 `true` 时尝试剥离的前缀列表，可按需增删，如 `("图:", "表:")`],
  [`codly-args`],
  [`(:)`],
  [传递给 `codly` 包的额外参数，用于自定义代码块样式。常用选项：\
    `number-format: none`  关闭代码行号；\
    `display-icon: false`  关闭语言图标；\
    `lang-format: none`    关闭语言名称；\
    `zebra-fill: none`     关闭交替背景色],
  [`logo`],
  [`none`],
  [封面校徽图片路径，`path` 类型，如 `path("assets/logo.svg")`；为 `none` 时封面显示灰色占位框],
  [`wordmark`],
  [`none`],
  [封面校名字标图片路径，`path` 类型；为 `none` 时封面显示灰色占位框],
) <config-layout>

=== `system`

- #strong[作用]：系统字体方案，决定中文与西文字体的 fallback 顺序。
- #strong[可填值]：`"windows"` / `"macos"` / `"linux"`。
- #strong[默认值]：`"windows"`。
- #strong[填写示例]：`system: "linux"`
- #strong[注意事项]：可被命令行 `--input system=linux` 覆盖，优先级高于此配置。各方案的字体对照见 README "字体配置" 一节。

=== `blind`

- #strong[作用]：盲审模式开关。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`false`。
- #strong[填写示例]：`blind: false`
- #strong[注意事项]：开启后自动隐藏作者、导师、学号、致谢、"攻读学位期间发表的论文"页及原创性声明，封面替换为盲审版，PDF 元数据隐藏作者。可被命令行编译模式下的 `--input blind=true` 参数覆盖。

=== `preview`

- #strong[作用]：预览模式，链接文本显示为蓝色。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`true`。
- #strong[填写示例]：`preview: true`
- #strong[注意事项]：生成打印版时应设为 `false`（链接不着色）。可被命令行编译模式下的 `--input preview=false` 参数覆盖。

=== `first-line-indent`

- #strong[作用]：正文首行缩进宽度。
- #strong[可填值]：长度值（length），如 `2em`。
- #strong[默认值]：`2em`。
- #strong[填写示例]：`first-line-indent: 1.77em`
- #strong[注意事项]：Word 模板固定为 `1.77em`，如需严格对照 Word，请设为 `1.77em`。

=== `always-start-odd`

- #strong[作用]：章节是否总是从奇数页开始。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`true`。
- #strong[填写示例]：`always-start-odd: false`
- #strong[注意事项]：置 `false` 可减少因奇偶页产生的空白页，适合线上阅读或精简打印。可被命令行编译模式下的 `--input always-start-odd=false` 参数覆盖。

=== `clean-declaration`

- #strong[作用]：原创性声明页是否隐藏页眉和页码。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`false`。
- #strong[填写示例]：`clean-declaration: true`
- #strong[注意事项]：Word 模板的声明页包含页眉与页码，故默认 `false`；若需去除可设为 `true`。

=== `outline-depth`

- #strong[作用]：目录显示的最大标题层级。
- #strong[可填值]：整数（int）。
- #strong[默认值]：`3`。
- #strong[填写示例]：`outline-depth: 3`
- #strong[注意事项]：只显示到三级标题（`===`）时设为 `3`，四级及以上标题不显示在目录里。

=== `word-count`

- #strong[作用]：是否统计正文与附录字数。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`false`。
- #strong[填写示例]：`word-count: true`
- #strong[注意事项]：开启后正文中可用 `#total-words`（CJK 字数）与 `#total-characters`（总字符数）显示统计结果；如不需要可设置 `false` 关闭统计以提升编译速度。

=== `achievement-outlined`

- #strong[作用]："攻读学位期间发表的论文"页是否进入目录。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`true`。
- #strong[填写示例]：`achievement-outlined: false`
- #strong[注意事项]：设为 `false` 时该页仍出现在论文中，但不在目录中列出。盲审模式下成果页不显示，与致谢、原创性声明页行为一致。

=== `supplements`

- #strong[作用]：自定义引用记号和列表页标题。
- #strong[可填值]：字典（dict）。
- #strong[默认值]：`(:)`（使用模板内置默认）。
- #strong[填写示例]：`supplements: (成果表: "攻读学位期间发表的论文")`
- #strong[注意事项]：可覆写的键包括——引用前缀 `图`/`表`/`代码`/`公式`/`节` 及 `图表`（未知 kind 的 fallback）；列表标题 `插图列表`/`表格列表`/`代码列表`/`公式列表`/`符号表`/`成果表`。传入的键会覆盖默认值，未传入的沿用默认。例如：设置 `supplements: (成果表: "攻读学位期间发表的论文")` 可自定义成果表标题，其他列表标题仍使用默认值。

=== `use-latexref`

- #strong[作用]：LaTeX 引用兼容开关。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`false`。
- #strong[填写示例]：`use-latexref: true`
- #strong[注意事项]：开启后，`@fig:xxx` 等带前缀的引用若解析失败，会自动剥离前缀重试 `@xxx`，适配从 LaTeX 迁移的文档（LaTeX 习惯写 `\ref{fig:xxx}`）。详见"进阶"一章的 @latexref 小节。

=== `latexref-prefixes`

- #strong[作用]：`use-latexref` 为 `true` 时尝试剥离的前缀列表。
- #strong[可填值]：字符串数组（array）。
- #strong[默认值]：`("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:")`。
- #strong[填写示例]：`latexref-prefixes: ("图:", "表:")`
- #strong[注意事项]：可按需增删前缀，模板按列表顺序尝试剥离。

=== `codly-args`

- #strong[作用]：传递给 `codly` 包的代码块样式参数。
- #strong[可填值]：字典（dict）。
- #strong[默认值]：`(:)`。
- #strong[常见选项]：
  - `number-format: none`   关闭代码行号
  - `display-icon: false`   关闭语言图标
  - `lang-format: none`     关闭语言名称
  - `zebra-fill: none`      关闭交替斑马条纹背景色
- #strong[填写示例]：`codly-args: (number-format: none, zebra-fill: none)`

=== `logo`

- #strong[作用]：封面校徽图片路径。
- #strong[可填值]：`path` 类型，如 `path("path/to/file")`。
- #strong[默认值]：`none`（封面显示灰色占位框）。
- #strong[填写示例]：`logo: path("assets/pkulogo.pdf")`
- #strong[注意事项]：北大校徽资源取自 CTAN 的 `pkuthss` 包，使用北大校名字标须遵守相关授权规定，详见 README 许可证一节。

=== `wordmark`

- #strong[作用]：封面校名字标图片路径。
- #strong[可填值]：`path` 类型，如 `path("path/to/file")`。
- #strong[默认值]：`none`（封面显示灰色占位框）。
- #strong[填写示例]：`wordmark: path("assets/pku-wordmark.pdf")`
- #strong[注意事项]：同 `logo`，使用北大校名字标须遵守相关授权规定。

== 参考文献

本模板集成了 gb7714-bilingual 包，提供符合 GB/T 7714 标准的参考文献格式，并自动根据文献语言切换中英文术语。

#booktab(
  width: 100%,
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  caption: "参考文献配置项",
  [*参数名*],
  [*系统默认值*],
  [*说明*],
  [`override-bib`],
  [`false`],
  [是否自定义参考文献引用样式。设为 `true` 时忽略下述参数，用户需自行处理参考文献],
  [`bib-file`],
  [`none`],
  [BibTeX 文件路径，`path` 类型，如 `path("ref.bib")`],
  [`bib-style`],
  [`"numeric"`],
  [引用风格：`"numeric"`（顺序编码制）或 `"author-date"`（著者—出版年制）],
  [`bib-version`],
  [`"2015"`],
  [GB/T 7714 标准版本：`"2015"` 或 `"2025"`。GB/T 7714-2025 标准从 2026 年 7 月 1 日开始实施],
  [`bib-cn-first`],
  [`true`],
  [仅 `bib-style: "author-date"`。`true` 时参考文献列表中中文条目排在外文之前；`false` 时外文在前。中文条目按作者姓氏拼音排序],
  [`bib-pinyin-override`],
  [`(:)`],
  [仅 `author-date` 且中文作者。多音字校正字典，如 `("重": "chong2")`],
) <config-bib>

=== `override-bib`

- #strong[作用]：是否完全自定义参考文献样式。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`false`。
- #strong[填写示例]：`override-bib: false`
- #strong[注意事项]：设为 `true` 时忽略下述 `bib-*` 参数，用户需在论文中自行编写 `#bibliography(...)` 或自定义渲染逻辑。

=== `bib-file`

- #strong[作用]：BibTeX 参考文献文件路径。
- #strong[可填值]：`path` 类型，如 `path("path/to/a-bib-file")`。
- #strong[默认值]：`none`。
- #strong[填写示例]：`bib-file: path("ref.bib")`

=== `bib-style`

- #strong[作用]：参考文献引用风格。
- #strong[可填值]：`"numeric"`（顺序编码制）或 `"author-date"`（著者—出版年制）。
- #strong[默认值]：`"numeric"`。
- #strong[填写示例]：`bib-style: "author-date"`
- #strong[注意事项]：`"author-date"` 时正文引用显示作者与年份，`"numeric"` 显示方括号编号。

=== `bib-version`

- #strong[作用]：GB/T 7714 标准版本。
- #strong[可填值]：`"2015"` 或 `"2025"`。
- #strong[默认值]：`"2015"`。
- #strong[填写示例]：`bib-version: "2025"`
- #strong[注意事项]：GB/T 7714-2025 标准从 2026 年 7 月 1 日开始实施，若学校明确要求采用新标准请选 `"2025"`。

=== `bib-cn-first`

- #strong[作用]：（仅 `bib-style: "author-date"`）中文文献是否排在外文之前。
- #strong[可填值]：布尔值（`true` / `false`）。
- #strong[默认值]：`true`。
- #strong[填写示例]：`bib-cn-first: false`
- #strong[注意事项]：`true` 时中文条目在前、外文在后，中文按作者姓氏拼音排序；`false` 时外文在前。

=== `bib-pinyin-override`

- #strong[作用]：（仅 `author-date` 且为中文作者）多音字发音校正字典。
- #strong[可填值]：字典，键为汉字，值为 `tone-num-end` 音节串。
- #strong[默认值]：`(:)`。
- #strong[填写示例]：`bib-pinyin-override: ("重": "chong2")`
- #strong[注意事项]：用于拼音排序时对多音字的读音校正，避免排序错乱。
