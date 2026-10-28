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
  - [功能速查​](#功能速查)
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

### 安装 Typst 与编辑器

1. 下载并安装 Typst，具体教程请参考[Tutorial of Typst](https://typst.app/docs/tutorial/)

> MacOS的可以使用brew安装

2. 在Vscode（建议）中安装Tinymist Typst插件

### 获取模板并编译

1. Git clone本项目到本地
2. 在Vscode中打开**版本根目录**（即包含 `template/`、`work/`、`fonts/` 的 `0.1.1/` 目录），编辑 `template/thesis.typ`，将示例内容替换为你自己的内容，保存后插件自动编译输出PDF

也可以使用命令行编译（在版本根目录 `0.1.1/` 下执行）：

```bash
typst compile template/thesis.typ --font-path fonts
```

> 注意：参考文献路径 `#references("/template/refs.bib")` 从项目根目录写起（以 `/` 开头），
> 故编译与 Tinymist 的根目录都必须是版本根目录，不要在 `template/` 子目录内单独编译。

**字体**：模板严格使用学校规范指定的标准字体——宋体 SimSun、黑体 SimHei、楷体 KaiTi、仿宋 FangSong、微软雅黑、华文中宋、西文 Times New Roman；规范未指定的两处——代码用 Courier New（Windows 自带、论文代码清单的传统选择，模板自选），数学公式用编译器内置的 New Computer Modern Math（Times New Roman 无 OpenType MATH 表，不能排公式）。上述中西文字体均为 Windows 系统自带，正常 Windows 电脑直接编译即可。包内 `fonts/` 目录只存放这些标准字体文件（无其他内容），电脑缺少字体时可直接安装，或用 `--font-path fonts` 临时加载，无需安装。在 VSCode + Tinymist 中可在工作区 `.vscode/settings.json` 配置字体路径，保存后插件自动编译：

```json
{
  "tinymist.fontPaths": ["packages/preview/jiangcai-jufe-master-thesis/0.1.1/fonts"]
}
```

### 版本模式

同一源文件可产出三种版本，由文档顶部的 `#version-mode.update(...)` 控制；命令行可用 `--input` 临时指定：

| 模式 | 效果 |
|---|---|
| `"review"`（默认） | 导师阅览完整版：封面、独创性声明、致谢齐全 |
| `"blind"` | 送审匿名版：封面信息表隐去作者/导师整行，独创性声明页与致谢整节（含标题）自动消失 |
| `"print"` | 无封面打印版：封面不渲染（页眉论文标题不受影响），声明页起排为第 1 页 |

```bash
typst compile template/thesis.typ blind.pdf --font-path fonts --input mode=blind
typst compile template/thesis.typ print.pdf --font-path fonts --input mode=print
```

模式值拼写错误时编译立即报错并列出合法取值；Tinymist 预览不传 `--input`，始终按默认 review 版渲染。

### 表格：xlsx 三线表与自动续表

正文表格用 `tlt()` 从 xlsx 读取数据，自动生成规范三线表：

```typst
#figure(tlt(read("./tables/xxx.xlsx", encoding: none)), caption: [表标题])
```

表格跨页时**自动续表**：续页自动标注“续表”并重复表头，无需手动拆表。前置部分的缩略语对照表、附录中的表同样用 `tlt()` 生成（不加 figure 题注，故不占“表X.X”编号、不进表目录）；缩略语对照表由 `multi-outline(abbrev-list: true, abbrev-body: tlt(...))` 生成（写法见示例），如需“主要符号表”，仿照该页再复制一段即可。

### 标题与中英双语目录

- `=` 至 `=====` 分别为一至五级标题，自动编号为“1 / 1.1 / 1.1.1 /（1）/ ①”
- 各级标题旁标注英文，如 `= 绪论 #en[Introduction]`，英文目录（TABLE OF CONTENTS）自动提取生成，无需手动维护

> 若标题需要加标签（如 `= 绪论 #en[Introduction] <first>`)，标签必须写在 `#en[...]` **之后**；写在前面会导致英文标记脱离标题体，英文目录将无法提取该标题的英文（回退显示中文原文）。

### 图、公式、代码与算法

- 插图：`#figure(image("./imgs/xx.png", width: 90%), caption: [图标题]) <标签>`，正文中用 `#@标签` 引用；多子图用 `subfloat()` 并排并手工标注（a）（b）子题，共享一个图号（见教程示例「混排」一节）
- 公式：行间公式 `$ ... $` 自动编号“（章号.序号）”，后加 `<标签>` 即可用 `#@标签` 引用（显示为“式（X.X）”）；行内公式直接写在段落中
- 代码清单：`#code(..., caption: [代码标题])` 包裹代码块，代码左对齐并整体左缩进 2 字符，引用显示“代码X.X”
- 伪代码：`#algorithm(caption: [...], input: [...], output: [...], [算法步骤])`，步骤用 `\` 分行、行首行号自动编排（`numbered: false` 关闭），引用显示“算法X.X”
- 脚注：`#footnote([脚注文本])`

图、表、代码、算法按类型分开计数（如第 2 章第一张图为图2.1、第一张表为表2.1，互不干扰），公式单独连续计数；题注、正文引用与图表公式目录中的编号自动保持一致。

### 参考文献、附录与致谢

- 参考文献：`#references("/template/refs.bib")` 一行生成 GB/T 7714—2025 文献表（标题外置、链接蓝色局部化）；正文引用写 `[@文献key]`，多文献合并写 `[@a; @b]`
- 附录：`#appendix[...]` 包裹附录内容
- 致谢：`#thanks[...]` 包裹致谢内容，签名姓名/年月自动取自封面；blind 模式下整节自动不渲染

### 占位文本

`#kouhu(builtin-text: "aspirin", indices: 1, length: 100)` 生成随机中文段落，用于演示长篇排版效果，替换为自己的正文时删除即可；也可用 `custom-text: ("含 English 术语的中文段落",)` 传入自定义语料，`length: 0` 表示整段只输出一遍不截断。

> 中文论文中外文术语首次出现时建议写“支持向量机（Support Vector Machine，SVM）”，后文直接使用缩写 SVM，示例正文即按此习惯书写，可对照参考。

> `template/thesis.typ` 既是完整的功能示例，也是一篇 Typst 与本模板的使用教程：
> 正文按系统手册方式分章讲解 Typst 安装编译、文档结构、文字、公式、图表、代码与参考文献的写法，
> 封面、摘要、目录、图表公式、参考文献、附录、致谢的用法均可直接对照模仿。

## 文档结构

```
#cover(...)       封面（中英文题目、作者、导师等参数）
#declaration()    独创性声明与使用授权说明（blind 模式自动跳过）；
                  可选 signature/mentor-signature/date 传 image，电子签名与手写日期浮于横线上方
#abstract(...)    中文摘要 + 英文摘要（关键词）
#multi-outline()  中文目录 / 英文目录 / 图目录 / 表目录 / 公式目录（均自动生成）；
                  代码目录、伪代码目录默认关闭，用开关开启：
                  #multi-outline(code-list: true, algorithm-list: true)；
                  图表类目录各有布尔开关（figure-list / table-list / equation-list /
                  code-list / algorithm-list），开关开启但全文无对应条目时整页自动跳过；
                  缩略语对照表为可选页：abbrev-list 开关 + abbrev-body 内容（默认关闭），
                  如 abbrev-body: tlt(read("./tables/缩略语对照表.xlsx", encoding: none))
正文               一至五级标题、图、表、代码、算法、公式、脚注、引用
#references(...)  参考文献
#appendix[...]    附录
#thanks[...]      致谢（blind 模式整节自动消失；签名姓名/年月自动取自封面）
```

前置部分（摘要、目录等）页码为罗马数字，正文从阿拉伯数字 1 重新计数；奇偶页页眉分别显示论文标题与当前章标题。

## 功能速查

各功能的详细用法见上文「使用方法」，此处一行一条供速查（对照 `template/thesis.typ` 示例文件使用）：

| 功能 | 写法 |
|---|---|
| 版本模式 | `#version-mode.update(sys.inputs.at("mode", default: "review"))`，命令行 `--input mode=blind` |
| 封面 | `#cover(zh-title1: [...], author: [...], mentor: [...], ...)` |
| 多级标题 | `=` 至 `=====`（一至五级） |
| 中英双语目录 | `= 绪论 #en[Introduction]` |
| 插图 | `#figure(image("./imgs/xx.png", width: 90%), caption: [图标题]) <标签>` |
| 三线表（自动续表） | `#figure(tlt(read("./tables/xxx.xlsx", encoding: none)), caption: [表标题])` |
| 代码清单 | `#code(..., caption: [代码标题])` |
| 伪代码 | `#algorithm(caption: [...], input: [...], output: [...], [算法步骤])`（`\` 分行自动编号，`numbered: false` 关闭） |
| 公式 | `$ ... $ <标签>`，正文 `#@标签` 引用 |
| 不同元素左右混排 | `#beside(元素1, 元素2, ...)`（各栏等宽、独立编号） |
| 同类多子元素混排 | `#subfloat(kind: image/table/raw/"algorithm", caption: [...], ([（a）子题], 内容), ...)`（共享一个编号；算法子项可扩展为 `(子题, 内容, 输入, 输出)` 四元组） |
| 脚注 | `#footnote([脚注文本])` |
| 参考文献 / 附录 / 致谢 | `#references("/template/refs.bib")`；`#appendix[...]`；`#thanks[...]` |
| 占位文本 | `#kouhu(builtin-text: "aspirin", indices: 1, length: 100)` |
| 缩略语对照表 / 附录表 | `tlt()` 生成、不加题注（写法见示例） |

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
