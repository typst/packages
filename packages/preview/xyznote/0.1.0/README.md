# Simple Typst note template

A Simple Typst note template

## 使用

```typ
#import "@preview/xyznote:0.1.0": *

#show: note.with(
  title: "xyznote",
  author: "wardenxyz",
  abstract: "一个简单的 Typst 笔记模板",
  createtime: "2024-11-27",
  bibliography-file: "ref.bib", //注释在这里删除参考文献页面
)
```

## VS Code 本地编辑（推荐）

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 新建一个 `.typ` 文件

3. Ctrl+K V 即可预览 PDF

4. 点击 typst 文件顶部 `Export PDF` 就可以导出 PDF 文件

## 鸣谢

这个项目用到了以下三个项目的代码

https://github.com/gRox167/typst-assignment-template

https://github.com/DVDTSB/dvdtyp

https://github.com/a-kkiri/SimpleNote
