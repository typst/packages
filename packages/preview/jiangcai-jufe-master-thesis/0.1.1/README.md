**This is a thesis template for Jiangxi University of Finance and Economics**

[![江西财经大学logo](assets/江西财经大学-logo.svg)](https://www.jxufe.edu.cn/)

# 江西财经大学硕士毕业论文Typst模板

![GitHub License](https://img.shields.io/github/license/MaxforCherubim/jufe-master-thesis-Typst-template)

为酱菜学子提供方便好用的硕士毕业论文Typst模板

## 目录

- [江西财经大学硕士毕业论文Typst模板](#江西财经大学硕士毕业论文typst模板)
  - [目录](#目录)
  - [项目概述​](#项目概述)
  - [使用方法​](#使用方法)
  - [文档结构](#文档结构)
  - [模板功能速览​](#模板功能速览)
  - [注意事项​](#注意事项)
  - [贡献指南​](#贡献指南)
  - [联系方式​](#联系方式)
  - [许可证信息​](#许可证信息)

## 项目概述​

- 本项目为[江西财经大学硕士毕业论文全流程](https://github.com/MaxforCherubim/jufe-master-thesis-process)的子项目
- 项目起初源于给导师的审阅稿和查重稿，使用的是Typst工具
- 本项目在[Github](https://github.com/MaxforCherubim/jufe-master-thesis-Typst-template)和[Gitee](https://gitee.com/maxforcherubim/jufe-master-thesis-Typst-template)上同步更新，欢迎各位学弟学妹提交反馈，共同完善此模板

> [Typst](https://typst.app/)是一款可用于出版的可编程标记语言，定位与[$\LaTeX$](https://www.latex-project.org/) 相似

    1. Typst相比于LaTeX最大的优势在于编译速度快，1000页的文件LaTeX编译可能要八分钟，但是Typst可能只要几十秒
    2. Typst安装方便，轻巧易用；不再是LaTeX那种难以看懂的宏语言
        （好吧我承认Typst虽然好看是好看，但是也不是特别好看懂）

## 使用方法​

1. 下载并安装Typst，具体教程请参考[Tutorial of Typst](https://typst.app/docs/tutorial/)

> MacOS的可以使用brew安装

2. 在Vscode（建议）中安装Tinymist Typst插件
3. Git clone本项目到本地
4. 在Vscode中打开 `template/thesis.typ`，将示例内容替换为你自己的内容，保存后插件自动编译输出PDF

也可以使用命令行编译（在 `template` 目录下执行）：

```bash
typst compile thesis.typ --font-path ../fonts
```

> 模板**严格使用学校规范指定的标准字体**：宋体 SimSun、黑体 SimHei、楷体 KaiTi、仿宋 FangSong、微软雅黑、华文中宋、西文 Times New Roman、代码 Courier New。这些字体均为 Windows 系统自带，正常 Windows 电脑直接编译即可。包内 `fonts/` 目录只存放这些标准字体文件（无其他内容），电脑缺少字体时可直接安装，或用 `--font-path ../fonts` 临时加载，无需安装。

在 VSCode + Tinymist 中可在工作区 `.vscode/settings.json` 配置字体路径，保存后插件自动编译：

```json
{
  "tinymist.fontPaths": ["packages/preview/jiangcai-jufe-master-thesis/0.1.1/fonts"]
}
```

> `template/thesis.typ` 既是完整的功能示例，也是一篇 Typst 与本模板的使用教程：
> 正文按系统手册方式分章讲解 Typst 安装编译、文档结构、文字、公式、图表、代码与参考文献的写法，
> 封面、摘要、目录、图表公式、参考文献、附录、致谢的用法均可直接对照模仿；
> 其中 `#kouhu(...)` 用于填充随机中文段落以演示长篇排版效果，替换为自己的正文时删除即可。

## 文档结构

```
#cover()         封面（中英文题目、作者、导师等参数）
#declaration()   独创性声明与使用授权说明
#abstract()      中文摘要 + 英文摘要（关键词）
#multi-outline() 中文目录 / 英文目录 / 图目录 / 表目录 / 公式目录（均自动生成）
正文              一至五级标题、图、表、代码、算法、公式、脚注、引用
#bibliography()  参考文献
附录 / 致谢
```

前置部分（摘要、目录等）页码为罗马数字，正文从阿拉伯数字 1 重新计数；奇偶页页眉分别显示论文标题与当前章标题。

## 模板功能速览​

对照 `template/thesis.typ` 示例文件使用以下功能：

| 功能 | 用法 |
|---|---|
| 封面信息 | `#cover(zh-title1: [...], zh-title2: [...], en-title1: [...], author: [...], mentor: [...], degree: [...], academy: [...], subject: [...], research: [...])` |
| 中英双语目录 | 各级标题旁标注英文，如 `= 绪论 #en[Introduction]`，英文目录（TABLE OF CONTENTS）自动提取生成，无需手动维护 |
| 多级标题 | `=` 至 `=====` 分别为一至五级标题，自动编号为"1 / 1.1 / 1.1.1 /（1）/ ①" |
| 插图 | `#figure(image("./imgs/xx.png", width: 90%), caption: [图标题]) <标签>`，正文中用 `#@标签` 引用；多子图可用 `grid` 并排并手工标注（a）（b），共享一个图号（见示例图5.1） |
| 三线表 | `#figure(tlt(read("./tables/xxx.xlsx", encoding: none)), caption: [表标题])`，从 xlsx 读取数据 |
| 代码清单 | `#code(` ` ```python ... ``` ` `, caption: [代码标题])`，代码左对齐并整体左缩进 2 字符，引用显示"代码X.X" |
| 伪代码 | `#algorithm(caption: [...], input: [...], output: [...], [算法步骤])`，引用显示"算法X.X" |
| 公式 | 行间公式 `$ ... $` 自动编号"（章号.序号）"，后加 `<标签>` 即可用 `#@标签` 引用（显示为"式（X.X）"）；行内公式直接写在段落中 |
| 脚注 | `#footnote([脚注文本])` |
| 参考文献 | `#bibliography("./refs.bib", style: "gb-7714-2015-numeric")`，引用写 `[@文献key]`；多文献合并写 `[@a; @b]` |
| 占位文本 | `#kouhu(builtin-text: "aspirin", indices: 1, length: 100)` 生成随机中文段落；也可用 `custom-text: ("含 English 术语的中文段落",)` 传入自定义语料，`length: 0` 表示整段只输出一遍不截断 |
| 缩略语对照表 / 附录表 | 前置部分可选页，写法见示例（不需要整段删除即可）；表格同样用 `tlt()` 从 `tables/` 下的 xlsx 生成三线表（不加 figure 题注，故不占"表X.X"编号、不进表目录）；如需"主要符号表"，仿照该页再复制一段即可 |

图、表、代码、算法按类型分开计数（如第 2 章第一张图为图2.1、第一张表为表2.1，互不干扰），公式单独连续计数；题注、正文引用与图表公式目录中的编号自动保持一致。

> 若标题需要加标签（如 `= 绪论 #en[Introduction] <first>`)，标签必须写在 `#en[...]` **之后**；写在前面会导致英文标记脱离标题体，英文目录将无法提取该标题的英文（回退显示中文原文）。

> 中文论文中外文术语首次出现时建议写"支持向量机（Support Vector Machine，SVM）"，后文直接使用缩写 SVM，示例正文即按此习惯书写，可对照参考。

## 注意事项​

1. 本项目较为傻瓜，安装好Typst和Vscode对应的Tinymist Typst插件后，就可以运行本项目，完成自己的论文而无需关心格式问题。如果在使用过程中产生了多种问题，请在[讨论区](https://github.com/MaxforCherubim/jufe-thesis-defence-Revealjs-template/discussions)创建相关讨论，我都会尽力解答的
2. 由于Typst也在不断更新，可能会导致本项目产生Bug，除此之外还可能会有其他Bug，请在Github上提交[issues](https://github.com/MaxforCherubim/jufe-thesis-defence-Revealjs-template/issues)，我会及时修复

## 贡献指南​

- 本项目强烈呼吁各位使用者即各位学弟学妹提交反馈，包括但不限于在使用过程中遇到的问题、想到的建议，甚至是小白问题都可以在讨论区创建讨论，我会及时参与讨论的！**我们的所有互动都会成为后来者的学习资料，请积极参加！**
- 如果对本项目感兴趣，甚至想要进一步开发，欢迎提交PR！

## 联系方式​

- 本项目作者是章迎潭，本科17级经济统计1班，硕士23级应用统计2班
- 导师为数理统计系马海强教授
- 邮件：<EMAIL><bay237580157@outlook.com>

## 许可证信息​

本项目开源许可证为[MIT license](https://opensource.org/license/mit/)

[回到顶部](#目录)
