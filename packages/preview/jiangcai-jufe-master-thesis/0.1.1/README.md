**This is a thesis template for Jiangxi University of Finance and Economics**

[![江西财经大学logo](assets/江西财经大学-logo.svg)](https://www.jxufe.edu.cn/)

# 江西财经大学硕士毕业论文Typst模板

![GitHub License](https://img.shields.io/github/license/MaxforCherubim/jufe-master-thesis-Typst-template)

为酱菜学子提供方便好用的硕士毕业论文Typst模板

## 目录

- [江西财经大学硕士毕业论文Typst模板](#江西财经大学硕士毕业论文typst模板)
  - [目录](#目录)
  - [项目概述](#项目概述)
  - [使用方法](#使用方法)
    - [安装与编译](#安装与编译)
    - [版本模式](#版本模式)
    - [功能一览](#功能一览)
  - [文档结构](#文档结构)
  - [功能速查](#功能速查)
  - [注意事项](#注意事项)
  - [贡献指南](#贡献指南)
  - [联系方式](#联系方式)
  - [许可证信息](#许可证信息)

## 项目概述

- 本项目为[江西财经大学硕士毕业论文全流程](https://github.com/MaxforCherubim/jufe-master-thesis-process)的子项目
- 在[Github](https://github.com/MaxforCherubim/jufe-master-thesis-Typst-template)和[Gitee](https://gitee.com/maxforcherubim/jufe-master-thesis-Typst-template)上同步更新

> [Typst](https://typst.app/)是一款可编程标记语言，定位与[$\LaTeX$](https://www.latex-project.org/)相似，编译速度快、安装轻便、语法直观。

## 使用方法

### 安装与编译

1. 安装 Typst（[官方教程](https://typst.app/docs/tutorial/)；macOS 可用 `brew`）
2. 在 VSCode 中安装 Tinymist Typst 插件
3. Git clone 本项目，在 VSCode 中打开**版本根目录**（即 `0.1.1/`），编辑 `template/thesis.typ`，保存后自动编译

也可命令行编译（在 `0.1.1/` 下执行）：

```bash
typst compile template/thesis.typ --font-path fonts
```

> 参考文献路径从项目根目录写起（以 `/` 开头），编译与 Tinymist 根目录都必须是版本根目录。

**字体**：模板使用学校规范指定的标准字体（宋体、黑体、楷体、仿宋、Times New Roman 等），均为 Windows 自带。缺字体的电脑可直接安装 `fonts/` 目录中的字体，或用 `--font-path fonts` 临时加载。VSCode 可在工作区 `.vscode/settings.json` 配置：

```json
{ "tinymist.fontPaths": ["packages/preview/jiangcai-jufe-master-thesis/0.1.1/fonts"] }
```

### 版本模式

同一源文件可产出三种版本，由 `#version-mode.update(...)` 控制，命令行可用 `--input` 临时指定：

| 模式 | 效果 |
|---|---|
| `"review"`（默认） | 完整版：封面、声明、致谢齐全 |
| `"blind"` | 送审匿名版：隐去作者/导师信息，声明与致谢自动消失 |
| `"print"` | 无封面打印版：封面不渲染，声明页起排为第 1 页 |

```bash
typst compile template/thesis.typ blind.pdf --font-path fonts --input mode=blind
```

### 功能一览

- **三线表**：`tlt()` 从 xlsx 读取数据自动生成，跨页自动续表（标注"续表"并重复表头）
- **中英双语目录**：标题旁标注 `#en[English Title]`，英文目录自动提取
- **图/公式/代码/算法**：按类型分开计数，编号"章号.序号"，题注与引用自动一致
- **参考文献**：`#references(...)` 生成 GB/T 7714 文献表，正文写 `[@key]` 引用
- **致谢**：blind 模式整节自动不渲染，签名姓名/年月自动取自封面

> `template/thesis.typ` 既是功能示例也是使用教程，各功能均可直接对照模仿。

## 文档结构

```bash
#cover(...)       封面
#declaration()    独创性声明（blind 模式自动跳过）
#abstract(...)    中英文摘要与关键词
#multi-outline()  中英文目录 / 图表公式目录（自动生成，空目录自动跳过）
正文              标题、图、表、代码、算法、公式、脚注、引用
#references(...)  参考文献
#appendix[...]    附录
#thanks[...]      致谢
```

前置部分罗马数字页码，正文阿拉伯数字从 1 起；奇偶页页眉分别显示论文标题与章标题。

## 功能速查

| 功能 | 写法 |
|---|---|
| 版本模式 | `#version-mode.update(...)`；命令行 `--input mode=blind` |
| 封面 | `#cover(zh-title1: [...], author: [...], ...)` |
| 标题 | `=` 至 `=====`（一至五级） |
| 双语目录 | `= 绪论 #en[Introduction]` |
| 插图 | `#figure(image("..."), caption: [...]) <标签>` |
| 三线表 | `#figure(tlt(read("...xlsx", encoding: none)), caption: [...])` |
| 代码清单 | `#code(..., caption: [...])` |
| 伪代码 | `#algorithm(caption: [...], input: [...], output: [...], [...])` |
| 公式 | `$ ... $ <标签>` |
| 左右混排 | `#beside(元素1, 元素2, ...)` |
| 子图/子表 | `#subfloat(kind: image, caption: [...], ([（a）子题], 内容), ...)` |
| 脚注 | `#footnote([...])` |
| 参考文献 | `#references("/template/refs.bib")`；引用 `[@key]` |
| 附录 / 致谢 | `#appendix[...]`；`#thanks[...]` |
| 占位文本 | `#kouhu(builtin-text: "aspirin", indices: 1, length: 100)` |

## 注意事项

**优点：**

1. 安装即用，格式全自动，无需关心排版细节
2. 编译迅速，保存即出 PDF，远快于 LaTeX
3. xlsx 三线表自动续表，参考文献 GB/T 7714 样式内置
4. 中英双语目录、封面/声明/致谢一键生成，版本模式切换匿名版/打印版

**缺点：**

1. 句末引用偶现行首悬挂：`…文字#[@ref]。` 中 `[N]` 和句号可能被甩到下一行行首（Typst 引擎局限），在句号后增删一两个字即可避开
2. GBT2025尚未更新，等待大佬更新https://github.com/YDX-2147483647/gb7714-bench
3. Typst 仍在快速迭代，版本更新偶可能引入兼容性问题

遇到任何问题欢迎在[讨论区](https://github.com/MaxforCherubim/jufe-thesis-defence-Revealjs-template/discussions)提问，或提交 [issues](https://github.com/MaxforCherubim/jufe-thesis-defence-Revealjs-template/issues)。

## 贡献指南

- 欢迎提交反馈——问题、建议、小白问题都可以在讨论区交流，**所有互动都会成为后来者的学习资料**
- 欢迎提交 PR 参与开发

## 联系方式

- 作者：章迎潭，本科17级经济统计1班，硕士23级应用统计2班
- 导师：数理统计系马海强教授
- 邮件：<bay237580157@outlook.com>

## 许可证信息

[MIT license](https://opensource.org/license/mit/)

[回到顶部](#目录)
