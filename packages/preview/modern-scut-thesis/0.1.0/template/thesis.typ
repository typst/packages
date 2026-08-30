#import "@preview/modern-scut-thesis:0.1.0": bilingual-bibliography, documentclass, 字号, 辅助字体
#import "@preview/algorithmic:1.0.7"
#import "build.typ": blind, include-acknowledgement, print-ready, twoside
#import "info.typ": doctype, equivalent, info, international, kind
#import "data.typ": * // 实验数据常量，见第三章「实验数据管理」一节

// SCUT 学位论文模板

#let (
  doc,
  preface,
  mainmatter,
  appendix,
  fonts-display-page,
  cover,
  decl-page,
  abstract,
  abstract-en,
  bibliography,
  outline-page,
  list-of-figures,
  list-of-tables,
  notation,
  acknowledgement,
  publications,
  threeline-table,
  theorem,
  lemma,
  corollary,
  definition,
  proposition,
  example,
  remark,
  proof,
  algorithm-figure,
) = documentclass(
  doctype, // "master" | "doctor"
  twoside, // 双面模式
  blind, // 盲审级别："none" | "single" | "double"
  print-ready: print-ready, // 印刷版空白页
  kind: kind, // "academic" | "professional"
  international: international, // 留学生学位论文
  equivalent: equivalent, // 同等学力申请学位
  info, // 论文信息
  bibliography: bibliography.with("ref.bib", style: "GB-T-7714—2015（顺序编码，双语，姓名不大写，无URL、DOI）.csl"),
)

// 全局页面设置
#show: doc

// 字体展示测试页（调试用）
// #fonts-display-page()

// 封面
#cover()

// 声明页
#decl-page()

// 前言：罗马数字页码
#show: preface

// 中文摘要
#abstract(
  keywords: ("关键词一", "关键词二", "关键词三", "关键词四"),
)[
  摘要是学位论文内容的简短陈述，应体现论文工作的核心思想。
  论文摘要应力求语言精练准确。摘要内容应涉及本项科研工作的目的和意义、
  研究思想和方法、研究成果和结论。
  硕士学位论文的中文摘要一般约 500～800 字，必须突出论文的新见解。

  关键词一般为 3～5 个，按词条的外延层次排列（外延大的排在前面）。
  关键词之间用分号分开，最后一个关键词后不打标点符号。
]

// 英文摘要
#abstract-en(
  keywords: ("Keyword1", "Keyword2", "Keyword3", "Keyword4"),
)[
  The content of the English abstract and keywords should be consistent with the Chinese abstract and keywords, conform to English grammar, and be smooth and fluent in wording.
]

// 目录
#outline-page()

// 插图目录与表格目录（不需要时可删除或注释）
#list-of-figures()
#list-of-tables()

// 主要符号对照表（置于前言部分；条目中的数学式自动转为行内，不参与编号）
#notation[
  / $\{I\}$: 惯性坐标系
  / $\{B\}$: 体坐标系
  / $bold(q) = [q_0, q_1, q_2, q_3]^sans(T)$: 单位四元数
  / $bold(eta)_q$: 位姿向量
  / $bold(nu) = [u, v, w, p, q, r]^sans(T)$: 速度向量
  / $u, v, w$: 纵向、横向、垂向速度
  / $p, q, r$: 横滚、俯仰、偏航角速度
  / $bold(tau)$: 控制输入向量
  / $bold(M)$: 惯性矩阵
  / $bold(C)(bold(nu))$: 科里奥利力和向心力矩阵
  / $bold(D)(bold(nu))$: 流体阻尼矩阵
  / $bold(g)_q (bold(q))$: 恢复力向量
  / $bold(R)(bold(q))$: 旋转矩阵
  / $bold(J)_q (bold(eta)_q)$: 运动学变换矩阵
  / $m$: 水下机器人质量
  / $bold(I)_b$: 转动惯量矩阵
  / $I_c (bold(x))$: 观测图像
  / $J_c (bold(x))$: 无退化场景辐射亮度
  / $B_c^infinity (bold(x))$: 无限远处背景光
  / $t_c (bold(x))$: 透射率
  / $beta_c$: 总衰减系数
  / $d(bold(x))$: 场景点到相机的距离
  / $bold(x)_0$: 原始数据样本
  / $bold(x)_t$: 第 $t$ 步噪声状态
  / $T$: 总扩散步数
  / $beta_t$: 噪声方差调度参数
  / $alpha_t$: 噪声调度参数
  / $macron(alpha)_t$: 累积乘积
  / $bold(epsilon)$: 高斯噪声
  / $bold(epsilon)_theta$: 噪声预测网络
  / $hat(bold(x))_0$: 预测的原始数据
  / $sigma_t$: 随机性参数
  / $cal(D)$: 专家轨迹数据集
  / $bold(o)$: 观测
  / $bold(a)$: 动作
  / $pi_theta$: 策略网络
  / $H$: 预测时域
  / $n_("act")$: 动作预测长度
  / $bold(I)_("rgb")$: RGB输入图像
  / $bold(I)_d$: 度量深度图像
  / $bold(c)$: 目标条件向量
  / $bold(F)$: 视觉特征图
  / $bold(gamma), bold(beta)$: 特征级线性调制参数
  / $bold(F)_("vit")$: DinoV2骨干特征
]

// 正文
#show: mainmatter

= 绪　论

绪论（或引言）一般作为第一章，是论文主体的开端。绪论的内容应简要说明研究工作的目的、范围、相关领域的前人工作和知识空白、理论基础、研究设想、研究方法和实验设计、预期结果和意义等。应言简意赅，不要与摘要雷同，不要写成摘要的注释。一般教科书中有的知识，在绪论中不必赘述。

学位论文为了反映出作者确已掌握了坚实的基础理论和系统的专门知识，具有开阔的科学视野，对研究方案作了充分论证，因此，有关历史回顾和前人工作的综述分析，以及理论分析等，可以单独成章，用足够的文字叙述。

== 研究背景

== 国内外研究现状

引用参考文献时采用顺序编码制，以上标方括号标注，如文献 @蒋有绪1998 所述。

= 正文要求

论文正文是学位论文的核心部分，占主要篇幅。正文应该结构合理，层次分明，推理严密，重点突出，图表、参考文献规范，内容集中简练，文笔通顺流畅。博士学位论文不少于6万字，硕士学位论文为3～5万字。

对本研究内容及成果应进行较全面、客观的理论阐述，应着重指出本研究内容中的创新、改进与实际应用之处。理论分析中，应将他人研究成果单独书写，并注明出处，不得将其与本人提出的理论分析混淆在一起。

自然科学的论文应推理正确，结论清晰，无科学性错误。

== 理论分析

=== 基本概念

（此处填写基本概念和理论阐述。定理、引理、证明等环境的编写方法见第三章。）

=== 核心算法

（此处填写算法描述。算法伪代码编写方法见第三章。）

== 图表与公式

每个图均应有图题，图号按章编排，图题置于图下。

表序按章编排，表序与表名之间空一格，表名中不允许使用标点符号，表名后不加标点。表序与表名置于表上。表格采用三线表格式：顶线和底线为粗线，表头下线为细线，无竖线。

公式居中书写，序号按章编排。公式可以是独立编号的行间公式，也可以是前段文字的自然延续——前者公式后留空行另起段，后者则不加空行使后续文字视为同段延续。

图、表、公式的具体 Typst 写法见第三章。

== 实验验证

=== 实验设计

（此处填写实验设计方案。）

== 结果分析

（此处填写实验结果与分析。实验数据建议统一维护在 `data.typ` 中，如：共进行 #exp-rounds 回合实验，成功率 #exp-success-rate%，平均延迟 #exp-avg-latency ms。写法见第三章「实验数据管理」一节。）

== 本章小结

论文正文各章后应有一节"本章小结"。

= 本模板说明

本章说明如何用本 Typst 模板实现 SCUT 规范中的各项格式。

== Typst 简介

Typst 是一门用 Rust 编写的现代化排版系统，于 2023 年公开发布，目标是成为 LaTeX 的现代替代品：既具备与 LaTeX 相当的排版能力，又在易用性和编译速度上大幅改进。本模板即基于 Typst 实现。

速度是 Typst 相对 LaTeX 最直观的优势。LaTeX 每次修改都需完整重新编译，长文档动辄数秒乃至数分钟；Typst 采用增量编译，首次编译通常在毫秒到秒级，此后每次修改只需数毫秒即可更新结果，配合编辑器插件可以边写作边预览。此外，Typst 编译器是数十 MB 的单一可执行文件，不必像 TeX Live 那样安装数 GB 的宏包体系，第三方宏包在首次引用时自动下载缓存；数学公式、图表编号、交叉引用、目录、参考文献管理等在 LaTeX 中需借助宏包的功能均为内置能力；其标记语法与脚本语言经过统一设计，报错信息也较 LaTeX 清晰易读。

关于 Typst 的定位、性能与适用场景的更多讨论，可参阅小蓝书导引章“为什么学习 Typst”一节@raindrop-blue；中文资料与常见问题的汇总见“Typst 中文社区导航”@typst-guide-cn。

== 环境配置

使用本模板前需完成三项准备：安装 Typst 编译器、安装模板所需字体、创建论文项目。

=== 安装 Typst 编译器

Typst 各平台的安装途径与编辑器配置，小蓝书导引章“配置 Typst 运行环境”一节已有详细介绍@raindrop-blue，此处按官方 README 的 Installation 一节列出常用方式#footnote[Typst 官方仓库 README 的安装说明：#link("https://github.com/typst/typst?tab=readme-ov-file#installation")]。安装完成后执行 `typst --version` 验证。

*包管理器方式。* Windows 使用 winget，安装后自动加入 PATH：

```powershell
winget install --id Typst.Typst
```

macOS 使用 Homebrew：

```shell
brew install typst
```

Ubuntu 使用 snap：

```shell
sudo snap install typst
```

BTW：

```shell
sudo pacman -S typst
```

其余发行版的打包情况可在 Repology 查询。注意包管理器中的版本可能滞后于官方最新发布。

*Docker 方式。* 不想在本机安装编译器时，可直接运行官方预构建镜像。镜像内不含中文字体，编译本模板需同时挂载源码目录与宿主机字体目录：

```shell
docker run --rm -v "$PWD":/data -v /usr/share/fonts:/usr/share/fonts:ro \
  -w /data ghcr.io/typst/typst:latest compile thesis.typ
```

*手动构建方式。* 安装 Rust 工具链后，可安装最新发布版：

```shell
cargo install --locked typst-cli
```

或跟踪主分支的开发版：

```shell
cargo install --git https://github.com/typst/typst --locked typst-cli
```

也可以从 GitHub Releases 直接下载预编译二进制放入 PATH，此后用 `typst update` 升级。

本地编辑推荐使用 VS Code 搭配 Tinymist 插件：安装后打开 `.typ` 文件即可获得语法高亮与报错提示，按下 `Ctrl + K V` 开启实时预览，每次保存自动增量编译。

*Typst Web App。* 不想本地安装时，可使用官方在线编辑器 Typst Web App（https://typst.app ）：浏览器打开即用，提供实时预览与多人协作。对本模板而言有几点不便。其一，模板依赖的宋体、黑体、楷体、仿宋等中文字体需以字体文件形式上传到项目中才能正确渲染；其二，命令行构建参数不可用，盲审、印刷等构建变体需直接修改项目根目录 `build.typ` 中的默认值；其三，查重版依赖页范围抽取与关闭 PDF 标签（均为命令行导出选项），无法在 Web App 中直接完成，可下载完整 PDF 后用 PDF 工具抽取正文页面，或改用本地 Typst CLI。

=== 安装字体

本模板不随仓库分发字体文件，而是依赖操作系统已安装的字体：中文部分需要宋体（SimSun）、黑体（SimHei）、楷体（KaiTi）、仿宋（FangSong），拉丁字符统一使用 Times New Roman。Windows 自带上述字体，开箱即用；macOS 与 Linux 需自行安装，前者通过字体册安装字体文件，后者将字体文件复制到 `~/.local/share/fonts` 后执行 `fc-cache -f` 刷新缓存。安装完成后可用 `typst fonts` 确认编译器能识别到这些字体；若成稿字体与预期不符，可临时启用 `#fonts-display-page()` 检查实际命中的字体。

如有特殊需要，可在 `documentclass` 的 `fonts` 参数中覆盖字体配置（配置结构见模板源码仓库的 `utils/style.typ`），当您这么做时，请自行谨慎核对学院对字体的要求。

=== 创建论文项目

模板已发布至 Typst Universe，使用 `typst init` 即可创建论文项目：

```shell
typst init @preview/modern-scut-thesis:0.1.0 my-thesis
cd my-thesis
typst compile thesis.typ
```

VS Code 用户还可通过 Tinymist 插件的模板库创建：按下 `Ctrl + Shift + P` 打开命令面板，输入 `Typst: Show available Typst templates (gallery)`，搜索 `modern-scut-thesis`，点击 `+` 号生成项目目录。

Typst Web App 用户在首页 `Start from template` 中选择 `modern-scut-thesis` 即可在线创建项目。

模板源码托管于 GitHub 仓库（https://github.com/snow-trap/modern-scut-thesis ），可用于提交 Issue 与 PR。写作过程中也建议用 Git 管理自己的论文：`.typ` 源文件是纯文本，按章节粒度提交，便于回退、对比与协作；编译产物（PDF）建议写入 `.gitignore`，只跟踪源文件。

完成本节三项准备后，在论文项目根目录执行 `typst compile thesis.typ` 即可编译出本说明文档。盲审、查重、印刷等场景的构建命令见本章“构建变体”一节。

== 论文信息

论文题目、作者、学号、导师、学院、专业、日期等元信息统一在项目根目录的 `info.typ` 中维护，封面、英文内封、提名页、摘要页与 PDF 元信息均从此读取，正文无需重复填写。其中分类号 `clc` 按论文主题对照《中国图书馆分类法》填写，自动渲染于提名页左上角。

学位类型相关变体也在 `info.typ` 顶部配置：`doctype` 选择硕士（`"master"`）或博士（`"doctor"`）；`kind: "professional"` 为专业学位；`international: true` 为留学生学位论文；`equivalent: true` 为同等学力申请学位。后三者均作用于盲审封面：专业学位将信息栏改用“学位类别”，同等学力在标题下加括号副题。

== 实验数据管理

实验设置与结果中的数值（回合数、成功率、延迟等）往往在全文中多处出现，写作过程中还会反复修订。建议把这些常量统一定义在项目根目录的 `data.typ` 中，正文用变量引用，修改一处即全部更新：

#figure(
  ```typ
  // data.typ
  #let exp-rounds = 20       // 实验回合数
  #let exp-success-rate = 92.5 // 成功率 (%)

  // 章节文件或 thesis.typ 顶部
  #import "data.typ": *

  共进行 #exp-rounds 回合实验，成功率 #exp-success-rate%。
  ```,
  caption: [实验数据集中管理示例],
)

常量不限于数值，也可以是数学式（如 `#let train-lr = $4 times 10^(-4)$`）或内容块，表格的 `data` 参数中同样可以使用。为避免通配导入的名称冲突，建议常量统一加前缀（如 `exp-`、`train-`）。

== 章节标题

正文中 `=` 对应章标题，`==` 对应节标题，`===` 对应条标题。各层级自动按 SCUT 规范编号（如"第一章"、"1.1"、"1.1.1"）。结论章不加章号，在标题后加 `<no-numbering>` 标签即可。

== 可选页面

插图目录、表格目录与符号表为可选页面，`thesis.typ` 已默认启用，不需要时删除或注释相应调用即可：

- *插图目录与表格目录*：`#list-of-figures()` 与 `#list-of-tables()`，位于目录页之后。
- *符号表*：`#notation[...]`，位于正文开始之前，表项写法见 `thesis.typ` 中的示例。

== 定理环境 <sec:theorem>

基于 `great-theorems` 包@great-theorems。

模板内置定理、引理、推论、定义、命题、例、备注、证明八种环境。
各环境有独立计数器，每章起始处自动重置，序号格式为"章号-序号"。
如需混合计数器（如定理与引理共用），修改 `utils/theorem.typ` 中
对应环境的 `counter` 参数为同一计数器即可。

#theorem[
  设 $p$ 为素数，$p ∤ a$，则 $a^(p-1) ≡ 1 (mod p)$。
] <thm:fermat>

#lemma[
  若 $a ≡ b (mod m)$，$c ≡ d (mod m)$，则
  $a + c ≡ b + d (mod m)$。
]

#proof[
  由同余定义直接可得。
]

#corollary[
  同余关系对减法也成立。
]

#definition(title: [素数])[
  一个大于 $1$ 的自然数，如果除了 $1$ 和它自身外，
  不能被其他自然数整除，称为素数。
]

#proposition[
  若 $a$ 和 $b$ 互素，则存在整数 $x$、$y$ 使 $a x + b y = 1$。
]

#example[
  设 $n = 7$，$a = 3$。由于 $7$ 为素数且 $7 ∤ 3$，
  由费马小定理得 $3^6 ≡ 1 (mod 7)$。
]

#remark[
  素数有无穷多个，这是古希腊数学家欧几里得在《几何原本》中
  首次证明的经典结论。
]

引用定理用 `@thm:fermat`，渲染为"@thm:fermat"。

== 图表

编号与交叉引用基于 `i-figured` 包@i-figured。

=== 三线表

使用 `threeline-table()` 封装函数，传入 `header` 和 `data` 即可：

#figure(
  threeline-table(
    columns: 3,
    header: ([参数], [数值], [单位]),
    data: (
      [温度],
      [25],
      [℃],
      [压力],
      [101.3],
      [kPa],
      [时间],
      [60],
      [s],
    ),
  ),
  caption: [示例表格],
) <example-table>

如需普通表格（如附录中的成果表），直接用 `table()` 即可。合并单元格也不需要额外封装，在 `data` 中直接使用 `table.cell(rowspan: 2)[...]` 或 `table.cell(colspan: 2)[...]` 即可。

=== 图片

插图用 `figure` + `image` 或任意图形内容。论文配图建议统一放在项目根目录的 `images/` 文件夹中，以相对路径引用，如 `image("images/fig1.png")`。多张图可排列成子图，@fig:example-figure(a) 用 `rect` 等绘图原语绘制，@fig:example-figure(b) 用 `image` 引入 SVG，@fig:example-figure(c) 用 `image` 引入位图。子图的 (a)(b)(c) 标签目前需要手写（如本例）；Universe 上的 subpar 包虽提供子图自动编号，但其计数与 i-figured 冲突（子图会被计入正图序号），暂不兼容。
#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    [
      #align(center, box(width: 100%, height: 100pt, rect(width: 100%, height: 100%, fill: gray.lighten(30%))))
      #align(center, text(font: 辅助字体, size: 字号.五号)[(a) 左：typst 图形])
    ],
    [
      #align(center, box(width: 100%, height: 100pt, image("images/demo-figure.svg", height: 100%)))
      #align(center, text(font: 辅助字体, size: 字号.五号)[(b) 中：SVG 图片])
    ],
    [
      #align(center, box(width: 100%, height: 100pt, image("images/scut_logo.jpg", height: 100%)))
      #align(center, text(font: 辅助字体, size: 字号.五号)[(c) 右：JPG 图片])
    ],
  ),
  caption: [示例：三个子图],
) <example-figure>

== 公式

编号与交叉引用基于 `i-figured` 包@i-figured。

=== 独立编号公式

直接写行间公式并加标签，`i-figured` 自动编号：

$ y = a x + b $ <linear>

引用用 `@eqt:linear`，渲染为@eqt:linear。

=== 避免行间公式后另起新段

中文论文中，行间公式有时属于前段文字的延续，此时不应另起段落。
Typst 会把行间公式当作独立 block 断开段落，需手动处理。

*不另起段*——段末 `\ ` 换行 + `#box(width: 100%)` 包裹公式，后续无缩进：

#figure(
  ```typ
  考虑一元二次方程 $a x^2 + b x + c = 0$，其根由求根公式给出： \
  #box(width: 100%)[$ x = (-b ± sqrt(b^2 - 4 a c)) / (2 a) $]
  当判别式 $b^2 - 4 a c > 0$ 时方程有两个不等实根。
  ```,
  caption: [不另起段的源码],
)

考虑一元二次方程 $a x^2 + b x + c = 0$，其根由求根公式给出： \
#box(width: 100%)[$ x = (-b ± sqrt(b^2 - 4 a c)) / (2 a) $]
当判别式 $b^2 - 4 a c > 0$ 时方程有两个不等实根。

*另起新段*——公式后空行，后续有 2em 首行缩进：

#figure(
  ```typ
  考虑一元二次方程 $a x^2 + b x + c = 0$，其根由求根公式给出：

  $ x = (-b ± sqrt(b^2 - 4 a c)) / (2 a) $

  当判别式 $b^2 - 4 a c > 0$ 时方程有两个不等实根。
  此结论可推广至复数域。
  ```,
  caption: [另起新段的源码],
)

考虑一元二次方程 $a x^2 + b x + c = 0$，其根由求根公式给出：

$ x = (-b ± sqrt(b^2 - 4 a c)) / (2 a) $

当判别式 $b^2 - 4 a c > 0$ 时方程有两个不等实根。
此结论可推广至复数域。

=== 兼容 LaTeX 公式语法

Typst 的公式语法与 LaTeX 不同，例如分式写作 `frac(a, b)` 而非 `\frac{a}{b}`，上下标一般无需花括号，直接粘贴 LaTeX 公式源码无法编译。

若希望保留 LaTeX 写法，可用 mitex 包@mitex 渲染；套一层数学环境后，公式照常按章编号，也可用 `@eqt:` 引用：

#figure(
  ```typ
  #import "@preview/mitex:0.2.7": mi, mitex

  行内公式 #mi(`e^{i \pi} + 1 = 0`)，行间公式：

  $ #mitex(`\frac{1}{2} + \sum_{i=1}^{n} x_i`) $ <my-eq>
  ```,
  caption: [用 mitex 渲染 LaTeX 公式],
)

如需把存量 LaTeX 公式一次性转换为 Typst 语法，可使用 tex2typst 转换工具#footnote[tex2typst 提供命令行工具与网页版：#link("https://github.com/qwinsi/tex2typst")]，长期写作建议仍直接使用 Typst 语法。

== 标签与引用

编号与交叉引用基于 `i-figured` 包@i-figured。

图表标签不加前缀，由 `i-figured` 自动生成带前缀的内部标签。引用时加对应前缀：

- 表格 `@tbl:my-table`，如@tbl:example-table
- 图片 `@fig:my-figure`，如@fig:example-figure
- 公式 `@eqt:my-eq`，如@eqt:linear
- 章节 `@sec:my-section`，如@sec:theorem（渲染为"小节 编号"，Typst 内置中文 supplement）

两个容易踩的坑。其一，标签处只写裸名 `<my-figure>`，不要写成 `<fig:my-figure>`：`i-figured` 会无条件再套一层前缀变成 `fig:fig:my-figure`，引用静默失效。其二，引用渲染自带“图”“表”等补充词，正文写作时不要再手写这类字：写“如 @fig:example-figure 所示”，而不是“如图 @fig:example-figure 所示”（后者会渲染成“如图 图 3-1 所示”）。

引用参考文献用 `@citation-key`，标注为上标方括号，如文献 @蒋有绪1998 所述。

== 参考文献

本模板的参考文献按“条目数据与著录样式分离”的思路组织：条目统一维护在项目根目录的 `ref.bib`（BibTeX 格式）中，著录格式则由 `documentclass` 的 `bibliography` 参数指定的 CSL 文件统一控制，当前使用 GB/T 7714—2015 顺序编码双语变体，取自 Zotero 中文社区样式库@zotero-chinese-styles。需要更换样式时（例如要求显示 URL、DOI），只需替换该 CSL 文件，正文与条目文件均不必改动。

.bib 条目一般不必手工编写：Zotero 等文献管理软件可选中条目导出 BibTeX，配合 Better BibTeX 插件还能固定引用键；中国知网、万方、Google Scholar 等学术网站的论文页面也提供“导出”或“引用”入口，可直接获取 BibTeX 记录，粘贴进 `ref.bib` 即可使用。`ref.bib` 中附有几条英文示例：IEEE 会议论文 @akkaynak2018revised @akkaynak2019seathru、arXiv 预印本 @wolf2025diffusion @chib2023recent，以及作者超过三人的期刊论文 @mitchell2022review。

Typst 的 CSL 引擎只支持单一全局语言环境，无法按条目语言切换“等”与“et al.”（该能力属于 CSL-M 扩展）。本模板用 `bilingual-bibliography()` 调用文献列表以绕过这一限制：它对渲染结果做最小字符串替换，检测到的英文条目中“等”替换为“et al.”、“卷 N”替换为“Vol. N”，中文条目保持不变——文末可见 @mitchell2022review 显示“et al.”而中文条目显示“等”。若遇到未预期的排版，可将该调用换回普通的 `#bibliography(title: "参考文献", full: false)`。注意文献列表默认只收录被正文引用的条目（`full: false`），`ref.bib` 中未被引用的条目不会出现在列表中。

== 代码块

基于 `zebraw` 包@zebraw，支持行号和语法高亮。学校目前规范（2022 版本）暂无代码块字体要求，这里使用了中文计算机学科教材常见的 Courier New 及宋体。


#figure(
  ```py
  def hello(): # 一个 python 函数
      print("Hello, SCUT!")
  ```,
  caption: [代码块示例],
) <code-example>

== 算法伪代码

基于 `algorithmic` 包@algorithmic。

使用 `algorithm-figure()`，自动编号（"算法 2-1"）。
语法模仿 LaTeX algorithmicx，提供 `If`/`While`/`For`/`Function`/`Procedure` 等。

注意不要在章节文件顶层写 `#import "@preview/algorithmic:1.0.7": *`：通配导入会把模板封装的中文补充词“算法”覆盖成英文“Algorithm”。像下方示例一样把 `import` 写在 `algorithm-figure` 的花括号作用域内即可。

#algorithm-figure(
  "Binary Search",
  vstroke: .5pt + luma(200),
  {
    import algorithmic: *
    Procedure(
      "Binary-Search",
      ("A", "n", "v"),
      {
        Comment[Initialize the search range]
        Assign[$l$][$1$]
        Assign[$r$][$n$]
        LineBreak
        While(
          $l <= r$,
          {
            Assign([mid], FnInline[floor][$(l + r) / 2$])
            IfElseChain(
              $A ["mid"] < v$,
              {
                Assign[$l$][$"mid" + 1$]
              },
              [$A ["mid"] > v$],
              {
                Assign[$r$][$"mid" - 1$]
              },
              Return[mid],
            )
          },
        )
        Return[*null*]
      },
    )
  },
) <alg:binary-search>

引用用 `@alg:binary-search`，渲染为@alg:binary-search。

== 脚注

正文中以 `#footnote[内容]` 插入脚注，标记跟在所需注释的文字之后。脚注按页重新编号，以辅助字体小字号排版#footnote[这是一个脚注示例。]。

== 构建变体

除最终版外，常用构建变体如下。所有开关由项目根目录的 `build.typ` 解析命令行输入（`--input`）控制，不传入任何参数时即为最终版。

*盲审版。* 使用 `--input profile=blind` 启用盲审，并用 `--input blind=single|double` 指定级别（缺省为双盲）。单盲封面保留作者与导师栏；双盲封面只保留论文题目、学科（学位类别）、所在学院与论文提交日期，不输出英文内封、提名页、原创性声明页与致谢，研究成果清单自动切换为匿名表格，PDF 元数据不写入作者；博士论文（两种盲审级别）均在封面后附专家评阅结果处理办法页。

```shell
typst compile --input profile=blind --input blind=single thesis.typ thesis-blind-single.pdf
```

*印刷版。* 使用 `--input profile=for-print`，自动为封面、英文内封、提名页与声明页补充空白背面页：

```shell
typst compile --input profile=for-print thesis.typ thesis-for-print.pdf
```

*查重版。* 查重系统通常只需要正文部分，页码范围由模板自动标记（`<mainmatter-start>` 由 `mainmatter` 布局放置在正文首页，`<backmatter-start>` 由 `bilingual-bibliography()` 放置在参考文献页），并需关闭 PDF 标签以兼容查重系统。分两步完成：先用 `typst eval` 查询两个标签所在的页码

```shell
typst eval --in thesis.typ 'query(<mainmatter-start>).first().location().page()'
typst eval --in thesis.typ 'query(<backmatter-start>).first().location().page()'
```

假设输出分别为 9 和 23，则正文为第 9 至 22 页，代入执行

```shell
typst compile --no-pdf-tags --pages 9-22 thesis.typ thesis-for-check.pdf
```

Linux/macOS 用户也可用下面的命令自动完成查询与抽取：

```shell
start=$(typst eval --in thesis.typ \
  'query(<mainmatter-start>).first().location().page()')
end=$(( $(typst eval --in thesis.typ \
  'query(<backmatter-start>).first().location().page()') - 1 ))
typst compile --no-pdf-tags --pages "$start-$end" thesis.typ thesis-for-check.pdf
```

其余开关：`--input twoside=false` 关闭双面排版；`--input include-acknowledgement=false` 隐藏致谢页。

需要长期切换到某一变体时，也可直接修改 `build.typ` 中对应开关的默认值（如将 `profile` 的默认值改为 `"blind"`），此后普通编译与编辑器实时预览均按该变体输出。

模板源码仓库另提供封装脚本 `scripts/build.sh`（Linux/macOS）与 `scripts/build.ps1`（Windows），支持 `final`、`blind`、`for-check`、`for-print` 与 `all` 子命令，一键产出对应 PDF 到 `out/` 目录；这些脚本只是上述 `--input` 命令的封装，克隆仓库的用户直接执行脚本即可，如 `scripts/build.sh blind single`。

= 结　论 <no-numbering>

学位论文的结论单独作为一章排写，但不加章号。

结论是对整个论文主要成果的总结。在结论中应明确指出本研究内容的创造性成果或创新性理论（含新见解、新观点），对其应用前景和社会、经济价值等加以预测和评价，并指出今后进一步在本研究方向进行研究工作的展望与设想。

如果不能导出应有的结论，也可以没有结论而进行必要的讨论。

#pagebreak(weak: true)
#bilingual-bibliography(bibliography: bibliography, title: "参考文献", full: false)

// 附录
// “对需要收录于学位论文中但又不适合书写于正文中的附加数据、方案、资料、详细公式推导、计算机程序、统计表、注释等有特色的内容，可做为附录排写，序号采用‘附录1’、‘附录2’等。”
#show: appendix

= 附录一

== 附录子标题

附录内容。

// 攻读学位期间取得的研究成果
// “攻读博士/硕士学位期间取得的研究成果一般包括发表（含录用、已投稿、拟投稿）的与学位论文相关的学术论文、发明专利、著作、获奖科研项目等。”
#publications[
  此处可填写专利、著作、获奖项目等详细内容。
]

// 致谢
// “致谢中主要感谢指导教师和在学术方面对论文的完成有直接贡献及重要帮助的团体和人士，以及感谢给予转载和引用权的资料、图片、文献、研究思想和设想的所有者。致谢辞应谦虚诚恳，内容简洁明了、实事求是。”
#if include-acknowledgement {
  acknowledgement[
    致谢内容。感谢指导教师和在学术方面对论文的完成有直接贡献及重要帮助的团体和人士。
  ]
}
