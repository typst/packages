#import "../lib.typ": *

= Detection modes

== "first" mode (default)

#show: auto-dir

The first recognised script character sets the direction — like Apple Notes and WhatsApp.

=== Examples

A הרבה עברית כתובה פה — LTR (starts with "A")

הרבה עברית with some English — RTL (starts with "ה")

A الكثير من العربية هنا — LTR (starts with "A")

العربية مع some English — RTL (starts with "ع")

== "auto" mode (majority)

#show: auto-dir.with(detect-by: "auto")

The majority of characters determines direction.

=== Examples

A הרבה עברית כתובה פה — RTL (more Hebrew than Latin)

הרבה עברית with a bit of English — RTL (Hebrew majority)

Mostly English עם קצת עברית — LTR (Latin majority)

A الكثير من النص العربي هنا — RTL (more Arabic than Latin)

== Forcing language

Force a specific language on a block:

#force-lang("he")[English text tagged as Hebrew.]

#force-lang("ar")[English text tagged as Arabic.]

#force-lang("fa")[English text tagged as Farsi.]

== Section-level forcing

#setarabic
هذا القسم كله باللغة العربية.

= عنوان عربي

#setfarsi
این بخش فارسی است.

= عنوان فارسی

#sethebrew
חלק זה בעברית.

= כותרת עברית

#setauto
Back to automatic detection.
