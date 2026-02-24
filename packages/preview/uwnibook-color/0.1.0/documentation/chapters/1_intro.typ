#import "../packages.typ": *
#import "../defs.typ": *

= 例文分析學 <chap:example>
#subheading[
  獨以前文難為察状貌也。是以作此章句以呈 uwni-book 模版之效。試論分析學之種種，不能盡述也。
]

== 集論

=== ZFC 公理
// #emphblock[
//   dsfaf
//   df
// ]

=== 交集
#highlighteq($
  A union B = {x | x in A or x in B}
$)

// === 商集

=== 勢
集 $S$ 其元之數，名曰*勢*，記曰 $abs(S)$。例如 $abs({1, 2, 3}) = 3$。若 $(exists n in NN^*)abs(S) = n$，則稱 $S$ 爲*有限集*，否則爲*無限集*，如分數集，實數集等。無限集中，$abs(NN) = alef_0$ 若勢與自然數集之勢等，則名之*可數集*，否則曰*不可數集*。例如分數集爲可數集，實數集爲不可數集。有限集之勢皆自然數，且 $abs(emptyset) = 0$。何言其勢等？
$
  S tilde.equiv T <=> (exists f: S -> T) f "對射也"
$
此計數之抽象也，若有 $S = {suit.club.stroked, suit.diamond.stroked, suit.heart.stroked, suit.spade.stroked}$ 集，數以一二三四而知其勢乃 $4$ 也。編號計數法實乃一雙射: $S -> NN^*_(<=4)$ 也。無限集也，雖數不盡其元，猶可較也。若有集可令其元一一對應於自然數者，正如數盡自然數之勢也。

=== 幂集
集 $S$ 全子之所聚也，名曰冪集，記曰 $2^S := {x | x subset S }$。例如 $2^{1, 2} = {{}, {1}, {2}, {1, 2}}$。$S$ 冪集之勢 $abs(2^S) = 2^abs(S)$ 也，請以歸納法證明之:
$abs(2^emptyset) = abs({emptyset}) = 1$
,令
$abs(2^S) = 2^abs(S)$,
既添一新元 $x$ 於 $S$，其冪集必含原 $2^S$ 諸元，又以 $2^(S union {x})$ 之新添乃 $x$ 與舊 $2^S$ 諸元之合併故

$
  abs(2^(S union {x})) = overbrace(abs(2^S), "原" S "之勢") + underbrace(abs(2^S times {x}), "新添之勢") = 2^abs(S) + 2^abs(S) = 2^(abs(S)+1) = 2^(abs(S union {x}))
$

所證如是。


// === 界
=== 最大與最小
論以偏序集之構 $(T, prec.eq)$，若 $forall t exists m (m prec.eq t)$，則稱 $T$ 有*最小元* $m$，記曰 $min T = m$。若 $forall t exists M(t prec.eq M)$，則謂之有*最大元* $M$，記曰 $max T = M$。
設 $cal(S) := { S | S subset.eq T }$ 爲 $T$ 的子集族
$ max (union.big_(S in cal(S)) S) = max {max S | S in cal(S)} $
#multi-row($
  (forall t_1 in T_1)(forall t_2 in T_2)\ t_1 <= max T_1 <= max{max T_1, max T_2} and t_2 <= max T_2 <= max{max T_1, max T_2}
$)

- 有限偏序集不常有最大最小元。例如 $T = {suit.club.stroked, suit.diamond.stroked, suit.heart.stroked}$，偏序關係 $prec.eq = id$。所以無最大及最小元者，不可相較而已。
- 有限全序集常有最大最小元。請擬以歸納證明之
  + $abs(S) = 1$，$S$ 之元唯一，即最大最小元也。
  + $abs(S) = 2$，設 $S = {t_1, t_2}$，其最元得計算如下
    $
      max S = cases(t_1 quad "if" t_2 prec.eq t_1, t_2 quad "if" t_1 prec.eq t_2), wide
      min S = cases(t_1 quad "if" t_1 prec.eq t_2, t_2 quad "if" t_2 prec.eq t_1)
    $
  + 設 $abs(S) = N$，$S$ 有最大元 $M$ 與最小元 $m$。
  + 察 $abs(S) = N+1$，令 $S' = S without {s}$。
    由前款知 $S'$ 有最大元 $M'$ 與最小元 $m'$。然則 $max S = max{M', s}$, $min S = min{m', s}$ 也。即 $S$ 有最大最小元也。

集之界，不逾之境也。凡集 $S subset.eq T$ 之元 $s$，其或 $s <= M$ 者，則名 $M$ 爲 $S$ 一*上界*。反之，若 $M <= s$ 則喚作*下界*。若上下界並存，則謂之*有界*。界不必屬於集也。上界之最小者，號曰*上確界*，或曰最小上界，記曰 $sup S$。下界之最大者，號曰*下確界*，或曰最大下界，記曰 $inf S$。

$
  sup S = min{ t in T | s in S, s <= t}
$
$
  inf S = max{ t in T | s in S, t <= s}
$

例以上界與上確界，察其性質，凡有二項，一曰 $sup S$ 乃 $S$ 之上界也，二曰凡其上界莫小於 $sup S$ 也，即最小之上界也。
請問偏序集恆有上界乎？
1。有限集顯然恆有界，且 $sup S= max S$ 而 $inf S = min S$ 也。依序可列 $S$ 之元,


== 代數

=== 關係
稱集 $R subset.eq A times B$ 爲集 $A$，$B$ 上之*二元#index(modifier: "二元")[關係]*，畧以#index[關係]。若 $A = B$ 即 $R subset.eq A^2$ 則畧以 $A$ 上之關係。若以中綴表達式記 $a in A$ 與 $b in B$ 之適關係 $R$ 者，曰 $a R b$:
$
  a R b <=> (forall r in R)(exists a in A)(exists b in B)r = (a, b)
$
亦可記作前綴表達式並輔以括弧讀號，如 $R(a,b)$。這裡舉例同窗關係，朋友關係

=== 恆等關係
記 $S$ 上之*恆等#index(modifier: "恆等")[關係]*曰 $id_S$
$
  id_S := {(s, s) | s in S}
$
例如 $S = {suit.club.stroked, suit.diamond.stroked, suit.heart.stroked}$，$id_S = {(suit.club.stroked, suit.club.stroked), (suit.diamond.stroked, suit.diamond.stroked), (suit.heart.stroked, suit.heart.stroked)}$

=== 偏序關係
設以并關係集 $(S, prec.eq)$，並有
/ 自反性: $(forall s in S) s prec.eq s$
/ 反對稱性: $(forall s, t in S) s prec.eq t and t prec.eq s -> s = t$
/ 傳遞性: $(forall s, t, u in S) s prec.eq t and t prec.eq u -> s prec.eq u$
則名 $prec.eq$ 曰*偏序關係*。偏序關係之最小者，唯有恆等關係也。不難證明之。
+ $id$ 適自反性，反對稱性，傳遞性，故爲偏序關係也。
+ 凡 $(forall s in S) id without {(s, s)}$ 之關係皆以有違自反性而非偏序關係也。故最小也
+ 凡偏序關係必含 $id$ 也。可以歸謬法示其唯一也。

=== 全序關係
若改 $prec.eq$ 之自反性爲完全性，即
$
  "完全性":& quad (forall s, t in S) s prec.eq t or t prec.eq s \
  "反對稱性":& quad (forall s, t in S) s prec.eq t and t prec.eq s -> s = t\
  "傳遞性":& quad (forall s, t, u in S) s prec.eq t and t prec.eq u -> s prec.eq u
$

則謂之*全序#index(modifier: "全序")[關係]*，或曰*鏈*。凡全序之關係，恆偏序也。請備述之。全序關係滿足反對稱性與傳遞性，並以完全性蘊含自反性即知其亦偏序也。

// == 數域 <chap>

== 換元術
夫換元之術者，分析學之魂魄也。以之解方程，求積分，皆有其用。且其法之簡明，使人易於理解。換元本爲函數之複合，請例以如下。求函數 $f(x) = 1-x^2$ 之最大值。作換元 $g: x |-> cos t$ 得

$
  x stretch(->)^(g) cos t stretch(->)^(f) 1 - cos^2 t = sin^2 t
$

而其最值瞭然也。
簡記一階邏輯
$
  (forall a in A)p(a) <=> forall a(a in A -> p(a))
$



// == 數列
// 數列者，

== 數列單調收斂之定理
凡單調遞增數列之有上界者與單調遞減數列之有下界者，皆收斂。請證明之。
// == 自然數論
// === Peano 公理

== 整數論

#let mr = $stretch(-, size: #1em)$
#let dr = $slash slash$

相等關係
$
  a mr b = c mr d <=> a + d = b + c
$

凡自然數 $n$，察對射於 $NN -> {n mr 0 | n in NN}$ 上者 $n |-> n mr 0$。知整數之形如 $n mr 0$ 者同構於 $NN$ 也。故可以整數 $n$ 記自然數 $n mr 0$ 而無虞也。
逆元
$
  -a := 0 mr a
$

== 分數論

相等關係
$
  a dr b = c dr d <=> a d = b c
$
必有
$
  (exists x dr y in [a dr b]) gcd(x, y) = 1
$
*約式*，或曰*最簡分式*，分式之子母互素者也。例如 $1\/1$，$2\/3$，$5\/8$。以其子母皆最小，立爲 $QQ\/=$ 之代表元也。稠性: $a$

== 實數論
請問，正方形之對角線長 $l$ 幾何? 以勾股定理知 $l^2 = 2$，擬其長以一分數之約式 $l = p\/q$

#multi-row($
  l^2 = 2 <=> p^2 = 2 q^2
  <=> 2 divides p^2 <=> 2 divides p\
  <=> exists p'(p = 2 p') <=>
  2p'^2 = q^2 <=> 2 divides q^2 <=> 2 divides q
$)

$p$ 與 $q$ 皆偶數，而 $p \/ q$ 非約式也。故知 $l$ 非分數之屬也。以Ἵππασος之初覺爲嚆矢，分數之遺缺始昭於天下矣。此所以分數不可以度量也。

另察一例，有集分數其平方皆小於 $2$ 者
#let QQ2 = $QQ_(<sqrt(2))$
$
  QQ2 := {x in QQ | x^2 < 2}
$
即知有上界也。而無上確界。擬以歸謬法證之：
設其上確界爲 $macron(x)$，則 $forall x in QQ2, macron(x) >= x$，
$
  forall epsilon > 0, exists y in QQ2, macron(x) - epsilon < y
$

由全序關係之三歧性知
+ 若 $macron(x)^2 = 2$: 證偽
+ 若 $macron(x)^2 > 2$，需證明 $exists y in QQ2, y < macron(x)$，設 $y = macron(x) - epsilon$，並使 $y^2 > 2$。即 $y$ 爲上界而甚小耳。 $ (macron(x) - epsilon)^2 >= 2 <=> macron(x)^2 - 2 macron(x) epsilon + epsilon^2 > 2 arrow.l.double macron(x)^2 - 2 macron(x) epsilon >= 2 <=> epsilon <= (macron(x)^2 - 2) / (2 macron(x)) $
  不妨取 $epsilon = (macron(x)^2 - 2) / (2 macron(x))$，即爲證
+ 若 $macron(x)^2 < 2$，需證明 $exists y in QQ2, y > macron(x)$，設 $y = macron(x) + epsilon$。即 $macron(x)$ 乃非上界耳。 $ y^2 = (macron(x) + epsilon)^2 <= 2 <=> macron(x)^2 + 2 macron(x) epsilon + epsilon^2 < 2 arrow.l.double macron(x)^2 + 2 macron(x) epsilon <= 2 <=> epsilon <= (2 - macron(x)^2) / (2 macron(x)) $
  不妨取 $epsilon = (2 - macron(x)^2) / (2 macron(x))$，即爲證

故知 $QQ2$ #index[上確界]之不存也。

二例。#let QQ4 = $QQ_(<2)$
$
  QQ4 := {x in QQ | x^2 < 4}
$
可知 $x >= 2$ 皆上界也，而$sup QQ4 = 2$也

凡 $Q$ 爲 $QQ$ 上非空有上界子集，則定義為實數。
全序集 $(X, prec.eq)$。若其非空子集之有上界者有上確界。曰*序完備*

#proposition[
  以下三命題等價也
  + $(X, prec.eq)$ 序完備也
  + $X$ 非空子集之有下界者有下確界也
  + 凡 $∀A, B ⊆ X$ 不空，$∀a ∈ A, ∀b ∈ B, a ≤ b -> (∃c ∈ X)(∀a ∈ A, ∀b ∈ B) a <= c <= b$ 也。
]

== 極限
若夫極限者，古希臘之先賢始用，至 Cauchy#notefigure(image("assets/Augustin-Louis_Cauchy_1901.jpg"), caption: [Augustin-Louis Cauchy, 1789-1857]) 嚴明定義之，已歷數千年矣。然微分與無窮小之辯，相爭其存廢逾千載未能決也。其或爲 0，或幾及 0 而非 0。時 0 而時亦非 0，George Berkeley 等甚異之。而物理學家總以無窮小算得正確之結果，故不以爲謬也。數學之理也，必明必晰。然則應先申明極限為何物，而後可以道嚴謹之分析而無虞也。

#definition(title: [極限])[
  稱數列 ${a_n}$ 之極限曰

  $
    & lim_(n -> oo) a_n = L \
    <=> quad & (forall epsilon > 0) (exists N in NN^*) (forall n > N) abs(a_n - L) < epsilon
  $
]

極限者近而不逮，傍而未屆也。$a_n$ 之值將屆於 $L$ ，抑不之至。不得知也。若以 $epsilon-N$ 定義論之。恣取正數 $epsilon$，不論大小，必存一處 $N$，凡 $n$ 之後於 $N$ 者，$a_n$ 與 $L$ 相距幾微。何以知其然也? 蓋其相距小於 $epsilon$ 者也。凡正數者，皆見小於 $a_n$ 與 $L$ 之相距，此所以度量其近也。豈非因 $n$ 之漸長而 $a_n$ 幾及於 $L$ 耶？！

=== 單調有界性之定理

數列之收斂者，其極限必存焉。以單調有界性之定理得知其收斂而不得知其極限也。欲察極限幾何，猶須探其值而後驗以定義也。幸有各術如下以索數列之極限，一曰夾逼定理，二曰四則運算，三曰 Stolz-Cesàro 定理也。

=== 夾逼定理

夾逼定理者，求極限之要術也。設有數列 ${a_n}$、${b_n}$、${c_n}$，自某項起恆有 $a_n <= b_n <= c_n$，且 $lim_(n -> oo) a_n = lim_(n -> oo) c_n = L$，則必有 $lim_(n -> oo) b_n = L$ 也。

#proposition(title: [夾逼定理])[
  設數列 ${a_n}$、${b_n}$、${c_n}$ 滿足
  $
    (exists N in NN^*)(forall n > N) a_n <= b_n <= c_n
  $
  若 $lim_(n -> oo) a_n = lim_(n -> oo) c_n = L$，則 $lim_(n -> oo) b_n = L$。
]

#proof()[
  以極限定義證之。設 $forall epsilon > 0$，因 $lim_(n -> oo) a_n = L$，故
  $
    (exists N_1 in NN^*)(forall n > N_1) abs(a_n - L) < epsilon
  $
  即 $L - epsilon < a_n < L + epsilon$。同理，因 $lim_(n -> oo) c_n = L$，故
  $
    (exists N_2 in NN^*)(forall n > N_2) abs(c_n - L) < epsilon
  $
  即 $L - epsilon < c_n < L + epsilon$。

  取 $N_0 = max{N, N_1, N_2}$，則當 $n > N_0$ 時有
  $
    L - epsilon < a_n <= b_n <= c_n < L + epsilon
  $

  故 $abs(b_n - L) < epsilon$，即 $lim_(n -> oo) b_n = L$。
]

若數列 ${b_n}$ 之極限難求，但得覓取上下夾逼之數列 ${a_n}$ 與 ${c_n}$，則可藉求 ${a_n}$ 與 ${c_n}$ 之極限而得 ${b_n}$ 之極限也。

舉例以言之。
#example[
  請證 $ lim_(n -> oo) (sin n) / n = 0 $

  蓋 $abs(sin n) <= 1$，故 $ -1 / n <= (sin n) / n <= 1 / n $
  而 $lim_(n -> oo) 1 \/ n = lim_(n -> oo) (-1 \/ n) = 0$，由夾逼定理知 $lim_(n -> oo) (sin n) / n = 0$ 也。
]

夾逼定理不獨用於數列，亦可推廣於函數極限。設函數 $f(x)$、$g(x)$、$h(x)$ 於點 $x_0$ 之某鄰域內（或去心鄰域內）滿足 $f(x) <= g(x) <= h(x)$，且 $lim_(x -> x_0) f(x) = lim_(x -> x_0) h(x) = L$，則 $lim_(x -> x_0) g(x) = L$ 也。

=== 極限之代數運算
極限之加減乘除是也。設以 $lim_(n -> oo) a_n = L$，$lim_(n -> oo) b_n = M$，由定義知 $forall epsilon > 0$

#multi-row($
  &(exists N_a in NN^*) (forall n > N_a) abs(a_n - L) < epsilon \ and quad &(exists N_b in NN^*) (forall n > N_b) abs(b_n - M) < epsilon
$)

故而 $abs(-a_n - (-L)) = abs(a_n - L) < epsilon$，是以
$
  lim_(n -> oo) (-a_n) = -L
$<eq:lim-rev>
也。設 $N := max{N_a, N_b}$，以三角不等式
$
  abs(a_n + b_n - (L + M)) <= abs(a_n - L) + abs(b_n - M) < 2 epsilon
$
故而
$
  lim_(n -> oo) (a_n + b_n) = L + M
$<eq:lim-add>
並由@eq:lim-rev 可知 $lim_(n -> oo) (a_n - b_n) = L - M$ 也。

此所以極限之代數運算效也。
$
  abs(a_n b_n - L M)
$

== 級數論
級數者，數列之累和也。累數列 ${a_n}$ 前 $n$ 項之和，名曰 $s_n = sum_(k=0)^n a_k$。則記

$
  sum_(n=0)^oo a_n := lim_(n -> oo) s_n
$
爲*無窮級數*，畧作*級數*。其中凡 $a_n > 0$ 者，謂之*正項級數*。若 $s_n$ 收斂即曰級數收斂。$s_n$ 發散即謂之級數發散。

#proposition[
  凡級數 $sum_(n=0)^oo a_n$ 之收斂者
  $
    lim_(n -> oo) a_n = 0
  $
]
#proof[
  不妨設 $sum_(n=0)^oo a_n = L$，$s_n = sum_(k=0)^n a_k$ 收斂於 $L$。然則由極限定義知，於凡正數 $epsilon > 0$ 之中，必存有一自然數 $N$，而凡自然數 $n$ 之 $n > N + 1$ 者
  $
    abs(s_(n-1) - L) < epsilon / 2
  $
  然則 $ abs(s_n - L) < epsilon / 2 $
  又因 $s_n = s_(n-1) + a_n$，故 $forall n > N$
  $
    abs(s_n - L - (s_(n-1) - L)) <= abs(s_n - L) + abs(s_(n-1) - L) < epsilon
  $
  故 $lim_(n -> oo) a_n = 0$。
]

欲料反之然否，請道以下例。

#example(title: [調和級數])[
  調和級數者，形如 $sum_(n=1)^oo 1 \/ n$ 之級數也。雖 $1\/n -> 0$ 於 $n -> oo$，然其級數發散。請證以比較審斂法：

  $
    sum_(n=1)^oo 1 / n = 1 + 1 / 2 + 1 / 3 + 1 / 4 + 1 / 5 + 1 / 6 + 1 / 7 + 1 / 8 + dots.c
  $

  分組而計：
  $
    "原式" &= 1 + 1 / 2 + (1 / 3 + 1 / 4) + (1 / 5 + 1 / 6 + 1 / 7 + 1 / 8) + dots.c \
    &> 1 + 1 / 2 + (1 / 4 + 1 / 4) + (1 / 8 + 1 / 8 + 1 / 8 + 1 / 8) + dots.c \
    &= 1 + 1 / 2 + 1 / 2 + 1 / 2 + dots.c
  $

  無界而知其發散也。此為 Nicole Oresme 於十四世紀所證也。
]

有諸據可以斷級數之斂散。請道其詳。
=== 檢比術

=== 檢根術

== 常數 $eu$
常數 $eu$，或曰*自然底數*，初見於複利率之計算。凡 $n > 0$ 有定義曰
$ eu := lim_(n->oo) a_n = lim_(n -> oo) (1+1 / n)^n $
此處唯需證明 RHS 收斂。請道其證法
$
  a_n
  = sum_(k=0)^n binom(n, k)(1 / n)^k
  = sum_(k=0)^n n^(underline(k)) / (k! n^k)
$

$n^(underline(k)) / (k! n^k) >0$ ，則知 $a_n$ 之嚴格遞增矣。張之

$
  a_n &= sum_(k=0)^n 1 / k! n / n (n-1) / n dots.c (n-k+1) / n \
  &= sum_(k=0)^n 1 / k! (1 - 1 / n) dots.c (1 - (k-1) / n) \
$<eq:an-expand>

茲定義曰 $e_n := sum_(k=0)^n 1\/k!$ ，逐項比較即知 $a_n < e_n$

由 $(forall k >= 1) thick 1\/k! <= 1\/2^(k-1)$
$
  (1+1 / n)^n <= e_n
  &= 1 + 1 + 1 / 2 + 1 / (2 times 3) + dots.c + 1 / (2 times dots.c times (n-1) times n)\
  &<= 1 + 1 + 1 / 2 + 1 / (2 times 2) + dots.c + 1 / (2^(n-1))\
  &<= 3
$
抑由 $ (forall k >= 2) quad 1 / k! <= 1 / k(k-1) = 1 / (k-1) - 1 / (k) $
亦得所欲證。由定義知 $sup a_n = eu$ 也。
法前例亦可得證 $e_n$ 之收斂。然 $lim_(n->oo) e_n eq.quest eu$ 之真僞猶未可辨，不宜臆斷。

#let e_n_plot(n) = {
  range(n + 1).fold(
    0,
    (acc, k) => (
      acc + 1 / calc.fact(k)
    ),
  )
}
#let e_plot(n) = calc.pow(1 + 1 / n, n)


再證二者收斂於同處。庶幾以夾逼定理證之，唯需各項 $a_n < e_n < eu$。以上圖料其然也。然理學也非證不信非驗不服。請證之如下。令@eq:an-expand 之 $n -> oo$，左邊收斂於 $eu$ 而 $"右邊" tilde.eq e_n$ 也。故 $e_n < eu$，然則可以[假幣定理]得其證矣。

此二例以其典據垂於史，而級數之收斂至 $eu$ 者止此二例歟? 另察一例 $b_n = (1 + 1 \/ n)^(n+1)$ 可見
$
  lim_(n -> oo) b_n = lim_(n -> oo) (1 + 1 / n)a_n = lim_(n -> oo) a_n= eu
$
有違於前，$b_n$ 單調遞減並收斂至 $eu$ 也。請證明如下
$
  b_n / b_(n-1) =
  (1 + 1 / n)^(n+1) / (1 + 1 / (n-1))^n
  // = (1 + n^(-1)) (
  //   (1 + n^(-1))/(1 + (n-1)^(-1))
  // )^n \
  // = (1 + n^(-1)) (((1 + n^(-1)) (n-1)) / (n - 1 + 1))^n \
  // = (1 + n^(-1)) ((n-n^(-1))/n)^n \
  = (1 + 1 / n) (1 - 1 / n^2)^n \
$
欲證明 $forall n > 1$，$b_n\/b_(n-1) < 1$，即求證
$
  (1 - 1 / n^2)^n < n / (n+1)
$
凡 $x in (0, 1]$，因 $(1-x)(1+x) = 1-x^2 < 1$ 故 $(1-x)^n < (1+x)^(-n)$，
换元以 $x |-> 1\/n^2$，並乘兩邊以 $1+1\/n$，再以Bernoulli不等式得

$
  (1+1 / n )(1 - 1 / n^2)^n < (1+1 / n ) (1 + 1 / n^2)^(-n) < (1+1 / n )(1 + n / n^2)^(-1) = 1
$

$b_n\/b_(n-1) < 1$ 也。而 $b_n$ 之嚴格遞減可知矣。故 $inf b_n = eu$


=== 指數函數

定義 $exp$ 函數曰
#definition(
  title: [$exp$ 函數],
  $
    exp x := sum_(n=0)^oo x^n / n!
  $,
)

審其斂散，法以比值
$
  lr(abs(x^(n+1) / (n+1)!) mid(slash) abs(x^n / n!)) = abs(x / (n+1)) -> 0 " 當 " n -> oo
$

故冪級數 $exp x$ 於 $RR$ 處處絕對收斂也。

== 差分方程論
請問線性微分方程如 $y'' + y = 0$ 者當作何解？得特徵方程 $r^2 + 1 = 0$ 有根 $r = plus.minus i$ 故知通解爲 $y = c_1 cos x + c_2 sin x$。代入即明此誠爲其解也。此*全解*耶? 請論其理。
定義數列 ${x_n}$ 之*前向差分算子*曰
$ Delta x_n = x_(n+1) - x_(n) $
而*逆向差分算子*曰
$ nabla x_n = x_n - x_(n-1) $
$n >= 0$ 階差分遞歸定義曰

$
  Delta^n = cases(
    I &"if" n = 0,
    Delta compose Delta^(n-1) quad & "if" n > 0,
  )
$

因 $Delta (a x_n + b y_n) = a Delta x_n + b Delta y_n$，可知 $Delta$ 爲線性#index(modifier: "線性")[算子]。又以 $I$ 之線性，知 $Delta^n$ 亦線性也。
稱形如
$ sum_(k=0)^n a_k Delta^k x_k = b $
之方程式曰 $n$ *階常係數差分方程*。特稱 $b = 0$ 者爲*齊次*，否則爲*非齊次*。若有一列數 $hat(x)_n$ 可令 $x_n = hat(x)_n$ 滿足方程，則稱 $hat(x)_n$ 爲方程之*解*。
請探其性質。凡非齊次方程之解 ${hat(x)_n}$，${hat(y)_n}$，其和 ${hat(x)_n + hat(y)_n}$ 亦解矣
$
  sum_(k=0)^n a_k Delta^k (alpha hat(x)_k + beta hat(y)_k) = alpha sum_(k=0)^n a_k Delta^k hat(x)_k + beta sum_(k=0)^n a_k Delta^k hat(y)_k = 0
$
