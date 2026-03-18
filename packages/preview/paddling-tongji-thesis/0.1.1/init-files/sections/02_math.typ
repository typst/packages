#import "@preview/paddling-tongji-thesis:0.1.1": *

= 数学 <math>

在本节（@math）中，我们展示各种数学符号和环境的使用。

Typst 具有特殊的语法和库函数来排版数学公式，与#LaTeX 相似，但差别也很大。

数学公式可以与文本并列显示，也可以作为单独的块显示。如果数学公式的开头和结尾至少有一个空格（如 #raw("$ x^2 $", lang: "typ")），则会被排版到单独的块中。

毕业论文规范规定，公式应另起一行居中排版。公式后应注明编号，按章顺序编排，编号右端对齐。若你想了解更多数学排版的内容，可以参考#link("https://typst.app/docs/reference/math/")[#emph[Typst的数学模式文档]]。

== 变量

在Typst的数学模式中，单个字母总是按原样显示。而多个字母则被解释为变量和函数。要逐字显示多个字母，可以将它们放在引号中；要访问单字母变量，可以使用#link(
  "https://typst.app/docs/reference/scripting/#expressions",
)[#emph[`#`语法]]。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
$ A = pi r^2 $
$ "area" = pi dot "radius"^2 $
$ cal(A) :=
    { x in RR | x "is natural" } $
#let x = 5
$ #x < 17 $
  ```, [
  $ A = pi r^2 $ <pir2>
  $ "area" = pi dot "radius"^2 $
  $ cal(A) :=
  { x in RR | x "is natural" } $
  #let x = 5
  $ #x < 17 $
])

== 数学符号

Typst数学模式提供了像圆周率（$pi$）、点号（$dot$）或实数集（$RR$）等众多#link("https://typst.app/docs/reference/symbols/sym/")[#emph[符号]]。许多数学符号有不同的变体。你可以通过对符号应用#link("https://typst.app/docs/reference/symbols/symbol/")[#emph[修饰符]]来选择不同的变体。Typst
还识别许多像 $=>$ 这样的 “速记序列”，这些序列可以近似表示一个符号。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
$ x < y => x gt.eq.not y $
  ```, [
  $ x < y => x gt.eq.not y $
])

按照国标 GB/T 3102.11—1993《物理科学和技术中使用的数学符号》，微分符号 $dif$ 应使用直立体。除此之外，数学常数也应使用直立体，如圆周率 $pi$、自然对数的底 $ee$、虚数单位 $ii$、$jj$ 等。

== 换行

公式也可以包含换行。每行可以包含一个或多个对齐点（`&`），然后进行对齐。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $
  ```, [
  $ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $
])

== 函数调用

数学模式支持特殊的函数调用，无需使用 `#` 号前缀。在这些 “数学调用”
中，参数列表的工作方式与代码中略有不同：

- 在其中，Typst 仍然处于
  “数学模式”。因此，你可以直接在其中编写数学公式，但需要使用 `#` 语法来传递代码表达式（字符串除外，字符串在数学语法中可用）。
- Typst支持位置参数和命名参数，但不支持尾随内容块和参数扩展。
- Typst还提供了二维参数列表的额外语法。分号（`;`）用于分隔行，逗号（`,`）用于分隔列。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
$ frac(a^2, 2) $
$ vec(1, 2, delim: "[") $
$ mat(1, 2; 3, 4) $
$ lim_x =
    op("lim", limits: #true)_x $
  ```, [
  $ frac(a^2, 2) $
  $ vec(1, 2, delim: "[") $
  $ mat(1, 2;3, 4) $
  $ lim_x =
  op("lim", limits: #true)_x $
])

要在数学调用中逐字书写逗号或分号，可以用反斜线将其转义。另一方面，冒号只有在前面直接出现标识符时才会被特殊识别，因此在这种情况下要逐字显示冒号，只需在冒号前插入空格即可。

== 对齐

当方程式包含多个对齐点（`&`）时，这将创建交替右对齐和左对齐的列块。在下面的示例中，表达式 `(3x + y) / 7` 是右对齐的，而 `= 9`
是左对齐的。单词 `given` 也是左对齐的，因为 `&&` 在一行中创建了两个对齐点，使对齐方式交替两次。`& &` 和 `&&`
的行为方式完全相同。与此同时，`multiply by 7` 是左对齐的，因为只有一个 `&` 在它之前。每个对齐点简单地交替右对齐/左对齐。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
$ (3x + y) / 7 &= 9 && "given" \
  3x + y &= 63 & "multiply by 7" \
  3x &= 63 - y && "subtract y" $
  ```, [
  $ (3x + y) / 7 &= 9      && "given" \
  3x + y       &= 63     & "multiply by 7" \
  3x           &= 63 - y && "subtract y" $
])

