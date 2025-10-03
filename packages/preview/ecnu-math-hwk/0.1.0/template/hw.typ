#import "@preview/ecnu-math-hwk:0.1.0": *
#set text(lang: "zh")

#show: hwk.with(author: "小花狮", course: [Typst 入门], hwk_id: 1, stu_id: 810975)

#let rank = math.op("rank")
#let End = math.op("End")

#problem[
  求矩阵的逆
  $
    A:=mat(2, 1, 3; 0, 1, 2; 1, 0, 3)
  $
]

#solution[
  使用伴随矩阵，可以得到
  $
    A^(-1) = frac(1, det A)A^\* = frac(1, 5) mat(3, -3, 1; 2, 3, -4; -1, 1, 2)
  $
]

#problem[
  求解线性方程组

  $
    mat(2, 1, 1; 1, 1, 1; 1, 2, 1) vec(x, y, z)=vec(4, 3, 4)
  $<eq>

]

#solution[
  对 @eq 对应的增广矩阵进行高斯消元
  $
    mat(2, 1, 1, 4; 1, 1, 1, 3; 1, 2, 1, 4; augment: #(-1)) --> mat(1, 0, 0, 1; 0, 1, 0, 1; 0, 0, 1, 1; augment: #(-1))
  $
  从而，解为 $(x,y,z)=(1,1,1)$.
]


#problem[
  若 $alpha_1=(1,3,4,-2)^(tack.b), alpha_2=(2,1,3,t)^(tack.b), alpha_3=(3,-1,2,0)^(tack.b)$ 线性相关，求 $t$.
]

#solution[
  考虑矩阵
  $
    A=mat(alpha_1, alpha_2, alpha_3)
  $
  不难验证 $alpha_1,alpha_3$ 线性无关，从而 $rank A>=2$，因为 $alpha_1,alpha_2,alpha_3$ 线性相关，得到 $rank A<3$，因此
  $rank A=2$。 由秩的性质：秩等于最大非零子式的阶数，得到
  $
    det mat(3, 1, -1; 4, 3, 2; -2, t, 0)=0 => t=-1
  $
  因此 $t=-1$.
]

#problem[
  设向量组 $alpha_1,alpha_2,alpha_3$ 线性无关，证明 $alpha_1+alpha_2, alpha_2+alpha_3,alpha_1+alpha_3$ 也线性无关。
]

#proof[
  考虑等式
  $
    &    & k_1(alpha_1+alpha_2)+k_2(alpha_2+alpha_3)+k_3(alpha_1+alpha_3) & =bold(0) \
    & => &                            k_1 alpha_1+k_2 alpha_2+k_3 alpha_3 & =bold(0)
  $<eq-2>
  由 $alpha_1,alpha_2,alpha_3$ 线性无关，得到 $k_1=k_2=k_3=0$，从而 $alpha_1+alpha_2, alpha_2+alpha_3,alpha_1+alpha_3$ 线性无关。
]

#problem[
  求下列向量组的一组基，并将其余向量用该基线性表示。
  $
    alpha_1 & =(1,2,-1,3)^(tack.b) \
    alpha_2 & =(2,4,-2,6)^(tack.b) \
    alpha_3 & =(1,0,1,1)^(tack.b) \
    alpha_4 & =(3,2,1,5)^(tack.b)
  $
]

#solution[
  注意到 $alpha_2=2 alpha_1, alpha_4=alpha_1+2 alpha_3$，且不难证明 $alpha_1,alpha_3$ 线性无关，因此 $\{alpha_1,alpha_3\}$ 是该向量组的一组基。
]

#problem[
  已知线性映射 $phi:RR^(3) -> RR^(4)$
  $
    phi lr(( vec(x_1, x_2, x_3) ))
    =
    vec(
      3x_1+2x_2+x_3,
      x_1+x_2+x_3,
      x_1-3x_2,
      2x_1+3x_2+x_3
    )
  $
  考虑 $RR^(3)$ 的一组标准基 $e_1,e_2,e_3$， $RR^(4)$ 的一组标准基 $hat(e_1),hat(e_2),hat(e_3),hat(e_4)$

  + 计算 $bold(A)_(phi)$ 。
  + 计算 $rank bold(A)_(phi)。$
]

#solution[
  + 由题意得
    #let A = math.mat(
      (3, 2, 1),
      (1, 1, 1),
      (1, -3, 0),
      (2, 3, 1),
    )
    $
      phi mat(e_1, e_2, e_3)=#A=mat(hat(e_1), hat(e_2), hat(e_3), hat(e_4)) #A
    $
    从而
    $
      bold(A)_(phi)=#A
    $
  + 通过初等行列变换消元，可以得到如下相抵关系：
    $
      bold(A)_(phi) tilde.op mat(
        1, 0, 0;
        0, 1, 0;
        0, 0, 1;
        0, 0, 0
      )
    $
    由相抵不变量得到 $rank bold(A)_(phi)=3$ 。
]

#problem[
  设 $cal(A) in End(RR^(3))$，定义如下
  $
    cases(
      cal(A)(eta_1) & =(-5,0,3)^(tack.b) \
      cal(A)(eta_2) & =(0,-1,6)^(tack.b) \
      cal(A)(eta_3) & =(-5,-1,9)^(tack.b),
    )
  $
  其中，
  $
    cases(
      eta_1 & =(-1,0,2)^(tack.b) \
      eta_2 & =(0,1,1)^(tack.b) \
      eta_3 & =(3,-1,0)^(tack.b)
    )
  $
  + 求 $cal(A)$ 在标准基 $e_1,e_2,e_3$ 下的矩阵。

  + 求 $cal(A)$ 在基 $eta_1,eta_2,eta_3$ 下的矩阵。
]

#solution[
  + 由题意得
    $
      cal(A) mat(eta_1, eta_2, eta_3) & =mat(e_1, e_2, e_3) P \
             mat(eta_1, eta_2, eta_3) & =mat(e_1, e_2, e_3) S
    $
    其中，
    $
      P=mat(-5, 0, -5; 0, -1, -1; 3, 6, 9), S=mat(-1, 0, 3; 0, 1, -1; 2, 1, 0)
    $
    从而得到
    $
         && cal(A) mat(e_1, e_2, e_3) S & =mat(e_1, e_2, e_3) P \
      => &&   cal(A) mat(e_1, e_2, e_3) & =mat(e_1, e_2, e_3) P S^(-1)
    $
    因此， $cal(A)$ 在标准基 $e_1,e_2,e_3$ 下的矩阵为
    $
      A:=P S^(-1)=frac(1, 7) mat(-5, 20, -20; -4, -5, -2; 27, 18, 24)
    $
  + 由于
    $
               cal(A) mat(e_1, e_2, e_3) & =mat(e_1, e_2, e_3) A \
      => cal(A) mat(eta_1, eta_2, eta_3) & =mat(eta_1, eta_2, eta_3) S^(-1) A S
    $
    从而，矩阵为
    $
      S^(-1) A S = mat(2, 3, 5; -1, 0, -1; -1, 1, 0)
    $
]
