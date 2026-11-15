#import "@preview/ecnu-math-hwk:0.1.1": *
#set text(lang: "en")

#show: hwk.with(author: "Fuhan", course: [Linear Algebra], hwk-id: 1, stu-id: 10245501401)

#let rank = math.op("rank")
#let End = math.op("End")

#problem[
  Find the inverse of the matrix
  $
    A:=mat(2, 1, 3; 0, 1, 2; 1, 0, 3).
  $
]

#solution[
  Using the adjugate formula, we obtain
  $
    A^(-1) = frac(1, det A)A^\* = frac(1, 5) mat(3, -3, 1; 2, 3, -4; -1, 1, 2).
  $
]

#problem[
  Solve the linear system
  $
    mat(2, 1, 1; 1, 1, 1; 1, 2, 1) vec(x, y, z)=vec(4, 3, 4).
  $<eq>
]

#solution[
  Apply Gaussian elimination to the augmented matrix associated with @eq:
  $
    mat(2, 1, 1, 4; 1, 1, 1, 3; 1, 2, 1, 4; augment: #(-1)) --> mat(1, 0, 0, 1; 0, 1, 0, 1; 0, 0, 1, 1; augment: #(-1)).
  $
  Therefore, the solution is $(x,y,z)=(1,1,1)$.
]

#problem[
  Suppose
  $alpha_1=(1,3,4,-2)^(tack.b)$,
  $alpha_2=(2,1,3,t)^(tack.b)$, and
  $alpha_3=(3,-1,2,0)^(tack.b)$
  are linearly dependent. Find $t$.
]

#solution[
  Consider the matrix
  $
    A=mat(alpha_1, alpha_2, alpha_3).
  $
  The vectors $alpha_1$ and $alpha_3$ are linearly independent, so $rank A>=2$. Since
  $alpha_1,alpha_2,alpha_3$ are linearly dependent, $rank A<3$. Hence $rank A=2$.
  The rank equals the order of the largest nonzero minor, so
  $
    det mat(3, 1, -1; 4, 3, 2; -2, t, 0)=0 => t=-1.
  $
  Therefore, $t=-1$.
]

#problem[
  Let $alpha_1,alpha_2,alpha_3$ be linearly independent. Prove that
  $alpha_1+alpha_2$, $alpha_2+alpha_3$, and $alpha_1+alpha_3$ are also linearly independent.
]

#proof[
  Suppose
  $
    &    & k_1(alpha_1+alpha_2)+k_2(alpha_2+alpha_3)+k_3(alpha_1+alpha_3) & =bold(0). \
    & => & (k_1+k_3)alpha_1+(k_1+k_2)alpha_2+(k_2+k_3)alpha_3 & =bold(0)
  $<eq-2>
  Since $alpha_1,alpha_2,alpha_3$ are linearly independent, @eq-2 implies
  $k_1+k_3=k_1+k_2=k_2+k_3=0$. Thus $k_1=k_2=k_3=0$, proving the result.
]

#problem[
  Find a basis for the following set of vectors, and express each remaining vector as a linear
  combination of that basis:
  $
    alpha_1 & =(1,2,-1,3)^(tack.b), \
    alpha_2 & =(2,4,-2,6)^(tack.b), \
    alpha_3 & =(1,0,1,1)^(tack.b), \
    alpha_4 & =(3,2,1,5)^(tack.b).
  $
]

#solution[
  We have $alpha_2=2 alpha_1$ and $alpha_4=alpha_1+2 alpha_3$. Moreover, $alpha_1$ and
  $alpha_3$ are linearly independent. Therefore, $\{alpha_1,alpha_3\}$ is a basis for the set.
]

#problem[
  Let $phi:RR^(3) -> RR^(4)$ be the linear map
  $
    phi lr(( vec(x_1, x_2, x_3) ))
    =
    vec(
      3x_1+2x_2+x_3,
      x_1+x_2+x_3,
      x_1-3x_2,
      2x_1+3x_2+x_3
    ).
  $
  Use the standard bases $e_1,e_2,e_3$ of $RR^(3)$ and
  $hat(e_1),hat(e_2),hat(e_3),hat(e_4)$ of $RR^(4)$.

  + Compute the matrix $bold(A)_(phi)$.
  + Compute $rank bold(A)_(phi)$.
]

#solution[
  + By definition,
    #let A = math.mat(
      (3, 2, 1),
      (1, 1, 1),
      (1, -3, 0),
      (2, 3, 1),
    )
    $
      phi mat(e_1, e_2, e_3)=#A=mat(hat(e_1), hat(e_2), hat(e_3), hat(e_4)) #A.
    $
    Hence
    $
      bold(A)_(phi)=#A.
    $
  + Elementary row operations give
    $
      bold(A)_(phi) tilde.op mat(
        1, 0, 0;
        0, 1, 0;
        0, 0, 1;
        0, 0, 0
      ).
    $
    Therefore, $rank bold(A)_(phi)=3$.
]

#problem[
  Let $cal(A) in End(RR^(3))$ be defined by
  $
    cases(
      cal(A)(eta_1) & =(-5,0,3)^(tack.b),
      cal(A)(eta_2) & =(0,-1,6)^(tack.b),
      cal(A)(eta_3) & =(-5,-1,9)^(tack.b),
    )
  $
  where
  $
    cases(
      eta_1 & =(-1,0,2)^(tack.b),
      eta_2 & =(0,1,1)^(tack.b),
      eta_3 & =(3,-1,0)^(tack.b).
    )
  $

  + Find the matrix of $cal(A)$ with respect to the standard basis $e_1,e_2,e_3$.
  + Find the matrix of $cal(A)$ with respect to the basis $eta_1,eta_2,eta_3$.
]

#solution[
  + From the definition,
    $
      cal(A) mat(eta_1, eta_2, eta_3) & =mat(e_1, e_2, e_3) P, \
             mat(eta_1, eta_2, eta_3) & =mat(e_1, e_2, e_3) S,
    $
    where
    $
      P=mat(-5, 0, -5; 0, -1, -1; 3, 6, 9), quad S=mat(-1, 0, 3; 0, 1, -1; 2, 1, 0).
    $
    It follows that
    $
         && cal(A) mat(e_1, e_2, e_3) S & =mat(e_1, e_2, e_3) P, \
      => &&   cal(A) mat(e_1, e_2, e_3) & =mat(e_1, e_2, e_3) P S^(-1).
    $
    Therefore, the matrix of $cal(A)$ in the standard basis is
    $
      A:=P S^(-1)=frac(1, 7) mat(-5, 20, -20; -4, -5, -2; 27, 18, 24).
    $
  + Since
    $
               cal(A) mat(e_1, e_2, e_3) & =mat(e_1, e_2, e_3) A, \
      => cal(A) mat(eta_1, eta_2, eta_3) & =mat(eta_1, eta_2, eta_3) S^(-1) A S,
    $
    the matrix in the basis $eta_1,eta_2,eta_3$ is
    $
      S^(-1) A S = mat(2, 3, 5; -1, 0, -1; -1, 1, 0).
    $
]
