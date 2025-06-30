# 华东师范大学学位论文 Typst 模板 modern-encu-thesis

这里是华东师范大学研究生 / 本科学位论文的 Typst 模板。

本项目 fork 自 [OrangeX4](https://github.com/Orangex4) 开发的 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis)。本项目除适配了华东师范大学本科及硕士学位论文的格式要求之外，还做了以下优化：

- 优化图片与表格的排版
- 优化页眉排版和页码显示，支持奇偶页
- 优化目录的缩进与对齐
- 优化引用格式
- 优化段落缩进
- 优化对多行标题 / 院系的处理逻辑
- 优化开启 `twoside` 参数后的页码逻辑
- 修复中文文字断行的问题
- 增加字数统计功能

对于研究生，我们参考华东师范大研究生院于 2023 年发布的[华东师范大学博士、硕士学位论文基本格式要求](https://yjsy.ecnu.edu.cn/8e/62/c42090a429666/page.htm)；对于本科生，我们参考华东师范大学教务处于 2021 年更新的[华东师范大学本科生毕业论文（设计）格式要求](http://www.jwc.ecnu.edu.cn/d4/be/c40573a513214/page.htm)。格式适配于 2025 年初，后续使用的同学请留意参考校方的最新通知。

![1736643710702](https://jtchen.s3.ap-northeast-1.amazonaws.com/v1/img/2025/01/11/1736643710702.png)

示例文档：

- 本科学位论文 [modern-ecnu-thesis-bachelor.pdf](https://github.com/jtchen2k/modern-ecnu-thesis/releases/latest/download/modern-ecnu-thesis-bachelor.pdf)
- 硕士学位论文，学术学位 [modern-ecnu-thesis-master-academic.pdf](https://github.com/jtchen2k/modern-ecnu-thesis/releases/latest/download/modern-ecnu-thesis-master-academic.pdf)
- 硕士学位论文，专业学位 [modern-ecnu-thesis-master-professional.pdf](https://github.com/jtchen2k/modern-ecnu-thesis/releases/latest/download/modern-ecnu-thesis-master-professional.pdf)
- 博士学位论文，学术学位 [modern-ecnu-thesis-doctor-academic.pdf](https://github.com/jtchen2k/modern-ecnu-thesis/releases/latest/download/modern-ecnu-thesis-doctor-academic.pdf)
- 博士学位论文，专业学位 [modern-ecnu-thesis-doctor-professional.pdf](https://github.com/jtchen2k/modern-ecnu-thesis/releases/latest/download/modern-ecnu-thesis-doctor-professional.pdf)

## Why Typst

> 天下苦 LaTeX 久矣。

Typst 是一个基于 Rust 的现代化的排版引擎。它具备类似 Markdown 的简洁语法、清晰的错误提示、实时预览级的编译性能，又同时具备和 LaTeX 一样精准的排版控制和图灵完备的脚本能力。自 2023 年 4 月开源发布以来，已获得 ![](https://img.shields.io/github/stars/typst/typst?style=flat)。现代化的 Typst 可以让你更加专注于论文内容本身，而不被 LaTeX 漫长的编译时间与难以阅读的输出日志困扰。当然，Typst 作为一个年轻的工具还在快速发展，生态远没有 LaTeX 丰富，也有大量的 issue 正在解决的路上。欢迎加入这个社区来共建现代排版生态。

## Usage

### 在 VSCode 中本地编辑（推荐）

请确保本地已安装 Typst，推荐使用最新版本。这里是 Typst 与模板版本的对应关系：

| typst 版本 | 模板版本 |
| ---------- | -------- |
| <0.12.0    | 不支持   |
| 0.12.0     | 0.1.0    |
| 0.13.0     | 0.2.0    |

#### 从 Typst Universe 获取模板

1. 在 VSCode 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件。
2. 按下 `Cmd / Ctrl + Shift + P` 打开命令界面，输入 `Typst: Show available Typst templates (gallery) for picking up a template` 打开 Tinymist 提供的 Template Gallery。在列表中搜索 `modern-ecnu-thesis`，点击 `❤` 按钮收藏，点击 `+` 来创建论文模板。

   ![1736800054020](https://jtchen.s3.ap-northeast-1.amazonaws.com/v1/img/2025/01/13/1736800054020.png)
3. 用 VS Code 打开生成的目录，打开 `thesis.typ` 文件，按下 `Ctrl / Cmd + K V` 或者是点击文档顶部的 Preview 来实时预览。

#### 从 git 获取模板

由于 Typst Universe 上的文件更新可能有延迟，你可以 clone 本仓库来保证使用最新的模板文件。入口文件为 `template/thesis.typ`。为了使用本地的模板，你可以将 `thesis.typ` 首行的：

```typst
#import "@preview/modern-ecnu-thesis:0.x.x"
```

改为：

```typst
#import "../lib.typ"
```

随后，在 template 目录下使用 `make` 命令编译或 `make watch` 持续监听文件更新。由于需获取上一级目录的文件，请留意在 typst compile 命令中加入 `--root ..` 参数。

或者，你也可以参考[该文档](https://github.com/typst/packages?tab=readme-ov-file#local-packages)，将本地仓库 `ln` 到 typst local package 的目录。例如：

```bash
# macOS
export DATA_DIR="~/Library/Application Support"
# Linux
export DATA_DIR="~/.local/share"
ln -s </path/to/modern-ecnu-thesis> $DATA_DIR/typst/packages/preview/modern-ecnu-thesis/0.x.x
```

这种方式不需要修改 `thesis.typ` 文件，直接使用 `#import "@preview/modern-ecnu-thesis:0.x.x"` 即可。Typst 会优先使用本地文件。

### 在线编辑

在 [Typst Web App](https://typst.app/app/) 中选择 `Start from template`，随后搜索 `modern-ecnu-thesis` 即可开始使用。

![1736800622590](https://jtchen.s3.ap-northeast-1.amazonaws.com/v1/img/2025/01/13/1736800622590.png)

> [!IMPORTANT]
> 为了在 Web 编辑器中正确显示字体（宋体、黑体、楷体、仿宋、Times、Arial 等），你需要将[该文件夹](https://github.com/jtchen2k/modern-ecnu-thesis/tree/main/fonts)内的字体文件**全部**上传到 Typst Web App。将整个 fonts 文件夹上传到工程任意位置即可。

## Tips

默认模板有一些示例代码，清空前请留意。

### 字数统计

模板内置了字数统计功能。统计时会除去标题与标点符号，默认包括了正文与附录的所有内容。一个英语单词或一个 CJK 汉字将会被统计为一个 word，一个任意字符会被统计为一个 char。默认的统计范围为正文 + 附录，这取决于文中 `#show: word-count-cjk` 的位置。如果希望包括摘要、目录等能容，将这一行移动到 `#show: preface` 的下一行即可。

如需统计字数，可以使用 `make count` 命令，你会得到类似如下的输出：

```
#word: 100
#char: 200
```

具体而言，该命令使用 `typst query` 命令来查询嵌入在 `mainmatter.typ` 里的包含字数信息的 `metadata`。你也可以在正文中使用 `total-words-cjk`、`total-characters` 或使用以下代码来显示总字数 / 字符数：

```typst
context state("total-words-cjk").final()
context state("total-characters").final()
```

### 从 LaTeX 到 Typst

- Typst 支持的图片格式包括 png, jpeg, gif 与 svg，不支持 pdf 与 eps。你可以使用 InkSpace 或 [pdf2svg](https://github.com/dawbarton/pdf2svg) 等工具将 pdf 转换为 svg 格式：

  ```bash
  pdf2svg input.pdf output.svg
  ```
- Typst 现在已经支持图片的浮动排版了。你可以使用 `figure` 的 `placement` 属性来控制图片位置，可以实现类似 LaTeX 的 `[htbp]` 功能：

  ```typst
  figure {
      placement: "top";
      caption: "image caption";
      ...
  }[#image("...)] <label>
  ```
- Typst 有一套自己的公式语法，与 LaTeX 大同小异且更加简洁。如果你已经十分熟悉 LaTeX 的语法并希望继续使用，可以引入 [MiTeX](https://github.com/mitex-rs/mitex)，它将允许你在 Typst 中使用 LaTeX 数学语法。
- Typst 原生兼容了 biblatex 引用格式，直接修改 ref.bib 即可。

更多 Typst 的介绍、学习资料与项目背景可参考[上游项目](https://github.com/nju-lug/modern-nju-thesis)的 README。

## Contribution

与华东师范大学学位论文相关的请求欢迎在这里发起 issue 或 PR。高校无关的优化与建议请前往[上游项目](https://github.com/nju-lug/modern-nju-thesis)参与讨论，这样可以帮助到更多该项目的未来用户。

因个人精力有限，以下功能暂未完成，欢迎有兴趣的同学贡献代码：）

- **本科**
  - [x] 中英双语图片标题（[@ruoyiqiao](https://github.com/ruoyiqiao)）
  - [ ] 中英双语图标自动编号
  - [ ] 本科学位论文的诚信承诺页
- **研究生**
  - 暂无

## 特性说明

### 双语图片标题

本模板支持两种图片标题格式：普通图片标题和双语图片标题。

#### 1. 普通图片标题

使用 Typst 原生的 `figure` 语法:

```typst
#figure(
  placement: top,  // 控制图片位置
  caption: [图片标题],
)[
  #image("path/to/image.png", width: 80%)
] <fig:label>
```

#### 2. 双语图片标题

使用模板提供的 `bilingual-figure` 函数:

```typst
#bilingual-figure(
  image("path/to/image.png", width: 80%),
  caption: "中文标题",
  caption-en: "English Caption",
  kind: "figure",  // 可选："figure"或"table"
  caption-position: bottom,  // 可选：top或bottom
  manual-number: "1.1"  // 需要手动指定编号
)
```

#### 3. 切换图表标题格式

要在普通图表标题和双语图表标题之间切换，需修改 `mainmatter` 参数:

```typst
// 使用普通图表标题
#show: mainmatter.with(caption-mode: "standard")

// 使用双语图表标题
#show: mainmatter.with(caption-mode: "bilingual")
```

**注意事项：**

- **两种格式不能混用，否则会导致图片编号出现问题**
- 使用双语图片标题时，需要手动维护 `manual-number` 参数以确保编号的正确性
- 目前双语图片标题不支持引用功能

## Changelog

### 0.3.0 (2025.6.30)

- feat: 支持中英双语图片标题（[@ruoyiqiao](https://github.com/ruoyiqiao)）
- fix: 修复摘要页面的页码错误
- fix: 修复摘要首行缩进的问题
- fix: 修复页脚编号错误的问题
- fix: 调整表格字体大小使其略小于正文

### 0.2.0 (2025.2.19)

- feat: 适配 Typst 0.13.0，重新处理首行缩进的逻辑
- fix: 修复等宽字体的大小问题
- fix: 修复连续标题的重复间距问题
- fix: 去除对 `anti-matter` 和 `outrageous` 的依赖
- fix: 更稳定的中文断行处理
- fix: 调整多处细节和间距

### 0.1.0 (2025.1.13)

- 初始版本

## References

- [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) by [OrangeX4](https://github.com/Orangex4)
- [ECNU-Undergraduate-LaTeX](https://github.com/YijunYuan/ECNU-Undergraduate-LaTeX) by [YijunYuan](https://github.com/YijunYuan)
- [华东师范大学硕士论文模板-2023](https://www.overleaf.com/latex/templates/hua-dong-shi-fan-da-xue-shuo-shi-lun-wen-mo-ban-2023/ctvnwyqtsbbz) by ivyee17
- [ECNU_graduation_thesis_template](https://github.com/ECNU-ICA/ECNU_graduation_thesis_template) by [ECNU-ICA](https://github.com/ECNU-ICA)
- [ECNU-Dissertations-Latex-Template](https://github.com/DeepTrial/ECNU-Dissertations-Latex-Template) by [Karl Xing](https://github.com/DeepTrial)
- [关于2023-2024学年第二学期学术型学位硕士研究生论文答辩及学位申请工作的通知](https://yjsy.ecnu.edu.cn/c1/7a/c42079a573818/page.htm) by 华东师范大学研究生院
- [毕业论文常用下载材料](http://www.jwc.ecnu.edu.cn/d4/be/c40573a513214/page.htm) by 华东师范大学教务处
- [学校标识](https://www.ecnu.edu.cn/wzcd/xxgk/xxbs.htm) by 华东师范大学

## License

This project is licensed under the MIT License.
