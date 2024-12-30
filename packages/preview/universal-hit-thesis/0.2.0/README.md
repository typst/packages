# HIT-Thesis-Typst

适用于哈尔滨工业大学学位论文的 Typst 模板

![hit-thesis-typst-cover](https://vonbrank-images.oss-cn-hangzhou.aliyuncs.com/20240426-HIT-Thesis-Typst/hit-thesis-typst-development-cover-01.jpg)

> [!WARNING]
> 本模板正处于积极开发阶段，存在一些格式问题，适合尝鲜 Typst 特性
> 
> 本模板是民间模板，**可能不被学校认可**，正式使用过程中请做好随时将内容迁移至 Word 或 LaTeX 的准备

## 关于本项目

[Typst](https://typst.app/) 是使用 Rust 语言开发的全新文档排版系统，有望以 Markdown 级别的简洁语法和编译速度实现 LaTeX 级别的排版能力，即通过编写遵循 Typst 语法规则的文本文档、执行编译命令，来可生成目标格式的 PDF 文档。

**HIT Thesis Typst** 是一套简单易用的哈尔滨工业大学学位论文 Typst 模板，受 [hithesis](https://github.com/hithesis/hithesis) 启发，计划囊括一校三区本科、硕士、博士的学位论文格式。

**预览效果**

- 本科通用：[universal-bachelor.pdf](https://github.com/chosertech/HIT-Thesis-Typst/blob/build/universal-bachelor.pdf)

## 使用

### 本地编辑 Ⅰ （推荐）

这种方式适合大多数用户。

首先安装 Typst，您可以在 Typst Github 仓库的 [Release 页面](https://github.com/typst/typst/releases/) 下载最新的安装包直接安装，并将 `typst` 可执行程序添加到 `PATH` 环境变量；如果您使用 Scoop 包管理器，则可以直接通过 `scoop install typst` 命令安装。

安装好 Typst 之后，您只需要选择一个您喜欢的目录，并在此目录下执行以下命令：

```sh
typst init @preview/universal-hit-thesis:0.2.0
```

Typst 将会创建一个名为 `universal-hit-thesis` 的文件夹，进入该目录后，您可以直接修改目录下的 `universal-bachelor.typ` ，然后执行以下命令进行编译生成 `.pdf` 文档：

```sh
typst compile universal-bachelor.typ
```

或者使用以下命令进行实时预览：

```sh
typst watch universal-bachelor.typ
```

当您要实时预览时，我们推荐使用 VS Code 进行编辑，配合 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=nvarner.typst-lsp), [vscode-pdf](https://marketplace.visualstudio.com/items?itemName=tomoki1207.pdf) 等插件可以大幅提升您的编辑体验。

### 本地编辑 Ⅱ

这种方法适合 Typst 开发者。

首先使用 `git clone` 命令 clone 本项目，或者直接在 Release 页面下载特定版本的源码。在 `templates/` 目录下选择您需要的模板，直接修改或复制一份，在根目录运行以下命令进行编译：

```sh
typst compile ./templates/<template-name>.typ --root ./
```

或者使用如下命令进行实时预览：

```sh
typst watch ./templates/<template-name>.typ --root ./
```

> [!TIP]
> 本模板正处于积极开发阶段，更新较为频繁，虽然已经上传至 Typst Universe，但是您依然可以借助 Typst local packages 来实现在 Typst Universe 同步本模板的最新版本前，在本地体验本模板的最新版本，具体做法为：
> - 在 Release 页面下载对应版本的源码压缩包，并将其解压到 `{data-dir}/typst/packages/local/universal-hit-thesis/{version}`，`{data-dir}` 在不同操作系统下的值为：
>   - `$XDG_DATA_HOME` or `~/.local/share` on Linux
>   - `~/Library/Application` Support on macOS
>   - `%LOCALAPPDATA%` on Windows
>   
>   `{version}` 的值为 `typst.toml` 中 `version` 项的值.
>   
>   解压完成后 `typst.toml` 文件应该出现在 `{data-dir}/typst/packages/local/universal-hit-thesis/{version}` 目录下.
>
> - 接着您需要在您的论文中将 `#import "@preview/universal-hit-thesis:0.2.0"` 修改为 `#import "@local/universal-hit-thesis:{version}"`，即可更新模板.

### 在线编辑

本模板已上传 Typst Universe，您可以使用 Typst 的官方 Web App 进行编辑。

---

> [!NOTE]
> 注意到，官方提供的本科毕业设计 Microsoft Word 论文模板 `本科毕业论文（设计）书写范例（理工类）.doc` 在一校三区是通用的，意味着本 Typst 模板的本科论文部分理论上也是在一校三区通用的，因此我们提供适用于各校区的本科毕业论文模板模块导出，即以下四种导入模块的方式效果相同：
> ```typ
> #import "@preview/universal-hit-thesis:0.2.0": harbin-bachelor
> #import harbin-bachelor: * // 哈尔滨校区本科
> ```
> ```typ
> #import "@preview/universal-hit-thesis:0.2.0": weihai-bachelor
> #import weihai-bachelor: * // 威海校区本科
> ```
> ```typ
> #import "@preview/universal-hit-thesis:0.2.0": shenzhen-bachelor
> #import shenzhen-bachelor: * // 深圳校区本科
> ```
> ```typ
> #import "@preview/universal-hit-thesis:0.2.0": universal-bachelor
> #import universal-bachelor: * // 一校三区本科通用
> ```

## 依赖

### 可选依赖

若要书写和引用伪代码，您可以使用 `algorithm-figure`，为此，您需要导入 `@algorithmic` 包。

```typ
#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm
```

使用方式详见[模板](https://github.com/chosertech/HIT-Thesis-Typst/blob/main/templates/universal-bachelor.typ)中的`算法`节
