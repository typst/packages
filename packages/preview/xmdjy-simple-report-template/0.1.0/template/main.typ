#import "@preview/xmdjy-simple-report-template:0.1.0" : *

#showpage(
  course: "课程名称",
  college: "学院名",
  author : "名字",
  stdid: "学号",
  title: "实验名",
  class: "班级"
)

#reportpage[
= 简介
#text(fill : blue,weight : "bold")[Typst]是一款轻量级的编程语言，具有markdown类似的语法和相当latex的排版能力，可以用来完成实验报告，同时适合vibe coding来水平时的作业报告（bushi，为了美观与整齐我设计了这样的一个模板供大家使用

= 使用说明
== 常用排版语法
- 标题使用\=、\==来表示不同级别的标题
- *加粗* / _斜体_使用\*和\_来包裹
- #highlight(fill : yellow)[高亮]使用 \#highlight[] 来高亮文本
- #sub[下标]和#super[上标]使用 \#sub[] 和 \#super[] 来表示上下标
- 无序列表使用 \- 开始，有序列表使用 \+ 开始
  + 有序1
  + 有序2
== 插入图片
#figure(
  image("images/exp.png",width : 75%),
  caption : [图片的说明],
)


== 插入表格
#figure(
  table(
    columns : 3,
    align : center,
    [*阶段*],[*研究内容*],[*应用*],
    [content1],[content2],[content3],
    [111],[222],[333],
  ),
  caption : [表格说明],
)

== 代码块
```cpp
#include<bits/stdc++.h>
using namespace std;
signed main(){
  cout << "code example" << endl;
  return 0;
}
```

== 数学公式
行内公式示例：$E=m c^2$ \
行间公式示例：$ A = pi r^2 $ \
更复杂一点的：$ cal(F)(omega) = integral_(-infinity)^(infinity) f(t) e^(-i omega t) d t $ \
其他示例：$ A = mat(1, 2; 3, 4)  \ quad sum_(i=1)^n i = (n(n+1)) / 2 $ \

== 文献引用
在给出的ref.bib中添加需要引用的文献，然后在文中使用 \
[ICIR2025]Think Then React 动作生成的新思路 @tan2025think 
#bibliography("ref.bib", style: "gb-7714-2015-numeric",title : "参考文献")

]