# modern-hust-cse-report

An (unofficial) Typst template for lab reports at the School of Cyber Science and Engineering, Huazhong University of Science and Technology (HUST).

此项目是华中科技大学网络空间安全学院实验/实践报告的通用Typst 模板。

计算机学院的大多数课现已提供了统一的LaTeX模板，不过考虑到网安没有新生实践课，LaTeX的上手曲线太高了。并且LaTeX无敌慢的本地编译速度，已经本地安装相对麻烦也都是问题。

但目前网安学院实验报告Word模板的混乱程度已经令人发指了，部分老师给的实验报告模板格式几乎是不可用的状态。

我相信很多同学都遇到过自己轻松一弄格式就乱掉了，然后调个行距段距和对齐怎么都调不明白。事实上，由于小学初中信息课都光顾着玩电脑了，我的Word熟练度真是够糟糕的。而事实证明网安学院自己的老师们的Word也并不熟练，从制作出来的模板千奇百怪就可见一斑。

作为一个泛CS专业的学生，相信大家更习惯文本编辑器的工作流。那么Typst非常适合你，它旨在成为LaTeX的现代替代。Typst帮助我们实现了格式分离，事实上你要输入的只是纯文本的报告内容，而不需要操心任何格式上的问题。并且Typst的上手曲线也非常平滑。在肉眼可见的未来，甚至有取代LaTeX之势。

由于网页端typst.app并不包含微软字体，因为更推荐在本地撰写和编译。如果你使用的是VSCode，可以通过Tinymist插件预览。Tinymist也同样支持文本编辑器，

当然，考虑到这是一个通用模板，对于具体的课程，你要对着老师给的模板填充一部分文字构成该课程的具体模板。不过一旦制作完成，你可以把模板分享给同学，无需重复劳动。

欢迎issue和pull request!!!

## 格式声明

- 标题页默认采用宋体26pt，可通过 title-font 参数切换为仿宋
- 一级标题黑体18pt居中
- 二级标题黑体14pt左对齐
- 标题前后1em间距
- 首页底部的日期是可选的，如果date置为空字符串则不显示，否则你可以输入Typst日期格式自动渲染，我建议使用datetime.today()函数自动获取日期
- 一级标题编号可选汉字数字（一、二、三）和阿拉伯数字（1、2、3）两种方式，通过 chinese-heading-number 参数控制
- 页眉为黑体10.5pt
- 块级数学公式（使用 `$ $` 包裹）会自动添加右侧编号：


目前评分表格的格式千奇百怪，所以无法提供一种统一的模板(但是你可以让GPT or claude帮你写)。

## 使用方式
### 前置安装
此模板需要你的电脑里有Fangsong , SimSun,SimHei, Times New Roman等Windows字体。如果你用的Windows系统那么这些本来就预装了。

如果你用的是NixOS在[我的NUR package]("https://github.com/DzmingLi/nur-packages")里面提供了`windows-fonts`这个包，里面包含了Windows 11所有的自带字体。

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
#import "@preview/modern-hust-cse-report:0.1.0": report, fig, tbl

#show: report.with(
  name: "李华",
  class: "网安2101",
  id: "U2020XXXXX",
  contact: "user@example.com",
  head:[页眉内容],
  date: datetime.today(),//你设为空字符首页就没有日期
  requirements:true,//如果你设为false就不会出现课程报告设计要求：1.报告不可以抄袭，发现雷同者记为零分...这一页
  scoretable:[
    // 评分表要用 Typst 格式写在这里
    // 如果有课程目标评价标准、评分标准等内容，也都写在这里
    // 如果有多页内容，记得使用 #pagebreak() 分页
  ],
  title: [本科：《密码硬件综合实践》报告],
  chinese-heading-number: true, // 设置为 false 使用阿拉伯数字，默认为 true 使用汉字数字
  title-font: "SimSun", // 标题页字体，可选 "SimSun"(宋体) 或 "FangSong"(仿宋)，默认为宋体
  signature: "signature.png", // 签名图片路径，设置为 none 则不显示签名
)

= 第一章
== 第一节

正文内容……

// 插入图片
#fig("image.png", caption: "这是图片标题", width: 80%)
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

### 图片插入

使用 `fig` 函数插入图片，它会自动添加格式化的图注：

```typst
#fig("path/to/image.png", caption: "图片描述", width: 80%)
```

- `caption`: 图片标题（必填）
- `width`: 图片宽度，可以是百分比或绝对值（可选，默认 auto）
- 图片编号格式为 `图x-y-z`，其中 x 是一级标题编号，y 是二级标题编号，z 是该节内的图片序号
- 每个二级标题下的图片编号会自动重置
- 图注使用 Times New Roman 和黑体混合字体，14pt，居中显示在图片下方

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
- 表注使用 Times New Roman 和黑体混合字体，14pt，居中显示在表格上方


