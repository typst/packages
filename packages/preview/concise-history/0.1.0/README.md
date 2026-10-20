# A Chinese Humanities Book Template Inspired by A Concise World History-仿《简明世界史》效果中文文科书籍模板（Concise History）


本模板为 Typst 设计，专用于排版中文书籍（尤其适合文史哲类著作），内置符合传统出版规范的版面风格，包含自动封面、目录、页眉、脚注、图表题注、着重号等功能。模板提供 A4 和 A5 两种开本预设，所有样式均可通过字典灵活覆盖。

This template is designed for Typst and is tailored for typesetting *Chinese* books (especially suitable for works in literature, history, and philosophy). It incorporates page layouts that follow traditional publishing conventions, and includes built‑in features such as an automatic title page, table of contents, headers, footnotes, figure and table captions, and emphasis marks. The template offers two preset paper sizes, A4 and A5, and all styles can be flexibly overridden via dictionaries.

## 快速使用

导入模板后，调用 concise-history-book 函数，传入必要的 title、author、publisher、date 等参数，以及 cfg 预设（如 concise-history-a4）。正文中使用等号定义一级标题，双等号定义二级标题，依此类推。

示例参考 example 目录下的排版样例。

## 主要参数说明

concise-history-book 函数的直接参数如下：

| 参数名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| title | 字符串 | 必填 | 书名 |
| subtitle | 字符串或 none | none | 副标题 |
| author | 字符串或数组 | "" | 作者，多人可用数组，如 ("张三", "李四") |
| publisher | 字符串或 none | none | 出版社名称 |
| date | datetime 或 none | datetime.today() | 出版日期，设为 none 则不显示 |
| edition | 整数或 none | none | 版次（如 3 表示第3版） |
| cover | 内容块或 auto | auto | 封面内容；auto 自动生成带四角花纹的封面 |
| dedication | 内容块或 none | none | 题献页内容（如“谨以此书献给……”） |
| toc | 布尔值 | true | 是否生成目录 |
| front-matter-headings | 字符串数组 | ("前言","目录","序言","跋","自序","内容简介","内容提要","本册引言","电子化排版说明") | 识别为前辅文的章标题（一级标题） |
| back-matter-headings | 字符串数组 | ("附录","后记","参考文献","索引","本书引用书目") | 识别为后辅文的章标题（一级标题） |
| cfg | 字典 | (:) | 排版样式配置（详见下文） |
| body | 内容块 | 必填 | 正文内容（使用 = 定义一级标题等） |

提示：前辅文和后辅文的标题会自动归入相应区域，页码编号方式不同（前辅文用罗马数字，正文用阿拉伯数字）。对于两个字的一级前后辅文标题（如“前言”），模板会自动在两字间插入调整字符（默认为全角空格），使排版更均衡。

## 样式配置 (cfg)

cfg 字典的顶层字段及默认值（以 A4 为例）如下。您可以通过覆盖这些字段自定义版面。

### 基础设置

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| paper | 字符串 | "a4" | 纸张规格，可选 "a4" 或 "a5" |
| margin | 字典 | (top:2.5cm, bottom:2.5cm, left:3cm, right:3cm) | 页边距 |
| size | 长度 | 10pt | 正文字号 |
| display-page-numbers | 布尔 | true | 是否显示页码 |
| use-odd-pagebreak | 布尔 | false | 标题是否强制从奇数页开始 |
| lang | 字符串 | "zh" | 语言 |
| force-zh-puct | 布尔 | true | 是否将英文标点自动转成中文标点（如 . 变为 。） |
| hide-list-marker | 布尔 | true | 是否隐藏列表的项目符号/编号 |
| enum_num | numbly 对象 | numbly("{1:一}、", "{2:①}、", …) | 列表编号格式（详见 numbly 文档） |
| headingone-adjust-char | 字符串或 none | "　　"（全角空格） | 两个字的一级标题中间插入的调整字符 |
| outline_depth | 整数 | 3 | 目录显示的标题最大层级 |
| dedication-size-offset | 长度 | 6pt | 题献页文字相对正文字号的增量 |

### 排版细节 (typography)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| main-font | 字体元组 | (("Tinos", covers:"latin-in-cjk"), "Source Han Serif SC") | 正文主字体（西文回退 + 中文） |
| title-font | 字体元组 | (("Ronzino", covers:"latin-in-cjk"), "Source Han Sans SC") | 标题字体 |
| fangsong-font | 字体元组 | (("Tinos", covers:"latin-in-cjk"), "Zhuque Fangsong (technical preview)") | 仿宋字体（用于引文等） |
| header-font | 字体元组 | _fonts.fang | 页眉字体（仿宋） |
| tracking | 长度 | 0.08em | 字符间距 |
| line-spacing | 长度 | 0.7em | 行距（相对于字号） |
| par-spacing | 长度 | 1em | 段落间距 |
| indent | 长度 | 2em | 首行缩进 |
| justify | 布尔 | true | 是否两端对齐 |
| list-spacing | 长度 | 1em | 列表项间距 |
| quote-inset | 长度 | 2em | 引用块左右缩进 |
| header-font-size-factor | 浮点数 | 0.875 | 页眉字号相对于正文字号的比例 |
| display-header | 布尔 | true | 是否显示页眉 |
| header-suffix | 字符串或 none | none | 页眉标题后缀（如 " · "） |
| header-rule-color | 颜色 | black | 分隔线颜色 |
| header-rule-thickness | 长度 | 0.5pt | 分隔线粗细 |
| header-rule-length | 长度或百分比 | 100% | 分隔线长度 |

### 标题样式 (heading)

每个字段均为长度为 6 的数组，依次对应一级至六级标题。

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| font | 字体数组 | (_fonts.hei, …) | 各级标题字体 |
| size | 长度数组 | (16pt,14pt,10pt,10pt,10pt,10pt) | 字号 |
| weight | 字重数组 | ("bold","medium","medium","regular","regular","regular") | 字重 |
| align | 对齐方式数组 | (center,center,left,left,left,left) | 对齐 |
| above | 长度数组 | (2em, …) | 标题前间距 |
| below | 长度数组 | (2em, …) | 标题后间距 |
| pagebreak | 布尔数组 | (true,false,false,false,false,false) | 是否强制分页（一级标题默认分页） |
| header-numbly | 字符串数组 | ("第{1:一}章 ", "第{2:一}节 ", …) | 标题编号格式（用于页眉和目录） |

### 目录样式 (toc)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title-font | 字体 | _fonts.song | 目录标题字体 |
| title-size | 长度 | 14pt | 目录标题字号 |
| title-weight | 字重 | "bold" | 目录标题字重 |
| title-align | 对齐 | center | 目录标题对齐 |
| level1-font | 字体 | _fonts.hei | 一级条目字体 |
| other-font | 字体 | _fonts.song | 其他级别条目字体 |
| entry-size | 长度数组 | (12pt,10pt,10pt) | 各级条目字号（最多三级） |
| vspace | 长度数组 | (2em,1em) | 条目间距（一级间、非一级间） |

### 封面样式 (cover)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title-size | 长度 | 36pt | 书名号字号 |
| subtitle-size | 长度 | 18pt | 副标题字号 |
| author-size | 长度 | 12pt | 作者字号 |
| publisher-size | 长度 | 12pt | 出版社字号 |
| date-size | 长度 | 12pt | 日期字号 |
| edition-size | 长度 | 14pt | 版次字号 |
| ornament-offset | 长度 | -1.5cm | 四角花纹距边角偏移 |
| ornament-size | 长度 | 2cm | 花纹大小 |
| title-gap | 长度 | 1.5em | 书名与副标题间距 |
| subtitle-gap | 长度 | 4em | 副标题与作者间距 |
| author-gap | 长度 | 20em | 作者与出版社间距 |
| publisher-gap | 长度 | 1em | 出版社与日期间距 |
| date-gap | 长度 | 1em | 日期与版次间距 |
| cover-background | 颜色 | rgb("#F4E8D1") | 封面背景色 |
| cover-foreground | 颜色 | rgb("#2C1810") | 封面文字颜色 |
| ornament-collection | 字符串 | "pgfhan" | 花纹素材库（ornamentalyst 包） |
| ornament-index | 整数 | 3 | 花纹编号 |

### 图表题注 (caption)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| separator | 字符串 | "  " | 题注编号与文字间的分隔符 |
| font | 字体 | _fonts.fang | 题注字体（仿宋） |
| numbering | 字符串 | "1 - 1" | 编号格式（章号 - 图号） |
| size | 长度 | 1em | 字号（相对于正文字号） |

### 脚注 (footnote)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| font | 字体 | _fonts.fang | 脚注字体 |
| size | 长度 | 1em | 字号（相对于正文字号） |
| entry_gap | 长度 | 0.6em | 脚注条目间距 |
| numbering | 字符串 | "①" | 脚注编号样式 |

## 纸张预设

模板内置两种预设配置，可直接使用：
- concise-history-a4：A4 纸张，上下边距 2.5cm，左右 3cm，正文字号 10pt。
- concise-history-a5：A5 纸张，上下边距 2.5cm，左右 2cm，其余同 A4。

您也可以直接在 cfg 中设置 paper: "a5" 并覆盖其他参数。

## 特殊功能

- 着重号：
模板内置“着重号”函数，用于在汉字下方添加着重号（圆点），适合强调文本。使用时将需要强调的文字作为参数传入即可。

```typst
#着重号[这是需要强调的文字]
```

- 自定义封面：
通过 cover 参数传入任意内容块即可替换自动生成的封面。

```typst
cover: [
  #align(center)[
    #text(size: 40pt)[我的书]
    #v(2cm)
    #text(size: 20pt)[作者：某某]
  ]
]
```

## 自定义示例（文字描述）

```typst
#import "@preview/concise-history:0.1.0": concise-history-book, concise-history-a4

#let my-cfg = (
  ..concise-history-a4,
  heading: (
    ..concise-history.heading,
    // 一些修改
  )
)

#show: concise-history-book.with(
  title: "世界史",
  author: "历史系",
  date: datetime.today(),
  publisher: "出版社",
  cfg: my-cfg
)
```


## 注意事项

1. 字体依赖：模板预设了西文字体（Tinos、Ronzino）和中文思源宋体/黑体/朱雀仿宋。请确保系统中安装了这些字体，或通过 cfg 替换为本地可用字体。

2. 标点转换：默认开启 force-zh-puct，会将英文标点转成中文标点。若需保留英文标点（如中英文混排代码），可设为 false。

3. 页码编号：前辅文（前言、目录等）使用罗马数字，正文及后记使用阿拉伯数字，自动切换。

4. 标题识别：front-matter-headings 和 back-matter-headings 中的标题字符串必须完全匹配正文中的一级标题文字，才能正确归入相应区域。

5. 依赖包：模板依赖 outrageous、numbly、hydra、i-figured、ornamentalyst 等包。

## 许可 License

- 注意：《简明世界史》出版于 1975 年，首次发表至今已超过50年。作品已进入公有领域。此处仅用来测试模板效果。

- Note: A Concise World History was published in 1975, and more than 50 years have passed since its first publication. The work has entered the public domain. It is used here solely to test the template's effects.

- 模板本身采用 MIT 许可证。

- The template itself is licensed under the MIT License.

## 贡献 Contributions

欢迎提交 Issue 或 Pull Request。如有改进建议或样式定制需求，请随时联系。

Issues and pull requests are welcome. If you have suggestions for improvements or need style customisation, please feel free to get in touch.

## 感谢 Acknowledgements

参考了 songting-book 中的部分实现。

Some implementations reference parts of the songting-book project.
