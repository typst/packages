// ═══════════════════════════════════════════════════════════════════════════════
// TYPDRAW3D v0.3.0 — MASTER GALLERY TOÀN DIỆN TẤT CẢ CÁC GÓI LỆNH 3D
// Tương đương trọn bộ năng lực Luadraw & Chuẩn mực SGK Toán THPT Việt Nam
// Tác giả: ThS. Nguyễn Sáng <sangnhc87@gmail.com>
// ═══════════════════════════════════════════════════════════════════════════════

#import "@preview/cetz:0.5.2"
#import "lib.typ": *

#set page(
  paper: "a4",
  margin: (top: 1.4cm, bottom: 1.4cm, left: 1.5cm, right: 1.5cm),
  header: context {
    let p = counter(page).get().first()
    grid(
      columns: (1fr, 1fr),
      align(left)[#text(size: 8pt, fill: rgb("64748b"))[*TypDraw3D v0.3.0* — Master Gallery Hình Học 3D Thuật Toán]],
      align(right)[#text(size: 8pt, fill: rgb("64748b"))[Trang #p / 7]]
    )
    v(-4pt)
    line(length: 100%, stroke: 0.5pt + rgb("cbd5e1"))
  },
  footer: context {
    align(center)[
      #text(size: 8pt, fill: rgb("94a3b8"))[Bản quyền © 2026 Nguyễn Sáng • TypDraw3D (Chuẩn Luadraw & SGK GDPT Mới)]
    ]
  }
)

#set text(font: ("STIX Two Text", "Times New Roman", "New Computer Modern"), size: 9.5pt, lang: "vi")
#set par(justify: true)

// Tiêu đề phần trong gallery
#let muc-gallery(so, tieu-de, mo-ta) = block(width: 100%, below: 8pt, above: 10pt)[
  #text(size: 13pt, weight: "bold", fill: rgb("1e3a8a"))[#so. #tieu-de]
  #v(1pt)
  #text(size: 8.5pt, fill: rgb("475569"))[#mo-ta]
  #v(2pt)
  #line(length: 100%, stroke: 1pt + rgb("cbd5e1"))
]

// ─────────────────────────────────────────────────────────────
// TRANG 1: TUYỆT TÁC LUADRAW — CHÙM ĐÈN n ĐỈNH & CẮT MẶT CẦU
// ─────────────────────────────────────────────────────────────

#align(center)[
  #text(size: 17pt, weight: "bold", fill: rgb("0f172a"))[BỘ MASTER GALLERY HÌNH HỌC 3D TYPDRAW3D]
  #v(1pt)
  #text(size: 10pt, style: "italic", fill: rgb("334155"))[
    Động cơ Dựng Hình 3D Thuật Toán Tự Động — Tương Đương Luadraw (LuaLaTeX) & Chuẩn SGK Việt Nam
  ]
]

#muc-gallery(
  "PHẦN 1",
  "ĐỘNG CƠ LUADRAW: CHÙM ĐÈN n ĐỈNH & LÁT CẮT MẶT CẦU",
  "Thuật toán Dcut_sphere tự động giải tiếp tuyến silhouette, chia cung thấy nét liền và cung khuất nét đứt, kết hợp đổ bóng Gradient Studio chân thực và dựng vector lực không gian."
)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 8pt,
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt, fill: rgb("ea580c"))[1. Chùm 3 đỉnh ($n = 3$)] \
      #v(2pt)
      #preset-chum-den-luadraw-fig(n: 3, R: 2.0, z-cut: -0.6, S-height: 3.3, shading: "orange")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt, fill: rgb("0284c7"))[2. Chùm 4 đỉnh ($n = 4$)] \
      #v(2pt)
      #preset-chum-den-luadraw-fig(n: 4, R: 2.0, z-cut: -0.6, S-height: 3.3, shading: "blue")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt, fill: rgb("059669"))[3. Chùm 5 đỉnh ($n = 5$)] \
      #v(2pt)
      #preset-chum-den-luadraw-fig(n: 5, R: 2.0, z-cut: -0.6, S-height: 3.3, shading: "emerald")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt, fill: rgb("9333ea"))[4. Chùm 6 đỉnh ($n = 6$)] \
      #v(2pt)
      #preset-chum-den-luadraw-fig(n: 6, R: 2.0, z-cut: -0.6, S-height: 3.3, shading: "purple")
    ]
  ]
)

#v(14pt)

#grid(
  columns: (1fr, 1.2fr),
  gutter: 14pt,
  [
    #align(center)[
      #text(weight: "bold", size: 9pt)[5. Cắt chỏm cầu góc $alpha$ ở tâm (`preset-sphere-cut-alpha-fig`)] \
      #v(4pt)
      #preset-sphere-cut-alpha-fig(R: 2.5, z-cut: 1.3, shading: "orange")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold", size: 9pt)[6. Giao tuyến 2 mặt cầu (`preset-two-spheres-intersection-fig`)] \
      #v(4pt)
      #preset-two-spheres-intersection-fig()
    ]
  ]
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// TRANG 2: TRỌN BỘ 5 KHỐI PLATON & ĐA DIỆN ARCHIMEDES
// ─────────────────────────────────────────────────────────────

#muc-gallery(
  "PHẦN 2",
  "5 KHỐI ĐA DIỆN ĐỀU PLATON & KHỐI ARCHIMEDES",
  "Tọa độ giải tích tỉ lệ vàng phi = (1 + sqrt(5))/2, tự động khử nét khuất (Back-face Culling) và đổ bóng ánh sáng định hướng Lambertian (Lambertian Diffuse Shading)."
)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[1. Tứ diện đều (`tetrahedron-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[4 đỉnh, 4 mặt tam giác đều] \
      #v(2pt)
      #tetrahedron-fig(radius: 2.0, palette: "orange")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[2. Hình lập phương (`cube-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[8 đỉnh, 6 mặt vuông] \
      #v(2pt)
      #cube-fig(size: 2.2, palette: "blue")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[3. Bát diện đều (`octahedron-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[6 đỉnh, 8 mặt tam giác đều] \
      #v(2pt)
      #octahedron-fig(radius: 2.0, palette: "emerald")
    ]
  ]
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[4. Khối 12 mặt đều (`dodecahedron-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[20 đỉnh, 12 mặt ngũ giác đều] \
      #v(2pt)
      #dodecahedron-fig(radius: 2.0, palette: "violet")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[5. Khối 20 mặt đều (`icosahedron-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[12 đỉnh, 20 mặt tam giác đều] \
      #v(2pt)
      #icosahedron-fig(radius: 2.0, palette: "gold")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[6. Bán đều Cuboctahedron (`cuboctahedron-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[12 đỉnh, 8 tam giác + 6 vuông] \
      #v(2pt)
      #cuboctahedron-fig(radius: 2.0, palette: "blue")
    ]
  ]
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[7. Chóp đôi ngũ giác (`bipyramid-fig(n: 5)`)] \
      #v(2pt)
      #bipyramid-fig(n: 5, radius: 2.0, height: 3.2, palette: "emerald")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[8. Chóp ngũ giác đều (`pyramid-fig(n: 5)`)] \
      #v(2pt)
      #pyramid-fig(n: 5, radius: 2.0, height: 3.2, palette: "orange")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[9. Lăng trụ lục giác đều (`prism-fig(n: 6)`)] \
      #v(2pt)
      #prism-fig(n: 6, radius: 1.8, height: 3.0, palette: "blue")
    ]
  ]
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// TRANG 3: HÌNH HỌC KHÔNG GIAN THPT — CÁC KHỐI HÌNH CHÓP
// ─────────────────────────────────────────────────────────────

#muc-gallery(
  "PHẦN 3",
  "HÌNH HỌC KHÔNG GIAN THPT: CÁC KHỐI HÌNH CHÓP CHUẨN SGK",
  "Bộ hình vẽ chóp chuẩn mực sách giáo khoa Việt Nam, tích hợp đường cao tự động, đường chéo đáy và hook callback them: d => { ... } cho phép dựng thêm điểm, đoạn, thiết diện tùy thích."
)

#grid(
  columns: (1fr, 1fr),
  gutter: 15pt,
  [
    #align(center)[
      #text(weight: "bold")[1. Chóp tam giác $S.A B C$ có $S A perp (A B C)$] \
      #text(size: 8pt, fill: rgb("64748b"))[`chop-s-abc-fig(duong-cao: "dinh-a")`] \
      #v(2pt)
      #chop-s-abc-fig(
        duong-cao: "dinh-a",
        them: d => {
          let M = trung-diem(d.S, d.B)
          ve-diem(M, ten: $M$, huong: "east")
          ve-doan(d.A, M, mau: rgb("dc2626"), day: 1pt)
        }
      )
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[2. Chóp tam giác đường cao hạ xuống trọng tâm $H$] \
      #text(size: 8pt, fill: rgb("64748b"))[`chop-s-abc-fig(duong-cao: "tam")`] \
      #v(2pt)
      #chop-s-abc-fig(duong-cao: "tam")
    ]
  ]
)

#v(10pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 15pt,
  [
    #align(center)[
      #text(weight: "bold")[3. Chóp tứ giác $S.A B C D$ đáy bình hành & đường cao $S O$] \
      #text(size: 8pt, fill: rgb("64748b"))[`chop-s-abcd-fig(duong-cheo: true, duong-cao: "SO")`] \
      #v(2pt)
      #chop-s-abcd-fig(duong-cheo: true, duong-cao: "SO")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[4. Chóp tứ giác $S.A B C D$ có $S A perp (A B C D)$] \
      #text(size: 8pt, fill: rgb("64748b"))[`chop-s-abcd-fig(duong-cao: "dinh-a")`] \
      #v(2pt)
      #chop-s-abcd-fig(duong-cao: "dinh-a")
    ]
  ]
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt)[5. Chóp tứ giác đều $S.A B C D$] \
      #v(2pt)
      #chop-deu-tu-giac-fig()
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt)[6. Chóp cụt đều ($O, O'$)] \
      #v(2pt)
      #chop-cut-deu-fig()
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold", size: 8.5pt)[7. Tam diện vuông $O.A B C$] \
      #v(2pt)
      #tam-dien-vuong-fig()
    ]
  ]
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// TRANG 4: LĂNG TRỤ, HỘP & KHỐI TRÒN XOAY THPT
// ─────────────────────────────────────────────────────────────

#muc-gallery(
  "PHẦN 4",
  "LĂNG TRỤ, KHỐI HỘP & KHỐI TRÒN XOAY CHUẨN SGK",
  "Hình lăng trụ tam giác, lăng trụ lục giác đều, hình hộp chữ nhật, hình lập phương cùng các khối tròn xoay: hình nón, hình trụ, mặt cầu với kinh vĩ tuyến chuẩn xác."
)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[1. Lăng trụ tam giác $A B C.A'B'C'$] \
      #text(size: 8pt, fill: rgb("64748b"))[`lang-tru-tam-giac-fig`] \
      #v(2pt)
      #lang-tru-tam-giac-fig(
        them: d => {
          let M = trung-diem(d.B, d.C)
          let M1 = trung-diem(d.B1, d.C1)
          ve-diem(M, ten: $M$, huong: "south")
          ve-diem(M1, ten: $M'$, huong: "north")
          ve-doan(d.A, M, dut: true, mau: rgb("dc2626"))
          ve-doan(M, M1, mau: rgb("dc2626"))
        }
      )
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[2. Hình hộp chữ nhật] \
      #text(size: 8pt, fill: rgb("64748b"))[`hop-chu-nhat-fig(duong-cheo: true)`] \
      #v(2pt)
      #hop-chu-nhat-fig(duong-cheo: true)
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[3. Hình lập phương] \
      #text(size: 8pt, fill: rgb("64748b"))[`lap-phuong-fig()`] \
      #v(2pt)
      #lap-phuong-fig()
    ]
  ]
)

#v(15pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[4. Hình nón THPT] \
      #text(size: 8pt, fill: rgb("64748b"))[`non-fig(truc: true, r: 2.0)`] \
      #v(2pt)
      #non-fig()
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[5. Hình trụ THPT] \
      #text(size: 8pt, fill: rgb("64748b"))[`tru-fig(truc: true, r: 1.8)`] \
      #v(2pt)
      #tru-fig()
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[6. Mặt cầu THPT] \
      #text(size: 8pt, fill: rgb("64748b"))[`cau-fig(tam: true, r: 2.2)`] \
      #v(2pt)
      #cau-fig()
    ]
  ]
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// TRANG 5: HÌNH HỌC TỌA ĐỘ OXYZ (LỚP 12)
// ─────────────────────────────────────────────────────────────

#muc-gallery(
  "PHẦN 5",
  "HÌNH HỌC TỌA ĐỘ OXYZ CHUẨN SGK TOÁN 12",
  "Hệ trục tọa độ Oxyz trực quan, vectơ đơn vị i, j, k, cơ chế gióng hộp tự động của điểm M(x, y, z), mặt phẳng đoạn chắn x/a + y/b + z/c = 1 và tam giác trong không gian."
)

#grid(
  columns: (1fr, 1fr),
  gutter: 15pt,
  [
    #align(center)[
      #text(weight: "bold")[1. Hệ trục Oxyz & Điểm gióng hộp $M(2; 3; 2.5)$] \
      #text(size: 8pt, fill: rgb("64748b"))[`oxyz-fig` kết hợp `(d.giong-hop)(2, 3, 2.5)`] \
      #v(4pt)
      #oxyz-fig(
        x: 3.5, y: 4.2, z: 3.6,
        them: d => {
          (d.giong-hop)(2.0, 3.0, 2.5, nhan: $M(2; 3; 2.5)$)
        }
      )
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[2. Mặt phẳng đoạn chắn $x/a + y/b + z/c = 1$] \
      #text(size: 8pt, fill: rgb("64748b"))[`mat-phang-doan-chan-fig(a: 2.5, b: 3.2, c: 2.8)`] \
      #v(4pt)
      #mat-phang-doan-chan-fig(a: 2.5, b: 3.2, c: 2.8, ten: $(alpha)$)
    ]
  ]
)

#v(15pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 15pt,
  [
    #align(center)[
      #text(weight: "bold")[3. Tam giác $A B C$ & Trọng tâm $G$ trong không gian Oxyz] \
      #text(size: 8pt, fill: rgb("64748b"))[`tam-giac-oxyz-fig(...)` tự động gióng tọa độ đỉnh] \
      #v(4pt)
      #tam-giac-oxyz-fig(
        A: (2.2, 1.0, 3.0),
        B: (1.0, 3.5, 0.5),
        C: (3.0, 2.0, 0.0),
        hien-trong-tam: true,
      )
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[4. Hệ trục Oxyz với lưới tọa độ mặt phẳng đáy Oxy] \
      #text(size: 8pt, fill: rgb("64748b"))[`oxyz-fig(luoi: ("xy",), vach: true, so: true)`] \
      #v(4pt)
      #oxyz-fig(
        x: 3.0, y: 4.0, z: 3.0,
        don-vi: true,
        vach: true,
        so: true,
        luoi: ("xy",),
      )
    ]
  ]
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// TRANG 6: ĐƯỜNG CONG 3D & KHỐI TRÒN XOAY STUDIO TỰ DO
// ─────────────────────────────────────────────────────────────

#muc-gallery(
  "PHẦN 6",
  "ĐƯỜNG CONG 3D KHÔNG GIAN & KHỐI TRÒN XOAY STUDIO",
  "Đường xoắn ốc 3D Helix (Spring), hình xuyến 3D Torus, khối cầu Studio đa tầng Radial Gradient, khối trụ và nón 3D xoay góc tự do tương đương năng lực TeXgraph / Luadraw."
)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[1. Đường xoắn ốc 3D (`helix-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Helix 3 vòng, tự chia nét trước/sau] \
      #v(4pt)
      #helix-fig(radius: 1.5, height: 3.5, turns: 3.0)
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[2. Hình xuyến 3D (`torus-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Torus $R = 2.0, r = 0.65$ đổ bóng vàng] \
      #v(4pt)
      #torus-fig(R: 2.0, r: 0.65, palette: "gold")
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[3. Khối cầu Studio (`sphere-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Đổ bóng Radial Warm-Orange] \
      #v(4pt)
      #sphere-fig(radius: 2.2, shading: "orange")
    ]
  ]
)

#v(15pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  [
    #align(center)[
      #text(weight: "bold")[4. Hình trụ Studio (`cylinder-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Gradient tuyến tính thân trụ] \
      #v(4pt)
      #cylinder-fig(radius: 1.4, height-vector: (0.0, 0.0, 3.2))
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[5. Hình nón Studio (`cone-fig`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Gradient tuyến tính thân nón] \
      #v(4pt)
      #cone-fig(radius: 1.7, apex: (0.0, 0.0, 3.2))
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[6. Khối cầu Thạch Anh Tím] \
      #text(size: 8pt, fill: rgb("64748b"))[Shading Amethyst & Xích đạo] \
      #v(4pt)
      #sphere-fig(radius: 2.2, shading: "amethyst")
    ]
  ]
)

#pagebreak()

// ─────────────────────────────────────────────────────────────
// TRANG 7: ĐẠI SỐ HÌNH HỌC KHÔNG GIAN LINH HOẠT (GEOMETRIC ALGEBRA)
// ─────────────────────────────────────────────────────────────

#muc-gallery(
  "PHẦN 7",
  "ĐẠI SỐ HÌNH HỌC KHÔNG GIAN LINH HOẠT (GEOMETRIC ALGEBRA)",
  "Hệ thống giải tích và đại số hình học tự động: tọa độ điểm, vector, đường thẳng, mặt phẳng, mặt cầu, 4 tâm tam giác Euler, hình chiếu, đoạn vuông góc chung và thuật toán cắt thiết diện tự động."
)

#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  [
    #align(center)[
      #text(weight: "bold")[1. Cắt thiết diện tự động (`cat-thiet-dien`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Mặt phẳng qua M song song đáy (ABC)] \
      #v(4pt)
      #khong-gian-3d(
        cam: make-camera(elevation: 22deg, azimuth: 35deg, scale: 1.0),
        length: 1.1cm,
        g => {
          let A = pt(0, 0, 0); let B = pt(4, 0, 0); let C = pt(1, 3, 0); let S = pt(0, 0, 4)
          let M = trung-diem(S, B)
          let mp-cat = mat-phang(M, phap-tuyen: (0, 0, 1))
          let poly = (vertices: (S, A, B, C), faces: ((1, 2, 3), (0, 1, 2), (0, 2, 3), (0, 3, 1)))
          let td = cat-thiet-dien(poly, mp-cat)

          (g.doan)(A, B)
          (g.doan)(B, C)
          (g.doan)(C, A, dut: true)
          (g.doan)(S, A, dut: true)
          (g.doan)(S, B)
          (g.doan)(S, C)

          (g.diem)(A, ten: $A$, huong: "east", lech: (-0.12, 0.0))
          (g.diem)(B, ten: $B$, huong: "north", lech: (0.0, -0.15))
          (g.diem)(C, ten: $C$, huong: "west", lech: (0.12, 0.0))
          (g.diem)(S, ten: $S$, huong: "south", lech: (0.0, 0.15))
          (g.diem)(M, ten: $M$, huong: "north-west", mau: blue)

          if td.len() >= 3 {
            (g.da-giac)(td, fill: rgb("38bdf8").transparentize(70%), stroke: 1.2pt + blue)
          }
        }
      )
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[2. Đoạn vuông góc chung (`doan-vuong-goc-chung`)] \
      #text(size: 8pt, fill: rgb("64748b"))[Tự động tìm chân đoạn vuông góc nối SB và AC] \
      #v(4pt)
      #khong-gian-3d(
        cam: make-camera(elevation: 22deg, azimuth: 35deg, scale: 1.0),
        length: 1.1cm,
        g => {
          let A = pt(0, 0, 0); let B = pt(4, 0, 0); let C = pt(1, 3, 0); let S = pt(0, 0, 4)
          let line-SB = dt(S, diem2: B)
          let line-AC = dt(A, diem2: C)
          let perp = doan-vuong-goc-chung(line-SB, line-AC)

          (g.doan)(A, B)
          (g.doan)(B, C)
          (g.doan)(C, A, dut: true)
          (g.doan)(S, A, dut: true)
          (g.doan)(S, B)
          (g.doan)(S, C)

          (g.diem)(A, ten: $A$, huong: "east", lech: (-0.12, 0.0))
          (g.diem)(B, ten: $B$, huong: "north", lech: (0.0, -0.15))
          (g.diem)(C, ten: $C$, huong: "west", lech: (0.12, 0.0))
          (g.diem)(S, ten: $S$, huong: "south", lech: (0.0, 0.15))

          (g.doan)(perp.M1, perp.M2, dut: true, mau: red, day: 1.3pt)
          (g.diem)(perp.M1, ten: $M_1$, huong: "south-east", mau: red, bk: 2.2pt)
          (g.diem)(perp.M2, ten: $M_2$, huong: "north-west", mau: red, bk: 2.2pt)
          (g.goc-vuong)(S, perp.M1, perp.M2, size: 0.2, mau: red)
          (g.goc-vuong)(C, perp.M2, perp.M1, size: 0.2, mau: red)
        }
      )
    ]
  ]
)

#v(10pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  [
    #align(center)[
      #text(weight: "bold")[3. Bốn tâm tam giác & Đường thẳng Euler] \
      #text(size: 8pt, fill: rgb("64748b"))[Trực tâm H, Trọng tâm G, Ngoại tiếp O thẳng hàng] \
      #v(4pt)
      #khong-gian-3d(
        cam: make-camera(elevation: 30deg, azimuth: 20deg, scale: 1.0),
        length: 1.2cm,
        g => {
          let A = pt(0, 0, 0); let B = pt(4.5, 0.5, 0.5); let C = pt(1.5, 3.5, 1.0)
          let G = trong-tam-tam-giac(A, B, C)
          let O = tam-ngoai-tiep(A, B, C)
          let H = truc-tam(A, B, C)
          let I = tam-noi-tiep(A, B, C)

          (g.da-giac)((A, B, C), fill: rgb("f8fafc"), stroke: 1.2pt + black)
          (g.doan)(H, O, mau: rgb("dc2626"), day: 1.0pt) // Đường thẳng Euler

          (g.diem)(A, ten: $A$, huong: "east", lech: (-0.12, 0.0))
          (g.diem)(B, ten: $B$, huong: "north", lech: (0.0, -0.15))
          (g.diem)(C, ten: $C$, huong: "south", lech: (0.0, 0.15))

          (g.diem)(G, ten: $G$, huong: "north-west", mau: rgb("059669"), bk: 2.2pt)
          (g.diem)(O, ten: $O$, huong: "south-east", mau: rgb("0284c7"), bk: 2.2pt)
          (g.diem)(H, ten: $H$, huong: "north-east", mau: rgb("dc2626"), bk: 2.2pt)
          (g.diem)(I, ten: $I$, huong: "west", mau: rgb("9333ea"), bk: 2.2pt)
        }
      )
    ]
  ],
  [
    #align(center)[
      #text(weight: "bold")[4. Phép quay Rodrigues quanh trục 3D] \
      #text(size: 8pt, fill: rgb("64748b"))[Quay điểm A quanh trục OZ góc 60°, 120°, 180°] \
      #v(4pt)
      #khong-gian-3d(
        cam: make-camera(elevation: 25deg, azimuth: 40deg, scale: 1.0),
        length: 1.1cm,
        g => {
          let O = pt(0, 0, 0)
          let Z = pt(0, 0, 3.5)
          let A = pt(2.5, 0.0, 1.5)
          (g.vecto)(O, Z, ten: $z$, huong: "east", mau: rgb("475569"))

          let A1 = quay-quanh-truc(A, O, (0, 0, 1), 60deg)
          let A2 = quay-quanh-truc(A, O, (0, 0, 1), 120deg)
          let A3 = quay-quanh-truc(A, O, (0, 0, 1), 180deg)

          (g.doan)(O, A, dut: true, mau: rgb("94a3b8"))
          (g.doan)(O, A1, dut: true, mau: rgb("94a3b8"))
          (g.doan)(O, A2, dut: true, mau: rgb("94a3b8"))
          (g.doan)(O, A3, dut: true, mau: rgb("94a3b8"))

          (g.diem)(A, ten: $A_0$, huong: "north", mau: rgb("ea580c"), bk: 2.2pt)
          (g.diem)(A1, ten: $A_1$, huong: "north", mau: rgb("0284c7"), bk: 2.2pt)
          (g.diem)(A2, ten: $A_2$, huong: "north", mau: rgb("059669"), bk: 2.2pt)
          (g.diem)(A3, ten: $A_3$, huong: "north", mau: rgb("9333ea"), bk: 2.2pt)

          // Cung quỹ đạo tròn
          let arc-pts = ()
          for step in range(19) {
            let ang = step * 10deg
            arc-pts.push(quay-quanh-truc(A, O, (0, 0, 1), ang))
          }
          (g.da-giac)(arc-pts, stroke: (paint: rgb("ea580c"), thickness: 1.0pt, dash: "dashed"), close: false)
        }
      )
    ]
  ]
)

#v(15pt)
#align(center)[
  #block(
    fill: rgb("eff6ff"),
    stroke: 1pt + rgb("93c5fd"),
    radius: 6pt,
    inset: (x: 15pt, y: 10pt),
    width: 95%,
  )[
    #text(weight: "bold", size: 10pt, fill: rgb("1e40af"))[
      🎉 TYPDRAW3D v0.3.0 — ĐẦY ĐỦ TRỌN BỘ TẤT CẢ CÁC GÓI LỆNH HÌNH HỌC 3D & ĐẠI SỐ LINH HOẠT!
    ] \
    #v(2pt)
    #text(size: 8.5pt, fill: rgb("334155"))[
      Mọi khối hình đều có sẵn hàm độc lập 1 dòng lệnh kết thúc bằng `-fig` và môi trường dựng hình đại số linh hoạt `khong-gian-3d`. Người dùng hoàn toàn tự do giải tích hình học, tìm hình chiếu, giao tuyến, góc, khoảng cách, đoạn vuông góc chung, thiết diện tự động và quay Rodrigues trực quan.
    ]
  ]
]
