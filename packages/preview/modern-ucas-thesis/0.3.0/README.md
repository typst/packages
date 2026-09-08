<h1 align="center">modern-ucas-thesis</h1>

<p align="center">
  <a href="docs/README_EN.md">English</a> | <strong>中文</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-beta-blue?style=flat-square" alt="Project Status">
  <img src="https://img.shields.io/github/last-commit/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Last Commit">
  <img src="https://img.shields.io/github/issues/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Open GitHub issues of modern-ucas-thesis">
  <img src="https://img.shields.io/github/license/Vncntvx/modern-ucas-thesis?style=flat-square" alt="MIT license of modern-ucas-thesis">
</p>

基于 [Typst](https://typst.app/) 的中国科学院大学学位论文模板，遵循《中国科学院大学研究生学位论文撰写规范指导意见（2022年）》格式要求。

> ⚠️ **免责声明**：本项目非官方出品，使用前请自行核对学校最新格式要求。
---

## 快速开始

### 1. 安装 Typst

```bash
# macOS
brew install typst

# Windows
winget install --id Typst.Typst

# 或使用官方安装脚本
curl -fsSL https://typst.community/install | sh
```

### 2. 使用项目

```bash
# 克隆仓库
git clone https://github.com/Vncntvx/modern-ucas-thesis.git
cd modern-ucas-thesis

# 编译论文（中文字体来自系统字库；缺字时可加 --font-path 指向字体目录）
typst compile template/thesis.typ --root .

# 或开启实时预览
typst watch template/thesis.typ --root .
```

### 3. 配置论文信息

编辑 `template/thesis.typ`：

```typst
#import "@preview/modern-ucas-thesis:0.3.0": documentclass

#let (
  doc, preface, mainmatter, appendix,
  cover, decl-page, abstract, abstract-en,
  outline-page, list-of-figures-and-tables, notation,
  bilingual-bibliography, acknowledgement, backmatter,
  bifigure, bitable, continued-table, auto-table, aligned-equation,
) = documentclass(
  doctype: "doctor",       // "bachelor" | "master" | "doctor" | "postdoc"
  degree: "academic",      // "academic" | "professional"
  anonymous: false,        // 盲审模式
  twoside: true,           // 双面打印模式
  fontset: "mac",          // "windows" | "mac" | "fandol" | "adobe"
  info: (
    title: ("论文标题", "副标题（可选）"),
    title-en: "Thesis Title",
    author: "张三",
    author-en: "Zhang San",
    // 导师：结构化字典列表 (name:, title:, affiliation:)，多导师第一导师在前
    supervisors: (
      (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
      (name: "王五", title: "研究员", affiliation: "中国科学院××研究所"),
    ),
    supervisors-en: (
      (name: "Si Li", title: "Professor", affiliation: "×× Institute, CAS"),
      (name: "Wu Wang", title: "Professor", affiliation: "×× Institute, CAS"),
    ),
    department: "中国科学院××研究所",
    major: "管理科学与工程",
    category: "管理学博士",
    submit-date: datetime(year: 2024, month: 6, day: 1),
  ),
  bibliography: bibliography.with("ref.bib"),
)

#show: doc
#cover()
#decl-page()
#show: preface
// 摘要、目录、符号表...
#show: mainmatter
// 正文...
```

---

## 项目结构

```text
modern-ucas-thesis/
├── template/              # 论文源文件（模板入口）
│   ├── thesis.typ        # 主文件
│   ├── ref.bib           # 参考文献
│   └── images/           # 图片目录
├── pages/                # 具体页面实现（封面、声明、摘要、目录、致谢等）
├── layouts/              # 页面级布局（doc / preface / mainmatter / appendix）
├── utils/                # 可复用工具（双语图表、续表、对齐公式、字体、编号等）
├── docs/                 # 文档（规范原文、定制指南、FAQ 等）
├── lib.typ               # 主库入口（documentclass 闭包工厂）
├── typst.toml            # Typst 包配置
```

---

## 功能特性

> 实现状态对照《中国科学院大学研究生学位论文撰写规范指导意见（2022年）》`docs/RULES.md` 逐项核验代码现状。状态含义：✅ 已完成｜🟡 部分实现／待完善｜❌ 未开始｜➖ 规范未强制要求。

### 文档配置

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 全局信息配置（文档类型、学位类型、字体等） | ✅ | `documentclass` 闭包工厂统一注入 |
| 盲审模式 | ✅ | `anonymous: true` 自动隐藏作者/导师等字段 |
| 双面打印模式 | ✅ | `twoside: true` 自动插入空白页使各部分从奇数页开始 |
| 国家图书馆封面（含密级/中图分类号/UDC/学校代码） | ❌ | `nl-cover` 参数已预留；`secret-level`/`clc`/`udc`/`school-code` 字段已在 `lib.typ` 定义但未渲染 |

### 封面与前置页

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 研究生封面（中/英文，硕/博） | ✅ | 标题黑体小三号加粗、字段宋体四号加粗 2 倍行距、日期 Times New Roman 四号加粗 |
| 本科生封面 | ✅ | 经 `bachelor-cover.typ` 实现，由 `doctype` 分发 |
| 书脊 | ❌ | 规范要求：黑体小四号，上=题目、中=作者、下="中国科学院大学"，距上下边界 3cm |
| 原创性声明与授权说明 | ✅ | 研究生与本科生均已实现（含统一声明模板，样张3） |
| 中文摘要（含关键词） | ✅ | "摘　要"二字间空一字符，黑体四号加粗居中；3~5 关键词，中文逗号分隔 |
| 英文摘要（含关键词） | ✅ | "Key Words"加粗，首字母大写，英文逗号分隔 |
| 目录 | ✅ | 章节缩进至三级（一级顶格、二级 1 字符、三级 2 字符），页码右对齐 |
| 图表目录 | ✅ | 先列图后列表，置于目录后另页编排 |
| 符号表（术语与符号说明） | ✅ | 置于目录之后、正文之前，另页编排 |

### 正文排版

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 章节标题编号 | ✅ | 阿拉伯数字三级（最多四级），章"第1章"居中，子节"1.1 / 1.1.1"顶左 |
| 页眉 | ✅ | 奇数页=当前章/部分名，偶数页=论文题目；宋体小五号居中，下加分隔线 |
| 页码制式 | ✅ | 前言大写罗马数字居中；正文默认 `twoside: true`，奇数页右下、偶数页左下，单面时居中 |
| 脚注 | ✅ | 五号宋体，章/部分起始重置计数 |
| 尾注 | ➖ | 规范未强制要求 |
| 交叉引用（图/表/公式/章节） | ✅ | 统一前缀：`@fig:` / `@tbl:` / `@eqt:` |
| 段落格式 | ✅ | 宋体小四号，1.25 倍行距，首行缩进 2 字符，两端对齐 |
| 代码块语法高亮 | ✅ | Typst 原生 raw block 支持 |

### 图表处理

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 双语图表标题 | ✅ | 图题居图下、表题居表上，宋体五号加粗居中，1.25 倍行距 |
| 图表注释（表注、图注） | ✅ | "注："加粗，左缩进 2 字符，续行对齐 |
| 图表按章编号 | ✅ | 形如 `图1-1`、`表3-2`，分章连续编码 |
| 自动续表（长表跨页） | ✅ | `auto-table` 主动分页，自动重复表头并标注"续表"/"(continued)" |
| 手动续表 | ✅ | `continued-table` 需配合源表 label 使用 |
| 附录图表编号 | ✅ | 沿用正文编号形式（`1-1`），与规范"附录图表参考正文编号方式"一致 |
| 三线表 | ✅ | 通过 `table.hline()` 组合实现，模板内置示例 |
| 卧排表（横向表格） | ✅ | `bitable`/`bifigure`/`auto-table` 内置 `landscape: true`，逆时针旋转 90°，方位"顶左底右" |
| 地图审图号注释辅助 | ❌ | 规范要求涉国界图件注明"审图号 GS(2021)××××号"，需用户手动添加 |

### 公式与数学

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 行间公式编号 | ✅ | 编号置于括号内，右端对齐 |
| 多行公式对齐与编号 | ✅ | `aligned-equation` 编号对齐到最后一行右侧 |
| 公式按章编号 | ✅ | 形如 `(3-1)`，分章连续编码 |
| 不编号公式 | ✅ | 以 `<->` 标签标识 |
| 附录公式编号 | ✅ | 形如 `(1-1)`，沿用正文编号形式 |
| 长公式转行 | ✅ | 在 `+ - × ÷ < >` 等运算符后转行（Typst 原生支持） |
| 定理/引理/证明环境 | ➖ | 规范未强制要求 |

### 参考文献

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 双语参考文献标题 | ✅ | 中文"参考文献"，英文自动处理 |
| GB/T 7714-2015 格式（顺序编码制） | ✅ | 默认 `gb-7714-2015-numeric` |
| GB/T 7714-2015 格式（著者—出版年制） | 🟡 | 可经 `style: "gb-7714-2015-author-date"` 切换，但未提供默认配置与样式校验 |
| 中英文文献格式自动转换 | ✅ | 自动识别中英文文献并转换"等/卷/册/译/版"等术语 |
| 文献引用与交叉引用 | ✅ | `@citekey` |
| 荐读书目（未引用文献） | ❌ | 规范要求"正文中未被引用但被阅读的文献可集中列入附录，标题为'荐读书目'"，未提供专门支持 |

### 附录与后置

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 附录章节 | ✅ | 一级标题无编号，子节 `1.1`，图表 `1-1`，公式 `(1-1)` |
| 致谢页 | ✅ | 标题二字间空一字符，末尾具日期与封面一致 |
| 作者简介与学术成果 | ✅ | 含教育/工作经历、论文清单（同参考文献格式）、专利、项目、获奖 |
| 学位类别中英文对照表 | 🟡 | 规范附件2，仅作为附录示例表格存在于 `thesis.typ`，未抽取为可复用组件 |

### 字体与排版

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 预定义字体组 | ✅ | `windows` / `mac` / `fandol` / `adobe` 四套，含宋/黑/楷/仿宋/等宽 |
| 自定义字体配置 | ✅ | `fonts` 参数覆盖 `fontset` 单项 |
| 中西文字体混排 | ✅ | 中文宋体/黑体等 + 英文 Times New Roman |
| 中文伪加粗 | ✅ | 非 fandol 字体组经 `@preview/cuti:0.4.0` 启用 |

### 其他文档类型

| 功能项 | 状态 | 规范依据 / 说明 |
|--------|------|----------------|
| 博士后学位论文 | ❌ | `postdoc` 调用时 `panic`，未实现 |

### 待办优先级建议

按规范契合度影响排序：

1. **书脊**（❌）— 规范明确要求，缺项
2. **国家图书馆封面 / 密级显示**（❌）— 字段已预留，封面未渲染密级行
3. **荐读书目**（❌）— 规范提及，未提供专门支持
4. **卧排表**（✅）— `bitable`/`bifigure`/`auto-table` 内置 `landscape: true` 参数
5. **著者—出版年制默认配置**（🟡）— 引擎支持，缺省配置与样式校验
6. **学位类别对照表组件化**（🟡）— 当前仅作示例，未抽取复用

---

## 文档

- [定制指南](docs/CUSTOMIZE.md)
- [格式规范原文](docs/RULES.md)（中国科学院大学研究生学位论文撰写规范指导意见 2022）
- [常见问题](docs/FAQ.md)
- [格式化工具](docs/FORMAT.md)
- [UCAS 标识版权说明](docs/LOGO_COPYRIGHT.md)

---

## 致谢

- 基于 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 开发
- 参考 [ucasthesis](https://github.com/mohuangrui/ucasthesis) LaTeX 模板

---

## 许可证

本项目代码采用 [MIT](LICENSE) 许可证开源。

**关于 UCAS 标识**：本包不含校徽、Logo 文件（版权归中国科学院大学所有）。封面默认不渲染校徽；如需添加，请自行准备文件并在 `pages/master-cover.typ`（研究生）或 `pages/bachelor-cover.typ`（本科）中恢复 `image(...)` 调用，相关权责详见 [docs/LOGO_COPYRIGHT.md](docs/LOGO_COPYRIGHT.md)。

---

<p align="center">
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/issues">报告问题</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/discussions">讨论交流</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/pulls">贡献代码</a>
</p>
