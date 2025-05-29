#import "mod.typ": *
#show: style

= 实验结果

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
)

