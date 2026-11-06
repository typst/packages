# Unofficial WHU Lab Report 

An **unofficial** Typst template for undergraduate course lab reports at Wuhan University (WHU), School of Computer Science. It provides a cover page, table of contents, styled code blocks, appendix support, and more — ready to use out of the box.

基于 Typst 的武汉大学计算机学院本科生课程设计报告模板(**非官方**),提供封面页、目录、代码块样式、附录等开箱即用的功能.

## Usage

```typst
#import "@preview/unofficial-whu-lab-report:0.1.0": *

#show: whu-report.with(
  subtitle: "线性回归实验报告",
  instructor: "DLX",
  student-id: "**",
  student-name: "**",
  major: "CSHY",
  course-name: "机器学习",
  date: "二○二六年五月",
)

= 概述

内容...
```

## Parameters / 模板参数

| Parameter / 参数 | Type / 类型 | Default / 默认值 | Description / 说明 |
|------|------|--------|------|
| `course` | str | `"武汉大学计算机学院"` | College/department name / 学院名称 |
| `title` | str | `"本科生课程设计报告"` | Report category / 报告类别 |
| `subtitle` | str | none | Specific report title / 报告标题 |
| `instructor` | str | none | Instructor name / 指导教师 |
| `student-id` | str | none | Student ID / 学号 |
| `student-name` | str | none | Student name / 学生姓名 |
| `major` | str | none | Major name / 专业名称 |
| `course-name` | str | none | Course name / 课程名称 |
| `date` | str | none | Report date / 报告日期 |
| `font-size` | length | `12pt` | Base text size / 正文字号 |
| `math-color` | color | `purple` | Math equation color / 公式颜色 |
| `show-declaration` | bool | `false` | Include declaration page / 是否显示声明页 |
| `show-toc` | bool | `true` | Include table of contents / 是否显示目录 |
| `toc-depth` | int | `3` | TOC depth / 目录深度 |
| `code-theme` | str | none | Syntax highlighting theme path / 代码高亮主题路径 |
| `mono-font` | str,array | `("Jetbrains Mono")` | Monospace font / 等宽字体 |
| `cn-serif` | str,array | `("Latin Modern Roman", "Songti SC")` | Serif font / 衬线字体 |

## Appendix Style

Use `appendix-style` to switch to appendix numbering style(e.g.,A.1,A.2,B.1,B.2,etc.)

```typst
#pagebreak()
#show: appendix-style
= 附录
== 代码段
```
## Code Block Style
Use `code-theme` to switch to a specific syntax highlighting theme.The default theme is `./assets/code.tmTheme`.
## Font Dependencies
- **Songti SC** 
- **Heiti SC**
- **Jetbrains Mono**
- **Latin Modern Roman**

## License

MIT
