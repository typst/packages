# 上海交通大学学位论文 modern-sjtu-thesis

这是上海交通大学学位论文的 [Typst 模板](https://typst.app/universe/package/modern-sjtu-thesis)
，它能够简洁、快速、持续生成 PDF 格式的毕业论文，现已支持本科、硕士和博士的毕业论文撰写，均参考官方提供的word模板进行开发。

## 使用

### VS Code 本地编辑（推荐）

#### 使用 Typst Universe 模板库版本

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 按下 `Ctrl + Shift + P`(Windows) / `Command + Shift + P`(MacOS) 打开命令界面，输入 `Typst: Show available Typst templates (gallery) for picking up a template` 打开 Tinymist 提供的 Template Gallery，然后从里面找到 `modern-sjtu-thesis`，点击 `❤` 按钮进行收藏，以及点击 `+` 号，就可以创建对应的论文模板了。

3. 最后用 VS Code 打开生成的目录，打开 `thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

> 优点：使用最简单，目录结构清晰；缺点：官方模板库无法及时维护，出现 Bug 或者想要自定义样式，无法自行修改。

#### 使用 GitHub 仓库版本

1. 在 VS Code 中安装 [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 插件，负责语法高亮, 错误检查和 PDF 预览。

2. 运行命令 `git clone https://github.com/tzhTaylor/modern-sjtu-thesis`，克隆本仓库到本地。

3. 最后用 VS Code 打开目录，打开 `template/thesis.typ` 文件，按下 `Ctrl + K V`(Windows) / `Command + K V`(MacOS) 或者是点击右上角的按钮进行实时编辑和预览。

> 优点：模板更新最及时，在了解 Typst 语法的情况下可以自行对模板进行修改；对 git 操作不太熟悉的用户门槛较高。

### Web APP

Typst 提供了官方的 Web App，支持像 Overleaf 一样在线编辑。

实际上，我们只需要在 [Web App](https://typst.app/?template=modern-sjtu-thesis&version=0.5.0) 中的 `Start from template` 里选择 `modern-sjtu-thesis`，即可在线创建模板并使用。

**但是 Web App 并没有安装本地 Windows 或 MacOS 所拥有的字体，所以字体上可能存在差异，所以推荐本地编辑！**

**你需要手动上传 fonts 目录下的字体文件到项目中，否则会导致字体显示错误！**

## Typst 快速入门

推荐这篇「[面向 Word 用户的快速入门向导](https://typst-doc-cn.github.io/guide/word.html)」，虽然标题写的是面向 Word 用户，但适合所有对于排版或者样式定制有一定的需求的人快速上手 Typst，并且开始使用 Typst 的排版功能。

## 功能列表

- **全局配置**
  - [x] 类似 LaTeX 中的 `documentclass` 的全局信息配置
  - [x] 盲审模式：将个人信息替换成小黑条，并且隐藏致谢页面，论文提交阶段使用
  - [x] 双面模式：加入空白页，便于打印和增加论文页数
  - [x] 打印模式：调整页边距，便于打印
- **模板**
  - [x] 模板
    - [x] 中文封面
    - [x] 英文封面
    - [x] 声明页
    - [x] 中文摘要
    - [x] 英文摘要
    - [x] 目录页
    - [x] 插图目录
    - [x] 表格目录
    - [x] 算法目录
    - [x] 符号对照表
    - [x] 附录
    - [x] 参考文献
    - [x] 致谢
    - [x] 成果
    - [x] 英文大摘要（本科）
- **环境**
  - [x] 插图环境 `imagex`
    - [x] 子图 `subimagex`
    - [x] 双语图题
  - [x] 表格环境 `tablex`
    - [x] 续表
    - [x] 脚注
  - [x] 算法环境 `algox`：跨页自动续
  - [x] 定理环境：使用 `theorion` 包
- **其他功能**
  - [x] 正文字数统计
  - [x] 避免孤行标题 (experimental)
  - [x] 自定义参考文献格式
  - [x] 多行公式编号

## 相关链接

如果对 Typst 论文撰写感兴趣的话，可以从开题报告和中期报告模板开始尝试。

- [研究生开题报告 Typst 模板](https://github.com/tzhTaylor/typst-sjtu-thesis-proposal)

- [硕士研究生中期报告 Typst 模板](https://github.com/tzhTaylor/typst-sjtu-thesis-midterm)

如果想要类似于 SJTUBeamer 的幻灯片模板，可以使用我开发的

- [基于 Touying 的上海交通大学 Typst 幻灯片模板](https://github.com/tzhtaylor/touying-sjtu)

如果想要在平时的数学作业中使用 Typst，但对于 Typst 相关的数学语法不太熟悉，可以参考我维护的

- [《本科生 LaTeX 数学》的 Typst 中文版](https://github.com/tzhtaylor/typst-undergradmath-zh)

## Q&A

### 我不会 LaTeX，可以用这个模板写论文吗？

可以。

如果你不关注模板的具体实现原理，你可以用 Markdown Like 的语法进行编写，只需要按照模板的结构编写即可。

### 我不会编程，可以用这个模板写论文吗？

同样可以。

如果仅仅是当成是入门一款类似于 Markdown 的语言，相信使用该模板的体验会比使用 Word 编写更好。

### 为什么只有一个 thesis.typ 文件，没有按章节分多个文件？

因为 Typst **语法足够简洁**、**编译速度足够快**、并且 **拥有光标点击处双向跳转功能**。

语法简洁的好处是，即使把所有内容都写在同一个文件，你也可以很简单地分辨出各个部分的内容。

编译速度足够快的好处是，你不再需要像 LaTeX 一样，将内容分散在几个文件，并通过注释的方式提高编译速度。

光标点击处双向跳转功能，使得你可以直接拖动预览窗口到你想要的位置，然后用鼠标点击即可到达对应源码所在位置。

还有一个好处是，单个源文件便于同步和分享。

### 为什么 Typst 有很多关于字体的警告？

你会发现 Typst 有许多关于字体的警告，这是因为 modern-sjtu-thesis 为了保证在各个系统的可用性，加入了各个系统的字体集，你可以无视警告，或者克隆本仓库后在 `utils/style.typ` 中删除系统中不存在的字体。

### 学习 Typst 需要多久？

一般而言，仅仅进行简单的编写，不关注布局的话，你可以打开模板就开始写了。

如果你想进一步学习 Typst 的语法，例如如何排篇布局，如何设置页脚页眉等，一般只需要几个小时就能学会。

如果你还想学习 Typst 的「[参考](https://typst-doc-cn.github.io/docs/reference/foundations/)」部分，进而能够编写自己的模板，一般而言需要几天的时间阅读文档，以及他人编写的模板代码。

如果你有 Python 或 JavaScript 等脚本语言的编写经验，了解过函数式编程、宏、样式、组件化开发等概念，入门速度会快很多。

### 目前 Typst 有哪些第三方包和模板？

可以查看 [Typst Universe](https://typst.app/universe)。

个人推荐的包：

- 基础绘图：[cetz](https://typst.app/universe/package/cetz)
- 绘制带有节点和箭头的图表，如流程图等：[fletcher](https://typst.app/universe/package/fletcher)
- 绘制数据图：[lilaq](https://typst.app/universe/package/lilaq)
- 定理环境：[theorion](https://typst.app/universe/package/theorion)
- 伪代码：[lovelace](https://typst.app/universe/package/lovelace)
- 带行号的代码显示包：[codly](https://typst.app/universe/package/codly)
- 简洁的 Numbering 包：[numbly](https://typst.app/universe/package/numbly)
- 幻灯片和演示文档：[touying](https://typst.app/universe/package/touying)
- 相对定位布局包：[pinit](https://typst.app/universe/package/pinit)
- 数学单位包：[unify](https://typst.app/universe/package/unify)
- 数字格式化包：[zero](https://typst.app/universe/package/zero)

在模板文件中我也展示了一些第三方包的用法。

## 致谢

- 感谢 [@OrangeX4](https://github.com/OrangeX4) 开发的 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 模板，本模板大体结构都是参考其开发的。

- 感谢 [Typst 中文社区导航 FAQ](https://typst-doc-cn.github.io/guide/FAQ.html)，帮忙解决了各种疑难杂症。

## License

This project is licensed under the MIT License.

It also includes third-party components licensed under other open source licenses,
including the Apache License 2.0 and MIT License.

See the `third_party/` directory for details on third-party components and their licenses.
