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

BTW, the theobox is based on the package [theorion](https://typst.app/universe/package/theorion) and the code display env is based on the package [zebraw](https://typst.app/universe/package/zebraw) .

## Main File Introduction (must)

`main.typ`

## Acknowledgement

This template is based on the following templates:
+ The style of cover and the doc in Typst template [LessElegantNote](https://github.com/choglost/LessElegantNote) ;
+ Great help from Typst template [Orange-book](https://github.com/flavio20002/typst-orange-template) and I realize the preface with the aid of [Official-Document](https://typst.app/docs) ;
+ The original Latex template [Elegantbook-magic-revision](https://github.com/Azure1210/elegantbook-magic-revision) .

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

公式盒子基于 [theorion](https://typst.app/universe/package/theorion) 文档代码显示环境基于 [zebraw](https://typst.app/universe/package/zebraw) 。

## 模板主文件说明 (必读)

`main.typ` 是模板的主文件。
+ 可以使用 `cover-environment` 来创建封面：
    + 参数 `style` 控制封面的具体样式，类型为整型（默认为 1），0.9. 版本暂时只有一种样式，未来会增加
    + 参数 `title` 控制文档的标题
    + 参数 `subtitle` 控制文档的副标题
    + 参数 `author` 控制文档的作者
    + 参数 `date` 控制文档日期（默认为文档构建日期）
    + 参数 `cover-image` 控制封面图像
+ **不可删除** 在封面环境后，需要使用 `#show: overall` 来规定文档页面的大小、文字段落的样式以及个人其他样式等；
+ 可以使用 `front-matter` 来创建前文环境，所有前文文档都需要被该环境包裹；
+ 可以使用 `my-outline` 来创建全文的目录；
+ **不可删除** 在开启正文写作时，需要使用 `#show: main-matter` 来开启正文文档的正常页码和章节计数等；
+ 可以使用 `part-page` 引入部分环境：
    + 参数 `title` 控制部分页面的标题
    + 参数 `chapter-reindex` 表示引入部分页是否会初始化章节序号（默认）
    + 参数 `img` 控制部分页的背景图（默认为 `none`）
    + 参数 `body` 控制部分页的内容（默认为 `none` 引入默认的部分页样式）
+ 可以使用 `appendix` 来创建附录环境，所有的附录页面需要被该环境包裹：
    + 参数 `affect-main` 控制附录页影响正文计数（默认为假）
    + 参数 `unify` 表示不同附录环境是否参与附录统一计数（默认为真）
+ 可以使用 `my-bibliography` 来创建参考文献环境。

## 鸣谢

本模板主要参考了以下几个模板（点击模板名称可跳转到原网址）：
+ Typst模板 [LessElegantNote](https://github.com/choglost/LessElegantNote) 中有关封面设计以及整体风格；
+ Typst模板 [Orange-book](https://github.com/flavio20002/typst-orange-template) 给予了本人最大的帮助，结合 [官方文档]("https://typst.app/docs) 的帮助实现了各种不同的标题样式以及前辅助页环境；
+ Latex模板 [Elegantbook-magic-revision](https://github.com/Azure1210/elegantbook-magic-revision) 中部分设计风格。

本模板所使用的所有图片都是上海博物馆、湖南博物馆、湖北博物馆的各种官方馆藏图片，如果侵犯了博物馆图片的隐私，可以联系本人，本人会立刻删除相关图片。







