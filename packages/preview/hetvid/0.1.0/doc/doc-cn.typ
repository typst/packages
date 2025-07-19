#import "@local/hetvid:0.1.0": *
#import "@preview/metalogo:1.2.0": TeX, LaTeX // For displaying the LaTeX logo
#import "@preview/cetz:0.3.4": canvas, draw
#import "@preview/fancy-units:0.1.1": num, unit, qty



#show: hetvid.with(
  title: [Hetvid：一个轻量级笔记的Typst模板],
  author: "itpyi",
  affiliation: "大唐西京慈恩翻译学院",
  header: "说明文档",
  date-created: "2025-03-27",
  date-modified: "2025-04-28",
  abstract: [Hetvid是一个Typst模板，用于创作轻量级的笔记。本文是该模板的实例和说明文档，在介绍特性的同时，也会谈及作者的设计理念。],
  toc: true,
  body-font: ("TeX Gyre Termes", "Songti SC", "Source Han Serif SC"),
  math-font: ("TeX Gyre Termes Math"),
  lang: "zh",
)

// #show math.equation: set text(font: "Libertinus Serif")
// #set text(font: "Libertinus Math")

在本文中，以#text-muted[浅色字体]表示的内容是尚未实现的功能或特性。

= 调用本模板<sec-diaoyong>

#let version = "0.1.0"

调用模板的方法有如下三种：
- 将模板文件复制到工作目录下，在文档中通过
  ```typ
  #import "hetvid.typ": *
  ```
  调用。
- 将该项目复制到本地包目录下，在文档中通过
  #raw(
    block: true,
    lang: "typ",
    "#import \"@local/hetvid:"+version+"\": *"
  )
  调用。
#text-muted[
  - 在本模板发布之后，使用者或可通过
    #raw(
      block: true,
      lang: "typ",
      "#import \"@preview/hetvid:"+version+"\": *"
    )
    调用。
]
我们推荐使用第二种方法。

具体来说，本地包目录为`{data-dir}/typst/packages/local/`，其中`{data-dir}`为
- Linux系统：`$XDG_DATA_HOME`或`~/.local/share`；
- MacOS：`~/Library/Application Support`；
- Windows系统：`%APPDATA%`。 其中`%APPDATA`表示一个变量，一般为
  ```
  C:\Users\USERNAME\AppData\Roaming
  ```
  可在 cmd 中通过下述命令查看
  ```shell
  $ echo The value of ^%AppData^% is %AppData%
    The value of %AppData% is C:\Users\USERNAME\AppData\Roaming
  ```
  参见 https://superuser.com/questions/632891/what-is-appdata。
使用者可将该项目复制到本地包目录下。例如对于 Windows 系统，最终应存在如下文件夹：
#raw(
    block: true,
    "C:\Users\USERNAME\AppData\Roaming\typst\packages\local\hetvid\\"+version+"\\"
  )
此时使用者可通过`#import`命令来使用该模板。


引入模板后，通过如下代码即可指定相应信息。格式信息部分所有变量都给出了预设值，如果不需要修改这些默认值，则不用在调用时写出。
```typ
#show: hetvid.with(
  // 标题信息
  title: [Hetvid：一个轻量级笔记的Typst模板], 
  author: "itpyi",
  affiliation: "大唐西京慈恩翻译学院", 
  header: "说明文档", //出现在页眉左侧
  date-created: "2025-03-27", //预设为当天
  date-modified: "2025-04-28", //预设为当天
  abstract: [], //摘要，预设为空；当且仅当不为空时展示“摘要”章节
  toc: true, //是否显示目录，预设值为是，可设为 false 以关闭之

  // 语言，默认为英文，可更改为中文
  lang: "zh", //更改为中文

  // 下为格式信息，不修改则不用写出，有更改需求则写出需更改的项目即可
  // 纸张大小，默认为 a4
  paper-size: "a4",

  // 字体族，下为默认值
  body-font: ("New Computer Modern", "Libertinus Serif", "TeX Gyre Termes", "Songti SC", "Source Han Serif SC", "STSong", "Simsun", "serif"),
    raw-font: ("DejaVu Sans Mono", "Cascadia Code", "Menlo", "Consolas", "New Computer Modern Mono", "PingFang SC", "STHeiti", "华文细黑", "Microsoft YaHei", "微软雅黑"),
    heading-font: ("Helvetica", "Tahoma", "Arial", "PingFang SC", "STHeiti", "Microsoft YaHei", "微软雅黑", "sans-serif"),
    math-font: ("New Computer Modern Math", "Libertinus Math", "TeX Gyre Termes Math"),
    emph-font: ("New Computer Modern","Libertinus Serif", "TeX Gyre Termes", "Kaiti SC", "KaiTi_GB2312"),
    body-font-size: 11pt,
    body-font-weight: "regular",
    raw-font-size: 9pt,
    caption-font-size: 10pt,
    heading-font-weight: "regular",

  // 颜色
  link-color: link-color, //链接颜色
  muted-color: muted-color, //弱文字颜色，即本文档中浅色字体
  block-bg-color: block-bg-color, //代码块等的背景颜色

  // 段落格式
  ind: 1.5em, //首行缩进，英文默认为 1.5em，中文固定为 2em，无法在用户层面更改
  justify: true, //是否两端对齐，默认为是

  // 引用和参考文献格式，英文默认为 springer-mathphys，中文默认为 gb-7714-2015-numeric
  bib-style: (
    en: "springer-mathphys",
    zh: "gb-7714-2015-numeric"
  )
    
  // 定理编号的层级，默认为 1，此时定理在每个一级标题下编号，详后
  thm-num-lv: 1,
)
```


= 字体

== 基础设定

我们设定了几类字体，其预设值见#ref(<sec-diaoyong>)中的代码。预设值是一些字体族，一个字体族在 Typst 中实现为一个`array`类型的变量，包含了若干个字体。对于每一个字符，编译器将以字体族中支持该字符的第一个字体显示之。使用者在修改时应注意，我们希望使用专业的西文字体而非宋体来显示拉丁字母，因此，建议将只覆盖拉丁字母的字体放在前面，将中文字体放在后面。

几类字体如下:

/ 正文字体 (`body-font`): 主要用于正文。其大小和字重由`body-font-size`和`body-font-weight`给出。

/ 纯文本字体 (`raw-font`): 用于纯文本内容，例如代码等。预设值都是等宽字体。由于同字号的等宽字体大小与普通字体不一定匹配，我们提供了`raw-font-size`变量供使用者调整纯文本字体大小。

/ 标题字体 (`heading-font`): 用于文档标题和各节标题。预设值为无衬线字体（例如黑体），使标题与正文判然有别，且更具现代感。使用者也可将其修改为加粗的衬线字体。使用者可通过设定`heading-font-weight`来调整标题的字重。
/ 数学字体 (`math-font`): 用于数学公式。详见@sec:math-font。
/ 强调字体 (`emph-font`): 以拉丁字母书写的文本中，一般使用意大利体（_italic_，斜体）来表示强调，但斜体字形与汉字的特性天然互斥。因此，在汉字书写的文本中，一般使用更接近手写体的_楷体_来表示强调。我们通过`emph-font`来表示用于强调的中文字体。如果使用者希望修改预设值为一个新的字体族，注意应在字体族中先放入和正文字体（`body-font`）相同的拉丁字体。

另外，我们提供了`caption-font-size`参量以控制脚注的字号大小。

== 关于数学字体<sec:math-font>

从自洽的角度讲，我们建议将数学字体和正文中的西文字体设成同种字体（的数学变种和常规形态）。例如在公式环境中我们也时常遇到有文字意义的、用正体表示的字符，我们不希望这些字符在公式环境和正文中呈现为不同字体。又如公式中常出现数字，而正文中也会有数字，它们可能指代完全一样的对象，因此我们也不希望它们呈现为不同字体。支持数学公式的字体可参考 #link("https://tex.stackexchange.com/questions/425098/which-opentype-math-fonts-are-available")[Which OpenType Math fonts are available? (StackExchange)]。

模板预设的数学字体为 New Computer Modern Math，对应正文字体 New Computer Modern，这是 #LaTeX 的默认字体。本文档使用的正文字体是 TeX Gyre Termes，数学字体为与之匹配的 TeX Gyre Termes Math。该字体是 Times 字体的开源复刻版本，详见#link("https://zhuanlan.zhihu.com/p/506189673")[【字体的故事】Times New Roman（知乎）]。使用该字体的原因详见@sec:latin-cjk-spacing。

== New Computer Modern 的字重问题

模板预设使用的正文字体 New Computer Modern 和数学字体 New Computer Modern Math 可以选择两种字重，一种是我们预设使用的常规（regular， 400）字重，另一种是稍粗一些的 book（450）字重。使用者如想使用后者，将`body-font-weight`设为 450 即可。

New Computer Modern 字体的两种字重在 Typst 中的默认行为稍显怪异（0.13.1 版本）。假设使用者通过如下代码设置字体：
```typ
#set text(font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math") 
```
此时正文为 New Computer Modern 字体，字重默认为 regular (400)；公式为 New Computer Modern Math 字体，字重默认为 book (450)。因此公式会显得稍粗于正文。我们的模板通过对两种字体都明确写出字重避免了这一问题。

== 中西文之间的空格问题<sec:latin-cjk-spacing>

在一般的排版中，汉字与拉丁字母、阿拉伯数字之间会稍有分隔。Typst 通过`text`函数中的`cjk-latin-spacing`参量控制是否自动提供此分隔，其预设值为`auto`，即自动提供，使用者可将其设为`none`以关闭。

本模板开启了 Typst 提供的自动空格功能，但我们期待该功能具有一定的“稳定性”，即无论使用者的源码是否手动在中西文之间添加了空格，编译出的文档都有一个大小相同的空格。如下例：

#lizi[
  下面两行，第一行的源码没有添加空格，第二行的源码添加了空格。
  - 我花了3天时间写好了一个Typst模板。
  - 我花了 3 天时间写好了一个 Typst 模板。
]

我们希望自动空格具有上述稳定性的考虑如下：
- 使用者是否手动添加空格一般不是一个稳定的行为。
- Typst 的自动空格机制在汉字和数学公式、汉字和纯文本之间不起作用，如@li-raw-eq。
- 我们希望用`@{KEY}`而非`#ref(<{KEY}>)`来快捷地实现引用，但前者后面不能紧跟文字，因此不得不添加空格，详见@文献引用。为了排版行为的自洽，我们希望 Typst 添加的自动空格不受此手动空格的影响。

#lizi[下面两行，第一行的源码没有添加空格，第二行的源码添加了空格，第三行在纯文本两侧没有添加空格，在公式和汉字之间添加了空格。
  - 函数`sqrt(x)`计算了$x^(1\/2)$。
  - 函数 `sqrt(x)` 计算了 $x^(1\/2)$。
  - 函数`sqrt(x)`计算了 $x^(1\/2)$。
]<li-raw-eq>

很不幸，Typst 的自动空格机制并不总是具有这样良好的性质。开启自动空格时，中西文之间的空格是否受源码中使用者手动添加的空格的影响，取决于字体和标点压缩等多个因素。下@li-font1、@li-font2 展示了字体的影响，@li-compress 展示了标点压缩的影响。

#lizi[
  #set text(font: ("New Computer Modern", "Songti SC", "Source Han Serif SC"))
  将西文字体设置为 New Computer Modern，则手动添加空格会使空格增大。
  - 我花了3天时间写好了一个Typst模板。
  - 我花了 3 天时间写好了一个 Typst 模板。
]<li-font1>

#lizi[
  #set text(font: ("Libertinus Serif", "Songti SC", "Source Han Serif SC"))
  将西文字体设置为 Libertinus Serif，则手动添加空格不影响编译结果。
  - 我花了3天时间写好了一个Typst模板。
  - 我花了 3 天时间写好了一个 Typst 模板。
]<li-font2>

#lizi[
  下面两行，第一行的源码没有添加空格，第二行的源码添加了空格。可以看到，在压缩量较大时，手动添加空格与否对排版效果影响巨大。（如下效果方正书宋/思源宋体、TeX Gyre Termes 字体配置下可以呈现，其他字体呈现相同效果可能需要对文字略加增减。）
  - 我花了有近30天时间，夜以继日、焚膏继晷、废寝忘食地写好了一个Typst模板，以飨用者。
  - 我花了有近 30 天时间，夜以继日、焚膏继晷、废寝忘食地写好了一个 Typst 模板，以飨用者。
]<li-compress>

考虑到上述细节问题，我们建议讲究的使用者在中文文档中如下处理：
- 使用对手动空格不敏感的字体，例如 TeX Gyre Termes、Libertinus Serif 等。
- 在汉字和公式之间_总是_手动添加空格。
- 在汉字和纯文本之间_不_添加空格，因为我们在定制纯文本的背景时已经在背景到两侧字符之间、纯文本字符到背景边框之间放置了横向距离。
换言之，我们建议使用者在处理纯文本和公式时采用#ref(<li-raw-eq>)第三行的方式，并通过字体设置以容许在一般的汉字和拉丁字母之间比较随机地添加空格。至于标点压缩导致的对空格的敏感，我们暂时没有好的处理方案，讲究的使用者可通过控制自己的习惯（例如总是添加空格）来保持风格的统一。

= 标题

一级标题字号为 #qty[1.4][em]。一级标题上方有 #qty[2][em]（相对标题字体大小，下同）的竖直空间，下方有 #qty[1.2][em] 的竖直空间。

== 二级标题

二级标题字号为 1.2 em。二级标题上方有 #qty[1.5][em] 的竖直空间，下方有 #qty[1.2][em] 的竖直空间。

=== 三级标题

三级标题的字号大小为 1.1 em。三级标题上方有 #qty[1.5][em] 的竖直空间，下方有 #qty[1.2][em] 的竖直空间。

尽管 Typst 提供了更高级标题的功能，但模板作者强烈不推荐使用层级过多的标题，因此也未对其行为作特别订制。一般来说，100页以下的笔记甚至很少使用到三级标题。例如，Kitaev的文章#cite(<kitaevQuantumComputationsAlgorithms1997>)#cite( <kitaevAnyonsExactlySolved2006>)#cite(<kitaevAlmostidempotentQuantumChannels2025>)和Witten的讲义#cite(<wittenNotesEntanglementProperties2018>)#cite(<wittenMiniIntroductionInformationTheory2020>)#cite(<wittenIntroductionBlackHole2025>)都不使用三级标题。

= 段落和缩进<sec:par>

使用者可通过`justify: true | false`来调整是否两端对齐，预设为两端对齐。

关于首行缩进，本模板设置`lang="zh"`后，强制首行缩进2字符，使用者无法修改。与之相反，设置`lang="en"`时用户可通过`ind`来设置缩进量。模板作此设计的原因是现代中文排版的首行缩进习惯相对确定。

Typst 的首行缩进，可以通过`all`选项来决定是否缩进所有段落，但其行为实际上比较复杂，要之：
- 预设行为是`all: false`，此时对于一“段”，如果其前一个块级元素也是“段”，则缩进此段，反之不缩进。不是“段”的块级元素包括：
  - 空元素：于是块级元素（如块级引用、定理）的首段不缩进，合乎英文排版习惯，对于中文文档需要特殊处理。
  - 节标题：于是每节第一段不缩进，合乎英文排版习惯，对于中文文档需要特殊处理。
  - 行间公式：于是行间公式后不缩进，符合一般习惯，但如果一段以行间公式结尾，则需要特殊处理。
  - 块级引用：和行间公式类似，一般情况符合习惯，但如果某一段以引用结尾，则需特殊处理，详见@sec:quote。
  - 无序和有序列表：和行间公式类似，一般所谓段内元素出现，其后续内容之不缩进缩进符合习惯，但如果一段以列表结尾则需特殊处理。
  - 图：于是没有设置浮动的图后不缩进，仅当图作为段落内部元素出现时符合习惯，其他情况需要特殊处理，详见@sec:fig。
  - 其他块级元素，例如本模板使用的定理环境等。
  可以看出，这种设定一般来说符合习惯，但对于一些情况需要特殊处理。
- 设置`all: true`，此时缩进所有段落。对于中文模板，这样设置也有一些需要特殊处理的问题，例如行间公式、块级引用后总是分段，因此需要将它们放进盒子（box）里。
模板作者认为，行间公式作为 Typst 的原生语法，保持其简洁性非常重要，因此我们采取了第一种方案，即不设置全部缩进，而对需要缩进的段落特殊处理。

实现此特殊处理的方式非常简单：在需要缩进而默认未能缩进的段落前加一虚拟的段落，使其对编译器呈现为一个类型为“段”的块级元素，但在编译结果中并不显示出来。为此，我们提供了`par-vir`函数以实现这种虚拟的段落。在模板中，我们已经对中文情况下需要调整的地方添加了虚拟段落，因此大部分情况下用户无需担心缩进行为的问题。仅当用户缩写的段落以公式、引用、列表等非段块级元素结尾而其后内容需另起一段时，用户须插入
```typ
#par-vir
```
来实现正确的缩进。见下例。

#lizi[
  这一段以公式结尾，
  $ 1+1=2. $
  #par-vir
  我们希望另起一段。

  不加虚拟段落则我们无法在公式后另起一段，即使加了空行。
  $ 1+1=2. $

  我们未能另起一段。当然，这个空行是不影响竖直间距的。
]

= 引文<sec:quote>

模板订制了成段引文的行为：两侧缩进 4 个字符，内部首行缩进 2 字符，上下竖直距离为 #qty[1.5][em]，且后续内容默认绪接上段，首行不缩进。作为例子，我们引《封建论》的一节来展示效果。
#quote(attribution: [柳宗元《封建論》], block: true)[
  秦有天下，裂都會而為之郡邑，廢侯衛而為之守宰，據天下之雄圖，都六合之上游，攝制四海，運於掌握之內，此其所以為得也。不數載而天下大壞，其有由矣。亟役萬人，暴其威刑，竭其貨賄。負鋤梃謫戍之徒，圜視而合從，大呼而成群。時則有叛人而無叛吏，人怨於下，而吏畏於上，天下相合，殺守劫令而並起。咎在人怨，非郡邑之制失也。

  漢有天下，矯秦之枉，徇周之制，剖海內而立宗子，封功臣。數年之間，奔命扶傷之不暇。困平城，病流矢，陵遲不救者三代。後乃謀臣獻畫，而離削自守矣。然而封建之始，郡國居半，時則有叛國而無叛郡。秦制之得，亦以明矣。繼漢而帝者，雖百代可知也。
]
在一般的行文中，引文是作为段落内的元素出现的，因此模板默认引文之后不分段。如需分段，即使接续内容首行缩进，用户可插入一虚拟段落。

= 公式

行间公式默认编号，如
$ cal(F)f (k) = 1/(2 upright(pi) "i") integral dif k thin "e"^("i"k x) f(x), $<eq:fourier>
可引用其编号，如公式 (@eq:fourier)。在引用公式时，我们订制了引用命令`@{KEY}`只显示数字，前缀和括号需由使用者自行处理。原因是使用者可能在同一个文档中使用不同的前缀，例如公式 (1)、方程 (1)、求和 (1) 等，也可能同时引用多个公式，例如公式 (1-3) 等。与其用复杂的语法自动化各种可能的需求，不如留给使用者自己处理。

行间公式上下加有 #qty[1.2][em] 的竖直空间，这与 #LaTeX 的默认行为是一致的，否则过于拥挤，如下例。

#lizi[
  #show math.equation.where(block: true): set block(above: 0.5em, below: 0.5em)
  如果公式前后的文字都写满了一行，而公式和上下文字之间又没有空隙，如
  $ 1+1=2, $
  则视觉效果十分拥挤，我们不希望呈现这样的效果，因此给公式上下添加了空隙。
]

= 定理

由于现有定理包在细节上都不令人满意，作者开发了#link("https://github.com/itpyi/typst-dingli")[dingli 包]以实现定理环境。由于 dingli 包尚未发布，为了方便使用者，我们将包复制到了本模板下，即`dingli.typ`文件。其中我们定义了函数以实现定理、定义、引理、推论、例、证明等。本文的各示例已经使用了提供的`#lizi`函数。

我们的定理包对如下细节做了特别定制：
- 缩进问题。包括定理后下一段的缩进和中文文档中定理本身的缩进。
- 与上下文间距的问题。本模板设置为 #qty[1.5][em]。
- 编号层级问题。可以选择不按标题编号、按一级标题编号或按更高级标题编号。可通过`thm-num-lv: 0|1|...`调整。模板默认为按一级标题编号。

#dingli[这是一个定理。中文环境中，定理仍然首行缩进2个字符，并且不整体缩进，亦不顶格。]

这是定理后的一段，注意竖直间距。

#dingli([$s$-定理])[这是一个有名字的定理。注意定理名称和分隔符的处理。]

#dingli[这是一个定理。
定理前后的竖直间距设定为weak，故没有额外间距。]
#zhengming[这是一个证明。
$ 1 + 1 = 2 $
这竟然需要证明？

这是证明中的另一段。
]

还有其他类型，包括引理、推论、定义等。

#yinli[这是一个引理。]
#tuilun[这是一个推论。]
#dingyi[这是一个定义。]<def:example>

可以按照 typst 一般语法引用定理。如@def:example。


= 图表<sec:fig>

== 段内图表

我们有时会在行文中插入这样的图表：它们和上下文紧密相关，但没有太多独立的价值。于是我们希望它成为文段的一部分而非独立的、有图注的图表。对于这类图表，我们建议用
```typ
#align(center,image("{SOURCE}")) //图片
#align(center)[#table({...}] //表格
```
这样的语句来插入，而不使用`#figure`来插入，因为`#figure`主要被设计用来插入浮动体。我们也未对此时`#figure`的行为作特别订制。

== 独立图表

我们建议给所有独立的图表添加图注。对于此类图片，我们设定了三点不同于typst默认行为的特性：
+ 图注少于一行则居中，多于一行则居左。例见@fig:short-caption 和@fig:long-caption。其实现参考了 #link("https://sitandr.github.io/typst-examples-book/book/snippets/layout/multiline_detect.html")[Typst Examples Book: Multipline detection]。
+ 图注的标题（即图 1、表 1 一类文字）加粗显示。
+ 图注字号略小于正文，由`caption-font-size`给出。
+ 在图的上下插入 #qty[2][em] 的竖直空间，使其与正文稍有分隔。
其中3、4条是为了避免混淆图注和正文。

#figure(
  canvas({
    let N = 6
    let n = 4
    let space = 1
    let vspace = 2
    let offset = (N - n) / 2
    let r = 0.1
    import draw: *
    for i in range(N) {
      circle((i*space, 0), radius: r, fill: black)
      content((i*space, -r),[#i],anchor: "north", padding: 2pt)
    }
    for i in range(n) {
      rect((i*space + offset - r, vspace - r),(i*space + offset + r, vspace + r), fill: black)
      i = i + 1
    }
    let links = ((1,2,4,5),
                 (0,2,3,5),
                 (0,4),
                 (1,4))
    for j in (0,1,2,3) {
      for i in links.at(j) {
        line((i*space, 0), (j*space + offset, vspace))
      }
    }
    }),
  caption: [短图注居中。]
)<fig:short-caption>

#figure(
  canvas({
    let N = 6
    let n = 4
    let space = 1
    let vspace = 2
    let offset = (N - n) / 2
    let r = 0.1
    import draw: *
    for i in range(N) {
      circle((i*space, 0), radius: r, fill: black)
    }
    for i in range(n) {
      rect((i*space + offset - r, vspace - r),(i*space + offset + r, vspace + r), fill: black)
      i = i + 1
    }
    let links = ((1,2,4,5),
                 (0,2,3,5),
                 (0,4),
                 (1,4))
    for j in (0,1,2,3) {
      for i in links.at(j) {
        line((i*space, 0), (j*space + offset, vspace))
      }
    }
    }),
  caption: [若图注长于一行，则采取左对齐。这是一个双边图，上部有4个节点，下部有6个节点，每个上节点与偶数个下节点相连。]
)<fig:long-caption>

图后内容另成一段。首行仍缩进。由于字号差异和竖直分隔的存在，文字并不与长图注相混淆。

#figure(
  canvas({
    let N = 6
    let n = 4
    let space = 1
    let vspace = 2
    let offset = (N - n) / 2
    let r = 0.1
    import draw: *
    for i in range(N) {
      circle((i*space, 0), radius: r, fill: black)
    }
    for i in range(n) {
      rect((i*space + offset - r, vspace - r),(i*space + offset + r, vspace + r), fill: black)
      i = i + 1
    }
    let links = ((1,2,4,5),
                 (0,2,3,5),
                 (0,4),
                 (1,4))
    for j in (0,1,2,3) {
      for i in links.at(j) {
        line((i*space, 0), (j*space + offset, vspace))
      }
    }
    }),
  placement: top,
  caption: [此图固定在页面顶部。注意typst对浮动体的预设行为是，其编号取决于在源代码中的位置而非在生成的文件中的位置。]
)<fig:placement>

也可将图放在页面固定位置而非相对文字而言的固定位置。见@fig:placement。注意 typst 对浮动体的预设行为是，其编号取决于在源代码中的位置而非在生成的文件中的位置，这使得图片的编号合乎行文逻辑，是合理的，但是当同一文档里混有置于原位和浮动在页首或页尾的图片时，所得文档中图片的编号就可能显得错乱。对此我们的建议是，总是将图片置于页首或页尾。


== 图表中的文字

表格中文字大小等同于`body-font-size`。图片中，由于该模板首先考虑的用途是学术笔记，因此假设使用者会使用 #link("https://typst.app/universe/package/cetz/")[cetz] 画图。此时图中文字大小应以等于图注文字大小为宜。模板对此做了特别订制。见@fig:short-caption。

= 文献引用 <文献引用>

参考文献及其引用的格式由`bib-style`给出，该参量为字典类型，键为语言，值为参考文献格式。对中文（`zh`）的预设值为国标GB/T 7714-2015。注意国标格式引用时编号在上脚标的方括号内，与前后文字之间均不应有空格。此时应通过`#cite(<$KEY>)`而非`@$KEY`引用文献。
/ 正确示例: 引用文献#cite(<wittenIntroductionBlackHole2025>)后不该有空格.
/ 错误示例: 引用文献@wittenIntroductionBlackHole2025 后有空格. (使用`@$KEY`引用时, 若其后无空格则编译器无法正确识别`$KEY`.)

关于可选的参考文献格式，请参考官方文档#cite(<BibliographyFunctionTypst>)。

= 设计理念和文化

该模板得名于“因明”的梵语拉丁转写hetuvidyā。因明学是佛教的逻辑论辩之学，由玄奘法师引入中国。

我们对模板的审美追求是平正而清晰。即尽量合乎常见的排版规范，且不添加任何繁复的线条，以合乎惯例的缩进、空行来明白无误地区隔不同组分。

#set par(justify: false)

#bibliography("ref.bib")
