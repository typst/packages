#import "@preview/faboxyst:0.3.0": *
#set page(width: 20cm, height: auto, margin: 1cm)
#show: faboxyst.with(theme: themes.notebook)
#let L = [Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh.]
#let AR = [نص عربي تجريبي لاختبار اتجاه الكتابة من اليمين إلى اليسار.]
#let S3 = ((title: [Analysis], body: L, icon: [★]), (title: [Plan], body: L, icon: [✦]), (title: [Build], body: L, icon: [●]))
#let A3 = ((title: [التحليل], body: AR, icon: [★]), (title: [التخطيط], body: AR, icon: [✦]), (title: [البناء], body: AR, icon: [●]))
#parchemin(title: [عنوان الرسالة], sign: [الموقّع])[السلام عليكم ورحمة الله وبركاته، هذه رسالة تجريبية طويلة قليلاً لنرى كيف يتم محاذاة النص إلى اليمين داخل الرق المزخرف.]
#v(3mm)
#parchemin(title: [Letter], direction: rtl)[Forced right-to-left.]
#v(3mm)
#parchemin(title: [Letter])[Normal English text stays on the left.]
#v(3mm)
#lettre(title: [رسالة])[#set text(lang: "ar")
نص بالعربية]
