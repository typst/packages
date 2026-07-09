# gbt9704 for Typst

Version: 0.1.0  

Typst 模板，用于排版符合 **GB/T 9704-2012**《党政机关公文格式》的文档。

## 功能特性

- 严格遵循国标：页面边距、字号行距、标题字体、缩进规则、两端对齐。
- 提供红头、主送、附件、署名、日期、版记等公文要素函数。
- 支持红色分隔线（红头）和黑色分隔线（版记）。
- 兼容中文字体回退（大标宋 → 黑体）。

## 快速开始

### 使用 typst init

```bash
typst init @preview/gbt9704
```

### 手动导入

```typst
#import "@preview/gbt9704:0.1.0": *
#show: gbt9704.with(redline: true, title-indent: true)

// 文档内容 ...
```

### 选项

`gbt9704` 函数接受以下参数：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `redline` | bool | `false` | 是否在红头下方绘制红色分隔线 |
| `title-indent` | bool | `true` | 章节标题是否首行缩进 2 字符 |

## 核心函数

| 函数 | 说明 |
|------|------|
| `gongwentitle(title)` | 大标题（二号大标宋，红色，居中） |
| `gongwensubtitle(subtitle)` | 副标题（三号仿宋，居中） |
| `make-header(organ, number, signatory, redline)` | 红头（发文机关、发文字号、签发人） |
| `main-receiver(receiver)` | 主送机关（取消缩进） |
| `attachment(title)` | 单附件（带「附件：」前缀） |
| `attachment-no-hz(title)` | 单附件（无前缀，用于带序号） |
| `attachment-item(title, indent)` | 多附件条目（自定义缩进） |
| `signature(name)` | 署名（右对齐，右侧空 2 字符） |
| `signdate(date)` | 日期（同署名） |
| `notes(text)` | 附注（括号内，无缩进） |
| `copyto(text)` | 抄送（「抄送：」前缀） |
| `issueinfo(organ, date)` | 印发机关与日期（左右对齐） |
| `seprule` | 黑色分隔线（版记使用） |
| `redrule` | 红色分隔线（红头使用） |

## 标题级别

- 一级标题 (`=`) : 黑体，三号 (16pt)
- 二级标题 (`==`) : 楷体加粗，三号 (16pt)
- 三级标题 (`===`) : 仿宋加粗，三号 (16pt)

## 字体依赖

系统需安装以下字体（或提供备选）：

| 字体 | 用途 | 备选 |
|------|------|------|
| 方正大标宋（FZDaBiaoSong-B06） | 红头、大标题 | 黑体（SimHei） |
| 仿宋（FangSong） | 正文 | 宋体（SimSun） |
| 黑体（SimHei） | 一级标题 | Noto Sans CJK SC |
| 楷体（KaiTi） | 二级标题 | STKaiti, Noto Serif CJK SC |
| 宋体（SimSun） | 辅助 | Noto Serif CJK SC |

## 项目结构

```
gbt9704/
├── src/
│   └── lib.typ               # 模板主文件
├── template/
│   └── main.typ              # typst init 模板
├── examples/
│   ├── example.typ           # 完整公文案例
│   └── manual.typ            # 使用手册
├── typst.toml
├── LICENSE
└── README.md
```

## 示例

编译示例文件：

```bash
# 完整公文案例（含红头、表格、附件、版记）
typst compile --root . examples/example.typ

# 使用手册（API 参考）
typst compile --root . examples/manual.typ
```

参见 `examples/example.typ` 和 `examples/manual.typ`，或下载预编译 PDF：
- [example.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/example.pdf)
- [manual.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/manual.pdf)

## 变更记录

### v0.1.0 (2026-07-09)

- **首个 Typst 版本**：完整的 GB/T 9704-2012 党政机关公文格式支持。
- A4 页面，国标边距（左 28mm、右 26mm、上 37mm、下 35mm），28 磅行距。
- 公文要素函数：红头、标题、主送、附件、署名、日期、版记、附注、抄送。
- 中文标题编号支持（一、（一）、1.），首行缩进，表格居中。
- 字号：大标题二号 (22pt)、正文三号 (16pt)、发文字号四号 (12pt)。
- 字体回退链覆盖方正、仿宋、黑体、楷体、宋体及开源替代。
- `typst init @preview/gbt9704` 快速开始模板。

## 反馈与贡献

- Issue: https://codeberg.org/songwupei/typst-gbt9704/issues
- Repository: https://codeberg.org/songwupei/typst-gbt9704
