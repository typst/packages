# 电子科技大学论文模板

分享一个自用的电子科技大学（UESTC）硕士学位论文的 Typst 模板，按照《电子科技大学研究生学位论文规范》的硕士论文模板编写，欢迎fork，提交 issue和PR.

## 适用人群：

习惯使用 markdown 等标记语言，熟悉函数式编程，对 typst 有一定了解。

## 版本变更记录

| 版本号 | 日期       | 变更内容 |
| ------ | ---------- | -------- |
| 1.0    | 2025-08-26 | 在线发布版本 |

## 功能特色

- 实现了带样式图表的封装组件
- 可以实现分章节编写正文再 #include 引入

## 需求规划

- 包括本科和博士论文版本
- 实现双面打印版本
- 其他官方规范中要求但尚未注意和实现的要求

## 缺陷列表

- 暂未实现封面和标题页的完美复刻，需要手动导入 pdf
- 尚未发布到 typst universe

## 主要函数说明

| 函数名          | 类别     | 说明           | 参数                                       |
| --------------- | -------- | -------------- | ------------------------------------------ |
| thesis-figure   | 组件函数 | 插入图         | 图片路径，图名称                           |
| thesis-table    | 组件函数 | 插入表格       | 表名，表头，表体，列宽                     |
| toc             | 页面函数 | 插入目录       | 无                                         |
| list-of-figures | 页面函数 | 插入图目录     | 无                                         |
| list-of-tables  | 页面函数 | 插入表目录     | 无                                         |
| abstract        | 页面函数 | 插入中英文摘要 | 中文关键词，英文关键词，中文摘要，英文摘要 |
| acknowledgment  | 页面函数 | 插入致谢页     | 致谢内容                                   |
| reference       | 页面函数 | 插入参考文献   | 自定义 bib 文件路径                        |
| appendix        | 页面函数 | 插入附录       | 附录内容                                   |

## 使用方法

1. 下载源文件

```
git clone https://github.com/pldxmm/uestc-thesis.git
```

2. 下载 vsccode tinymist 插件，即可实时预览

3. 提前填写论文封面 docx 模板，转为 pdf 并放入 materials 文件夹
4. main-example.typ文件, 修改封面导入路径，填写页面函数参数
5. 编写正文（main.typ）和参考文献(references.bib)
6. 快捷编译使用 tinymist 插件 export ，或使用命令行编译，生成 pdf

**注 请使用 typst0.13 及之后版本**

```
typst compile main.typ
```

### 封面导入

```
#muchpdf(read("materials/cover-example.pdf", encoding: none))
```

### 图函数

```
#thesis-figure(
image("/images/image-example.svg",width: 100%),
caption: [DORA指标],
)
```

### 表格函数

```
#thesis-table(
    title:[表格名称],
    header:([姓名], [年龄], [性别]),
    body: (
      [张三],[20], [男],
      [李四], [21], [女]
      )，
    // 调节列宽比例
    columns:(1fr,1fr,1fr)
    notes:[表格备注]
)
```
