// MẪU 05 — PHIẾU HỌC TẬP / CHUYÊN ĐỀ

#import "@preview/sang-math:1.0.2": *

#let theme = "workbook-jade"

#show: book-theme.with(
  theme: theme,
  title: "PHIẾU HỌC TẬP: TÍNH ĐƠN ĐIỆU",
  subtitle: "Lý thuyết ngắn — ví dụ mẫu — luyện tập",
  author: "Giáo viên: ................................",
  institution: "TRƯỜNG THPT ................................",
  subject: "Toán",
  grade: "Lớp 12",
  year: "2026–2027",
  cover-note: [Có thể xóa trang bìa hoặc thay toàn bộ thông tin tại khối cấu hình đầu file.],
)

#book-chapter([Ứng dụng đạo hàm], number: "01", theme: theme)
#book-lesson([Tính đơn điệu của hàm số], number: "1", theme: theme)

#goal-box(theme: theme)[
  - Biết xét dấu đạo hàm trên từng khoảng xác định.
  - Kết luận đúng các khoảng đồng biến và nghịch biến.
]

#theory-box(theme: theme)[
  Nếu $f'(x)>0$ trên khoảng $I$ thì $f$ đồng biến trên $I$.
  Nếu $f'(x)<0$ trên khoảng $I$ thì $f$ nghịch biến trên $I$.
]

#method-box(theme: theme)[
  1. Tìm tập xác định.
  2. Tính $f'(x)$ và tìm các điểm làm đạo hàm bằng $0$ hoặc không xác định.
  3. Lập bảng xét dấu.
  4. Kết luận trên từng khoảng xác định.
]

#example-box(title: [Ví dụ mẫu], theme: theme)[
  Xét tính đơn điệu của $f(x)=x^3-3x+1$.

  Ta có $f'(x)=3x^2-3=3(x-1)(x+1)$.
  Do đó $f$ đồng biến trên $(-oo;-1)$ và $(1;+oo)$, nghịch biến trên $(-1;1)$.
]

#warning-box(theme: theme)[
  Không gộp hai khoảng qua một điểm không thuộc tập xác định của hàm số.
]

#practice-box(theme: theme)[
  Xét tính đơn điệu của các hàm số:
  - $y=x^3-6x^2+9x$.
  - $y=frac(x^2+1,x-1)$.
]

#exercise-box(theme: theme, lines: 8)[
  Lập bảng biến thiên của hàm số $y=x^4-2x^2+1$.
]

#summary-box(theme: theme)[
  Dấu của đạo hàm quyết định chiều biến thiên, nhưng kết luận luôn phải tôn trọng tập xác định.
]
