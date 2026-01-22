#import "../lib.typ": *

// ======================================================
//                 填写说明 (Instructions)
// ======================================================
// 
// 1. [enrollment] 入学方式 (请填写对应字母 "a" / "b" / "c"): 
//    "a" -> 直博生 Doctoral Student after Bachelor's
//    "b" -> 普博生 Regular Doctoral Student
//    "c" -> 硕博连读生 Combined Master and Doctoral
//
// 2. [degree-program] 学生类别 (请填写对应字母 "a" / "p"): 
//    "a" -> 学术型 Academic
//    "p" -> 专业型 Professional
//
// 3. [dissertation-title] 论文题目: 
//    支持使用 \n 手动换行，不加则由系统自动处理换行和对齐。
//
// 4. [source-of-research-project] 研究课题来源:
//    支持单选或多选。单选请填数字，多选请填数组，如 (1, 3)。必须至少选一项。
//    1. 国家自然科学基金课题 NSFC Research Grants
//    2. 国家社会科学基金 National Social Science Fund of China
//    3. 国家重大科研专项 National Key Research Projects
//    4. 其它纵向科研课题 Other Governmental Research Grants
//    5. 企业横向课题 R&D Projects from Industry
//    6. 自拟课题 Self-proposed Project
//
//          示例 A：多选 (勾选 1 和 3)
//                 source-of-research-project: (1, 3), 
//          示例 B：单选 (勾选 2)
//                 source-of-research-project: 2, 
//
// 5. [signature-image/text/signature-date] 文末签字栏设置:
//    优先显示图片签名。若无图片，则显示文本签名（楷体）。两者皆空将触发红色警告。
//    - signature-image: 签名图片路径，如 "figures/signature.png" (支持 png/jpg/pdf)
//    - signature-text:  签名文字内容，如 "张三"
//    - signature-date:  签署日期，如 today-date 或者自定义 "2026-01-01"
//
//          示例 A: 使用手写签名图片 (最推荐) ---
//                 signature-image: "figures/your_signature.png",
//                 signature-date:  today-date
//          示例 B: 仅使用名字文本 (临时方案) ---
//                 signature-text:  "张三",
//                 signature-date:  "2026-01-01"
// ======================================================


#show: body => project(
  
  // --- 封面信息 (Cover Information) ---
  student-id:     "012345678901",
  name:           "你的名字",
  supervisor:     "你的导师",
  major:          "你的专业",
  school:         "你的学院",
  enrollment:     "b", 
  degree-program: "a",
  date:           today-date,

    // --- 正文开头的特制表格 (Dissertation & Project) ---
  dissertation-title: "我的很长很长很长很长很长很长很长很长很长很长很长很长很长很长的\n很厉害的论文题目",
  source-of-research-project: (1, 3, 5),
  dissertation-proposal-date: "2026-01-01",
  
  // --- 结尾签字栏 (Final Signature) ---
  signature-image: "figures/your_signature.png",
  signature-text:  "你的名字",
  signature-date:  today-date,
  
  body
)

// ======================================================
//            --- 这里开始编写你的报告正文 ---
// ======================================================

= 报告正文 Report。#text(weight: "regular", size: 12pt)[请阐述开题报告或上次年度进展报告以来学位论文研究工作的进展情况及所取得的阶段性成果，并简述下一年度研究计划，不少于3,000汉字。Please summarize your research progress and achievements since your dissertation proposal or last annual progress review, as well as your plan for next step. No less than 2,400 words if written in English.]

制作本中期报告 Typst 模板的初衷，是为校友们提供一个比 LaTeX 更轻量、比 Word 更专业的排版方案。

== 模板使用指南 (Template Guide)

本模板已针对上海交通大学年度进展报告的格式规范，深度定制了字体、间距、标题悬挂缩进及参考文献样式。

=== 数学公式 (Mathematics) <math_section>

Typst 采用了类似数学直觉的语法。行内公式直接使用 \$ 包裹，如 $a^2 + b^2 = c^2$。

对于复杂的行间公式，可以使用双美元符号：
$ cal(F)(omega) = integral_(-infinity)^(infinity) f(t) e^(-i omega t) d t $

你也可以编写矩阵或多行对齐公式：
$ A = mat(1, 2; 3, 4), quad sum_(i=1)^n i = (n(n+1)) / 2 $

=== 图像处理与交叉引用 (Images & References)

插入图片建议使用 `figure` 环境，这样可以自动生成“图 1”这样的标签并支持自动编号。

#figure(
  // 请确保 figures 文件夹下有对应的图片文件
  image("figures/A.png", width: 50%),
  caption: [示例图片],
) <fig_A>

如 @fig_A 所示，图片会自动居中。在正文中使用 `@fig_A` 即可实现自动跳转引用。

=== 表格设计 (Tables)

本模板对表格进行了局部优化，使其更符合中文学术排版的“三线表”或“全框表”风格。

#figure(
  table(
    columns: (auto, 1fr, 1.5fr), // 自动宽度、1份比例、1.5份比例
    stroke: 0.5pt,              // 线条粗细
    inset: 8pt,                 // 单元格内边距
    align: center + horizon,    // 水平居中，垂直居中
    table.header([*阶段*], [*研究内容*], [*预期成果*]),
    [第一阶段], [国内外文献综述与需求分析], [提交开题报告定稿],
    [第二阶段], [核心算法设计与仿真验证], [发表高质量学术论文],
    [第三阶段], [实验数据收集与论文撰写], [完成学位论文初稿],
  ),
  caption: [课题研究详细进度安排表],
) <tab_schedule>

通过引用 @tab_schedule ，读者可以清晰地了解研究进度。

==== 三线表展示

三线表通常用于展示实验结果或对比数据，其结构简洁明了。

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    // 关键：首先将全局边框设为 none
    stroke: none, 
    inset: 8pt,
    align: center + horizon,
    
    // 1. 顶线：在 table.header 之前通过 line 模拟或使用 table.hline
    table.hline(stroke: 1.5pt), // 顶线较粗
    table.header([*方法*], [*准确率 (%)*], [*召回率 (%)*], [*F1 分数*]),
    table.hline(stroke: 0.5pt), // 栏目线较细
    
    [Baseline], [85.2], [82.1], [83.6],
    [Proposed], [92.4], [90.8], [91.6],
    [State-of-art], [93.1], [91.2], [92.1],
    
    table.hline(stroke: 1.5pt), // 底线较粗
  ),
  caption: [不同算法性能对比（三线表示例）],
) <tab_3line>

通过引用 @tab_3line 可以看到，三线表取消了所有竖线，使数据阅读更加流畅。

=== 参考文献管理 (Bibliography)

本模板集成了 `gb-7714-2015-numeric` 标准。你只需要在同级目录下准备一个 `ref.bib` 文件。

引用方式非常简单：

- 单个引用：该算法的收敛性已在文献 @ZJSD 中得到证明。
- 多个引用：目前主流观点支持该结论 @ZJSD @SPDZ。

参考文献列表会自动根据你的引用顺序生成在文末，并应用左缩进 2 字符的样式。

=== 章节标签与快速跳转

你可以通过在标题后添加 `<label_name>` 来定义标签。

例如，本文档 数学公式 的章节定义为 `=== 数学公式 <math_section>`。我们现在可以轻松地通过 `@math_section` 跳回该部分 @math_section。

=== 常用排版技巧

- *加粗*：使用 `*加粗内容*` .
- _斜体_：使用 `_斜体内容_`。
- #underline[下划线]：使用 `#underline[内容]`。
- #highlight[高亮]：使用 `#highlight[内容]`。
- #text(fill: red)[彩色文字]：使用 `#text(fill: color)[内容]`。
- 脚注：直接在文中写 `#footnote[内容]` 即可生成#footnote[这是一个脚注]。

=== 列表

==== 无序列表 (Unordered Lists)
无序列表使用减号 `-` 开头。它可以自动处理多级嵌套：

- 第一级项目
  - 第二级嵌套项目
    - 第三级嵌套项目
- 并列的一级项目

==== 有序列表 (Ordered Lists)
有序列表使用加号 `+` 开头，Typst 会自动处理编号逻辑：

+ 第一项任务：收集很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多文献数据。
+ 第二项任务：建立数学模型。
  + 子任务 A：参数标定。
  + 子任务 B：灵敏度分析。
+ 第三项任务：撰写开题报告。

==== 术语列表 (Term Lists)

术语列表非常适合用于“变量定义”或“名词解释”，使用斜杠 `/` 开头：

/ $alpha$: 显著性水平（Significance Level），通常取 0.05。
/ $P_(i,j)$: 表示从状态 $i$ 转移到状态 $j$ 的概率。
/ 模型参数: 经过多轮实验标定后得到的全局最优参数解。

==== 列表样式自定义

如果你需要自定义列表的符号（例如将圆点改为方框或箭头），可以使用 `set` 规则：

// 局部设置：将无序列表符号改为中划线，有序列表改为字母，调整术语列表间距
#block[
  #set list(marker: ([—], [•]))
  #set enum(numbering: "a)")
  #set terms(separator: h(3em), hanging-indent: 1em) // 调整术语列表间距
  
  - 这里的符号是长划线 `—`
    - 这里的符号是圆点 `•`
  + 这里的编号是 a)
  / 自定义术语: 术语与解释之间的间距被拉大了。
]

块外面自动恢复默认

- 这里的符号回到了圆点
+ 这里的编号回到了数字
/ 自定义术语: 术语与解释之间的间距被恢复了。

== 进展情况 <status>

正如在 @status 中所述，目前该领域的研究正处于快速发展期。


== 现有成果

已经发表了 _Nature_ 和 _Science_ 各100篇。

// 3. 参考文献
#v(2em)
#text(weight: "bold")[参考文献 References:]
#pad(left: 2em)[
  #set par(first-line-indent: 0pt) // 重置参考文献内部的首行缩进，防止冲突
  #bibliography(
    "ref.bib", 
    title: none, 
    style: "gb-7714-2015-numeric"
  )
]


= 成果清单 List of Achievements。#text(weight: "regular", size: 12pt)[请列出开题报告以来或上次年度进展报告以来新发表的学术论文、授权专利、国际会议论文、专著等成果清单。作者、标题、杂志、卷、期、页码等信息请填写完整。Please provide a list of academic publications (papers, patents, international academic conference talks, monographs, etc.) since your dissertation proposal or last annual progress review. Information on author list, title, journal name, volume, number, and pages shall be complete.]

#set enum(indent: 2em)
+ 成果1
+ 成果2

