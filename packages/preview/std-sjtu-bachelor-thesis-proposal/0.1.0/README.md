<div align="center">

# 上海交通大学本科生毕业设计（论文）开题报告

# SJTU Bachelor Thesis Proposal

**Typst Template**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Typst Package](https://img.shields.io/badge/Typst-Package-239DAD)](https://typst.app/universe/package/std-sjtu-bachelor-thesis-proposal)

本模板严格依据上海交通大学教务处官方 [Word 模板](https://jwc.sjtu.edu.cn/info/1222/123971.htm) 制作  
相比传统 LaTeX，Typst 提供 **毫秒级编译速度** 与 **零配置环境**

📖 [查看完整文档](#-使用指南) | 🎯 [快速开始](#-快速开始) | 💬 [问题反馈](https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template/issues)

---

### ✨ 如果这个模板对你有帮助，请[点个 Star ⭐](https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template) 支持一下！

---

</div>

## 📸 模板预览

<div align="center">

| [本科生开题报告](https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template) | [本科生中期检查](https://github.com/zh1-z/SJTU-Bachelor-Thesis-Midterm-Typst-Template)  |
| :---: | :---: |
| <img src="https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template/blob/main/0.1.0/thumbnail.png?raw=true" width="100%" /> | <img src="https://github.com/zh1-z/SJTU-Bachelor-Thesis-Midterm-Typst-Template/blob/main/0.1.0/thumbnail.png?raw=true" width="100%" /> |

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
3. 搜索框输入 `std-sjtu-bachelor-thesis-proposal`
4. 选择模板并点击 **"Create"** 即可开始编辑

> ⚠️ **字体配置重要提示**：Web App 未预装本地中文字体，需要手动上传字体文件
>
> **具体操作步骤：**
> 1. 在项目根目录创建 `fonts` 文件夹
> 2. 从 Windows 系统的 `C:\Windows\Fonts\` 或 macOS 的 `/System/Library/Fonts/` 目录中，找到并上传以下字体文件：
>
> **中文字体（必需）：**
> - `SimSun.ttc` 或 `simsun.ttf` - 宋体
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
3. 在模板库中搜索 `std-sjtu-bachelor-thesis-proposal`
4. 选择模板并指定项目路径，自动创建项目

**选项 B：克隆仓库（灵活）**

```bash
git clone https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template.git
cd SJTU-Bachelor-Thesis-Proposal-Typst-Template/0.1.0
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
  cover-title:    "你的论文题目",
  name:           "你的名字",
  student-id:     "512345678901",        // 12位学号
  major:          "你的专业",
  supervisor:     "你的导师",
  school:         "你的学院",

  body
)
```

### 编写正文

在 `template/main.typ` 的正文部分直接编写内容，支持：

- **章节标题**：使用 `=` 标记层级
- **数学公式**：行内 `$a^2 + b^2 = c^2$`，行间 `$ ... $`
- **图片插入**：`#figure(image("path"), caption: [...])`
- **表格制作**：使用 `table()` 函数
- **参考文献**：使用 `@citation_key` 引用

详细语法请参考文件中的示例代码。

### 填写意见汇总页

在文件的末尾，你可以通过 `opinion-page` 函数来生成或填充“指导教师”与“学院”的意见页。

#### 情况 A：生成空白页面（用于手动签字）

如果你需要打印出来后再由老师手写评价，请直接调用空函数：

```typst
#opinion-page()
```

#### 情况 B：直接生成电子版意见

如果你希望在文档中直接填入内容并自动勾选审查结果，可以配置以下参数：

```typst
#opinion-page(
  // [指导教师意见]：支持多行文本或 Typst 格式
  supervisor-comment: [
    该课题选题意义重大，研究方案可行，进度安排合理。
    
    同意该生开题。
  ],
  
  // [学院（系）意见]：支持多行文本或 Typst 格式
  school-comment: [
    经审核，该课题符合本科生毕业设计（论文）开题要求。
  ],
  
  // [审查结果]：可选值为 "agree"（同意）、"disagree"（不同意）或 none（不勾选）
  result: "agree"
)
```
---

## 🔧 字体配置

### 必需字体

为确保最佳排版效果，请确保系统已安装以下字体：

| 字体类型 | 字体名称 | 常见文件名 |
|---------|---------|-----------|
| 中文 | 宋体 (SimSun) | `SimSun.ttc` / `simsun.ttf` |
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
   fc-list :lang=zh | grep -E "SimSun|KaiTi|SimHei"

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

<table>
  <thead>
    <tr>
      <th align="center">适用对象</th>
      <th align="center">阶段</th>
      <th align="center">模板名称<br/>(Official Standard)</th>
      <th align="center">版本</th>
      <th align="center">资源链接</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2" align="center">
        <b>本科生</b><br/>
        (Bachelor)
      </td>
      <td align="center">
        🎓<br/>
        开题
      </td>
      <td align="center">
        上海交通大学本科生<br/>
        毕业设计（论文）开题报告
      </td>
      <td align="center"><code>0.1.0</code></td>
      <td align="center">
        <a href="https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template"><img src="https://img.shields.io/badge/GitHub-Repo-181717?logo=github" alt="GitHub"></a><br/>
        <a href="https://typst.app/universe/package/std-sjtu-bachelor-thesis-proposal"><img src="https://img.shields.io/badge/Typst-Universe-239DAD?logo=typst&logoColor=white" alt="Typst"></a>
      </td>
    </tr>
    <tr>
      <td align="center">
        📋<br/>
        中期
      </td>
      <td align="center">
        上海交通大学本科生<br/>
        毕业设计（论文）中期检查报告
      </td>
      <td align="center"><code>0.1.0</code></td>
      <td align="center">
        <a href="https://github.com/zh1-z/SJTU-Bachelor-Thesis-Midterm-Typst-Template"><img src="https://img.shields.io/badge/GitHub-Repo-181717?logo=github" alt="GitHub"></a><br/>
        <a href="https://typst.app/universe/package/std-sjtu-bachelor-thesis-midterm"><img src="https://img.shields.io/badge/Typst-Universe-239DAD?logo=typst&logoColor=white" alt="Typst"></a>
      </td>
    </tr>
    <tr>
      <td rowspan="3" align="center">
        <b>研究生</b><br/>
        (Graduate)<br/>
        <hr style="margin: 8px 0; border: none; border-top: 1px solid #dfe2e5;"/>
        硕士<br/>(Master)<br/>
        博士<br/>(Doctoral)
      </td>
      <td align="center">
        🎓<br/>
        开题
      </td>
      <td align="center">
        上海交通大学研究生<br/>
        学位论文开题报告
      </td>
      <td align="center"><code>0.1.0</code></td>
      <td align="center">
        <a href="https://github.com/zh1-z/SJTU-Graduate-Thesis-Proposal-Typst-Template"><img src="https://img.shields.io/badge/GitHub-Repo-181717?logo=github" alt="GitHub"></a><br/>
        <a href="https://typst.app/universe/package/std-sjtu-graduate-thesis-proposal"><img src="https://img.shields.io/badge/Typst-Universe-239DAD?logo=typst&logoColor=white" alt="Typst"></a>
      </td>
    </tr>
    <tr>
      <td align="center">
        📋<br/>
        中期
      </td>
      <td align="center">
        上海交通大学硕士研究生<br/>
        学位论文中期检查报告
      </td>
      <td align="center"><code>0.1.0</code></td>
      <td align="center">
        <a href="https://github.com/zh1-z/SJTU-Master-Midterm-Typst-Template"><img src="https://img.shields.io/badge/GitHub-Repo-181717?logo=github" alt="GitHub"></a><br/>
        <a href="https://typst.app/universe/package/std-sjtu-master-midterm-report"><img src="https://img.shields.io/badge/Typst-Universe-239DAD?logo=typst&logoColor=white" alt="Typst"></a>
      </td>
    </tr>
    <tr>
      <td align="center">
        📊<br/>
        年度
      </td>
      <td align="center">
        上海交通大学博士研究生<br/>
        学位论文年度进展报告
      </td>
      <td align="center"><code>0.1.0</code></td>
      <td align="center">
        <a href="https://github.com/zh1-z/SJTU-Doctoral-Annual-Progress-Typst-Template"><img src="https://img.shields.io/badge/GitHub-Repo-181717?logo=github" alt="GitHub"></a><br/>
        <a href="https://typst.app/universe/package/std-sjtu-doctoral-annual-progress"><img src="https://img.shields.io/badge/Typst-Universe-239DAD?logo=typst&logoColor=white" alt="Typst"></a>
      </td>
    </tr>
  </tbody>
</table>

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
3. 建议上传完整的 Times New Roman 字体族（4个文件）和全部中文字体（3个文件）
4. 上传后刷新页面即可生效
</details>

<details>
<summary><b>Q: 模板与官方 Word 版本有差异怎么办？</b></summary>

A: 本模板严格按照官方最新版制作，但如发现格式问题，欢迎提交 [Issue](https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template/issues) 反馈。
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

- 感谢 [Typst](https://typst.app/) 项目为学术写作带来的革新
- 感谢所有提出建议和反馈的用户

---

## 💖 支持项目

如果这个模板对你有帮助，请：

- ⭐ 给项目[点个 Star](https://github.com/zh1-z/SJTU-Bachelor-Thesis-Proposal-Typst-Template)
- 🐛 提交 Bug 报告和功能建议
- 🔀 Fork 并改进模板
- 📢 分享给更多需要的同学

<div align="center">

**让我们一起让学术写作更加高效！**

</div>
