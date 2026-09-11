# 深圳大学 Typst 幻灯片模板 (SZU Typst Slides)

<p align="right">
  <a href="README.md">English</a> | <strong>中文</strong>
</p>

[![Typst 适用版本: 0.14+](https://img.shields.io/badge/Typst-0.14%2B-blue)](https://typst.app/)
[![Touying 适用版本: 0.7.4](https://img.shields.io/badge/Touying-0.7.4-orange)](https://touying-typ.github.io/)
[![开源协议: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

一个优雅、现代且专业的深圳大学（SZU）[Typst](https://typst.app/) 幻灯片与毕业答辩报告模板，基于 [Touying](https://touying-typ.github.io/) 框架构建。

内置两种深大官方品牌配色主题：**Metropolis**（深红现代极简风格）与 **University**（经典学术风格）。提供独立的中英文全套模板（遵循 `xxx_zh.*` 与 `xxx_en.*` 统一命名），彻底解决中英混排与元数据标签混乱问题。

<p align="center">
  <img src="assets/szu-logo.svg" width="120" alt="SZU logo">
</p>

---

## 核心特性

- **深大专属视觉规范**：精准还原深圳大学主色荔红（`#A20040`）、辅助金、校徽矢量图标及旗帜元素。
- **双主题随心切换**：支持 Metropolis 扁平极简风与 University 经典学术风一键切换。
- **纯正中英双语划分**：提供完全独立的中文模板（`main_zh.typ`）与英文模板（`main_en.typ`），封面标签、大纲、致谢与正文各自规范纯正。
- **丰富可复用组件**：内置卡片、指标展示、结论高亮块、标签行、规范表格、带编号大纲项等。
- **现代化 Typst 生态**：全面支持 Typst 0.14+ 与 Touying 0.7.4。

---

## 快速上手

### 1. 安装 Typst

- **macOS** (Homebrew):
  ```bash
  brew install typst
  ```
- **Arch Linux**:
  ```bash
  pacman -S typst
  ```
- **Windows** (Winget / Scoop):
  ```powershell
  winget install --id Typst.Typst
  # 或
  scoop install typst
  ```
- 或从 [Typst Releases](https://github.com/typst/typst/releases) 直接下载预编译二进制。

### 2. 克隆模板

```bash
git clone https://github.com/<your-username>/szu-typst-slides.git
cd szu-typst-slides
```

### 3. 选择语言并修改个人信息

- **中文幻灯片**：编辑 `section-cover_zh.typ`，修改论文标题、答辩人、导师、学院、专业等。
- **英文幻灯片**：编辑 `section-cover_en.typ`，填写对应英文信息。

### 4. 编译导出 PDF

```bash
# 编译中文幻灯片：
typst compile main_zh.typ main_zh.pdf

# 编译英文幻灯片：
typst compile main_en.typ main_en.pdf

# 兼容默认编译入口：
typst compile main.typ
```

### 5. 实时预览与热更新

```bash
# 实时监视中文幻灯片修改：
typst watch main_zh.typ

# 实时监视英文幻灯片修改：
typst watch main_en.typ
```

---

## 切换主题

编辑 `main_zh.typ`（或 `main_en.typ`），通过注释/取消注释顶部的主题引入语句即可切换：

```typst
// Metropolis 主题（默认：深红配色极简风）
#import "libs/szu-met-theme.typ": *

// University 主题（经典学术页眉与侧边栏风格）
// #import "libs/szu-uni-theme.typ": *
```

---

## 文件结构

本项目采用统一的中英文划分命名规范（`xxx_en.*` 和 `xxx_zh.*`）：

```text
szu-typst-slides/
├── README.md                 # 英文说明文档（默认入口）
├── README_zh.md              # 中文说明文档
├── README_en.md              # 英文说明文档别名
├── main_zh.typ               # 中文幻灯片主入口
├── main_en.typ               # 英文幻灯片主入口
├── main.typ                  # 兼容入口（默认引入 main_zh.typ）
├── libs/
│   ├── szu-colors.typ        # 深大品牌色值（红/金/蓝/青体系）
│   ├── szu-met-theme.typ     # SZU Metropolis 主题实现
│   └── szu-uni-theme.typ     # SZU University 主题实现
├── slide-text.typ            # 全局字体、字号、配色变量
├── slide-functions.typ       # 可复用组件（卡片、指标、图表等）
├── slide-components.typ      # 兼容层导出文件
├── section-cover_zh.typ      # 中文封面页（在此填写答辩信息）
├── section-cover_en.typ      # 英文封面页
├── section-outline_zh.typ    # 中文大纲/目录页
├── section-outline_en.typ    # 英文大纲/目录页
├── section-background_zh.typ # 中文研究背景示例章节
├── section-background_en.typ # 英文研究背景示例章节
├── section-work_zh.typ       # 中文主要工作与实验示例章节
├── section-work_en.typ       # 英文主要工作与实验示例章节
├── section-summary_zh.typ    # 中文总结与展望示例章节
├── section-summary_en.typ    # 英文总结与展望示例章节
├── section-thanks_zh.typ     # 中文致谢页
├── section-thanks_en.typ     # 英文致谢页
├── section-appendix_zh.typ   # 中文附录示例
├── section-appendix_en.typ   # 英文附录示例
├── assets/                   # 校徽与矢量旗帜资源
└── ref.bib                   # BibTeX 参考文献库
```

---

## 内置组件

组件实现位于 `slide-functions.typ` 中：

| 组件 | 用法 | 说明 |
|------|------|------|
| `card(title, body)` | `#card([标题], [正文内容])` | 圆角卡片容器，用于凸显核心定义 |
| `conclusion-card(title, body)` | `#conclusion-card([结论], [正文])` | 带高亮边框的结论卡片 |
| `result-conclusion(body, label: [结论：])` | `#result-conclusion([主要发现])` | 带前缀标签的快速结论块 |
| `metric(label, value, note)` | `#metric([准确率], [94.8%], [较基线提升 4.2%])` | 核心实验指标展示块 |
| `small-title(text)` | `#small-title[小标题]` | 深大红小节标题 |
| `outline-item(index, title, subtitle)` | 见 `section-outline_*.typ` | 带数字角标的大纲卡片项 |
| `soft-note(body)` | `#soft-note[备注说明]` | 浅色背景提示框 |
| `issue-row(tag, desc)` | `#issue-row([问题标签], [问题详情描述])` | 胶囊标签与描述行 |
| `img(path, caption, width)` | `#img("assets/szu-logo.svg", [图名], width: 60%)` | 居中图片与图题 |
| `slide-table(...)` | `#slide-table(columns: 2, ...)` | 适合幻灯片字号的表格封装 |

---

## 自定义配置

1. **封面信息**：编辑 `section-cover_zh.typ` 或 `section-cover_en.typ`，修改以下变量：
   - `thesis-title` / `cover-title`：论文题目
   - `thesis-subtitle`：报告副标题
   - `college-name`：学院名称
   - `major-name`：专业名称
   - `candidate-name`：答辩人姓名
   - `advisor-names`：导师姓名与职称
2. **章节内容**：根据实际情况修改或替换 `section-background_*.typ`、`section-work_*.typ`、`section-summary_*.typ` 等文件中的内容。
3. **幻灯片顺序**：在 `main_zh.typ` 或 `main_en.typ` 底部调整 `#xxx-section` 调用的顺序，或增删页面。
4. **排版微调**：如需调整字号、间距或色板，可直接编辑 `slide-text.typ`。

---

## 依赖说明

| 依赖项 | 推荐版本 | 用途 |
|--------|----------|------|
| **Typst** | `0.14+`（已在 `0.14.2` 测试） | 编译工具链与 CLI |
| `@preview/touying` | `0.7.4` | 幻灯片宏包框架 |
| `@preview/theorion` | `0.6.0` | 定理环境与数学公式支持 |
| `@preview/numbly` | `0.1.0` | 多级标题编号格式化 |
| `@preview/cuti` | `0.4.0` | 中文伪粗体模拟 |

> 首次编译时，Typst 会自动从官方 `@preview` 仓库拉取并缓存所需宏包。

---

## 字体配置

- **中文字体**：`Heiti SC`（macOS 系统黑体）
- **英文字体**：`Times New Roman`

如在 Windows 或 Linux 环境下使用，请打开 `slide-text.typ` 将 `zh-font` 改为系统已安装的中文字体：
```typst
#let zh-font = "SimHei"       // 例如 Windows 环境可使用黑体
#let en-font = "Times New Roman"
```

---

## 开源协议

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 致谢

- [Touying](https://touying-typ.github.io/) — 优秀的 Typst 幻灯片制作框架
- [modern-szu-slides](https://github.com/yjdyamv/modern-szu-slides) — 灵感来源的深大 LaTeX 模版
- 深圳大学 (Shenzhen University)
