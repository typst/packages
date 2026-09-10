# 西安电子科技大学硕士学位论文 Typst 模板

用 [Typst](https://typst.app) 排版西安电子科技大学硕士学位论文（中文撰写）。
版式依据研究生院《研究生学位论文模板》与配套《撰写要求》逐项校准，支持**学术学位 / 专业学位**
与**盲审模式**，开箱即可写出可送审的 PDF。

![预览：封面 / 目录 / 正文](https://raw.githubusercontent.com/CoderJackZhu/modern-xdu-thesis/main/docs/images/preview.png)

## 特性

- **版式与官方模板一致**：页边距、版心、固定 20 磅行距、章标题间距、页眉双横线、
  奇偶页码、每章奇数页起等逐项对照官方输出，并用一份 112 页的真实论文验证过总页数与分页。
- **学术学位 / 专业学位**：一个参数切换，差异只在封面与题名页的字段。
- **盲审模式**：一个开关隐去封面、题名页与作者简介中的身份信息。
- **图表公式自动编号**：按章编号（图 2.1 / 表 2.1 / 式 (2-1)），插图索引、表格索引、
  目录自动生成，交叉引用直接写 `@标签`。
- **参考文献**：GB/T 7714-2005，写作样式由 Typst 内置引擎完成；中文文献「等」与英文文献
  「et al.」自动区分。
- **不依赖额外字体**：全篇只用宋体、黑体、Times New Roman，按系统字体解析，不内置字体文件。

## 包含与不包含

| 范围 | 说明 |
|---|---|
| 硕士学位论文（中文撰写） | 包含：封面、中英文题名页、声明、中英文摘要、插图索引、表格索引、符号对照表、缩略语对照表、目录、正文、附录、参考文献、致谢、作者简介 |
| 学术学位 / 专业学位 | 包含：由一个参数切换 |
| 盲审模式 | 包含：由一个开关控制 |
| 本科毕业设计 | 不包含：请用 [typst_xdutemplate](https://github.com/Hubert9982/typst_xdutemplate) |
| 博士学位论文 | 不包含 |
| 英文撰写的学位论文 | 不包含 |
| 开题报告 / 中期考核 / 答辩表格 | 不包含：不属于学位论文正文 |
| 详细中文摘要（单独装订） | 不包含：学校规定与论文分开装订 |

## 环境要求

- **Typst 0.15** 或更高版本。安装方式二选一：
  - **编辑器插件（推荐）**：VS Code / Cursor 安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)，
    打开 `.typ` 文件即可实时预览，插件自带编译器。
  - **命令行**：`brew install typst`（macOS）、`winget install --id Typst.Typst`（Windows），
    或参考 [官方安装说明](https://github.com/typst/typst#installation)。
- **字体**：系统自带即可。Windows 的 `SimSun` / `SimHei`，macOS 的 `Songti SC` / `Heiti SC`，
  Linux 安装 `fonts-noto-cjk`。模板不内置字体文件。

## 快速开始

```bash
git clone https://github.com/CoderJackZhu/modern-xdu-thesis
cd modern-xdu-thesis
bash dev/pkg-stage.sh                          # 把本仓库注册为本地 Typst 包，只需运行一次
typst compile --root . template/thesis.typ out.pdf
```

`dev/pkg-stage.sh` 把仓库挂到 Typst 的本地包目录，模板里的
`@preview/modern-xdu-thesis:0.1.0` 才能解析到当前工作区。脚本可重复运行，
解除用 `bash dev/pkg-stage.sh --remove`。

模板目前未发布到 Typst Universe，因此暂时不能用 `typst init @preview/modern-xdu-thesis:0.1.0`，
请按上面的方式克隆使用。

## 配置论文信息

打开 `template/thesis.typ`，把 `documentclass(...)` 里的 `info` 换成你自己的信息：

| 字段 | 说明 |
|---|---|
| `title` / `title-en` | 中英文题目，多行写成数组 `("第一行", "第二行")` |
| `author` / `author-en` | 姓名 / 拼音 |
| `discipline` / `subdiscipline` | 一级学科 / 二级学科（学术学位） |
| `domain` | 领域（专业学位） |
| `degree-name` | 学位名称，如 `"电子信息硕士"` |
| `supervisor` | 导师，`("李四", "教授")` |
| `enterprise-supervisor` | 企业导师，仅专业学位使用；学术学位填 `(none, none)` |
| `department` | 学院 |
| `submit-date` | 提交日期，`(year: 2025, month: 6)` |
| `school-code` / `clc` / `student-id` / `secret-level` | 题名页左上角信息栏（西电代码 `10701`） |
| `abstract` / `keywords` | 中文摘要与关键词 |
| `abstract-en` / `keywords-en` | 英文摘要与关键词 |
| `notation` | 符号对照表，`(("α", "路径损耗指数"), …)` |
| `abbreviations` | 缩略语对照表，`(("MIMO", "全称", "中文"), …)` |

关键词写成数组，模板会按「逗号 + 空格」分隔并处理末尾标点。

## 写作指南

> 学校对论文各部分的具体规定（题目字数、摘要篇幅、关键词个数、图表公式写法、参考文献数量、
> 作者简介要求、装订顺序、盲审注意事项等），以及**哪些由模板自动满足、哪些必须自己保证**，
> 见 [写作要求](写作要求.md)。提交前可对照其中的自查清单逐项检查。

### 页面顺序

前置与后置部分按下面的顺序调用，页与页之间用 `#pagebreak(to: "odd")` 分隔，
使每页都从奇数页开始：

```typ
#show: doc

#cover()
#pagebreak(to: "odd")
#title-cn()                     // 中文题名页
#pagebreak(to: "odd")
#title-en()                     // 英文题名页
#pagebreak(to: "odd")
#declaration()                  // 声明
#pagebreak(to: "odd")
#abstract()                     // 中文摘要（罗马页码从这一页起为 I）
#pagebreak(to: "odd")
#abstract-en()                  // ABSTRACT
#pagebreak(to: "odd")
#list-of-figures()              // 插图索引
#pagebreak(to: "odd")
#list-of-tables()               // 表格索引
#pagebreak(to: "odd")
#notation()                     // 符号对照表
#pagebreak(to: "odd")
#abbreviations()                // 缩略语对照表
#pagebreak(to: "odd")
#outline-page()                 // 目录

#show: mainmatter.with(header-title: "西安电子科技大学硕士学位论文")

= 第一章 绪论
…

#pagebreak(to: "odd")
#appendix()                     // 附录
#pagebreak(to: "odd")
#references()                   // 参考文献
#pagebreak(to: "odd")
#acknowledgement()              // 致谢
#pagebreak(to: "odd")
#bio()                          // 作者简介
```

`template/thesis.typ` 就是一份可运行的完整示例，直接改它即可。

### 标题

编号由模板生成，正文里不要手写数字：

```typ
= 第一章 绪论          // 章号写在标题文字里
== 研究背景与意义       // 自动编号 1.1
=== 毫米波信道特性      // 自动编号 1.1.1
==== 路径损耗模型       // 自动编号（1），不进目录
```

### 图、表与公式

```typ
#figure(image("fig.png", width: 80%),
  caption: [毫米波大规模 MIMO 系统框图])      // 图题在下，编号「图 2.1」

#figure(table(columns: 3, [参数], [符号], [取值], …),
  caption: [仿真参数设置])                    // 表题在上，「表 2.1」

$ bold(y) = bold(A) bold(h) + bold(n) $       // 公式编号「(2-1)」，右对齐
```

图、表、公式按章编号，正文中引用写 `@标签`。题注里可以正常引用文献，
插图索引与表格索引不会因此打乱参考文献的编号顺序。

需要让索引里显示更短的文字时（相当于 LaTeX 的 `\caption[短]{长}`），用 `索引题注`：

```typ
#figure(rect(width: 5cm, height: 2.5cm),
  caption: 索引题注([系统框图], [毫米波大规模 MIMO 系统框图 @zhang2023]))
```

### 参考文献

标准为 GB/T 7714-2005。把文献写进 `.bib` 文件，正文用 `#cite(<条目键>)` 引用，
末尾调用 `#references`：

```typ
正文……#cite(<koseki2002>)。          // 输出上标 [1]

#references(bib: "/refs.bib")
```

`.bib` 的路径要写成**根相对**（前导 `/`，相对 `typst --root`）。

也可以直接把排好的条目交给模板：

```typ
#references(entries: ("作者. 题名[M]. 北京: 出版社, 1993.", …))
```

### 盲审模式

`documentclass(blind: true)` 即可。封面与中英文题名页隐去作者与导师姓名；致谢只保留标题；
作者简介中的本文作者姓名替换为「（盲审隐去）」，**保留「第一作者」「第一发明人」等排序标记**，
合作者署名按惯例保留。

`author` 这类信息写成字符串时模板会自动隐去；写成 markup（`[…]`）的内容模板无法改写，需要自行处理。

## 常见问题

**编译时提示 `unknown font family: simsun` 之类的警告？**
是字体回退链里本机没有的候选字体，属正常提示。只要正文没有出现方框（豆腐块）就不用处理。

**中文显示成方框？**
系统缺少中文字体。按上面的「环境要求」安装对应字体后重新编译。

**参考文献列表是空的？**
正文里没有用 `#cite(<条目键>)` 引用过文献。参考文献只收录被引用过的条目。

**我不会 Typst，能直接用来写论文吗？**
可以。日常使用只涉及「填字段」与「写标题正文」，`.bib` 之外几乎不需要语法知识。
语法参考 [Typst 中文文档](https://typst-doc-cn.github.io/docs/)。

**怎么换成专业学位 / 学术学位？**
改 `degree` 参数。专业学位记得填 `enterprise-supervisor`，学术学位填 `(none, none)`。

**页数和 Word 排出来的不一样？**
字体度量不同会导致换行位置有细微差异，可能相差一两页，属正常现象。

**能改字体或字号吗？**
可以但不建议，学校格式检查会核对字体名。字体映射在 `utils/style.typ`，
版式常量在 `layouts/doc.typ`，修改后请对照官方模板核对版式。

## 与官方模板的差异

| 项 | 说明 |
|---|---|
| 逐行位置 | 官方 PDF 嵌入 SimSun，本模板使用系统宋体，字体度量不同导致换行点不同，因此逐行位置无法逐行对齐；行距、字号、边界、章标题起排位置均一致 |
| 封面与声明 | 官方 LaTeX 模板有两代实现（2024.04 与新版重写版），本模板采用 2024.04 版与 Word 2025.01 版 |
| 符号对照表字号 | 本模板 12pt；参考论文为 10.5pt，官方示例未包含此页 |
| 附录页 | 官方示例与参考论文均无附录页，其坐标按其它后置部分推导 |

## 目录结构

```
lib.typ          包入口，documentclass(degree:, blind:, fonts:, info:)
layouts/         页面版式核心
pages/           各页面组件：封面、题名页、声明、摘要、索引、目录、后置部分
utils/           字体映射、样式常量、计数器
template/        可运行的示例论文，也是 typst init 复制的目录
写作要求.md       官方撰写要求对照表 + 提交前自查清单
dev/             验收与维护工具，使用者不需要（不进发布包）
                 ├── check-all.sh        一条命令跑完全部验收
                 ├── verify-*.py         各部分版式验收（前置 / 索引 / 正文）
                 ├── compare-*.py        与官方 PDF 逐行、逐页对照
                 ├── probe-*.typ         早期技术验证用例
                 ├── test-*.typ          各场景编译入口
                 ├── stress/             用真实论文压测模板
                 └── local-paths.example.sh  本地素材路径配置示例
docs/            格式规格（权威来源、冲突裁定、硬约束）、各部分页面规格、验证报告
```

撰写论文只需要 `template/` 目录。

## 参考资料

- 西安电子科技大学研究生院《研究生学位论文模板（2015 年修订版）2025.01 修订》及配套《撰写要求》
- [xduts](https://github.com/note286/xduts) —— 官方 LaTeX 模板
- [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) —— 本模板的初始骨架（MIT）

## License

MIT
