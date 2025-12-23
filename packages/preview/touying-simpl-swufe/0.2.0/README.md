[![Typst Package](https://img.shields.io/badge/Typst-Package-239dad?logo=typst)](https://typst.app/universe/package/touying-simpl-swufe)
[![License](https://img.shields.io/github/license/leichaoL/touying-simpl-swufe)](https://github.com/leichaoL/touying-simpl-swufe/blob/main/LICENSE)

# [English](README.en.md) | [中文说明](README.md)
# 西南财经大学Typst Touying 模板

Typst 版的 [SWUFE Beamer 模板](https://www.overleaf.com/latex/templates/swufe-beamer-theme/hysqbvdbpnsm)。

参考 [Touying Slide Theme for Beihang University](https://github.com/Coekjan/touying-buaa)进行制作。

## 快速开始（官方包）

### 在线编辑

Typst 提供了官方的 Web App，支持像 Overleaf 一样在线编辑。这是本模板的[在线使用示例](https://typst.app/project/rge4aZ0GFg5Ms7vZo51RvI)。

在 [Typst Web App](https://typst.app) 中选择 `Start from template` 创建新项目，搜索 `touying-simpl-swufe` 即可使用。

![Web App 中选择模板](imgs/choose%20template.webp)
![在线编辑](imgs/webapp%20edit.webp)

Web App 并没有安装本地 Windows 或 MacOS 所拥有的字体，字体上可能存在差异，详情请见[字体说明](#字体说明)。

### 本地使用

#### VSCode 本地编辑（推荐）

1. 在 VSCode 中安装 [Tinymist Typst 插件](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)。
2. 按`Ctrl Shift P`或者`F1`打开命令面板，输入 `Typst: 显示可用的 Typst 模板（画廊），以选择一个模板进行初始化`（`Typst: Show available Typst templates (gallery) for picking up a template`），在弹出的窗口中搜索找到 `touying-simpl-swufe`，点击 ❤ 按钮进行收藏，点击 + 号使用模板。
3. VSCode 会自动创建并打开一个新项目，打开`main.typ`文件，按下`Ctrl + K V`进行实时编辑和预览。
4. （可选）安装并使用[Typst-figure-pasteTools](https://marketplace.visualstudio.com/items?itemName=yuzhong.typst-figure-pastetools) 插件和[Typst-table-paste](https://marketplace.visualstudio.com/items?itemName=leichaoL.typst-table-paste) 插件，可以像Word、PPT一样直接复制粘贴图片和表格，极大提升 Typst 的使用体验。

![Tinymist Typst 模板画廊](imgs/gallery.webp)

![VSCode 编辑](imgs/vscode%20edit.webp)



#### 终端

通过 Typst 官方包管理器安装并初始化项目：

```console
$ typst init @preview/touying-simpl-swufe
Successfully created new project from @preview/touying-simpl-swufe:<latest>
To start writing, run:
> cd touying-simpl-swufe
> typst watch main.typ
```

## 字体说明

为了实现与示例同样的显示效果，本模板推荐使用 **楷体（KaiTi）** 作为中文字体。

- **Windows 系统**：楷体为系统自带字体，可直接使用。
- **macOS 系统**：通常会直接使用系统自带的"楷体-简"（Kaiti SC）。
- **Linux 系统**：需要手动安装楷体字体。

**[Typst Web App](https://typst.app) 用户**：模板在Web App中默认使用 `Noto Serif CJK SC`（思源宋体）作为中文字体。为了保证显示效果，建议上传楷体字体文件，上传后模板会自动使用楷体。


## 快速开始（Github 源）

### 方法一：直接复制文件

将 [`lib.typ`](lib.typ) 复制到你的项目根目录，然后在 Typst 文件顶部导入：

```typst
#import "/lib.typ": *
```

### 方法二：本地包安装

从 GitHub 克隆并作为本地包安装，便于在多个项目中复用（可参考 [Typst 文档](https://github.com/typst/packages/blob/main/README.md)）：

```bash
git clone https://github.com/leichaol/touying-simpl-swufe.git {data-dir}/typst/packages/local/touying-simpl-swufe/0.2.0
```

其中 `{data-dir}` 为：

- Linux：`$XDG_DATA_HOME` 或 `~/.local/share`
- macOS：`~/Library/Application Support`
- Windows：`%APPDATA%`，即 `C:/Users/<username>/AppData/Roaming`

然后在文档中导入：

```typst
#import "@local/touying-simpl-swufe:0.2.0": *
```

## 示例

![模板截图](thumbnail.webp)

更多示例见 [`examples`](examples) 目录。

### 编译示例

在本地编译示例：

```console
$ typst compile ./examples/main.typ --root .
```

将生成 `./examples/main.pdf`。

## 模板Slide函数族和主要配置项

### 模板Slide函数族
模板提供了一系列用于生成投影幻灯片的函数，包括
- `title-slide` ：用于生成标题页面
- `outline-slide` ：用于加入目录页
- `focus-slide` ：用于纯色背景的聚焦页
- `ending-slide` ：用于生成不含标题的结束致谢页

### 其他函数

- `tblock` ：用于生成略微带阴影的定理框
- `shadow-figure` ：用于生成带阴影效果的图片

使用方法参考 examples 目录中的 [main.typ](examples/main.typ)。

### 主要配置项


```typst
#show: swufe-theme.with(
  // 生成的幻灯片比例，可设置为 "4-3" 或 "16-9"
  aspect-ratio: "16-9", 
  // 语言设置，"zh" 为中文，"en" 为英文，影响目录和自动编号等文本显示的语言
  lang: "zh", 
  // 字体设置，下面的例子中设置了 Libertinus Serif 作为英文字体，楷体作为中文字体，若不存在则依次使用后备字体
  font: ((name: "Libertinus Serif", covers: "latin-in-cjk"), "KaiTi", "Kaiti SC", "楷体", "Noto Serif CJK SC"), 

  // Basic information
  config-info(
    title: [Typst Slide Theme for Southwest University of Finance and Economics Based on Touying],
    subtitle: [基于Touying的西南财经大学Typst幻灯片模板],
    // 显示在页脚的标题
    short-title: [Typst Slide Theme for SWUFE Based on Touying],
    authors: [雷超#super("1"), Lei Chao#super("1,2")],
    // 显示在页脚的作者
    author: [Presenter: Lei Chao],
    date: datetime.today(),
    institution: ([#super("1")金融学院 西南财经大学], [#super("2")西南财经大学]),
    // 首页中显示的图片
    banner: image("../assets/swufebanner.svg"),
  ),

  // 模板主题色配置
  config-colors(
    primary: rgb(1, 83, 139),
    primary-dark: rgb(0, 42, 70),
    secondary: rgb(255, 255, 255),
    neutral-lightest: rgb(255, 255, 255),
    neutral-darkest: rgb(0, 0, 0),
  ),
)
```

## 版权声明

本主题的 Logo 来自 [swufe-logo](https://github.com/ChenZhongPu/swufe-logo)，作者为 [ChenZhongPu](https://github.com/ChenZhongPu)。感谢作者提供 Logo 资源。

这些 Logo 为西南财经大学所有，其在此处的使用仅用于学术排版，不代表学校的官方许可或背书。

模板作者不拥有这些 Logo 的版权，也不主张任何相关权利。

如需官方使用或再分发 Logo，请直接联系[西南财经大学](https://www.swufe.edu.cn/)。

## 许可证

采用 [MIT License](LICENSE) 授权。
