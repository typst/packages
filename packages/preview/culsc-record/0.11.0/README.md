# A Typst CULSC Experiment Record Template | 基于 Typst 的全国大学生生命科学竞赛实验记录模板

[中文](#中文) | [English](#english)

---

## 中文

### 简介

这是一个用于全国大学生生命科学竞赛（科学探究类）实验记录的 Typst 模板。该模板提供了符合比赛规定的页面布局、国标格式的数学公式和参考文献支持。

### 快速开始

#### 1. 导入模板

在你的文件开头导入模板：

```typst
#import "@preview/culsc-record:0.11.0": *
```

`0.11.x` 代表这是适用于第 11 届的版本

或者本地使用:

```typst
#import "/lib.typ": *
```

#### 2. 配置实验信息

使用 `culsc-record` 函数配置实验信息：

```typst
#show: culsc-record.with(
  session: "十一",           // 届数
  serial: "01",              // 序号（实验记录的顺序编号）
  start-year: "2026",        // 实验开始年份
  start-month: "01",         // 实验开始月份
  start-day: "21",           // 实验开始日期
  start-time: "08:00",       // 实验开始时间
  end-year: "2026",          // 实验结束年份
  end-month: "01",           // 实验结束月份
  end-day: "30",             // 实验结束日期
  end-time: "12:30",         // 实验结束时间
  text-fontset: "web",       // 文本字体集（可选 "windows", "macos", "web"）
  math-fontset: "web",       // 数学字体集（可选 "recommend", "windows", "macos", "web"）
)
```

#### 3. 编写实验内容

使用 Typst 的标准语法编写实验内容：

```typst
= 实验目的

本次实验旨在探究......

= 实验材料

- 试剂：......
- 仪器：......

= 实验步骤

+ 取样......
+ 离心......

= 实验结果

实验结果表明......

= 实验总结

通过本次实验......
```

### 项目结构建议

建议为每个实验创建独立的文件夹：

```
project/
├── template/
│   ├── 01/
│   │   ├── experiment-01.typ
│   │   └── ref-01.bib
│   ├── 02/
│   │   ├── experiment-02.typ
│   │   └── ref-02.bib
│   └── 03/
│       ├── experiment-03.typ
│       └── ref-03.bib
├── lib.typ
└── src/
```

### 字体配置

模板提供三种预设字体配置：

- `"windows"` - 中易宋体/黑体 + Times New Roman
- `"macos"` - 华文宋体/黑体 + Times New Roman
- `"web"` - 思源宋体/黑体 + TeX Gyre Termes

对于数学字体还有一种额外的推荐配置：

- `"recommend"` - 推荐配置（需自行安装字体）

### 参考文献

在文档末尾添加参考文献：

```typst
#print-bib(
  bibliography: bibliography.with("ref-01.bib"),
  full: false,  // false 只显示引用的文献，true 显示全部
  gbpunctwidth: "full", // 中文文献使用全角标点，"half" 切换为半角
  uppercase-english-names: true, // 西文人名是否全大写
  bib-number-gutter: 1em, // 编号与条目的间距
  bib-number-align: "right", // 编号对齐行为，还可选 "left"
)
```

### 注意事项

1. "序号"是实验记录的顺序编号（1、2、3...），不是团队编号
2. 所有材料中不得出现团队编号、学校名称和姓名
3. 避免出现明确的实验材料采样和保存地点
4. 避免出现带有学校标识的实验照片
5. 避免出现团队成员合照或正面照片

### 示例

编译 `template/01/experiment-01.typ` 获取完整示例。

---

## English

### Introduction

This is a Typst template for experiment records of the China Undergraduate Life Sciences Contest (Scientific Exploration). It provides page layouts compliant with competition requirements, along with support for GB-standard mathematical formulas and references.

### Quick Start

#### 1. Import the Template

Import the template at the beginning of your file:

```typst
#import "@preview/culsc-record:0.11.0": *
```

`0.11.x` indicates that this version is tailored for the 11th session

Or for local use:

```typst
#import "/lib.typ": *
```

#### 2. Configure Experiment Information

Configure your experiment information using the `culsc-record` function:

```typst
#show: culsc-record.with(
  session: "十一",           // Session number
  serial: "01",              // Serial number (experiment record sequence)
  start-year: "2026",        // Experiment start year
  start-month: "01",         // Experiment start month
  start-day: "21",           // Experiment start day
  start-time: "08:00",       // Experiment start time
  end-year: "2026",          // Experiment end year
  end-month: "01",           // Experiment end month
  end-day: "30",             // Experiment end day
  end-time: "12:30",         // Experiment end time
  text-fontset: "web",       // Text font set ("windows", "macos", "web")
  math-fontset: "web",       // Math font set ("recommend", "windows", "macos", "web")
)
```

#### 3. Write Experiment Content

Write your experiment content using standard Typst syntax:

```typst
= Experiment Objective

This experiment aims to investigate......

= Materials

- Reagents: ......
- Equipment: ......

= Procedures

+ Sampling......
+ Centrifugation......

= Results

The results show that......

= Conclusion

Through this experiment......
```

### Recommended Project Structure

It's recommended to create separate folders for each experiment:

```
project/
├── template/
│   ├── 01/
│   │   ├── experiment-01.typ
│   │   └── ref-01.bib
│   ├── 02/
│   │   ├── experiment-02.typ
│   │   └── ref-02.bib
│   └── 03/
│       ├── experiment-03.typ
│       └── ref-03.bib
├── lib.typ
└── src/
```

### Font Configuration

The template provides three preset font configurations:

- `"windows"` - SimSun/SimHei + Times New Roman
- `"macos"` - Songti SC/Heiti SC + Times New Roman
- `"web"` - Noto Serif CJK SC/Noto Sans CJK SC + TeX Gyre Termes

For math fonts, an additional recommended configuration:

- `"recommend"` - Recommended (requires manual font installation)

### Bibliography

Add bibliography at the end of your document:

```typst
#print-bib(
  bibliography: bibliography.with("ref-01.bib"),
  full: false,  // false: cited only, true: all entries
  gbpunctwidth: "full", // Use full-width punctuation for Chinese, "half" for half-width
  uppercase-english-names: true, // Whether to uppercase English names
  bib-number-gutter: 1em, // Space between number and entry
  bib-number-align: "right", // Number alignment, can also be "left"
)
```

### Important Notes

1. "Serial number" refers to the experiment record sequence (1, 2, 3...), not the team number
2. Do not include team numbers, school names, or personal names in any materials
3. Avoid mentioning specific sampling and storage locations
4. Avoid photos with school identifiers
5. Avoid team photos or portrait photos

### Examples

Compile `template/01/experiment-01.typ` for complete examples.

---

## License

[MIT](LICENSE)

## Repository

[https://github.com/SchrodingerBlume/typst-culsc-record](https://github.com/SchrodingerBlume/typst-culsc-record)
