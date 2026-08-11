# English Introduction of the Template

This template realize an Elegant-like template.

## Structure of the Project (Must)

```
- library
    - function.typ // the function created by the author of the template
    - template.typ // the template created by the author of the template
    - theobox.typ // the theobox function created by the author of the template
- template
    - content // the chapter of the doc to be included
    - custom
        - custom-config.typ // Your configuration, do not change the filename.
        - custom-func.typ // Your function, do not change the filename.
        - parameter.typ // The parameter of the doc, do not change the filename.
    - main.typ // the main typ file
    - refs.bib
```

BTW, the theobox is based on the package #link(https://typst.app/universe/package/theorion)[theorion] and the code display env is based on the package #link(https://typst.app/universe/package/zebraw)[zebraw].

## Main File Introduction (must)

`main.typ`

## Acknowledgement

This template is based on the following templates:
+ The style of cover and the doc in Typst template #link("https://github.com/choglost/LessElegantNote")[LessElegantNote];
+ Great help from Typst template #link("https://github.com/flavio20002/typst-orange-template")[Orange-book] and I realize the preface with the aid of #link("https://typst.app/docs")[Official-Document]
+ The original Latex template #link("https://github.com/Azure1210/elegantbook-magic-revision")[Elegantbook-magic-revision].

The pictures are from museums in China, if there are some piracy problems, I will delete them.




















# 中文版文档说明

本模板实现了类 Elegant 的模板。

## 项目文件结构 (必读)

```
- library
    - function.typ // 模板作者实现的函数
    - template.typ // 模板作者创建的模板文件
    - theobox.typ // 模板作者创建的公式盒子
- template
    - content // 文档章节内容保存目录
    - custom
        - custom-config.typ // 使用模板的人的个人设置 不要修改文件名
        - custom-func.typ // 使用模板的人的个人函数 不要修改文件名
        - parameter.typ // 使用模板的人的参数设置 不要修改文件名
    - main.typ // 模板主文件
    - refs.bib
```

公式盒子基于 #link(https://typst.app/universe/package/theorion)[theorion] 文档代码显示环境基于 #link(https://typst.app/universe/package/zebraw)[zebraw].

## 模板主文件说明 (必读)

`main.typ`

## 鸣谢

本模板主要参考了以下几个模板（点击模板名称可跳转到原网址）：
+ Typst模板 #link("https://github.com/choglost/LessElegantNote")[LessElegantNote] 中有关封面设计以及整体风格；
+ Typst模板 #link("https://github.com/flavio20002/typst-orange-template")[Orange-book] 给予了本人最大的帮助，结合#link("https://typst.app/docs")[官方文档]的帮助实现了各种不同的标题样式以及前辅助页环境；
+ Latex模板 #link("https://github.com/Azure1210/elegantbook-magic-revision")[Elegantbook-magic-revision] 中部分设计风格。

本模板所使用的所有图片都是上海博物馆、湖南博物馆、湖北博物馆的各种官方馆藏图片，如果侵犯了博物馆图片的隐私，可以联系本人，本人会立刻删除相关图片。







