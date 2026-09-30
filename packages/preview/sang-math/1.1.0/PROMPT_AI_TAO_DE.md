# Prompt hướng dẫn AI tạo đề bằng sang-math 1.0.5

File này dành cho giáo viên sưu tầm câu hỏi, dùng OCR/app/AI tạo phần phổ biến và
chỉ tự biên soạn các câu khó. Có thể sao chép nguyên prompt tổng bên dưới vào
ChatGPT, Gemini, Claude hoặc một AI viết mã khác.

Nếu không muốn tự sao chép prompt, dùng trang **AI sang-math có kiểm định** tại
`https://hdsd-conictypst.pages.dev/ai-sang-math.html`. Trang này tự gắn hợp đồng
API 1.0.5, kiểm tra cấu trúc đầu ra và gửi lỗi lại model để sửa.

## 1. Prompt tổng — tạo một đề mới

Sao chép toàn bộ khối sau và thay các phần trong `{{...}}`:

```text
Bạn là chuyên gia Toán THPT Việt Nam và chuyên gia Typst. Hãy tạo một file Typst
hoàn chỉnh, biên dịch được, dùng đúng package:

#import "@preview/sang-math:1.0.5": *

YÊU CẦU ĐỀ:
- Lớp: {{10/11/12}}.
- Chủ đề/phạm vi: {{ghi rõ chương, bài hoặc ma trận}}.
- Thời gian: {{15/45/60/90 phút}}.
- Cấu trúc: {{ví dụ 12 TN + 4 Đúng/Sai + 6 Trả lời ngắn}}.
- Mức độ: {{x% nhận biết, x% thông hiểu, x% vận dụng, x% vận dụng cao}}.
- Theme: {{teal-pro/lotus/navy-gold/print-economy/...}}.
- Mã đề: {{101}}.
- Chế độ mặc định: dethi; có thể đổi thành loigiai bằng biến profile.
- Yêu cầu riêng: {{nội dung thực tế, câu phân hóa, có/không hình, ...}}.

QUY TẮC API BẮT BUỘC:
1. Tạo preset và bốn hàm câu hỏi đúng mẫu:
   #let preset = exam-preset(theme: "...", profile: profile)
   #let (tn, ds, tln, tl) = exam-mode(..preset.question)
2. Dùng #exam-part(...) để chia phần. Số câu khai báo phải đúng số câu thật.
3. Trắc nghiệm nhiều phương án dùng đúng dạng:
   #tn([Nội dung], ([$A$], True([$B$]), [$C$], [$D$]), id: "TN01", tags: (...), loigiai: [...])
   Mỗi câu TN phải có đúng 4 phương án và đúng 1 True(...).
4. Đúng/Sai dùng đúng dạng:
   #ds([Nội dung chung], (True([ý đúng]), [ý sai], True([ý đúng]), [ý sai]), id: "DS01", loigiai: [...])
   Mỗi câu Đ/S phải có đúng 4 mệnh đề. Chỉ mệnh đề đúng mới bọc True(...).
5. Trả lời ngắn dùng đúng dạng:
   #tln([Nội dung], [$đáp án$], id: "TLN01", loigiai: [...])
   Đáp án phải ngắn, duy nhất hoặc có quy tắc chấp nhận rõ; không để trống.
6. Tự luận dùng đúng dạng:
   #tl([Nội dung], id: "TL01", lines: 6, loigiai: [...])
   Không truyền đáp án ở đối số thứ hai của #tl.
7. ID phải duy nhất, ổn định và tuần tự: TN01..., DS01..., TLN01..., TL01....
8. Mỗi câu có tags gồm chủ đề và mức độ: "NB", "TH", "VD" hoặc "VDC".
9. Công thức dùng cú pháp Typst, không dùng LaTeX thô:
   - dùng frac(a,b), sqrt(x), integral, dif, pi, RR, ZZ;
   - dùng dfrac(a,b) khi cần phân số lớn và tfrac(a,b) khi cố ý cần phân số nhỏ inline;
   - hệ dùng heva(...), lựa chọn trường hợp dùng hoac(...);
   - không viết \frac, \sqrt, \begin{cases}, \mathrm hoặc dấu $ kiểu LaTeX sai cú pháp.
10. Không tự bịa macro ngoài API. Không dùng các tên như question(), choices(),
    answer() hoặc solution() nếu chúng không có trong mẫu này.
11. Không import file local, font, ảnh hoặc package khác nếu đề không thực sự cần.
    Nếu cần hình, ưu tiên CeTZ và đặt trong tham số fig:; không dùng URL ảnh ngoài.
12. Mọi đáp án và lời giải phải được tự giải kiểm tra độc lập. Không tạo phương án
    trùng nhau, không có hai đáp án cùng đúng, không dùng dữ kiện thiếu.
13. Với câu VDC chưa chắc chắn, hãy ghi TODO-CAN-GV-KIEM-TRA trong comment thay vì
    bịa đáp án. Không đưa một câu chưa kiểm chứng vào đề chính thức.
14. Đề 12–4–6 phải có đúng 12 TN, 4 Đ/S, 6 TLN. Nội dung lời giải phải giải thích
    được vì sao đáp án đúng, không chỉ viết "chọn A/B/C/D".

KHUNG ĐẦU FILE PHẢI GIỮ:
#import "@preview/sang-math:1.0.5": *
#let profile = sys.inputs.at("profile", default: "dethi")
#let preset = exam-preset(theme: "{{theme}}", profile: profile)
#let (tn, ds, tln, tl) = exam-mode(..preset.question)
#show: sang-setup.with(math-color: black)
#show: exam-theme.with(
  theme: preset.theme,
  school: "{{trường}}",
  exam-title: "{{tên đề}}",
  subject: "TOÁN {{lớp}}",
  duration: "{{thời gian}}",
  code: "{{mã đề}}",
  ..preset.template,
)

KẾT QUẢ TRẢ VỀ:
- Trước tiên trả đúng một khối mã ```typ ... ``` chứa toàn bộ file chạy được.
- Sau khối mã, cho bảng kiểm ngắn: số câu từng loại, danh sách ID, phân bố mức độ,
  các câu cần giáo viên kiểm tra lại.
- Không rút gọn bằng dấu "...". Không bỏ lời giải. Không chỉ mô tả cách làm.
```

## 2. Prompt chuyển đề sưu tầm/OCR sang sang-math

```text
Hãy chuyển nội dung đề tôi gửi bên dưới thành một file Typst hoàn chỉnh dùng
"@preview/sang-math:1.0.5".

Nguyên tắc:
- Giữ nguyên ý nghĩa toán học, số liệu, thứ tự câu và đáp án gốc.
- Sửa lỗi OCR rõ ràng như mất số mũ, nhầm dấu trừ, căn, phân số; nhưng liệt kê mọi
  chỗ đã suy đoán sau mã nguồn để giáo viên duyệt.
- Không tự thêm đáp án nếu nguồn không cho đủ dữ kiện. Đánh dấu comment
  // TODO-CAN-GV-KIEM-TRA ngay trước câu chưa chắc chắn.
- Dùng #tn, #ds, #tln, #tl đúng chữ ký của sang-math. TN đúng có True(...), Đ/S
  chỉ bọc True(...) quanh mệnh đề đúng.
- Đặt ID ổn định TN01, DS01, TLN01, TL01 và tags theo chủ đề/mức độ.
- Chuyển LaTeX sang Typst: \frac -> frac, \sqrt -> sqrt, \infty -> oo,
  \mathbb{R} -> RR, hệ phương trình -> heva(...).
- Không dùng ảnh cho phần chữ và công thức. Nếu nguồn có hình chưa thể dựng lại,
  để một khung [CHÈN HÌNH CÂU ...] và ghi rõ trong báo cáo; không bịa hình.
- Tự giải lại từng câu để đối chiếu đáp án. Nếu đáp án nguồn có vẻ sai, giữ câu,
  ghi TODO và nêu mâu thuẫn trong báo cáo thay vì âm thầm đổi.
- Trả một khối ```typ``` đầy đủ, không dùng dấu ba chấm; sau đó trả báo cáo lỗi OCR,
  đáp án nghi vấn và câu cần giáo viên kiểm tra.

NỘI DUNG NGUỒN:
{{dán văn bản OCR, đề sưu tầm hoặc nội dung do app xuất ở đây}}
```

## 3. Prompt chỉ tạo câu phân hóa/chặn điểm 10

```text
Hãy viết {{số lượng}} câu Toán lớp {{lớp}} mức VDC thuộc chủ đề {{chủ đề}}, dùng
đúng sang-math:1.0.5. Mục tiêu là phân hóa nhóm 9–10 điểm nhưng dữ kiện phải gọn,
đáp án kiểm chứng được và không đánh đố bằng ngôn ngữ.

Mỗi câu phải có:
- ID VDC01, VDC02... và tags ("{{chủ đề}}", "VDC").
- lời giải từng bước, kiểm tra điều kiện và kết luận;
- nếu là TN: 4 phương án sinh từ các sai lầm điển hình, đúng đúng 1 phương án;
- một mục comment // KIEM-CHUNG cho biết cách AI đã kiểm tra đáp án;
- không tái sử dụng nguyên văn bài phổ biến; thay số/dữ kiện phải bảo đảm bài vẫn đúng.

Chỉ dùng các macro #tn/#ds/#tln/#tl, True, step, heva, hoac, dfrac, tfrac đã có
trong package. Trả một khối ```typ``` có thể dán trực tiếp vào vùng câu hỏi của đề.
Nếu không chắc đáp án, không được bịa; ghi TODO-CAN-GV-KIEM-TRA.
```

## 4. Prompt kiểm định một file AI đã tạo

```text
Hãy audit file Typst sang-math:1.0.5 dưới đây như một người phản biện đề thi.
Không viết lại ngay. Trước hết lập bảng lỗi theo 4 nhóm:
1) lỗi cú pháp/API Typst;
2) lỗi cấu trúc: số câu, ID trùng, thiếu True, sai chữ ký #tn/#ds/#tln/#tl;
3) lỗi toán học: dữ kiện, đáp án, phương án nhiễu, lời giải;
4) lỗi sư phạm: mức độ, diễn đạt, phân bố chủ đề.

Sau bảng lỗi, trả một khối ```typ``` là bản đã sửa hoàn chỉnh. Không đổi câu đúng
nếu không cần. Không bịa macro. Đảm bảo mỗi TN đúng đúng một phương án, mỗi Đ/S có
đúng bốn mệnh đề và mọi TLN có đáp án máy đọc được.

FILE CẦN KIỂM ĐỊNH:
{{dán file .typ ở đây}}
```

## 5. Prompt cho môn Hóa học và Vật lí

```text
Bạn là chuyên gia soạn đề {{Hóa học / Vật lí}} THPT Việt Nam. Hãy tạo file Typst hoàn chỉnh:
- Hóa học: dùng thêm #import "@preview/typsium:0.3.2": * và hàm #ce("...") cho công thức, phản ứng.
- Khung đề: dùng #import "@preview/sang-math:1.0.5": * với đầy đủ preset, tn, ds, tln.
- Trắc nghiệm: dùng #tn(..., ([A], True([B]), [C], [D]), id: "TN01", loigiai: [...]).
- Đúng/Sai: dùng #ds(..., (True([a]), [b], True([c]), [d]), id: "DS01", loigiai: [...]).
- Trả lời ngắn: dùng #tln(..., ans: "...", id: "TLN01", loigiai: [...]).
```

## 6. Checklist giáo viên phải tự duyệt

AI chỉ là trợ lý soạn thảo. Trước khi dùng chính thức, giáo viên vẫn phải:

- biên dịch file và đọc toàn bộ PDF;
- tự giải lại các câu VD/VDC;
- kiểm tra đúng số câu, mã đề, thời gian và phạm vi kiến thức;
- kiểm tra mỗi TN chỉ có một đáp án đúng và mỗi Đ/S đủ bốn mệnh đề;
- thử cả `profile=dethi` và `profile=loigiai`;
- xóa mọi `TODO-CAN-GV-KIEM-TRA` trước khi phát hành;
- kiểm tra nguồn/bản quyền của câu sưu tầm và không yêu cầu AI sao chép nguyên văn
  tài liệu có bản quyền mà mình không được phép sử dụng.
