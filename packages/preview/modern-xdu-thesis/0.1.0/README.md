# 西安电子科技大学学位论文 Typst 模板

用 [Typst](https://typst.app) 排版西安电子科技大学本科毕业设计（论文）与硕士学位论文（中文撰写）。
本科与硕士使用独立实现入口并放在同一个包中；`typst init` 的默认模板仍为硕士。

**本模板不是学校官方发布**，版式数值以官方文件与实物论文实测为准；与官方模板存在差异的地方
逐条列在[「与官方模板的差异」](#与官方模板的差异)。

| 硕士（学术 / 专业学位） | 本科毕业设计（论文） |
|---|---|
| ![硕士预览：封面 / 目录 / 正文](https://raw.githubusercontent.com/CoderJackZhu/modern-xdu-thesis/main/docs/images/preview.png) | ![本科预览：封面 / 目录 / 正文](https://raw.githubusercontent.com/CoderJackZhu/modern-xdu-thesis/main/docs/images/preview-bachelor.png) |

## 特性

- **本科与硕士独立版式**：本科使用 150 × 247mm 版心、1.5 倍行距、页眉外侧页码与 0.75 磅单线；硕士保留 155 × 240.93mm 版心、固定 20 磅行距、页脚页码与双横线。
- **实物论文压力测试**：硕士 112 页、本科 55 页；两篇的章起始页、参考文献数量与行距均与源论文一致（本科的分页在转换脚本补页后对齐，说明见验收报告）。
- **学术学位 / 专业学位**：一个参数切换，差异只在封面与题名页的字段。
- **盲审模式**：一个开关隐去封面、题名页与作者简介中的身份信息。
- **图表公式自动编号**：按章编号（图 2.1 / 表 2.1 / 式 (2-1)），插图索引、表格索引、
  目录自动生成，交叉引用直接写 `@标签`。
- **参考文献**：GB/T 7714-2015，写作样式由 Typst 内置引擎完成；中文文献「等」与英文文献
  「et al.」自动区分。
- **不依赖额外字体**：全篇只用宋体、黑体、Times New Roman，按系统字体解析，不内置字体文件。

## 包含与不包含

| 范围 | 说明 |
|---|---|
| 硕士学位论文（中文撰写） | 包含：封面、中英文题名页、声明、中英文摘要、插图索引、表格索引、符号对照表、缩略语对照表、目录、正文、附录、参考文献、致谢、作者简介 |
| 学术学位 / 专业学位 | 包含：由一个参数切换 |
| 盲审模式 | 包含：由一个开关控制 |
| 本科毕业设计（论文） | 包含：可开关封面、中英文摘要、目录、正文、附录、参考文献、致谢；独立 `bachelor` 入口 |
| 本科装订独立表单 | 不包含：诚信书、任务书、中期检查表、成绩评定表、查重报告等由学院另行发放 |
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

包已提交 Typst Universe（[typst/packages#5822](https://github.com/typst/packages/pull/5822)），
**发布后一条命令即可创建项目**：

```bash
typst init @preview/modern-xdu-thesis:0.1.0 my-thesis   # 硕士（默认模板）
cd my-thesis && typst compile thesis.typ                # 编译出 PDF
```

本科没有 `[template]` 入口（一个包只能声明一份默认模板，已留给硕士），
把 [`examples/bachelor-thesis.typ`](examples/bachelor-thesis.typ) 复制到自己的项目后编译即可。

发布前（或想直接用仓库里的开发版）：

```bash
git clone https://github.com/CoderJackZhu/modern-xdu-thesis
cd modern-xdu-thesis
bash dev/pkg-stage.sh                          # 把本仓库注册为本地 Typst 包，只需运行一次
typst compile --root . template/thesis.typ out.pdf               # 硕士默认模板
typst compile --root . examples/bachelor-thesis.typ bachelor.pdf # 本科独立示例
```

`dev/pkg-stage.sh` 把仓库挂到 Typst 的本地包目录，模板里的
`@preview/modern-xdu-thesis:0.1.0` 才能解析到当前工作区。脚本可重复运行，解除用
`bash dev/pkg-stage.sh --remove`。

### 在线编辑（typst.app）

把项目上传到 [Typst Web App](https://typst.app) 即可在线编辑、多人协作，不必安装任何东西。
**但 Web App 没有本机字体**：需要把宋体、黑体、Times New Roman 的字体文件一并上传到项目里
（Windows 在 `C:\Windows\Fonts`，macOS 在 `/System/Library/Fonts` 与 `/Library/Fonts`），
否则正文会显示成方框（豆腐块）。字体有版权，仅供自己项目内使用。

### 本科独立入口

`typst.toml` 的 `[template]` 仍指向硕士 `template/thesis.typ`。本科从包导出的独立
`bachelor` 模块进入，完整文件见 `examples/bachelor-thesis.typ`：

```typ
#import "@preview/modern-xdu-thesis:0.1.0": bachelor

#let (doc, cover, abstract, abstract-en, outline-page, mainmatter,
  appendix, references, acknowledgement) = bachelor.documentclass(
  cover-enabled: true, // 学院封面不同时可设为 false，再自行插入封面
  info: (
    title: ("论文题目第一行", "论文题目第二行"),
    author: "张三",
    department: "人工智能学院",
    major: "智能科学与技术",
    supervisor: ("李四", "王五"),
    class-id: "2101011",
    student-id: "21010100001",
    abstract: [中文摘要……],
    abstract-en: [English abstract...],
    keywords: ("关键词一", "关键词二", "关键词三"),
    keywords-en: ("keyword one", "keyword two", "keyword three"),
  ),
)
```

`info` 字段与硕士基本对应，本科特有的三项：

| 字段 | 说明 |
|---|---|
| `title` | 题目，多行写成数组 `("第一行", "第二行")`，居中排在封面横线上 |
| `class-id` / `student-id` | 班级 / 学号，排在封面右上角 |
| `supervisor` | 导师，可写两人 `("李四", "王五")` |

其余字段（`author`、`department`、`major`、`abstract`、`abstract-en`、`keywords`、
`keywords-en`）与硕士含义相同。`cover-enabled: false` 时封面整页不输出，可插入学院提供的封面。

本科正文一级标题只写 `= 引言`，模板自动生成“第一章 引言”；附录连续调用
`appendix(...)`，会生成“附录 A / B / C”及图 A1、表 B2、式 (C-3)。

## 硕士配置论文信息

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

### 硕士页面顺序

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

### 本科页面顺序

```typ
#show: doc
#cover()
#pagebreak(to: "odd")
#counter(page).update(1) // 中文摘要从 i 开始；必须放在摘要页面之前
#abstract()
#pagebreak(to: "odd")
#abstract-en()
#pagebreak(to: "odd")
#outline-page()

#show: mainmatter
= 引言
…

#appendix(title: "补充材料", body: […])
#pagebreak(to: "odd")
#acknowledgement()
#pagebreak(to: "odd")
#references(entries: (…))
```

封面默认输出并自动留空背面。`cover-enabled: false` 时 `cover()` 不输出内容，可插入学院提供的封面。
完整示例见 `examples/bachelor-thesis.typ`。

### 标题

编号由模板生成，正文里不要手写数字：

```typ
= 第一章 绪论          // 章号写在标题文字里
== 研究背景与意义       // 自动编号 1.1
=== 毫米波信道特性      // 自动编号 1.1.1
==== 路径损耗模型       // 自动编号（1），不进目录
```

上例是硕士写法。本科一级标题写 `= 绪论`，由 `bachelor` 入口自动补“第一章”。

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

标准为 GB/T 7714-2015。把文献写进 `.bib` 文件，正文用 `#cite(<条目键>)` 引用，
末尾在**论文文件里**构造好 bibliography，再交给 `#references`：

```typ
正文……#cite(<koseki2002>)。          // 输出上标 [1]

#references(body: bibliography(
  "/refs.bib", style: "gb-7714-2015-numeric", title: none,
))
```

必须写成 `body:` 而不是 `#references(bib: "/refs.bib")`：`bib` 是一个路径字符串，
Typst 会**在包内部**解析它，指向包目录而不是你的项目，所以对使用者不可用。
换成文档侧构造的 `bibliography` 之后，路径就按你的项目根解析。

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
| 本科封面素材 | 校名书法字与校徽在官方封面里是图形（无文字层），本模板按实测坐标以图片随包分发，版权归学校；`cover-enabled: false` 时不引用 |
| 本科压力测试分页 | 转换脚本为对齐分页骨架补过填充页（Pandoc 丢失复杂表格所致），故「55 页一致」证明的是骨架可对齐；版式数值另有反向测量独立核验（见 `docs/本科验收报告.md`） |

## 目录结构

```
lib.typ          硕士包入口，并导出 bachelor 模块命名空间
bachelor.typ     本科独立实现入口，bachelor.documentclass(info:, cover-enabled:)
bachelor/        本科专用版式、页面与正文规则（不导入硕士 layouts/pages）
layouts/         硕士页面版式核心
pages/           硕士各页面组件
utils/           字体映射与无状态共用工具
template/        硕士示例，也是 typst init 默认复制的目录
examples/        本科完整示例（手动复制使用）
写作要求.md       官方撰写要求对照表 + 提交前自查清单
dev/             验收与维护工具，使用者不需要（不进发布包）
                 ├── check-all.sh        一条命令跑完全部验收
                 ├── verify-*.py         硕士与本科 PDF 反向测量
                 ├── compare-*.py        与官方 PDF 逐行、逐页对照
                 ├── test-*.typ          各场景编译入口与负向测试
                 ├── stress/             硕士 112 页压力测试
                 ├── undergrad/          本科 55 页转换与压力测试
                 └── local-paths.example.sh  本地素材路径配置示例
docs/            格式规格（权威来源、冲突裁定、硬约束）、各部分页面规格、验证报告
```

硕士从 `template/thesis.typ` 开始；本科复制 `examples/bachelor-thesis.typ` 到自己的项目。

## 参考资料

- 西安电子科技大学《毕业设计手册》2019 与教务处优秀毕业设计（论文）Word 样例
- 西安电子科技大学研究生院《研究生学位论文模板（2015 年修订版）2025.01 修订》及配套《撰写要求》
- [xduts](https://github.com/note286/xduts) —— 官方 LaTeX 模板
- [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) —— 本模板的初始骨架（MIT）

## 反馈与许可

排版问题、版式差异请走 [Issues](https://github.com/CoderJackZhu/modern-xdu-thesis/issues)。
报版式差异时请附上官方文件或实物论文的对应页 —— 本项目所有版式结论都以可测量的证据为准。

代码以 MIT 许可发布。本科封面使用的校名书法字与校徽是学校标识，版权归学校，仅随封面组件
分发（`cover-enabled: false` 时不引用）；在其它场合使用请另行获得授权。
