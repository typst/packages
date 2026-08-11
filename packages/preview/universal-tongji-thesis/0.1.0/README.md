# 同济大学研究生学位论文模板

适用于同济大学学位论文的Typst模板

> [!WARNING]
> 本模板正处于积极开发阶段，存在一些格式问题，适合尝鲜Typst特性
>
> 本模板是民间模板，**可能不被学校认可**，正式使用过程中请做好随时将内容迁移至Word或LaTeX的准备

## 关于本项目

[Typst](https://typst.app/) 是使用Rust语言开发的全新文档排版系统，您可以通过编写遵循Typst语法规则的文本文档、执行编译命令，来可生成目标格式的PDF文档。Typst有望以 Markdown 级别的简洁语法和编译速度实现 LaTeX 级别的排版能力。

本模板是一套套简单易用的同济大学学位论文Typst模板，计划囊括本科、硕士、博士的学位论文格式。

## 使用

### 本地编辑（推荐）

这种方式适合大多数用户。

- 安装Typst

如果您使用 Scoop 包管理器，直接使用如下命令安装：

```sh
scoop install typst
```

安装好Typst后执行如下命令：

```sh
typst init @preview/universal-tongji-thesis:0.1.0
```

Typst 将会创建一个名为 `universal-tongji-thesis` 的文件夹，进入该目录后，您可以直接修改目录下的 `thesis.typ` ，然后执行以下命令进行编译生成 `.pdf` 文档：

```sh
typst compile thesis.typ
```

> [!TIP]
> 本模板正处于积极开发阶段，更新较为频繁，虽然已经上传至 Typst Universe，但是您依然可以借助 Typst local packages 来实现待 Typst Universe 同步本模板的最新版本前，在本地体验本模板的最新版本，具体可按如下步骤操作：
>
> - 确保配置了 Cargo 环境
> - 使用 `cargo install typship` 安装 typship
> - 项目根目录执行 `typship install local` 将项目部署至本地 `@local` 名称空间下
> - 在模板开头使用 `#import "@local/universal-tongji-thesis:0.1.0"` 进行导入
>   更多内容可参考 [Typship](https://github.com/sjfhsjfh/typship) 的文档.

### 在线编辑

本模板已上传 Typst Universe，您可以使用 Typst 的官方 Web App 进行编辑。

具体来说，在 Typst Web App 登录后，点击 `Start from template`，在弹出的窗口中选择 `universal-tongji-thesis`，即可从模板创建项目。

> [!NOTE]
>
> Typst Web App 的排版渲染在浏览器本地执行，所以实时预览体验几乎与在本地编辑无异。
>
> 默认情况下，Web App 中的模板字体显示与预期可能存在差异，这是因为 Web App 默认不提供 `SimSun`, `Times New Roman` 等中文排版常用字体。为了解决这个问题，您可以在搜索引擎搜索以下字体文件：
>
> - `TimesNewRoman.ttf` （包括 `Bold`, `Italic` `Bold-Italic` 等版本）
> - `SimSun.ttf`
> - `SimHei.ttf`
> - `FangSong.ttf`
> - `Kaiti.ttf`
>
> 并将这些文件手动上传至 Web App 项目根目录中，或为了目录整洁，可以创建一个 `fonts` 文件夹并将字体置于其中，Typst Web App 将自动加载这些字体，并正确渲染到预览窗口中.
>
> 由于每次在 Typst Web App 中打开项目时都需要重新下载字体，而中文字体体积普遍较大，加载时间较长，因此我们更推荐**本地编辑**。

## 特性 / 路线图

- 模板
  - [x] 硕士毕业论文
  - [x] 博士毕业论文
  - [ ] 本科毕业设计

## 已知问题

### 排版

尽管本 Typst 模板各部分字体、字号等设置均与原 Word 模板一致，但段落排版视觉上仍与 Word 模板有一些差别，这与字符间距、行距、段落间距有一定肉眼排版成分有关。

### 参考文献

- 学校对参考文献格式的要求与标准的 `GB/T 7714-2015 numeric` 格式存在差异。

## 致谢

- 感谢 [modern-ecnu-thesis](https://github.com/jtchen2k/modern-ecnu-thesis) 为本模板的一些特性提供实现思路。
