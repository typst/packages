# gbt9704-gongwen — 适配 GB/T 9704-2012 · 党政机关公文格式

Version: 0.1.0

A Typst template that adapts **GB/T 9704-2012**, the Chinese national standard for official government document layout.
适配 **GB/T 9704-2012**《党政机关公文格式》的 Typst 模板。

## Features · 功能特性

- Strict GB compliance: page margins, font sizes, line spacing, heading fonts, indentation rules, justified alignment.
  严格遵循国标：页面边距、字号行距、标题字体、缩进规则、两端对齐。
- Document element functions: red-header, main receiver, attachments, signatures, dates, 版记 (end-matter).
  提供红头、主送、附件、署名、日期、版记等公文要素函数。
- Red separator line (header) and black separator line (end-matter).
  支持红色分隔线（红头）和黑色分隔线（版记）。
- CJK font fallback chain with open-source alternatives.
  兼容中文字体回退（大标宋 → 黑体）。

## Quick Start · 快速开始

### Using typst init · 初始化

```bash
typst init @preview/gbt9704-gongwen
```

### Manual import · 手动导入

```typst
#import "@preview/gbt9704-gongwen:0.1.0": *
#show: gbt9704.with(redline: true, title-indent: true)

// Your document content ... 文档内容 ...
```

### Options · 选项

`gbt9704` accepts the following parameters / 接受以下参数：

| Parameter 参数 | Type 类型 | Default 默认 | Description 说明 |
|------|------|--------|------|
| `redline` | bool | `false` | Draw red separator below red-header / 红头下方红色分隔线 |
| `title-indent` | bool | `true` | Indent section headings 2 characters / 章节标题首行缩进 2 字符 |

## Core Functions · 核心函数

| Function 函数 | Description 说明 |
|------|------|
| `gongwentitle(title)` | Document title (22pt red title font, centered) / 大标题（二号大标宋，居中） |
| `gongwensubtitle(subtitle)` | Subtitle (16pt FangSong, centered) / 副标题（三号仿宋，居中） |
| `make-header(organ, number, signatory, redline)` | Red-header (organ name, document number, signatory) / 红头（发文机关、发文字号、签发人） |
| `main-receiver(receiver)` | Main receiver (flush left, no indent) / 主送机关（顶格，取消缩进） |
| `attachment(title)` | Single attachment with "附件：" prefix / 单附件（带「附件：」前缀） |
| `attachment-no-hz(title)` | Attachment without prefix, for numbered items / 单附件（无前缀，用于带序号） |
| `attachment-item(title, indent)` | Custom-indented attachment item / 多附件条目（自定义缩进量） |
| `signature(name)` | Signature block (right-aligned, 2-character right margin) / 署名（右对齐，右侧空 2 字符） |
| `signdate(date)` | Date block (same format as signature) / 日期（同署名格式） |
| `notes(text)` | Notes in parentheses, no indent / 附注（括号内，无缩进） |
| `copyto(text)` | CC field with "抄送：" prefix / 抄送（「抄送：」前缀） |
| `issueinfo(organ, date)` | Issuing organ and date, left-right aligned / 印发机关与日期（左右对齐） |
| `seprule` | Black separator line (for end-matter) / 黑色分隔线（版记使用） |
| `redrule` | Red separator line (for header) / 红色分隔线（红头使用） |

## Heading Levels · 标题级别

| Level 级别 | Syntax 语法 | Font 字体 | Size 字号 |
|------|------|------|------|
| 1 | `=` | SimHei (黑体) | 16pt |
| 2 | `==` | KaiTi bold (楷体加粗) | 16pt |
| 3 | `===` | FangSong bold (仿宋加粗) | 16pt |

## Font Dependencies · 字体依赖

The following fonts are required (fallbacks are used in order):
系统需安装以下字体（按优先级自动回退）：

| Font 字体 | Purpose 用途 | Fallback 备选 |
|------|------|------|
| FZDaBiaoSong-B06 (方正大标宋) | Red-header, document title / 红头、大标题 | SimHei (黑体) |
| FangSong (仿宋) | Body text / 正文 | SimSun (宋体) |
| SimHei (黑体) | Level-1 headings / 一级标题 | Noto Sans CJK SC |
| KaiTi (楷体) | Level-2 headings / 二级标题 | STKaiti, Noto Serif CJK SC |
| SimSun (宋体) | Auxiliary / 辅助 | Noto Serif CJK SC |

## Project Structure · 项目结构

```text
gbt9704-gongwen/
├── src/
│   └── lib.typ               # Template source / 模板主文件
├── template/
│   └── main.typ              # typst init template / typst init 模板
├── examples/
│   ├── example.typ           # Full government document example (zh) / 完整公文案例（中文）
│   ├── example-en.typ        # Government document example (en) / 完整公文案例（英文）
│   ├── manual.typ            # Usage manual (zh) / 使用手册（中文）
│   └── manual-en.typ         # Usage manual (en) / 使用手册（英文）
├── typst.toml
├── LICENSE
└── README.md
```

## Examples · 示例

Compile the examples / 编译示例文件：

```bash
# Government document case — Chinese (red-header, tables, attachments, 版记)
# 完整公文案例 — 中文（含红头、表格、附件、版记）
typst compile --root . examples/example.typ

# Government document case — English
# 完整公文案例 — 英文
typst compile --root . examples/example-en.typ

# Usage manual — Chinese (API reference)
# 使用手册 — 中文（API 参考）
typst compile --root . examples/manual.typ

# Usage manual — English
# 使用手册 — 英文
typst compile --root . examples/manual-en.typ
```

Pre-compiled PDFs / 预编译 PDF：
- [example.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/example.pdf)
- [example-en.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/example-en.pdf)
- [manual.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/manual.pdf)
- [manual-en.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/manual-en.pdf)

## Changelog · 变更记录

### v0.1.0 (2026-07-09)

- **First Typst release**: Full GB/T 9704-2012 official document format support.
  **首个 Typst 版本**：完整的 GB/T 9704-2012 党政机关公文格式支持。
- A4 page, GB-standard margins (L 28mm, R 26mm, T 37mm, B 35mm), 28pt line spacing.
  A4 页面，国标边距，28 磅行距。
- Document element functions: red-header, title, main receiver, attachment, signature, date, end-matter, notes, CC.
  公文要素函数：红头、标题、主送、附件、署名、日期、版记、附注、抄送。
- Chinese heading numbering (一、（一）、1.), first-line indent, centered tables.
  中文标题编号支持，首行缩进，表格居中。
- Font sizes: title 22pt, body 16pt, document number 12pt.
  字号：大标题二号 (22pt)、正文三号 (16pt)、发文字号四号 (12pt)。
- Font fallback: FZDaBiaoSong, FangSong, SimHei, KaiTi, SimSun + open-source alternatives.
  字体回退链覆盖方正、仿宋、黑体、楷体、宋体及开源替代。
- `typst init @preview/gbt9704-gongwen` quick-start template.
  `typst init @preview/gbt9704-gongwen` 快速开始模板。

## Feedback & Contributing · 反馈与贡献

- Issues: https://codeberg.org/songwupei/typst-gbt9704/issues
- Repository: https://codeberg.org/songwupei/typst-gbt9704
