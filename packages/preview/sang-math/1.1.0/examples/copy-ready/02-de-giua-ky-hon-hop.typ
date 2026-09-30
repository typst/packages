// MẪU 02 — ĐỀ GIỮA KỲ HỖN HỢP

#import "@preview/sang-math:1.0.2": *

#let profile = sys.inputs.at("profile", default: "dethi")
#let preset = exam-preset(theme: "navy-gold", profile: profile)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: black)
#show: exam-theme.with(
  theme: preset.theme,
  school: "TRƯỜNG THPT ................................",
  exam-title: "ĐỀ KIỂM TRA GIỮA HỌC KỲ I",
  subject: "TOÁN 11",
  duration: "60 phút",
  code: "101",
  footer-left: [Năm học 2026–2027],
  ..preset.template,
)

#exam-part([PHẦN I. Trắc nghiệm nhiều phương án], count: 4)

#tn(
  [Nghiệm của phương trình $sin x=0$ là],
  (
    True([$x=k pi, k in ZZ$]),
    [$x=pi/2+k pi, k in ZZ$],
    [$x=k 2pi, k in ZZ$],
    [$x=pi/2+k 2pi, k in ZZ$],
  ),
  id: "TN01",
  tags: ("luong-giac", "nhan-biet"),
  loigiai: [$sin x=0 <=> x=k pi, k in ZZ$.],
)

#tn(
  [Cho cấp số nhân có $u_1=2$, công bội $q=3$. Số hạng $u_4$ bằng],
  ([$18$], [$27$], True([$54$]), [$81$]),
  id: "TN02",
  tags: ("cap-so-nhan", "thong-hieu"),
  loigiai: [$u_4=u_1 q^3=2 dot 3^3=54$.],
)

#tn(
  [Có bao nhiêu cách chọn 2 học sinh từ một nhóm 5 học sinh?],
  ([$5$], True([$10$]), [$20$], [$25$]),
  id: "TN03",
  tags: ("to-hop", "thong-hieu"),
  loigiai: [Số cách là $binom(5,2)=10$.],
)

#tn(
  [Giới hạn $lim_(n -> +oo) frac(1,n)$ bằng],
  (True([$0$]), [$1$], [$+oo$], [$-oo$]),
  id: "TN04",
  tags: ("gioi-han", "nhan-biet"),
  loigiai: [$lim_(n -> +oo) frac(1,n)=0$.],
)

#exam-part([PHẦN II. Trắc nghiệm đúng / sai], count: 1)

#ds(
  [Cho dãy số $(u_n)$ với $u_n=2n+1$. Xét các khẳng định sau:],
  (
    True([$u_1=3$]),
    True([$u_5=11$]),
    [$u_n$ là một cấp số nhân],
    True([Hiệu $u_(n+1)-u_n$ luôn bằng $2$]),
  ),
  id: "DS01",
  tags: ("day-so", "dung-sai"),
  loigiai: [Ta có $u_(n+1)-u_n=2$, nên đây là cấp số cộng, không phải cấp số nhân.],
)

#exam-part([PHẦN III. Trả lời ngắn], count: 2)

#tln(
  [Tính tổng $1+2+3+...+10$.],
  [$55$],
  id: "TLN01",
  tags: ("tong", "thong-hieu"),
  loigiai: [$S=frac(10 dot 11,2)=55$.],
)

#tln(
  [Một tổ có 4 nam và 3 nữ. Chọn ngẫu nhiên một học sinh. Xác suất chọn được học sinh nữ bằng bao nhiêu?],
  [$3/7$],
  id: "TLN02",
  tags: ("xac-suat", "thong-hieu"),
  loigiai: [Xác suất cần tìm bằng $frac(3,7)$.],
)

#exam-part([PHẦN IV. Tự luận], count: 1)

#tl(
  [Giải phương trình $2 cos x-1=0$.],
  id: "TL01",
  tags: ("ham-so", "VD"),
  lines: 6,
  loigiai: [
    $2 cos x-1=0 <=> cos x=frac(1,2)$.

    Do đó $x=plus.minus frac(pi,3)+k 2pi$, với $k in ZZ$.
  ],
)

#het
