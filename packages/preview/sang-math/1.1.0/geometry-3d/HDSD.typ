// ═══════════════════════════════════════════════════════════════════════════════
// HƯỚNG DẪN SỬ DỤNG CHUYÊN NGHIỆP — TYPDRAW3D v0.2.0
// Gói Hình Học Không Gian THPT & Đồ Họa 3D Thuật Toán Tự Động Cho Typst
// Tác giả: ThS. Nguyễn Sáng <sangnhc87@gmail.com>
// ═══════════════════════════════════════════════════════════════════════════════

#import "lib.typ": *

#set page(
  paper: "a4",
  margin: (top: 2.2cm, bottom: 2.2cm, left: 2.2cm, right: 2.2cm),
  header: context {
    let p = counter(page).get().first()
    if p > 1 [
      #grid(
        columns: (1fr, 1fr),
        align(left)[#text(size: 8.5pt, fill: rgb("64748b"))[*TypDraw3D* — Hướng Dẫn Sử Dụng Chuyên Nghiệp]],
        align(right)[#text(size: 8.5pt, fill: rgb("64748b"))[Trang #p]]
      )
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + rgb("cbd5e1"))
    ]
  },
  footer: context {
    let p = counter(page).get().first()
    if p > 1 [
      #align(center)[#text(size: 8pt, fill: rgb("94a3b8"))[Bản quyền © 2026 Nguyễn Sáng • TypDraw3D for Typst • Chuẩn SGK Việt Nam]]
    ]
  }
)

#set text(font: "Libertinus Serif", size: 10.5pt, lang: "vi")
#set par(justify: true, leading: 0.7em)

// Định dạng tiêu đề chương, mục
#show heading.where(level: 1): it => block(width: 100%, below: 14pt, above: 20pt)[
  #text(size: 15pt, weight: "bold", fill: rgb("1e3a8a"))[#it.body]
  #v(2pt)
  #line(length: 100%, stroke: 1.5pt + rgb("1e3a8a"))
]

#show heading.where(level: 2): it => block(below: 10pt, above: 14pt)[
  #text(size: 12pt, weight: "bold", fill: rgb("0369a1"))[#it.body]
]

#show heading.where(level: 3): it => block(below: 8pt, above: 10pt)[
  #text(size: 10.5pt, weight: "bold", fill: rgb("334155"))[#it.body]
]

#show raw.where(block: true): it => block(
  fill: rgb("f8fafc"),
  inset: 10pt,
  radius: 5pt,
  stroke: 0.5pt + rgb("e2e8f0"),
  width: 100%,
  text(size: 8.5pt, font: "Menlo", it)
)

#show raw.where(block: false): it => box(
  fill: rgb("f1f5f9"),
  inset: (x: 3pt, y: 1pt),
  radius: 3pt,
  text(size: 9pt, font: "Menlo", it)
)

// Khung mẹo / lưu ý sư phạm
#let hop-luu-y(tieu-de: "LƯU Ý QUAN TRỌNG", noi-dung) = block(
  fill: rgb("eff6ff"),
  stroke: (left: 3pt + rgb("2563eb")),
  inset: (x: 12pt, y: 10pt),
  radius: (right: 4pt),
  width: 100%,
)[
  #text(weight: "bold", size: 9.5pt, fill: rgb("1e40af"))[💡 #tieu-de] \
  #v(2pt)
  #text(size: 9.5pt, fill: rgb("1e293b"))[#noi-dung]
]

// ─────────────────────────────────────────────────────────────
// TRANG BÌA & TIÊU ĐỀ CHÍNH
// ─────────────────────────────────────────────────────────────

#align(center)[
  #v(10pt)
  #text(size: 12pt, tracking: 2pt, weight: "bold", fill: rgb("64748b"))[TÀI LIỆU HƯỚNG DẪN KỸ THUẬT & SOẠN GIẢNG THPT] \
  #v(8pt)
  #text(size: 25pt, weight: "bold", fill: rgb("1e3a8a"))[TYPDRAW3D v0.2.0] \
  #v(4pt)
  #text(size: 13pt, weight: "medium", fill: rgb("0284c7"))[Gói Vẽ Hình Học Không Gian THPT & Đồ Họa 3D Thuật Toán Cho Typst] \
  #v(8pt)
  #line(length: 40%, stroke: 1pt + rgb("94a3b8"))
  #v(6pt)
  #text(size: 9.5pt, fill: rgb("475569"))[
    *Tác giả:* ThS. Nguyễn Sáng #h(10pt) • #h(10pt) *Email:* `sangnhc87@gmail.com` \
    *Tính năng:* Chuẩn SGK GDPT mới • Thuật toán 3D tự động • Hook `them: d => { ... }` trực quan
  ]
  #v(15pt)
]

#outline(indent: 1.5em, depth: 2)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// CHƯƠNG 1: TỔNG QUAN & KHỞI ĐỘNG NHANH
// ─────────────────────────────────────────────────────────────

= Chương 1: Tổng Quan & Khởi Động Nhanh

== 1.1. Triết lý phát triển
Trong soạn giảng Toán THPT tại Việt Nam, nhu cầu vẽ hình học không gian (Hình học 11) và hình học giải tích toạ độ $O x y z$ (Hình học 12) là tối quan trọng. Trước đây, giáo viên thường gặp khó khăn:
- *LaTeX / TikZ / Luadraw:* Cú pháp phức tạp, biên dịch chậm, cài đặt môi trường LuaTeX cồng kềnh.
- *Gói vẽ 2D cơ bản:* Chưa có thuật toán tính toán 3D thực tế, khó vẽ góc, khó xác định nét khuất tự động, khó lấy trung điểm hay mặt phẳng thiết diện.

*TypDraw3D* ra đời để giải quyết triệt để bài toán này bằng cách kết hợp:
1. *Cú pháp 1 dòng nhanh gọn:* Mỗi hình mẫu chuẩn SGK đều có hàm bao đóng độc lập `-fig()` chèn trực tiếp vào văn bản.
2. *Cơ chế Callback Hook `them: d => { ... }`:* Trả về toàn bộ tọa độ các đỉnh, tâm, đáy trong biến `d`. Giáo viên chỉ cần lấy `d.S`, `d.A`, `d.B`, `d.C`... để dựng trung điểm, hạ đường cao, đánh dấu góc vuông mà không cần tính toán toạ độ thủ công.
3. *Động cơ 3D Luadraw tích hợp:* Động cơ đại số vectơ và camera phối cảnh 3D thời gian thực với công nghệ khử nét khuất (*Back-face Culling*) và đổ bóng Gradient Studio.

== 1.2. Cài đặt và sử dụng
Chỉ cần import thư viện ở đầu file tài liệu `.typ`:

```typst
#import "@preview/typdraw3d:0.2.0": *
// Hoặc khi dùng local:
// #import "lib.typ": *
```

== 1.3. Ví dụ đầu tiên trong 10 giây
Để chèn một hình chóp tam giác đều có sẵn đường cao hạ từ đỉnh $S$ xuống trọng tâm đáy $H$, chỉ cần viết:

#grid(
  columns: (1.2fr, 0.8fr),
  gutter: 15pt,
  [
```typst
#hinh-chop-tam-giac-fig(
  duong-cao: "tam",
  them: d => {
    // d chứa: d.S, d.A, d.B, d.C, d.H
    let M = trung-diem(d.S, d.B)
    ve-diem(M, ten: $M$, huong: "east")
    ve-doan(d.A, M, dut: true, mau: red)
  }
)
```
  ],
  align(center + horizon)[
    #hinh-chop-tam-giac-fig(
      duong-cao: "tam",
      them: d => {
        let M = trung-diem(d.S, d.B)
        ve-diem(M, ten: $M$, huong: "east")
        ve-doan(d.A, M, dut: true, mau: rgb("dc2626"), day: 0.9pt)
      }
    )
  ]
)

#hop-luu-y[
  Mọi hàm có đuôi `-fig` đều tự động gói trong một khung hình độc lập. Nếu quý thầy cô muốn kết hợp nhiều hình vào cùng một hệ trục hoặc lồng ghép nâng cao, có thể gọi hàm gốc (bỏ chữ `-fig`) bên trong `#cetz.canvas({ ... })`.
]

#pagebreak()

// ─────────────────────────────────────────────────────────────
// CHƯƠNG 2: THƯ VIỆN HÌNH HỌC THPT CHUẨN SGK
// ─────────────────────────────────────────────────────────────

= Chương 2: Thư Viện Hình Học Không Gian THPT Chuẩn SGK

== 2.1. Các khối chóp (Pyramids)

=== A. Chóp tam giác ($S.A B C$)
Hỗ trợ các dạng đường cao thường gặp:
- `duong-cao: none`: Chóp tổng quát không có đường cao.
- `duong-cao: "dinh-a"`: Cạnh bên $S A bot (A B C)$ (chuẩn đề thi THPT).
- `duong-cao: "tam"`: Chóp đều có $S H bot (A B C)$ tại trọng tâm $H$ của đáy.

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Trường hợp $S A bot (A B C)$:*
      #v(4pt)
      #align(center)[
        #hinh-chop-tam-giac-fig(duong-cao: "dinh-a")
      ]
    ]
  ],
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Trường hợp $S H bot (A B C)$ tại tâm:*
      #v(4pt)
      #align(center)[
        #hinh-chop-tam-giac-fig(duong-cao: "tam")
      ]
    ]
  ]
)

=== B. Chóp tứ giác ($S.A B C D$) & Chóp tứ giác đều
Cạnh đáy $A D$ và $A B$ nằm phía sau tự động vẽ nét đứt. Cạnh đáy $B C, C D$ và các cạnh bên $S B, S C, S D$ vẽ nét liền. Cạnh $S A$ nét đứt nếu $S A$ nằm sau hoặc nét liền tùy cấu hình.

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Chóp tứ giác $S A bot (A B C D)$:*
      #v(4pt)
      #align(center)[
        #hinh-chop-tu-giac-fig(duong-cao: "dinh-a")
      ]
    ]
  ],
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Chóp tứ giác đều $S.A B C D$ ($S O bot$ đáy):*
      #v(4pt)
      #align(center)[
        #hinh-chop-tu-giac-deu-fig(duong-cao: true)
      ]
    ]
  ]
)

#pagebreak()

=== C. Chóp lục giác đều ($S.A B C D E F$) & Chóp cụt đều
Khối chóp đáy lục giác và hình chóp cụt thường xuất hiện trong các bài toán thực tế (lều bạt, tháp nước, chóp nón cụt).

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Chóp lục giác đều $S.A B C D E F$:*
      #v(4pt)
      #align(center)[
        #hinh-chop-luc-giac-deu-fig(duong-cao: true)
      ]
    ]
  ],
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Chóp cụt tứ giác đều $A B C D.A'B'C'D'$:*
      #v(4pt)
      #align(center)[
        #hinh-chop-cut-deu-fig(truc: true)
      ]
    ]
  ]
)

== 2.2. Các khối lăng trụ & Khối hộp (Prisms & Cuboids)

=== A. Lăng trụ tam giác $A B C.A'B'C'$ & Khối hộp chữ nhật
Hình lăng trụ và hình hộp được dựng với góc nhìn xiên chuẩn mực, bảo đảm tỉ lệ trực quan và phân biệt rõ nét khuất.


#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Lăng trụ tam giác $A B C.A'B'C'$:*
      #v(4pt)
      #align(center)[
        #hinh-lang-tru-tam-giac-fig(
          them: d => {
            // Thiết diện qua A' và trung điểm BC
            let M = trung-diem(d.B, d.C)
            ve-diem(M, ten: $M$, huong: "north")
            ve-doan(d.A_prime, M, dut: true, mau: rgb("dc2626"))
          }
        )
      ]
    ]
  ],
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 8pt, radius: 5pt)[
      *Hình hộp chữ nhật / lập phương:*
      #v(4pt)
      #align(center)[
        #hinh-hop-fig(
          duong-cheo: true,
          them: d => {
            ve-doan(d.B, d.D, dut: true, mau: rgb("2563eb"))
          }
        )
      ]
    ]
  ]
)

#pagebreak()

== 2.3. Các khối tròn xoay (Hình nón, Hình trụ, Khối cầu)
Các khối tròn xoay sử dụng thuật toán lấy mẫu tham số đường cong elip chuẩn xác, loại bỏ hoàn toàn hiện tượng méo góc hay gãy khúc.

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 6pt, radius: 5pt)[
      *Hình nón tròn xoay:*
      #v(3pt)
      #align(center)[
        #hinh-non-thpt-fig(r: 1.3, h: 2.6, b: 0.42)
      ]
    ]
  ],
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 6pt, radius: 5pt)[
      *Hình trụ tròn xoay:*
      #v(3pt)
      #align(center)[
        #hinh-tru-thpt-fig(r: 1.2, h: 2.5, b: 0.38)
      ]
    ]
  ],
  [
    #block(stroke: 0.5pt + rgb("e2e8f0"), inset: 6pt, radius: 5pt)[
      *Khối cầu chuẩn SGK:*
      #v(3pt)
      #align(center)[
        #hinh-cau-thpt-fig(r: 1.4, b: 0.42)
      ]
    ]
  ]
)

== 2.4. Bộ công cụ vẽ thêm cực mạnh (Helpers)
Bên trong hàm `them: d => { ... }`, quý thầy cô có thể dùng các hàm tiện ích sau:

#table(
  columns: (1.5fr, 2.5fr),
  fill: (x, y) => if y == 0 { rgb("e0f2fe") } else { none },
  stroke: 0.5pt + rgb("cbd5e1"),
  inset: 6pt,
  [*Hàm tiện ích*], [*Ý nghĩa & Cách dùng*],
  [`trung-diem(A, B)`], [Tính tọa độ 2D trung điểm của đoạn thẳng $A B$.],
  [`ti-le(A, B, k)`], [Điểm chia $P = A + k(B - A)$. Ví dụ: $k = 2/3$ là điểm chia trọng tâm.],
  [`trong-tam(A, B, C)`], [Tính trọng tâm tam giác hoặc hệ điểm bất kỳ.],
  [`ve-diem(P, ten: $M$, huong: "north")`], [Chấm điểm tròn và gán nhãn toán học theo hướng chỉ định.],
  [`ve-doan(A, B, dut: true, mau: red)`], [Vẽ đoạn thẳng liền hoặc đứt với màu sắc và độ dày tùy chọn.],
  [`ve-goc-vuong(A, O, B)`], [Ký hiệu góc vuông tại đỉnh $O$ giữa 2 tia $O A$ và $O B$.],
  [`ve-cung-goc(A, O, B, nhan: $alpha$)`], [Vẽ cung góc tròn kèm nhãn góc $alpha$ giữa 2 đoạn thẳng.],
  [`ve-thiet-dien((A, M, N), mau: orange)`], [Đổ bóng mặt phẳng thiết diện mờ trong suốt (alpha blending).],
  [`ve-mat-phang-khong-gian(ten: $(alpha)$)`], [Vẽ hình bình hành biểu diễn mặt phẳng không gian.],
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// CHƯƠNG 3: HÌNH HỌC TOẠ ĐỘ OXYZ (LỚP 12)
// ─────────────────────────────────────────────────────────────

= Chương 3: Hình Học Tọa Độ Oxyz (Toán 12)

== 3.1. Hệ trục tọa độ Oxyz chuẩn mực
Hệ trục $O x y z$ được thiết kế theo đúng quy ước SGK Việt Nam:
- Trục $O x$ chéo hướng xuống phía trước-trái về phía người quan sát.
- Trục $O y$ hướng sang phải theo phương ngang.
- Trục $O z$ hướng thẳng đứng lên trên.
- Ba vectơ đơn vị $arrow(i), arrow(j), arrow(k)$ phân biệt theo 3 màu sắc chuẩn mực.

```typst
#he-truc-oxyz-fig(
  x: 3.5, y: 4.5, z: 4.0,   // Giới hạn các trục
  don-vi: true,              // Hiện vectơ i, j, k
  vach: true, so: true,      // Hiện vạch chia và số
  luoi: ("xy",),             // Lưới mặt phẳng Oxy
  them: d => {
    // d chứa: d.t3 (hàm đổi 3D -> 2D), d.O, d.X, d.Y, d.Z
  }
)
```

== 3.2. Vẽ điểm 3D tự động gióng hình hộp (`diem-oxyz`)
Tính năng được các giáo viên yêu thích nhất: Tự động kẻ các đường đứt nét gióng điểm $M(x_0, y_0, z_0)$ xuống mặt phẳng đáy $O x y$, trục $O x$, trục $O y$, trục $O z$ và tự động ghi toạ độ số lên các trục!

#grid(
  columns: (1.2fr, 0.8fr),
  gutter: 12pt,
  [
```typst
#he-truc-oxyz-fig(
  x: 3.5, y: 4.0, z: 3.5,
  them: d => {
    let t3 = d.t3
    // Tự động gióng hộp tọa độ:
    diem-oxyz(
      t3,
      (2.2, 3.0, 2.5),
      ten: $M(2.2; 3.0; 2.5)$,
      giong: true,
      mau: blue
    )
  }
)
```
  ],
  align(center + horizon)[
    #he-truc-oxyz-fig(
      x: 3.2, y: 3.8, z: 3.4,
      them: d => {
        let t3 = d.t3
        diem-oxyz(t3, (2.0, 2.8, 2.4), ten: $M$, giong: true, mau: rgb("1d4ed8"))
      }
    )
  ]
)

== 3.3. Mặt phẳng đoạn chắn $x/a + y/b + z/c = 1$
Tự động vẽ tam giác thiết diện chắn trên 3 trục tọa độ, tô màu trong suốt và đánh dấu các góc vuông tại gốc $O$:

#grid(
  columns: (1.2fr, 0.8fr),
  gutter: 12pt,
  [
```typst
#he-truc-oxyz-fig(
  x: 3.5, y: 4.0, z: 3.5,
  don-vi: false,
  them: d => {
    mat-phang-doan-chan(
      d.t3,
      a: 2.5, b: 3.2, c: 2.8,
      ten: $(alpha)$,
      mau: rgb("2563eb"),
      do-mo: 20%
    )
  }
)
```
  ],
  align(center + horizon)[
    #he-truc-oxyz-fig(
      x: 3.2, y: 3.8, z: 3.4,
      don-vi: false,
      them: d => {
        mat-phang-doan-chan(d.t3, a: 2.4, b: 3.0, c: 2.6, ten: $(alpha)$, mau: rgb("2563eb"), do-mo: 20%)
      }
    )
  ]
)

== 3.4. Bộ giải giải tích không gian tự động (Solvers)
Gói cung cấp sẵn thư viện tính toán toạ độ giải tích thuần túy (không chỉ vẽ hình):
- `v3-cong(u, v)`, `v3-tru(u, v)`, `v3-nhan(u, k)`, `v3-vo-huong(u, v)`, `v3-co-huong(u, v)`.
- `tich-hon-tap(u, v, w)`: Tính $[arrow(u), arrow(v), arrow(w)] = (arrow(u) times arrow(v)) dot arrow(w)$ (xét đồng phẳng, thể tích tứ diện).
- `khoang-cach-3d(A, B)`: Khoảng cách giữa 2 điểm trong không gian.
- `pt-mat-phang(A, B, C)`: Lập phương trình $a x + b y + c z + d = 0$ đi qua 3 điểm.
- `khoang-cach-diem-mp(M, mp)`: Khoảng cách từ điểm $M$ đến mặt phẳng $(P)$.
- `hinh-chieu-diem-mp(M, mp)`: Tọa độ hình chiếu vuông góc $H$ của điểm $M$ lên mặt phẳng $(P)$.
- `giao-dt-mp(M0, u, mp)`: Tìm tọa độ giao điểm của đường thẳng và mặt phẳng.

#pagebreak()

// ─────────────────────────────────────────────────────────────
// CHƯƠNG 4: ĐỘNG CƠ 3D THUẬT TOÁN (LUADRAW ENGINE)
// ─────────────────────────────────────────────────────────────

= Chương 4: Động Cơ 3D Thuật Toán (Phong Cách Luadraw)

== 4.1. Khái niệm & Khả năng của Luadraw Engine trong Typst
Đối với các bài toán hình học không gian phức tạp hoặc đồ họa 3D nâng cao (mô hình kỹ thuật, khối đa diện xoay tự do theo mọi góc nhìn, mặt cầu cắt kinh tuyến/vĩ tuyến, mặt nón cắt mặt phẳng), TypDraw3D trang bị động cơ giải tích 3D thuật toán tự động:
- *Camera 3D đầy đủ:* Tọa độ mắt nhìn, điểm ngắm (`look-at`), góc xoay Yaw, Pitch, Roll, khoảng cách tiêu cự.
- *Chiếu hình học:* Hỗ trợ cả phối cảnh (*Perspective*) và song song (*Orthographic*).
- *Thuật toán Back-face Culling:* Tự động tính tích vô hướng của vectơ pháp tuyến bề mặt $arrow(n)$ với vectơ tia nhìn $arrow(v)$ để phân loại mặt thấy (vẽ liền/tô bóng) và mặt khuất (vẽ đứt hoặc ẩn đi).
- *Ánh sáng Studio & Đổ bóng Gradient:* Tự động tính góc phản xạ ánh sáng Lambertian Shading.

== 4.2. Khối cầu 3D Studio có lát cắt & Đổ bóng Gradient
Tái hiện chuẩn xác bài toán quả cầu cắt góc và đổ bóng mượt mà của Luadraw (LuaLaTeX) ngay trong Typst:

#grid(
  columns: (1fr, 1fr),
  gutter: 15pt,
  [
```typst
#cetz.canvas({
  let cam = make-camera(
    elevation: 20deg,
    azimuth: 35deg
  )
  preset-sphere-cut-alpha(
    R: 2.2,
    z-cut: 1.1,
    cam: cam,
    shading: "orange",
  )
})
```
  ],
  align(center + horizon)[
    #cetz.canvas({
      let cam = make-camera(elevation: 20deg, azimuth: 35deg)
      preset-sphere-cut-alpha(R: 1.8, z-cut: 0.9, cam: cam, shading: "orange")
    })
  ]
)

== 4.3. Chao đèn đa giác 3D phân bố $n$ đỉnh trên vành cầu (`preset-chum-den-luadraw-fig`)
Động cơ tự động giải tiếp tuyến silhouette, phân tách cung thấy nét liền và cung khuất nét đứt, đồng thời phân bố $n$ đỉnh đều đặn trên miệng cắt cầu kèm các vector lực $arrow(F)_i$ như trong mô hình vật lý:

#align(center)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 15pt,
    [
      #text(size: 9.5pt, weight: "bold", fill: rgb("ea580c"))[Chùm đèn 3 đỉnh ($n = 3$, Orange):] \
      #v(4pt)
      #preset-chum-den-luadraw-fig(n: 3, R: 2.0, z-cut: -0.8, S-height: 3.0, shading: "orange")
    ],
    [
      #text(size: 9.5pt, weight: "bold", fill: rgb("0284c7"))[Chùm đèn 4 đỉnh ($n = 4$, Blue):] \
      #v(4pt)
      #preset-chum-den-luadraw-fig(n: 4, R: 2.0, z-cut: -0.8, S-height: 3.0, shading: "blue")
    ]
  )
]

#pagebreak()

== 4.4. Trọn bộ 5 Khối Đa Diện Đều Platon & Khối Archimedes
Thuật toán giải tích tự động phân loại mặt thấy/mặt khuất (*Back-face Culling*) và đổ bóng ánh sáng định hướng (*Lambertian Diffuse Lighting*), giúp giáo viên và học sinh quan sát trực quan cấu trúc không gian của các khối đa diện đều:

#v(6pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[Tứ diện đều (`tetrahedron-fig`)] \
      #v(3pt)
      #tetrahedron-fig(radius: 1.8, palette: "orange")
    ]
  ],
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[Lập phương (`cube-fig`)] \
      #v(3pt)
      #cube-fig(size: 2.0, palette: "blue")
    ]
  ],
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[Bát diện đều (`octahedron-fig`)] \
      #v(3pt)
      #octahedron-fig(radius: 1.8, palette: "emerald")
    ]
  ]
)

#v(10pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[12 mặt đều (`dodecahedron-fig`)] \
      #v(3pt)
      #dodecahedron-fig(radius: 1.8, palette: "violet")
    ]
  ],
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[20 mặt đều (`icosahedron-fig`)] \
      #v(3pt)
      #icosahedron-fig(radius: 1.8, palette: "gold")
    ]
  ],
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[Khối Cuboctahedron (`cuboctahedron-fig`)] \
      #v(3pt)
      #cuboctahedron-fig(radius: 1.8, palette: "blue")
    ]
  ]
)

#v(12pt)
#hop-luu-y(tieu-de: "ĐIỀU CHỈNH GÓC NHÌN & ĐỔ BÓNG ĐA DIỆN")[
  Mọi hàm đa diện đều nhận tham số `cam: make-camera(elevation: ..., azimuth: ...)` để xoay tự do trong không gian 3D, và tham số `palette: "blue" | "orange" | "emerald" | "violet" | "gold"` để thay đổi màu sắc. Thuật toán culling và shading sẽ tự động tính lại toàn bộ theo góc nhìn mới.
]

#pagebreak()

// ─────────────────────────────────────────────────────────────
// CHƯƠNG 5: TRA CỨU NHANH API & CHEAT SHEET
// ─────────────────────────────────────────────────────────────

= Chương 5: Bảng Tra Cứu Nhanh (Cheat Sheet)

#table(
  columns: (2fr, 1.2fr, 3fr),
  fill: (x, y) => if y == 0 { rgb("dbeafe") } else { none },
  stroke: 0.5pt + rgb("cbd5e1"),
  inset: 5.5pt,
  [*Tên hàm*], [*Mô-đun*], [*Tham số chính & Mô tả*],
  [`hinh-chop-tam-giac-fig`], [`thpt`], [`duong-cao` ("dinh-a" / "tam"), `ten`, `them`],
  [`hinh-chop-tu-giac-fig`], [`thpt`], [`duong-cao` ("dinh-a" / "tam"), `ten`, `duong-cheo`],
  [`hinh-chop-tu-giac-deu-fig`], [`thpt`], [`duong-cao: true`, `ten-tam: $O$`, `them`],
  [`hinh-chop-luc-giac-deu-fig`], [`thpt`], [`duong-cao: true`, `ten`, `mau`, `them`],
  [`hinh-chop-cut-deu-fig`], [`thpt`], [`truc: true`, `ten-tam: ($O$, $O'$)`, `them`],
  [`hinh-lang-tru-tam-giac-fig`], [`thpt`], [`h: 3.2`, `ten`, `them`],
  [`hinh-hop-fig` / `hinh-lap-phuong-fig`], [`thpt`], [`duong-cheo: true`, `ten`, `them`],
  [`hinh-non-thpt-fig`], [`thpt`], [`r: 2.0`, `h: 3.5`, `b: 0.55`, `them`],
  [`hinh-tru-thpt-fig`], [`thpt`], [`r: 1.8`, `h: 3.2`, `b: 0.5`, `them`],
  [`hinh-cau-thpt-fig`], [`thpt`], [`r: 2.2`, `b: 0.6`, `them`],
  [`he-truc-oxyz-fig`], [`oxyz`], [`x`, `y`, `z`, `don-vi`, `vach`, `so`, `luoi`, `them`],
  [`diem-oxyz`], [`oxyz`], [`t3`, `P: (x,y,z)`, `ten`, `giong: true`, `mau`],
  [`mat-phang-doan-chan`], [`oxyz`], [`t3`, `a`, `b`, `c`, `ten: $(alpha)$`, `do-mo`],
  [`trung-diem`], [`thpt`], [`(A, B)` -> trả về điểm `(x, y)`],
  [`ti-le`], [`thpt`], [`(A, B, k)` -> trả về `A + k(B - A)`],
  [`trong-tam`], [`thpt`], [`(..pts)` -> trả về trọng tâm hệ điểm],
  [`ve-diem`], [`thpt`], [`pt`, `ten`, `huong`, `lech`, `bk`, `mau`],
  [`ve-doan`], [`thpt`], [`A`, `B`, `dut: false`, `mau`, `day`],
  [`ve-goc-vuong`], [`thpt`], [`A`, `O`, `B`, `r`, `mau`, `day`],
  [`ve-cung-goc`], [`thpt`], [`A`, `O`, `B`, `r`, `nhan`, `mau`],
  [`ve-thiet-dien`], [`thpt`], [`pts: (A, B, C...)`, `mau`, `do-mo`],
  [`preset-chum-den-luadraw-fig`], [`luadraw`], [`n: 3|4|5|6`, `R`, `z-cut`, `S-height`, `shading`, `hien-luc: true`],
  [`dcut-sphere-fig`], [`luadraw`], [`center`, `radius`, `plane-pt`, `plane-normal`, `shading`, `them`],
  [`tetrahedron-fig`], [`polyhedra`], [`center`, `radius`, `palette`, `shading`, `stroke-visible`, `them`],
  [`cube-fig`], [`polyhedra`], [`center`, `size`, `palette`, `shading`, `stroke-visible`, `them`],
  [`octahedron-fig`], [`polyhedra`], [`center`, `radius`, `palette`, `shading`, `stroke-visible`, `them`],
  [`dodecahedron-fig`], [`polyhedra`], [`center`, `radius`, `palette`, `shading`, `stroke-visible`, `them`],
  [`icosahedron-fig`], [`polyhedra`], [`center`, `radius`, `palette`, `shading`, `stroke-visible`, `them`],
  [`cuboctahedron-fig`], [`polyhedra`], [`center`, `radius`, `palette`, `shading`, `stroke-visible`, `them`],
  [`camera`], [`camera`], [`elevation`, `azimuth`, `roll`, `mode: "ortho"|"cavalier"|"perspective"`],
  [`draw-sphere-studio`], [`curved3d`], [`center`, `radius`, `cam`, `show-cut`],
  [`draw-cone-studio`], [`curved3d`], [`base-center`, `radius`, `height`, `cam`],
  [`draw-cylinder-studio`], [`curved3d`], [`base-center`, `radius`, `height`, `cam`],
)

#v(10pt)
#align(center)[
  #text(size: 11pt, weight: "bold", fill: rgb("1e3a8a"))[TYPDRAW3D — CÔNG CỤ ĐẮC LỰC CỦA GIÁO VIÊN TOÁN THPT!] \
  #v(2pt)
  #text(size: 9pt, fill: rgb("64748b"))[Mọi đóng góp và yêu cầu mở rộng tính năng, vui lòng liên hệ: Nguyễn Sáng • `sangnhc87@gmail.com`]
]
