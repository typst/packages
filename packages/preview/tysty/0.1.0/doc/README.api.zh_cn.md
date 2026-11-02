# API 参考

[使用示例](../README.md#usage) · [English](README.api.en.md)

## 开始使用

使用 Typst 0.15.1 或更高版本，并安装 `@preview/tysty:0.1.0`。导入包、选择模板，然后通过 `entry` 创建文档：

```typst
#import "@preview/tysty:0.1.0": *
#show: template
#entry(id: "home", title: [Notebook], authors: ())[
  #mkcover()
  Notebook content.
]
```

使用 `typst compile --root . notebook.typ` 编译；导出 HTML 时添加 `--features html` 并将输出指定为 `notebook.html`。

## 文档与元数据

`entry(..fields, content)` 声明元数据并渲染文档标题和正文，将 ID 注册为引用目标，并加入阅读顺序。需要封面时，在正文中调用 `mkcover()`。一次编译中的文档 ID 必须唯一。

省略 `parent-id` 时，`entry` 会继承当前文档的 ID；没有当前文档时则创建语义根节点。显式设置 `parent-id: auto` 总是将文档设为自身的根节点。`entry` 不会恢复先前的当前文档；请用 `embed` 保存并恢复上下文。父子关系与标题的视觉嵌套相互独立。

| 字段 | 类型 | 默认值与含义 |
| --- | --- | --- |
| `id` | `str` | 必填且唯一 |
| `title` | `content` | 必填，例如 `[标题]` |
| `authors` | `array` | 必填；字符串或作者记录，可为空数组 |
| `parent-id` | `str` 或 `auto` | `entry` 默认继承；显式 `auto` 表示根节点 |
| `file-path` | `str` | `"(no link (uri))"`；拼接到文件链接前缀 |
| `date` | `datetime` | `datetime.today()`；当天日期 |
| `lang` | `str` | `"en_US"` |
| `version` | `str` | `"0.0.1"` |
| `doi` | `str` | `"(none)"` |
| `abstract`, `description` | `str` | `""`；空字符串 |
| `keywords` | 字符串数组 | `()` |
| `license` | `str` | `"apache-v2"` |
| `cover_image` | `img` | `img.null` |
| `category` | `category` | `category.null` |
| `tags` | 标签记录数组 | `()` |
| `tlb` | `dictionary` | `(:)`；保存的元数据 |

`entry` 接受上表列出的元数据字段，不支持 `new-page` 等渲染选项。可选字段仍需符合声明的类型，不能用 `none` 替代其默认值。

`meta(..fields)` 是底层声明 API，接受同样的元数据字段。它发布元数据并选择当前文档，但不渲染或注册标题。与 `entry` 不同，省略 `parent-id` 表示根节点。使用 `entry` 可以一次完成文档声明与渲染。

## 自动渲染

这些辅助函数可用于共用的 PDF、HTML 和 bundle 源文件，会根据调用位置自动选择对应的渲染行为。

| API | 行为 |
| --- | --- |
| `template(body, ..options)` | 通过 `#show: template` 使用，选择 PDF、单文件 HTML 或 bundle 包装器，选项传递给对应包装器。 |
| `embed(body, offset: …)` | 保存并恢复当前文档；PDF 默认增加标题层级，HTML 和 bundle 默认不增加。 |
| `mkcover()` | 渲染当前文档封面，不新增引用目标或阅读顺序项。 |
| `mkoutline(..args)` | PDF 和单文件 HTML 自动生成标题目录；bundle 自动生成带页面链接的文档树，包括在 bundle 页面内调用时。 |
| `render-children(title)` | 列出具有已渲染引用目标的直接子文档。 |
| `render-tags(tree)` | 渲染注册的标签树及直接关联到各节点的已渲染文档。 |
| `set-base(p)` | 设置文档 `file-path` 链接使用的字符串前缀。 |

`mkoutline()` 使用默认目录标题，可通过 `mkoutline(title: [目录])` 自定义。PDF 和单文件 HTML 接受 Typst 的 `outline` 选项；bundle 接受 `title` 和 `depth`，但目前 bundle 的 `depth` 不限制文档树层级。

```typst
#import "@preview/tysty:0.1.0": *
#show: template
#set-base("https://example.com/notes/")
#entry(id: "parent", title: [Parent], authors: (), file-path: "parent.typ")[
  #mkoutline()
  #embed[
    #entry(id: "child", title: [Child], authors: ())[
      Child content.
    ]
  ]
  #render-children[Children]
]
```

单独源文件可使用 `#embed(include "child.typ")`。生成 bundle 时，应将创建页面的 `entry` 调用放在其他页面正文之外，参见 README 中的静态站点示例。

## 引用与查询

| API | 返回值或行为 |
| --- | --- |
| `mkindex(label, content)` | 显示内容并在当前位置注册唯一字符串标签；文档 ID 已占用相应标签。 |
| `lookup(label, content)` | 渲染链接并记录反向引用，存在当前文档时记录其 ID。支持前向引用，未知目标会导致编译失败。 |
| `indexers()` | 上下文查询，按文档顺序返回数组；记录包含 `label`、`loc`、`content` 和 `lookup(content)` 方法。 |
| `backlinks(label)` | 上下文查询，返回含 `loc`、`content`、`ctx` 的引用数组；`ctx.variant` 为 `"doc"`（ID 在 `ctx.payload` 中）或 `"null"`。 |

```typst
#import "@preview/tysty:0.1.0": *
#show: template
#entry(id: "note", title: [Note], authors: ())[
  #mkindex("term")[A term]
  #lookup("term")[See the term]
  #context {
    let refs = backlinks("term")
    [References: #refs.len()]
    for item in indexers() {
      par((item.lookup)(item.content))
    }
  }
]
```

直接调用索引记录的 `lookup` 只创建普通链接，不记录反向引用。导航链接同样不记录反向引用。

## 作者、图像与分类

`(author.new)(name: ..., affiliation: ..., email: ..., home: ..., orcid: ...)` 需要全部五个字符串字段，允许空字符串。`authors` 也接受纯字符串姓名。

```typst
#let alice = (author.new)(name: "Alice", affiliation: "Lab", email: "", home: "", orcid: "")
#let bob = (author.update)(alice, name: "Bob")
#let make-author = (author.with)(affiliation: "Lab", email: "", home: "", orcid: "")
#let carol = make-author(name: "Carol")
```

| 图像值 | 含义 |
| --- | --- |
| `(img.path)("cover.png")` | 图像路径 |
| `(img.data)(read("cover.png", encoding: none))` | 原始图像字节 |
| `img.null` | 无图像；它是值而非构造函数 |

将这些值作为 `entry` 的 `cover_image` 参数，并在正文中调用 `mkcover()`。

所有分类构造函数使用命名字段。除 `volume` 和 `issue` 为整数外，字段均为字符串。每个构造函数都要求提供表中列出的全部字段。

| 构造函数 | 字段 |
| --- | --- |
| `category.journal` | `journal`, `volume`, `issue`, `pages` |
| `category.conference` | `conference`, `proceedings` |
| `category.book` | `publisher`, `isbn`, `edition` |
| `category.bookChapter` | `book`, `pages` |
| `category.thesis` | `degree`, `university` |
| `category.report` | `institution`, `number` |
| `category.preprint` | `repository`, `platform` |
| `category.blogPost` | `site`, `series` |
| `category.null` | 无分类；预先构造的值 |

示例：`(category.journal)(journal: "Example", volume: 1, issue: 2, pages: "1–8")`.

`author` 等记录类型提供 `new(..fields)`、`update(instance, ..fields)`（返回校验后的副本）、`with(..defaults)`（返回构造函数）和 `compare(other-type)`（判断类型兼容性，而非实例相等性）。实例提供 `fields()`，用于递归提取数据字段。`tag` 也是记录类型；推荐使用 `tag.register` 和标签实例的 `sub`，避免手动构造其状态字段。

`img` 和 `category` 提供 `new(variant, ..args)`、`with(variant, ..defaults)` 和 `compare(other-type)`。变体构造函数是 `new` 的简写。实例包含 `variant`、`payload` 和 `fields()`；后者返回以变体名为键的字典。`category.null` 和 `img.null` 已经是实例。

## 标签

`(tag.register)(namespace, tree)` 接受字符串命名空间和嵌套字典，叶子节点为 `(:)`。返回节点包含 `tag` 和 `children`，子节点具有相同结构。标签包含 `id`、`name` 和父标签 ID `_parent`。

```typst
#let topics = (tag.register)("notes", (science: (physics: (:),),))
#let physics = topics.children.science.children.physics.tag
#let optics = (physics.sub)("optics")
// 在 entry 中使用 tags: (physics,)
#context {
  let notes = (physics.get-doc)()
  [Tagged documents: #notes.len()]
}
```

`(tag-instance.sub)(name)` 创建具有确定性 ID 的子标签，但不会将其插入已有树的 `children` 字典。`(tag-instance.get-doc)()` 查询直接带有该标签的文档，包括已声明但未渲染的文档；不会自动包含后代标签关联的文档。

## 当前文档状态

`current` 仅供用户读取文档信息。不建议用户直接更新它；当前文档及其作用域由 `entry` 和 `embed` 管理。

请在上下文块中调用读取方法，并用括号包围方法名，例如 `#context { (current.get)().title }`。

| 方法 | 行为 |
| --- | --- |
| `(current.get)()` | 当前记录，初始值为 `(:)` |
| `(current.at)(loc)` | 指定 Typst 位置的记录 |
| `(current.final)()` | 最终的当前记录 |

使用 `entry` 选择文档，使用 `embed` 保存并恢复外层文档上下文。正常使用时，请勿直接调用 `current.update`、`current.enter` 或 `current.leave`。

## 显式渲染命名空间

在明确输出目标时使用这些命名空间；通常使用上述自动选择的辅助函数即可。包的 `html` 模块名可能遮蔽 Typst 内置的 `html`；需要调用内置 HTML 操作时可使用 `std.html`。

| 命名空间 API | 签名与行为 |
| --- | --- |
| `pdf.template` | `(body)`；PDF 页面样式 |
| `html.template` | `(body, title: "Notebook", lang: "en", css: html.stylesheet, css-href: none)`；默认内联 CSS，指定 `css-href` 时使用外部样式表 |
| `pdf.embed`, `html.embed` | `(body, offset: true/false)`；默认分别为 `true`、`false` |
| `pdf.mkdoc` | `(content, new-page: true)`；渲染当前元数据 |
| `html.mkdoc` | `(content, new-page: true, ssg: false)`；接受但忽略 `new-page`；`ssg` 选择站点布局 |
| `pdf.mkcover`, `html.mkcover` | `()`；当前文档封面 |
| `pdf.lookup`, `html.lookup` | `(label, content)`；引用行为与顶层函数相同 |
| `pdf.mkindex`, `html.mkindex` | `(label, content)`；共享索引注册逻辑 |
| `pdf.render-children`, `html.render-children` | `(title)`；对应输出格式的子文档列表 |
| `pdf.render-tags`, `html.render-tags` | `(tree)`；对应输出格式的标签树 |
| `html.stylesheet` | 默认 CSS 字符串 |
| `html.page` | `(path, body, title: "Notebook", lang: "en")`；输出 bundle HTML 页面并恢复文档作用域 |
| `html.bundle` | `(body, css: html.stylesheet)`；输出共享的 `tysty.css` |

`html.page` 要求相对 `.html` 路径，不允许空路径段、`.` 或 `..`。需要显式路径时，可使用以下独立 bundle 示例：

```typst
#import "@preview/tysty:0.1.0": *
#show: html.bundle
#html.page("guide/index.html", title: "Guide")[
  #entry(id: "guide", title: [Guide], authors: ())[
    #mkcover()
    Guide content.
  ]
]
```

使用 `typst compile --root . --features html,bundle --format bundle manual.typ output` 编译。

## 静态站点生成

使用 `#show: template`，并通过 `--features html,bundle --format bundle` 编译。README 提供了基于 `entry` 的完整站点示例。自动路由沿语义父节点生成，省略根文档 ID，每页位于其路由目录的 `index.html`。祖先文档必须存在，父链不能成环。请确保生成的路由唯一。

| API | 行为 |
| --- | --- |
| `ssg.route(id, ancestors: (), root: false)` | 纯路由计算；`root: true` 返回 `"index.html"`，否则拼接规范化的祖先与 ID，再追加 `/index.html`。 |
| `ssg.mkoutline(depth: none, title: [Documents])` | 使用相对页面链接的站点树；目前接受 `depth`，但不据此限制层级。 |
| `ssg.ref(label)` | 插入已生成页面保存的 Typst 正文，临时切换至其文档上下文；这是内容复用，而非仅创建链接。目标必须已生成。 |
| `ssg.embed(body, offset: false)` | 保存并恢复当前文档上下文 |
| `ssg.mkdoc(body)` | 底层渲染器：在 bundle 中输出路由页面，其他情况使用 HTML 渲染 |
| `ssg.is-bundle-output()` | 上下文查询，判断是否存在 bundle 标记 |
| `ssg.entities()` | 上下文查询，返回去重的已生成页面 ID 数组 |

路由示例：

```typst
#assert.eq(ssg.route("Home", root: true), "index.html")
#assert.eq(ssg.route("Review", ancestors: ("Research",)), "research/review/index.html")
```

路由片段会转换为小写，保留 Unicode 字母与数字，将其他连续字符替换为连字符，保留 `/` 分隔符；空结果使用 `untitled`。`route` 仅处理传入的祖先列表，不会自动查询或删除根节点。
