// MẪU 04 — ĐỀ TỰ LUẬN CÓ DÒNG TRỐNG / VÙNG NHÁP

#import "@preview/sang-math:1.0.2": *

#let profile = sys.inputs.at("profile", default: "draft") // draft | dethi | loigiai
#let preset = exam-preset(theme: "print-economy", profile: profile, draft: true)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: black)
#show: exam-theme.with(
  theme: preset.theme,
  school: "TRƯỜNG THPT ................................",
  exam-title: "BÀI KIỂM TRA TỰ LUẬN",
  subject: "TOÁN 12",
  duration: "45 phút",
  code: "TL01",
  ..preset.template,
)

#exam-part([PHẦN TỰ LUẬN], count: 3)

#tl(
  [Khảo sát tính đơn điệu của hàm số $y=x^3-3x+1$.],
  id: "TL01",
  tags: ("phuong-trinh", "TH"),
  lines: 8,
  loigiai: [
    Ta có $y'=3x^2-3=3(x-1)(x+1)$.
    Hàm số đồng biến trên $(-oo;-1)$ và $(1;+oo)$, nghịch biến trên $(-1;1)$.
  ],
)

#tl(
  [Giải bất phương trình $log_2(x-1)>=3$.],
  id: "TL02",
  tags: ("hinh-hoc-khong-gian", "VD"),
  lines: 7,
  loigiai: [
    Điều kiện $x>1$. Vì cơ số $2>1$ nên
    $log_2(x-1)>=3 <=> x-1>=8 <=> x>=9$.
  ],
)

#tl(
  [Trong không gian $O x y z$, viết phương trình mặt cầu tâm $I(1,-2,3)$ đi qua $A(3,-2,3)$.],
  id: "TL03",
  tags: ("toi-uu", "VDC"),
  lines: 7,
  loigiai: [
    $R=I A=2$. Phương trình mặt cầu là
    $(x-1)^2+(y+2)^2+(z-3)^2=4$.
  ],
)

#het
