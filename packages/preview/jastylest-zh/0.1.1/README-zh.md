中文 | [English](README.md)

# jastylest-zh

jastylest 是一个用于 Typst 日文排版的模板，而 jastylest-zh 基于此针对中文排版进行了优化。

## 使用方法
在你的文件的最开头添加
```typ
#import "@preview/jastylest-zh:0.1.0": *
```

然后使用配置文件：
```typ
#let (article, textsf) = template(
  seriffont: "STIX Two Text",             // 西文衬线字体
  seriffont-cjk: "Noto Serif CJK SC",     // 中文衬线字体
  sansfont: "Noto Serif",                 // 西文无衬线字体
  sansfont-cjk: "Noto Sans CJK SC",       // 中文无衬线字体
  monofont: "Fira Mono",                  // 西文等宽字体
  monofont-cjk: "Noto Sans Mono CJK SC",  // 中文等宽字体
  mathfont: "STIX Two Math",              // 数学字体
  kaiti-cjk: "FandolKai",                 // 楷体字体，默认为FandolKai（需要导入）
  paper: "a4",              // 纸张大小，默认为a4
  font-size: 12pt,          // 字号，也可以配合其他的包导入中文字号
  code-font-size: 11pt,     // 代码字号
  font-weight: "regular",   // 字体粗细，默认为常规
  cols: 1,                  // 多栏，默认为1栏
  titlepage: false,         // 是否显示标题页，默认不显示
  title: [*标题*],          // 标题，可以使用格式
  office: [单位],           // 单位，可以使用格式，可以兼做副标题
  author: [作者],           // 作者，可以使用格式
  // date: none,            // 日期，默认为当前日期
)
#show: article  // 展示文档
```

## 字体
默认字体为 STIX Two Text/Math、Fira Sans/Mono 和思源宋体/黑体。您也可以自行修改。

斜体的默认中文字体是 FandolKai（需自行上传），您也可以自行在上方配置中更改。Fandol 系列字体可以在 <https://ctan.org/pkg/fandol> 中下载。

## 功能
内置两个函数：`#textsf[]` 和 `#noindent[]`。`#textsf[]` 可以让被括号包裹的部分使用无衬线字体，而 `#noindent[]` 可以让被括号包裹的部分取消缩进。

## 样例
`document.typ` 里面有文档示例，包含了所有可以配置的参数。
