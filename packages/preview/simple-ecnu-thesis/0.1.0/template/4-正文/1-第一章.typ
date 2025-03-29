#import "mod.typ": *
#show: style

= 绪论

== Typst 基本的语法

=== 强调和斜体

强调使用 `*` 包围内容，
// 或使用函数 `#strong()[content]`，
比如 Artificial Neural Network 中的 *Artificial* 是人工的意思；
而 #strong()[Neural] 是神经元的意思。

用斜体使用`_` 包围内容，
// 或使用函数 `#emph()[content]`，
比如 Neural Network 中的 _Network_ 是网络的意思

== 列表的使用

=== 无序列表

如果想使用无序列表，
可以使用 `-` 号，
比如我想列举世界公认的三大数学家：

- 阿基米德
- 艾萨克·牛顿
- 约翰·卡尔·弗里德里希·高斯

=== 有序列表

如果是有序列表，
可以使用 `+` 号，
比如世界上最高的三座山峰：

+ 珠穆朗玛峰
+ 乔戈里峰
+ 干城章嘉峰

== 文献的引用

如何引用文献？

- 单文献：引用 @vaswani2017attention
- 单文献：引用 #ref(<vaswani2017attention>)
- 多文献：引用 @vaswani2017attention @he2016deep
- 多文献：引用 @vaswani2017attention @he2016deep @szegedy2015going

