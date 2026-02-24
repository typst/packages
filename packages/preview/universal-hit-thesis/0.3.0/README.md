# 哈尔滨工业大学论文模板 · [![Build Templates](https://github.com/hitszosa/universal-hit-thesis/actions/workflows/build-templates.yml/badge.svg?branch=dev)](https://github.com/hitszosa/universal-hit-thesis/actions/workflows/build-templates.yml)

适用于哈尔滨工业大学学位论文的 Typst 模板

![hit-thesis-typst-cover](https://vonbrank-images.oss-cn-hangzhou.aliyuncs.com/20240426-HIT-Thesis-Typst/hit-thesis-typst-development-cover-01.jpg)

> [!WARNING]
> 本模板正处于积极开发阶段，存在一些格式问题，适合尝鲜 Typst 特性
> 
> 本模板是民间模板，**可能不被学校认可**，正式使用过程中请做好随时将内容迁移至 Word 或 LaTeX 的准备

## 关于本项目

[Typst](https://typst.app/) 是使用 Rust 语言开发的全新文档排版系统，您可以通过编写遵循 Typst 语法规则的文本文档、执行编译命令，来可生成目标格式的 PDF 文档。Typst 有望以 Markdown 级别的简洁语法和编译速度实现 LaTeX 级别的排版能力。

**universal-hit-thesis** 是一套简单易用的哈尔滨工业大学学位论文 Typst 模板，受 [hithesis](https://github.com/hithesis/hithesis) 启发，计划囊括一校三区本科、硕士、博士的学位论文格式。

**预览效果**

- 本科通用：[universal-bachelor.pdf](https://github.com/hitszosa/universal-hit-thesis/blob/build/universal-bachelor.pdf)
- 深圳硕士：[shenzhen-master.pdf](https://github.com/hitszosa/universal-hit-thesis/blob/build/shenzhen-master.pdf)
- 博士通用：[universal-doctor.pdf](https://github.com/hitszosa/universal-hit-thesis/blob/build/universal-bachelor.pdf)

## 使用

### 本地编辑 Ⅰ （推荐）

这种方式适合大多数用户。

首先安装 Typst，您可以在 Typst Github 仓库的 [Release 页面](https://github.com/typst/typst/releases/) 下载最新的安装包直接安装，并将 `typst` 可执行程序添加到 `PATH` 环境变量；如果您使用 Scoop 包管理器，则可以直接通过 `scoop install typst` 命令安装。

安装好 Typst 之后，您只需要选择一个您喜欢的目录，并在此目录下执行以下命令：

```sh
typst init @preview/universal-hit-thesis:0.3.0
```

Typst 将会创建一个名为 `universal-hit-thesis` 的文件夹，进入该目录后，您可以直接修改目录下的 `universal-bachelor.typ` ，然后执行以下命令进行编译生成 `.pdf` 文档：

```sh
typst compile universal-bachelor.typ
```

或者使用以下命令进行实时预览：

```sh
typst watch universal-bachelor.typ
```

当您要实时预览时，我们更推荐使用 Visual Studio Code 进行编辑，配合 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 等插件可以大幅提升您的编辑体验。

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
> 本模板正处于积极开发阶段，更新较为频繁，虽然已经上传至 Typst Universe，但是您依然可以借助 Typst local packages 来实现待 Typst Universe 同步本模板的最新版本前，在本地体验本模板的最新版本，具体可按如下步骤操作：
> - 确保配置了 Cargo 环境
> - 使用 `cargo install typship` 安装 typship
> - 项目根目录执行 `typship install local` 将项目部署至本地 `@local` 名称空间下
> - 在模板开头使用 `#import "@local/universal-hit-thesis:0.3.0"` 进行导入
> 更多内容可参考 [Typship](https://github.com/sjfhsjfh/typship) 的文档.

### 在线编辑

本模板已上传 Typst Universe，您可以使用 Typst 的官方 Web App 进行编辑。

具体来说，在 Typst Web App 登录后，点击 `Start from template`，在弹出的窗口中选择 `universal-hit-thesis`，即可从模板创建项目。

![hit-thesis-web-app-create](https://vonbrank-images.oss-cn-hangzhou.aliyuncs.com/20240426-HIT-Thesis-Typst/hit-thesis-web-app-create.jpg)

![hit-thesis-web-app-demo](https://vonbrank-images.oss-cn-hangzhou.aliyuncs.com/20240426-HIT-Thesis-Typst/hit-thesis-web-app-demo.jpg)

> [!NOTE]
>
> Typst Web App 的排版渲染在浏览器本地执行，所以实时预览体验几乎与在本地编辑无异。
> 
> 默认情况下，Web App 中的模板字体显示与预期可能存在差异，这是因为 Web App 默认不提供 `SimSun`, `Times New Roman` 等中文排版常用字体。为了解决这个问题，您可以在搜索引擎搜索以下字体文件：
> 
> - `TimesNewRoman.ttf` （包括 `Bold`, `Italic` `Bold-Italic` 等版本）
> - `SimSun.ttf`
> - `SimHei.ttf`
> - `Kaiti.ttf`
> - `Consolas.ttf`
> - `Courier New.ttf`
> 
> 并将这些文件手动上传至 Web App 项目根目录中，或为了目录整洁，可以创建一个 `fonts` 文件夹并将字体置于其中，Typst Web App 将自动加载这些字体，并正确渲染到预览窗口中.
> 
> 由于每次在 Typst Web App 中打开项目时都需要重新下载字体，而中文字体体积普遍较大，加载时间较长，因此我们更推荐**本地编辑**。

---

> [!NOTE]
> 注意到，官方提供的本科毕业设计 Microsoft Word 论文模板 `本科毕业论文（设计）书写范例（理工类）.doc` 在一校三区是通用的，意味着本 Typst 模板的本科论文部分理论上也是在一校三区通用的，因此我们提供适用于各校区的本科毕业论文模板模块导出，即以下四种导入模块的方式效果相同：
> ```typ
> #import "@preview/universal-hit-thesis:0.3.0": harbin-bachelor
> #import harbin-bachelor: * // 哈尔滨校区本科
> ```
> ```typ
> #import "@preview/universal-hit-thesis:0.3.0": weihai-bachelor
> #import weihai-bachelor: * // 威海校区本科
> ```
> ```typ
> #import "@preview/universal-hit-thesis:0.3.0": shenzhen-bachelor
> #import shenzhen-bachelor: * // 深圳校区本科
> ```
> ```typ
> #import "@preview/universal-hit-thesis:0.3.0": universal-bachelor
> #import universal-bachelor: * // 一校三区本科通用
> ```
> 博士论文模板也存在类似的情况，`universal-doctor` 模块理论上在一校三区是通用的

## 特性 / 路线图

- 模板
  - [x] 哈尔滨校区本科毕业设计
  - [ ] 哈尔滨校区硕士毕业论文
  - [x] 哈尔滨校区博士毕业论文
  - [x] 威海校区本科毕业设计
  - [ ] 威海校区硕士毕业论文
  - [x] 威海校区博士毕业论文
  - [x] 深圳校区本科毕业设计
  - [x] 深圳校区硕士毕业论文
  - [x] 深圳校区博士毕业论文
- 排版
  - [ ] 不同操作系统字符集行距、段落间距适配
  - [ ] 不同校区不同模板主题化
- 组件
  - [x] 双语目录
  - [x] 双语图表
  - [x] 伪代码
  - [x] 电子签名

## 依赖

### 可选依赖

若要书写和引用伪代码，您可以使用 `algorithm-figure`，为此，您需要导入 `algo` 或 `lovelace` 包。

```typ
#import "@preview/algo:0.3.4": algo, i, d, comment, code

#import "@preview/lovelace:0.2.0": *
```

使用方式详见[模板](https://github.com/chosertech/HIT-Thesis-Typst/blob/main/templates/universal-bachelor.typ)中的`伪代码`节

## 已知问题

### 排版

尽管本 Typst 模板各部分字体、字号等设置均与原 Word 模板一致，但段落排版视觉上仍与 Word 模板有一些差别，这与字符间距、行距、段落间距有一定肉眼排版成分有关.

### 参考文献

- 学校对参考文献格式的要求与标准的 `GB/T 7714-2015 numeric` 格式存在差异，我们已修改相关 CSL 文件并形成 `gb-t-7714-2015-numeric-hit.csl` 以修复作者名字大小写等问题，但仍有以下已知特性尚未支持：
  - 仅纯电子资源（如网页、软件）显示引用日期和 URL
  - 无 DOI
- 引用其他学校的学位论文时参考文献页对应条目存在格式问题，因为 Typst 尚不支持 CSL 文件中的 `school` 等字段.
- 目前版本的 Typst 对 CSL 支持程度成谜，更多问题可参考 [SEU-Typst-Template 参考文献已知问题](https://github.com/csimide/SEU-Typst-Template/?tab=readme-ov-file#%E5%8F%82%E8%80%83%E6%96%87%E7%8C%AE).
- 目前的行距、段间距等仅针对 Windows 下的中文字体做适配，Linux/Mac OS 下可能存在字体适配问题.

## 致谢

+ 感谢 [HUST-typst-template](https://github.com/werifu/HUST-typst-template) 为本模板早期版本的框架提供思路.
+ 感谢 [@csimide](https://gist.github.com/csimide) 和 [@OrangeX4](https://github.com/OrangeX4) 提供的中英双语参考文献实现.
+ 感谢 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 为本模板的一些特性提供实现思路.
