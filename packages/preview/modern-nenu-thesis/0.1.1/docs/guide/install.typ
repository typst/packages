#import "../book.typ": *


#show: book-page.with(title: "安装")
#show: checklist.with(fill: white.darken(20%), stroke: blue.lighten(20%))

#let page-self = "/guide/install.typ"

#mywarning(title: "写在前面")[
  需要保证你拥有 `LiSu`（隶书）这个字体模板才能够正常渲染，而官方的服务器在字体上对中文支持并不是很好，因此我们推荐第二种方式进行开发
]

= 在线安装

你可以在 #link("https://typst.app/")[官方WebAPP] 上注册账号免费在线编辑，具体而言：

在 #link("https://typst.app/universe/")[Typst 的官方库] 中搜索 `modern-nenu-thesis` 即可找到模板（或直接访问 #link("https://typst.app/universe/package/modern-nenu-thesis")[modern-nenu-thesis]）

通过官方提供的 `Create project in App` 选项，我们可以创建一个使用此模板的项目，文件仅包含 `template` 中的：

- `fig/`: 用于存放图片文件
- `ref.bib`: 为 `biblatex` 数据库
- `thesis.typ`: 为论文文件

= 本地使用 (_推荐_)

首先我们需要在本地下载 `Typst` 的编译器，具体操作参考 #link("https://github.com/typst/typst")[官方指引]

// NOTE 修改时注意版本号的修改

这样，我们就可以通过命令（注意版本号）：

```sh
typst init @preview/modern-nenu-thesis:0.1.0
```
使用这个模板来创建一个项目

我们推荐使用 `VS Code` 配合插件 `Tinymist` 进行编辑，打开 `template/thesis.typ` 进行预览即可

= 完全离线

你可以通过 `git` 来克隆本仓库：
```sh
git clone git@github.com:virgiling/NENU-Thesis-Typst.git modern-nenu-thesis
```
在 `modern-nenu-thesis` 中即可开始编辑，编辑的方式与本地使用一致

#mynotify[
  离线使用的话有福利（虽然也不算真的福利），你可以使用 `other` 文件夹中的模板，这些模板都是单页使用（但会使用 `assets` 中的一些文件），你可以直接打开这些模板文件，然后进行预览

  - 实验报告模板 (lab-report.typ)
  - 研究生/博士生 开题报告模板 (master-proposal.typ)
]
