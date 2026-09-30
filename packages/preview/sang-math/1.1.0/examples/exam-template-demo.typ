// Demo đầy đủ cho sang-math 1.0.2
// SỬA NHANH NGAY TRONG FILE, KHÔNG CẦN DÒNG LỆNH:
//
// 1) Chọn kiểu đầu ra bằng cách sửa profile:
//    "dethi"   -> đề học sinh
//    "loigiai" -> lời giải + bảng đáp án cuối đề
//    "compact" -> đề 2 cột
//    "draft"   -> có nháp bên phải từng câu
//    "beamer"  -> bỏ header/trang in, sẵn chuyển sang sang-beamer.typ
//
// 2) Chọn màu/mẫu bằng cách sửa theme:
//    classic | ocean | emerald | royal | violet | crimson | graphite | amber | teal-pro
//    sky | indigo-minimal | print-economy | aurora | lotus | navy-gold | jade | coral | plum
//
// 3) Chọn kiểu A/B/C/D bằng cách sửa opt-style:
//    auto hoặc "plain" = kiểu nguyên thuỷ A. B. C. D.
//    "theme" = theo theme. Ví dụ theme "teal-pro" tự dùng "solid-pentagon".
//    Muốn ép một kiểu cụ thể thì viết trong dấu nháy:
//    "circle" | "solid-circle" | "double-circle" | "pentagon" | "solid-pentagon"
//    "hexagon" | "solid-hexagon" | "diamond" | "solid-diamond" | "triangle" | "badge"
//
// 4) Các dòng ví dụ bật nhanh:
//    #let profile = "loigiai"     // lời giải + bảng đáp án
//    #let profile = "compact"     // đề 2 cột
//    #let profile = "draft"       // có nháp bên phải
//    #let theme = "aurora"        // mẫu xanh sáng
//    #let opt-style = "plain"     // A. B. C. D. nguyên thuỷ
//    #let opt-style = "circle"    // A/B/C/D khoanh tròn
//    #let opt-style = "hexagon"   // A/B/C/D trong lục giác đều

#import "../lib.typ": *

// BẢNG ĐIỀU KHIỂN: sửa các dòng này là đủ.
#let theme = "teal-pro"
#let profile = "loigiai"
#let opt-style = auto          // auto = "plain" = A. B. C. D.
// #let opt-style = "theme"    // theo theme: teal-pro tự dùng "solid-pentagon"
// #let opt-style = "circle"
// #let opt-style = "hexagon"
// #let opt-style = "solid-hexagon"
#let q-label-style = auto
#let answer-key = auto
#let two-columns = auto
#let draft = auto

#let preset = exam-preset(
  theme: theme,
  profile: profile,
  opt-style: opt-style,
  q-label-style: q-label-style,
  answer-key: answer-key,
  two-columns: two-columns,
  draft: draft,
)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: preset.accent)

#let render-exam(body) = {
  let common = (
    department: "SỞ GIÁO DỤC VÀ ĐÀO TẠO",
    school: "TRƯỜNG THPT SANG-MATH",
    exam-title: "ĐỀ MẪU TEMPLATE SANG-MATH 1.0.2",
    subject: "TOÁN 12",
    duration: "90 phút",
    code: "101",
    footer-left: [Sang Math 1.0.2 — Demo đủ 12 TN, 4 Đ/S, 6 TLN, 3 TL],
  )

  exam-theme(body, theme: preset.theme, ..common, ..preset.template)
}

#show: render-exam

#exam-part([PHẦN I. Câu trắc nghiệm nhiều phương án], count: 12)

#tn(
  [Đạo hàm của hàm số $f(x) = x^3 - 3 x + 2$ là],
  ([$3 x^2$], True([$3 x^2 - 3$]), [$x^2 - 3$], [$3 x^2 + 2$]),
  id: "TN01",
  tags: ("dao-ham", "nhan-biet"),
  loigiai: [$f'(x) = 3 x^2 - 3$.],
)

#tn(
  [Tập xác định của hàm số $y = log_2 (x - 1)$ là],
  ([$(0; +oo)$], True([$(1; +oo)$]), [$[1; +oo)$], [$RR$]),
  id: "TN02",
  tags: ("logarit", "tap-xac-dinh"),
  loigiai: [Điều kiện $x - 1 > 0 <=> x > 1$.],
)

#tn(
  [Cho cấp số cộng có $u_1 = 2$ và công sai $d = 3$. Số hạng $u_5$ bằng],
  ([$11$], True([$14$]), [$17$], [$20$]),
  id: "TN03",
  tags: ("day-so", "cap-so-cong"),
  loigiai: [$u_5 = u_1 + 4 d = 2 + 12 = 14$.],
)

#tn(
  [Nghiệm của phương trình $2^x = 16$ là],
  ([$2$], [$3$], True([$4$]), [$8$]),
  id: "TN04",
  tags: ("mu-logarit", "phuong-trinh"),
  loigiai: [$16 = 2^4$ nên $x = 4$.],
)

#tn(
  [Giá trị lớn nhất của $f(x)= -x^2 + 4 x + 1$ trên $RR$ là],
  ([$1$], [$4$], True([$5$]), [$9$]),
  id: "TN05",
  tags: ("cuc-tri", "parabol"),
  loigiai: [Đỉnh parabol có $x = 2$, $f(2)=5$.],
)

#tn(
  [Một hộp có 3 bi đỏ và 2 bi xanh. Lấy ngẫu nhiên 1 bi. Xác suất lấy được bi đỏ là],
  ([$frac(2, 5)$], True([$frac(3, 5)$]), [$frac(1, 2)$], [$frac(3, 2)$]),
  id: "TN06",
  tags: ("xac-suat", "co-ban"),
  loigiai: [Có 3 kết quả thuận lợi trong 5 khả năng đồng khả năng.],
)

#tn(
  [Trong không gian $O x y z$, vectơ pháp tuyến của mặt phẳng $2 x - y + 3 z - 1 = 0$ là],
  ([$(2, 1, 3)$], True([$(2, -1, 3)$]), [$(-2, 1, -3)$], [$(1, -1, 3)$]),
  id: "TN07",
  tags: ("oxyz", "mat-phang"),
  loigiai: [Mặt phẳng $a x + b y + c z + d = 0$ có pháp tuyến $(a,b,c)$.],
)

#tn(
  [Nguyên hàm của hàm số $f(x)=2 x$ là],
  ([$x^2$], True([$x^2 + C$]), [$2 x^2 + C$], [$x + C$]),
  id: "TN08",
  tags: ("nguyen-ham", "co-ban"),
  loigiai: [$integral 2 x dif x = x^2 + C$.],
)

#tn(
  [Nếu $sin alpha = frac(3,5)$ và $alpha$ nhọn thì $cos alpha$ bằng],
  ([$frac(3,5)$], True([$frac(4,5)$]), [$frac(5,4)$], [$frac(1,5)$]),
  id: "TN09",
  tags: ("luong-giac", "tam-giac"),
  loigiai: [$cos alpha = sqrt(1 - frac(9,25)) = frac(4,5)$.],
)

#tn(
  [Số nghiệm nguyên của bất phương trình $x^2 - 5 x + 6 <= 0$ là],
  ([$1$], True([$2$]), [$3$], [$4$]),
  id: "TN10",
  tags: ("bat-phuong-trinh", "tam-thuc"),
  loigiai: [$x^2 - 5x + 6 = (x-2)(x-3)$ nên $x in [2;3]$. Nghiệm nguyên là $2,3$, có 2 nghiệm.],
)

#tn(
  [Đường tiệm cận đứng của đồ thị $y = frac(2 x + 1, x - 3)$ là],
  ([$x = -3$], [$y = 2$], True([$x = 3$]), [$y = 3$]),
  id: "TN11",
  tags: ("tiem-can", "ham-phan-thuc"),
  loigiai: [Mẫu bằng 0 tại $x=3$, tử khác 0 nên $x=3$ là tiệm cận đứng.],
)

#tn(
  [Cho hàm số $f(x)=x^4 - 2 x^2$. Khi đặt $t=x^2$, biểu thức $f(x)$ trở thành],
  ([$t^2 + 2t$], True([$t^2 - 2t$]), [$t - 2 t^2$], [$t^4 - 2t$]),
  id: "TN12",
  tags: ("doi-bien", "ham-bac-bon"),
  loigiai: [Vì $x^4 = t^2$ và $x^2=t$, suy ra $f=t^2-2t$.],
)

#exam-part([PHẦN II. Câu trắc nghiệm đúng / sai], count: 4)

#ds(
  [Cho hàm số $f(x)=x^3-3x$. Xét các khẳng định sau:],
  (
    True([$f'(x)=3x^2-3$]),
    True([Phương trình $f'(x)=0$ có hai nghiệm $x=-1, x=1$]),
    [$f$ đồng biến trên khoảng $(-1;1)$],
    True([$f(1)=-2$]),
  ),
  id: "DS01",
  tags: ("dao-ham", "dung-sai"),
  loigiai: [Ta có $f'(x)=3(x^2-1)$. Trên $(-1;1)$, $f'<0$ nên hàm nghịch biến.],
)

#ds(
  [Cho cấp số nhân có $u_1=3$, công bội $q=2$. Xét các mệnh đề:],
  (
    True([$u_2=6$]),
    True([$u_4=24$]),
    [$u_5=36$],
    [$u_n=3 n^2$],
  ),
  id: "DS02",
  tags: ("day-so", "cap-so-nhan"),
  loigiai: [$u_n = 3 dot 2^(n-1)$ nên $u_5=48$.],
)

#ds(
  [Trong không gian, cho mặt cầu $(S): (x-1)^2 + (y+2)^2 + z^2 = 9$.],
  (
    True([Tâm mặt cầu là $I(1,-2,0)$]),
    True([Bán kính mặt cầu bằng $3$]),
    [$O(0,0,0)$ nằm trên mặt cầu],
    True([Điểm $A(1,-2,3)$ nằm trên mặt cầu]),
  ),
  id: "DS03",
  tags: ("oxyz", "mat-cau"),
  loigiai: [Thay tọa độ vào phương trình mặt cầu để kiểm tra từng ý.],
)

#ds(
  [Một biến cố $A$ có $P(A)=0.35$. Xét các khẳng định:],
  (
    True([$0 <= P(A) <= 1$]),
    [$P(overline(A))=0.35$],
    True([$P(overline(A))=0.65$]),
    [$P(A)+P(overline(A))=0$],
  ),
  id: "DS04",
  tags: ("xac-suat", "bien-co-doi"),
  loigiai: [Biến cố đối có xác suất $1-0.35=0.65$.],
)

#exam-part([PHẦN III. Câu trả lời ngắn], count: 6)

#tln(
  [Tính $f'(2)$ biết $f(x)=x^3+x$.],
  [$13$],
  id: "TLN01",
  tags: ("dao-ham", "tln"),
  loigiai: [$f'(x)=3x^2+1$, nên $f'(2)=13$.],
)

#tln(
  [Tìm tổng các nghiệm của phương trình $x^2 - 7x + 10 = 0$.],
  [$7$],
  id: "TLN02",
  tags: ("phuong-trinh", "viet"),
  loigiai: [Theo Viète, tổng nghiệm bằng $7$.],
)

#tln(
  [Một hình hộp chữ nhật có kích thước $2,3,4$. Thể tích bằng bao nhiêu?],
  [$24$],
  id: "TLN03",
  tags: ("the-tich", "hinh-hoc"),
  loigiai: [$V=2 dot 3 dot 4=24$.],
)

#tln(
  [Tính $log_2 32$.],
  [$5$],
  id: "TLN04",
  tags: ("logarit", "tln"),
  loigiai: [$32=2^5$.],
)

#tln(
  [Có bao nhiêu cách xếp 4 học sinh thành một hàng ngang?],
  [$24$],
  id: "TLN05",
  tags: ("hoan-vi", "dem"),
  loigiai: [Số cách là $4! = 24$.],
)

#tln(
  [Cho $overrightarrow(a)=(1,2,2)$. Độ dài $overrightarrow(a)$ bằng bao nhiêu?],
  [$3$],
  id: "TLN06",
  tags: ("vecto", "oxyz"),
  loigiai: [$abs(overrightarrow(a)) = sqrt(1^2+2^2+2^2)=3$.],
)

#exam-part([PHẦN IV. Câu tự luận], count: 3)

#tl(
  [Khảo sát sự biến thiên của hàm số $y=x^3-3x+1$ và tìm các điểm cực trị.],
  id: "TL01",
  tags: ("tu-luan", "khao-sat"),
  lines: 6,
  loigiai: [
    Ta có $y'=3x^2-3=3(x-1)(x+1)$.
    Suy ra $y'=0 <=> x=-1$ hoặc $x=1$.
    Bảng dấu cho thấy hàm đồng biến trên $(-oo,-1)$ và $(1,+oo)$, nghịch biến trên $(-1,1)$.
    $y(-1)=3$, $y(1)=-1$. Vậy cực đại tại $(-1,3)$, cực tiểu tại $(1,-1)$.
  ],
)

#tl(
  [Giải bất phương trình $log_2(x-1) >= 3$.],
  id: "TL02",
  tags: ("tu-luan", "logarit"),
  lines: 5,
  loigiai: [
    Điều kiện $x>1$.
    Vì cơ số $2>1$, ta có $log_2(x-1) >= 3 <=> x-1 >= 2^3 = 8$.
    Suy ra $x >= 9$. Kết hợp điều kiện, nghiệm là $[9,+oo)$.
  ],
)

#tl(
  [Trong không gian $O x y z$, viết phương trình mặt cầu tâm $I(1,-2,3)$ đi qua điểm $A(3,-2,3)$.],
  id: "TL03",
  tags: ("tu-luan", "mat-cau"),
  lines: 5,
  loigiai: [
    Bán kính $R=I A=sqrt((3-1)^2+(-2+2)^2+(3-3)^2)=2$.
    Phương trình mặt cầu là $(x-1)^2+(y+2)^2+(z-3)^2=4$.
  ],
)

#het
