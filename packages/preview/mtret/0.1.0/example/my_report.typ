#import "@preview/mtret:0.1.0": *
#import "@preview/enja-bib:0.1.0": *
#import bib-setting-plain: *

#show: bib-init
#show: style

#titles("カハンの加算アルゴリズムの実装と考察", subtitle: "数値計算法 第一回レポート")
#name(id: "hinshiba", "瀕死")
#date_info(qdate: datetime(year: 2025, month: 10, day: 2))

// #outline()

= 概要

本レポートでは計算機上での加算の際に発生しうる情報落ちによる誤差を軽減する手法の1つであるカハンの加算アルゴリズムについて実装し，原理を考察，他のアルゴリズムとの比較を行う．

= 実装

今回作成したカハンの加算アルゴリズムの`Python`による実装を@code:impl に示す．
なお，実行可能なプログラムは`GoogleForm`にて別途提出してある．

#fcode(caption: [Pythonによる実装], label: <code:impl>, placement: none)[
  ```py
  def kahan_add(vals: NDArray[np.float32]) -> np.float32:
      ans = np.float32(0)
      comp: np.float32 = np.float32(0)
      for x in vals:
          x -= comp
          temp: np.float32 = ans + x
          comp = (temp - ans) - x
          ans = temp
      return ans
  ``` ]
6行目の，変数`temp`にいままでの総和`ans`と入力`x`を加算する操作を繰り返し行うことで加算が達成される．
このとき，加算後の`temp`はには情報落ちの誤差等が含まれている可能性がある．これを7行目によって求め，変数`comp`に保存する．
そして，次回の加算前に，`comp`を考慮した値に入力`x`を調整するという実装である．

= 結果

ここでは非常に簡単な実行結果のみとし，詳細な考察と比較は考察で行う．

@code:run を@code:impl の定義の下で実行した結果を@txt:res に示す．
#fcode(caption: [実行例], label: <code:run>)[
  ```python
  # マシンイプシロンの近似値
  eps = np.finfo(np.float32).eps

  print(f"{np.float32(2) + eps + eps =}")
  print(f"{kahan_add(np.array([2, eps, eps], dtype=np.float32))=}")
  ``` ]
//
#ftext(caption: [実行結果], label: <txt:res>)[
  ```txt
  np.float32(2) + eps + eps =np.float32(2.0)
  kahan_add(np.array([2, eps, eps], dtype=np.float32))=np.float32(2.0000002)
  ``` ]
//
この結果から，カハンの加算アルゴリズムでは`2 + eps`時の誤差を補正して，最終的にはより近い解を得られていることがわかる．

= 考察

本章ではカハンの加算アルゴリズムを含めた3つのアルゴリズムを比較し，誤差の評価と，どのような点が優位であるのかについて考察する．
考察するアルゴリズムは入力を順番に足すもっとも単純なもの，応用解析の講義において説明された絶対値が小さい値から足していくもの，カハンの加算アルゴリズムの3つである．

== 理論的説明

設定として，$x_1, x_2 ... x_(n+1) (x_i >= 0)$の総和を求めるものとし，加算前には誤差を持っていなかったものとする．また，減算における誤差は小さい@kahan ので誤差は常に無視できるものとする．

以降において，$i$回目の加算で生じる相対誤差を$epsilon_i$，変数`comp`の値を$c_i$，誤差を含む$x_(i+1)$までの総和を$S_i$とする．

まず，1回目は$0$との加算で誤差が発生しないものとし，
$
  S_1 = x_1 + 0, #h(1em) epsilon_i = 0, #h(1em) c_1 = 0
$
$i (i > 1)$回目では，
$
  S_i & = {(x_i - c_(i-1))+ S_(i-1)}(1 + epsilon_i) \
      & = x_i - c_(i-1) + S_(i-1) + epsilon_i (x_i - c_(i-1) + S_(i-1)) \
  #v(1.5em)
  c_i & = S_i - S_(i-1) - (x_i - c_(i-1)) \
      & = epsilon_i (x_i - c_(i-1) + S_(i-1))
$
また，
$
      S_i & = x_i - c_(i-1) + S_(i-1) + epsilon_i (x_i - c_(i-1) + S_(i-1)) \
          & = x_i - c_(i-1) + x_(i-1) - c_(i-2) + S_(i-2) + epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2)) \
          & + epsilon_i {x_i - c_(i-1) + x_(i-1) - c_(i-2) + S_(i-2) + epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2))} \
  #v(1.5em)
  c_(i-1) & = epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2))
$
より，
$
  S_i & = x_i - epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2)) + x_(i-1) - c_(i-2) + S_(i-2) + epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2)) \
  & + epsilon_i {x_i - epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2)) + x_(i-1) - c_(i-2) + S_(i-2) + epsilon_(i-1) (x_(i-1) - c_(i-2) + S_(i-2))} \
  & = x_i + x_(i-1) - c_(i-2) + S_(i-2) + epsilon_i {x_i + x_(i-1) - c_(i-2) + S_(i-2)} \
$
よって，この操作を繰り返すと，
$
  S_i & = x_i + x_(i-1) + ... + x_1 - c_0 + epsilon_i {x_i + x_(i-1) ... x_1 - c_0 }
$
となる．
したがって，このアルゴリズムにおいては，加算の回数に誤差が依存しないことがわかる．
// In the following program $2 is an estimate of the e r r o r caused when S = T was last rounded or truncated, and is u s e d in s tate ~ ment 13 to compensate for that error. The pa ren theses in state- merit 23 must not be omitted; they cause tile d i f f e r ence (S--T) to be evaluated first and hence, in most e~ses, w i t h o u t e r ror be- cause the difference is normalized before it is rounded o r t r u n c a t e d .

== 他のアルゴリズムとの比較

比較として絶対値が小さい値から足す場合や，単純に足す場合について考える．

1回目は$0$との加算で誤差が発生しないものとし，
$
  S_1 = x_1 + 0, #h(1em) epsilon_i = 0
$
$i (i > 1)$回目では，
$
  S_i & = (x_i + S_(i-1))(1 + epsilon_i) \
      & = x_i + S_(i-1) + epsilon_i (x_i + S_(i-1)) \
      & = {x_i + (x_(i-1) + S_(i-2))(1 + epsilon_(i-1))} + epsilon_i {x_i + (x_(i-1) + S_(i-2))(1 + epsilon_(i-1))} \
      & = x_i + x_(i-1) + S_(i-2) + epsilon_(i-1){x_i + x_(i-1) + S_(i-2)} + \
      & epsilon_i{x_i + x_(i-1) + S_(i-2)} + epsilon_i epsilon_(i-1){x_i + x_(i-1) + S_(i-2)} \
      & ... \
$
ここで，$epsilon_i << 1$とすると，$epsilon_i epsilon_j$は無視できるほど小さい．
このとき，上式より1回加算するごとに$epsilon_i$の積となる項が1つづつ増えるので，これら誤差が互いに打ち消しあわないとすると，概ね$n$の増え方に比例して誤差も増えていくこととなる．

絶対値が小さい順に足すとすると，それぞれの$epsilon_i$は単純に足すより小さくなると考えられるが，こちらもまた概ね$n$の増え方に比例して誤差も増えていくこととなる．また，比較を用いたソートの過程で，最低でも$O(n log n)$の時間計算量を持つことになる@algo ため計算量が悪化する．

したがって，このアルゴリズムにおいては，加算の回数に誤差が依存しないことがわかる．

ここまでの比較を@comp にまとめる．
#figure(caption: "アルゴリズムの比較", supplement: "表")[
  #table(
    columns: 3,
    table.header([*アルゴリズム*], [*誤差の増え方*], [*時間計算量*]),
    [単純な加算], [$n$に比例], [$O(n)$],
    [絶対値の低い順に加算], [$n$に比例], [$O(n log n)$],
    [カハンの加算アルゴリズム], [一定], [$O(n)$],
  )] <comp>

このことから，カハンの加算アルゴリズムは時間計算量を単純な加算からそのままに，誤差を大きく減らすことのできるアルゴリズムであるということがわかった．

// 参考文献
#bibliography-list(
  title: "参考文献",
  bib-item(
    label: <kahan>,
    author: "Kahan, W.",
    year: "1965",
    yomi: "Kahan",
    (
      [Kahan, W., Pracniques: further remarks on reducing truncation errors, Commun. ACM (1965],
      [), Vol. 8, pp. 40–41],
    ),
  ),
  bib-item(
    label: <algo>,
    author: "浅野 哲夫",
    year: "1965",
    yomi: "Kahan",
    (
      [浅野 哲夫, 和田 幸一, 増澤 利光, アルゴリズム論, オーム社 (2003],
      [), p. 100],
    ),
  ),
)
