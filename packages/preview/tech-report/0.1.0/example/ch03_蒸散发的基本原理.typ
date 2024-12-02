#import "../lib.typ": *
#counter(heading).update(2)
#let delta(x) = $Delta #x$

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸散发的基本原理")

= 蒸散发的基本原理

== 物理基础

=== 气化潜热

#showybox(frame: (
    // title-color: red.darken(30%),
    border-color: blue.darken(10%),
    body-color: blue.lighten(95%) ), 
    // title: [*比热容*]
  )[
  
  *气化潜热* $lambda$：单位质量的液体，气化所需要吸收的热量，$"MJ"\/"kg"$。
  $ lambda = 2.5 "MJ" "kg"^(-1) $
]

  根据气化潜热$lambda$的定义，可以得到潜热$"LE"$：

  $ "LE" = lambda delta(m_v) = lambda delta(rho_v) V $ <eq_le>

其中，$delta(m_v)$是蒸发导致的水汽质量的变化，$"LE"$是蒸发所需的能量，$rho_v$水汽的密度。

你可以这样引用公式#[@eq_le]。

=== 比热容

#box_red([
  *比热容* $c_p$：单位质量的物质升高1℃所需要的能量，$J \/ ("kg" ℃)$。

  根据比热容$c_p$的定义，可以得到温度变化引起的感热$H$：
  $ H = c_p rho V delta(T) $ <eq_h>
])

其中，$rho$: 空气密度，$V$: 空气体积。

#beamer_block([
  *小试牛刀：*

  1. $R_n = 100 W m^(-2)$，能量全部转换为潜热，1天的总能量为多少？对应的蒸发量是多少mm？#highlight()[考察点：汽化潜热]

    #nonum([$
      "LE" = 100 W m^(-2) times 86400 s = 8.64 "MJ" \
      E = "LE"/lambda = (8.64 "MJ") / (2.5 "MJ" "kg"^(-1)) = 3.456 "kg" \
    $])

  2. $1m^3$的空气，温度升高1℃，需要吸收多少能量？#highlight()[考察点：比热容]
  
    空气的比热容$c_p = 1103 J \/ ("kg" ℃)$，空气的密度$rho = 1.2 "kg" \/ m^3$。

    #nonum([$ 
      m = rho V = 1.2 times 1 = 1.2 "kg" \
      H = 1103 J \/ ("kg" ℃) times 1.2"kg" times 1℃ = 1323.6 J 
    $])
])

// === 湿度计常数

// 湿度计常数，通过如下公式推导得到：
// $ R_n = "LE" + H $

// 上式忽略了土壤热通量$G$，主要是因为土壤热通量$G$在长时间尺度仅占10%左右。当$R_n = 0$的情景下，感热与潜热相加等于0，二者相互转换。

// 代入公式#[@eq_le]和#[@eq_h]代入上式，同时借用水汽压与水汽密度的转换公式#[@eq_rho_v]（$delta(rho_v) = epsilon rho delta(e) /P$），可以得到：

// $
//   lambda delta(rho_v) V + c_p rho V delta(T) = 0 \
//   delta(rho_v) = -c_p rho delta(T) / lambda \ 
//   epsilon rho delta(e) /P = -c_p delta(T) / lambda \
//   delta(e) = -(c_p P)  / (epsilon lambda) delta(T) \
//   delta(e) = -gamma delta(T) \
// $

// 其中，$gamma$是湿度计常数，单位$"Pa"\/℃$。

// === 干球温度与湿球温度

// - *湿球温度*：百叶箱中避光情景下（$R_n=0$），湿布包裹，充分供水，蒸发降温得到的最低温度。

// *(a) $R_n = 0$*

//   如图#[@fig_Tdry_Twet]，从X -> Y过程，$lambda E + H = 0$，X -> Y，令$delta(e) = "es"(T') - e$，可以得到：
//   $
//     lambda E [X -> Y] = lambda delta(rho_v) V
//      = lambda epsilon rho delta(e) / P V, (rho_v = epsilon rho e / P) \
//   $
//   $ H[X -> Y] = c_p rho V delta(T) $
  
//   代入能量平衡公式：

//   $ 
//     lambda E [X -> Y] + H[X -> Y] = 0 \
//     lambda epsilon rho delta(e) / P V + c_p rho V delta(T) = 0 \ 
//     lambda epsilon delta(e) / P + c_p delta(T) = 0 
//   $
//   $ delta(e) = -gamma delta(T), (gamma = (c_p P) / (epsilon lambda) ) $

//   其中，$delta(e)$和$delta(T)$分别表示$X->Y$过程中，水汽压和温度的变化。

//   - $delta(e) = "es"(T') - e$, 如图#[@fig_Tdry_Twet]，从$X->Y$水汽压变大，是一个蒸发的过程；

//   - $delta(T) = T' - T$，是一个降温的过程。
  

//   #box_red[
//     根据该情景，可以推出湿球温度的理论值。
//   ]

  
// #figure(
//   image("images/蒸散发/湿球温度计算.png", width: 80%),
//   caption: [
//     干球温度与湿球温度示意图。
//   ]
// ) <fig_Tdry_Twet>

// *(b) $R_n > 0$，且充分供水*

// 若充分供水，空气中的水汽压可达到饱和，意味着初始状态和结束状态，都处于饱和水汽压曲线上，正如从$Y->A$过程（图#[@fig_Tdry_Twet]）。

// $
//   lambda E [Y -> A] = lambda delta(rho_v) V
//    =& lambda epsilon rho delta(e) / P V, (delta(e) = "es"(T_A) - "es"(T_Y)) \
//    =& lambda epsilon rho abs("OA") / P V 
//   // c_p rho V delta(T)
// $

// $
//   H[Y -> A] =& H[Y -> X] = -lambda E [Y -> X] \
//             =& lambda E [X -> Y] \
//             =& lambda epsilon rho ("es"(T') - e) / P V = lambda epsilon rho abs("OX") / P V
// $

// 因此，

// $  
//   Delta = abs("OA") / abs("OY"), gamma = abs("YB") / abs("BX") = abs("OX") / abs("OY")  \ 

//   (lambda E [Y -> A]) / H[Y -> A] = abs("OA") / abs("OX")  = Delta / gamma
// $

// 联立方程，即可解出$lambda E$和$H$：

// $ cases( 
//   R_n = lambda E + H \
//   (lambda E ) / H = Delta / gamma
// ) $

// $ lambda = (Delta R_n) / (Delta + gamma) $
// $ H = (gamma R_n) / (Delta + gamma) $

// *(c) $R_n > 0$，供水不充分*

// 如图#[@fig_Tdry_Twet]，从X -> A过程，初始状态水汽压不饱和。
// #box_red([
//   求解的过程，将该过程划分为两段：$X -> Y$ 和$Y -> A$两段，分别写出两段的感热与潜热，之后相加即可得到，在此不再赘述。
// ])

// // #pagebreak()


// == 通量

// #beamer_block([“百花丛中过，片叶不沾身”——通量])

// #showybox(frame: (
//     // title-color: red.darken(30%),
//     border-color: blue.darken(10%),
//     body-color: blue.lighten(95%) ), 
//     // title: [*比热容*]
//   )[
//   若能量全部转换为感热，1天的总能量为多少？对应的温度升高是多少℃？

//   #nonum([$
//     H = 100 W m^(-2) times 86400 s = 8.64 "MJ" \
//     delta(T) = H / (c_p rho V) = (8.64 "MJ") / (1103 J \/ ("kg" ℃) times 1.2 "kg") = 6528 ℃
//   $])

//   $delta(T)$按10℃算，$1 m^3$空气，升温所需要的能量：

//   #nonum([$
//     E_H =1103 J \/ ("kg" ℃) times 1.2"kg" times 10℃ = 13,236 J 
//   $])
// ]

// *为何会出现这种现象？* #highlight([主要是因为干净的空气是个“小透明”])，拦截辐射的能力较弱。正常情况下，Rn=100 $W\/m^2$，升温幅度在10℃左右（图@fig1_yuchen），空气升温所耗的能量$E_H$仅占总能量的0.15%。

// *那能量都去哪里了？*

// #beamer_block([大部分能量是穿过，而非截留。])

// #figure(
//   image("images/蒸散发/通量-水汽.png", width: 80%),
//   caption: [
//     水汽通量。
//     ]
// ) <fig_flux_le>

// === 潜热通量

// #highlight()[*(a) 比湿的形式：*]

// $ E = -D pdv(rho_v, z) = -D rho pdv(q, z) $

// - D是水汽的分子扩散系数，单位$m^2\/s$。

// 在积分过程中，认为大气的状态达到均衡，认为E是常数。从地表$z_1$到参考高度$z_2$进行积分，可以得到：

// $ integral_(z_1)^(z_2) E  d z = integral_(z_1)^(z_2) -D rho d q $

// $ lambda E &= - lambda D rho (integral_(z_1)^(z_2) d q) / (integral_(z_1)^(z_2) d z) \
//     &= lambda rho (q(z_1) - q(z_2)) / ((z_2 - z_1) / D) \
//     &= lambda (rho delta(q)) / r_v, (r_v = (z_2 - z_1) / D)
// $

// 上式，定义了水汽传递阻力$r_v$ ($s\/m$)，导度$g_v$等于阻力的倒数（$g_v = 1/r_v$, $m\/s$），$delta(q) = q(z_1) - q(z_2)$。蒸发的水汽通常来源于湿润的地表。一般而言，$q(z_1) > q(z_2)$。

// #highlight()[*(b) 水汽压的形式：*]

// $ $

// $ lambda E &= -lambda D pdv(rho_v, z) 
//     = -lambda D ( epsilon rho) / P pdv(e, z), (rho_v = (epsilon rho)/ P e ) \
//   &= -(D rho c_p) / gamma pdv(e, z), (gamma = (c_p P) / (epsilon lambda) )
// $

// $ lambda E &= -(D rho c_p) / gamma (integral_(z_1)^(z_2) d e ) / (integral_(z_1)^(z_2) d z  )  \
//    &= -(D rho c_p) / gamma (e(z_2) - e(z_1)) / (z_2 - z_1)
//     = (rho c_p delta(e)) / (gamma r_v), (r_v = (z_2 - z_1) / (D) )
// $

// // = -D rho pdv(q, z) 

// === 感热通量

// #figure(
//   image("images/蒸散发/通量-热量.png", width: 80%),
//   caption: [
//     感热通量。图件源自#[@monteith2013] Figure 3.3。
//     ]
// ) <fig_flux_le>

// $ H = -k pdv(rho c_p T, z)  = - k rho c_p pdv(T, z) $

// $ integral_(z_1)^(z_2) H d z = integral_(z_1)^(z_2) - k rho c_p d T $

// $ H =& - k rho c_p (integral_(z_1)^(z_2) d T ) / (integral_(z_1)^(z_2) d z) \
//     =& k rho c_p (T(z_1) - T(z_2)) / (z_2 - z_1) \
//     =& (rho c_p delta(T)) / r_H, (r_H = (z_2 - z_1) / k)
// $

// // - $kappa$：热传导系数，单位$W\/(m K)$；
// - $k$：热扩散系数，单位$m^2\/ s$；
// - $H$: 感热通量，单位$W\/m^2$；
// - $c_p$: 比热容，单位$J\/("kg" K)$；
// - $rho$: 空气密度，单位$"kg"\/m^3$；
// - $r_H$: 热量的传递阻力，单位$s\/m$；

// #beamer_block([$rho c_p$的作用是把$Delta T$转化为能量的单位。])

// === 修正湿度计常数

// 考虑水汽和热量的传递阻力后，如图#[@fig_Tdry_Twet]，感热与潜热的公式变形为：

// $ lambda E = lambda (epsilon rho delta(e)) / (P r_v) V, H = (rho c_p delta(T)) / r_H V $

// $lambda E + H = 0$ 可得，
// $ 
//   lambda epsilon delta(e) / (P r_v) = - c_p delta(T) / r_H
//    delta(e) / ( r_v) = - (c_p P) / (lambda epsilon) r_v / r_H delta(T)
// $

// 令$gamma^* = (c_p P) / (lambda epsilon) r_v / r_H = gamma r_v / r_H $。$gamma^*$被称为修正湿度计常数。


== 如何使用

=== 图件

#figure(
  image("Penman1948_示意图.png", width: 75%),
  caption: [Penman 1948水面蒸发示意图。]
) <fig_penman1948>

=== 表格

#figure(
  caption: [土壤类型、$K$、与$K"lat"_"factor"$值。表格出自Fan et al. (2007) Table 2。],
  table(
    columns: (1.5cm, 4cm, 3cm, 2cm),
    // inset: 10pt,
    align: horizon,
    table.header(
      [*编号*], [*土壤类型*], [*$K$*], [*$K"lat"_"factor"$*],
    ),
    [1], "sand", [15.2064], [2],
    [1], [sand], [15.2064], [2], 
    [2], [loamy sand], [13.5043], [3], 
    [3], [sandy loam], [2.9981], [4], 
    [4], [silt loam], [0.6221], [10], 
    [5], [loam], [0.6048], [12], 
    [6], [sandy clay loam], [0.5443], [14], 
    [7], [silty clay loam], [0.1210], [20], 
    [8], [clay loam], [0.2160], [24], 
    [9], [sandy clay], [0.1901], [28], 
    [10], [silty clay], [0.0864], [40], 
    [11], [clay], [0.1123], [48], 
    [12], [peat], [0.6912], [2]
  )
)

=== 代码

```julia
function Fourier(y::AbstractVector{FT}, P::FT=length(y); 
  threshold=0.95) where {FT<:Real}
  N = length(y)
  Δt = P / N
  t = 0.0:Δt:(P-Δt)   # lenght(t) == N
  # freq = 1 ./ t
  freq = fftfreq(N, 1 / Δt)
  ## 快速傅里叶变化
  len = N ÷ 2
  Fy = fft(y)[1:len]
  ak = 2 / N * real.(Fy)
  bk = -2 / N * imag.(Fy)  # fft sign convention
  ak[1] = ak[1] / 2

end
```

=== 参考文献

图件源自#[@monteith2013] Figure 3.4。


// 这里水面蒸发指的是：从水面到参考高度（一般指2m）的潜热通量，图中从点W到Y的过程。

// $ lambda E [W -> X] = -H[W -> X] = (rho c_p D) / r_H $
// $ lambda E [X -> Y] = (Delta R_n) / (Delta + gamma^*) $
// $ lambda E [Y -> Z] = -H[Y -> Z] = -(rho c_p D_0) / r_H $

// $W -> Z$，对应的蒸发面水汽不饱和，该过程总的潜热和感热为：

// $ lambda E [W -> Z] = (Delta R_n) / (Delta + gamma^*) + (rho c_p (D - D_0)) / r_H $

// $
//   H [W -> Z] =& R_n - lambda E [W -> Z] \
//     =&  (gamma^* R_n) / (Delta + gamma^*) - (rho c_p (D - D_0)) / r_H
// $

// 若蒸发面水汽饱和（充分供水），则是$W -> Y$过程：

// $ lambda E [W -> Y] = (Delta R_n) / (Delta + gamma^*) + (rho c_p D) / r_H $ <ch3_eq37>

// $
//   H [W -> Y] =& R_n - lambda E [W -> Z] \
//     =&  (gamma^* R_n) / (Delta + gamma^*) - (rho c_p D) / r_H
// $ <ch3_eq38>

// *另一种推导方法：暴力求解*

// 跳过图#[@fig_Tdry_Twet]和#[@fig_penman1948]的几何过程，针对$W -> Y$（图#[@fig_penman1948]，湿表面到空气的热量与水汽交互）的过程，采用暴力求解。

// 下标$""_w$和$""_a$分别代表湿表面和空气。空气指的是参考高度处的空气，一般为2m。

// $ H = R_n - lambda E =  rho c_p (T_w - T_a) \/ r_H $ <ch3_2_h>

// $ 
//   lambda E = lambda epsilon rho (e_w - e_a) / (P r_v) 

//    &= rho c_p (e_w - e_a) / (gamma^* r_H) = rho c_p ("es"(T_w) - e_a) / (gamma^* r_H) $ <ch3_eq40>

// 其中，认为水面的水汽压为饱和$e_w  = "es"(T_w)$，
// $
//   e_w - e_a = "es"(T_w) - e_a = "es"(T_w) - "es"(T_a) + "es"(T_a) - e_a \ = "es"(T_w) - "es"(T_a) + "VPD"
// $

// $ lambda E = rho c_p ("es"(T_w) - "es"(T_a) + "VPD") / (gamma^* r_H) \ 
// = rho c_p (Delta (T_w - T_a) + "VPD") / (gamma^* r_H) $ <ch3_2_le>

// 求出#[@ch3_2_h]中的$T_w - T_a$，代入#[@ch3_2_le]，可以得到：

// $
//   lambda E = (Delta R_n) / (Delta + gamma^*) + (rho c_p "VPD" \/ r_H)  / (Delta + gamma^*) 
// $ <ch3_pm_le>

// $
//   H = (gamma^* R_n) / (Delta + gamma^*) - (rho c_p "VPD" \/ r_H)  / (Delta + gamma^*) 
// $ <ch3_pm_h>

// #box_red([为何与#[@ch3_eq37]和#[@ch3_eq38]的结果不同？

// #nonum([$
//   lambda E = (Delta R_n) / (Delta + gamma^*) + rho c_p D \/ r_H
// $])

// *其实他们是等价的，因为$ "VPD" = D (Delta + gamma^*)$。*可借助图#[@fig_penman1948]的几何关系，推导得出。
// ])

// === 叶片与冠层蒸发 (Monteith 1965)

// #figure(
//   image("images/蒸散发/叶片蒸发.png", width: 70%),
//   caption: [
//     叶片蒸腾阻力示意图。图件源自#[@monteith2013] Figure 13.4。
//   ]
// ) <fig_monteith>

// 相比于水面蒸发，叶片蒸发在水汽传导阻力中多了气孔阻力。因此，$H$的表达形式不变，$lambda E$的表达形式变为：

// $ 
//   lambda E &= lambda epsilon rho (e_w - e_a) / (P (r_v + r_s) ) = 
//     rho c_p (e_w - e_a) / (gamma (r_v + r_s) ), 
//     gamma = (c_p P) / (lambda epsilon)
// $ <ch3_eq45>

// 重新联立公式#[@ch3_2_h]，可以得到：

// $ gamma^* = gamma (r_v + r_s) / r_H $

// $
//   lambda E &= (Delta R_n + rho c_p "VPD" \/ r_H) / (Delta + gamma^*)  \
//    &= (Delta R_n + rho c_p "VPD" \/ r_H) / (Delta + gamma ( 1 + r_s/r_H)) 
// $ <ch3_monteith1965>

// #beamer_block([
// 这里认为$r_H approx r_v$。根据辐射理论 #[@monteith2013] ，$r_v = (kappa / D)^0.67 r_H approx 0.93 r_H$。
// D是水汽的分子扩散系数，单位$m^2\/s$。$kappa$是空气的热扩散系数，单位$m^2\/s$。
// ])

// === 参考作物蒸发 (FAO98)

// // #beamer_block([
//   一种假想的参考作物，高度为0.12m，固定的地表阻力为70 $s\/m$，反射率为0.23。

//   A hypothetical reference crop with an assumed crop height of 0.12 m, a fixed surface resistance of 70 $s\/m$ and an albedo of 0.23.
// // ])

// #figure(
//   image("images/蒸散发/参考作物_FAO98_Figure9.png", width: 70%),
//   caption: [
//     参考作物蒸发示意图。图件源自FAO No. 56, Figure 9。
//   ]
// ) <fig_fao98>

// == 实际蒸发

// #figure(
//   image("images/蒸散发/根区土壤水分布.png", width: 85%),
//   caption: [根区土壤水分布。]
// ) <fig_>

// === 植被蒸腾与植被光合

// === 蒸散发与土壤水之间的关系

// 无论是土壤蒸发还是植被蒸腾，都与土壤水分有关。

几种不同格式的参考文献：
- `gb-7714-2005-numeric`: China National Standard GB/T 7714-2005 (numeric, 中文)

- `gb-7714-2015-author-date`: China National Standard GB/T 7714-2015 (author-date, 中文)

- `gb-7714-2015-note`: China National Standard GB/T 7714-2015 (note, 中文)

- `gb-7714-2015-numeric`: China National Standard GB/T 7714-2015 (numeric, 中文)

#bibliography("References.bib", title: "参考文献", style:"gb-7714-2015-author-date")
