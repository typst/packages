# modern-hust-cse-report

An (unofficial) Typst template for lab reports at the School of Cyber Science and Engineering, Huazhong University of Science and Technology (HUST).

此项目是华中科技大学网络空间安全学院实验/实践报告的通用Typst 模板。

Typst 旨在成为 LaTeX 的现代替代，帮助我们实现了格式分离，只需输入纯文本的报告内容，而不需要操心任何格式上的问题。它上手曲线非常平滑，并且作为纯文本格式对于使用AI撰写实验报告颇有优势。

由于网页端 typst.app 并不包含微软字体，因为更推荐在本地撰写和编译。如果你使用的是VSCode，可以通过 [Tinymist 插件](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)预览。Tinymist也同样支持绝大多数文本编辑器，

当然，考虑到这是一个通用模板，对于具体的课程，你要对着老师给的模板填充一部分文字构成该课程的具体模板。不过一旦制作完成，你可以把模板分享给同学，无需重复劳动。

这个模板基本上严格符合学院官方的实验报告要求。需要注意的是，根据具体的课程不同，有的老师给你的Word模板可能有问题，比如缺少报告要求页，比如甚至采用汉字来进行排序编号，比如标题甚至不是仿宋，但这只是老师给的模板错误，我个人觉得我们仍然应该使用正确的模板。

## 格式声明

- 标题页使用仿宋，校名/学院/报告标题均为26pt。如果你的课程名称较长（如《计算机网络工程与安全实践》），标题可能一行放不下，可以通过 `title-size: 25pt` 缩小标题字号，少1pt肉眼不可感
- 一级标题黑体18pt居中
- 二级标题黑体14pt左对齐
- 标题前后1em间距
- 首页底部日期固定为 `datetime.today()` 渲染
- 页眉为黑体10.5pt，内容为“网络空间安全学院” + 报告标题
- 标题页标题固定带“本科：”前缀
- 块级数学公式（使用 `$ $` 包裹）会自动添加右侧编号：

目前评分表格的格式千奇百怪，所以无法提供一种统一的模板(但是你可以让 AI 帮你写，我推荐 Claude，只有它比较会写 Typst)。

## 安装

此模板需要你的电脑里有 Fangsong, SimSun, SimHei, Times New Roman 等 Windows 字体。

### 方法一：使用 typst init（推荐）

在当前目录初始化项目：

```bash
typst init @preview/modern-hust-cse-report
```

指定自定义目录名称：

```bash
typst init @preview/modern-hust-cse-report my-report
```

### 方法二：手动导入

在已有 Typst 项目中导入该模板并填写信息：

```typst
#import "@preview/modern-hust-cse-report:0.1.2": report, fig, tbl

#show: report.with(
  name: "李华",
  class: "网安2101",
  id: "U2020XXXXX",
  contact: "user@example.com",
  scoretable:[
    // 评分表要用 Typst 格式写在这里
    // 如果有课程目标评价标准、评分标准等内容，也都写在这里
    // 如果有多页内容，记得使用 #pagebreak() 分页
  ],
  title: "《密码硬件综合实践》报告",
  signature: "signature.png", // 签名图片路径，设置为 none 则不显示签名
)

= 第一章
== 第一节

正文内容……

// 插入图片
#fig(image("image.png", width: 80%), caption: "这是图片标题")
// 这将自动显示为：图1-1-1:这是图片标题

// 插入表格
#tbl(
  table(
    columns: 3,
    [姓名], [学号], [成绩],
    [张三], [001], [95],
    [李四], [002], [88],
  ),
  caption: "学生成绩表"
)
// 这将自动显示为：表1-1-1:学生成绩表

// 插入数学公式（块级公式会自动编号）
$ E = m c^2 $
// 这将自动显示为：E = m c^2  (1-1-1)

```

## 使用
### 图片插入

使用 `fig` 函数插入图片，它会自动添加格式化的图注：

```typst
#fig(image("path/to/image.png", width: 80%), caption: "图片描述")
```

- `content`: 图片内容（使用 Typst 的 `image()` 函数创建）
- `caption`: 图片标题（必填）
- 图片编号格式为 `图x-y-z`，其中 x 是一级标题编号，y 是二级标题编号，z 是该节内的图片序号
- 每个二级标题下的图片编号会自动重置
- 图注使用 Times New Roman 和黑体混合字体，12pt，居中显示在图片下方

### 表格插入

使用 `tbl` 函数插入表格，它会自动添加格式化的表注：

```typst
#tbl(
  table(
    columns: 3,
    [列1], [列2], [列3],
    [数据1], [数据2], [数据3],
  ),
  caption: "表格描述"
)
```

- `content`: 表格内容（使用 Typst 的 `table()` 函数创建）
- `caption`: 表格标题（必填）
- 表格编号格式为 `表x-y-z`，其中 x 是一级标题编号，y 是二级标题编号，z 是该节内的表格序号
- 每个二级标题下的表格编号会自动重置
- 表注使用 Times New Roman 和黑体混合字体，12pt，居中显示在表格上方
