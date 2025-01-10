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

对于研究生，我们参考华东师范大研究生院于 2023 年发布的[华东师范大学博士、硕士学位论文基本格式要求](https://yjsy.ecnu.edu.cn/8e/62/c42090a429666/page.htm)；对于本科生，我们参考华东师范大学教务处于 2021 年更新的[华东师范大学本科生毕业论文（设计）格式要求](http://www.jwc.ecnu.edu.cn/d4/be/c40573a513214/page.htm)。格式适配于 2025 年初，后续使用的同学请留意参考校方的最新通知。

![1736471485839](https://jtchen.s3.ap-northeast-1.amazonaws.com/v1/img/2025/01/09/1736471485839.png)

在这里可以找到硕士学位论文的示例文档：[thesis.pdf](https://github.com/jtchen2k/modern-ecnu-thesis/releases/download/0.1.0/thesis.pdf)。

## Usage

### 在 VSCode 中本地编辑（推荐）

首先请确保安装的 typst 版本 >= 0.12.0，

#### 从 Typst Universe 获取模板

1. 在 VSCode 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件。
2. 按下 `Cmd / Ctrl + Shift + P` 打开命令界面，输入 `Typst: Show available Typst templates (gallery) for picking up a template` 打开 Tinymist 提供的 Template Gallery。在列表中搜索 `modern-ecnu-thesis`，点击 `❤` 按钮收藏，点击 `+` 来创建论文模板。
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

在 Typst Web App 中选择 `Start from template`，随后搜索 `modern-ecnu-thesis` 即可开始使用。

为了在 Web 编辑器中正确显示字体，你需要将[这里](https://github.com/jtchen2k/modern-ecnu-thesis/tree/main/fonts)的字体文件上传到 Typst Web App。

## Tips

- Typst 支持的图片格式包括 png, jpeg, gif 与 svg，不支持 pdf 与 eps。你可以使用 InkSpace 或 [pdf2svg](https://github.com/dawbarton/pdf2svg) 等工具将 pdf 转换为 svg 格式：

    ```bash
    pdf2svg input.pdf output.svg
    ```

- Typst 现在已经支持图片的浮动排版了。你可以使用 `figure` 的 `placement` 属性来控制图片位置。
- Typst 有一套自己的公式语法，与 LaTeX 大同小异且更加简洁。如果你已经十分熟悉 LaTeX 的语法并希望使用，可以使用 [MiTeX](https://github.com/mitex-rs/mitex)，它将允许你在 Typst 中使用 LaTeX 数学语法。
- Typst 原生兼容了 biblatex 引用格式，直接修改 ref.bib 即可。
- 默认模板有一些示例代码，清空前请留意。

更多 Typst 的介绍、学习资料与项目背景可参考[上游项目](https://github.com/nju-lug/modern-nju-thesis)的 README。

## Contribution

与华东师范大学学位论文相关的请求欢迎在这里发起 issue 或 PR。高校无关的优化与建议请前往[上游项目](https://github.com/nju-lug/modern-nju-thesis)参与讨论，这样可以帮助到更多该项目的未来用户。

因个人精力有限，以下功能暂未完成，欢迎有兴趣的同学贡献代码：）

- **本科**
  - [ ] 中英双语图片标题
- **研究生**
  - 暂无

## References

- [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) by [OrangeX4](https://github.com/Orangex4)
- [ECNU-Undergraduate-LaTeX](https://github.com/YijunYuan/ECNU-Undergraduate-LaTeX) by [YijunYuan](https://github.com/YijunYuan)
- [华东师范大学硕士论文模板-2023](https://www.overleaf.com/latex/templates/hua-dong-shi-fan-da-xue-shuo-shi-lun-wen-mo-ban-2023/ctvnwyqtsbbz) by ivyee17
- [关于2023-2024学年第二学期学术型学位硕士研究生论文答辩及学位申请工作的通知](https://yjsy.ecnu.edu.cn/c1/7a/c42079a573818/page.htm) by 华东师范大学研究生院
- [毕业论文常用下载材料](http://www.jwc.ecnu.edu.cn/d4/be/c40573a513214/page.htm) by 华东师范大学教务处
- [学校标识](https://www.ecnu.edu.cn/wzcd/xxgk/xxbs.htm) by 华东师范大学

## License

This project is licensed under the MIT License.