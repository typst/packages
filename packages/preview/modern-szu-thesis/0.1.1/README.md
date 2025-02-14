# 深圳大学学位论文 modern-szu-thesis

深圳大学毕业论文（设计）的 Typst 模板，能够简洁、快速、持续生成 PDF 格式的毕业论文，这是基于[modern-nju-thesis](https://typst.app/universe/package/modern-nju-thesis)的深大本科生论文模板。

**此模板非官方模板，有不被接受的可能性**

# 优势
typst
- 编译快
- 制作模板能力强
- 现代的编程语言
- 有强大的控制力，也有标记模式

# 劣势
typst
- 新兴排版语言，积累较少
- 不够稳定，还处于发展状态

# 使用帮助

## 在线编辑

官方提供的在线编辑器，在这里你可以通过搜索模板而使用它
**由于官方在线编辑器没有提供字体，因此你必须需要上传/font目录下的字体才可以正常显示字体。**
(ps: 虽然与 Overleaf 看起来相似，但是它们底层原理并不相同。Overleaf 是在后台服务器运行了一个 LaTeX 编译器，本质上是计算密集型的服务；而 Typst 只需要在浏览器端使用 WASM 技术执行，本质上是 IO 密集型的服务，所以对服务器压力很小（只需要负责文件的云存储与协作同步功能）。)

## VS Code 本地编辑（推荐）

配置相当简单。

+ 在 VS Code 中安装 Tinymist Typst 和 Typst Preview 插件。前者负责语法高亮和错误检查等功能，后者负责预览。
        - 也推荐下载 Typst Companion 插件，其提供了例如 Ctrl + B 进行加粗等便捷的快捷键。
        - 你还可以下载[OrangeX4](https://github.com/OrangeX4)开发的 Typst Sync 和 Typst Sympy Calculator 插件，前者提供了本地包的云同步功能，后者提供了基于 Typst 语法的科学计算器功能。
+ 按下 Ctrl + Shift + P 打开命令界面，输入 Typst: Show available Typst templates (gallery) for picking up a template 打开 Tinymist 提供的 Template Gallery，然后从里面找到 modern-szu-thesis，点击 ❤ 按钮进行收藏，以及点击 + 号，就可以创建对应的论文模板了。
+ 最后用 VS Code 打开生成的目录，打开 thesis.typ 文件，并按下 Ctrl + K V 进行实时编辑和预览。

(这就好了？不错，你甚至不需要下载typst)

# 计划路线图

- [x]封面复刻
- [x]诚信声明
- [x]目录
- [x]中文摘要
- [x]正文
- [x]参考文献
- [x]致谢
- [x]英文摘要

# 致谢
感谢 [OrangeX4](https://github.com/OrangeX4) 制作的modern-nju-thesis模板，此模板可使用性很强。本readme文件参照了此模板的readme文件编写。
