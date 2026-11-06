// #import "@local/modern-cug-report:0.1.0":*
#import "@local/modern-cug-report:0.1.3": *
// #import "@preview/modern-cug-report:0.1.0": *
// #import "../lib.typ": *
#counter(heading).update(2)
#show: (doc) => template(doc, 
  footer: "CUG水文气象学2024",
  header: "蒸散发的基本原理")

= 1 蒸散发的基本原理

== 1.1 物理基础

=== 1.1.1 气化潜热

#box-blue()[
  *气化潜热* $lambda$：单位质量的液体，气化所需要吸收的热量，$"MJ"\/"kg"$。
  $ lambda = 2.5 "MJ" "kg"^(-1) $
]

  根据气化潜热$lambda$的定义，可以得到潜热$"LE"$：

  $ "LE" = lambda delta(m_v) = lambda delta(rho_v) V $ <eq_le>

其中，$delta(m_v)$是蒸发导致的水汽质量的变化，$"LE"$是蒸发所需的能量，$rho_v$水汽的密度。

你可以这样引用公式#[@eq_le]。

=== 1.1.2 比热容

#box-red([
  *比热容* $c_p$：单位质量的物质升高1℃所需要的能量，$J \/ ("kg" ℃)$。

  根据比热容$c_p$的定义，可以得到温度变化引起的感热$H$：
  $ H = c_p rho V delta(T) $ <eq_h>
])

其中，$rho$: 空气密度，$V$: 空气体积。

#beamer-block([
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


== 1.2 如何使用

=== 1.2.1 图表

#figure(
  image("Penman1948.png", width: 70%),
  caption: [Penman 1948水面蒸发示意图。]
) <fig_penman1948>

#show figure.caption: set par(spacing: 2.24em)

#figure(
  caption: [
    // #v(-1em)
    土壤类型、$K$、与$K"lat"_"factor"$值。表格出自Fan et al. (2007) Table 2。表格出自Fan et al. (2007) Table 2。表格出自Fan et al. (2007) Table 2。表格出自Fan et al. (2007) Table 2。],
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
) <table_soil_param>

#box-blue[
  采用`#[@fig_label]`的方式引用图件：如图#[@fig_penman1948]。

  采用相似的方法`#[@table_label]`引用表格：如表#[@table_soil_param]。
]


=== 1.2.2 代码

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


=== 1.2.3 研究基础

#ref-list(
  [[1]],
  [
    Su, W., T. P. Charlock, and F. G. Rose, 2005: Deriving surface ultraviolet radiation from CERES surface and atmospheric radiation budget: Methodology. _*J. Geophys. Res.*_, 110(D14209), doi: 10.1029/2005JD005794.
  ],
  [[2]],
  [
    Su, W., T. P. Charlock, F. G. Rose, and D. Rutan, 2007: Photosynthetically active radiation from clouds and the earth’s radiant energy system (CERES) products. _*J. Geophys. Res.*_, 112(G02022), doi: 10.1029/2006JG000290.
  ],
  [[3]],
  [
    Rutan, D. A., S. Kato, D. R. Doelling, F. G. Rose, L. T. Nguyen, T. E. Caldwell, and N. G. Loeb, 2015: CERES synoptic product: Methodology and validation of surface radiant flux. _*J. Atmos. Oceanic Technol.*_, 32, 1121–1143, doi: 10.1175/JTECH-D-14-00165.1.
  ],
)

=== 1.2.4 参考文献引用


- 作者年：`#cite(<monteith2013>, form: "prose")`, #cite(<monteith2013>, form: "prose")

- `#[@monteith2013]`: #[@monteith2013] Figure 3.4。

#h(2em)
图#[@fig_penman1948]源自#cite(<monteith2013>, form: "prose") Figure 3.4。


=== 1.2.5 参考文献格式

几种不同格式的参考文献：
- `gb-7714-2005-numeric`: China National Standard GB/T 7714-2005 (numeric, 中文)

- `gb-7714-2015-author-date`: China National Standard GB/T 7714-2015 (author-date, 中文)

- `gb-7714-2015-note`: China National Standard GB/T 7714-2015 (note, 中文)

- `gb-7714-2015-numeric`: China National Standard GB/T 7714-2015 (numeric, 中文)

#bibliography("References.bib", title: "参考文献", style:"gb-7714-2015-author-date")
