# 深圳大学 Typst 幻灯片模板 (SZU Typst Slides)

<p align="right">
  <a href="README.md">English</a> | <strong>中文</strong>
</p>

[![Typst 适用版本: 0.14+](https://img.shields.io/badge/Typst-0.14%2B-blue)](https://typst.app/)
[![Touying 适用版本: 0.7.4](https://img.shields.io/badge/Touying-0.7.4-orange)](https://touying-typ.github.io/)
[![开源协议: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

一个优雅、现代且专业的深圳大学（SZU）[Typst](https://typst.app/) 幻灯片与毕业答辩报告模板，基于 [Touying](https://touying-typ.github.io/) 框架构建。

内置两种深大官方品牌配色主题：**Metropolis**（深红现代极简风格）与 **University**（经典学术风格）。提供独立的中英文全套模板（遵循 `xxx_zh.*` 与 `xxx_en.*` 统一命名），彻底解决中英混排与元数据标签混乱问题。

---

## 页面预览

### 中文版幻灯片效果

| 封面标题页 | 目录大纲页 | 正文卡片与挑战 |
| :---: | :---: | :---: |
| <img src="gallery/preview-zh-cover.png" width="260" alt="深圳大学中文封面页"> | <img src="gallery/preview-zh-outline.png" width="260" alt="深圳大学中文大纲页"> | <img src="gallery/preview-zh-content.png" width="260" alt="深圳大学中文正文内容页"> |

### 英文版幻灯片效果

| Title Cover | Outline | Content |
| :---: | :---: | :---: |
| <img src="gallery/preview-en-cover.png" width="260" alt="SZU English Cover Slide"> | <img src="gallery/preview-en-outline.png" width="260" alt="SZU English Outline Slide"> | <img src="gallery/preview-en-content.png" width="260" alt="SZU English Content Slide"> |

---

## 核心特性

- **深大专属视觉规范**：精准还原深圳大学主色荔红（`#A20040`）、辅助金、校徽矢量图标及旗帜元素。
- **双主题随心切换**：支持 Metropolis 扁平极简风与 University 经典学术风一键切换。
- **纯正中英双语划分**：提供完全独立的中文模板（`main_zh.typ`）与英文模板（`main_en.typ`），封面标签、大纲、致谢与正文各自规范纯正。
- **丰富可复用组件**：内置卡片、指标展示、结论高亮块、标签行、规范表格、带编号大纲项等。
- **现代化 Typst 生态**：全面支持 Typst 0.14+ 与 Touying 0.7.4。

---

## 快速上手

### 方式一：通过 Typst Universe 初始化（推荐）

通过 Typst 官方 CLI 可以直接创建新幻灯片项目：

```bash
# 初始化幻灯片项目模板
typst init @preview/modern-szu-slides:0.1.0 my-slides
cd my-slides

# 编译默认幻灯片（中文）
typst compile main.typ

# 或编译英文版幻灯片
typst compile main_en.typ
```

在 Typst Web App 网页版中，点击 **Start from template** 并搜索 `modern-szu-slides` 即可一键创建。

### 方式二：克隆 GitHub 仓库

```bash
git clone https://github.com/Degurechaff57/szu-typst-slides.git
cd szu-typst-slides

# 编译中文幻灯片：
typst compile main_zh.typ main_zh.pdf

# 编译英文幻灯片：
typst compile main_en.typ main_en.pdf

# 兼容默认入口：
typst compile main.typ
```

### 实时预览与热更新

```bash
# 实时监视中文幻灯片修改：
typst watch main_zh.typ

# 实时监视英文幻灯片修改：
typst watch main_en.typ
```

---

## 切换主题

本包内置两套深大专属主题风格：
- **Metropolis 主题**（默认）：深红配色现代扁平学术风格。
- **University 主题**：经典大学学术风格，具备顶部横幅与侧边栏章节高亮。

使用包时切换主题非常简单：

```typst
#import "@preview/modern-szu-slides:0.1.0": *

// 默认使用 Metropolis 主题：
#show: szu-theme.with(lang: "zh", title: [我的论文题目], ...)

// 或切换为经典大学主题：
// #show: szu-uni-theme.with(lang: "zh", title: [我的论文题目], ...)
```

---

## 文件结构

本项目清晰划分为底层库组件与用户模板文件：

```text
modern-szu-slides/
├── lib.typ                   # 包主入口（统一重导出主题、组件、工具函数等）
├── src/                      # 底层库实现源码
│   ├── szu-colors.typ        # 深大品牌色值（红/金/蓝/青体系）
│   ├── szu-met-theme.typ     # SZU Metropolis 主题实现
│   ├── szu-uni-theme.typ     # SZU University 主题实现
│   ├── slide-cover.typ       # 封面与标题页布局实现
│   ├── slide-functions.typ   # 可复用组件（卡片、指标、图表、表格等）
│   └── slide-text.typ        # 全局字体、字号、配色变量
├── assets/
│   └── SZU_flag.pdf          # 矢量深大校旗旗帜图形
├── gallery/                  # 文档预览渲染图
│   ├── preview-zh-*.png
│   └── preview-en-*.png
├── template/                 # 初始化至用户项目的模板工程文件
│   ├── main.typ              # 默认入口（包含 main_zh.typ）
│   ├── main_zh.typ           # 中文幻灯片主入口
│   ├── main_en.typ           # 英文幻灯片主入口
│   ├── section-cover_zh.typ  # 中文封面元数据配置
│   ├── section-cover_en.typ  # 英文封面元数据配置
│   ├── section-outline_*.typ # 大纲页面
│   ├── section-*.typ         # 示例幻灯片章节
│   └── ref.bib               # BibTeX 参考文献库
├── LICENSE                   # MIT 开源协议与深大商标排除声明
├── README.md                 # 英文说明文档
└── README_zh.md              # 中文说明文档
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
| `img(path, caption, width)` | `#img("figures/chart.png", [图名], width: 60%)` | 居中图片与图题 |
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

## 开源协议与商标声明

- **模板代码与组件**：遵循 [MIT 开源协议](LICENSE)。
- **高校商标版权声明**：本项目中包含的深圳大学校旗旗帜图形（位于 `assets/SZU_flag.pdf`）属于**深圳大学**的注册商标与受保护财产，**不包含在 MIT 开源协议范围内**。该资源仅供深圳大学师生及科研人员在学术答辩、学术报告等非商业教育场景中使用。商标所有权归深圳大学所有（官网：https://www.szu.edu.cn ）。

## 致谢

- [Touying](https://touying-typ.github.io/) — 优秀的 Typst 幻灯片制作框架
- [modern-szu-slides](https://github.com/yjdyamv/modern-szu-slides) — 灵感来源的深大 LaTeX 模版
- 深圳大学 (Shenzhen University)

