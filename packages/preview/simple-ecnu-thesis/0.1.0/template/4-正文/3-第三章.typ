#import "mod.typ": *
#show: style

= 正文部分
<chapter-3>

== 人工智能
<chapter-3-ai>

本文的符号标记表如@symbol-table 所示

#let symbol-var = 40pt
#let symbol-value = 170pt
#figure(
  caption: [符号标记表],
  // placement: bottom,
  table(
    columns: (symbol-var, symbol-value, symbol-var, symbol-value),
    align: (col, row) => (center + horizon, left, center + horizon, left).at(col),
    inset: 5pt,
    [$cal(D)$], [数据集], [$X$], [训练集],
    [$Y$], [标签], [$accent(Y, hat)$], [预测标签],
    [$F$], [特征集合], [$S$], [特征集合子集],
    [$cal(F)$], [神经网络模型], [Pr], [模型预测概率分布],
  ),
) <symbol-table>

== 机器学习

我们提出了一个算法 ...... 如 @algo:split 所示

#figure(
  caption: [分割数据集],
  // placement: bottom,
  kind: "algorithm",
  supplement: "算法",
  pseudocode-list(booktabs: true, numbered-title: [分割数据集])[
    - *输入:* 数据集 $D(X, Y)$
    - *输出:* 训练集 $X_"train", Y_"train"$, 测试集, $X_"test", Y_"test"$
    + *Function* My-Function$(S, e):$
      + $S arrow.l S union e$
      + *return* $S$
    + `/* 初始化返回值 */`
    + $X_"train" arrow.l emptyset, Y_"train" arrow.l emptyset$
    + $X_"test" arrow.l emptyset, Y_"test" arrow.l emptyset$
    + *for* $(x, y) in (X, Y)$ *do*
      + $r arrow.l "Random()"$ #h(2em) `/* 生成 0~1 的随机数 */`
      + *if* $r < 0.7$:
        + $X_"train" arrow.l "My-Function"(X_"train", x)$
        + $Y_"train" arrow.l "My-Function"(Y_"train", y)$
      + *else*
        + $X_"test" arrow.l "My-Function"(X_"test", x)$
        + $Y_"test" arrow.l "My-Function"(Y_"test", y)$
    + *return* $X_"train", Y_"train", X_"test", Y_"test"$ `/*生成分割数据集 */`
  ],
) <algo:split>

使用 python 语言可以表述为
#figure(
  caption: [代码示例],
  ```py
  """该算法由 sklearn 官网提供"""
  from sklearn.model_selection import train_test_split
  from sklearn.datasets import load_iris
  # 读取数据
  iris = load_iris()
  # 取出特征和标签
  X = iris.data
  y = iris.target
  # 分割数据集
  X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
  ```,
)

== 深度学习

