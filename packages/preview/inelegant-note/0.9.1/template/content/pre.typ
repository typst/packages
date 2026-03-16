#import "@preview/inelegant-note:0.9.0": *

= 这个是前言

== 模板参考

本模板主要参考了以下几个模板（点击模板名称可跳转到原网址）：
+ Typst模板 #link("https://github.com/choglost/LessElegantNote")[LessElegantNote] 中有关封面设计以及整体风格；
+ Typst模板 #link("https://github.com/flavio20002/typst-orange-template")[Orange-book] 给予了本人最大的帮助，结合#link("https://typst.app/docs")[官方文档]的帮助实现了各种不同的标题样式以及前辅助页环境；
+ Latex模板 #link("https://github.com/Azure1210/elegantbook-magic-revision")[Elegantbook-magic-revision] 中部分设计风格；

== 设计参考

版式参考了电子工业出版社2020年韩绍强编著的《InDesign CC 设计与排版实用教程》的附录，以及相当多的专业教材，这里不做列举。

== 其他帮助

尤其感谢#link("https://typst-doc-cn.github.io/guide/")[typst非官方中文网]提供的各种很有帮助的资料以及对应群聊的群友，没有他们的帮助和支持，这个模板不会出现。

== 图片版权

本模板所使用的所有图片都是上海博物馆、湖南博物馆、湖北博物馆的各种官方馆藏图片，如果侵犯了博物馆图片的隐私，可以联系本人，本人会立刻删除相关图片。本人也承诺，本模板不做任何商业用途，仅仅用于教育用途以及科研用途。

== 前辅助页环境的实现

#zebraw[```typ
  #front_matter[
    #include "content/pre.typ"
  ]
```]

类似以上代码，把所有的文件放入front_matter这个函数里面。
