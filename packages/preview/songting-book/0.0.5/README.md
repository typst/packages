# 松亭书籍排版模板 (SongTing Book Template)

SongTing Book is a Typst template designed for Chinese book layout, supporting multiple paper sizes and providing comprehensive typesetting functionality.

松亭书籍排版模板是一个为中文书籍排版设计的 Typst 模板，支持多种纸型，提供了完整的排版功能, 本模板目前关注在电子设备上阅读的效果，后期会根据需求增加对印刷版的支持。

## 使用方法

### 使用 github clone 安装最新版

```bash
git clone --depth 1 https://github.com/zhinenggongziliaoku/songting-book.git ~/.cache/typst/packages/preview/songting-book/0.0.5
```

### 基本使用

```typst
#import "@preview/songting-book:0.0.5": songting-book

#show: songting-book.with(
  title: "我的书名",
  author: "作者名",
  date: datetime.today(),
  publisher: "出版社名称",
)

= 大标题

这是第一章的内容。

== 小标题

这是第一节的内容。
```

### 示例

参考 [sample](https://github.com/zhinenggongziliaoku/songting-book/tree/main/sample) 目录


## 模板特点

- **多种纸张格式支持**：内置A4、A5和B6三种纸张规格配置
- **中文排版优化**：专为中文内容设计的间距、缩进和标点规则
- **丰富的字体设置**：包括宋体、黑体、楷体、仿宋等中文字体配置
- **专业的章节样式**：自动生成"第一章"、"第一节"等中文章节标题
- **自动目录生成**：支持多级目录，可自定义样式和深度
- **灵活的前言后记处理**：自动区分前言、主体内容和后记等部分
- **智能标点转换**：可自动将英文标点转换为中文标点


## 主要参数说明

### 基本信息参数

| 参数名 | 说明 | 默认值 |
|--------|------|--------|
| title | 书名 | "" |
| subtitle | 副标题 | none |
| author | 作者 | "" |
| publisher | 出版社 | none |
| date | 日期 | 当前日期 (如不需要，通过参数传入none)|
| edition | 版本 | none |
| cover | 封面 | auto (自动生成) |
| dedication | 献辞 | none |
| toc | 是否生成目录 | true |

### 高级配置参数

| 参数名 | 说明 | 默认值 |
|--------|------|--------|
| front-matter-headings | 前言部分标题列表 | ("前言", "目录", "序言", "跋", "自序", "内容简介") |
| back-matter-headings | 后记部分标题列表 | ("附录", "后记", "参考文献", "索引", "本书引用书目") |

# cfg 参数

## 1. 页面基本设置

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| paper | 纸张大小 | "a4" |
| margin | 页边距 | (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm) |
| size | 正文字号 | 12pt |
| display-page-numbers | 是否显示页码 | true |
| use-odd-pagebreak | 是否在奇数页开始新章节 | false |
| lang | 语言设置 | "zh" |
| justify | 是否两端对齐 | true |
| indent | 首行缩进 | 2em |

## 2. 封面设置

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| cover-title-size | 封面标题字号 | 36pt |
| cover-subtitle-size | 封面副标题字号 | 24pt |
| cover-author-size | 封面作者字号 | 18pt |
| cover-publisher-size | 封面出版社字号 | 16pt |
| cover-date-size | 封面日期字号 | 14pt |
| cover-edition-size | 封面版本字号 | 14pt |
| dedication-size-offset | 献辞字号偏移量 | 2pt |

## 3. 目录设置

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| toc-title-font | 目录标题字体 | 字体.宋体 |
| toc-title-size | 目录标题字号 | 16pt |
| toc-title-weight | 目录标题字重 | "bold" |
| toc-title-align | 目录标题对齐方式 | center |
| toc-level1-font | 一级目录项字体 | 字体.黑体 |
| toc-other-font | 其他级别目录项字体 | 字体.宋体 |
| toc-entry-size | 目录项字号(各级) | (14pt, 12pt, 12pt) |
| toc-vspace | 目录项间距 | (2em, 1em) |
| outline_depth | 目录深度 | 3 |

## 4. 标题设置

默认支持六级标题，配置项可以自定义各级标题的样式。

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| heading.font | 标题字体(各级) | (字体.黑体, 字体.黑体, ...) |
| heading.size | 标题字号(各级) | (22pt, 18pt, 16pt, 14pt, 14pt, 14pt) |
| heading.weight | 标题字重(各级) | ("bold", "medium", "medium", "regular", "regular", "regular") |
| heading.align | 标题对齐方式(各级) | (center, center, left, left, left, left) |
| heading.above | 标题上方间距(各级) | (2em, 2em, 2em, 2em, 2em, 2em) |
| heading.below | 标题下方间距(各级) | (2em, 2em, 2em, 2em, 2em, 2em) |
| heading.pagebreak | 各级标题是否强制分页 | (true, false, false, false, false) |
| heading.header-numbly | 标题编号格式 | ("第{1:一}章 ", "第{2:一}节 ", "{3:一} ", "（{4:一}）", "{5:1}", "（{6:1}）") |
| headingone-adjust-char | 两字标题调整字符 | "　　" |

## 5. 图表和脚注设置

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| caption.separator | 图表编号与标题分隔符 | "  " |
| caption.font | 图表标题字体 | 字体.楷体 |
| caption.numbering | 图表编号格式 | "1 - 1" |
| caption.size | 图表标题字号 | 1em |
| footnote.font | 脚注字体 | 字体.楷体 |
| footnote.size | 脚注字号 | 0.8em |

## 6. 字体和排版设置

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| main-font | 正文主字体 | 字体.宋体 |
| title-font | 标题字体 | 字体.黑体 |
| kai-font | 楷体 | 字体.楷体 |
| tracking | 字符间距 | 0.1em |
| line-spacing | 行间距 | 1.5em |
| par-spacing | 段落间距 | 2em |
| enum_num | 列表编号格式 | numbly("{1:一}、", "{2:①}、", "{3:1}、", "{4:I}、", "{5:1}、") |
| force-zh-puct | 是否强制转换为中文标点 | true |

## 7. 页眉页脚设置

| 配置项 | 说明 | 默认值 |
|-------|------|-------|
| header-suffix | 页眉后缀 | none |
| header-rule | 是否显示页眉分隔线 | true |
| display-header | 是否显示页眉 | true |
| header-spacing | 页眉间距 | 0.25em |
| header-font-size-factor | 页眉字号因子 | 0.875 |
| header-font | 页眉字体 | 字体.楷体 |

## 纸张配置

模板支持三种预设纸张格式，可通过`cfg`参数进行指定：

```typst
#songting-book(
  title: "我的书名",
  cfg: songting-a4
)

// 内容...

```

### A4配置特点

- 页边距：上下2.5cm，左右3cm
- 字号：12pt
- 行距：1.5倍行距
- 首行缩进：2em

### A5配置特点

- 适合中小型图书、文集等
- 页边距：上下2.5cm，左右2cm
- 其他设置基本与A4相同

### B6配置特点

- 适合手机、kindle等电子设备阅读
- 页边距：上下1cm，左右0.6cm
- 字号：超大
- 隐藏页码和页眉

## 字体设置

模板预设了几种中文字体族及其回退序列：

- **宋体**：正文主要字体
- **黑体**：标题使用
- **楷体**：引用文字、页眉

## 自定义配置示例

```typst
#import "@preview/songting-book:0.0.4": songting-book, songting-a4

#let songting-a4-no-header-numbly = (
  ..songting-a4,
  heading: (
    ..songting-a4.heading,
    header-numbly: ("", "",""),
  )
)

#show: songting-book.with(
  title: "农民进城 防骗手册",
  author: "马文胜 主编",
  date: datetime.today(),
  publisher: "湖南人民出版社出版",
  cfg: songting-a4-no-header-numbly
)
```

## 特殊功能

### 居中诗歌

使用楷体居中显示：

```typst

> 这是一首诗
#quote(attribution: "poem")[
  床前明月光，
  疑是地上霜。
  举头望明月，
  低头思故乡。
]
```

### 图表标题

图表会自动编号并使用设定的字体显示标题：

```typst
#figure(
  image("path/to/image.png"),
  caption: "这是一张图片"
)
```

### 自定义封面

如果不想使用自动生成的封面，可以提供自定义封面：

```typst
#songting-book(
  title: "我的书",
  author: "作者",
  cover: [
    #align(center)[
      #text(size: 30pt)[我的自定义封面]
      // 其他封面元素...
    ]
  ]
)[
  // 内容...
]
```

## 注意事项

1. 模板默认会自动将英文标点转换为中文标点，对于中英文混排的情况可通过`force-zh-puct: false`关闭
2. 正文中的章节标题会自动使用"第一章"、"第一节"等格式编号
3. 前言和后记部分的标题不会编号
4. 中文排版会自动处理标点符号、行距和缩进等细节

## 常见问题解答

1. **如何调整行间距和段落间距？**
   通过`cfg`参数中的`line-spacing`和`par-spacing`设置

2. **如何修改目录样式？**
   通过`cfg`参数中的`toc-title-font`、`toc-entry-size`等设置

3. **如何调整章节标题样式？**
   通过`cfg`参数中的`heading`设置字体、大小、对齐方式等

4. **如何自定义页眉？**
   通过`cfg`参数中的`display-header`和`header-suffix`设置


## 注意事项

1. 使用此模板需要安装相应的中文字体（windows自带的宋体、黑体、楷体, 以及思源黑体，使用思源黑体是为了标题获得更大的字重）,否则需要通过参数指定(思源宋体、思源黑体等需要自己安装)
    下载地址: https://mirrors.tuna.tsinghua.edu.cn/adobe-fonts/


## 依赖

此模板依赖于 Typst 0.13.1 或更高版本。

## 许可

MIT

## 贡献

欢迎任何形式的贡献，包括但不限于代码、文档、示例等。请提交 Pull Request 或在 Issues 中提出建议。


# Known Issue

* Not working with include
* Style need to be polished
