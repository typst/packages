= 样式

== 字体样式

本模板支持多种字体，如*加粗文本*，_斜体文本_ #footnote[中文通常不使用斜体，而是使用楷体等。]，`等宽文本 (Raw Text)`@ruc-thesis-template。

== 列表

=== 无序列表

- 第一项
- 第二项
  - 子项 A
  - 子项 B
    - 第三级子项
- 第三项

=== 有序列表

+ 第一项
+ 第二项
  + 子项 1
  + 子项 2
    + 第三级子项
+ 第三项

== 数学公式

- 行内公式：$E = m c^2$。
- 行间公式：
  $
    f(x) = 1 / sigma sqrt(2 pi) e^(- (x - mu)^2 / (2 sigma^2))
  $
- 带编号的行间公式（会顶格）：
  $
    f(x) = sum_(n=0)^N (x^n / n!) + integral_0^x e^(-t^2) d t
  $ <eq1>
- 多行公式：
  $
    A & = pi r^2 \
    C & = 2 pi r
  $

== 图表

#figure(
  image("../assets/example.png"),
  caption: [明代永宁宣抚司及永宁卫疆域图],
)

表格会自动使用三线表格式：

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [量的名称], [单位名称], [单位符号],
    [长度], [米], [m],
    [质量], [千克(公斤)], [kg],
    [时间], [秒], [s],
    [电流], [安[培]], [A],
    [热力学温度], [开[尔文]], [K],
    [物质的量], [摩[尔]], [mol],
    [发光强度], [坎[德拉]], [cd],
  ),
  caption: [国际单位制的基本单位],
)

== 代码块

在论文中你可以自由的引用代码块：

```python
def hello_world():
    print("Hello, World!")

if __name__ == "__main__":
    hello_world()
```
