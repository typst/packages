<h1 align="center">xwysyy-typst</h1>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://typst.app"><img src="https://img.shields.io/badge/Typst-%E2%89%A5%200.14-239dad.svg" alt="Typst version: >= 0.14"></a>
  <a href="https://github.com/touying-typ/touying"><img src="https://img.shields.io/badge/touying-0.7.3-blueviolet.svg" alt="touying version: 0.7.3"></a>
  <a href="https://github.com/xwysyy/xwysyy-typst#-主题配色"><img src="https://img.shields.io/badge/Themes-sky%20%7C%20sunset-ff69b4.svg" alt="Built-in themes: sky and sunset"></a>
  <a href="https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/THEME-GENERATOR.md"><img src="https://img.shields.io/badge/AI-Theme%20Generator-orange.svg" alt="AI Theme Generator"></a>
</p>

<p align="center">
  <b>中文</b> | <a href="https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/README-EN.md">English</a>
</p>

> 基于 [touying](https://github.com/touying-typ/touying) 的学术演示文稿主题 + 学术笔记排版，适合课题汇报、论文答辩、学术分享和文献笔记。派生自 [Carlos-Mero/may](https://github.com/Carlos-Mero/may)（MIT）。

## ✨ 特性

- 内置 **sky** / **sunset** 两套配色，`theme` 参数一键切换，支持 [AI 自定义配色](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/THEME-GENERATOR.md)
- 7 种 slide 版式 + 学术笔记模式，覆盖封面、目录、章节过渡、焦点页等场景
- `textbox` 多列文本框、`red` / `yellow` 标注宏、CJK 合成斜体等学术排版组件
- `#pause` 逐步揭示动画，内置 `frozen-counters` 防止编号异常
- 可选扩展 `xwysyy-extras.typ`：cetz 绘图 / fletcher 流程图 + theorion 定理环境
- 兼容 touying 0.7.x 全部高级特性

## 👀 效果预览

> 示例 deck 位于 `examples/` 目录，编译查看效果：

```bash
typst compile examples/slides-sky.typ           # sky 主题 slide
typst compile examples/slides-sunset.typ        # sunset 主题 slide
typst compile examples/note.typ                  # 学术笔记
```

### 🌤️ Sky 主题

| 封面 | 列表与强调 |
|:---:|:---:|
| ![Sky theme cover slide](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sky-p1-01.png) | ![Sky theme lists and highlights](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sky-p4-04.png) |
| **文本框组件** | **代码与公式** |
| ![Sky theme textbox components](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sky-p5-05.png) | ![Sky theme code and equations](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sky-p8-08.png) |

### 🌅 Sunset 主题

| 封面 | 列表与强调 |
|:---:|:---:|
| ![Sunset theme cover slide](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sunset-p1-01.png) | ![Sunset theme lists and highlights](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sunset-p4-04.png) |
| **文本框组件** | **代码与公式** |
| ![Sunset theme textbox components](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sunset-p5-05.png) | ![Sunset theme code and equations](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-sunset-p8-08.png) |

### 📝 笔记模式

| 标题与目录 | 列表与代码 | 表格与引用 |
|:---:|:---:|:---:|
| ![Note mode title and TOC](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-note-p1-1.png) | ![Note mode lists and code](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-note-p2-2.png) | ![Note mode tables and quotes](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/a0c4c07/assets/preview-note-p3-3.png) |

## 🚀 快速开始

将 `xwysyy.typ` 复制到你的项目目录，然后：

```typst
#import "@preview/xwysyy:0.1.0": *

#show: xwysyy-pre.with(
  theme: "sunset",
  config-info(
    title: [我的演示标题],
    subtitle: [副标题],
    author: " ",
    date: datetime.today(),
    institution: " ",
  ),
)

#title-slide()

= 章节标题

== 页面标题

正文内容，支持 *粗体* 和 #red[标红强调]。

#textbox(
  [*模块 A*

  第一列内容],

  [*模块 B*

  第二列内容],
)

#end-slide(title: [谢谢！], body: [欢迎提问])
```

## 🎨 主题配色

通过 `theme` 参数选择内置主题，或参考 [AI 配色生成器](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/THEME-GENERATOR.md) 创建自定义配色。

| 字段 | 用途 | sky | sunset |
|------|------|-----|--------|
| `sea` | 主色 | `#3b60a0` | `#970014` |
| `sky` | 强调色 | `#bdd0f1` | `#D8A6A2` |
| `skyl` | 浅色背景 | `#eff3ff` | `#fdf0f0` |
| `skyll` | 代码块/textbox 底色 | `#f4f9ff` | `#FFF8F6` |
| `paper` | 深底上的文字 | `#f5f6f8` | `#f5f6f8` |
| `header-fill` | 顶栏背景 | sea 深蓝 | `#F7EEE7` |
| `header-text` | 顶栏文字 | paper 白 | `#970014` |
| `page-fill` | 页面背景 | 纯白 | `#fffefd` |

## 🧩 组件速查

| 类别 | API | 用法 |
|------|-----|------|
| Slide 入口 | `xwysyy-pre` | `#show: xwysyy-pre.with(theme: "sky", ...)` |
| 封面 | `title-slide` | `#title-slide()` |
| 目录 | `outline-slide` | `#outline-slide()` 自动收集章节标题 |
| 内容页 | `xwysyy-slide` | `== 标题` 自动触发 |
| 章节过渡 | `new-section-slide` | `= 标题` 自动触发 |
| 焦点页 | `focus-slide` | `#focus-slide[大字内容]` |
| 全屏图片 | `image-slide` | `#image-slide(img: image("bg.png"))` |
| 结束页 | `end-slide` | `#end-slide(title: [...])` |
| 文本框 | `textbox` | `#textbox[内容]` / `#textbox([列 1], [列 2])` |
| 标红 | `red` / `bred` | `#red[文字]` / `#bred[粗体标红]` |
| 标黄 | `yellow` / `byellow` | `#yellow[文字]` / `#byellow[粗体标黄]` |
| 笔记入口 | `xwysyy-note` | `#show: xwysyy-note.with(title: [...])` |
| 可选扩展 | `xwysyy-extras` | cetz 绘图 + fletcher 流程图 + theorion 定理环境 |

完整 API 参考见 [USAGE.md](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/USAGE.md)，自定义指南见 [CUSTOMIZATION.md](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/CUSTOMIZATION.md)。

## ⚙️ 环境要求

- Typst >= 0.14
- touying 0.7.3（首次编译自动下载）
- physica 0.9.5（首次编译自动下载）
- 字体：Times New Roman + Noto Serif CJK SC（中文）+ Maple Mono（代码）

## 📖 文档

| 文档 | 内容 |
|------|------|
| [USAGE.md](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/USAGE.md) | 完整 API 参考：版式、组件、扩展包、非 slide 文档入口 |
| [CUSTOMIZATION.md](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/CUSTOMIZATION.md) | 自定义指南：改色、改字、加版式、touying 高级特性、扩展集成 |
| [THEME-GENERATOR.md](https://github.com/xwysyy/xwysyy-typst/blob/a0c4c07/docs/THEME-GENERATOR.md) | AI 配色生成器：用 AI 从截图/描述创建自定义主题 |

## 🙏 致谢

- 主题派生自 [Carlos-Mero/may](https://github.com/Carlos-Mero/may)（MIT）
- 底层框架 [touying](https://github.com/touying-typ/touying)

## 📄 License

[MIT](./LICENSE)
