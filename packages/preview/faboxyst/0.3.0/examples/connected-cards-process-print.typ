// Connected Cards Process — monochrome print gallery, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.print)

#let sample = (
  (title: [Idea], body: [Notice an opportunity and frame the question clearly. Gather useful observations, identify what is missing, and agree on the problem the team wants to solve.], icon: image("assets/connected-idea.svg", width: 1.12cm), print-icon: image("assets/connected-idea.svg", width: 1.12cm)),
  (title: [Plan], body: [Set a clear goal, compare possible directions, choose a practical route, and map the next steps with the people and resources needed to carry it through.], icon: image("assets/connected-target.svg", width: 1.12cm), print-icon: image("assets/connected-target.svg", width: 1.12cm)),
  (title: [Create], body: [Build a small solution, try it with real users, collect feedback, and refine the idea before investing more time in a larger release.], icon: image("assets/connected-rocket.svg", width: 1.12cm), print-icon: image("assets/connected-rocket.svg", width: 1.12cm)),
  (title: [Measure], body: [Review the results against the original goal, share what changed, record the lessons, and decide whether to improve, repeat, or move on.], icon: image("assets/connected-chart.svg", width: 1.12cm), print-icon: image("assets/connected-chart.svg", width: 1.12cm)),
)

= Connected cards process — print, LTR
#v(0.35cm)
#connected-cards-process(steps: sample, width: 22cm, columns: 4, direction: ltr)

#v(0.62cm)
= Same sequence — print, RTL
#v(0.35cm)
#connected-cards-process(
  steps: (
    (title: [الفكرة], body: [لاحظ الفرصة وصُغ السؤال بوضوح. اجمع الملاحظات وحدّد المعلومات الناقصة واتفق مع الفريق على المشكلة التي تريدون حلّها.], icon: image("assets/connected-idea.svg", width: 1.12cm), print-icon: image("assets/connected-idea.svg", width: 1.12cm)),
    (title: [التخطيط], body: [حدّد هدفاً واضحاً وقارن بين المسارات الممكنة واختر خطة عملية، ثم رتّب الخطوات والموارد اللازمة لتنفيذها.], icon: image("assets/connected-target.svg", width: 1.12cm), print-icon: image("assets/connected-target.svg", width: 1.12cm)),
    (title: [الإنجاز], body: [أنشئ حلاً أولياً واختبره مع المستخدمين واجمع ملاحظاتهم وحسّن الفكرة قبل الانتقال إلى إصدار أكبر.], icon: image("assets/connected-rocket.svg", width: 1.12cm), print-icon: image("assets/connected-rocket.svg", width: 1.12cm)),
    (title: [القياس], body: [قارن النتائج بالهدف الأصلي وشارك ما تغيّر وسجّل الدروس المستفادة، ثم قرّر إن كنت ستحسّن العمل أو تكرّره أو تنتقل إلى خطوة جديدة.], icon: image("assets/connected-chart.svg", width: 1.12cm), print-icon: image("assets/connected-chart.svg", width: 1.12cm)),
  ),
  width: 22cm,
  columns: 4,
  direction: rtl,
)
