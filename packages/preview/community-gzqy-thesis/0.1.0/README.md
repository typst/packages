# community-gzqy-thesis

社区维护的贵州轻工职业技术学院毕业设计（论文）Typst 模板，依据《毕业设计（论文）撰写要求与规范》编制。

Community-maintained Typst template for the Graduation Project (Thesis) of Guizhou Light Industry Technical College, prepared in accordance with the Requirements and Specifications for Graduation Project (Thesis) Writing.

## 使用方法

### 方式一：通过 Typst Universe 使用（推荐）

在 Typst 编辑器中初始化模板：

```bash
typst init @preview/community-gzqy-thesis:0.1.0
```

或在 `.typ` 文件中直接导入：

```typst
#import "@preview/community-gzqy-thesis:0.1.0": *

#show: community-gzqy-thesis.with(
  title: "论文题目",
  major: "专业名称",
  advisor: "指导教师",
  student-id: "学号",
  student-name: "姓名",
  year: "2026",
  month: "6",
  abstract-zh: [中文摘要内容。],
  keywords-zh: ("关键词1", "关键词2"),
  abstract-en: [English abstract.],
  keywords-en: ("keyword1", "keyword2"),
)

= 绪论
== 研究背景
...

#thesis-bibliography(bibliography("refs.bib", title: none, style: "gb-7714-2015-numeric"))
#thesis-acknowledgement[致谢内容。]
```

### 方式二：本地使用

克隆本仓库，将 `lib.typ` 放在项目中，将 `#import` 路径改为本地路径即可。

## 导出内容

| 名称 | 类型 | 说明 |
|------|------|------|
| `community-gzqy-thesis` | show rule 函数 | 主模板函数，自动渲染封面、摘要、目录、原创性声明 |
| `thesis-bibliography` | 函数 | 渲染参考文献标题 + bibliography |
| `thesis-acknowledgement` | 函数 | 渲染致谢标题 + 内容 |
| `heiti` | 字体列表 | 黑体字体 fallback 列表 |
| `songti` | 字体列表 | 宋体字体 fallback 列表 |
| `fs` | 字号字典 | 中文字号对应 pt 值 |

## 论文结构

模板自动生成以下结构：

1. 封面
2. 中文摘要
3. 英文摘要（Abstract）
4. 目录
5. 正文（用户通过 `= 标题` 编写）
6. 参考文献（通过 `thesis-bibliography` 渲染）
7. 致谢（通过 `thesis-acknowledgement` 渲染）
8. 原创性声明（自动附加）

## 许可证

MIT License
