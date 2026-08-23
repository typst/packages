# 大学论文 Typst 模板

[![GitHub 仓库](https://img.shields.io/badge/GitHub-仓库-blue?logo=github)](https://github.com/strangelion/university-typst-template)
[English](README.md)

一款专为本科生毕业论文设计的专业 Typst 排版模板。遵循中文学术规范，自动处理封面、章节格式与参考文献管理，让您把精力集中在真正重要的事情上：您的研究本身。

## 主要特点

- **轻松写作：** 使用直观的标记语法，再也不用与复杂的 LaTeX 指令纠缠。
- **学术严谨：** 内建符合中文论文标准的封面、层级标题、图表编号等。
- **极速编译：** 基于 Typst 引擎，实时编译、即时预览 PDF。
- **即开即用：** 提供从摘要到致谢的完整文档框架。
- **引用无忧：** 原生集成 GB/T 7714（顺序编码制）国家标准参考文献格式。

## 快速开始

### 环境配置
您可以在本地或浏览器中使用 Typst：

**本地安装：**
- **Windows：** 从 GitHub Releases 下载 `typst-x86_64-pc-windows-msvc.zip`，并将可执行文件添加到系统 PATH。
- **macOS/Linux：** 通过包管理器（Homebrew、APT、Pacman）安装，或使用 Rust 的 Cargo：`cargo install typst-cli`。
- **Android：** 通过 Termux 安装 Linux 环境后，参照 Linux 说明操作。
- **验证：** 在终端中运行 `typst -V`，若显示版本信息则说明安装成功。

**VSCode（推荐）：** 安装 “Tinymit Typst” 扩展，可获得类似 Typora 的“所见即所得”实时写作体验。

**在线使用：**
- Typst 官方网页应用：[typst.app/play/](https://typst.app/play/)
- GitHub Codespaces：在此创建 Codespace

### 获取模板
选择您喜欢的方式：
- **下载 ZIP：** 下载并解压项目源代码。
- **克隆仓库：** `git clone https://github.com/strangelion/university-typst-template.git`

### 编译您的论文
进入项目目录后运行：

```cmd
typst compile main.typ paper.pdf
'''

如果遇到字体问题，请指定本地字体路径：

'''cmd
typst compile --font-path ./fonts main.typ paper.pdf
'''

VSCode 用户小贴士： 固定 main.typ 文件可避免生成无关的 PDF 片段（Ctrl + Shift + P → Typst: Pin the Main File to the Currently Open Document）。
配置

所有个人信息与论文元数据集中存放在 config.typ 中。只需一次修改（标题、姓名、学号等），封面及相关信息表便会自动同步更新。
参考文献

模板默认采用 GB/T 7714-2015（顺序编码制）样式。只需填写您的 references.bib（或 references.yml），并在正文中使用 #cite 命令即可。
GitHub Actions

您可以克隆本仓库并手动触发内置的 GitHub Action，生成包含已编译 PDF 的 ZIP 文件。

    注意： 请勿直接在上游仓库运行 Action，以免引发冲突。

许可证

本项目基于 Apache-2.0 许可证发行。