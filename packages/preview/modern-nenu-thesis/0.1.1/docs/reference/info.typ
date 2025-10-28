#import "../book.typ": *
#import "../style.typ": module, ref-fn, tidy

#show: book-page.with(title: "info 选项解释")

= Info <info>

== title #type-hint("str") | #type-hint("array")

论文中文题目

当需要换行/过长时可以使用字符数组传入

== title-en #type-hint("str")

论文英文题目

== grade #type-hint("str")

年级

== student-id #type-hint("str")

学号

== author #type-hint("str")

作者中文名

== author-en #type-hint("str")

作者英文名

== secret-level #type-hint("str")

密级中文

== secret-level-en #type-hint("str")

密级英文

== department #type-hint("str")

院系中文名

== department-en #type-hint("str")

院系英文名

== discipline #type-hint("str")

一级学科中文名

== discipline-en #type-hint("str")

一级学科英文名

== major #type-hint("str")

二级学科中文名

== major-en #type-hint("str")

二级学科英文名

== field #type-hint("str")

研究方向中文

== field-en #type-hint("str")

研究方向英文

== supervisor #type-hint("array")

导师信息(姓名, 职称)

== supervisor-en #type-hint("array")

导师英文信息

== submit-date #type-hint("str")

提交日期

== school-code #type-hint("str")

学校代码

== reviewers #type-hint("array")

论文评阅人，每个条目需包含以下字段:

=== name #type-hint("str")
姓名

=== workplace #type-hint("str")
工作单位/职称

=== evaluation #type-hint("str")

总体评价

== committee-members #type-hint("array")

答辩委员会成员，每个条目都需包含以下字段:

=== name #type-hint("str")
姓名

=== workplace #type-hint("str")
工作单位/职称

=== title #type-hint("str")

职务
