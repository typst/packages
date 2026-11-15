# Tysty

Tysty 是一个受 Emacs Org-mode 启发的 Typst 链接笔记库。它提供文档元数据、标签、交叉引用、目录和导航，可将同一份源码输出为 PDF、单文件 HTML 或静态网站。

API 参考：[English](doc/README.api.en.md) · [简体中文](doc/README.api.zh_cn.md)

## 开始使用

需要 Typst 0.15.1 或更高版本，以及 `@preview/tysty:0.1.0`。将以下内容保存为 `notebook.typ`：

```typst
#import "@preview/tysty:0.1.0": *
#show: template

#entry(id: "home", title: [笔记本], authors: ("Alice",), cover: true)[
  #mkoutline(title: [目录])
  欢迎阅读。
]

#embed[
  #entry(id: "first", parent-id: "home", title: [第一篇], authors: ("Alice",))[
    = 正文
    #mkindex("term")[术语]
    参见 #lookup("term")[术语]。
  ]
]

#render-children[子文档]
```

使用 `typst compile --root . notebook.typ` 输出 PDF；使用 `typst compile --root . --features html notebook.typ notebook.html` 输出单文件 HTML。顶层渲染函数会根据目标格式选择实现，也可以显式调用 `pdf.*` 和 `html.*`。

`entry` 同时声明和渲染文档。`id`、`title`、`authors` 必填，同一次编译中的 ID 必须唯一。`cover: true` 用封面替代标题。省略 `parent-id` 时，文档继承当前文档；显式写 `parent-id: auto` 可创建独立根文档。`embed` 保存并恢复外层文档上下文，PDF 中还默认增加标题层级。语义父子关系由 `parent-id` 决定，与视觉标题层级分开。

标签可用 `(tag.register)(namespace, tree)` 注册，再将返回节点的 `tag` 值放入 `entry` 的 `tags` 数组。`render-tags(tree)` 显示标签树。`lookup(label)[文本]` 创建引用并记录反向引用；`backlinks(label)` 可在上下文中查询这些引用。

## 静态网站

将以下内容保存为 `site.typ`：

```typst
#import "@preview/tysty:0.1.0": *
#show: template

#entry(id: "home", title: [笔记本], authors: (), cover: true)[首页]

#embed[
  #entry(id: "research", parent-id: "home", title: [研究], authors: ())[
    = 研究问题
    #mkoutline()
  ]
]
```

运行 `typst compile --root . --features html,bundle --format bundle site.typ output`，生成 `index.html`、`research/index.html` 和共享的 `tysty.css`。页面路由由文档 ID 和语义父链决定；根文档的 ID 不出现在路由中。生成页面的 `entry` 应放在其他页面的正文之外。站点导航、面包屑和章节目录由渲染器生成。

## 其他功能

- `set-base(prefix)` 设置文档 `file-path` 链接的前缀。
- `ssg.ref(id)` 在另一个已生成页面中复用指定页面的正文。
- `mkcover()` 可在通过 `meta()` 声明文档后单独渲染封面。
- `uid(namespace, name)` 使用纯 Typst 的 32 位 FNV-1a 散列，格式类似 UUID，但不是标准 UUID v5；有效散列空间只有 32 位，可能发生碰撞。

完整的字段、类型、显式渲染器和静态网站 API 请参阅[中文 API 参考](README.api.zh_cn.md)。
