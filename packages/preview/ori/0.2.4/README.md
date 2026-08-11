# 🌠Ori

[Ori](https://github.com/OrangeX4/typst-ori) 是一个简单但富有表现力的自用 Typst 文档模板，适用于笔记（支持夜间模式）、报告和各类文档。同时也是我个人 Typst 中文写作的最佳实践。

[Ori](https://github.com/OrangeX4/typst-ori) is a simple but expressive template for self-use Typst documents for notes (with night mode supported), reports, and all types of documents. It's also my personal best practice for writing with Typst in Chinese.

## 快速开始

要使用此模板，您需要：

1. 安装必需的字体：
   - [IBM Plex Serif, Mono](https://github.com/IBM/plex)
   - [Noto Serif CJK SC](https://github.com/notofonts/noto-cjk)

2. 导入模板，并在文档开头设置参数，包括标题、作者、课程或主题、学期、时间；
  ```typ
  #import "@preview/ori:0.2.4": *

  #set heading(numbering: numbly("{1:一}、", default: "1.1  "))
  #set math.equation(numbering: "(1)")

  #show: ori.with(
    title: "文档标题",
    author: "张三",
    subject: "Ori in Typst",
    semester: "2025 春",
    date: datetime.today(),
    // maketitle: true,
    // makeoutline: true,
    // theme: "dark",
    // media: "screen",
  )
  ```

## 特性

### 可配置参数

- `size`: 字体大小（默认 `11pt`）
- `screen-size`: 屏幕显示字体大小（默认 `11pt`）
- `maketitle`: 是否生成标题页（默认 `false`）
- `makeoutline`: 是否生成目录（默认 `false`）
- `outline-depth`: 目录深度（默认 `2`）
- `first-line-indent`: 首行缩进（设置为 `auto` 则为 `2em`）
- `media`: 媒体类型（`"screen"` 或 `"print"`）
- `lang`: 语言（默认 `"zh"`）
- `region`: 地区（默认 `"cn"`）

### 主要功能

1. **三线表支持**：基于 [Tablem 包](https://github.com/OrangeX4/typst-tablem)，提供简单的三线表功能
2. **Markdown 渲染**：基于 [Cmarker 包](https://github.com/SabrinaJewson/cmarker.typ)，支持 Markdown 语法，包括加粗、斜体、删除线等
3. **数学公式**：基于 [MiTeX 包](https://github.com/mitex-rs/mitex) 支持 LaTeX 风格的数学公式
4. **定理环境**：基于 [Theorion 包](https://github.com/OrangeX4/typst-theorion)，提供多种定理环境（定义、定理、引理、命题等）
5. **提示框**：包含多种样式的提示框（强调、引用、注意、提示、重要、警告、小心）

### 自定义

#### 标题编号

可以使用 `numbly` 包自定义标题编号样式：

```typst
#set heading(numbering: numbly("{1:一}、", default: "1.1  "))
```

#### 字体设置

可以通过设置 `font` 参数自定义字体：

```typst
#let font = (
  main: "IBM Plex Serif",
  mono: "IBM Plex Mono",
  cjk: "Noto Serif SC",
  emph-cjk: "KaiTi",
  math: "New Computer Modern Math",
  math-cjk: "Noto Serif SC",
)
```

## 需要定制？

源码仅有两百行左右，可以复制下来轻松定制。

## 致谢

- 感谢 [hongjr03](https://github.com/hongjr03) 的 [typst-assignment-template](https://github.com/hongjr03/typst-assignment-template)

## 许可证

MIT License
