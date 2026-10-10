# Thư viện phiếu OMR — sang-math 1.1.1

24 cấu hình phiếu A5 ngang/A4 dọc dùng cùng tọa độ ô tô và mốc căn chỉnh
với [Sang Math OMR](https://chamthi-conictypst.pages.dev/). Các hàm soạn đề,
sách, bảng biến thiên và hình học của 1.1.0 được giữ nguyên; bộ soạn đề được cải thiện khoảng cách công thức, QR mở rộng nhận dạng các mẫu mới.
Yêu cầu Typst 0.15.0 trở lên, giống bản 1.1.0.

## Ghép phiếu A5 vào đề A4

```typ
#import "@preview/sang-math:1.1.1": sang-omr-sheet
#set page(paper: "a4", margin: 10mm)
#let ma-de = "0101"
#state("sbd").update("1001")
#state("made").update(ma-de)
#sang-omr-sheet(profile: "new-12-2-4-a5")
```

Phiếu này ghi và tô `1001` ở **bốn cột đầu SBD**; **hai cột cuối để trống**
cho học sinh tự ghi và tô, ví dụ `23` để thành SBD đầy đủ `100123`.
SBD có sáu cột; nhập đủ sáu số thì tô đủ, nhập ngắn thì giữ nguyên tiền tố.
Không đệm số `0` hay chuyển tiền tố sang cột khác. Mã đề `0101` tô đủ bốn
cột; riêng mã đề ngắn được đệm `0` ở đầu cho đủ bốn số. Ô đáp án để trống.
Không có state hoặc state là `none`/`""` thì ô định danh để trống.
Mã chứa chữ, số âm hoặc quá dài bị báo lỗi, không bị cắt mất chữ số.
State được đọc tại vị trí từng phiếu; có thể đổi SBD/mã đề trước mỗi phiếu
khi sinh nhiều đề trong cùng tài liệu.

Phiếu A5 tự căn giữa theo trang A4, kể cả khi đề dùng lề 10, 15 hoặc 20 mm
hay lề trái/phải khác nhau. Nội dung phiếu giữ nguyên **190 × 140 mm**;
vùng một cột của đề phải rộng ít nhất **170 mm** và đủ chỗ theo chiều dọc.
Hàm không thay khổ trang, font hoặc định dạng đoạn của đề. Ưu tiên in 100%
và giữ đủ 12 mốc cùng mốc nhận chiều. Nếu máy in cần thêm lề, có thể chọn
in đồng đều 96%, căn giữa A4: mốc ngoài cùng cách mép khoảng 9 mm.
Bản thu nhỏ này đã qua kiểm tra chấm ảnh mô phỏng; nên thử một phiếu
in–scan thật trước khi in cả lớp. Không co giãn riêng một chiều hoặc đưa
vào cột hẹp; trang hẹp hơn 210 mm hay vùng chứa hẹp hơn 170 mm sẽ báo lỗi.

Để dùng cách `#include`, tải [12-2-4.typ](../examples/omr/12-2-4.typ)
đặt cạnh file đề rồi dùng:

```typ
#set page(paper: "a4", margin: 10mm)
#let ma-de = "0101"
#state("sbd").update("1001")
#state("made").update(ma-de)
#include "12-2-4.typ"
```

[Ví dụ đề A4 đầy đủ](../examples/omr/new-state-example.typ).
Mẫu cũ [12-4-6ngang.typ](../examples/omr/12-4-6ngang.typ) và
[ví dụ state cũ](../examples/omr/state-example.typ) giữ cú pháp include của
1.1.0, đồng thời sửa SBD ngắn thành tiền tố ở các cột đầu như trên.
Đường dẫn include là file đã tải vào dự án; `#import` package không tự tạo
file `12-2-4.typ` cạnh đề.

## In phiếu riêng và ghi đè state

```typ
#import "@preview/sang-math:1.1.1": sang-omr-sheet
#set page(paper: "a5", flipped: true, margin: 10mm, numbering: none)
#sang-omr-sheet(
  profile: "new-12-2-4-a5",
  embed: false,
  sbd: "1001",
  ma-de: "0101",
)
```

Với A4 chọn ID kết thúc `-a4`, đặt trang A4 dọc, lề 10 mm và `embed: false`.
`sbd: auto`/`ma-de: auto` (mặc định) đọc state; tham số cụ thể ghi đè state
cho riêng phiếu đó. `sbd: ""` hoặc `ma-de: none` chủ động để trống.
Mặc định `embed: auto` dành khoảng trống chứa mốc cho A5, còn A4 là phiếu riêng.

## Chấm và QR đáp án

Khi chấm trên web, chọn đúng tên cấu trúc và khổ giấy tương ứng. SBD/mã đề
được đọc từ ô tô trên bản in, không dựa vào tên file. TLN có tối đa **bốn
ký tự, tính cả dấu âm và dấu phẩy**: `-1,5`, `0,05`, `1234`, `0` hợp lệ;
`-12,5` không vừa. Thang điểm do giáo viên cài đặt trong web và được dùng
khi tính lại điểm; thư viện in không khóa thang điểm.

`sang-omr-profile("new-12-2-4-a5")` trả cấu hình TN/ĐS/TLN và khổ giấy.
Sau khi soạn đủ các câu bằng `tn`, `ds`, `tln`, dùng
`#sang-omr-qr(ma-de: ma-de, profile: "new-12-2-4-a5")` để tạo QR đáp án
đúng cấu hình. Đặt QR ở vùng trống ngoài phiếu, tránh ô tô và mốc.
Không truyền profile thì QR giữ hành vi cũ của 1.1.0.

`sang-omr-catalog` chứa 24 mô tả. [profiles.json](profiles.json) kèm tọa độ
ô/mốc, cấu trúc TLN, mẫu gốc và hash nguồn cho phần mềm nhận dạng; đây là
schema đo từ bản in, không phải một bộ chấm ảnh độc lập. Metadata vô hình
trong PDF ghi ID mẫu/SBD/mã đề để công cụ tích hợp sử dụng; bản scan vẫn
được kiểm tra bằng mốc và vị trí ô tô.

## Danh sách cấu hình

File ví dụ dưới đây dùng `#import "@preview/sang-math:1.1.1"` và in phiếu
riêng. Các mẫu A5 đều có thể ghép vào đề bằng `sang-omr-sheet` như trên.

| ID mẫu | TN | Đ/S | TLN | Khổ giấy | File ví dụ |
|---|---:|---:|---:|---|---|
| `new-12-2-4-a5` | 12 | 2 | 4 | A5 | [Typst](../examples/omr/new-12-2-4-a5.typ) |
| `new-12-2-4-a4` | 12 | 2 | 4 | A4 | [Typst](../examples/omr/new-12-2-4-a4.typ) |
| `new-0-10-0-a5` | 0 | 10 | 0 | A5 | [Typst](../examples/omr/new-0-10-0-a5.typ) |
| `new-0-10-0-a4` | 0 | 10 | 0 | A4 | [Typst](../examples/omr/new-0-10-0-a4.typ) |
| `new-0-4-6-a5` | 0 | 4 | 6 | A5 | [Typst](../examples/omr/new-0-4-6-a5.typ) |
| `new-0-4-6-a4` | 0 | 4 | 6 | A4 | [Typst](../examples/omr/new-0-4-6-a4.typ) |
| `new-12-4-0-a5` | 12 | 4 | 0 | A5 | [Typst](../examples/omr/new-12-4-0-a5.typ) |
| `new-12-4-0-a4` | 12 | 4 | 0 | A4 | [Typst](../examples/omr/new-12-4-0-a4.typ) |
| `new-12-0-4-a5` | 12 | 0 | 4 | A5 | [Typst](../examples/omr/new-12-0-4-a5.typ) |
| `new-12-0-4-a4` | 12 | 0 | 4 | A4 | [Typst](../examples/omr/new-12-0-4-a4.typ) |
| `new-0-5-5-a5` | 0 | 5 | 5 | A5 | [Typst](../examples/omr/new-0-5-5-a5.typ) |
| `new-0-5-5-a4` | 0 | 5 | 5 | A4 | [Typst](../examples/omr/new-0-5-5-a4.typ) |
| `new-0-6-4-a5` | 0 | 6 | 4 | A5 | [Typst](../examples/omr/new-0-6-4-a5.typ) |
| `new-0-6-4-a4` | 0 | 6 | 4 | A4 | [Typst](../examples/omr/new-0-6-4-a4.typ) |
| `new-8-3-3-a5` | 8 | 3 | 3 | A5 | [Typst](../examples/omr/new-8-3-3-a5.typ) |
| `new-8-3-3-a4` | 8 | 3 | 3 | A4 | [Typst](../examples/omr/new-8-3-3-a4.typ) |
| `new-8-4-2-a5` | 8 | 4 | 2 | A5 | [Typst](../examples/omr/new-8-4-2-a5.typ) |
| `new-8-4-2-a4` | 8 | 4 | 2 | A4 | [Typst](../examples/omr/new-8-4-2-a4.typ) |
| `new-0-0-10-a5` | 0 | 0 | 10 | A5 | [Typst](../examples/omr/new-0-0-10-a5.typ) |
| `new-0-0-10-a4` | 0 | 0 | 10 | A4 | [Typst](../examples/omr/new-0-0-10-a4.typ) |
| `new-40-0-0-a5` | 40 | 0 | 0 | A5 | [Typst](../examples/omr/new-40-0-0-a5.typ) |
| `new-40-0-0-a4` | 40 | 0 | 0 | A4 | [Typst](../examples/omr/new-40-0-0-a4.typ) |
| `new-18-4-6-a4` | 18 | 4 | 6 | A4 | [Typst](../examples/omr/new-18-4-6-a4.typ) |
| `new-24-4-0-a4` | 24 | 4 | 0 | A4 | [Typst](../examples/omr/new-24-4-0-a4.typ) |
