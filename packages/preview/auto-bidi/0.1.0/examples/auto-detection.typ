#import "../lib.typ": *
#show: auto-dir

= auto-bidi examples

== Hebrew / עברית

זוהי פסקה בעברית. הכיוון מזוהה אוטומטית.

This paragraph is in English. Direction is automatically detected.

== Arabic / العربية

هذه فقرة باللغة العربية. يتم اكتشاف الاتجاه تلقائياً.

== Farsi / فارسی

این یک پاراگراف فارسی است. جهت به صورت خودکار تشخیص داده می‌شود.

== Mixed content

עברית with some English — still RTL because Hebrew comes first.

English with some עברית — stays LTR because English comes first.

العربية مع بعض English — RTL لأن العربية تأتي أولاً.

== Math stays LTR

הפונקציה $f(x) = x^2 + 1$ היא פרבולה.

المعادلة $E = m c^2$ لا تؤثر على اتجاه الفقرة.

تابع $f(x) = x^2$ یک سهمی است.

== Lists

Hebrew list:
- פריט ראשון
- פריט שני
- פריט שלישי

Arabic list:
- العنصر الأول
- العنصر الثاني
- العنصر الثالث

Farsi list:
- مورد اول
- مورد دوم
- مورد سوم

== Direction hints

Use `#r` or `#l` to nudge detection:

#r English text that should be RTL.

#l טקסט עברי שצריך להיות LTR.
