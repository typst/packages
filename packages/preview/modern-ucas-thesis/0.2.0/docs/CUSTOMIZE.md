# modern-ucas-thesis 定制指南

> 本指南详细说明如何配置和使用 modern-ucas-thesis。

---

## 📖 简介

### 模板用途

本项目用于撰写**中国科学院大学研究生学位论文**（硕士/博士），参考《中国科学院大学研究生学位论文撰写规范指导意见（校发学位字〔2022〕40 号）》的格式要求。

### 支持的学位类型

| 学位类型 | 英文标识 | 说明 |
|---------|---------|------|
| 学术型硕士 | `master` | 硕士学位论文（学术型） |
| 专业型硕士 | `master` + `professional` | 硕士学位论文（专业型） |
| 学术型博士 | `doctor` | 博士学位论文（学术型） |
| 专业型博士 | `doctor` + `professional` | 博士学位论文（专业型） |
| 本科生 | `bachelor` | 学士学位论文（开发中） |

## 配置参数

### documentclass 函数参数

`documentclass` 是模板的入口函数，通过闭包机制实现全局配置。所有参数均在 `lib.typ` 中定义。

#### 基础配置参数

| 参数名 | 类型 | 默认值 | 必填 | 所在文件 | 说明 |
|-------|------|--------|------|---------|------|
| `doctype` | string | `"doctor"` | 否 | `lib.typ` | 文档类型：`"bachelor"` \| `"master"` \| `"doctor"` \| `"postdoc"`（注：`"postdoc"` 尚未实现） |
| `degree` | string | `"academic"` | 否 | `lib.typ` | 学位类型：`"academic"`（学术型）\| `"professional"`（专业型） |
| `nl-cover` | boolean | `false` | 否 | `lib.typ` | 是否使用国家图书馆封面（待实现） |
| `twoside` | boolean | `false` | 否 | `lib.typ` | 双面模式，自动插入空白页便于打印 |
| `anonymous` | boolean | `false` | 否 | `lib.typ` | 盲审模式，隐藏个人信息并省略致谢 |
| `fontset` | string | `"mac"` | 否 | `lib.typ` | 预定义字体组：`"windows"` \| `"mac"` \| `"fandol"` \| `"adobe"` |
| `fonts` | dictionary | `(:)` | 否 | `lib.typ` | 自定义字体配置，覆盖 `fontset` 设置 |
| `bibliography` | function | `none` | 否 | `lib.typ` | 参考文献函数，如 `bibliography.with("ref.bib")` |

#### 论文信息参数 (info)

`info` 参数为字典类型，包含论文的所有元信息：

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|-------|------|--------|------|------|
| `title` | array/string | `("基于 Typst 的", "中国科学院大学学位论文")` | 是 | 论文中文题目，支持数组或字符串（用 `\n` 分隔） |
| `title-en` | string | `"UCAS Thesis Template for Typst"` | 是 | 论文英文题目 |
| `author` | string | `"张三"` | 是 | 作者中文姓名 |
| `author-en` | string | `"Zhang San"` | 是 | 作者英文姓名（姓全大写） |
| `grade` | string | `"20XX"` | 是 | 入学年份 |
| `student-id` | string | `"1234567890"` | 是 | 学号 |
| `department` | string | `"某研究所"` | 是 | 培养单位（研究所/学院全称） |
| `department-en` | string | `"XX Institute"` | 是 | 培养单位英文 |
| `major` | string | `"xx 专业"` | 是 | 学科专业全称 |
| `major-en` | string | `"xx major"` | 是 | 学科专业英文 |
| `category` | string | `"学科门类或专业学位类别"` | 是 | 学位类别（如：工学博士） |
| `category-en` | string | `"XX category"` | 是 | 学位类别英文 |
| `supervisor` | array | `("李四", "教授")` | 是 | 第一导师（姓名, 职称），用于摘要页显示 |
| `supervisors` | array | `("李四 教授", "王五 研究员")` | 是 | 导师列表（用于封面显示，可包含多位导师） |
| `supervisor-en` | string | `"Professor Li Si"` | 是 | 第一导师英文 |
| `supervisors-en` | array | `("Professor Si Li", ...)` | 是 | 导师列表英文 |
| `supervisor-ii` | array | `()` | 否 | 第二导师（姓名, 职称） |
| `supervisor-ii-en` | string | `""` | 否 | 第二导师英文 |
| `submit-date` | datetime | `datetime.today()` | 是 | 论文提交日期 |
| `defend-date` | datetime | `datetime.today()` | 否 | 答辩日期 |
| `confer-date` | datetime | `datetime.today()` | 否 | 学位授予日期 |
| `bottom-date` | datetime | `datetime.today()` | 否 | 封面底部日期 |
| `chairman` | string | `"某某某 教授"` | 否 | 答辩委员会主席 |
| `reviewer` | array | `("某某某 教授", ...)` | 否 | 答辩委员会成员列表 |
| `clc` | string | `"O643.12"` | 否 | 中图分类号 |
| `udc` | string | `"544.4"` | 否 | UDC 分类号 |
| `secret-level` | string | `"公开"` | 否 | 密级（公开/内部/秘密/机密） |
| `supervisor-contact` | string | - | 否 | 导师联系方式 |
| `email` | string | - | 否 | 作者邮箱 |
| `school-code` | string | `"14430"` | 否 | 学校代码（中国科学院大学代码为 14430） |
| `degree` | string/auto | `auto` | 否 | 学位名称（`auto` 自动根据 `doctype` 生成） |
| `degree-en` | string/auto | `auto` | 否 | 学位名称英文（`auto` 自动根据 `doctype` 生成） |

### 字体配置详解

#### 预定义字体组 (`fontset`)

| 字体组 | 宋体 | 黑体 | 楷体 | 仿宋 | 使用场景 |
|-------|------|------|------|------|---------|
| `windows` | SimSun | SimHei | KaiTi | FangSong | Windows 系统 |
| `mac` | Songti SC | Heiti SC | Kaiti SC | STFangSong | macOS 系统 |
| `fandol` | FandolSong | FandolHei | FandolKai | FandolFang | 跨平台自由字体 |
| `adobe` | Adobe Song Std | Adobe Heiti Std | Adobe Kaiti Std | Adobe Fangsong Std | Adobe 字体 |

#### 等宽字体配置

```typst
#let 等宽字体 = (
  "DejaVu Sans Mono",
  "Courier New", "Courier",
  "SF Mono", "Monaco", "Menlo",
  "IBM Plex Mono",
  "Source Han Sans HW SC",
  "Noto Sans Mono CJK SC",
  "SimHei", "Heiti SC", "STHeiti",
)
```

#### 自定义字体 (`fonts`)

通过 `fonts` 参数可覆盖或补充预定义字体：

```typst
#let (..., doc) = documentclass(
  fontset: "mac",
  fonts: (
    宋体: ("Times New Roman", "Source Han Serif SC"),
    黑体: ("Times New Roman", "Source Han Sans SC"),
    等宽: ("JetBrains Mono", "思源黑体"),
  ),
  ...
)
```

支持的字体键名：

- `宋体`: 正文主要字体
- `黑体`: 标题字体
- `楷体`: 摘要等部分字体
- `仿宋`: 可选字体
- `等宽`: 代码块字体

---

## 分部分配置指南

### 1. 封面 (Cover)

#### 功能说明

封面页根据 `doctype` 自动分发到不同的实现函数：

- 硕士/博士：`master-cover` (文件: `pages/master-cover.typ`)
- 本科：`bachelor-cover` (文件: `pages/bachelor-cover.typ`)

#### 调用方式

```typst
#cover()
```

#### 封面配置参数

位于 `pages/master-cover.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `stroke-width` | length | `0.5pt` | 信息区域下划线宽度 |
| `min-title-lines` | int | `2` | 标题最小行数（自动填充） |
| `min-supervisor-lines` | int | `2` | 导师区域最小行数 |
| `min-reviewer-lines` | int | `5` | 评审人区域最小行数 |
| `info-inset` | dictionary | `(x: 0pt, bottom: 0.5pt)` | 信息区域内边距 |
| `info-key-width` | length | `70pt` | 信息标签宽度 |
| `info-column-gutter` | length | `6pt` | 信息列间距 |
| `info-row-gutter` | length | `1.2em` | 信息行间距（约2倍行距） |
| `meta-block-inset` | dictionary | `(left: -15pt)` | 元数据块的内边距 |
| `meta-info-inset` | dictionary | `(x: 0pt, bottom: 2pt)` | 元信息区域内边距 |
| `meta-info-key-width` | length | `35pt` | 元信息标签宽度 |
| `meta-info-column-gutter` | length | `10pt` | 元信息列间距 |
| `meta-info-row-gutter` | length | `1pt` | 元信息行间距 |
| `defence-info-inset` | dictionary | `(x: 0pt, bottom: 0pt)` | 答辩信息区域内边距 |
| `defence-info-key-width` | length | `110pt` | 答辩信息标签宽度 |
| `defence-info-column-gutter` | length | `2pt` | 答辩信息列间距 |
| `defence-info-row-gutter` | length | `12pt` | 答辩信息行间距 |
| `anonymous-info-keys` | array | 见代码 | 盲审模式下需隐藏的字段 |

#### 封面内容配置

封面信息通过 `info` 参数在 `documentclass` 中配置，包括：

| 显示项 | 对应 info 键 |
|-------|-------------|
| 论文题目 | `title` |
| 作者姓名 | `author` |
| 指导教师 | `supervisors` |
| 学位类别 | `category` |
| 学科专业 | `major` / `degree` + `major`（专业型） |
| 培养单位 | `department` |
| 提交日期 | `submit-date` |

#### 专业型学位封面差异

当 `degree: "professional"` 时：

- 学位类别字段显示为：专业学位类别（领域）
- 格式为：`学位名称（学科专业）`

#### 盲审模式下的封面

当 `anonymous: true` 时，以下字段显示为黑块：

- `student-id`, `author`, `author-en`
- `supervisors`, `supervisors-en`
- `supervisor-ii`, `supervisor-ii-en`
- `chairman`, `reviewer`
- `department`

---

### 2. 原创性声明 (Declaration)

#### 功能说明

- 硕士/博士使用 `master-decl-page` (文件: `pages/master-decl-page.typ`)
- 本科使用 `bachelor-decl-page` (文件: `pages/bachelor-decl-page.typ`)
- 盲审模式下自动跳过（`anonymous: true`）

#### 调用方式

```typst
#decl-page()
```

#### 声明页配置

声明页内容固定，包含：

1. 原创性声明（作者签名 + 日期）
2. 授权使用声明（作者签名 + 导师签名 + 日期）

> **注意**：声明页需要打印后手写签名，再扫描插入 PDF。

---

### 3. 摘要 (Abstract)

#### 功能说明

| 函数 | 用途 | 文件位置 |
|------|------|---------|
| `abstract` | 中文摘要 | `pages/master-abstract.typ` / `pages/bachelor-abstract.typ` |
| `abstract-en` | 英文摘要 | `pages/master-abstract-en.typ` / `pages/bachelor-abstract-en.typ` |

#### 调用方式

```typst
// 中文摘要
#abstract(
  keywords: ("关键词1", "关键词2", "关键词3")
)[
  摘要正文内容...
]

// 英文摘要
#abstract-en(
  keywords: ("keyword1", "keyword2", "keyword3")
)[
  Abstract content...
]
```

#### 摘要配置参数

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `keywords` | array | `()` | 关键词列表（3-5 个） |
| `outline-title` | content | `[摘#h(1em)要]` / `"Abstract"` | 目录中显示的标题 |
| `outlined` | boolean | `true` | 是否加入目录 |
| `title-above` | length | `24pt` | 标题上方间距 |
| `title-below` | length | `18pt` | 标题下方间距 |
| `abstract-title-weight` | string | `"regular"` | 标题字重 |
| `stroke-width` | length | `0.5pt` | 下划线宽度 |
| `info-value-align` | alignment | `center` | 信息值对齐方式 |
| `info-inset` | dictionary | `(x: 0pt, bottom: 0pt)` | 信息区域内边距 |
| `info-key-width` | length | `74pt` | 信息标签宽度 |
| `grid-inset` | length | `0pt` | 网格内边距 |
| `column-gutter` | length | `0pt` | 列间距 |
| `row-gutter` | length | `10pt` | 行间距 |
| `leading` | length | `1.25em` | 行距 |
| `spacing` | length | `1.25em` | 段间距 |

#### 盲审模式

当 `anonymous: true` 时，以下字段会被隐藏（显示为黑块）：

- 中文摘要：`author`, `grade`, `supervisor`, `supervisor-ii`
- 英文摘要：`author-en`, `supervisor-en`, `supervisor-ii-en`

---

### 4. 目录 (Table of Contents)

#### 功能说明

自动生成论文目录，支持最多四级标题。

#### 调用方式

```typst
#outline-page()
```

#### 目录配置参数

位于 `pages/outline-page.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `depth` | int | `4` | 目录深度（最多显示几级标题）。注意：根据规范要求，正文章节题名最多编到第三级标题（1.1.1），建议设置为 `3` |
| `title` | content | `[目#h(1em)录]` | 目录标题 |
| `outlined` | boolean | `false` | 目录自身是否加入目录 |
| `title-above` | length | `24pt` | 标题上方间距 |
| `title-below` | length | `18pt` | 标题下方间距 |
| `title-text-args` | dictionary | `auto` | 标题文本参数 |
| `reference-font` | font | `auto` | 页码字体 |
| `reference-size` | length | `字号.小四` | 页码字号 |
| `font` | font/list | `auto` | 条目字体 |
| `size` | array | `(字号.四号, 字号.小四)` | 各级条目字号 |
| `above` | array | `(6pt, 6pt)` | 各级条目上方间距 |
| `below` | array | `(0pt, 0pt)` | 各级条目下方间距 |
| `indent` | array | `(0pt, 18pt, 28pt)` | 各级条目缩进 |
| `fill` | content | `([.])` | 引导符样式 |
| `gap` | length | `.3em` | 条目与页码间距 |

#### 目录规范要求

根据《指导意见》：

- 目录不包括中英文摘要，包括论文正文中的全部内容的标题
- 正文章节题名最多编到第三级标题（1.1.1）
- 一级标题顶格书写，二级缩进一个汉字符，三级缩进两个汉字符

---

### 5. 图表目录 (List of Figures and Tables)

#### 功能说明

分别生成图目录和表目录，置于目录页之后。

#### 调用方式

```typst
#list-of-figures-and-tables()
```

#### 图表目录配置参数

位于 `pages/list-of-figures-and-tables.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `fig-title` | string | `"图目录"` | 图目录标题 |
| `tbl-title` | string | `"表目录"` | 表目录标题 |
| `outlined` | boolean | `false` | 是否加入目录 |
| `title-above` | length | `24pt` | 标题上方间距 |
| `title-below` | length | `18pt` | 标题下方间距 |
| `title-text-args` | dictionary | `auto` | 标题文本参数 |
| `font` | font | `auto` | 字体 |
| `size` | length | `字号.四号` | 字号 |
| `above` | length | `14pt` | 条目上方间距 |
| `below` | length | `14pt` | 条目下方间距 |

---

### 6. 符号列表 (Notation)

#### 功能说明

用于列出论文中使用的符号、缩略词、计量单位等。

#### 调用方式

```typst
#notation()[

  == 字符
  
  #table(
    columns: (1fr, auto, auto),
    table.header([*符号*][*说明*][*单位*]),
    [$R$], [气体常数], [$m^2 dot s^(-2) dot K^(-1)$],
  )
  
  == 算子
  
  #table(...)
  
  == 缩写
  
  #table(...)
]
```

#### 符号列表配置参数

位于 `pages/notation.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `title` | string | `"符号列表"` | 页面标题 |
| `outlined` | boolean | `false` | 是否加入目录 |
| `title-above` | length | `24pt` | 标题上方间距 |
| `title-below` | length | `18pt` | 标题下方间距 |
| `title-text-args` | dictionary | `auto` | 标题文本参数 |
| `font` | font | `auto` | 字体 |
| `size` | length | `字号.小四` | 字号 |

---

### 7. 正文 (Main Matter)

#### 功能说明

正文部分设置，包括章节编号、字体样式、页眉页脚等。

#### 调用方式

```typst
#show: mainmatter

= 绪论<chap:introduction>

== 研究背景

正文内容...
```

#### 正文配置参数

位于 `layouts/mainmatter.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `leading` | length | `1.25em` | 行距（1.25 倍行距） |
| `spacing` | length | `1.25em` | 段间距 |
| `justify` | boolean | `true` | 两端对齐 |
| `first-line-indent` | dictionary | `(amount: 2em, all: true)` | 首行缩进 |
| `numbering` | function | `custom-numbering` | 章节编号格式 |
| `text-args` | dictionary | `auto` | 正文文本参数 |
| `top-edge` | string | `"cap-height"` | 文字上边缘 |
| `bottom-edge` | string | `"baseline"` | 文字下边缘 |
| `display-header` | boolean | `true` | 是否显示页眉 |
| `header-vspace` | length | `0em` | 页眉垂直间距 |
| `skip-on-first-level` | boolean | `true` | 是否跳过一级标题页眉 |
| `stroke-width` | length | `0.8pt` | 页眉分隔线宽度 |
| `reset-footnote` | boolean | `true` | 是否重置脚注计数器 |
| `separator` | string | `"  "` | 图表标题分隔符 |
| `caption-style` | function | `strong` | 图表标题样式 |
| `caption-size` | length | `字号.五号` | 图表标题字号 |
| `show-figure` | function | `i-figured.show-figure` | 图编号函数 |
| `show-equation` | function | `i-figured.show-equation` | 公式编号函数 |

#### 标题样式配置

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `heading-font` | array | `(fonts.黑体,)` | 标题字体 |
| `heading-size` | array | `(字号.四号, 字号.小四, 字号.小四, 字号.小四)` | 各级标题字号 |
| `heading-weight` | array | `("bold", "regular", "regular", "regular")` | 各级标题字重 |
| `heading-above` | array | `(24pt, 24pt, 12pt, 12pt)` | 标题上方间距（规范值，实际为规范值+行距） |
| `heading-below` | array | `(6pt, 6pt, 6pt, 6pt)` | 标题下方间距（规范值，实际为规范值+行距） |
| `heading-pagebreak` | array | `(true, false)` | 是否自动换页（`true`表示该级别标题前自动换页，索引0对应一级标题，以此类推） |
| `heading-align` | array | `(center, auto)` | 标题对齐方式 |

#### 标题段前段后间距计算逻辑

标题的段前段后间距采用**动态计算**方式，实际渲染时会在导入的规范值基础上自动加上当前级别的单倍行距：

```
实际段前间距 = heading-above + 当前级别字体大小（单倍行距）
实际段后间距 = heading-below + 当前级别字体大小（单倍行距）
```

**各级标题实际间距：**

| 级别 | 字体大小 | 规范段前 | 规范段后 | 实际段前 | 实际段后 |
|------|---------|---------|---------|---------|---------|
| 一级标题 | 14pt | 24pt | 6pt | 38pt | 20pt |
| 二级标题 | 12pt | 24pt | 6pt | 36pt | 18pt |
| 三级标题 | 12pt | 12pt | 6pt | 24pt | 18pt |
| 四级标题 | 12pt | 12pt | 6pt | 24pt | 18pt |

#### 章节编号格式

默认使用 `custom-numbering` 函数（文件: `utils/custom-numbering.typ`）：

- 一级标题：`第1章`
- 二级标题：`1.1`
- 三级标题：`1.1.1`

#### 页眉设置

- **奇数页**：显示当前章标题（如"第1章 绪论"）
- **偶数页**：显示论文题目
- **字体**：宋体小五号
- **分隔线**：0.8pt 黑色实线

#### 防止自动换页

在某些情况下（如参考文献、致谢后），不希望标题自动换页，可以使用标签：

```typst
= 致谢 <no-auto-pagebreak>
```

---

### 8. 图表配置 (Figures & Tables)

#### 图表编号

使用 `i-figured` 包实现分章编号：

- 图：`图 1-1`、`图 1-2` ...
- 表：`表 1-1`、`表 1-2` ...

#### 图表引用

```typst
// 引用图
@fig:label-name

// 引用表
@tbl:label-name
```

#### 图的配置

```typst
#figure(
  image("path/to/image.svg", width: 60%),
  caption: [图题说明],
) <fig:label-name>
```

规范要求：

- 图应具有"自明性"
- 图题置于图下居中
- 图序与图题间空一格
- 建议使用中英文双语图题

#### 表的配置

```typst
#figure(
  table(
    columns: 3,
    table.header([列1], [列2], [列3]),
    [数据1], [数据2], [数据3],
  ),
  caption: [表题说明],
) <tbl:label-name>
```

规范要求：

- 使用"三线表"格式（顶线、栏目线、底线）
- 表题置于表上居中
- 表序与表题间空一格
- 表内同一栏数字上下对齐

#### caption 配置

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `separator` | string | `"  "` | 编号与标题间的分隔符 |
| `caption-style` | function | `strong` | 标题样式 |
| `caption-size` | length | `字号.五号` | 标题字号 |

---

### 9. 公式配置 (Equations)

#### 公式编号

使用 `i-figured` 包实现分章编号：

- 格式：`(1.1)`、`(1.2)` ...

#### 公式引用

```typst
// 带编号的行间公式
$ phi := (1 + sqrt(5)) / 2 $ <eqt:golden-ratio>

// 引用公式
根据 @eqt:golden-ratio，我们有...

// 不带编号的行间公式
$ y = integral_1^2 x^2 dif x $ <->
```

---

### 10. 参考文献 (References)

#### 功能说明

支持 GB/T 7714-2015 格式，提供双语参考文献支持。

#### 调用方式

```typst
// 在 documentclass 中配置
#let (..., bilingual-bibliography) = documentclass(
  bibliography: bibliography.with("ref.bib"),
  ...
)

// 在论文末尾调用
#bilingual-bibliography(full: true)
```

#### 参考文献配置参数

位于 `utils/bilingual-bibliography.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `bibliography` | function | `none` | 参考文献函数（必需） |
| `title` | string | `"参考文献"` | 标题 |
| `full` | boolean | `false` | 是否显示所有条目 |
| `style` | string | `"gb-7714-2015-numeric"` | 引用样式 |
| `mapping` | dictionary | `(:)` | 额外词汇映射 |
| `extra-comma-before-et-al-trans` | boolean | `false` | 译者数量 >1 时是否加逗号 |
| `allow-comma-in-name` | boolean | `false` | 姓名中是否允许逗号 |

#### 支持的引用样式

- `gb-7714-2015-numeric`：顺序编码制（默认）
- `gb-7714-2015-author-date`：著者-出版年制

#### BibTeX 示例

```bibtex
@article{key,
  author  = {作者姓名},
  title   = {文章标题},
  journal = {期刊名称},
  year    = {2023},
  volume  = {1},
  number  = {1},
  pages   = {1--10},
}

@book{key2,
  author    = {作者姓名},
  title     = {书名},
  publisher = {出版社},
  year      = {2023},
  address   = {出版地},
}
```

---

### 11. 附录 (Appendix)

#### 功能说明

附录部分设置，重置计数器并使用不同编号格式。

#### 调用方式

```typst
#show: appendix

= 附录标题

附录内容...
```

#### 附录配置参数

位于 `layouts/appendix.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `numbering` | function | `custom-numbering` | 章节编号格式 |
| `show-figure` | function | `i-figured.show-figure` | 图编号格式 |
| `show-equation` | function | `i-figured.show-equation` | 公式编号格式 |
| `reset-counter` | boolean | `false` | 是否重置章节计数器 |

默认编号格式：

- 附录章节：`A`、`B`、`C` ...
- 附录图：`图 A-1`、`图 A-2` ...
- 附录表：`表 A-1`、`表 A-2` ...
- 附录公式：`(A.1)`、`(A.2)` ...

---

### 12. 致谢 (Acknowledgements)

#### 功能说明

致谢页面，盲审模式下自动隐藏。

#### 调用方式

```typst
#acknowledgement[
  感谢导师的悉心指导...
  
  感谢家人的支持...
]
```

#### 致谢配置参数

位于 `pages/acknowledgement.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `anonymous` | boolean | `false` | 盲审模式（自动跳过） |
| `twoside` | boolean | `false` | 双面模式 |
| `title` | content | `[致#h(1em)谢]` | 标题 |
| `outlined` | boolean | `true` | 是否加入目录 |
| `title-above` | length | `24pt` | 标题上方间距 |
| `title-below` | length | `18pt` | 标题下方间距 |
| `title-text-args` | dictionary | `auto` | 标题文本参数 |
| `body` | content | 必需 | 致谢内容 |

---

### 13. 作者简历 (Backmatter)

#### 功能说明

作者简历及攻读学位期间发表的学术论文与其他相关学术成果。

#### 调用方式

```typst
#backmatter[
  == 作者简历
  
  ××××年××月——××××年××月，在××大学××院（系）获得学士学位。
  
  ××××年××月——××××年××月，在××大学××院（系）获得硕士学位。
  
  == 已发表的学术论文
  
  (1) 论文1
  
  (2) 论文2
  
  == 申请或已获得的专利
  
  (1) 专利1
  
  == 参加的研究项目及获奖情况
  
  (1) 项目1
]
```

#### 作者简历配置参数

位于 `pages/backmatter.typ`：

| 参数名 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `anonymous` | boolean | `false` | 盲审模式（自动跳过） |
| `twoside` | boolean | `false` | 双面模式 |
| `title` | content | `[作者简历及攻读学位期间发表的学术论文与其他相关学术成果]` | 标题 |
| `outlined` | boolean | `true` | 是否加入目录 |
| `title-above` | length | `24pt` | 标题上方间距 |
| `title-below` | length | `18pt` | 标题下方间距 |
| `title-text-args` | dictionary | `auto` | 标题文本参数 |
| `body` | content | 必需 | 简历内容 |

---

## 样式定制

### 页面设置

位于 `layouts/doc.typ`：

| 参数名 | 默认值 | 说明 |
|-------|--------|------|
| `margin` | `(top: 2.54cm, bottom: 2.54cm, left: 3.17cm, right: 3.17cm)` | 页边距 |
| `header-ascent` | `1.5cm` | 页眉高度 + 页眉与正文间距 |
| `footer-descent` | `1.5cm` | 正文与页脚间距 |

### 字号定义

位于 `utils/style.typ`：

| 名称 | 大小 | 用途 |
|------|------|------|
| `初号` | 42pt | 特大标题 |
| `小初` | 36pt | 大标题 |
| `一号` | 26pt | 一级标题（封面"学位论文"） |
| `小一` | 24pt | - |
| `二号` | 22pt | - |
| `小二` | 18pt | - |
| `三号` | 16pt | - |
| `小三` | 15pt | - |
| `四号` | 14pt | 一级标题、摘要标题 |
| `中四` | 13pt | - |
| `小四` | 12pt | 正文、二级及以下标题 |
| `五号` | 10.5pt | 图表标题 |
| `小五` | 9pt | 页眉、脚注 |
| `六号` | 7.5pt | - |
| `小六` | 6.5pt | - |
| `七号` | 5.5pt | - |
| `小七` | 5pt | - |

### 实际使用字号

| 内容 | 字号 | 说明 |
|------|------|------|
| 正文 | `字号.小四` (12pt) | 宋体 |
| 一级标题 | `字号.四号` (14pt) | 黑体加粗，居中 |
| 二级标题 | `字号.小四` (12pt) | 黑体 |
| 三级标题 | `字号.小四` (12pt) | 黑体 |
| 四级标题 | `字号.小四` (12pt) | 黑体 |
| 图表标题 | `字号.五号` (10.5pt) | 宋体加粗 |
| 页眉 | `字号.小五` (9pt) | 宋体 |

### 颜色配置

模板默认使用黑色文字。如需自定义颜色，可在文档中覆盖：

```typst
#set text(fill: rgb("#333333"))  // 深灰色正文
```

## 注意事项

### 1. 字体依赖

- **Windows 用户**：使用 `fontset: "windows"`，确保安装了 SimSun、SimHei、KaiTi、FangSong
- **macOS 用户**：使用 `fontset: "mac"`，系统自带所需字体
- **跨平台需求**：使用 `fontset: "fandol"`，无需安装额外字体
- **Adobe 字体**：使用 `fontset: "adobe"`，需安装 Adobe 中文字体

### 2. 双面印刷设置

```typst
#let (..., doc) = documentclass(
  twoside: true,  // 启用双面模式
  ...
)
```

双面模式特点：

- 自动插入空白页，确保章节从奇数页（右页）开始
- 中文摘要、英文摘要、目录等部分后自动换页到奇数页
- 适合双面打印装订

### 3. 盲审模式

```typst
#let (..., doc) = documentclass(
  anonymous: true,  // 启用盲审模式
  ...
)
```

盲审模式特点：

- 封面个人信息替换为黑块
- 摘要页作者信息隐藏
- 声明页、致谢页、作者简历自动省略

### 4. 修改配置后重新编译

修改 `documentclass` 参数后，需要重新编译才能生效：

```bash
typst compile template/thesis.typ
```

---

## 更新记录

### 2026-03-13（本次检查更新）

**检查依据**：对照《中国科学院大学研究生学位论文撰写规范指导意见（校发学位字〔2022〕40 号）》及实际代码进行审核

**修复内容**：
1. 修正 `doctype` 参数说明，标注 `"postdoc"` 尚未实现
2. 补充封面参数表格中缺失的参数：`meta-block-inset`, `meta-info-column-gutter`, `meta-info-row-gutter`, `defence-info-inset`, `defence-info-key-width`, `defence-info-column-gutter`, `defence-info-row-gutter`
3. 补充致谢页参数：`title-above`, `title-below`, `title-text-args`
4. 补充作者简历页参数：`title-above`, `title-below`, `title-text-args`
5. 更新目录深度参数 `depth` 的说明，建议根据规范设置为 `3`

**检查文件**：
- `lib.typ` - 主入口配置
- `pages/master-cover.typ` - 封面页配置
- `pages/master-abstract.typ` / `master-abstract-en.typ` - 摘要页配置
- `pages/outline-page.typ` - 目录配置
- `pages/acknowledgement.typ` - 致谢页配置
- `pages/backmatter.typ` - 作者简历配置
- `layouts/mainmatter.typ` - 正文配置
- `layouts/appendix.typ` - 附录配置

### 2026-03-13

**检查依据**：对照《中国科学院大学研究生学位论文撰写规范指导意见（校发学位字〔2022〕40 号）》及实际代码进行审核

**修复内容**：
1. 修正 `supervisor` 和 `supervisors` 参数说明，明确区分用途
2. 修正 `degree` 和 `degree-en` 必填标注（应为选填）
3. 补充 `school-code` 参数说明（默认值为中国科学院大学代码 14430）
4. 修正封面参数 `info-column-gutter` 值：`18pt` → `6pt`
5. 修正封面参数 `info-row-gutter` 值：`12pt` → `1.2em`
6. 修正摘要参数：`row-gutter` 拆分为 `grid-inset`、`column-gutter`、`row-gutter`，并修正 `leading`/`spacing` 值为 `1.25em`
7. 修正目录规范描述，明确「目录不包括中英文摘要」
8. 补充 `heading-pagebreak` 参数说明，解释数组用法

**参考规范章节**：
- 第494-508行：排版与印刷要求
- 第313-357行：论文组成部分及要求
- 第418-443行：页码、页眉、章节编号规范
