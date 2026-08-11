// 导入模块
#import "@preview/rewind-note:0.1.0": *

// 使用主题（可传入自定义配置）
#show: rewind-theme.with(
  font-family: serif-fonts, // 可切换字体
  // bg-color: rgb("#fff0f0"),  // 可自定义背景色
)

// =================正文内容=================

#cover(
  // image-content: image("assets/brand.png"),
  title: [这是一篇使用#highlight[Typst]写的小红书笔记],
  subtitle: [Typst 小红书模板],
  author: "@reina",
)

= 什么是 Typst？

Typst 是一款新兴的排版系统，被称为 #highlight[LaTeX 的现代替代品]。它由两位德国开发者创建，目标是解决 LaTeX 学习曲线陡峭、编译速度慢的问题。

如果你曾经被 LaTeX 的报错信息折磨过，或者等待编译等到怀疑人生，那 Typst 绝对值得一试。

== 为什么选择 Typst？

1. *编译速度超快*：增量编译，实时预览，告别漫长等待。改一个字，瞬间看到效果。

2. *语法简洁直观*：比 LaTeX 更易学，比 Markdown 更强大。上手只需要几分钟。

3. *错误提示友好*：不再面对一堆看不懂的报错信息。Typst 会告诉你哪里错了、怎么改。

4. *内置脚本语言*：可编程的排版，自定义无限可能。想要什么样式，自己写就行。

5. *现代化工具链*：原生支持包管理、在线编辑、协作功能。

== Typst vs LaTeX

LaTeX 诞生于 1984 年，历史悠久但语法繁琐。写一个简单的文档都需要记住大量的命令和包。

Typst 吸取了现代编程语言的优点，让排版变得像写代码一样优雅。语法设计参考了 Rust、Python 等现代语言。

=== 语法对比

LaTeX 写个加粗：`\textbf{加粗}`

Typst 写个加粗：`*加粗*`

LaTeX 插入图片：

```latex
\begin{figure}
  \includegraphics{img.png}
  \caption{图片标题}
\end{figure}
```

Typst 插入图片：

```typst
#figure(
  image("img.png"),
  caption: [图片标题]
)
```

简单，直接，符合直觉。

=== 编译速度

LaTeX 编译一个 100 页的文档可能需要几十秒甚至几分钟。

Typst 编译同样的文档只需要毫秒级别。而且支持增量编译，只重新渲染改动的部分。

== Typst 的生态

虽然 Typst 还很年轻，但生态发展迅速：

- *Typst Universe*：官方包管理平台，已有数百个社区包
- *在线编辑器*：#link("https://typst.app")[typst.app] 提供免费的在线编辑环境
- *Tinymist*：强大的 LSP 实现，为 VS Code / Neovim 等编辑器提供智能补全、实时预览
- *中文支持*：原生支持 CJK 字符，不需要额外配置

= 关于这个模板

这是一个专为 #highlight[小红书风格] 设计的 Typst 模板。

为什么要做这个模板？因为小红书的图文笔记很火，但每次都要用设计软件排版太麻烦了。有了这个模板，直接写 Typst 代码就能生成精美的小红书风格图片。

== 特性一览

- 📐 *标准比例*：3:5 小红书画布尺寸
- 🎨 *可配置主题*：字体、颜色、间距随心调
- 📝 *标题装饰*：自动美化的多级标题样式
- 🖼️ *封面组件*：一行代码生成精美封面
- 💻 *代码高亮*：深色背景的代码块样式
- ✨ *高亮文本*：小红书风格的黄色高亮

== 模板结构

```
typst-rednote/
├── lib.typ           # 统一导出入口
├── core/
│   └── constants.typ # 字体、颜色等常量
└── themes/
    ├── rednote.typ   # 主题函数
    ├── cover.typ     # 封面组件
    └── styles.typ    # 标题和代码样式
```

== 如何使用？

=== 基础用法

```typst
#import "lib.typ": *

#show: rednote-theme

= 标题
正文内容...
```

=== 自定义配置

```typst
#show: rednote-theme.with(
  font-family: serif-fonts,
  bg-color: rgb("#fff0f0"),
  accent-color: rgb("#ff6b6b"),
)
```

=== 添加封面

```typst
#cover(
  image-content: image("cover.png"),
  title: "你的标题",
  subtitle: "副标题",
  author: "@你的ID",
)
```

== 可配置参数

- `font-family`：字体族，默认无衬线
- `bg-color`：背景色，默认米白色
- `text-color`：文字颜色，默认深灰
- `highlight-color`：高亮色，默认浅黄
- `accent-color`：强调色，默认小红书红

= 写在最后

Typst 代表了排版工具的未来方向：简洁、快速、现代。

如果你厌倦了 LaTeX 的繁琐，又觉得 Word 不够专业，不妨试试 Typst。

这个小红书模板只是一个开始，希望能帮助更多人发现 Typst 的魅力。

== 相关链接

- Typst 官网：#link("https://typst.app")
- Tinymist：#link("https://github.com/Myriad-Dreamin/tinymist")
- 本模板仓库：#link("https://github.com/ri-nai/typst-rednote")

== 致谢

感谢以下项目的启发和帮助：

- #link("https://typst.app")[Typst] - 让排版变得简单
- #link("https://github.com/Myriad-Dreamin/tinymist")[Tinymist] - 优秀的 Typst LSP
- #link("https://github.com/typst/packages")[Typst Packages] - 丰富的社区生态

快来试试吧 ✨
