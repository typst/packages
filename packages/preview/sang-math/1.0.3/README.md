# sang-math

A comprehensive Typst package for typesetting Vietnamese High School Mathematics documents, exams, and presentations.

## Features

- **Exam Creation**: Macros for generating multiple-choice questions (MCQ), True/False questions, and answer keys.
- **Math Symbols**: Shortcuts for common math symbols used in Vietnam.
- **Variation Tables**: Draw beautiful sign tables and variation tables for functions.
- **Geometry**: Built-in wrappers for CeTZ to easily draw 2D and 3D geometric figures.
- **Presentations (Beamer)**: Create slides for teaching math with step-by-step reveals.
- **Books & Workbooks**: Macros for typesetting books and workbooks with beautiful theorem and definition boxes.
- **Duplex Draft Layout**: `layout-draft` creates a 70/30 exam page whose scratch margin alternates right/left on odd/even pages for double-sided printing.

## Usage

```typst
#import "@preview/sang-math:1.0.3": *

// Your awesome math document
```

```typst
#import "@preview/sang-math:1.0.3": layout-draft
#show: layout-draft.with(nháp-pct: 30%)

// Odd pages: scratch area on the right.
// Even pages: scratch area on the left.
```

## Tác giả (Author)
- **Tên:** Nguyễn Văn Sang
- **Công việc:** Giáo viên Toán tại Trường THPT Nguyễn Hữu Cảnh - TP. HCM
- **Email:** nguyensangnhc@gmail.com
- **Facebook:** [Nguyễn Văn Sang](https://www.facebook.com/nguyenvan.sang.92798072/)

## Ủng hộ dự án (Donate)
Nếu bạn thấy thư viện này hữu ích cho công việc giảng dạy và soạn thảo tài liệu Toán học, bạn có thể ủng hộ tác giả qua:

- **Ngân hàng VPBank:** Số tài khoản `10389821115` - Chủ tài khoản: NGUYEN VAN SANG
<img src="https://img.vietqr.io/image/vpbank-10389821115-compact.jpg" width="300" alt="VPBank QR Code">

*(Để hiển thị thêm mã QR của Momo, bạn có thể tải ảnh Momo lên mạng (ví dụ tải lên chính Github hoặc Facebook) rồi chèn link ảnh vào đây nhé!)*
