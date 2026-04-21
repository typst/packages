# 大学论文 Typst 模板

一个为本科生毕业论文设计的 Typst 排版模板。它基于中文学术规范，帮助使用者快速完成论文的封面、章节和参考文献排版，让使用者专注于写作本身。

## 特点

- 简洁写作：全程使用标记式语法，告别复杂的 LaTeX 命令。
- 符合学术规范：内置了中文论文标准格式（封面、各级标题、图表编号等）。
- 快速渲染：基于 Typst 引擎，实时编译，所见即所得。
- 完整的章节结构：预设了从“摘要”到“致谢”的完整文档框架。
- 参考文献支持：集成 GB/T 7714 中文国标引用样式。

## 使用方法

1. 环境准备

本项目需要安装 Typst。它提供本地编译与在线编辑两种使用方式：

- 本地安装：
  - Windows：从 GitHub Releases 下载 typst-x86_64-pc-windows-msvc.zip，解压后将路径添加到系统 PATH。
  - macOS/Linux：可以使用包管理器（如 Homebrew、APT、Pacman）进行安装，也可以使用 Rust 的 Cargo 工具通过 cargo install typst-cli 命令安装。
  - 安卓: 使用termux安装一个Linux环境再参照Linux教程使用
  - 验证安装：在终端中输入 typst -V，若显示版本号则说明安装成功。
  - VSCode 插件（推荐）：在 VSCode 扩展商店中搜索并安装 “Tinymit Typst”。它会在你保存代码时自动刷新 PDF 预览，带来类似 Typora 的写作体验。
- 网页使用：
  - 官方网站 https://typst.app/play/
  - 创建GitHub代码空间https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=strangelion/university-typst-template

2. 获取模板

你可以选择以下任一方式：

- 下载 ZIP：直接下载本项目代码并解压。
- 克隆仓库：
  ```bash
  git clone https://github.com/strangelion/university-typst-template.git
  ```

3. 编译论文

进入项目目录后，执行编译命令即可生成 PDF 文件：

```bash
cd university-typst-template
typst compile main.typ paper.pdf
```
如果出现字体问题手动安装字体或用这个：

```bash
cd university-typst-template
typst compile --font-path ./fonts main.typ paper.pdf
```

若你安装了 VSCode 插件，打开 main.typ 文件后，插件会自动启动预览服务。之后你可以在浏览器中实时查看论文排版效果。使用插件注意固定主文件以避免产生不需要的PDF文件（Ctrl + Shift + P打开命令面板）：
- Typst:将主文件固定到当前打开的文档 Typst: Pin the Main File to the Currently Open Document 
- Typst:取消固定主文件 Typst: Unpin the main file

## 项目结构

```
university-typst-template/
├── .devcontainer/            # Codespaces 配置目录
├── content/                  # 各章节内容文件
│   ├── abstract.typ
│   ├── acknowledgments.typ
│   ├── chapter1.typ
│   └── ...
├── modules/                  # 自定义模块与函数
│   └── utils.typ
├── fonts/                    # 自定义字体目录
├── main.typ                  # 论文入口文件
├── template.typ              # 核心样式模板
├── config.typ                # 集中管理元数据
├── references.bib            # 文献数据库
├── typst.toml                # 项目配置文件
├── resource/                 # 静态资源
│   └──  logo.png
└── README.md
```

## 配置说明

你可以在 config.typ 文件中修改论文的基本信息：

```typst
#let conf = (
  // 学校信息
  school: "XX大学",
  college: "社会科学与技术学院",
  major: "宇宙社会学",
  // 论文基本信息
  head: "主标题",
  title: "副标题",
  title-en: "English Title",
  // 作者信息
  author: "张三",
  student-id: "1145141314",
  // 指导教师
  supervisor: "罗教授",
  // 日期（自动生成当前年份）
  date: datetime.today().display("[year]年[month]月[day]日"),
  // 其他可选字段
  keywords: ("Typst", "论文模板", "排版"),
  keywords-en: ("Typst", "Thesis Template", "Typesetting"),
)
```

所有个人信息在这里只需修改一次，即可在封面和信息表格中全局生效。

## 参考文献

模板默认使用 GB/T 7714-2015 中文国标引用样式（numeric）。你只需要在references.bib(references.yml默认关闭) 文件中填入文献信息，并在正文中使用 #cite 引用即可。

## 贡献指南

欢迎提交 Pull Request 或 Issue 来完善这个模板！无论是修复 Bug、改进样式还是补充文档，都感激不尽。

## 特殊方式
- Github Action:
  - 可以clone该项目，修改好内容后手动触发action获得包含PDF的压缩包。（何意为？）
  - 不要pull本项目时使用action，会对本项目action产生影响。

## 许可证

该项目基于Apache-2.0 许可证开源。
