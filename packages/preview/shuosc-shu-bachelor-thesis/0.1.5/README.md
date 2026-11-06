# 上海大学本科生毕业论文 Typst 模板 - 上海大学开源社区版 (SHUOSC)

由上交的模板修改而来: [typst-sjtu-thesis-master](https://github.com/tzhTaylor/typst-sjtu-thesis-master)

这是上海大学本科生学位论文的 Typst 模板，它能够简洁、快速、持续生成 PDF 格式的毕业论文，它基于本科生院官方提供的模板进行开发。基于本科生院提供的 [word 模板](https://cj.shu.edu.cn/DataInterface/上海大学本科毕业论文（设计）撰写格式模板.pdf) 进行开发。

## 1. 使用方法

### 1.1. (推荐) VSCode 本地编辑 + 使用 Typst Universe 模板库

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 分别执行以下命令: 
   - 按下 `Ctrl + Shift + P`(Windows) / `Command + Shift + P`(MacOS) 打开命令界面
   - 输入 `Typst: Initialize a New Typst Project based on a Template` 并点击 
   - 输入 `@preview/shuosc-shu-bachelor-thesis` 并回车
   - 选择一个空的目录

3. 最后用 VS Code 打开指定的目录，打开 `thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

### 1.2. (开发者) VSCode 本地编辑 + 使用 GitHub 仓库

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 运行命令 `git clone git@github.com:shuosc/SHU-Bachelor-Thesis-Typst.git`，克隆本仓库到本地。

3. 最后用 VS Code 打开目录，打开 `template/thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

### 1.3. Web APP 在线编辑

Typst 提供了官方的 Web App，支持像 Overleaf 一样在线编辑。

实际上，我们只需要在 [Web App](https://typst.app/) 中的 `Start from template` 里选择 `shuosc-shu-bachelor-thesis`，即可在线创建模板并使用。

**但是 Web App 并没有安装本地 Windows 或 MacOS 所拥有的字体，所以字体上可能存在差异，所以推荐本地编辑！**

**你需要手动上传 fonts 目录下的字体文件到项目中，否则会导致字体显示错误！**

## 2. License

本项目采用 Apache 许可证（详见[LICENSE](./LICENSE)） 和 MIT 许可证（third-party, 详见[LICENSE-MIT](./LICENSE-MIT)）。

图片 `assets/cover.png` `assets/under-cover.png`：由上海大学提供，版权归上海大学所有，仅限本毕业设计使用。

This project is licensed under the Apache License (see [LICENSE](./LICENSE)) and MIT License (third-party, see [LICENSE-MIT](./LICENSE-MIT)).

The images `assets/cover.png` and `assets/under-cover.png` are provided by Shanghai University, and the copyright is owned by Shanghai University. They are for use only in this graduation project.