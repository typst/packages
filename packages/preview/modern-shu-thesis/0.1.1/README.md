# 上海大学本科生毕业论文模板 typst-shu-thesis

魔改自上交的模板: [typst-sjtu-thesis-master](https://github.com/tzhTaylor/typst-sjtu-thesis-master)

这是上海大学本科生学位论文的 [Typst 模板](https://typst.app/universe/package/shu-thesis)
，它能够简洁、快速、持续生成 PDF 格式的毕业论文，它基于本科生院官方提供的模板进行开发。基于本科生院提供的 [word 模板](https://cj.shu.edu.cn/DataInterface/上海大学本科毕业论文（设计）撰写格式模板.pdf) 进行开发。

## 使用

快速浏览效果: 查看 [thesis.pdf](https://github.com/XY-cpp/typst-shu-thesis/releases/latest/download/thesis.pdf)，样例论文源码：查看 [thesis.typ](https://github.com/XY-cpp/typst-shu-thesis/blob/main/template/thesis.typ)

**你只需要修改 `thesis.typ` 文件即可，基本可以满足你的所有需求。**

### VS Code 本地编辑（推荐）

#### 使用 Typst Universe 模板库版本

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 按照如下命令
   - 按下 `Ctrl + Shift + P`(Windows) / `Command + Shift + P`(MacOS) 打开命令界面
   - 输入 `Typst: Initialize a New Typst Project based on a Template` 并点击 
   - 输入 `@preview/modern-shu-thesis`并回车
   - 选择一个空的目录

3. 最后用 VS Code 打开指定的目录，打开 `thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

#### 使用 GitHub 仓库版本

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 运行命令 `git clone git@github.com:XY-cpp/typst-shu-thesis.git`，克隆本仓库到本地。

3. 最后用 VS Code 打开目录，打开 `template/thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

### Web APP

Typst 提供了官方的 Web App，支持像 Overleaf 一样在线编辑。

实际上，我们只需要在 [Web App](https://typst.app/) 中的 `Start from template` 里选择 `modern-shu-thesis`，即可在线创建模板并使用。

**但是 Web App 并没有安装本地 Windows 或 MacOS 所拥有的字体，所以字体上可能存在差异，所以推荐本地编辑！**

**你需要手动上传 fonts 目录下的字体文件到项目中，否则会导致字体显示错误！**

## License

本项目采用 MIT 许可证。

图片 `assets/cover.png` `assets/under-cover.png`：由上海大学提供，版权归上海大学所有，仅限本毕业设计使用。

未经授权，禁止将本毕业设计中的任何内容用于其他用途。

This project is licensed under the MIT License.

The images `assets/cover.png` and `assets/under-cover.png` are provided by Shanghai University, and the copyright is owned by Shanghai University. They are for use only in this graduation project.

Unauthorized use of any content from this graduation project for other purposes is prohibited.
