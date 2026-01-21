# modern-hust-cs-report

This is an unofficial template for curriculum and lab reports at School of Computer Science, Huazhong University of Science and Technology.

本模板为华中科技大学 计算机科学与技术学院 本科课程报告/实验报告 的模板，基于新生实践课老师发放的LaTeX模板修改而来。

## 使用方式

### 前置安装

此模板需要你的电脑里有Fangsong, SimSun, SimHei, Times New Roman等字体。

### 方法一：使用 typst init（推荐）

在当前目录初始化项目：

```bash
typst init @preview/modern-hust-cs-report
```

指定自定义目录名称：

```bash
typst init @preview/modern-hust-cs-report my-report
```

### 方法二：手动导入

在已有 Typst 项目中导入该模板并填写信息：

```typst
#import "@preview/modern-hust-cs-report:0.1.0": *


#show: experimental-report.with(
  title: "基于高级语言源程序格式处理工具",
  course-name: "程序设计综合课程设计",
  author: "蓝鹦鹉",
  school: "计算机科学与技术学院",
  class-num: "计算机科学与技术2407",
  stu-num: "U2024",
  instructor: "张三",
  report-date: "2025年11月4日",
)

= 引言

== 问题描述

在计算机科学中，抽象语法树（abstract syntax tree或者缩写为AST），是将源代码的语法结构的用树的形式表示。

== 课题背景与意义

随着软件开发规模的不断扩大和团队协作的日益频繁，代码的可读性和规范性变得越来越重要。

=== test1
123 // @xxx 引用

=== test2

3333

#pagebreak()
= 第二节

// 插入表格
#tbl(
  table(
    columns: 3,
    [列1], [列2], [列3],
    [数据1], [数据2], [数据3],
  ),
  caption: "示例表格",
)

// 插入图片
// #fig("./HUSTBlack.png", caption: "示例图片")

#pagebreak()

// 参考文献
// #citation("./report.bib")

// #pagebreak()

#show: appendix-section // 插入附录

= test
Here is the appendix content.

```

### 图片插入

使用 `fig` 函数插入图片，它会自动添加格式化的图注：

```typst
#fig("path/to/image.png", caption: "图片描述", width: 80%)
```

- `caption`: 图片标题（必填）
- `width`: 图片宽度，可以是百分比或绝对值（可选，默认 auto）
- 图片编号格式为 `图x-y-z`，其中 x 是一级标题编号，y 是二级标题编号，z 是该节内的图片序号
- 每个二级标题下的图片编号会自动重置
- 图注使用 Times New Roman 和黑体混合字体，14pt，居中显示在图片下方

### 表格插入

使用 `tbl` 函数插入表格，它会自动添加格式化的表注：

```typst
#tbl(
  table(
    columns: 3,
    [列1], [列2], [列3],
    [数据1], [数据2], [数据3],
  ),
  caption: "表格描述"
)
```

- `content`: 表格内容（使用 Typst 的 `table()` 函数创建）
- `caption`: 表格标题（必填）
- 表格编号格式为 `表x-y-z`，其中 x 是一级标题编号，y 是二级标题编号，z 是该节内的表格序号
- 每个二级标题下的表格编号会自动重置
- 表注使用 Times New Roman 和黑体混合字体，14pt，居中显示在表格上方

### 引用插入

使用 `citation` 函数插入引用。向它传递一个 `.bib` 文件，它会自动处理标题、目录等格式并自动展开 bib

### 附录插入

在编写完成正文后，使用 `#show: appendix-section` 标记进入附录区。

## 致谢

本项目中 `fig` 和 `tbl` 函数使用了 [DzmingLi/hust-cse-report](https://github.com/DzmingLi/hust-cse-report) @DzmingLi 的实现，感谢你的开源！

本项目使用了 Github Copilot 进行编写
