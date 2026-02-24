## FAQ

#### 1. 我不熟悉 LaTeX，可以使用本模板撰写论文吗？

可以。本模板基于 Typst 语法，支持类似 Markdown 的写作方式。您无需了解 LaTeX 或 Typst 的底层实现，只需按照模板结构编写内容即可。

#### 2. 我没有编程经验，可以使用本模板撰写论文吗？

可以。本模板的使用体验类似 Markdown，操作简便，适合无编程经验的用户。与 Word 相比，Typst 更适合进行学术论文的结构化写作。

#### 3. 为什么我的字体未能正常显示，而是一个个「豆腐块」？

出现此问题通常是由于本地未安装所需字体，**在 MacOS 下“楷体”显示异常尤为常见**。

请安装本项目 `fonts` 目录下的全部字体，其中已包含可免费商用的“方正楷体”和“方正仿宋”。安装完成后重新渲染即可。

您可以通过 `#fonts-display-page()` 命令显示字体渲染测试页面，以检查字体是否正常。

如仍有问题，可根据模板说明自定义字体。例如：

```typst
#let (...) = documentclass(
  fonts: (楷体: ((name: "Times New Roman", covers: "latin-in-cjk"), "FZKai-Z03S")),
)
```

先填写英文字体，再填写所需的「楷体」中文字体。

若无法找到所需字体，可能是由于**该字体变体（Variants）数量过少**，导致 Typst 无法识别该中文字体。

#### 4. 为什么 Typst 会出现大量字体相关的警告？

Typst 可能会出现较多字体相关的警告，这是由于 modern-ucas-thesis 模板中加入了许多不必要的 fallback 字体。您可以通过自定义字体来消除这些警告，建议按照“英文字体在前，中文字体在后”的顺序，依次传入“宋体”“黑体”“楷体”“仿宋”“等宽”等字体。

```typst
#let (...) = documentclass(
  fonts: (楷体: ((name: "Times New Roman", covers: "latin-in-cjk"), "FZKai-Z03S")),
)
```

#### 5. 为什么只有一个 thesis.typ 文件，而没有按章节拆分为多个文件？

这是因为 Typst 语法简洁、编译速度快，并且支持光标点击处的双向跳转功能。

语法简洁意味着即使所有内容集中在一个文件中，也能清晰分辨各部分内容。

编译速度快使得无需像 LaTeX 那样将内容分散到多个文件以提升编译效率。

双向跳转功能允许您直接在预览窗口定位并跳转到对应源码位置。

此外，单一源文件便于同步和分享。

当然，若您希望按章节拆分，Typst 也支持使用 `#import` 和 `#include` 语法导入或插入其他文件内容。您可以新建 `chapters` 文件夹，将各章节源文件放入其中，再通过 `#include` 语句插入到 `thesis.typ` 文件中。

#### 6. 目前 Typst 有哪些第三方包和模板？

您可以访问 [Typst Universe](https://typst.app/universe) 获取更多第三方包和模板。例如：

- 基础绘图：[cetz](https://typst.app/universe/package/cetz)
- 绘制带有节点和箭头的图表（如流程图等）：[fletcher](https://typst.app/universe/package/fletcher)
- 定理环境：[theorion](https://typst.app/universe/package/theorion)
- 伪代码：[lovelace](https://typst.app/universe/package/lovelace)
- 带行号的代码显示包：[zebraw](https://typst.app/universe/package/zebraw)
- 简洁的编号包：[numbly](https://typst.app/universe/package/numbly)
- 幻灯片与演示文档：[touying](https://typst.app/universe/package/touying)
- 相对定位布局包：[pinit](https://typst.app/universe/package/pinit)
- 数学单位包：[unify](https://typst.app/universe/package/unify)
- 数字格式化包：[zero](https://typst.app/universe/package/zero)
- LaTeX 数学公式支持：[mitex](https://typst.app/universe/package/mitex)
- 原生 Markdown 支持：[cmarker](https://typst.app/universe/package/cmarker)
- Markdown 风格的清单：[cheq](https://typst.app/universe/package/cheq)
- Markdown 风格的表格：[tablem](https://typst.app/universe/package/tablem)
