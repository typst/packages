#import "@preview/sang-math:1.1.1": mcq, sang-setup
#set page(paper: "a4", margin: 15mm)
#set text(font: "Times New Roman", size: 12pt)
#set par(leading: 0.3em)
#show: sang-setup

// These assertions run inside the question's paragraph rules, so a legacy
// engine that reserves only cap-height/baseline fails the overlap check.
#mcq([
  #context {
    let f = [$(1+1/x)/(1+1/x^2)$]
    let full = measure(box(text(top-edge: "bounds", bottom-edge: "bounds", f))).height
    let two = measure(block[#f #linebreak() #f]).height
    assert(two >= 2 * full + 2pt, message: "Two nested fractions must reserve both complete glyph frames")
    metadata((kind: "fraction-flow", full: full / 1pt, two: two / 1pt))
  }
  Hai dòng phân số lớn, không thu nhỏ công thức:
  $(1+1/x)/(1+1/x^2)$ #linebreak()
  $(1+1/x)/(1+1/x^2)$
], ([$1$], [$2$], [$3$], [$4$]), cols: 4)

#mcq([Các nhãn cùng hàng giữ chung đường chân chữ.], (
  [$(1+1/x)/(1+1/x^2)$],
  [$1/2$],
  [$x^((1+1/2)/(1+1/3))$],
  [Một phương án dài có phân số $1/2$, tiếp tục qua nhiều dòng; nhãn thụt treo và không chạm hàng kế tiếp.],
), cols: 2)

#mcq([Hệ, ma trận và phân số đều giữ kích thước tự nhiên.], (
  [$cases((x+1)/(x-1) & x>1, x^2 & x<=1)$],
  [$mat(1,2;3,4)$],
  [$a^(1/6)$],
  [$a^(5/3)$],
), cols: 2)

#mcq([Lựa chọn cột theo độ rộng nội dung.], (
  [Phương án văn bản đủ dài để cần một cột nhưng vẫn có khoảng cách vừa phải.],
  [Nội dung có phân số $1/2$ và các dấu câu tiếng Việt.],
  [Phương án thứ ba không bị ép chiều cao theo hàng công thức khác.],
  [Phương án thứ tư kết thúc câu.],
))
