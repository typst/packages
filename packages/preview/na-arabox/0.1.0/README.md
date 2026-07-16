# na-arabox

`na-arabox` هي حزمة لبرنامج Typst توفر صناديق نصية (Boxes) مخصصة للنصوص العربية، مصممة لتناسب المجلات التعليمية والمواد الأكاديمية.

`na-arabox` is a Typst package that provides custom text boxes tailored for Arabic content, designed for educational magazines and academic materials.

## الاستخدام / Usage

يمكنك استخدام هذه الحزمة عبر استيرادها من Typst Universe:
You can use this package by importing it from the Typst Universe:

```typst
#import "@preview/na-arabox:0.1.0": na-arabox

#na-arabox(title: "عنوان الصندوق", color: blue)[
  محتوى الصندوق هنا باللغة العربية.
]
