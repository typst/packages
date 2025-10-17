#import "../book.typ": *
#import "../style.typ": module, ref-fn, tidy

#show: book-page.with(title: "comments 参数说明")

= comments <comments>

博士论文评语与决议书内容配置参数

== 参数结构 #type-hint("dictionary")

评语包含以下两个字段:

=== supervisor #type-hint("str")
导师评语内容

=== committee #type-hint("str")
答辩委员会决议书内容

== 示例

```typst
comments: (
  supervisor: "导师的评语",
  committee: "委员会的评语",
)
```

#mynotify[
  此参数仅在博士论文模板中使用，其他类型论文将忽略此参数。
]
