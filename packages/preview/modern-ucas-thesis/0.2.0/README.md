<h1 align="center">modern-ucas-thesis</h1>

<p align="center">
  <a href="docs/README_EN.md">English</a> | <strong>中文</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-beta-blue?style=flat-square" alt="Project Status">
  <img src="https://img.shields.io/github/last-commit/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Last Commit">
  <img src="https://img.shields.io/github/issues/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Issues">
  <img src="https://img.shields.io/github/license/Vncntvx/modern-ucas-thesis?style=flat-square" alt="License">
</p>

基于 [Typst](https://typst.app/) 的中国科学院大学学位论文，参考《中国科学院大学研究生学位论文撰写规范指导意见（2022年）》格式要求。

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

# 编译论文
typst compile template/thesis.typ

# 或开启实时预览
typst watch template/thesis.typ
```

### 3. 配置论文信息

编辑 `template/thesis.typ`：

```typst
#import "../lib.typ": *

#show: documentclass.with(
  title: "论文标题",
  author: "作者姓名",
  supervisor: "导师姓名",
  degree: "博士",
  major: "计算机科学与技术",
)

// 开始撰写...
```

---

## 项目结构

```text
modern-ucas-thesis/
├── template/          # 论文源文件
│   ├── thesis.typ    # 主文件
│   ├── ref.bib       # 参考文献
│   └── images/       # 图片目录
├── pages/            # 页面模板（封面、摘要等）
├── layouts/          # 布局模板（前言、正文、附录）
├── utils/            # 工具函数
├── lib.typ           # 主库入口
└── docs/             # 文档
```

---

## 功能特性

| 功能类别 | 功能项 | 实现状态 |
|----------|--------|----------|
| **文档配置** | 全局信息配置（文档类型、学位类型、字体等） | 已完成 |
| | 盲审模式 | 已完成 |
| | 双面打印模式 | 已完成 |
| **封面与前置页** | 本科封面（中文/英文） | 待完善 |
| | 研究生封面（中文/英文） | 已完成 |
| | 原创性声明与授权说明 | 研究生已完成，本科待完善 |
| | 中文摘要（含关键词） | 已完成 |
| | 英文摘要（含关键词） | 已完成 |
| | 目录（含图表目录） | 已完成 |
| | 符号表（术语与符号说明） | 已完成 |
| **正文排版** | 章节标题编号 | 已完成 |
| | 页眉页脚设置 | 待完善 |
| | 脚注与尾注 | 未开始 |
| | 交叉引用（图表公式章节） | 已完成 |
| **图表处理** | 双语图表标题 | 已完成 |
| | 图表注释（表注、图注） | 已完成 |
| | 图表按章节编号 | 已完成 |
| | 自动/手动续表 | 待完善 |
| | 附录图表自动加"附"前缀 | 待完善 |
| **公式与数学** | 行间公式编号 | 已完成 |
| | 多行公式对齐与编号 | 已完成 |
| | 公式按章节编号 | 已完成 |
| | 附录公式加"附"前缀 | 已完成 |
| **参考文献** | 双语参考文献标题 | 已完成 |
| | GB/T 7714-2015 格式支持 | 已完成 |
| | 中英文文献格式自动转换 | 已完成 |
| | 文献引用与交叉引用 | 已完成 |
| **附录与后置** | 附录章节（罗马数字编号） | 已完成 |
| | 致谢页 | 已完成 |
| | 作者简介与学术成果 | 已完成 |
| **字体与排版** | 预定义字体组 | 已完成 |
| | 自定义字体配置 | 已完成 |
| | 中西文字体混排 | 已完成 |
| **其他文档类型** | 博士后学位论文 | 未开始 |
| | 本科生开题报告 | 未开始 |
| | 研究生开题报告 | 未开始 |
| | 定理/引理/证明环境 | 未开始 |

---

## 文档

- [定制指南](docs/CUSTOMIZE.md)
- [常见问题](docs/FAQ.md)
- [格式化工具](docs/FORMAT.md)

---

## 开发

```bash
# 格式化代码
make format

# 检查格式
make format-check
```

---

## 致谢

- 基于 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 开发
- 参考 [ucasthesis](https://github.com/mohuangrui/ucasthesis) LaTeX 模板

---

## 许可证

本项目代码采用 [MIT](LICENSE) 许可证开源。

**关于 UCAS 标识**：`assets/vi/` 目录下的校徽、Logo 等视觉标识的版权归中国科学院大学所有。本项目将其纳入仅为方便用户撰写学位论文（属于个人学习/教学合理使用范畴），请勿用于其他商业或官方用途。如需商用授权，请联系学校相关部门。详见 [docs/LOGO_COPYRIGHT.md](docs/LOGO_COPYRIGHT.md)。

---

<p align="center">
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/issues">报告问题</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/discussions">讨论交流</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/pulls">贡献代码</a>
</p>
