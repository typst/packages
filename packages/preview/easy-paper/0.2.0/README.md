# easy-paper

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FDawnfz-Lenfeng%2Feasy-paper%2Fmaster%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239dad)](https://typst.app/universe/package/easy-paper)
![GitHub Repo stars](https://img.shields.io/github/stars/Dawnfz-Lenfeng/easy-paper?style=flat&logo=github)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Typst](https://img.shields.io/badge/built%20with-Typst-239dad.svg)

A ready-to-use Typst template for Chinese papers.

一个基于 [SimplePaper](https://github.com/jinhao-huang/SimplePaper) 改进的 Typst 模板，可用于日常报告/作业等。只需一个文件，无需外置库，使用 Windows 系统内置字体，即可开始创作。

![Star History Chart](https://api.star-history.com/svg?repos=Dawnfz-Lenfeng/easy-paper&type=Date)

## 快速开始

### 从官方包导入

```typst
#import "@preview/easy-paper:0.2.0": *

#show: project.with(
  title: "文档标题",
  author: "作者姓名",
  date: auto,
  abstract: [
    摘要内容...
  ],
  keywords: ("关键词1", "关键词2")
)
```

或者直接使用 Typst-CLI 初始化：
```bash
typst init @preview/easy-paper
```

### 本地导入


得益于单文件设计，你可以直接下载 lib.typ 文件并将其放置在项目根目录。这种方式特别适合以下场景：

- **更新即时**：无需等待官方包库 (Package Registry) 同步，直接使用仓库最新代码。
- **深度 DIY**：你可以直接修改本地的 lib.typ 源码，进行深度的自定义配置，满足更换字体等特定的排版需求。

```bash
# Linux / macOS
curl -O https://raw.githubusercontent.com/Dawnfz-Lenfeng/easy-paper/refs/heads/master/lib.typ

# Windows (CMD 或 PowerShell)
curl.exe -O https://raw.githubusercontent.com/Dawnfz-Lenfeng/easy-paper/refs/heads/master/lib.typ
```

然后在你的 Typst 文件顶部导入模板：
```typst
#import "lib.typ": *
```

### 学术组件

在原有模板的基础上，一共有以下学术组件，以供基本日常笔记使用。

**题目框：**
```typst
#problem[
  计算 $f(x) = x^2$ 的导数。
]
```

**解答框：**
```typst
#solution[
  $f'(x) = 2x$
]
```

**总结框：**
```typst
#summary[
  这里可以写总结性的内容。
]
```

**三线表格：**
```typst
// 默认启用三线表格式
#figure(
  table(
      columns: 3,
      [项目], [数值], [单位],
      [长度], [10], [cm],
      [质量], [5], [kg],
  ),
  caption: [测量数据]
)
```

### 数学公式

模板对数学公式编号进行了优化，带标签的公式会自动编号，不带标签的公式不会编号。

```typst
// 行内公式
这是 $E = mc^2$ 公式。

// 带编号的公式
$ x = frac(-b plus.minus sqrt(b^2 - 4ac), 2a) $ <eq:quadratic>

// 不编号的公式
$ sum_(i=1)^n i = frac(n(n+1), 2) $
```

同时有一些自定义函数，如偏微分（后续可能会添加更多）：

```typst
// 偏微分
$ frac(partial f, partial x) = pardiff(f, x) $
```

### 字体说明

目前默认字体为：

- 中文：SimSun, STZhongsong, KaiTi, SimHei
- 英文：New Computer Modern, Times New Roman, Consolas

Windows 大部分字体已内置，macOS/Linux 可能需要额外安装中文字体。

如需使用其他字体，请修改模板中的字体配置。

### 自定义设置

模板中提供了一些自定义设置，如字体、字号、段间距等。可根据需求自行修改 `lib.typ` 中 `config` 配置。

| 配置项      | 默认值        | 说明         |
| ----------- | ------------- | ------------ |
| text-size   | 10.5pt (五号) | 正文字号     |
| author-size | 10.5pt (五号) | 作者字号     |
| title-size  | 18pt (二号)   | 标题字号     |
| title1-size | 15pt (小三)   | 一级标题字号 |
| title2-size | 14pt (四号)   | 二级标题字号 |
| title3-size | 12pt (小四)   | 三级标题字号 |
| spacing     | 1.5em         | 段间距       |
| leading     | 1.0em         | 行间距       |
| indent      | 2em           | 缩进         |
| small-space | 0.75em        | 小间距       |

## 效果展示

![page1](./assets/output-1.png)
![page2](./assets/output-2.png)

## 致谢

本模板基于 [jinhao-huang/SimplePaper](https://github.com/jinhao-huang/SimplePaper) 改进，感谢原作者。
