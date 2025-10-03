# ECNU Math Homework 

为华东师范大学写的作业模板，主要针对 问题-解答/证明的形式。

## 特点
- 支持中英文
- 格式简约美观
- 为每个问题中的行间公式进行编号，可以直接引用。
- 大大的校徽水印

适用于提交 pdf 作业

## 预览
| 1                    | 2                  | 3                |
| ----------------------- | --------------------- | --------------------- |
| ![1](pic/1.png) | ![2](pic/2.png) | ![3](pic/3.png) |

可见仓库中的 `template/hw.typ` 文件。

注意：中英文语言的设置要在 `show hwk` 之前。 

## 使用


可使用 Typst Universe 源导入：

```typ
#import "@preview/ecnu-math-hwk:0.1.0": *
```

也可克隆仓库到工作目录下进行导入。

```typ
#import "ecnu-math-hwk/lib.typ"
```

字体没有内置，您可能需要安装以下字体：

```typ
#let needed-font = (
    "Source Han Serif SC",
    "New Computer Modern",
    "Source Han Sans SC",
    "New Computer Modern Sans"
)
```