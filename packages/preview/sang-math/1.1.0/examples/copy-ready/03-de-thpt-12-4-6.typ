// MẪU 03 — KHUNG ĐỀ THPT 12–4–6
// 12 câu TN + 4 câu Đ/S + 6 câu TLN. Mọi câu có ID ổn định để dùng online.

#import "@preview/sang-math:1.0.2": *

#let profile = sys.inputs.at("profile", default: "dethi")
#let preset = exam-preset(theme: "lotus", profile: profile)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)

#show: sang-setup.with(math-color: black)
#show: exam-theme.with(
  theme: preset.theme,
  department: "SỞ GIÁO DỤC VÀ ĐÀO TẠO",
  school: "TRƯỜNG THPT ................................",
  exam-title: "ĐỀ THI THỬ TỐT NGHIỆP THPT",
  subject: "MÔN TOÁN",
  duration: "90 phút",
  code: "101",
  footer-left: [Đề gồm 12 câu TN, 4 câu Đ/S và 6 câu TLN],
  ..preset.template,
)

#exam-part([PHẦN I. Câu trắc nghiệm nhiều phương án lựa chọn], count: 12)

#tn([Đạo hàm của $f(x)=x^3-3x$ là], ([$3x^2$], True([$3x^2-3$]), [$x^2-3$], [$3x-3$]), id: "TN01", tags: ("dao-ham", "NB"), loigiai: [$f'(x)=3x^2-3$.])
#tn([Tập xác định của $y=log_2(x-1)$ là], ([$(0;+oo)$], True([$(1;+oo)$]), [$[1;+oo)$], [$RR$]), id: "TN02", tags: ("logarit", "NB"), loigiai: [Điều kiện $x-1>0 <=> x>1$.])
#tn([Nghiệm của $2^x=16$ là], ([$2$], [$3$], True([$4$]), [$8$]), id: "TN03", tags: ("mu", "NB"), loigiai: [$16=2^4$.])
#tn([Nguyên hàm của $2x$ là], ([$x^2$], True([$x^2+C$]), [$2x^2+C$], [$x+C$]), id: "TN04", tags: ("nguyen-ham", "NB"), loigiai: [$integral 2x dif x=x^2+C$.])
#tn([Tiệm cận đứng của $y=frac(2x+1,x-3)$ là], ([$x=-3$], [$y=2$], True([$x=3$]), [$y=3$]), id: "TN05", tags: ("tiem-can", "TH"), loigiai: [Mẫu bằng $0$ tại $x=3$ và tử khác $0$.])
#tn([Giá trị lớn nhất của $-x^2+4x+1$ trên $RR$ là], ([$1$], [$4$], True([$5$]), [$9$]), id: "TN06", tags: ("cuc-tri", "TH"), loigiai: [Đỉnh parabol có hoành độ $x=2$ và tung độ $5$.])
#tn([Cho cấp số cộng $u_1=2$, $d=3$. Giá trị $u_5$ bằng], ([$11$], True([$14$]), [$17$], [$20$]), id: "TN07", tags: ("day-so", "TH"), loigiai: [$u_5=2+4 dot 3=14$.])
#tn([Một hộp có 3 bi đỏ và 2 bi xanh. Xác suất lấy được bi đỏ là], ([$frac(2,5)$], True([$frac(3,5)$]), [$frac(1,2)$], [$frac(3,2)$]), id: "TN08", tags: ("xac-suat", "TH"), loigiai: [$P=frac(3,5)$.])
#tn([Trong $O x y z$, một vectơ pháp tuyến của mặt phẳng $2x-y+3z-1=0$ là], ([$(2,1,3)$], True([$(2,-1,3)$]), [$(-2,1,3)$], [$(1,-1,3)$]), id: "TN09", tags: ("oxyz", "NB"), loigiai: [Lấy bộ hệ số của $x,y,z$.])
#tn([Nếu $sin alpha=frac(3,5)$ và $alpha$ nhọn thì $cos alpha$ bằng], ([$frac(3,5)$], True([$frac(4,5)$]), [$frac(5,4)$], [$frac(1,5)$]), id: "TN10", tags: ("luong-giac", "TH"), loigiai: [$cos alpha=sqrt(1-frac(9,25))=frac(4,5)$.])
#tn([Số nghiệm nguyên của $x^2-5x+6<=0$ là], ([$1$], True([$2$]), [$3$], [$4$]), id: "TN11", tags: ("bat-phuong-trinh", "TH"), loigiai: [Nghiệm thực là $[2;3]$, gồm hai số nguyên $2,3$.])
#tn([Với $f(x)=x^4-2x^2$, đặt $t=x^2$ thì $f(x)$ bằng], ([$t^2+2t$], True([$t^2-2t$]), [$t-2t^2$], [$t^4-2t$]), id: "TN12", tags: ("doi-bien", "TH"), loigiai: [$x^4=t^2$ và $x^2=t$.])

#exam-part([PHẦN II. Câu trắc nghiệm đúng / sai], count: 4)

#ds([Cho $f(x)=x^3-3x$.], (True([$f'(x)=3x^2-3$]), True([$f'(1)=0$]), [$f$ đồng biến trên $(-1;1)$], True([$f(1)=-2$])), id: "DS01", tags: ("dao-ham", "DS"), loigiai: [$f'(x)=3(x^2-1)<0$ trên $(-1;1)$.])
#ds([Cho cấp số nhân có $u_1=3$, $q=2$.], (True([$u_2=6$]), True([$u_4=24$]), [$u_5=36$], [$u_n=3n^2$]), id: "DS02", tags: ("day-so", "DS"), loigiai: [$u_n=3 dot 2^(n-1)$ và $u_5=48$.])
#ds([Cho mặt cầu $(S):(x-1)^2+(y+2)^2+z^2=9$.], (True([Tâm là $I(1,-2,0)$]), True([Bán kính bằng $3$]), [$O$ nằm trên mặt cầu], True([$A(1,-2,3)$ nằm trên mặt cầu])), id: "DS03", tags: ("oxyz", "DS"), loigiai: [Thay tọa độ từng điểm vào phương trình.])
#ds([Một biến cố $A$ có $P(A)=0,35$.], (True([$0<=P(A)<=1$]), [$P(overline(A))=0,35$], True([$P(overline(A))=0,65$]), [$P(A)+P(overline(A))=0$]), id: "DS04", tags: ("xac-suat", "DS"), loigiai: [$P(overline(A))=1-P(A)=0,65$.])

#exam-part([PHẦN III. Câu trả lời ngắn], count: 6)

#tln([Tính $f'(2)$ với $f(x)=x^3+x$.], [$13$], id: "TLN01", tags: ("dao-ham", "TLN"), loigiai: [$f'(2)=3 dot 2^2+1=13$.])
#tln([Tìm tổng các nghiệm của $x^2-7x+10=0$.], [$7$], id: "TLN02", tags: ("viete", "TLN"), loigiai: [Theo Viète, tổng nghiệm bằng $7$.])
#tln([Hình hộp chữ nhật có ba kích thước $2,3,4$. Tính thể tích.], [$24$], id: "TLN03", tags: ("the-tich", "TLN"), loigiai: [$V=2 dot 3 dot 4=24$.])
#tln([Tính $log_2 32$.], [$5$], id: "TLN04", tags: ("logarit", "TLN"), loigiai: [$32=2^5$.])
#tln([Có bao nhiêu cách xếp 4 học sinh thành một hàng?], [$24$], id: "TLN05", tags: ("hoan-vi", "TLN"), loigiai: [$4!=24$.])
#tln([Cho $vec(a)=(1,2,2)$. Tính độ dài của $vec(a)$.], [$3$], id: "TLN06", tags: ("vecto", "TLN"), loigiai: [$abs(vec(a))=sqrt(1+4+4)=3$.])

#het
