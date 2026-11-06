#import "@preview/dorost:0.2.0": document, ltr, persian-digits

#show: document.with(lang: "fa", direction: "rtl")
#set footnote(numbering: "۱")

#set page(
  header: context [درست #h(1fr) #counter(page).display("1")],
  footer: context [#align(center)[نمونهٔ صفحه‌آرایی بومی Typst]],
)

= سند فارسی

این نمونه فقط قابلیت‌های پایهٔ نوشتار فارسی را نمایش می‌دهد: ی فارسی، ک فارسی و نیم‌فاصله در واژهٔ می‌روم.

تبدیل رقم‌ها اختیاری است: #ltr[#persian-digits("2026-10-11")].

شماره‌گذاری چندسطحی بومی Typst: #ltr[#numbering("۱.۱", 1, 2, 3)].

این جمله یک پانوشت دارد#footnote[نمونهٔ پانوشت فارسی.].

== ساختار در اختیار نویسنده است

فهرست‌ها و جدول‌ها از امکانات بومی Typst استفاده می‌کنند:

- زبان و جهت نوشتار مستقل هستند.
- فهرست، جدول و سربرگ را نویسنده می‌سازد.

#table(
  columns: 2,
  [ویژگی], [مقدار],
  [زبان], [فارسی],
  [جهت], [راست‌به‌چپ],
)
