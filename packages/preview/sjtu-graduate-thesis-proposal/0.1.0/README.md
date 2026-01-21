<div align="center">

# 上海交通大学研究生学位论文开题报告

# SJTU Graduate Thesis Proposal

**Typst Template**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Typst Package](https://img.shields.io/badge/Typst-Package-239DAD)](https://typst.app/universe/package/sjtu-graduate-thesis-proposal)

本模板严格依据上海交通大学研究生院官方 [Word 模板](https://www.gs.sjtu.edu.cn/xzzx/pygl) 制作  
相比传统 LaTeX，Typst 提供 **毫秒级编译速度** 与 **零配置环境**

📖 [查看完整文档](#-使用指南) | 🎯 [快速开始](#-快速开始) | 💬 [问题反馈](https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template/issues)

---

### ✨ 如果这个模板对你有帮助，请[点个 Star ⭐](https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template) 支持一下！

---

</div>

## 📸 模板预览

<div align="center">

| [研究生开题报告](https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template) | [硕士生中期检查](https://github.com/zh1-z/SJTU-Master-Midterm-Typst-Template) | [博士生年度进展](https://github.com/zh1-z/SJTU-Doctoral-Annual-Progress-Typst-Template) |
| :---: | :---: | :---: |
| <img src="https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template/blob/main/0.1.0/thumbnail.png?raw=true" width="100%" /> | <img src="https://github.com/zh1-z/SJTU-Master-Midterm-Typst-Template/blob/main/0.1.0/thumbnail.png?raw=true" width="100%" /> | <img src="https://github.com/zh1-z/SJTU-Doctoral-Annual-Progress-Typst-Template/blob/main/0.1.0/thumbnail.png?raw=true" width="100%" /> |

</div>

## ✨ 核心特性

- ⚡ **极速编译**：相比 LaTeX 数十秒编译，Typst 实现毫秒级响应
- 🎯 **零配置**：无需安装庞大的 TeX 发行版，开箱即用
- 📱 **实时预览**：所见即所得，修改即刻呈现
- 🎨 **格式完善**：严格遵循官方 Word 模板的所有格式要求
- 🛠️ **易于维护**：代码结构清晰，自定义修改简单直观
- 🌐 **多端支持**：支持 Web、VS Code、命令行等多种使用方式

## 📋 快速开始

### 方式一：Typst Web App（最简单）🌐

> 💡 **推荐新手使用**：无需安装任何软件，浏览器即可完成编辑

1. 访问 [Typst Web App](https://typst.app/) 并登录
2. 点击 **"Start from template"**
3. 搜索框输入 `sjtu-graduate-thesis-proposal`
4. 选择模板并点击 **"Create"** 即可开始编辑

> ⚠️ **字体配置重要提示**：Web App 未预装本地中文字体，需要手动上传字体文件
>
> **具体操作步骤：**
> 1. 在项目根目录创建 `fonts` 文件夹
> 2. 从 Windows 系统的 `C:\Windows\Fonts\` 或 macOS 的 `/System/Library/Fonts/` 目录中，找到并上传以下字体文件：
>
> **中文字体（必需）：**
> - `SimSun.ttc` 或 `simsun.ttf` - 宋体
> - `simfang.ttf` - 仿宋
> - `simkai.ttf` - 楷体
> - `simhei.ttf` - 黑体
>
> **英文字体（必需）：**
> - `times.ttf` - Times New Roman（常规）
> - `timesbd.ttf` - Times New Roman（粗体）
> - `timesi.ttf` - Times New Roman（斜体）
> - `timesbi.ttf` - Times New Roman（粗斜体）
>
> 3. 上传完成后刷新页面即可正常使用

---

### 方式二：VS Code 本地编辑（推荐）💻

> 💡 **最佳体验**：完整的本地字体支持 + 强大的编辑功能

#### 第一步：安装插件

在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件

- 提供语法高亮、智能补全、错误检查
- 支持实时 PDF 预览和导出

#### 第二步：获取模板

**选项 A：使用模板库（简单）**

1. 按 `Ctrl+Shift+P` (Windows/Linux) 或 `Cmd+Shift+P` (macOS)
2. 输入并选择：`Typst Init: Initialize a new Typst project`
3. 在模板库中搜索 `sjtu-graduate-thesis-proposal`
4. 选择模板并指定项目路径，自动创建项目

**选项 B：克隆仓库（灵活）**

```bash
git clone https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template.git
cd SJTU-Graduate-Thesis-Proposal-Typst-Template/0.1.0
```

> 💡 **提示**：克隆仓库版本可以及时获取最新更新，便于自定义修改

#### 第三步：开始编辑

1. 用 VS Code 打开模板目录
2. 打开 `template/main.typ` 文件
3. 按 `Ctrl+K V` (Windows/Linux) 或 `Cmd+K V` (macOS) 打开预览
4. 或点击右上角的预览按钮 📄 进行实时预览

---

### 方式三：命令行编译（适合进阶用户）⌨️

> 💡 **适合场景**：自动化构建、CI/CD 集成、脚本批量处理

#### 安装 Typst CLI

**Windows：**

**方法一：使用 Scoop（推荐）**
```powershell
# 如未安装 Scoop，先安装 Scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# 使用 Scoop 安装 Typst
scoop install typst
```

**方法二：使用 Chocolatey**
```powershell
# 如未安装 Chocolatey，以管理员身份运行 PowerShell 并执行：
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 使用 Chocolatey 安装 Typst
choco install typst
```

**方法三：手动下载**
1. 访问 [Typst Releases](https://github.com/typst/typst/releases/latest)
2. 下载 `typst-x86_64-pc-windows-msvc.zip`
3. 解压到任意目录（如 `C:\Program Files\Typst\`）
4. 将 `typst.exe` 所在目录添加到系统 PATH 环境变量
5. 在命令提示符或 PowerShell 中验证：`typst --version`

---

**Linux：**

```bash
# 方法一：使用包管理器（推荐）
# Arch Linux
sudo pacman -S typst

# Debian/Ubuntu（需要添加仓库）
# 暂不支持，请使用方法二或方法三

# Fedora
sudo dnf install typst

# 方法二：使用 Cargo（需要先安装 Rust）
cargo install --git https://github.com/typst/typst --locked typst-cli

# 方法三：下载预编译二进制
wget https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
tar -xf typst-x86_64-unknown-linux-musl.tar.xz
sudo mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/

# 验证安装
typst --version
```

---

**macOS：**

```bash
# 方法一：使用 Homebrew（推荐）
brew install typst

# 方法二：使用 Cargo（需要先安装 Rust）
cargo install --git https://github.com/typst/typst --locked typst-cli

# 验证安装
typst --version
```

#### 编译文档

**Windows（PowerShell/CMD）：**
```powershell
# 进入模板目录
cd template

# 单次编译
typst compile main.typ

# 监视模式（文件变化时自动重新编译）
typst watch main.typ

# 指定输出路径
typst compile main.typ output.pdf
```

**Linux/macOS：**
```bash
# 进入模板目录
cd template/

# 单次编译
typst compile main.typ

# 监视模式（文件变化时自动重新编译）
typst watch main.typ

# 指定输出路径
typst compile main.typ output.pdf
```

#### 常用命令

```bash
# 查看所有可用字体列表
typst fonts

# 指定字体目录编译（如使用自定义字体）
typst compile --font-path ../fonts main.typ

# 查看完整帮助文档
typst --help

# 查看版本信息
typst --version
```

> 💡 **Windows 用户提示**：
> - 推荐使用 PowerShell 而非 CMD，体验更好
> - 如果命令提示找不到 `typst`，请检查是否已将 Typst 添加到 PATH 环境变量
> - 字体路径使用反斜杠 `\` 或正斜杠 `/` 都可以，如：`--font-path ..\fonts` 或 `--font-path ../fonts`

---

## 📝 使用指南

### 填写个人信息

打开 `template/main.typ`，在文件开头找到参数配置区域：

```typst
#show: body => project(
  // --- 封面信息 ---
  student-id:     "123456789012",        // 12位学号
  name:           "你的名字",
  degree-program: "ad",                   // ad/pd/am/pm (见说明)
  study-mode:     "f",                    // f/p/e (见说明)
  supervisor:     "你的导师",
  school:         "你的学院",
  major:          "你的专业",
  date:           today-date,             // 或自定义 "2026-01-01"
  venue:          "会议室",

  // --- 课题信息 ---
  title:          "你的论文题目",
  proposed-title: "",                     // 可选，默认与 title 相同
  source-of-research-project: (1, 3),     // 研究课题来源（可多选）
  other-project-name: "",                 // 选择"其它"时填写

  // --- 签名信息 ---
  signature-image: "figures/signature.png", // 优先使用图片
  signature-text:  "你的名字",             // 或使用文字签名
  signature-date:  today-date,

  body
)
```

### 📌 参数说明

#### 学生类别 `degree-program`

| 代码 | 含义 |
|------|------|
| `ad` | 学术型博士生 Academic Doctoral Student |
| `pd` | 专业型博士生 Professional Doctoral Student |
| `am` | 学术型硕士生 Academic Master Student |
| `pm` | 专业型硕士生 Professional Master Student |

#### 学习形式 `study-mode`

| 代码 | 含义 |
|------|------|
| `f` | 全日制 Full-time |
| `p` | 非全日制 Part-time |
| `e` | 同等学力学生 |

#### 研究课题来源 `source-of-research-project`

```typst
// 单选示例
source-of-research-project: 1,

// 多选示例
source-of-research-project: (1, 3, 5),

// 选项说明：
// 1. 国家自然科学基金课题
// 2. 国家社会科学基金
// 3. 国家重大科研专项
// 4. 其它纵向科研课题
// 5. 企业横向课题
// 6. 自拟课题
// 7. 其它（需配合 other-project-name 参数）
```

### 编写正文

在 `template/main.typ` 的正文部分直接编写内容，支持：

- **章节标题**：使用 `=` 标记层级
- **数学公式**：行内 `$a^2 + b^2 = c^2$`，行间 `$ ... $`
- **图片插入**：`#figure(image("path"), caption: [...])`
- **表格制作**：使用 `table()` 函数
- **参考文献**：使用 `@citation_key` 引用

详细语法请参考文件中的示例代码。

---

## 🔧 字体配置

### 必需字体

为确保最佳排版效果，请确保系统已安装以下字体：

| 字体类型 | 字体名称 | 常见文件名 |
|---------|---------|-----------|
| 中文 | 宋体 (SimSun) | `SimSun.ttc` / `simsun.ttf` |
| 中文 | 仿宋 (FangSong) | `simfang.ttf` / `STFANGSO.TTF` |
| 中文 | 楷体 (KaiTi) | `simkai.ttf` / `STKAITI.TTF` |
| 中文 | 黑体 (SimHei) | `simhei.ttf` / `SIMHEI.TTF` |
| 英文 | Times New Roman | `times.ttf`, `timesbd.ttf`, `timesi.ttf`, `timesbi.ttf` |

> 💡 **提示**：Times New Roman 通常包含 4 个文件（常规、粗体、斜体、粗斜体），建议全部安装以获得完整支持

### Linux 系统字体安装

**方法一：使用包管理器**

```bash
# Debian/Ubuntu
sudo apt install fonts-wqy-microhei fonts-wqy-zenhei ttf-mscorefonts-installer

# Arch Linux
sudo pacman -S wqy-microhei wqy-zenhei ttf-ms-fonts

# Fedora
sudo dnf install wqy-microhei-fonts wqy-zenhei-fonts
```

**方法二：手动安装（推荐，字体效果最佳）**

1. **获取字体文件**：从 Windows 系统 `C:\Windows\Fonts\` 目录复制以下文件：
   ```
   中文字体：
   - SimSun.ttc 或 simsun.ttf (宋体)
   - simfang.ttf (仿宋)
   - simkai.ttf (楷体)
   - simhei.ttf (黑体)

   英文字体：
   - times.ttf (Times New Roman 常规)
   - timesbd.ttf (Times New Roman 粗体)
   - timesi.ttf (Times New Roman 斜体)
   - timesbi.ttf (Times New Roman 粗斜体)
   ```

2. **安装字体**：
   ```bash
   # 创建字体目录（如不存在）
   mkdir -p ~/.local/share/fonts/

   # 复制字体文件到字体目录
   cp *.ttf *.ttc ~/.local/share/fonts/

   # 或安装到系统全局目录（需要 sudo 权限）
   sudo cp *.ttf *.ttc /usr/share/fonts/
   ```

3. **刷新字体缓存**：
   ```bash
   fc-cache -fv
   ```

4. **验证安装**：
   ```bash
   # 检查中文字体
   fc-list :lang=zh | grep -E "SimSun|FangSong|KaiTi|SimHei"

   # 检查 Times New Roman
   fc-list | grep -i "times"
   ```

---

## 🎨 高级功能

### 自定义样式

模板的样式定义位于 `lib.typ`，你可以修改：

- 页边距、字号、行距
- 标题格式、编号样式
- 表格样式、图片布局

### 模块化写作

建议将不同章节分离为独立文件：

```typst
// main.typ
#include "chapters/chapter1.typ"
#include "chapters/chapter2.typ"
```

### 参考文献管理

在 `template/ref.bib` 中管理参考文献，使用标准 BibTeX 格式。

---

## 📚 相关项目

<div align="center">

| 项目 | 说明 | 链接 |
|------|------|------|
| 🎓 开题报告 | 研究生学位论文开题报告 | [GitHub](https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template) |
| 📋 中期检查 | 硕士研究生学位论文中期检查报告 | [GitHub](https://github.com/zh1-z/SJTU-Master-Midterm-Typst-Template) |
| 📊 年度进展 | 博士研究生学位论文年度进展报告 | [GitHub](https://github.com/zh1-z/SJTU-Doctoral-Annual-Progress-Typst-Template) |

</div>

---

## ❓ 常见问题

<details>
<summary><b>Q: 编译时提示找不到字体怎么办？</b></summary>

A: 请确保已安装所需字体。Linux 用户可参考 [字体配置](#-字体配置) 部分。使用 `typst fonts` 命令查看可用字体列表。
</details>

<details>
<summary><b>Q: 如何在 Web App 中使用本地字体？</b></summary>

A: Web App 需要手动上传字体文件：

1. 在项目根目录创建 `fonts` 文件夹
2. 上传所需的字体文件（参见上方"方式一：Typst Web App"中的字体列表）
3. 建议上传完整的 Times New Roman 字体族（4个文件）和全部中文字体（4个文件）
4. 上传后刷新页面即可生效

如果字体仍无法显示，可在代码开头添加：
```typst
#set text(font: ("./fonts/times.ttf", "./fonts/simsun.ttf"))
```
</details>

<details>
<summary><b>Q: 模板与官方 Word 版本有差异怎么办？</b></summary>

A: 本模板严格按照官方最新版制作，但如发现格式问题，欢迎提交 [Issue](https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template/issues) 反馈。
</details>

<details>
<summary><b>Q: 可以用于其他学校吗？</b></summary>

A: 本模板专为上海交通大学设计，其他学校格式要求可能不同，建议参考本模板自行修改。
</details>

---

## 📄 许可证

- **模板代码**：采用 [MIT License](LICENSE) 开源
- **校徽图片**：版权归上海交通大学所有，仅限在校师生学术用途使用

---

## 🙏 致谢

- 感谢 [@NemoYuan2008](https://github.com/NemoYuan2008) 的 LaTeX 模板提供的格式参考
- 感谢 [Typst](https://typst.app/) 项目为学术写作带来的革新
- 感谢所有提出建议和反馈的用户

---

## 💖 支持项目

如果这个模板对你有帮助，请：

- ⭐ 给项目[点个 Star](https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template)
- 🐛 提交 Bug 报告和功能建议
- 🔀 Fork 并改进模板
- 📢 分享给更多需要的同学

<div align="center">

**让我们一起让学术写作更加高效！**

</div>

