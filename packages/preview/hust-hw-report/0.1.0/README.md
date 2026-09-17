# hust-hw-report

[![Typst Universe](https://img.shields.io/badge/Typst-Universe-239DAD)](https://typst.app/universe/package/hust-hw-report/)

华中科技大学《硬件综合训练》课程设计报告的 Typst 模板。依据课程发布的
《硬件综合训练报告模板（2026-8-3 修订版）》Word 文档逐项还原：封面、红色页眉、
目录、标题层级、图表编号、代码灰底、原创性声明页均与 Word 模板版式一致。

An unofficial Typst template for the Hardware Comprehensive Training course
design report at the School of Computer Science, Huazhong University of Science
and Technology (HUST), faithfully recreated from the official Word template.

> [!WARNING]
> 本模板为非官方模板，提交报告前请核对课程最新要求。

## 快速开始

```bash
typst init @preview/hust-hw-report
typst compile main.typ
```

需要本机安装：宋体 (SimSun)、黑体 (SimHei)、楷体 (KaiTi)、华文中宋
(STZhongsong)、Times New Roman、Cambria、Arial、Calibri、Consolas
（Windows + Office 环境一般已具备）。

## 用法

```typst
#import "@preview/hust-hw-report:0.1.0": *

#show: report.with(
  title: "5段流水CPU设计",        // 题目
  major: "计算机科学与技术",       // 专业
  class: "CS240X",               // 班级
  stu-num: "U20241224",          // 学号
  name: "郭德纲",                 // 姓名
  phone: "1345565666",
  mail: "13456@qq.com",
  year: "2026",                  // 封面年份
  course: "硬件综合训练",          // 封面蓝条左侧
  doc-type: "课程设计报告",        // 封面蓝条右侧
  declaration: true,             // 末尾生成"原创性声明"页
  // signature: image("assets/signature.png", height: 0.9cm),
)

= 一级标题（章，自动新起一页）
== 二级标题
=== 三级标题
==== 条目标题（自动编号（1）（2）……）

#fig("assets/demo.png", caption: "总体结构图", width: 90%) <fig-arch>
如 @fig-arch 所示。

#tbl(
  table(columns: 3, [a], [b], [c], [1], [2], [3]),
  caption: "示例表格",
  label: "tbl-demo",
)
如表 @tbl-demo 所示。

#refs[文献一][文献二]   // 自动编号 [1] [2] ……
```

## 特性

- **封面**：橄榄绿竖条 + 白色年份 + 书法校名 + 蓝底白字标题条 + 下划线信息表，按 Word 模板坐标还原；
- **页面方案**：封面 / 目录（罗马页码）/ 正文（阿拉伯页码接续）三节独立边距，取自 docx 的 sectPr；
- **页眉页脚**：红色楷体页眉 + 3pt 黑线，页脚居中页码，与 Word 模板一致；
- **正文**：宋体小四 + Times New Roman，首行缩进两字符，行距按 Word 文档网格 22.95pt；
- **图表编号**："图 N.X / 表 N.X"按章编号、每章重置，题注黑体五号，图注在下、表注在上，支持跨章交叉引用；
- **表格跨页**：长表格自动续排；
- **代码**：灰色底纹（Word 模板要求），Consolas 等宽字体 + 语法高亮；
- **末页**："·指导教师评定意见·"页眉 + 楷体"一、原创性声明"+ 手写签名位。

## 与 Word 模板的差异

- 代码块有意使用 Consolas + Typst 语法高亮（Word 原版为宋体黑字），灰色底纹要求保持一致；
- 表头行跨页重复需自行使用 `table.header(...)`；
- Word 模板末节仅含原创性声明，指导教师评定意见表单需按课程要求自行补充。

## 致谢

- 图表编号与题注样式参考了 [modern-hust-cs-report](https://github.com/Paulkm2006/modern-hust-cs-report)；
- 模板依据的 Word 文档版权归课程组所有，校名图片来自该 Word 模板。

## License

MIT — 详见 [LICENSE](LICENSE)。
