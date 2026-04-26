#import "@preview/paddling-tongji-thesis:0.1.1": *

= 基本功能介绍 <introduction>

欢迎使用基于#link("https://typst.app")[Typst]的同济大学本科生毕业设计论文模板！

Typst是被广泛认为是#LaTeX 的 “进化版”，它保留了#LaTeX 的强大功能和灵活性，同时由于其编译时间短、易于上手等特点，也被认为是#LaTeX 的
“所见即所得（WYSIWYG，What You See Is What You Get）” 的实现。
Typst的设计理念是让文档的制作过程更加高效和愉快，同时保持专业级的输出质量。然而，由于Typst仍处于开发阶段，它的功能远没有#LaTeX 和基于#LaTeX 的C#TeX 那么丰富，因此在使用Typst时，我们可能需要一些额外的工作来完成一些特殊的排版需求。

在本节（@introduction）中，我们将介绍 Typst
的简单使用方法，尤其是中文排版的相关内容，并提供一些常用的排版示例。如果你对
Typst 的使用方法还不太熟悉，可以参考#link("https://typst.app/docs")[#emph[Typst的官方文档]]。

== 标题

Typst 用 `=` 来表示标题，其后紧跟标题内容。标题的级别由 `=` 的个数决定，`=` 的个数越多，标题级别越低。本模板支持的标题级别最高为
5，即
`=====`。

除了 `=`，Typst 还支持使用 #raw("#heading()", lang: "typ") 函数来表示标题，还可以自定义标题的样式。

下面是一个标题的例子：

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
      #heading(level: 2, outlined: false, "二级标题")

      二级标题是一种较为重要的标题级别，一般用于表示文章中的主要章节或主题。通常，它们会在上面添加分割线或加粗等效果，以突出其重要性。

      #heading(level: 3, outlined: false, "三级标题")

      相对于二级标题而言，三级标题是更加具体的标题级别，通常用于表示二级标题下的具体内容描述。它们的长度通常比二级标题短，与二级标题之间应有一定的间距。

      #heading(level: 4, outlined: false, "段落标题")

      段落标题是文章中比正文稍微具有一些重要性和突出性的内容，通常用加粗或斜体等方式来区别于正文。

      #heading(level: 5, outlined: false, "子段落标题")

      子段落标题是相对于段落标题更加细节化的内容，用于突出一段文字中的重点内容。通常采用斜体或加粗的方式表示。在一些正式的文献中，子段落标题的使用较少。
        ```, [
    #h(2em)
    #heading(level: 2, outlined: false, "二级标题")

    二级标题是一种较为重要的标题级别，一般用于表示文章中的主要章节或主题。通常，它们会在上面添加分割线或加粗等效果，以突出其重要性。

    #heading(level: 3, outlined: false, "三级标题")

    相对于二级标题而言，三级标题是更加具体的标题级别，通常用于表示二级标题下的具体内容描述。它们的长度通常比二级标题短，与二级标题之间应有一定的间距。

    #heading(level: 4, outlined: false, "段落标题")

    段落标题是文章中比正文稍微具有一些重要性和突出性的内容，通常用加粗或斜体等方式来区别于正文。

    #heading(level: 5, outlined: false, "子段落标题")

    子段落标题是相对于段落标题更加细节化的内容，用于突出一段文字中的重点内容。通常采用斜体或加粗的方式表示。在一些正式的文献中，子段落标题的使用较少。
  ],
)

值得注意的是，本模板中的标题样式已经根据同济大学的毕业论文要求进行了调整，因而可能与
Typst 的默认样式有所不同。

== 字体

与Markdown类似，在Typst中，粗体文字用 `*` 包裹，斜体文字用 `_` 包裹，等宽字体用 #raw("`") 包裹。例如：

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
In Typst, *bold*, _italic_ and `monospace` are supported.
  ```, [
In Typst, *bold*, _italic_ and `monospace` are supported.
])

在本模板中，我们将中文的粗体、斜体和等宽字体分别预设为 “#strong[黑体]”、“#emph[楷体]”
和 “#raw("仿宋")”。

请注意，因为语法解析的限制， `*...*`、`_..._` 和 #raw("`...`") 的前后有时需要空格分隔；而由于中文字体的特殊性，这样会导致额外的空格出现。因此，为了避免这种情况，我们可以使用 #raw("#emph[...]", lang: "typ") 函数来表示斜体，#raw("#strong[...]", lang: "typ") 函数来表示加粗，#raw("#raw(\"...\")", lang: "typ") 函数来表示等宽字体。例如：

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
      在中文环境中， *粗体*、_斜体_ 和 `等宽字体` 可能会导致额外的空格出现。而#strong[粗体]、#emph[斜体]和#raw("等宽字体")则不会。
        ```, [
  在中文环境中， *粗体*、_斜体_ 和 `等宽字体` 可能会导致额外的空格出现。而#strong[粗体]、#emph[斜体]和#raw("等宽字体")则不会。
  ],
)

此外，Typst 还支持使用 #raw("#[#set text(font: <some_font>); <some_text>]", lang: "typ") 命令来自定义字体。在本模板中，我们预置了方正字库中的以下字体，并设置了相应的别名供使用。

#table(
  columns: (auto, auto, 1fr), [
    #set align(center)
    #strong[字体]
  ], [
    #set align(center)
    #strong[别名]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], [
    #set align(center)
    #set text(font: font-family.song)
    宋体
  ], [
    #set align(center)
    #raw("font-family.song", lang: "typ")\
    或\
    #raw("songti", lang: "typ")
  ], [
    #set text(font: font-family.song)
    #h(2em)1900年前后，由埃里希 · 宝隆创办的 “同济医院” 正式挂牌。埃里希 ·
    宝隆医生看到医院里的医疗力量不足，计划在院内设立德文医学堂，招收中国学生，培养施诊医生。
  ], [
    #set align(center)
    #set text(font: font-family.hei)
    黑体
  ], [
    #set align(center)
    #raw("font-family.hei", lang: "typ")\
    或\
    #raw("heiti", lang: "typ")
  ], [
    #set text(font: font-family.hei)
    #h(2em)这个计划得到德国驻沪总领事以及德国政府高等教育司的支持。1906年，他们设立了一个支持医学堂开办的基金会，得到了德国
    “促进德国与外国思想交流的科佩尔基金会”
    的协助，筹集到一批医科书刊及新式的外科手术电动器械等物品。
  ], [
    #set align(center)
    #set text(font: font-family.kai)
    楷体
  ], [
    #set align(center)
    #raw("font-family.kai", lang: "typ")\
    或\
    #raw("kaiti", lang: "typ")
  ], [
    #set text(font: font-family.kai)
    #h(2em)1907年6月医学堂开学前，德国驻沪总领事克纳佩在上海不仅号召德国商人捐款，而且要求德国洋行向中国商人募捐。同时，费舍尔还要求中国官方的资助和支持，克纳佩利用在中德两国募来的捐款，成立了
    “为中国人办的德国医学堂基金会”。
  ], [
    #set align(center)
    #set text(font: font-family.fangsong)
    仿宋
  ], [
    #set align(center)
    #raw("font-family.fangsong", lang: "typ")\
    或\
    #raw("fangsong", lang: "typ")
  ], [
    #set text(font: font-family.fangsong)
    #h(2em)董事会由18人组成，主要成员有：三个德医公会元老：宝隆、福沙伯（第二任校长）、福尔克尔；三名德国商人：莱姆克、米歇劳和赖纳；两名中国绅商：朱葆三（沪军都督府财政部长及上海商务会会长，大买办）、虞洽卿（荷兰银行买办）；总领事馆的副领事弗赖海尔
    · 冯 · 吕特等。
  ], [
    #set align(center)
    #set text(font: font-family.xiaobiaosong)
    小标宋
  ], [
    #set align(center)
    #raw("font-family.xiaobiaosong", lang: "typ")\
    或\
    #raw("xiaobiaosong", lang: "typ")
  ], [
    #set text(font: font-family.xiaobiaosong)
    #h(2em)埃里希 ·
    宝隆医生被正式推选为董事会总监督（董事长）兼学堂首任总理（校长），负责学堂的管理。医学堂的校址设在同济医院对面的白克路（今凤阳路415号上海长征医院内）。1907年10月1日德文医学堂举行了开学典礼。
  ], [
    #set align(center)
    #set text(font: font-family.xihei)
    细黑
  ], [
    #set align(center)
    #raw("font-family.xihei", lang: "typ")\
    或\
    #raw("xihei", lang: "typ")
  ], [
    #set text(font: font-family.xihei)
    #h(2em)1923年3月17日北洋政府教育部下达第108号训令，批准同济工科
    “改为大学”。学校随即召开董事会议，将学校定名为 “同济大学”。1923年3月26日，学校以
    “同济大学董事会” 名义呈文北洋政府教育部，称 “经校董会议定名称为同济大学”。
  ],
)

我们还可以使用 #raw("#underline[]", lang: "typ") 命令来表示下划线，例如：

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
#underline[中Lorem文ipsum中dolor文]
  ```, [
  #underline[中Lorem文ipsum中dolor文]
])

=== 生僻字支持

由于本模板使用的是方正字库GBK字体，我们可以直接使用生僻字#footnote[此处的生僻字指：GBK编码中有，但GB2312编码中没有的字。]：丂丄丅丆丏丒丗丟丠両丣並丩丮丯丱丳丵丷丼乀乁乂乄乆乊乑乕乗乚乛乢乣乤乥乧乨乪乫乬乭乮乯。
