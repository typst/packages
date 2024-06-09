# :page_facing_up: 同济大学本科生毕业设计论文 Typst 模板（理工类）

中文 | [English](README-EN.md)

> [!CAUTION]
> 由于 Typst 项目仍处于密集发展阶段，且对某些功能的支持不完善，因此本模板可能存在一些问题。如果您在使用过程中遇到了问题，欢迎提交 issue 或 PR，我们会尽力解决。
>
> 在此期间，欢迎大家使用[我们的 $\LaTeX$ 模板](https://github.com/TJ-CSCCG/tongji-undergrad-thesis)。

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

请打开 [https://typst.app/universe/package/tongji-undergrad-thesis](https://typst.app/universe/package/tongji-undergrad-thesis) 并点击 `Create project in app` ，或在 Web App 中选择 `Start from a template`，再选择 `tongji-undergrad-thesis`。

然后，请将 [https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts/fonts](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts/fonts) 内的 **所有** 字体上传到 Typst Web App 内该项目的根目录。

### 本地 - 使用typst init

#### 1. 安装 Typst

参照 [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) 官方文档安装 Typst。

#### 2. 从模板初始化项目

```bash
typst init @preview/tongji-undergrad-thesis
```

#### 3. 下载字体

请到本仓库的 [`fonts`](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts) 分支下载字体文件，并将其安装到系统中。

#### 4. 编译

按照需求修改相关文件，然后执行以下命令以编译。

```bash
typst compile main.typ
```

> [!TIP]
> 若您发现字体无法正常显示，请将字体文件安装到系统中，再执行编译命令。

### 本地 - 使用Git Clone

#### 1. 安装 Typst

参照 [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) 官方文档安装 Typst。

#### 2. clone 本项目

```bash
git clone https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst.git
cd tongji-undergrad-thesis-typst
```

#### 3. 下载字体

请到本仓库的 [`fonts`](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts) 分支下载字体文件，并将其放置在 `fonts` 文件夹中，或者将字体文件安装到系统中。

#### 4. 编译

按照需求修改`init-files`目录内的相关文件，然后执行以下命令以编译。

```bash
typst --font-path ./fonts compile init-files/main.typ --root . 
```

> [!TIP]
> 若您发现字体无法正常显示，请将 `fonts` 文件夹中的字体文件安装到系统中，再执行编译命令。

## 如何为该项目贡献代码？

还请查看 [How to pull request](CONTRIBUTING.md/#how-to-pull-request)。

## 开源协议

该项目使用 [MIT License](LICENSE) 开源协议。

### 免责声明

本项目使用了方正字库中的字体，版权归方正字库所有。本项目仅用于学习交流，不得用于商业用途。

## 有关突出贡献的说明

* 该项目起源于 [FeO3](https://github.com/seashell11234455) 的初始版本项目 [tongji-undergrad-thesis-typst](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/lky)。
* 后来 [RizhongLin](https://github.com/RizhongLin) 对模板进行了完善，使其更加符合同济大学本科生毕业设计论文的要求，并增加了针对 Typst 的基础教程。

我们非常感谢以上贡献者的付出，他们的工作为更多同学提供了方便和帮助。

在使用本模板时，如果您觉得本项目对您的毕业设计或论文有所帮助，我们希望您可以在您的致谢部分感谢并致以敬意。

## 致谢

我们从顶尖高校的优秀开源项目中学到了很多：

* [lucifer1004/pkuthss-typst](https://github.com/lucifer1004/pkuthss-typst)
* [werifu/HUST-typst-template](https://github.com/werifu/HUST-typst-template)

## 联系方式

```python
# Python
[
    'rizhonglin@$.%'.replace('$', 'epfl').replace('%', 'ch'),
]
```

### QQ 群

* TJ-CSCCG 交流群：`1013806782`
