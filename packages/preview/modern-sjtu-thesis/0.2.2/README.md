# 上海交通大学学位论文 modern-sjtu-thesis

这是上海交通大学学位论文的 [Typst 模板](https://typst.app/universe/package/modern-sjtu-thesis)
，它能够简洁、快速、持续生成 PDF 格式的毕业论文，现已支持本科、硕士和博士的毕业论文撰写，均参考官方提供的word模板进行开发。

## 使用

### VS Code 本地编辑（推荐）

#### 使用 Typst Universe 模板库版本

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 按下 `Ctrl + Shift + P`(Windows) / `Command + Shift + P`(MacOS) 打开命令界面，输入 `Typst: Show available Typst templates (gallery) for picking up a template` 打开 Tinymist 提供的 Template Gallery，然后从里面找到 `modern-sjtu-thesis`，点击 `❤` 按钮进行收藏，以及点击 `+` 号，就可以创建对应的论文模板了。

3. 最后用 VS Code 打开生成的目录，打开 `thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

#### 使用 GitHub 仓库版本

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 运行命令 `git clone https://github.com/tzhTaylor/modern-sjtu-thesis`，克隆本仓库到本地。

3. 最后用 VS Code 打开目录，打开 `template/thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

### Web APP

Typst 提供了官方的 Web App，支持像 Overleaf 一样在线编辑。

实际上，我们只需要在 [Web App](https://typst.app/?template=modern-sjtu-thesis&version=0.2.2) 中的 `Start from template` 里选择 `modern-sjtu-thesis`，即可在线创建模板并使用。

**但是 Web App 并没有安装本地 Windows 或 MacOS 所拥有的字体，所以字体上可能存在差异，所以推荐本地编辑！**

**你需要手动上传 fonts 目录下的字体文件到项目中，否则会导致字体显示错误！**

## 相关链接

如果对 Typst 感兴趣的话，可以从开题报告和中期报告模板开始尝试。

- [研究生开题报告 Typst 模板](https://github.com/tzhTaylor/typst-sjtu-thesis-proposal)

- [硕士研究生中期报告 Typst 模板](https://github.com/tzhTaylor/typst-sjtu-thesis-midterm)

## 致谢

- 感谢 [@OrangeX4](https://github.com/OrangeX4) 开发的 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 模板，本模板大体结构都是参考其开发的。

- 感谢 [Typst 中文社区导航 FAQ](https://typst-doc-cn.github.io/guide/FAQ.html)，帮忙解决了各种疑难杂症。

## License

This project is licensed under the MIT License.
