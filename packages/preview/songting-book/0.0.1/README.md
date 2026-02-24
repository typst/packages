# SongTing Book Typst 模板使用说明

## 简介

`songting-book` 是一个专为中文书籍排版设计的 Typst 模板，提供了符合中文排版规范的布局和样式。该模板支持各种书籍元素，包括封面、前言、目录、章节、附录等，并针对中文排版特点进行了优化。

自动识别前言主体和附录部分，只用标记也能完成排版。

## 基本用法

```typst
#import "@preview/songting-book:0.0.1": songting-book

#show: songting-book.with(
  title: "我的书名",
  author: "作者名",
  date: datetime(year: 2023, month: 5, day: 1),
)

= 第一章

这是第一章的内容。

== 第一节

这是第一节的内容。
```

## 配置选项

`songting-book` 函数接受以下参数：

### 基本信息

- `title`: 书名 (字符串)
- `subtitle`: 副标题 (可选，字符串)
- `author`: 作者 (字符串)
- `publisher`: 出版社 (可选，字符串)
- `date`: 日期 (默认为当前日期，datetime 类型)
- `edition`: 版本号 (可选，数字)
- `cover`: 封面 (auto 使用默认生成封面，或提供自定义封面内容)
- `dedication`: 题词页 (可选，字符串)
- `toc`: 是否显示目录 (默认为 true)

### 结构配置

- `front-matter-headings`: 前言部分的标题列表 (默认包含 "前言", "目录", "序言", "跋", "自序")
- `back-matter-headings`: 后记部分的标题列表 (默认包含 "附录", "后记", "参考文献", "索引", "本书引用目录")
- `heading-cfg`: 自定义标题配置 (可选，字典)
- `paper-cfg`: 自定义纸张配置 (可选，字典)
- `cfg`: 主配置 (默认为 A4 纸张)

## 详细配置说明

### 纸张和页面设置

默认提供 A4 和 B6(kindle) 两种纸张规格，可通过 `cfg: (paper: "a4")` 或 `cfg: (paper: "iso-b6")` 选择。

每种纸张格式有独立的默认配置：

#### A4 配置
- 页边距: 上下 2.5cm，左右 2cm
- 字体大小: 12pt
- 显示页码: 是
- 章节标题使用较大字号

#### B6 配置
- 页边距: 上下 1.5cm，左右 1cm
- 字体大小: 三号
- 显示页码: 否
- 章节标题使用较小字号

### 字体配置

默认配置使用以下字体：
- 正文字体: SimSun (宋体) 和 Times New Roman
- 标题字体: SimHei (黑体)
- 引用字体: KaiTi (楷体)

可以通过修改 `cfg` 参数自定义字体：

```typst
#show: songting-book.with(
  // ...其他配置
  cfg: (
    main-font: ("FangSong", "Times New Roman"),
    title-font: ("HeiTi",),
    kai-font: ("KaiTi",),
  )
)
```

### 段落与排版配置

默认配置包括：
- 行距: 1em
- 段间距: 1.5em
- 首行缩进: 2em
- 字间距: 0.1em
- 文本对齐: 两端对齐

可以通过 `cfg` 参数修改：

```typst
#show: songting-book.with(
  // ...其他配置
  cfg: (
    tracking: 0.15em,      // 字间距
    line-spacing: 1.2em,   // 行距
    par-spacing: 1em,      // 段间距
    indent: 2.5em,         // 首行缩进
    justify: true,         // 两端对齐
  )
)
```

### 标题配置

可以通过 `heading-cfg` 参数自定义标题样式：

```typst
#show: songting-book.with(
  // ...其他配置
  heading-cfg: (
    font: ("黑体", "黑体", "黑体", "黑体", "黑体"),  // 各级标题字体
    size: (28pt, 22pt, 18pt, 16pt, 14pt),          // 各级标题大小
    align: (center, left, left, left, left),       // 各级标题对齐方式
    above: (2.5em, 2em, 1.5em, 1.2em, 1em),        // 标题上方间距
    below: (2em, 1.5em, 1.2em, 1em, 0.8em),        // 标题下方间距
    pagebreak: (true, false, false, false, false), // 各级标题是否另起一页
  )
)
```

### 目录配置

可以通过 `cfg` 参数控制目录深度和样式：

```typst
#show: songting-book.with(
  // ...其他配置
  cfg: (
    outline_depth: 3,  // 目录显示的标题级别深度
  )
)
```

## 章节编号

默认使用中文编号方式：
- 第一章、第二章...
- 第一节、第二节...

可通过 `cfg` 参数修改编号格式：

```typst
#show: songting-book.with(
  // ...其他配置
  cfg: (
    chapter-label: "第{1:一}章",  // 章编号格式
    section-label: "{1}.{2}",    // 节编号格式
  )
)
```

## 高级自定义

如需更高级的自定义，可以通过 `paper-cfg` 参数为特定纸张格式添加或覆盖配置：

```typst
#show: songting-book.with(
  // ...其他配置
  paper-cfg: (
    a4: (
      margin: (top: 3cm, bottom: 3cm, left: 2.5cm, right: 2.5cm),
      cover-title-size: 42pt,
      // 其他 A4 特定配置
    ),
    // 可以添加新的纸张格式
    custom-size: (
      // 自定义纸张配置
    )
  )
)
```

## 注意事项

1. 该模板依赖 `outrageous` 包来生成目录样式，请确保已安装该包
2. 为获得最佳效果，请确保系统已安装所需的中文字体（宋体、黑体、楷体）,否则需要通过参数切换
3. 如果需要自定义封面，请将 `cover` 参数设置为自定义内容
4. 若标题为两字，如"前言"，会自动添加空格以达到更美观的效果

## 示例

Check [sample](https://github.com/zhinenggongziliaoku/songting-book/tree/main/sample)


# Known Issue

* Not working with include
* Style need to be polished
