*这是一份用于实验报告的Typst模板*

---

该模板集成了封面生成、自动排版、代码块高亮、智能图表编号以及参考文献管理等功能，旨在让你专注于实验内容的撰写，而无需操心排版问题。

该模板默认样式为华中科技大学，其他学校的学生如果想要使用，可以自行在main.typ中传入自己学校的logo，同步修改页眉等相关信息即可。

---

#### 模板特点

1. **智能分章编号**：图表、公式、代码块自动按照”章节-序号"进行编号。

2. **定制封面**：封面logo,标题，课程，实验名称等标签与内容均支持自定义。

3. **代码块排版优化**：预设代码块圆角背景，选用JetBrains Mono/Consolas等宽字体提高阅读体验。

4. **中文排版增强**：支持中文**伪粗体**与*伪斜体*（映射为楷体）,兼容Markdown强调语法。

#### 使用方法

使用前确保系统安装了以下字体

- 中文字体：宋体 (SimSun), 黑体 (SimHei), 楷体 (KaiTi)

- 英文字体：Times New Roman

- 代码字体： Consolas或JetBrains Mono

如果你是windows系统，则系统已自带这些字体，无需额外安装

##### 方式一：使用命令行工具(推荐)

如果你已经在本地安装了 Typst CLI (0.12.0+),可[点击这里](https://github.com/typst/typst)前往安装，只需运行以下命令即可初始化一个新项目：

```bash
typst init @preview/simple-hust-report:0.1.0 my-report
```

这会自动在当前目录下创建一个名为 `my-report` 的文件夹，其中包含所有必要的文件。

##### 方式二:在Typst Web App中使用

1. 前往[Typst Web App](https://typst.app/)
2. 点击 "start from template"
3. 搜索simple-hust-report并导入

**方式三:手动引入(已有项目)**

如果你想在现有的文档中使用此模板，请在文件开头添加：

````typst
#import "@preview/simple-hust-report:0.1.0": pseudocode-list, report
#show: report.with(
  logo: none, //可选,校徽或者校名图片路径,不填或none则默认为华科校名
  //image("/images/HUSTGreen.svg",width:55%)
  type: "课程实验报告", //校名下方的标题
  course_name: ("课程名称", "人工智能导论"), //课程名称,必须以示例的("label","content")方式传参,可选,默认为none
  title: ("实验题目", "基于CNN的动物识别系统"), //实验题目,同上
  class_name: "CS2410", //专业班级
  student_id: "U202488888", //学号
  name: "张三", //学生姓名
  instructor: "李四", //指导教师
  date: datetime.today().display("[year]年[month]月[day]日"), //自动获取当前日期，也可手动修改
  school: "计算机科学与技术学院", //学院
  header_text: "华中科技大学课程实验报告", //页眉文字
  appendix: //可选，在[]中填写附录内容,默认为none,附录很长时建议新建appendix.typ文件并利用include导入
  [
    = 原始代码

    == 模块一
  ],
  //include appendix.typ
  bibliography-file: //可选,传入参考文献,默认为none,
  bibliography("ref.bib"),
)

= 引言
用 `=` 可以区分多级标题。

用 `*` 包裹可以*加粗*关键字，用 `_` 包裹可以_强调_关键词。

== 有序列表
有序列表以 `+` 开头，
+ 第一
+ 第二

== 无序列表
无序列表以 `-`开头,列表均可利用缩进进行嵌套。例如
- One
  - 这里是子列表
  - 111
- Two

= 第一章
所有图片、表格、公式、伪代码均会按照“章节-序号”自动编号。
== 图片插入
插入图片的格式如下,可在figure之后用`< >`包裹对figure的命名，然后用`@name`的方式来引用这个figure，就像这样@HUST，或者@this_is_a_table
#figure(
  caption: "华中科技大学(黑)",
  image("/images/HUSTBlack.svg", width: 80%),
)<HUST>

== 表格插入
表格的基本用法如下，
#figure(
  caption: "这里是表格的名字",
  table(
    columns: (1fr, 2fr, 1fr),
    //建立一个三列，宽度为1:2:1的表格
    [1], [2], [3],
    [a], [b], [c],
  ),
)<this_is_a_table>
== 公式插入
行内公式的插入如下,直接用`$`包裹即可，例如$F = m a$和$O(N^2)$, $cal(O)(N log N)$,单个字母间的空格表示相乘。用`""`包裹表示以原文呈现。


单行公式的插入,在开头`$`之后和结尾`$`之前多一个空格即可。

$
  T(n) = cases(
    1 & "if" n = 1,
    2T(n /2) + n & "if" n >= 2
  )
$

== 代码插入
=== 伪代码插入
插入伪代码的格式如下，用有序列表来实现缩进，用`*`包裹关键词实现加粗。伪代码格式的实现调用了 lovelace的库 。更多资料请#link("https://typst.app/universe/package/lovelace/")[点击这里]。

#figure(
  kind: "algorithm",
  supplement: "Algorithm",
  pseudocode-list(booktabs: true, numbered-title: [Quick Sort])[
    + *Input:* Array $A$, low $p$, high $r$
    + *Output:* Sorted Array $A$
    + *if* $p < r$ *then*
      + $q =$ *Partition*($A, p, r$)
      + *QuickSort*($A, p, q-1$)
      + *QuickSort*($A, q+1, r$)
    + *end if*
    + *return*
  ],
)<quick_sort>

如果导入了参考文献，可以直接使用`@`来进行访问，例如 @clrs 这样，被引用到的文献会出现在参考文献的列表中。

=== 代码块和行内代码插入
代码块的格式如下
```cpp
#include<iostream>
int main() {
  cout << "hello,world!";
}
```

```python
def helloWorld():
  print("hello,world!")

helloWolrd()
```

除此之外，还可以利用“ \` ”反引号包裹来实现行内代码的效果，例如`print()`

= 第二章
更多使用方法请查询#link("https://typst.app/docs/")[官方文档]。
````

接下来就可以开始修改模板，编写你的代码。

更多关于Typst的使用教程，请访问[Typst官方文档](https://typst.app/docs/)。

---

#### 目录结构说明

使用模板初始化后的推荐目录结构如下：

```text
my-report/
├── main.typ          # 主文件 (在此处编写你的报告)
├── refs.bib          # (可选) 参考文献库
├── appendix.typ      # (可选) 附录内容
└── images/           # (建议) 存放你的实验截图
```



---

#### 效果

![1](https://cdn.jsdelivr.net/gh/kkkkkkeng/pic-bed/img/20260116212628356.png)



![2](https://cdn.jsdelivr.net/gh/kkkkkkeng/pic-bed/img/20260116212731983.png)

![3](https://cdn.jsdelivr.net/gh/kkkkkkeng/pic-bed/img/20260116212816118.png)

![3](https://cdn.jsdelivr.net/gh/kkkkkkeng/pic-bed/img/20260116213256720.png)

---

#### 参数说明

| **参数名**          | **类型** | **默认值**       | **说明**                                             |
| ------------------- | -------- | ---------------- | ---------------------------------------------------- |
| `logo`              | content  | *华科logo*       | 封面的logo，最好传入`image("图片地址")`              |
| `type`              | string   | `"课程实验报告"` | 封面顶部的大标题                                     |
| `course_name`       | array    | `none`           | 格式为 `("标签", "内容")`，如 `("课程名称", "OS")`   |
| `title`             | array    | `none`           | 格式为 `("标签", "内容")`，如 `("实验题目", "Lab1")` |
| `class_name`        | string   | `"CS2410"`       | 专业班级                                             |
| `student_id`        | string   | `"U2024XXXXX"`   | 学号                                                 |
| `name`              | string   | `"张三"`         | 学生姓名                                             |
| `instructor`        | string   | `"李四"`         | 指导教师                                             |
| `date`              | string   | *自动生成今日*   | 报告日期                                             |
| `school`            | string   | `"计算机..."`    | 学院名称，显示在封面底部                             |
| `header_text`       | string   | `"华中科技..."`  | 页眉中间的红字文本                                   |
| `bibliography-file` | content  | `none`           | 传入参考文献，调用`bibliography("文献路径")`传入     |
| `appendix`          | content  | `none`           | 附录内容块，传入即开启附录模式                       |





