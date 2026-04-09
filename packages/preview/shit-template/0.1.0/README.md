## S.H.*.T Typst Template

![The logo of S.H.*.T. journal](./imgs/LOGO1.png)

> 为 [S.H.*.T](https://shitspace.xyz/) 期刊编写的typst模板，带来超越word与tex的体验，助你轻松编辑，简洁书写。
> 如果这帮到了你，阁下不妨点击⭐️作为激励

- Typst 非官方中文交流群:793548390
- **如遇到任何问题或需求，请联系Axuan:** _`1932208172@qq.com`_

## 重要提示：字体安装

本模板的主体中文字体使用了**思源宋体 (Source Han Serif)**。由于字体文件体积较大，未打包在模板内部。为了确保您的文档能够正确编译并呈现最佳排版效果：

* **本地命令行 (CLI) 用户：** 请务必确保您的个人电脑上已经安装了 [思源宋体](https://github.com/adobe-fonts/source-han-serif)（或 Noto Serif CJK SC）。
* **Typst 网页版 (Web App) 用户：** 您无需进行任何额外操作，目前 Typst 官方服务器已经预装了非常多高质量的开源 CJK（中日韩）字体。

## 编辑方式

- [Visual Studio Code](https://visualstudio.microsoft.com/) + [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)，推荐使用此种方式。
- [Typst app](https://typst.app/universe/package/shit-template) -> Start from a template，由Typst Template创建以体验此模板。

## 使用方式

### 1. 命令行初始化
如果您已在本地安装了 Typst，只需打开终端运行以下命令，即可一键拉取官方库的最新稳定版并创建论文文件夹：

```shell
typst init @preview/shit-template:0.1.0 my-paper
cd my-paper
```
初始化完成后，使用 VS Code 打开 my-paper 文件夹，编辑 main.typ 即可开始写作。

### 2. 使用Typst Web App

1. 打开 [Typst Web App](https://typst.app/) 并登录您的账号
2. 新建空白文档
3. 复制以下代码

```typst
#import "@preview/shit-template:0.1.0": *

#show: ieee-paper.with(
  title: "这里是论文的中文标题，请替换为您的研究题目",
  authors: (
    (
      name: "第一作者",
      marks: "1",
    ),
    (
      name: "第二作者",
      marks: "2",
    ),
  ),
  abstract: [
    摘要应简洁概括论文的内容，并涵盖研究背景、方法、结果和结论等要点...
  ],
  keywords: ("关键词一", "关键词二", "关键词三"),
)
= 引言
在这里开始撰写您的正文...
```
4. 在左侧的文件树中，新建一个名为 refs.bib 的空文件用于存放参考文献，并在需要时上传您的图片到左侧目录中。

### 3. 本地安装

```shell
git clone https://github.com/QzxTaqtaq/shit-typst-template.git
cd ./shit-typst-template

# linux / macOS
sudo bash ./local_install.sh

# windows
.\local_install.sh
```

完成本地安装后，您只需要在写论文时，将原来代码中的 `@preview/shit-template:0.1.0`替换为 `@local/shit-template:0.1.0`即可调用本地最新版。

## 开源协议

本项目采用 MIT 开源协议进行授权 —— 详情请参阅 LICENSE 文件。

**特别说明：** 位于 `template` 目录下的文件，以及您基于本模板所生成的最终文档，均适用 [MIT-0](https://choosealicense.com/licenses/mit-0/)（即 MIT 无署名限制）协议。这意味着，您可以自由自在地使用本模板撰写学术论文或其他文档；在您最终发表的作品中，既**无需**附带任何 MIT 许可声明文本，也**无需**对原作者进行署名。