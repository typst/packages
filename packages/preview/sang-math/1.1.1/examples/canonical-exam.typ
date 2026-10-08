// MẪU CHUẨN DUY NHẤT — Sang Math 1.1.1, cấu trúc 12 TN / 2 ĐS / 4 TLN.
// Chỉ đổi CẤU HÌNH và vùng CÂU HỎI. Không khai báo lại macro của gói.
#import "@preview/sang-math:1.1.1": *

// ==================== CẤU HÌNH ====================
#let config = (
  mode: sys.inputs.at("mode", default: "dethi"), // dethi | loigiai | solcolor
  ma-de: sys.inputs.at("made", default: "1201"),
  accent: rgb("d97706"),
  school: "TRƯỜNG THPT NGUYỄN HỮU CẢNH",
  title: "ĐỀ KIỂM TRA MÔN TOÁN",
  subject: "TOÁN 12",
  duration: "45 phút",
  answer-table: sys.inputs.at("answer-table", default: "auto"), // auto | 0 | 1
  qr: sys.inputs.at("qr", default: "0") == "1", // trang riêng cho giáo viên
  omr-id: "new-12-2-4-a5",
  omr-paper: "a5",
  sheet: sys.inputs.at("sheet", default: "0") == "1",
  sbd-prefix: sys.inputs.at("sbd", default: "1001"),
)
#assert(config.mode in ("dethi", "loigiai", "solcolor"), message: "mode: dethi, loigiai hoặc solcolor")
#assert(config.answer-table in ("auto", "0", "1"), message: "answer-table: auto, 0 hoặc 1")
#let (tn, ds, tln, tl) = exam-mode(mode: config.mode, accent: config.accent, show-tags: false)

#show: thpt-school-exam.with(
  department: "SỞ GIÁO DỤC VÀ ĐÀO TẠO",
  school: config.school,
  exam-title: config.title,
  subject: config.subject,
  duration: config.duration,
  structure: auto,
  code: config.ma-de,
  footer-left: [Biên soạn: GV Nguyễn Sáng],
  accent: config.accent,
  show-topbar: false,
)
// Quy tắc định dạng Typst; đây không phải macro thay thế engine của gói.
#show math.frac: math.display
#show math.cases: math.display
#set text(top-edge: "bounds", bottom-edge: "bounds")
#set par(leading: 0.65em)

// Phiếu lấy từ chính gói, không cần import engine hay include của một đề khác.
#if config.sheet and config.mode == "dethi" {
  state("sbd").update(config.sbd-prefix)
  state("made").update(config.ma-de)
  sang-omr-sheet(profile: config.omr-id)
}

// ==================== CÂU HỎI ====================
// TN: đúng một True(...). Đ/S: True(...) cho ý đúng; ý sai để [...].
// TLN: đáp án chuỗi, ví dụ "-1,5", "0,05", "0042". Không truyền ans:.
#exam-part([PHẦN I. Câu trắc nghiệm nhiều phương án lựa chọn], count: 12, reset-counter: true)

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

#exam-part([PHẦN II. Câu trắc nghiệm đúng / sai], count: 2, reset-counter: true)

#ds([Cho $f(x)=x^3-3x$.], (True([$f'(x)=3x^2-3$]), True([$f'(1)=0$]), [$f$ đồng biến trên $(-1;1)$], True([$f(1)=-2$])), id: "DS01", tags: ("dao-ham", "DS"), loigiai: [$f'(x)=3(x^2-1)<0$ trên $(-1;1)$.])
#ds([Cho cấp số nhân có $u_1=3$, $q=2$.], (True([$u_2=6$]), True([$u_4=24$]), [$u_5=36$], [$u_n=3n^2$]), id: "DS02", tags: ("day-so", "DS"), loigiai: [$u_n=3 dot 2^(n-1)$ và $u_5=48$.])

#exam-part([PHẦN III. Câu trả lời ngắn], count: 4, reset-counter: true)

#tln([Tính $f'(2)$ với $f(x)=x^3+x$.], "13", id: "TLN01", tags: ("dao-ham", "TLN"), loigiai: [$f'(2)=3 dot 2^2+1=13$.])
#tln([Tìm tổng các nghiệm của $x^2-7x+10=0$.], "7", id: "TLN02", tags: ("viete", "TLN"), loigiai: [Theo Viète, tổng nghiệm bằng $7$.])
#tln([Hình hộp chữ nhật có ba kích thước $2,3,4$. Tính thể tích.], "24", id: "TLN03", tags: ("the-tich", "TLN"), loigiai: [$V=2 dot 3 dot 4=24$.])
#tln([Tính $log_2 32$.], "5", id: "TLN04", tags: ("logarit", "TLN"), loigiai: [$32=2^5$.])

#het

// ==================== XUẤT ĐÁP ÁN ====================
// Lấy từ state do gói tạo khi đọc câu hỏi; không chép một bảng đáp án thứ hai.
// JSON là metadata vô hình của mẫu, không phải một macro ghi file của gói.
#context {
  let mc = state("se-mcq", ()).final()
  let tf = state("se-tf", ()).final()
  let sh = state("se-sh", ()).final()
  assert(mc.all(q => q.ans in ("A", "B", "C", "D")), message: "TN thiếu đáp án hợp lệ")
  assert(tf.all(q => q.ans.len() == 4), message: "Mỗi câu Đ/S phải có bốn ý")
  assert(sh.all(q => type(q.ans) == str), message: "Đáp án TLN trong mẫu chuẩn phải là chuỗi")
  let mc-keys = (:)
  let tf-keys = (:)
  let sh-keys = (:)
  for (i, q) in mc.enumerate() { mc-keys.insert(str(i + 1), q.ans) }
  for (i, q) in tf.enumerate() {
    let values = (:)
    for (j, label) in ("a", "b", "c", "d").enumerate() { values.insert(label, q.ans.at(j)) }
    tf-keys.insert(str(mc.len() + i + 1), values)
  }
  for (i, q) in sh.enumerate() { sh-keys.insert(str(mc.len() + tf.len() + i + 1), q.ans) }
  [#metadata((
    v: 1,
    meta: (
      source: "sang-math", made: config.ma-de,
      omr: (id: config.omr-id, mcq: mc.len(), tf: tf.len(), tln: sh.len(), paper: config.omr-paper),
    ),
    keys: ((config.ma-de): (
      mcq: mc-keys,
      tf: tf-keys,
      tln: sh-keys,
    )),
  )) <sang-math-answer-key>]
}

#if config.answer-table == "1" or (config.answer-table == "auto" and config.mode != "dethi") {
  pagebreak()
  align(center)[#text(weight: "bold")[ĐÁP ÁN — MÃ ĐỀ #config.ma-de]]
  print-answer-key()
}

#if config.qr {
  pagebreak()
  align(center)[#text(weight: "bold")[QR ĐÁP ÁN — DÀNH RIÊNG CHO GIÁO VIÊN]]
  align(center)[#sang-omr-qr(ma-de: config.ma-de, paper: config.omr-paper, profile: config.omr-id)]
}
