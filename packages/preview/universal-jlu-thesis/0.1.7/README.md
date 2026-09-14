# 吉林大学毕业设计论文模板 | Jilin University Bachelor Thesis Typst Template

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FIslatri%2Funiversal-jlu-thesis%2Frefs%2Fheads%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239dae)](https://typst.app/universe/package/universal-jlu-thesis)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个优雅、易用的吉林大学毕业设计论文 Typst 模板，完全遵循学校的官方格式要求。 | A elegant and easy-to-use Typst template for Jilin University (a university in China) bachelor's thesis, fully compliant with the official formatting requirements.

![jlu-dev-cover.png](https://s2.loli.net/2025/10/18/U7pTgl59nRWjLD4.png)

> **警告：本模板为民间开源项目**，非官方出品，使用前请了解：
>
> - 模板可能不被学校官方完全认可
> - 正式提交时请提前验证格式是否符合要求
> - 建议保持源文件备份，以便随时转换至 Word 或 LaTeX

## 关于本项目

[Typst](https://typst.app/) 是使用 Rust 语言开发的全新文档排版系统，具有 Markdown 级别的简洁语法和 LaTeX 级别的专业排版能力。与 LaTeX 相比，Typst 提供了更快的编译速度、更直观的语法和更便捷的开发体验。

**universal-jlu-thesis** 是一套基于 Typst 的吉林大学毕业设计论文模板，遵循学校官方的格式要求，参考了 [universal-hit-thesis](https://github.com/hitszosa/universal-hit-thesis) 的设计思路，目前支持本科毕业设计论文格式。

## 特点

- ✨ **符合吉大格式要求** - 严格按照官方文档实现字号、字体、行距等格式
- 🚀 **开箱即用** - 无需复杂配置，克隆即可开始写论文
- 📦 **模块化设计** - 清晰的目录结构，易于维护和扩展
- 🎨 **美观的排版** - 专业的论文排版效果
- 📚 **拓展性好** - 除了支持本科毕业设计，如果有需要，未来将考虑支持硕士、博士等其他学位的论文格式
- 🔄 **持续维护** - 积极响应社区反馈和需求更新

## 快速开始

### 使用方式 Ⅰ：本地编辑（推荐）

这是最常见的使用方式，适合大多数用户。

#### 前置要求

首先安装 Typst，你可以通过以下方式之一进行安装：

- 访问 [Typst GitHub 仓库](https://github.com/typst/typst/releases/) 下载最新版本的安装包
- 如果使用 Scoop 包管理器：`scoop install typst`
- 如果使用 Homebrew（macOS）：`brew install typst`

安装完成后，确保 `typst` 命令在你的 `PATH` 环境变量中。

#### 方法 A：从 Typst Universe 初始化（最快）

```bash
typst init @preview/universal-jlu-thesis:0.1.7
cd universal-jlu-thesis
typst compile jlu-bachelor-thesis.typ
```

#### 方法 B：克隆仓库（开发者推荐）

```bash
git clone https://github.com/Islatri/universal-jlu-thesis.git
cd universal-jlu-thesis
node ./template.js // 生成模板文件的js脚本
typst compile ./template/jlu-bachelor-thesis.typ --root ./
```

#### 实时预览

使用以下命令进行实时预览（推荐搭配 VS Code + [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件）：

```bash
typst watch ./template/jlu-bachelor-thesis.typ --root ./
```

### 使用方式 Ⅱ：在线编辑

本模板已上传至 Typst Universe，你可以直接在 Typst Web App 中使用：

1. 访问 [Typst Web App](https://typst.app)
2. 登录后点击 `Start from template`
3. 搜索并选择 `universal-jlu-thesis`
4. 即可开始在线编辑

**Note:** Web App 的排版渲染在浏览器本地执行，实时预览体验与本地编辑相近。

Web App 默认不提供中文字体，建议手动上传以下字体文件以获得最佳排版效果：

- SimSun.ttf（宋体）
- SimHei.ttf（黑体）
- Kaiti.ttf（楷体）
- TimesNewRoman.ttf 及其变体

### 基本使用流程

1. 根据上述方式之一获取模板
2. 修改论文基本信息（标题、作者、指导教师等）
3. 按照示例格式，在对应目录编写各章节内容
4. 在 `refs.bib` 中添加参考文献
5. 运行编译命令生成 PDF

**Tip:** 推荐使用 VS Code 配合 Tinymist Typst 插件进行编辑，可获得语法高亮、实时预览、代码补全等功能。

## 文件结构

```bash
universal-jlu-thesis/
├── core/                          # 核心模板文件
│   ├── template.typ               # 主模板定义
│   ├── fonts.typ                  # 字体配置
│   ├── layout.typ                 # 页面布局
│   ├── headings.typ               # 标题样式
│   ├── cover.typ                  # 封面设计
│   ├── abstract.typ               # 摘要页
│   ├── toc.typ                    # 目录
│   ├── figures.typ                # 图表样式
│   ├── bibliography.typ           # 参考文献
│   ├── commitment.typ             # 承诺书
│   └── utils.typ                  # 工具函数
├── template/
│   ├── jlu-bachelor-thesis.typ    # 本科毕设模板示例
│   ├── refs.bib                   # 参考文献数据库
│   └── assets/                    # 资源文件
├── examples/                      # 示例文件
├── docs/                          # 文档说明
├── assets/                        # 模板资源
├── lib.typ                        # 库文件
├── template.js                    # 模板生成脚本
├── typst.toml                     # Typst 包配置
└── README.md                      # 本文件
```

## 特性与路线图

### 支持的学位类型

- ✓ 本科毕业设计
- ✗ 硕士学位论文
- ✗ 博士学位论文

### 已实现的功能

- ✓ 规范的封面设计
- ✓ 双语摘要支持
- ✓ 自动生成目录
- ✓ 参考文献管理
- ✓ 图表编号和引用
- ✓ 页脚页码设置
- ✓ 多级标题样式

### 计划中的功能

- ✗ 更多学位类型支持
- ✗ 更多更新的官方论文格式要求文档

## 依赖

### 必选依赖

- **Typst** 0.13.0 或更高版本

### 可选依赖

如需使用高级功能，可引入以下包：

```typst
// 用于绘制伪代码
#import "@preview/algo:0.3.6": algo, i, d, comment, code

// 或使用 lovelace
#import "@preview/lovelace:0.3.0": *
```

### 字体依赖

为获得最佳排版效果，建议安装以下字体：

- **SimSun**（宋体）- 正文字体
- **SimHei**（黑体）- 标题字体
- **Times New Roman** - 英文字体
- **Kaiti**（楷体）- 备用字体

本模板严格遵循吉林大学的格式要求。详细的格式对照表请参考下文。

## 字号对照表

### 表格一：各个部分对应的字号

| 论文部分 | 字号 | 字体 | pt值 | 其他格式要求 |
|---------|------|------|------|-------------|
| 目录标题 | 3号 | 黑体 | 16pt | 居中 |
| 目录内容 | 4号 | 宋体 | 14pt | 行距18磅 |
| 中文摘要标题 | 4号 | 黑体 | 14pt | 居中 |
| 中文摘要内容 | 小4号 | 宋体 | 12pt | 1.5倍行距 |
| 关键词 | 小4号 | 宋体 | 12pt | |
| 外文摘要标题 | 4号 | Times New Roman | 14pt | 居中 |
| 外文摘要内容 | 小4号 | Times New Roman | 12pt | 1.5倍行距 |
| Keywords | 小4号 | Times New Roman | 12pt | |
| 正文章标题 | 小3号 | 黑体 | 15pt | 加粗，居中，段前段后0.5行 |
| 正文节标题 | 小4号 | 黑体 | 12pt | 加粗，居中，段前段后0.5行 |
| 正文2级标题 | 4号 | 黑体 | 14pt | 加粗 |
| 正文3级标题 | 小4号 | 黑体 | 12pt | 不加粗 |
| 正文内容 | 小4号 | 宋体 | 12pt | |
| 结论标题 | 小3号 | 黑体 | 15pt | 居中 |
| 结论内容 | 小4号 | 宋体 | 12pt | 1.5倍行距 |
| 致谢标题 | 小3号 | 黑体 | 15pt | 居中 |
| 致谢内容 | 小4号 | 宋体 | 12pt | 1.5倍行距 |
| 参考文献标题 | 小3号 | 黑体 | 15pt | 居中 |
| 参考文献内容 | 小4号 | 宋体 | 12pt | 行距18磅 |
| 图表 | 5号 | 宋体 | 10.5pt | |

### 表格二：各个字号所用于的部分

| 字号 | pt值 | 使用部分 | 字体要求 | 格式要求 |
|------|------|---------|----------|----------|
| 3号 | 16pt | 目录标题 | 黑体 | 居中 |
| 小3号 | 15pt | 正文章标题、结论标题、致谢标题、参考文献标题 | 黑体 | 居中，章标题需加粗并设置段前段后0.5行 |
| 4号 | 14pt | 目录内容、中文摘要标题、外文摘要标题、正文2级标题 | 宋体/黑体/Times New Roman | 根据具体部分要求 |
| 小4号 | 12pt | 中文摘要内容、关键词、外文摘要内容、Keywords、正文节标题、正文3级标题、正文内容、结论内容、致谢内容、参考文献内容 | 宋体/黑体/Times New Roman | 根据具体部分要求 |
| 5号 | 10.5pt | 图表 | 宋体 | |

这两个表格可以帮助您快速查找每个部分应该使用的字号，以及每个字号都用在哪些部分，方便您在撰写毕业论文时进行格式设置。

## 已知问题

### 排版相关

- 尽管模板各部分的字体、字号等设置均与官方 Word 模板一致，但段落排版在视觉上可能存在细微差异
- 这些差异与字符间距、行距、段落间距等因素有关，属于不同排版系统的正常特性
- 如遇到严重的排版问题，请通过 [GitHub Issues](https://github.com/Islatri/universal-jlu-thesis/issues) 报告

### 参考文献相关

- 当前参考文献格式基于 GB/T 7714-2015 标准实现
- 某些特殊类型的参考文献（如学位论文）可能存在格式问题
- Web 版本中可能无法完美支持所有 BibTeX 字段

### 系统兼容性

- 目前主要针对 Windows 系统下的中文字体进行了适配
- macOS 和 Linux 系统下可能存在字体适配问题
- 如有兼容性问题，欢迎提交 Issue 或 PR

## 贡献指南

非常欢迎各种形式的贡献！无论是报告 Bug、提出建议，还是提交代码改进，我们都很感谢。

### 我们接受的贡献包括

- 🐛 Bug 报告和修复
- ✨ 新功能建议和实现
- 🎨 格式纠正
- 📝 文档改进
- 🎓 **研究生论文模板**（硕士、博士等）
- 💡 代码优化和重构

### 如何贡献

1. Fork 本仓库
2. 创建新的分支 (`git checkout -b feature/your-feature`)
3. 提交你的修改 (`git commit -am 'Add some feature'`)
4. 推送到分支 (`git push origin feature/your-feature`)
5. 创建一个 Pull Request

### 贡献者风采

感谢所有为这个项目做出贡献的人们！

## 致谢

- 感谢 [universal-hit-thesis](https://github.com/hitszosa/universal-hit-thesis) 为本模板的框架设计和开发思路提供启发
- 感谢 [JLUThesis](https://github.com/jlshen025/JLUThesis) 提供的吉大毕设 LaTeX 实现参考以及LOGO
- 感谢吉林大学提供的官方论文格式规范文档。`docs` 目录包含以下资料：
  - 参考文献使用说明
  - 吉林大学本科生毕业论文（设计）撰写要求与书写格式（多个版本）
  - 官方论文格式规范文档，来源于：
    - [关于开展计算机科学与技术学院2025届本科生毕业论文（设计）评阅抽检工作的通知](https://ccst.jlu.edu.cn/info/1056/20364.htm)
    - [吉林大学本科生毕业论文（设计）撰写要求与书写格式](https://spxy.jlu.edu.cn/__local/0/48/5A/C4E0B85074DF0AC8F53EF5DC713_8439E436_A400.doc?e=.doc)
    - [通信工程学院2021届本科毕业论文（设计）工作安排](https://dce.jlu.edu.cn/info/1026/7840.htm)
  - 完整的本科毕设必填和选填表格模板（包含任务书、开题报告、中期检查、答辩资格审查、承诺书、答辩记录、评审表等）
  - 毕业论文资料袋填写模板
- 感谢所有为项目做出贡献的开发者和用户

## 相关链接

- 📖 [Typst 官方文档](https://typst.app/docs)
- 📚 [Typst Universe 包列表](https://typst.app/universe)
- 🏫 [吉林大学官方网站](https://www.jlu.edu.cn)
- � [论文格式要求参考](./docs/)
- 💬 [GitHub 讨论区](https://github.com/Islatri/universal-jlu-thesis/discussions)

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](./LICENSE) 文件。

这意味着：

- ✅ 你可以自由使用、修改和分发此模板
- ✅ 用于商业和私人项目
- ✅ 必须包含许可证声明

---

**如果这个项目对你有帮助，请考虑给个 Star ⭐️ 来支持我们！**

## 第三方资源 / Third-party assets

资源：template/assets/images/logo.png
来源：jlshen025 / JLUThesis（GitHub）
许可证：MIT License
署名："logo.png © jlshen025 (JLUThesis), 许可证: MIT License，来源: <https://github.com/jlshen025/JLUThesis/blob/master/figures/logo.png>"
说明：MIT 许可证允许再分发和衍生作品，但请保留原始版权声明与许可证文本。如果你将本仓库用于发布/分发（例如上传到 Typst Universe），本图像已标注为 MIT，可随仓库一并分发。

Asset: template/assets/images/logo.png
Source: jlshen025 / JLUThesis (GitHub)
License: MIT License
Attribution: "logo.png © jlshen025 (JLUThesis), License: MIT License, Source: <https://github.com/jlshen025/JLUThesis/blob/master/figures/logo.png>"
Note: The MIT license permits redistribution and derivative works provided that the copyright and license text are included. If you publish/distribute this project (for example on Typst Universe), this image is licensed MIT and may be distributed with the repository;
