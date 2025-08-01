# 中国科学院大学学位论文 typst-ucas-thesis

<p align="center" style="color: #888; font-size: 0.95em; margin-top: -0.5em; margin-bottom: 0.5em;">
  <a href="docs/README_EN.md">English</a> | <b>中文</b>
</p>

<div align="center">

![Project Status](https://img.shields.io/badge/status-beta-blue?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/WayneXuCN/typst-ucas-thesis?style=flat-square)
![Issues](https://img.shields.io/github/issues/WayneXuCN/typst-ucas-thesis?style=flat-square)
![License](https://img.shields.io/github/license/WayneXuCN/typst-ucas-thesis?style=flat-square)

</div>

<details open>
<summary>🚧 <strong>当前状态：Beta 版，持续开发中，欢迎反馈与贡献！</strong> 🚧</summary>

> - 该模板可初步用于撰写论文，但有大量细节仍在持续完善。
> - 欢迎通过 <a href="https://github.com/WayneXuCN/typst-ucas-thesis/issues">Issue</a> 或 <a href="https://github.com/WayneXuCN/typst-ucas-thesis/pulls">PR</a> 提出建议、反馈问题或贡献代码。
>
</details>

<blockquote style="border-left: 4px solid #f39c12; background: #fffbe6; padding: 0.8em 1em;">
<strong>⚠️ 免责声明：</strong> 本项目为民间开发的 Typst 学位论文模板，<br>
非中国科学院大学官方模板，仅供学习与参考。<br>
<b>实际使用时请务必自行核对学校最新的论文格式要求，本模板不保证完全符合官方规范，存在不被学校或相关部门认可的风险，因使用本模板而产生的任何问题，开发者不承担相关责任。</b>
</blockquote>

## 🚀 特性

- 🎨 **规范格式**：遵循《中国科学院大学研究生学位论文撰写规范指导意见（2022 年）》规范格式开发
- 🔧 **易于定制**：配置文件简单，支持自定义字体、样式和布局
- 🛠️ **易于使用**：Typst 上手难度与 Markdown 相当，源码可读性高
- 🖥️ **环境友好**：Typst 包管理按需下载，原生支持中日韩等非拉丁语言，Web App / VS Code 开箱即用
- ✨ **编译极快**：Typst 基于 Rust 编写，采用增量编译和高效缓存，文档再长也能秒级生成 PDF
- 🧑‍💻 **现代编程**：Typst 拥有变量、函数、包管理、错误检查、闭包等现代特性，支持函数式编程，标记/脚本/数学多模式可嵌套

## ⏩ 快速开始

#### 1. 获取模板

```bash
# 方式一：直接克隆仓库
git clone https://github.com/WayneXuCN/typst-ucas-thesis.git
cd typst-ucas-thesis

# 方式二：下载最新版本
wget https://github.com/WayneXuCN/typst-ucas-thesis/archive/refs/heads/main.zip
unzip main.zip
```

#### 2. 编辑论文

修改 `template/thesis.typ` 文件开始撰写您的论文：

```typst
#import "../lib.typ": *

#show: documentclass.with(
  title: "您的论文标题",
  author: "您的姓名",
  // 其他配置...
)

// 开始撰写您的论文内容
```

#### 3. 编译生成

```bash
# 编译生成 PDF
typst compile template/thesis.typ

# 监听文件变化，自动编译
typst watch template/thesis.typ
```

## 📁 项目结构

```text
typst-ucas-thesis/
├── template/           # 模板文件目录
│   ├── thesis.typ     # 主论文文件
│   ├── ref.bib        # 参考文献
│   └── images/        # 图片资源
├── utils/             # 工具函数
├── pages/             # 页面模板
├── layouts/           # 布局模板
├── lib.typ            # 主库文件
└── docs/              # 文档
```

## 🛣️ 开发路线

### 🧰 基础功能

<details>
<summary><b>📖 基础模板组件</b></summary>

| 功能模块         | 状态       | 说明/计划           |
| ---------------- | ---------- | ------------------- |
| 页面尺寸与边距   | ✅ 已完成   | 标准页面设置        |
| 页眉页脚         | 🚧 进行中   | 样式优化            |
| 章节结构         | ✅ 已完成   | 标准章节            |
| 图表支持         | ✅ 已完成   | 支持插图与表格      |
| 字体配置         | ✅ 已完成   | 自定义字体组        |
| 参考文献         | 🚧 进行中   | 样式优化            |
| 自动索引        | 📋 计划中   | 图表/公式/章节自动生成索引 |
| 脚注与尾注      | 📋 计划中   | 脚注和尾注样式      |

</details>

<details>
<summary><b>🎨 样式与排版</b></summary>

| 功能模块         | 状态       | 说明/计划           |
| ---------------- | ---------- | ------------------- |
| 封面模板         | ✅ 已完成   | 标准封面            |
| 封面样式         | 🚧 进行中   | 细节优化            |
| 目录样式         | 🚧 进行中   | 目录美化            |
| 标题样式         | 🚧 进行中   | 样式优化            |
| 图表样式         | 🚧 进行中   | 样式优化            |
| PDF/A 兼容      | 📋 计划中   | 支持生成 PDF/A 格式 |

</details>

### 🎯 学位类型支持

<details>
<summary><b>🎓 本科生模板</b></summary>

| 组件             | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 字体测试页       | ✅ 已完成   | 字体显示测试       |
| 封面             | ✅ 已完成   | 标准本科封面       |
| 声明页           | ✅ 已完成   | 诚信声明页         |
| 中文摘要         | ✅ 已完成   | 中文摘要页         |
| 英文摘要         | ✅ 已完成   | 英文摘要页         |
| 目录页           | 🚧 进行中   | 目录样式优化       |
| 插图目录         | 🚧 进行中   | 插图列表           |
| 表格目录         | 🚧 进行中   | 表格列表           |
| 符号表           | 📋 计划中   | 符号说明           |
| 致谢             | ✅ 已完成   | 致谢页面           |

</details>

<details>
<summary><b>🎓 研究生模板</b></summary>

| 组件             | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 封面             | ✅ 已完成   | 标准研究生封面     |
| 声明页           | ✅ 已完成   | 学术声明页         |
| 摘要             | ✅ 已完成   | 中英文摘要         |
| 页眉             | 🚧 进行中   | 页眉样式优化       |
| 国家图书馆封面   | 📋 计划中   | 国图封面模板       |
| 出版授权书       | 📋 计划中   | 出版授权模板       |

</details>

<details>
<summary><b>🎓 博士后模板</b></summary>

| 组件             | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 博士后报告模板   | 📋 计划中   | 完整博士后模板     |

</details>

### ⚙️ 高级功能

<details>
<summary><b>🔧 全局配置</b></summary>

| 功能             | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 文档类配置       | ✅ 已完成   | `documentclass` 配置 |
| 盲审模式         | ✅ 已完成   | 隐藏个人信息       |
| 双面模式         | ✅ 已完成   | 双面打印支持       |
| 自定义字体       | ✅ 已完成   | 字体配置系统       |
| 数学字体配置     | ✅ 已完成   | 用户自定义配置     |
| 分章节编译      | 📋 计划中   | 支持分章节单独编译 |
| 盲审匿名增强    | 📋 计划中   | 支持自动匿名处理   |
| 开源协议声明    | 📋 计划中   | 支持开源协议声明页 |

</details>

<details>
<summary><b>🔢 编号系统</b></summary>

| 功能             | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 前言罗马数字     | ✅ 已完成   | 前言页码编号       |
| 附录罗马数字     | ✅ 已完成   | 附录页码编号       |
| 表格编号         | ✅ 已完成   | `1.1` 格式         |
| 数学公式编号     | ✅ 已完成   | `(1.1)` 格式       |
| 自动章节索引    | 📋 计划中   | 支持章节自动索引   |

</details>

<details>
<summary><b>📚 扩展功能</b></summary>

| 功能             | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 定理环境         | 📋 计划中   | 定理、证明等环境   |
| 附录模板         | 📋 计划中   | 完善附录模板       |
| 类型检查         | 📋 计划中   | 函数参数类型检查   |
| 详细文档         | 📋 计划中   | 完善使用文档       |

</details>

<details>
<summary><b>📄 其他文件</b></summary>

| 文件类型         | 状态       | 说明               |
| ---------------- | ---------- | ------------------ |
| 本科生开题报告   | 📋 计划中  | 本科开题模板       |
| 研究生开题报告   | 📋 计划中  | 研究生开题模板     |

</details>

**图例**：✅ 已完成 | 🚧 进行中 | 📋 计划中

## 🔧 配置说明

### 基本配置

在 `template/thesis.typ` 文件中修改以下配置：

```typst
#show: documentclass.with(
  title: "论文标题",
  author: "作者姓名",
  supervisor: "导师姓名",
  degree: "学位类型",
  major: "专业名称",
  // 更多配置选项...
)
```

### 自定义字体

模板支持自定义字体配置，详见 `fonts/` 目录。

### 图片与资源

将图片放置在 `template/images/` 目录下，在论文中使用相对路径引用。

## 🛠️ 开发指南

### template 目录

- `thesis.typ` 文件: 你的论文源文件，可以随意更改这个文件的名字，甚至你可以将这个文件在同级目录下复制多份，维持多个版本。
- `ref.bib` 文件: 用于放置参考文献。
- `images` 目录: 用于放置图片。

### 内部目录

- `utils` 目录: 包含了模板使用到的各种自定义辅助函数，存放没有外部依赖，且 **不会渲染出页面的函数**。
- `pages` 目录: 包含了模板用到的各个 **独立页面**，例如封面页、声明页、摘要等，即 **会渲染出不影响其他页面的独立页面的函数**。
- `layouts` 目录: 布局目录，存放着用于排篇布局的、应用于 `show` 指令的、**横跨多个页面的函数**，例如为了给页脚进行罗马数字编码的前言 `preface` 函数。
  - 主要分成了 `doc` 文稿、`preface` 前言、`mainmatter` 正文与 `appendix` 附录/后记。
- `lib.typ`:
  - **职责一**: 作为一个统一的对外接口，暴露出内部的 utils 函数。
  - **职责二**: 使用 **函数闭包** 特性，通过 `documentclass` 函数类进行全局信息配置，然后暴露出拥有了全局配置的、具体的 `layouts` 和 `pages` 内部函数。

### 代码格式化

本项目使用 `typstyle` 进行代码格式化：

```bash
# 安装 typstyle
brew install typstyle  # macOS
cargo install typstyle # 其他平台

# 格式化代码
make format           # 格式化所有文件
make format-check     # 检查格式
./format-typst.sh -a  # 使用脚本格式化
```

### 参与贡献

- 在 Issues 中提出你的想法，如果是新特性，可以加入路线图！
- 实现路线图中仍未实现的部分，然后欢迎提出你的 PR。
- 同样欢迎 **将这个模板迁移至你的学校论文模板**，大家一起搭建更好的 Typst 社区和生态吧。

## 📝 文档

- [格式化工具文档](docs/FORMAT.md)
- [常见问题解答](docs/FAQ.md)

## 🤝 致谢

- 感谢 [nju-lug](https://github.com/nju-lug) 开发的 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 模板，为此版本的开发提供了良好基础。
- 感谢 [mohuangrui](https://github.com/mohuangrui) 开发的 [ucasthesis](https://github.com/mohuangrui/ucasthesis) LaTeX 模板，为此版本的开发提供了思路参考

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 💬 支持与反馈

如果您在使用过程中遇到问题或有改进建议，欢迎：

- 🐛 [报告问题](https://github.com/WayneXuCN/typst-ucas-thesis/issues)
- 💡 [提出建议](https://github.com/WayneXuCN/typst-ucas-thesis/discussions)
- 🔧 [提交代码](https://github.com/WayneXuCN/typst-ucas-thesis/pulls)
