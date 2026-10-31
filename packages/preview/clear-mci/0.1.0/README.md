# clear-mci — 《现代化工》Typst 模板

面向《现代化工》期刊中文稿件的 **社区制作** Typst 模板，用于排版中文论文的题名、摘要、
关键词、分级标题、图表、公式与参考文献。支持 `typst init` 直接创建新文章。

> **身份说明**
> 本模板由社区根据作者已调整的稿件排版整理，**不是**《现代化工》官方模板，也**未**经期刊
> 官方认证。参考文献样式（CSL）由稿件参考文献列表重建，相关排印细节**尚未**逐条对照期刊
> 官方投稿规范核实。正式投稿前请以期刊最新《投稿须知》为准。
>
> 包名 `clear-mci`、版本 `0.1.0` 为开发期名称，**尚未**注册或发布到 Typst Universe。

---

## 目录结构

| 路径 | 作用 |
| --- | --- |
| `typst.toml` | 包清单与初始化模板配置 |
| `journal.typ` | **唯一的样式源码**：排版规则、可复用组件、主入口 `mci` |
| `template/main.typ` | 初始化后供你编辑的最小文章示例 |
| `template/references.bib` | 示例用少量参考文献 |
| `template/modern-chemical-industry-custom.csl` | 参考文献样式（初始化时复制到你的项目） |
| `template/images/` | 示例图片 |
| `thumbnail.png` | 模板预览图 |

**改文章**：编辑初始化项目里的 `main.typ` 与 `references.bib`。
**改期刊样式**：只改 `journal.typ`（必要时改 `template/modern-chemical-industry-custom.csl`）。

---

## 使用

### 发布到 Typst Universe 之后（预期用法）

```bash
typst init @preview/clear-mci:0.1.0 my-paper
cd my-paper
typst compile main.typ
```

> 尚未发布时，上面的 `@preview/clear-mci:0.1.0` 无法从官方仓库下载；发布后方可使用。

### 发布前，从本仓库本地测试

Typst 从 `{包根}/{namespace}/{name}/{version}/` 结构查找本地包。先把本仓库内容复制到该结构，
再用 `--package-path` 初始化，避免覆盖已有同名包：

```bash
mkdir -p pkgroot/preview/clear-mci/0.1.0
cp -r ./* pkgroot/preview/clear-mci/0.1.0/          # 不含 .git

typst init --package-path ./pkgroot @preview/clear-mci:0.1.0 my-paper
cd my-paper
typst compile --package-path ../pkgroot main.typ
```

---

## 配置

所有参数均可省略，默认值即既有排版。需要覆盖时：

```typ
#import "@preview/clear-mci:0.1.0": *

#show: mci.with(
  body-font: "SimSun",             // 中文正文字体
  cn-title-font: "SimHei",         // 中文题名字体
  en-font: "Times New Roman",      // 英文字体（兼作中英混排拉丁字体）
  math-font: "Cambria Math",       // 数学字体
  heading-1-pagebreak: true,       // 一级标题是否另起一页（用户偏好，非期刊强制）
)
```

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `body-font` | `"SimSun"` | 中文正文/题注/表注的字体 |
| `cn-title-font` | `"SimHei"` | 中文题名字体（正文英文与数字用 `en-font`） |
| `en-font` | `"Times New Roman"` | 英文字体，同时作为中英混排的拉丁回退 |
| `math-font` | `"Cambria Math"` | 独立公式字体 |
| `heading-1-pagebreak` | `true` | 一级标题是否另起一页 |

字体配置会实际作用于正文与各组件（题名、摘要、关键词、表注等），组件内部通过共享配置读取，
**无需**在每次调用时重复传字体。

> `heading-1-pagebreak: true` 是作者保留的个人偏好，并非《现代化工》的强制规范，可自行关闭。

---

## 字体依赖

默认排版依赖以下 **Windows 字体**（本包不随附字体，避免再分发授权问题）：

- `SimSun`（宋体）——中文正文
- `SimHei`（黑体）——中文题名
- `Times New Roman`——英文
- `Cambria Math`——数学公式

未安装相应字体时，Typst 会提示 `unknown font family` 并回退，排版可能与预期不同。
如需在其他系统使用，请安装这些字体，或在 `mci.with(...)` 中改为本机已安装的等价字体
（例如开源字体），再确认字号/行距观感是否仍符合预期。

---

## 基本用法

### 题名、摘要、关键词

```typ
#title-cn[中文题名]
#abstract-cn[中文摘要……]
#keyword-cn[关键词一\;关键词二\;关键词三]

#pagebreak()

#title-en[English Title]
#abstract-en[English abstract……]
#keyword-en[keyword one; keyword two]
```

### 标题

```typ
// 引言：一级标题样式但不编号（不匹配章节名，由本处声明实现）
#heading(level: 1, numbering: none)[引言]

= 一级标题
== 二级标题
=== 三级标题
```

一级标题默认另起一页；关闭见 `heading-1-pagebreak`。标题编号固定为 `1.1.1` 三级。

### 图片

```typ
#figure(
  image("images/XRD.png", width: 80%),
  caption: [示例图片：广角 XRD 图谱],
) <fig-xrd>

如图 @fig-xrd 所示……      // 自动编号并渲染为“图 1”
```

### 三线表与表注

```typ
#figure(
  table(
    columns: (1.5fr, 1.5fr, 1fr),
    table.hline(stroke: 0.8pt),
    table.header([样品], [参数 A], [参数 B]),
    table.hline(stroke: 0.4pt),
    [A], [603.4], [5.90],
    [B], [966.0], [2.61],
    table.hline(stroke: 0.8pt),
  ),
  caption: [示例三线表],
) <tab-x>

#table-note[$S_("BET")$：BET 比表面积；$D_p$：平均孔径。]

见表 @tab-x。              // 自动编号并渲染为“表 1”
```

- 表格题注默认在表上方；表格不画网格线，三线由 `table.hline` 指定。
- `table-note` 不参与编号，置于表下。

### 公式

```typ
$ X = (overline(A_0) - overline(A_T)) / overline(A_0) times 100% $ <eq-conv>

按式 @eq-conv 计算……       // 自动编号并渲染为“式 1”
```

### 参考文献

CSL 文件会在 `typst init` 时被复制到你的项目目录，与 `references.bib` 同级，因此在
`main.typ` 中直接以相对路径引用即可：

```typ
#bibliography(
  "references.bib",
  style: "modern-chemical-industry-custom.csl",
  title: [参考文献],
)
```

正文引用用 `@key`（如 `@duan2023`），渲染为上标方括号编号。CSL 的标点（尤其页码前的
**半角冒号**）保持原样。BibTeX 条目中可使用 `#sub[2]`、`#super[0]` 写法表示上下标，
模板在参考文献中会将其转换为真正的上下标。

> 路径说明：Typst 的 `bibliography()` 路径相对 **调用它的文件**（即你的 `main.typ`）解析；
> 因此 CSL 与 `.bib` 都放在项目内、以相对路径引用最稳妥。

---

## 许可

- 包代码（如 `journal.typ`）：**MIT**，见 `LICENSE`。
- 初始化模板目录 `template/`（会被复制到用户项目、并由用户修改）：**MIT-0**（MIT No Attribution，无需署名、无需分发许可文本），见 `LICENSE-MIT-0`。

按 Typst 对模板包的建议，模板目录使用无需署名的许可，便于用户无限制地使用和分发自己修改后的稿件。

---

## 发布前待办

- [x] 已填写 `authors`、`license`（MIT AND MIT-0）、`repository`
- [x] 已添加 `LICENSE` / `LICENSE-MIT-0`
- [ ] 确认/替换 `thumbnail.png`（当前为示例第 5 页的渲染图，可替换）
- [ ] 对照《现代化工》最新投稿规范核实排印细节（当前系根据作者稿件重建，未逐条核实）
