// Demo thật cho bộ mẫu sách sang-math 1.0.2
// Sửa nhanh:
//   #let theme = "sgk-modern"
//   #let theme = "vdc-elite"
//   #let theme = "workbook-jade"
//   #let theme = "solution-crimson"
//   #let theme = "lesson-amber"
//   #let theme = "olympiad-indigo"

#import "../lib.typ": *

#let theme = sys.inputs.at("theme", default: "sgk-modern")

#show: book-theme.with(
  theme: theme,
  title: "CHUYÊN ĐỀ HÀM SỐ",
  subtitle: "Mẫu sách đẹp với mục lục, phân cấp và hộp sư phạm",
  author: "GV Nguyễn Văn Sang",
  institution: "Sang Math · ConicTypst",
  subject: "Toán",
  grade: "Lớp 12",
  year: "2026-2027",
  cover-note: [Một nguồn Typst dùng cho SGK, chuyên đề, workbook, giáo án và sách lời giải.],
)

#book-chapter([Khảo sát và ứng dụng đạo hàm], number: "01", theme: theme)

#book-lesson([Tính đơn điệu của hàm số], number: "1", theme: theme)

#goal-box(theme: theme)[
  - Nhận biết dấu của đạo hàm trên từng khoảng xác định.
  - Kết luận khoảng đồng biến, nghịch biến của hàm số.
  - Tránh lỗi gộp khoảng qua điểm gián đoạn.
]

#warmup-box(theme: theme)[
  Một vật chuyển động trên trục số có vị trí $s(t)=t^3-3t$.
  Khi nào vật đang chuyển động theo chiều dương?
]

#explore-box(theme: theme)[
  Quan sát dấu của $s'(t)$ trên các khoảng xác định rồi dự đoán chiều chuyển động.

  #bbbt(
    x-vals: ($-oo$, $-1$, $1$, $+oo$),
    d-signs: ("+", 0, "-", 0, "+"),
    v-vals: ($-oo$, $3$, $-1$, $+oo$),
    w2: 10.5,
  )
]

#book-section([Lý thuyết trọng tâm], number: "1.1", theme: theme)

#definition-box(theme: theme)[
  Hàm số $f$ được gọi là *đồng biến* trên khoảng $I$ nếu với mọi $x_1 < x_2$ trong $I$ ta có $f(x_1) <= f(x_2)$.
]

#theorem-box(theme: theme)[
  Nếu $f'(x) > 0$ với mọi $x$ thuộc khoảng $I$ thì $f$ đồng biến trên $I$.
  Nếu $f'(x) < 0$ với mọi $x$ thuộc khoảng $I$ thì $f$ nghịch biến trên $I$.
]

#method-box(theme: theme)[
  Quy trình xét tính đơn điệu:
  1. Tìm tập xác định.
  2. Tính đạo hàm và các nghiệm của $f'(x)=0$.
  3. Lập bảng xét dấu của $f'(x)$.
  4. Kết luận theo từng khoảng xác định.
]

#book-section([Ví dụ mẫu], number: "1.2", theme: theme)

#example-box(title: [Ví dụ 1. Hàm bậc ba], theme: theme)[
  Xét tính đơn điệu của hàm số $y=x^3-3x+1$.

  Ta có $y'=3x^2-3=3(x-1)(x+1)$.
  Suy ra $y'>0$ khi $x<-1$ hoặc $x>1$, và $y'<0$ khi $-1<x<1$.
]

#activity-box(theme: theme)[
  Hãy thay hệ số trong hàm số $y=x^3-3x+1$ để tạo một ví dụ mới có hai điểm tới hạn.
  So sánh bảng dấu với ví dụ trên.
]

#practice-box(theme: theme)[
  Xét tính đơn điệu của các hàm số:
  - $y=x^3-6x^2+9x$.
  - $y=(x-1)/(x+2)$.
]

#warning-box(theme: theme)[
  Với hàm phân thức, không được kết luận đồng biến trên một khoảng chứa điểm làm mẫu số bằng $0$.
]

#exercise-box(theme: theme, lines: 5)[
  Tìm khoảng đồng biến, nghịch biến của hàm số $y=(x^2+1)/(x-1)$.
]

#summary-box(theme: theme)[
  - Đạo hàm dương: hàm đồng biến.
  - Đạo hàm âm: hàm nghịch biến.
  - Luôn xét trên từng khoảng thuộc tập xác định.
]
