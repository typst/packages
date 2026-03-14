#import "../../library/template.typ": *

#set-heading-image(none)
= 其他演示

== 引用参考文献

人教版数学三年级下册 .. @面积和面积单位

== 各种盒子

#axiom-showy(title: "公理样例")[这个是公理样例]

#definition-showy(title: "定义样例")[这个是定义样例]

#law-showy(title: "定律样例")[这个是定律样例]

#theorem-showy(title: "定理样例")[这个是定理样例]

#lemma-showy(title: "引理样例")[这个是引理样例]

#postulate-showy(title: "假设样例")[这个是假设样例]

#corollary-showy(title: "推论样例")[这个是推论样例]

#proposition-showy(title: "命题样例")[这个是引理样例]

#example-showy(title: "例子样例")[这个是例子样例]

#exercise-showy(title: "练习样例")[这个是练习样例]

#axiom-rainbow(title: "公理样例")[这个是公理样例]

#definition-rainbow(title: "定义样例")[这个是定义样例]

#law-rainbow(title: "定律样例")[这个是定律样例]

#theorem-rainbow(title: "定理样例")[这个是定理样例]

#lemma-rainbow(title: "引理样例")[这个是引理样例]

#postulate-rainbow(title: "假设样例")[这个是假设样例]

#corollary-rainbow(title: "推论样例")[这个是推论样例]

#proposition-rainbow(title: "命题样例")[这个是引理样例]

#example-rainbow(title: "例子样例")[这个是例子样例]

#exercise-rainbow(title: "练习样例")[这个是练习样例]

#my-notebox-rainbow[
  这个是注意样例
]

#my-quotebox-rainbow[
  这个是引用样例
]

== 图像 表格 代码

#figure(
  none,
  caption: [图片实例]
)<zhulinqixian>

@zhulinqixian 是湖南博物馆的《“竹林七贤”湘绣画稿》。

#figure(
  table(
    columns: (auto, auto, auto),
    [表头1], [表头2], [表头3],
    [ohhhh], [ahhhhh], [ehhhh]
  ),
  caption: [表格实例]
)<biaoge>

@biaoge 是表格实例

#figure(
  zebraw[
    ```py
    import numpy as np
    
    a = np.randn(999)
    b = np.sum(a)
    c = 1

    for i in a:
      c = c * i
    ```
  ],
  kind: raw,
  caption: [代码实例]
)<code>

@code 是代码实例
