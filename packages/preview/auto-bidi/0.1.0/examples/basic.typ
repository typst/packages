#import "../lib.typ": *
#show: auto-dir
#title[Auto-Bidi]
= auto-bidi: basic example

== Automatic detection

This paragraph is English and stays LTR.

אם כותבים פסקה בעברית, היא נהיית RTL אוטומטית.

يمكن الكتابة بالعربية وستكون من اليمين لليسار تلقائياً.

also, $f(x) = x^2$ גם אם מתחילים באנגלית, אבל הרוב עברית -- זה עדיין עובד.

== Math and code are always LTR

הפונקציה $f(x) = x^2 + 1$ היא פרבולה. המשוואה לא משפיעה על כיוון הפסקה.

المعادلة $E = m c^2$ لا تؤثر على اتجاه الفقرة.

== Lists stay unified

- פריט ראשון
- second item — still RTL, the list is Hebrew overall
- פריט שלישי

== Forcing language on a block

#rl[This is tagged as Hebrew even though it is written in English.]

#lr[גם עברית כאן תופיע שמאל-לימין.]

#force-lang("fa")[این متن فارسی است و با قواعد زبان فارسی نمایش داده می‌شود.]

== Section-level forcing

#sethebrew
כל הפרקים הבאים הם עברית.

= גם כותרות הן RTL

#setauto
Back to automatic detection.

This paragraph is English again.
