// MẪU 06 — CÂU HỎI CÓ BẢNG BIẾN THIÊN VÀ HÌNH CeTZ

#import "@preview/cetz:0.5.2"
#import "@preview/sang-math:1.0.2": *

#let profile = sys.inputs.at("profile", default: "loigiai")
#let preset = exam-preset(theme: "ocean", profile: profile)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: black)
#show: exam-theme.with(
  theme: preset.theme,
  school: "TRƯỜNG THPT ................................",
  exam-title: "MẪU CÂU HỎI CÓ HÌNH VECTOR",
  subject: "TOÁN 12",
  duration: "30 phút",
  code: "H01",
  ..preset.template,
)

#exam-part([PHẦN I. Bảng biến thiên], count: 1)

#tn(
  [Cho hàm số có bảng biến thiên như hình. Hàm số nghịch biến trên khoảng nào?],
  ([$(-oo;-1)$], True([$(-1;1)$]), [$(1;+oo)$], [$(-oo;+oo)$]),
  id: "TN01",
  tags: ("bbt", "dao-ham"),
  fig: bbtv2(
    x-vals: ($-oo$, $-1$, $1$, $+oo$),
    d-signs: ("+", 0, "-", 0, "+"),
    v-vals: ($-oo$, $3$, $-1$, $+oo$),
  ),
  fig-pos: "center",
  fig-width: 85%,
  loigiai: [Hàng dấu $y'$ âm trên $(-1;1)$ nên hàm số nghịch biến trên khoảng đó.],
)

#pagebreak()
#exam-part([PHẦN II. Hình học CeTZ], count: 1)

#tn(
  [Elip trong hình có nửa trục lớn $a=3$ và nửa trục nhỏ $b=2$. Tiêu cự $2c$ bằng],
  ([$sqrt(5)$], True([$2sqrt(5)$]), [$5$], [$10$]),
  id: "TN02",
  tags: ("elip", "cetz"),
  fig: cetz.canvas(length: 0.7cm, {
    import cetz.draw: *
    draw-ellipse(
      name: "E",
      a: 3,
      b: 2,
      center: (0, 0),
      color: sm-blue,
      fill: rgb("E8F3FF"),
      show-axes: true,
      show-foci: true,
    )
  }),
  fig-pos: "center",
  fig-width: 60%,
  loigiai: [$c=sqrt(a^2-b^2)=sqrt(9-4)=sqrt(5)$ nên $2c=2sqrt(5)$.],
)

#het
