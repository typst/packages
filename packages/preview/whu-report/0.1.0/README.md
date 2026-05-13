# WHU Report — 武汉大学课程设计报告模板

基于 Typst 的武汉大学计算机学院本科生课程设计报告模板，提供封面页、目录、代码块样式、附录等开箱即用的功能。

## 使用

```typst
#import "@preview/whu-report:0.1.0": *

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

## 模板参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `course` | str | `"武汉大学计算机学院"` | 学院/部门名称 |
| `title` | str | `"本科生课程设计报告"` | 报告类别 |
| `subtitle` | str | none | 报告具体标题 |
| `instructor` | str | none | 指导教师 |
| `student-id` | str | none | 学号 |
| `student-name` | str | none | 学生姓名 |
| `major` | str | none | 专业名称 |
| `course-name` | str | none | 课程名称 |
| `date` | str | none | 报告日期 |
| `font-size` | length | `12pt` | 正文字号 |
| `math-color` | color | `purple` | 公式颜色 |
| `show-declaration` | bool | `false` | 是否显示声明页 |
| `show-toc` | bool | `true` | 是否显示目录 |
| `toc-depth` | int | `3` | 目录深度 |
| `code-theme` | str | none | 代码高亮主题路径 |
| `mono-font` | str,array | `("Jetbrains Mono"")` | 等宽字体 |
| `cn-serif` | str,array | `("Latin Modern Roman", "Songti SC")` | 衬线字体 |

## 附录样式

使用 `appendix-style` 切换附录编号：

```typst
#pagebreak()
#show: appendix-style
= 附录
== 代码段
```

## 字体依赖

模板默认使用以下字体：

- **Songti SC**: macOS 自带宋体
- **Heiti SC**: macOS 自带黑体
- **Jetbrains Mono**: 需自行安装，或更换 `mono-font` 参数
- **Latin Modern Roman**: Typst 内置

如遇字体缺失，请通过参数指定系统可用字体。

## License

MIT
