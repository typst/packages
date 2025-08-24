# :page_facing_up: 同济大学本科生毕业设计论文 Typst 模板（理工类）

中文 | [English](README-EN.md)

> [!CAUTION]
> 由于 Typst 项目仍处于密集发展阶段，且对某些功能的支持不完善，因此本模板可能存在一些问题。如果您在使用过程中遇到了问题，欢迎提交 issue 或 PR，我们会尽力解决。
>
> 在此期间，欢迎大家使用[我们的 LaTeX 模板](https://github.com/TJ-CSCCG/tongji-undergrad-thesis)。

## 样例展示

以下依次展示 “封面”、“中文摘要”、“目录”、“主要内容”、“参考文献” 与 “谢辞”。

<p align="center">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0001.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0002.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0004.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0005.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0019.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0020.jpg" width="30%">
</p>

## 使用方法

### 在线 Web App

#### 创建项目

- 打开 Typst Universe 中的 [![svg of typst-tongjithesis](https://img.shields.io/badge/Typst-paddling--tongji--thesis-239dae)](https://www.overleaf.com/latex/templates/tongji-university-undergraduate-thesis-template/tfvdvyggqybn)
并点击 `Create project in app`。

- 或在 [Typst Web App](https://typst.app) 中选择 `Start from a template`，然后选择 `paddling-tongji-thesis`。

#### 上传字体

从[`fonts` 分支](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts)下载所有字体文件，上传到该项目的根目录。即可开始使用。

### 本地使用

#### 1. 安装 Typst

参照 [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) 官方文档安装 Typst。

#### 2. 下载字体

从[`fonts` 分支](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts)下载所有字体文件，并**安装到系统中**。

#### 使用 `typst` 初始化

##### 初始化项目

```bash
typst init @preview/paddling-tongji-thesis
```

##### 编译

```bash
typst compile main.typ
```

#### 使用 `git clone` 初始化

##### Git Clone 项目

```bash
git clone https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst.git
cd tongji-undergrad-thesis-typst
```

##### 编译

```bash
typst compile init-files/main.typ --root .
```

> [!TIP]
> 若你不想把项目使用的字体安装到系统中，可以在编译时指定字体路径，例如：
>
> ```bash
> typst compile init-files/main.typ --root . --font-path {YOUR_FONT_PATH}
> ```

## 如何为该项目贡献代码？

还请查看 [How to pull request](CONTRIBUTING.md/#how-to-pull-request)。

## 开源协议

该项目使用 [MIT License](LICENSE) 开源协议。

### 免责声明

本项目使用了方正字库中的字体，版权归方正字库所有。本项目仅用于学习交流，不得用于商业用途。

## 有关突出贡献的说明

- 该项目起源于 [FeO3](https://github.com/seashell11234455) 的初始版本项目 [tongji-undergrad-thesis-typst](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/lky)。
- 后来 [RizhongLin](https://github.com/RizhongLin) 对模板进行了完善，使其更加符合同济大学本科生毕业设计论文的要求，并增加了针对 Typst 的基础教程。

我们非常感谢以上贡献者的付出，他们的工作为更多同学提供了方便和帮助。

在使用本模板时，如果您觉得本项目对您的毕业设计或论文有所帮助，我们希望您可以在您的致谢部分感谢并致以敬意。

## 致谢

我们从顶尖高校的优秀开源项目中学到了很多：

- [lucifer1004/pkuthss-typst](https://github.com/lucifer1004/pkuthss-typst)
- [werifu/HUST-typst-template](https://github.com/werifu/HUST-typst-template)

## 联系方式

```python
# Python
[
    'rizhonglin@$.%'.replace('$', 'epfl').replace('%', 'ch'),
]
```

### QQ 群

- TJ-CSCCG 交流群：`1013806782`
