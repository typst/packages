// MẪU 01 — KIỂM TRA 15 PHÚT
// Chỉ sửa khối CẤU HÌNH NHANH và nội dung các câu bên dưới.

#import "@preview/sang-math:1.0.2": *

// ── CẤU HÌNH NHANH ─────────────────────────────────────────────
#let profile = sys.inputs.at("profile", default: "dethi") // dethi | loigiai
#let theme = "teal-pro"
#let preset = exam-preset(theme: theme, profile: profile)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: black)
#show: exam-theme.with(
  theme: preset.theme,
  department: "SỞ GIÁO DỤC VÀ ĐÀO TẠO",
  school: "TRƯỜNG THPT ................................",
  exam-title: "BÀI KIỂM TRA 15 PHÚT",
  subject: "TOÁN 12 — CHỦ ĐỀ ĐẠO HÀM",
  duration: "15 phút",
  code: "001",
  footer-left: [Giáo viên: ................................],
  ..preset.template,
)

#exam-part([PHẦN I. Trắc nghiệm nhiều phương án], count: 4)

#tn(
  [Đạo hàm của hàm số $f(x)=x^2-3x+1$ là],
  (True([$2x-3$]), [$x-3$], [$2x+1$], [$x^2-3$]),
  id: "TN01",
  tags: ("dao-ham", "nhan-biet"),
  loigiai: [$f'(x)=2x-3$.],
)

#tn(
  [Giá trị của $log_2 8$ bằng],
  ([$2$], True([$3$]), [$4$], [$8$]),
  id: "TN02",
  tags: ("logarit", "nhan-biet"),
  loigiai: [Vì $8=2^3$ nên $log_2 8=3$.],
)

#tn(
  [Một nguyên hàm của hàm số $f(x)=x$ là],
  ([$x^2+C$], True([$frac(x^2,2)+C$]), [$2x+C$], [$frac(x,2)+C$]),
  id: "TN03",
  tags: ("nguyen-ham", "thong-hieu"),
  loigiai: [$integral x dif x=frac(x^2,2)+C$.],
)

#tn(
  [Một hộp có 2 viên bi đỏ và 3 viên bi xanh. Lấy ngẫu nhiên một viên bi. Xác suất lấy được bi đỏ là],
  (True([$frac(2,5)$]), [$frac(3,5)$], [$frac(1,2)$], [$frac(2,3)$]),
  id: "TN04",
  tags: ("xac-suat", "thong-hieu"),
  loigiai: [Có 2 kết quả thuận lợi trong 5 khả năng đồng khả năng.],
)

#exam-part([PHẦN II. Trả lời ngắn], count: 2)

#tln(
  [Nghiệm của phương trình $3x-6=0$ là bao nhiêu?],
  [$2$],
  id: "TLN01",
  tags: ("phuong-trinh", "nhan-biet"),
  loigiai: [$3x=6 <=> x=2$.],
)

#tln(
  [Cho cấp số cộng có $u_1=1$ và công sai $d=2$. Tính $u_5$.],
  [$9$],
  id: "TLN02",
  tags: ("cap-so-cong", "thong-hieu"),
  loigiai: [$u_5=u_1+4d=1+8=9$.],
)

#het
