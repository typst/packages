#import "@preview/modern-cug-report:0.1.0":*
// #import "../lib.typ": *

#counter(heading).update(2)
#let delta(x) = $Delta #x$

#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸散发的基本原理")

= 蒸散发的基本原理

== 物理基础

#box-red([
  *比热容* $c_p$：单位质量的物质升高1℃所需要的能量，$J \/ ("kg" ℃)$。

  根据比热容$c_p$的定义，可以得到温度变化引起的感热$H$：
  $ H = c_p rho V delta(T) $ <eq_h>
])

其中，$rho$: 空气密度，$V$: 空气体积。

#beamer-block([

  1. $R_n = 100 W m^(-2)$，全转为潜热，1天蒸发量是多少mm？#highlight()[考察点：汽化潜热]

    #nonum([$
      "LE" = 100 W m^(-2) times 86400 s = 8.64 "MJ" \
    $])
])


== 如何使用

=== 图件

```
#figure(
  image("Penman1948.png", width: 75%),
  caption: [Penman 1948水面蒸发示意图。]
) <fig_penman1948>
```

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
  )
)

=== 代码

```julia
function Fourier(y::AbstractVector{FT}, P::FT=length(y); 
  threshold=0.95) where {FT<:Real}
  Δt = P / N
  t = 0.0:Δt:(P-Δt)   # lenght(t) == N
  # freq = 1 ./ t
end
```

=== 参考文献

图件源自#[@monteith2013] Figure 3.4。

#bibliography("References.bib", title: "参考文献", style:"gb-7714-2015-author-date")
