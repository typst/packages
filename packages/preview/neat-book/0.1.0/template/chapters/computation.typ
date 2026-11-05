#import "@preview/neat-book:0.1.0": *

= 从证明到计算 <ch-computation>

#introduction[
  - 用欧几里得算法连接数学结构与计算过程。
  - 在伪代码中表达循环、赋值与返回。
  - 用带语言图标的代码框呈现可执行实现。
]

== 最大公因数

对于非负整数 $a, b$，只要 $b != 0$，就有
$ gcd(a,b) = gcd(b, a mod b). $ <eq-gcd>

#theorem(title: "欧几里得算法的正确性")[
  反复使用 @eq-gcd，直到第二个分量为 $0$；此时第一个分量即为最大公因数。
] <thm-gcd>

#proof[
  两个分量的公因子集合在每一步中保持不变。第二个分量严格递减且非负，
  所以算法终止。终止时 $gcd(a,0)=a$，结论成立。
]

=== 算法描述

#algorithm(
  title: "欧几里得算法",
  input: [非负整数 $a, b$，且不同时为 $0$],
  output: [$gcd(a,b)$],
  {
    import algorithmic: *
    While($b != 0$, {
      Assign[$r$][$a mod b$]
      Assign[$a$][$b$]
      Assign[$b$][$r$]
    })
    Return[$a$]
  },
) <alg-euclid>

@alg-euclid 的行号、循环缩进和竖线由开源 algorithmic 生成。
算法是原生 figure，可以参与引用，也可以单独生成算法目录。

#pagebreak()

== Python 实现

代码框自动读取围栏语言，显示语言名称、图标、行号与语法高亮。

```python
def gcd(a: int, b: int) -> int:
    """Return the greatest common divisor."""
    a, b = abs(a), abs(b)
    while b:
        a, b = b, a % b
    return a

assert gcd(252, 105) == 21
```

=== Rust 实现

```rust
fn gcd(mut a: u64, mut b: u64) -> u64 {
    while b != 0 {
        (a, b) = (b, a % b);
    }
    a
}
```

== 写作的下一步

用 `= 标题` 开始新章，用 `== 标题` 和 `=== 标题` 划分节与小节。
目录默认收录三个层级，定理标题与公式均可添加标签并引用。

#remark(title: "结构先行")[
  将书稿按章拆分，有助于保持每个文件简洁。导言区负责字体、封面与后置内容，
  章节文件只负责论述。参考文献统一输出在正文之后，附录随后开始。
]

@app-symbols 给出常用记号；其中的公式和定理使用字母章号。
