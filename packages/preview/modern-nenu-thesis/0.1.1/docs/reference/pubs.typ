#import "../book.typ": *
#import "../style.typ": module, ref-fn, tidy

#show: book-page.with(title: "pubs 参数说明")

= pubs <pubs>

论文创新性成果列表，支持数组嵌套格式

== 参数结构 #type-hint("array")

每个成果项为一个字典，包含以下字段:

=== name #type-hint("str")
成果名称

=== class #type-hint("str")
成果类别，如"学术论文"、"专利"等

=== publisher #type-hint("str")
发表单位/期刊名称

=== public-time #type-hint("str")
发表时间，格式为"YYYY-MM"

=== author-order #type-hint("str")
作者排序，如"1"表示第一作者

== 示例

```typst
pubs: (
  (
    name: "论文名称1",
    class: "学术论文",
    publisher: "NENU",
    public-time: "2025-09",
    author-order: "1",
  ),
  (
    name: "论文名称2",
    class: "学术论文",
    publisher: "NENU",
    public-time: "2025-10",
    author-order: "3",
  ),
)
```

此示例定义了两篇论文成果。支持添加多个成果项，每项需包含上述所有必要字段。
