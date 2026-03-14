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

### 2. 使用模板

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

```
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

## 功能支持

- **说明文档**
  - [ ] 编写更详细的说明文档，现在可以先参考 [NJUThesis](https://mirror-hk.koddos.net/CTAN/macros/unicodetex/latex/njuthesis/njuthesis.pdf) 的文档，参数大体保持一致，或者直接查阅对应源码函数的参数
- **类型检查**
  - [ ] 应该对所有函数入参进行类型检查，及时报错
- **全局配置**
  - [x] 类似 LaTeX 中的 `documentclass` 的全局信息配置
  - [x] **盲审模式**，将个人信息替换成小黑条，并且隐藏致谢页面，论文提交阶段使用
  - [x] **双面模式**，会加入空白页，便于打印
  - [x] **自定义字体配置**，可以配置「宋体」、「黑体」与「楷体」等字体对应的具体字体
  - [x] **数学字体配置**：模板不提供配置，用户可以自己使用 `#show math.equation: set text(font: "Fira Math")` 更改
- **模板**
  - [ ] 本科生模板
    - [ ] 字体测试页
    - [ ] 封面
    - [ ] 声明页
    - [x] 中文摘要
    - [x] 英文摘要
    - [x] 目录页
    - [x] 插图目录
    - [x] 表格目录
    - [x] 符号表
    - [ ] 致谢
  - [x] 研究生模板
    - [x] 封面
    - [x] 声明页
    - [x] 中文摘要
    - [x] 英文摘要
    - [ ] 目录页
    - [x] 图表目录
    - [x] 双语图表标题
    - [x] 符号表
    - [ ] 页眉
    - [ ] 致谢
    - [ ] 作者简历
  - [ ] 博士后模板
- **编号**
  - [x] 前言使用罗马数字编号
  - [x] 附录使用罗马数字编号
  - [x] 表格使用 `1.1` 格式进行编号
  - [x] 数学公式使用 `(1.1)` 格式进行编号
- **环境**
  - [ ] 定理环境（这个也可以自己使用第三方包配置）
- **其他文件**
  - [ ] 本科生开题报告
  - [ ] 研究生开题报告

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
