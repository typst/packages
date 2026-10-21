# 与 exam-zh 的差异与路线图

本文件列出 Typst 版与 LaTeX 版 exam-zh 行为不同、写法不同或尚不支持的地方，以及后续计划。
逐条的写法对照见 [API 对照手册](docs/reference.typ)，其中这些条目标有“写法不同”“Typst 中不需要”或“留给独立包”。

## 行为不同

| 项目 | exam-zh | 本模板 | 原因 |
|---|---|---|---|
| 连线题的连线、`select` 的选择标记 | 总是显示 | 只在教师版显示 | 二者都是答案 |
| Noto、思源预设的楷体 | 找不到字体时报警告 | 材料、古诗等退回宋体 | 这两套字体没有楷体；可用 `font: (kai: ..)` 指定 |
| 编译次数 | 至少两次（目录、引用、页数） | 一次 | Typst 自动迭代 |
| 密封线学生信息 | 命令要用花括号包起来（TikZ `text along path` 的限制） | 任意内容，如 `[座位号 #examsquare(2)]` | — |
| 题号 `question.index` | 入门文档称 `index = 0` 让题号从 1 开始，实际印出“0.” | 表示下一题题号，`index: 1` 从 1 开始 | 与 exam-zh 的实际行为一致，不与其入门文档一致 |

## 写法不同

| exam-zh | 本模板 | 原因 |
|---|---|---|
| `sealline/show` | `sealline: (enable: ..)` | `show` 是 Typst 关键字 |
| `\examsetup{title = {..}}` | `make-title: (..)` | `exam(title:)` 已用于试卷标题 |
| `\vec` | `vect` | Typst 的 `vec` 是列向量 |
| `\cap*`、`\nsubset` 等 | `inter`、`subset.not` 等 Typst 原生符号 | Typst 已有对应符号 |
| `font = newcm`、`math-font = stix` 等名称 | `font: (latin: "..", math: "..")` 直接写字体名 | 无需宏包映射 |
| `page/head-content` 中的 fancyhdr 代码 | `page: (head: [..])` 或 `n => [..]` | — |
| `\ExamPrintAnswerSet{..}` | `exam(teacher: teacher-defaults + (..))` | — |
| `\fillin[{$[2,3)$}]` 的括号保护 | 直接写 `fillin[$[2, 3)$]` | Typst 参数不需要保护 |
| `lineto` 与 `\linelistset`、按名称 `i-1`、`ii-3` 连线 | 每列一个数组，`connect: ((1, 3),)` 按序号连线 | 不需要给每列命名 |
| `writingbox` 的 tcolorbox 选项 | `title`、`box-stroke`、`inset`、`title-format` | 没有 tcolorbox |

## Typst 中不需要

- `\AddQuestionCounter`、`\AddChoicesCounter`、`\AddFillinCounter`：编号格式直接传函数，如 `label: n => [第 #n 题]`；
- `\ExamPrintAnswer`、`style/student-version-suffix`、`style/student-version-cleanaux`：教师版用 `--input exam-mode=teacher` 编译，输出文件名在命令行指定，没有辅助文件；
- `square/xshift`：方格画在同一个网格中，公共边自动只画一次；
- `composition-grid/hanzibox-options`、`multifigures` 的 tabularray 参数：对应 `cell-size`、`frame-type` 与 `column-widths` 等选项；
- `symbols/change-dfrac-style`、`dfrac-add`：Typst 不区分 `\frac` 与 `\dfrac`，`symbols.frac-add` 作用于所有分式；
- Overleaf 的 `\let\stop\empty`、XeLaTeX 与 `-shell-escape`。

## 尚不支持

| 功能 | 现状 | 计划 |
|---|---|---|
| 文字绕排（`wrapstuff`、`textfigure` 的 `top`） | Typst 不支持文字绕排浮动内容；可直接用 [meander](https://typst.app/universe/package/meander) 或 [wrap-it](https://typst.app/universe/package/wrap-it) | 独立包，或在模板中集成 meander |
| 更多汉字格（四线三格、拼音格等 `hanzibox` 类型） | `composition-grid` 支持口、田、米三种格子 | 独立的汉字格包 |
| 选择题、填空题答案集中到文末 | 与 exam-zh 相同，只有 `solution` 支持 `"show-move"` | 可用 `metadata` 收集，作为 exam-zh 之外的新功能 |

## 路线图

### 0.1.0

- [x] 包名 `exam-zh-next`，仓库 <https://github.com/pku-lemonade/exam-zh-next>，`authors` 含 GitHub 账号；
- [x] Release [v0.1.0](https://github.com/pku-lemonade/exam-zh-next/releases/tag/v0.1.0)，附 `guide.pdf` 与 `reference.pdf`；
- [x] 提交 Typst Universe：[typst/packages#6182](https://github.com/typst/packages/pull/6182)，自动检查全部通过；
- [ ] 等待审核，按审核意见修改；
- [ ] 在 typst.app 上从模板新建项目，确认默认字体可用、无警告。

### 0.2.0：老师常用、exam-zh 没有的功能

以下需求来自实际使用者（多数在 [ezexam](https://github.com/gbchu/ezexam) 的 issue 中被提出），按优先级排列：

- [ ] **大题分值自动统计**：由各题 `points` 自动生成“本题共 8 小题，共 40 分”与全卷总分；
- [ ] **答案汇总**：选择题、填空题的答案集中到文末或生成答案表（目前只有 `solution` 支持 `"show-move"`）；
- [ ] **题目引用**：`question(label: <q-fn>)[..]` 与 `@q-fn` 引用题号，如“由第 3 题可知”；
- [ ] **带题号的括号与横线**：英语七选五、完形填空中，`paren` 与 `fillin` 的占位显示题号；
- [ ] **着重号**：语文常用的字下加点；
- [ ] **试卷信息**：A/B 卷类型标记、命题人与审题人一行；
- [ ] **全页水印**：目前只有草稿纸有水印。

### 之后

- [ ] 讲义模式：同一套题目排成讲义（例题、解析框、公式编号），与试卷模式切换；
- [ ] 文字绕排与汉字格的独立包（见“尚不支持”），完成后在本模板中提供对应写法；
- [ ] 回归测试：把示例的渲染结果存为参考图，修改后逐页比较；
- [ ] `scripts/release.sh`：一条命令完成版本号更新、检查、打标签、发布 Release 与提交 Universe PR；
- [ ] 英文版 README 与入门指南；在线文档（Typst HTML 导出或静态网站）。
