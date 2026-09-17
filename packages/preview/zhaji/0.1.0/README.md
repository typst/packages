# zhaji · 札记

<p align="center">
  <b>A clean, restrained academic lecture notes and book template for Typst.</b><br>
  <b>专为理工科与数学设计的严肃、克制、优美的 Typst 课程讲义与笔记模板。</b>
</p>

<p align="center">
  <a href="#english">English Documentation</a> •
  <a href="#中文文档">中文文档</a>
</p>

---

<a name="english"></a>
## English Documentation

`zhaji` is a minimalist, publication-grade [Typst](https://typst.app/) template tailored for mathematics, theoretical science, and engineering courses.

Instead of heavy colored containers and cumbersome multi-level numeric counters (e.g., `1.1.2.1`), it embraces classic academic publishing aesthetics:
- **Clean Font Hierarchy**: Songti SC / SimSun for Chinese text, Heiti SC / SimHei for headings, and New Computer Modern for Latin characters and mathematics.
- **Dual-Track Compilation**: Compile single lesson notes independently during class with instantaneous preview, or compile the whole book into a unified volume with an auto-generated Table of Contents and clean page numbers.
- **Visual Anchor Hierarchy**: Headings are distinguished through vertical color accents, subtle geometric glyphs, and calibrated whitespace rather than noisy digits.
- **Restrained Callouts**: Only 3 intuitive block macros (`#thm`, `#def`, `#hint`) that eliminate verbose parameter boilerplate.
- **Dynamic Headers & Footers**: Centered footer page numbers, cover pages with zero header/footer noise, and running headers that dynamically track the current section.

---

### Recommended Project Layout

The template is distributed as a package, so there is no template directory to
copy or maintain: import `@preview/zhaji:0.1.0` and a course repository only
needs its own material.

```text
my-zhajis/
├── book.typ               # Full book entry point (Cover + Outline + Chapters)
├── notes/                 # Lesson notes (01.typ, 02.typ, ...)
├── figures/               # Vector plots, phase portraits, diagrams
└── out/                   # Exported PDFs (git-ignored)
```

---

### Installation

`zhaji` is available on [Typst Universe](https://typst.app/universe/package/zhaji),
so there is nothing to install: import it and start writing.

```typst
#import "@preview/zhaji:0.1.0": *
```

To begin from the bundled example document, pick the `zhaji` template in the
Typst web app or run:

```bash
typst init @preview/zhaji:0.1.0 my-notes
```

#### Alternative: local packages (`@local`)

If you would rather track a development checkout of this repository, you can
expose it through Typst's `@local` namespace instead.

##### macOS
```bash
# 1. Create the package namespace directory
mkdir -p "$HOME/Library/Application Support/typst/packages/local/zhaji"

# 2. Symlink your checkout as version 0.1.0
ln -s "/path/to/typst-zhaji" "$HOME/Library/Application Support/typst/packages/local/zhaji/0.1.0"
```

##### Linux
```bash
mkdir -p "$HOME/.local/share/typst/packages/local/zhaji"
ln -s "/path/to/typst-zhaji" "$HOME/.local/share/typst/packages/local/zhaji/0.1.0"
```

##### Windows (PowerShell)
```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\typst\packages\local\zhaji"
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\typst\packages\local\zhaji\0.1.0" -Target "C:\path\to\typst-zhaji"
```

Once linked, import the local copy with:
```typst
#import "@local/zhaji:0.1.0": *
```

---

### Quick Start

#### 1. Single Lesson Mode (`notes/01.typ`)
For fast, frictionless classroom note-taking:

```typst
#import "@preview/zhaji:0.1.0": *
#show: note

== Introduction

=== Free Fall Model
Consider a point mass $m$ undergoing free fall under gravity...
```

- **Output**: Clean A4 document with 2-character Chinese paragraph indent, running header with current section title, and centered page number in the footer.

#### 2. Full Book Mode (`book.typ`)
Assemble all lectures into a comprehensive course volume:

```typst
#import "@preview/zhaji:0.1.0": *
#show: note.with(
  title: "Ordinary Differential Equations",
  subtitle: "Lecture Notes & Compendium",
  author: "Author Name",
  mode: "book",
)

= Chapter 1: Introduction and Elementary Methods

#include "notes/01.typ"
#include "notes/02.typ"

= Chapter 2: Linear Differential Equations

#include "notes/03.typ"
```

- **Output**:
  - **Cover Page**: Elegant centered title, subtitle, author, and date without headers, footers, or page numbers.
  - **Table of Contents**: Auto-generated outline (depth 2: chapters and sections only) with leader dots.
  - **Body Text**: Numbering restarts from page 1 in the footer center; running headers track the current chapter/section.
  - **Collision-Proof**: Subfile `#show: note` calls automatically detect the book environment and become transparent, preventing accidental blank page breaks.

---

### Core Syntax and Macros

#### 1. Theorem Block: `#thm`
Left border: 1.2pt navy/slate blue (`#3b5f82`). Pure white background.

```typst
// With title
#thm[Existence and Uniqueness][
  If $f(t, y)$ is continuous and Lipschitz continuous with respect to $y$,
  then the initial value problem admits a unique solution.
]

// Without title
#thm[
  Every homogeneous linear system of order $n$ has $n$ linearly independent solutions.
]
```

#### 2. Definition Block: `#def`
Left border: 1.2pt slate blue.

```typst
#def[Ordinary Differential Equation][
  An equation containing derivatives of an unknown function $y(t)$ is called an ODE.
]
```

#### 3. General Hint / Remark / Case Block: `#hint`
Left border: 1pt neutral gray (or amber for warnings).

```typst
#hint[Physical Model][
  Assume aerodynamic drag is proportional to velocity: $F_d = - gamma v$.
]

#hint(style: "amber")[Caution][
  Check whether stationary solutions $y = y_*$ are lost during separation of variables.
]
```

---

### Inline Helpers & Accents

- **Prominent Emphasis `#emph[...]`**:
  Renders key terminology in bold academic crimson (`#b02a2a`) to stand out naturally from black body text:
  ```typst
  This set of solutions is called the #emph[general solution].
  ```
- **Light Gray Tag `#key[...]`**:
  Renders a rounded gray inline badge for subtle reminders:
  ```typst
  Check boundary conditions. #key[Easy to miss]
  ```
- **Q.E.D. Symbol `#qed`**:
  Right-aligned hollow square $\square$ marking the end of a proof:
  ```typst
  This completes the verification. #qed
  ```

---

### Heading Hierarchy (Visual Anchors, No Digit Clutter)

| Level | Syntax | Visual Style | Intended Usage |
| :--- | :--- | :--- | :--- |
| **Level 1** | `= Chapter Title` | **20pt Bold**, full-width accent line below | Chapters / Major Course Themes |
| **Level 2** | `== Section Title` | **15pt Bold**, 3.5pt left vertical pill, generous top margin | Core Lecture Sections |
| **Level 3** | `=== Model / Topic` | **12.5pt Bold**, prefixed with solid square `■` | Concrete physical models, theorems, setups |
| **Level 4** | `==== Step / Subcase` | **11pt Bold**, prefixed with subtle dash `–` | Derivation branches, computational steps |

---

### Mathematical Shorthands Table

| Meaning | Template Shortcut | Official Typst Equivalent | Rendered |
| :--- | :--- | :--- | :--- |
| **Differential Operator** | `$dd x$` | `$dif x$` | $\mathrm{d}x$ |
| **Derivative Fraction** | `$(dd y)/(dd x)$` | `$(dif y)/(dif x)$` | $\frac{\mathrm{d}y}{\mathrm{d}x}$ |
| **Plus-Minus Sign** | `$pm$` | `$plus.minus$` or `$±$` | $\pm$ |
| **Minus-Plus Sign** | `$mp$` | `$minus.plus$` | $\mp$ |
| **Number Sets** | `$R$`, `$C$`, `$N$` | `$RR$`, `$CC$`, `$NN$` | $\mathbf{R}, \mathbf{C}, \mathbf{N}$ |
| **Constants & Imaginary**| `$e$`, `$i$` | `$upright(e)$`, `$upright(i)$` | $\mathrm{e}, \mathrm{i}$ |
| **Norm & Inner Product** | `$norm(x)$`, `$inner(a, b)$` | `$norm(x)$`, `$angle.l a, b angle.r$` | $\|x\|$, $\langle a, b \rangle$ |

---

<a name="中文文档"></a>
## 中文文档

`zhaji` 是一个专为数学、物理及理工科理论课程设计的 [Typst](https://typst.app/) 讲义与课堂笔记模板。

摒弃繁琐花哨的彩色卡片与多层机械数字编号（如 `1.1.2.1`），追求严肃、克制、优美的学术出版物风格：
- **经典学术字体排版**：正文使用 Songti SC / SimSun 配 New Computer Modern，标题使用 Heiti SC / SimHei，数学公式使用 New Computer Modern Math。
- **单课与全书双轨编译**：上课记笔记支持单课毫秒级实时预览；学期末支持一键合订为专著级全本（带纯净封面、自动目录、动态页眉与页脚正中页码）。
- **纯视觉锚点分层**：不使用冗长数字点号，利用色标、几何方块与留白级差实现清晰层级。
- **极简语义宏**：仅保留 `#thm`（定理）、`#def`（定义）、`#hint`（提示/情形/模型）三个核心块级宏，无繁琐参数。
- **动态页眉页脚体系**：页码居中位于页脚，全书目录深度为 2（只收录大章大节，整洁易管理），页眉动态追踪当前翻阅的小节名。

---

### 安装

`zhaji` 已收录于 [Typst Universe](https://typst.app/universe/package/zhaji)，无需任何安装步骤，直接导入即可使用：

```typst
#import "@preview/zhaji:0.1.0": *
```

若想从自带的示例文档开始，可在 Typst 网页版中直接选择 `zhaji` 模板，或在命令行执行：

```bash
typst init @preview/zhaji:0.1.0 my-notes
```

#### 备选方案：`@local` 本地包

如果你想直接使用本仓库的开发版本，也可以把它挂载到 Typst 的 `@local` 命名空间下，**彻底告别 `../` 相对路径和 `--root .` 编译限制**。

##### macOS 快速挂载
```bash
# 1. 创建本地包存放目录
mkdir -p "$HOME/Library/Application Support/typst/packages/local/zhaji"

# 2. 软链接你的仓库副本（请替换实际路径）
ln -s "/path/to/typst-zhaji" "$HOME/Library/Application Support/typst/packages/local/zhaji/0.1.0"
```

##### Linux
```bash
mkdir -p "$HOME/.local/share/typst/packages/local/zhaji"
ln -s "/path/to/typst-zhaji" "$HOME/.local/share/typst/packages/local/zhaji/0.1.0"
```

##### Windows (PowerShell)
```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\typst\packages\local\zhaji"
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\typst\packages\local\zhaji\0.1.0" -Target "C:\path\to\typst-zhaji"
```

挂载完成后，在任意课程笔记中均可直接使用：
```typst
#import "@local/zhaji:0.1.0": *
```

---

### 快速上手

#### 1. 单课独立笔记（例如 `notes/01.typ`）

```typst
#import "@preview/zhaji:0.1.0": *
#show: note

== 引论

=== 自由落体模型
考虑一个质量为 $m$ 的物体做自由落体运动……
```

#### 2. 全书讲义合订本（例如 `book.typ`）

```typst
#import "@preview/zhaji:0.1.0": *
#show: note.with(
  title: "常微分方程",
  subtitle: "课堂笔记与讲义",
  author: "你的名字",
  mode: "book",
)

= 第一章 绪论与初等积分法

#include "notes/01.typ"
#include "notes/02.typ"

= 第二章 高阶线性微分方程

#include "notes/03.typ"
```

---

### 核心块级宏与使用示例

#### 1. 定理环境：`#thm`
左侧 1.2pt 蓝灰细线，自动带有加粗黑体前缀：
```typst
#thm[解的存在唯一性][
  若 $f(t, y)$ 在定义域上连续且关于 $y$ 满足 Lipschitz 条件，则初值问题存在唯一解。
]
```

#### 2. 定义环境：`#def`
左侧 1.2pt 蓝灰细线，自动带有加粗黑体前缀：
```typst
#def[常微分方程][
  形如 $F(t, y(t), y'(t), dots, y^((n))(t)) = 0$ 的方程称为常微分方程。
]
```

#### 3. 通用提示/情形/模型环境：`#hint`
左侧 1pt 中灰细线（无底色，保持印刷级黑白质感）：
```typst
#hint[模型 · 自由落体][
  假设物体只受重力作用，取竖直向下为正方向。
]

#hint(style: "amber")[注][
  定解条件不一定只是初始条件，也可以是两点边值条件。
]
```

---

### 推荐 VS Code 配置（配合 Tinymist 插件）

在笔记项目根目录下的 `.vscode/settings.json` 中配置：

```json
{
  "tinymist.projectResolution": "singleFile",
  "tinymist.exportPdf": "onSave",
  "tinymist.outputPath": "$root/out/$dir/$name",
  "tinymist.preview.refresh": "onType",
  "tinymist.formatterMode": "typstyle",
  "tinymist.systemFonts": true,
  "[typst]": {
    "editor.formatOnSave": true,
    "editor.wordWrap": "on"
  }
}
```

---

## License

MIT License © 2026 Boshugege
