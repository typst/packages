#import "../../library/template.typ": *

= 参数说明

== 排版参数说明

在library文件夹内的parameter.typ文件内可以调节各种各样的参数，参数基本都有注释，这里对一些影响模板结构的做一些特别的说明。

#zebraw[
  ```typ
  /* 16k版面属性 */
  #let page_16k = (
    width: 185mm, // 页面宽度
    height: 260mm, // 页面高度
    mar_t: 23mm, // 上页边距
    mar_b: 17mm, // 下页边距
    mar_x: 20mm, // 左右页边距
  )
  ```
]

模板按照正度16开的纸张大小设计，左右页边距相等，方便电子设备阅读。

#zebraw[
  ```typ
  /* 16k前辅助页属性 */
  #let front_16k = (
    index: false, // 前辅助页序号显示
    pagenum: true, //前辅助页页码显示
    outline: true, // 前辅助页目录显示
    header: false, // 前辅助页页眉显示
  )
  ```
]

index控制辅助页是否显示序号I,II,III，pagenum控制辅助页是否显示页码，outline控制是否在目录显示前言的章节（不管怎么调控都不会显示次级标题），header控制辅助页是否显示页眉。

#zebraw[
  ```typ
  #let lans = (
    lan: "zh", // 语言
    reg: "cn", // 地区
    ptn: "第一部分", // 正文部分样式
    chn: "第一章", // 正文一级标题样式
    apn: "附录A", // 附录一级标题样式
    pc: [前], // 引用前辅助页一级标题前缀
    ch: [章], // 引用正文一级标题前缀
    ap: [附], // 引用附录一级标题前缀
    eq: auto, // 公式前缀
    im: auto, // 图片前缀
    tb: auto, // 表格前缀
    ci: "gb-7714-2015-numeric", // 参考文献样式
    axmn: [公理], // 公理显示名称
    defn: [定义], // 定义显示名称
    lawn: [定律], // 定律显示名称
    thon: [定理], // 定理显示名称
    lemn: [引理], // 引理显示名称
    pstn: [假设], // 假设显示名称
    coon: [推论], // 推论显示名称
    prpn: [命题], // 命题显示名称
    exen: [练习], // 练习显示名称
    exan: [例子], // 例子显示名称
    cmmn: [注], // 注解显示名称
    sep: [：],
  )
  ```
]

这个参数是语言参数，可以根据自己的需求修改语言样式。有关ptn、chn、apn具体修改方式，请看官方文档有关numbering的说明。

#zebraw[
  ```typ
  /* 衬线字体与无衬线字体 */
  #let serif_font = (
    (name: "Source Han Serif SC", covers: "latin-in-cjk"),
    "Source Han Serif SC"
  ) // 衬线字体
  #let sans_font = (
    (name: "Source Han Sans SC", covers: "latin-in-cjk"),
    "Source Han Sans SC"
  ) // 无衬线字体
  #let code_font = (
    (name: "Consolas", covers: "latin-in-cjk"),
    "Source Han Sans SC"
) // 代码字体
  ```
]

这个是有关字体的设置。

#zebraw[
  ```typ
  #let heading1 = (
    size: 18pt, // 一级标题字号
    font: sans_font, // 一级标题字体
    weight: "regular", // 一级标题字重
    image: true, // 一级标题页头图（推荐图片尺寸：页面宽度 x 页面高度*0.3）
    part: false, // 部分页是否影响章节计数
    appendix: true, // 附录独立计数器
    index: false, // 正文公式图像表格统一计数
  )
  ```
]

image控制文档是否显示头图，如果为假，那么即便使用\#set_heading_image函数，也不会显示头图。本模板每个章节前都必须使用\#set_heading_image，头图不继承。part表示部分页是否会影响章节计数，如果为真，结构会变成
- 第一部分
  - 章节1
  - 章节2
- 第二部分
  - 章节1
  - 章节2
否则章节会全文按顺序继承；appendix如果为真那么所有附录统一一个计数器，如果为假，那么每一个独立的appendix环境都独立计数；index表示正文所有公式图像统一计数，这个可以防止部分影响章节计数时，公式序号重复的问题。

#zebraw[
  ```typ
  /* 目录样式 */
  #let outltext = (
    depth: 3, // 目录层级
    partsize: 11pt, // 部分字号
    partfont: sans_font, // 部分字体
    partcolor: black, // 部分颜色
    partbox: true, // 部分底栏显示
    partboxcolor: gray, // 部分底栏颜色
    level1size: 10.5pt, // 一级标题字号
    level1font: sans_font, // 一级标题字体
    level1color: black, // 一级标题颜色
    level2size: 10.5pt, // 二级标题字号
    level2font: serif_font, // 二级标题字体
    level2color: black, // 二级标题颜色
    level3size: 9pt, // 三级标题字号
    level3font: serif_font, // 三级标题字体
    level3color: black, // 三级标题颜色
    othersize: 10.5pt, // 页码，填充字号
    otherfont: serif_font, // 页码，填充字体
    fill: "·", // 标题和页码之间的填充
    selfoutl: true, // 部分页是否显示次级目录
    selfdepth: 2, // 部分独立页目录层级
    selfspacing: 1em, // 部分独立页目录行距
    selflevel1size: 10.5pt, // 部分独立页目录一级标题字号
    selflevel1font: sans_font, // 部分独立页目录一级标题字体
    selflevel1color: black, // 部分独立页目录一级标题颜色
    selfleveln1size: 10.5pt, // 部分独立页目录非一级标题字号
    selfleveln1font: serif_font, // 部分独立页目录非一级标题字体
    selfleveln1color: black, // 部分独立页目录非一级标题颜色
  )

  #outltext.insert("allind", outltext.level1size * 5) // 目录页一级标题前缀盒子大小
  #outltext.insert("level4ind", outltext.level1size * 1) // 目录页一级标题前缀盒子大小
  #outltext.insert("selfallind", outltext.selflevel1size * 4) // 部分独立页目录一级标题前缀盒子大小
  ```
]   

这个是有关目录样式的修改，depth表示总目录的显示层级（最多4层）。partsize到partboxcolor表示了总目录部分页的显示样式。allind表示了总目录页一级标题前缀所在盒子所占空间的大小。selfoutl表示全体部分页是否会显示标题，selfallind表示部分页的前缀盒子大小。本模板将一二级标题的前缀单独放在一个盒子里，如果发生不正常的换行，可以调大盒子的大小。

= 函数说明

#zebraw[
  ```typ
  #show: overall.with() // 总体样式，不能删除，否则不能正常显示全文
  ......
  #my_outline()
  #show: main_matter.with() // 正文环境，不能删除，否则不能正常显示正文
  ```
]

overall标示了全文的开始，mainmatter标示了正文的开始，my_outline可以实现全文的总目录。

#zebraw[```typ
  #front_matter[
    #include "content/pre.typ"
  ]
```]

类似以上代码，把所有的文件放入front_matter这个函数里面，可以把对应章节放在前辅助页。

#zebraw[
  ```typ
  /* 部分环境（注意，这里会导致增加部分标签） */
  /* chap_reindex 表示引入部分页是否初始化章节的序号 */
  #let part_page(title, chap_reindex: heading1.part, outl: outltext.selfoutl, img: none)
  ```
]

本模板允许用户创建部分页，chap_reindex可以自由修改真假值，和parameter文件不同，以影响章节计数。outl表示部分页是否会显示部分的目录。

#zebraw[
  ```typ
  /* 附录环境 */
  /* in_ main 表示附录页是否在正文内部，在正文内部要回复正文标题序号； */
  /* count 表示一个独立的附录计数器 */
  #let appendix(body, in_main: false, count: true) = {...}
  ```
]

本模板默认用户把附录放在文档末尾，因此不回复章节计数，如果要在正文中插入附录，可以把false改成true；但是模板会统一附录序号，这个符合大部分书籍惯例。