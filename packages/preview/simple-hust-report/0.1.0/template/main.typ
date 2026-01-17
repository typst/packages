#import "@preview/simple-hust-report:0.1.0": pseudocode-list, report
#show: report.with(
  logo: none, //可选,校徽/校名图片,用image包裹后传入,不填或none则默认为华科校名
  //image("/images/HUSTGreen.svg",width:55%)
  type: "课程实验报告", //校名下方的标题
  course-name: ("课程名称", "人工智能导论"), //可选,课程名称,必须以("label","content")方式传参,默认为none,则为不显示该行
  title: ("实验题目", "基于CNN的动物识别系统"), //实验题目,同上
  class-name: "CS2410", //专业班级
  student-id: "U202488888", //学号
  name: "张三", //学生姓名
  instructor: "李四", //指导教师
  date: datetime.today().display("[year]年[month]月[day]日"), //自动获取当前日期，可手动修改
  school: "计算机科学与技术学院", //学院
  header-text: "华中科技大学课程实验报告", //页眉文字
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









