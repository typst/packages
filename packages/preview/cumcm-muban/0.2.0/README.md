cumcm-muban 是一个为高教社杯全国大学生数学建模竞赛设计的 Typst 模板。

## 使用方法

你可以在 Typst 网页应用中使用此模板，只需在仪表板上点击 “Start from template”，然后搜索 cumcm-muban。

另外，你也可以使用 CLI 命令来启动这个项目。

```
typst init @preview/cumcm-muban
```

Typst 将会创建一个新的目录，其中包含了所有你开始所需要的文件。

## 配置

此模板导出了 cumcm 函数，包含以下命名参数：

- title: 论文的标题
- problem-chosen: 选择的题目
- team-number: 团队的编号
- college-name: 高校的名称
- member: 团队成员的姓名
- advisor: 指导教师的姓名
- date: 竞赛开始的时间
- cover-display: 是否显示封面以及编号页
- abstract: 摘要内容包裹在 `[]` 中
- keywords: 关键字内容包裹在 `()` 中，使用逗号分隔

该函数还接受一个位置参数 `body`，用于论文的正文内容。

该模板将在显示规则中使用`cumcm`函数进行示例调用来初始化您的项目。如果您想要将现有项目更改为使用此模板，您可以在文件顶部添加一个类似于以下的显示规则：

```typ
#import "@preview/cumcm-muban:0.2.0": *
#show: thmrules

#show: cumcm.with(
  title: "全国大学生数学建模竞赛 Typst 模板",
  problem-chosen: "A",
  team-number: "1234",
  college-name: " ",
  member: (
    A: " ",
    B: " ",
    C: " ",
  ),
  advisor: " ",
  date: datetime(year: 2023, month: 9, day: 8),

  cover-display: true,

  abstract: [],
  keywords: ("Typst", "模板", "数学建模"),
)

// 正文内容

// 参考文献
#bib(bibliography("refs.bib"))<__bib__>

// 附录
= 附录 A
```

## 模板预览

|  封面 |  编号页  |  正文  |
|:---:|:---:|:---:|
| ![Cover-1](https://github.com/a-kkiri/CUMCM-typst-template/blob/38309b04a9edc039def0f7a093eaa640989ccee8/figures/p1.jpg?raw=true) | ![Cover-2](https://github.com/a-kkiri/CUMCM-typst-template/blob/38309b04a9edc039def0f7a093eaa640989ccee8/figures/p2.jpg?raw=true)| ![Content](https://github.com/a-kkiri/CUMCM-typst-template/blob/38309b04a9edc039def0f7a093eaa640989ccee8/figures/p4.jpg?raw=true)|

## ⚠️注意

 > 本模板使用到的字体有 中易宋体（SimSun），中易黑体（SimHei），中易楷体（SimKai），Times New Romans。这些字体为 Windows 系统内置，不过对于 WebAPP/Linux/MacOS 使用者请到仓库自行获取