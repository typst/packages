# 松亭书籍排版模板 (SongTing Book Template)

松亭书籍排版模板是一个为中文书籍排版设计的 Typst 模板，支持多种纸型，提供了完整的排版功能

## 功能特点

- 支持 A4、A5、B6 等多种纸型
- 自动生成封面、目录
- 支持前言、主体内容、后记等结构
- 中文排版优化，支持宋体、黑体、楷体等字体
- 可自定义章节标题样式
- 自动页眉页脚处理
- 可参数配置

## 使用方法

### 基本使用

```typst
#import "@preview/songting-book:0.0.2": songting-book

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

## 配置选项

模板提供了多种配置选项，以下是一些主要参数：

### 基本参数

- `title`: 书名
- `subtitle`: 副标题（可选）
- `author`: 作者
- `publisher`: 出版社（可选）
- `date`: 日期
- `dedication`: 题词（可选）
- `toc`: 是否显示目录（默认为 true）
- `cover`: 封面设置（默认为 auto）

### 纸型配置

支持以下预设纸型：

- `a4`: A4 纸型（默认），近似 16 开
- `a5`: A5 纸型, 进近 32 开
- `b6`: B6 纸型（适合手机、kindle）

### 字体与排版配置

可通过 `cfg` 参数自定义以下设置：

```typst
cfg: (
  paper: "a4",                    // 纸型
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm), // 页边距
  size: 12pt,                     // 正文字号
  main-font: ("SimSun", "Times New Roman"), // 正文字体
  title-font: ("SimHei",),        // 标题字体
  kai-font: ("KaiTi",),           // 楷体（用于引用等）
  line-spacing: 1.5em,            // 行距
  par-spacing: 1.5em,             // 段落间距
  indent: 2em,                    // 首行缩进
  justify: true,                  // 两端对齐
  display-page-numbers: true,     // 显示页码
  display-header: true,           // 显示页眉
)
```

### 章节标题配置

可以自定义章节标题的字体、大小、间距等属性：

```typst
cfg: (
  heading: (
    font: ("SimHei", "SimHei", "SimHei", "SimHei", "SimHei"),
    size: (22pt, 16pt, 15pt, 14pt, 14pt),
    weight: ("bold", "regular", "regular", "regular", "regular"),
    align: (center, left, left, left, left),
    above: (2em, 2em, 1.5em, 1.2em, 1em),
    below: (2em, 1.5em, 1.2em, 1em, 0.8em),
    pagebreak: (true, false, false, false, false),
  ),
)
```

## 注意事项

1. 使用此模板需要安装相应的中文字体（windows自带的宋体、黑体、楷体）,否则需要通过参数指定(思源宋体、思源黑体等需要自己安装)
2. 前言、附录等特殊章节会自动识别并使用不同的格式


## 依赖

此模板依赖于 Typst 0.13.1 或更高版本。

## 许可

MIT

## 示例

Check sample


# Known Issue

* Not working with include
* Style need to be polished
