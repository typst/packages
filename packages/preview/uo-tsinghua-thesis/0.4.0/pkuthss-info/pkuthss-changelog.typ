#import "template.typ": *
#import "contributors.typ": *

#let issue(id) = link("https://github.com/lucifer1004/pkuthss-typst/issues/" + str(id), text(fill: purple)[\##id])

#set enum(indent: 0em)
#set list(indent: 0em)

#heading(level: 2, numbering: none, "2023-11-22")

+ 进一步优化了 `alwaysstartodd=true` 时的表现，现在插入的空白页不会显示页眉和页脚。

#heading(level: 2, numbering: none, "2023-11-20")

+ 修正了 `blind=true` 时，使用已经删除的 `textbf` 函数导致编译失败的问题（#issue(14)）。
+ 修正了 `alwaysstartodd=true` 时的处理逻辑（#issue(4)）。
+ 修正了 `v0.9` 版本下图表标题错误的问题。

#heading(level: 2, numbering: none, "2023-05-30")

+ 设置每一章的脚注编号从 1 开始。
  - 同时增加了脚注的示例。

#heading(level: 2, numbering: none, "2023-05-22")

+ 修正了 `booktab` 不能被正确引用的问题（#issue(12)）。

#heading(level: 2, numbering: none, "2023-05-06")

+ 修改了#strong[黑体]和#emph[斜体]前后空白的处理逻辑：
  - 现在如果希望前后不出现空白，应该直接使用 `#strong[粗体]` 或 `#emph[斜体]` ，而不是 `*粗体*` 或 `_斜体_`；
  - 因为语法解析的问题,使用 `_中文_` 时需要在前后加上空格才能被正确识别为 `emph`,但前后的空格也将被渲染出来。原来的解决方案是人为添加了 `h(0em, weak: true)`，但这又会导致在 `strong` 或 `emph` 块的结尾为西文字母时，手动插入的空格字符会被忽略；
  - 作者认为，目前的处理方式能够适应更多的需求。
+ 修正了#emph[斜体]对西文字母无效的问题（#issue(10)）。

#heading(level: 2, numbering: none, "2023-05-03")

+ 使用Typst `v0.3.0` 中提供的 `array` 类型的 `zip` 方法代替原 `helpers.typ` 中的 `zip` 函数。

#heading(level: 2, numbering: none, "2023-04-26")

+ 适配 Typst `v0.3.0`，将 `calc.mod` 改为 `calc.rem`。
+ 简化了 `show ref` 中的逻辑：
  - 现在提供了 `element`，可以少进行一次 `query`。

#heading(level: 2, numbering: none, "2023-04-20")

+ 不再给目录和索引页中填充空隙用的 `repeat([.])` 添加链接（参见#link("https://github.com/typst/typst/issues/758", text(fill: purple)[typst/typst\#758])）。

#heading(level: 2, numbering: none, "2023-04-19")

+ 修复了附录中没有一级标题时使用行间公式导致无法编译的错误（#issue(7)）。

#heading(level: 2, numbering: none, "2023-04-18")

+ 完整实现了盲评格式的论文（#issue(5)）：
  - 现在在 `blind = true` 时可以正确生成盲评格式的封面。
+ 修改了 `lengthceil` 辅助函数的逻辑：
  - 现在直接使用 `math.ceil` 函数，不再需要使用循环。

#heading(level: 2, numbering: none, "2023-04-16")

+ 增加了编译所需的字体文件（#contributors.TeddyHuang-00）。
+ 修正了论文标题样式（#contributors.TeddyHuang-00）：
  - 现在分为两行显示的论文标题样式将同样正确应用 `bold` 选项。
+ 增加了更多字号设置（#contributors.TeddyHuang-00）：
  - 对应 Word 中初号至小七的所有字号。

#heading(level: 2, numbering: none, "2023-04-14")

+ 适配了下一版本对 `query` 函数的改动：
  - 这会导致模板与 Typst `v0.2.0` 版本的不兼容。如果你使用的是 Typst `v0.2.0` 版本，请使用此前版本的模板。

#heading(level: 2, numbering: none, "2023-04-13")

+ 修正了 `alwaysstartodd` 为 `false` 时，摘要页不显示页码的错误。
+ 去除了版权声明中多余的空格。
+ 增加了致谢页和原创性声明页。
+ 增加了 `blind` 选项，设置为 `true` 时将生成盲评格式的论文。但目前只是去除了致谢和原创性声明，还需要进一步完善。

#heading(level: 2, numbering: none, "2023-04-12")

+ 将代码块的首选字体改为 `New Computer Modern Mono`：
  - Typst `v0.2.0` 版本内嵌了 `New Computer Modern` 字体，虽然并未同时提供 `New Computer Modern Mono`，这里将本模板的代码块字体相应进行了调整。`New Computer Modern Mono` 的字体文件现在在 `fonts` 目录中提供，同时删除了原来的 `CMU Typewriter Text` 字体文件。

#heading(level: 2, numbering: none, "2023-04-11")

+ 将代码块的首选字体改为 `CMU Typewriter Text`：
  - `CMU Typewriter Text` 的字体文件已经加入 `fonts` 目录，可以通过在运行 Typst 时使用 `--font-path` 参数指定 `fonts` 目录来使用。

#heading(level: 2, numbering: none, "2023-04-10")

+ 正确设置了语言类型：
  - 现在设置为 `zh`，之前错误设置为了 `cn`。
+ 正确设置了首行缩进：
  - 现在正文环境的首行缩进为 #2em。
+ 修正了引用图、表、公式等时在前后产生的额外空白：
  - 现在在 "@web" 等前后增加了 `h(0em, weak: true)`。
+ 修正了公式后编号的字体：
  - 现在设置为 #字体.宋体。
+ 修正了图题、表题等的字号：
  - 现在设置为 #字号.五号。
+ 修正了目录中没有对 `outlined` 进行筛选的问题：
  - 现在目录中只会显示 `outlined` 为 `true` 的条目。
+ 增加了对三线表的支持：
  - 现在可以通过 `booktab` 命令插入三线表。
+ 增加了对含标题代码块的支持：
  - 现在可以通过 `codeblock` 命令插入代码块。
+ 增加了插图索引、表格索引和代码索引功能：
  - 插图索引：使用 `listofimage` 选项启用或关闭；
  - 表格索引：使用 `listoftable` 选项启用或关闭；
  - 代码索引：使用 `listofcode` 选项启用或关闭。
+ 初步支持在奇数页开始的功能：
  - 使用 `alwaysstartodd` 选项启用或关闭。
