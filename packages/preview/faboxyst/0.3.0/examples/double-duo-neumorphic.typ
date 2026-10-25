// Double Duo Neumorphic — soft twin-shadow cards, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: rgb("#F0F1F3"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.notebook)

#let sample = (
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero, sed cursus ante dapibus diam. Sed nisi.], icon: image("assets/duo-target.svg", width: 1.34cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero, sed cursus ante dapibus diam. Sed nisi.], icon: image("assets/duo-bulb.svg", width: 1.34cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero, sed cursus ante dapibus diam. Sed nisi.], icon: image("assets/cube-stopwatch-white.svg", width: 1.34cm), raised: true, icon-fill: rgb("#4DBDE8"), title-colour: rgb("#35A9D7")),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero, sed cursus ante dapibus diam. Sed nisi.], icon: image("assets/duo-eye.svg", width: 1.34cm)),
)

= Double duo neumorphic — LTR
#v(0.42cm)
#double-duo-neumorphic(steps: sample, width: 19.6cm, columns: 2, direction: ltr)

#v(0.68cm)
= Same cards — RTL
#v(0.42cm)
#double-duo-neumorphic(
  steps: (
    (title: [الرؤية], body: [تأمّل الهدف بوضوح، واجمع الملاحظات، ثم حدّد السؤال الذي سيوجّه خطوات الفريق.], icon: image("assets/duo-target.svg", width: 1.34cm)),
    (title: [الإلهام], body: [امنح الأفكار الجديدة مساحة للنمو، واستكشف الاحتمالات قبل اختيار الحل المناسب.], icon: image("assets/duo-bulb.svg", width: 1.34cm)),
    (title: [الوقت], body: [نظّم وقتك وحدّد الأولويات، ووازن بين سرعة الإنجاز وجودة النتيجة.], icon: image("assets/cube-stopwatch-white.svg", width: 1.34cm), raised: true, icon-fill: rgb("#4DBDE8"), title-colour: rgb("#35A9D7")),
    (title: [الملاحظة], body: [راقب التفاصيل بعناية، وقارن ما تراه بالهدف، ثم قرّر ما يستحق الاهتمام.], icon: image("assets/duo-eye.svg", width: 1.34cm)),
  ),
  width: 19.6cm,
  columns: 2,
  direction: rtl,
)
