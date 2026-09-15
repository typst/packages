// faboxyst — volutebox / volute-pages / parchemin : le cadre volute de
// la papeterie (image 6) en boîte puis en cadre de page, et la lettre
// ancienne roulée rose.
#import "@preview/faboxyst:0.2.0": *

#set page(width: 17cm, height: 24cm, margin: 1.2cm, fill: white)
#show: faboxyst.with(theme: (lang: "fr", dir: ltr))
#set text(size: 10pt)

#volutebox(fill: volute-colours.paper)[
  #set text(size: 9.5pt)
  #align(center)[
    #text(size: 1.35em, weight: "bold")[Avis aux familles]
    #v(0.3cm)

    La réunion annuelle aura lieu le samedi 12 octobre à 9 h 30, dans la
    grande salle des fêtes. Un moment convivial clôturera la matinée.

    #v(0.2cm)
    #text(style: "italic")[Le bureau de l'association.]
  ]
]

#pagebreak()

#volute-pages[
  #set text(size: 9.5pt)
  = Le cadre en page entière

  Le même cadre volute borde ici chaque page : doubles filets
  chanfreinés, volutes d'encre aux quatre angles et tirets d'écho le
  long des bords.

  #lorem(80)
]

#set page(margin: 1.4cm, background: none, fill: white)
#pagebreak()

#set text(lang: "ar", dir: rtl, size: 9pt)
#parchemin(
  title: [وضعية إدماجية: الآفات الاجتماعية وظاهرة العنف في الوسط المدرسي],
  sign: [سامية عمران],
)[
  يعيش مجتمعنا اليوم على وقع تحوّلات متسارعة أفرزت جملة من الآفات
  الاجتماعية الخطيرة، كان من أبرزها ظاهرة العنف التي نشّت طريقها إلى
  الوسط المدرسي لتهدّد أمنه واستقراره. فلم تعد المدرسة ذلك الفضاء الآمن
  الذي يتلقّى فيه التلميذ العلم والمعرفة في ظلّ الاحترام المتبادل.

  وتتشعّب أسباب هذه الظاهرة وتتداخل جذورها؛ فمنها ما يعود إلى البيئة
  الأسرية المفكّكة التي يفتقر فيها الطفل إلى الحنان والتوجيه السليم،
  ومنها ما يرتبط بالتأثير السلبي لوسائل التواصل الاجتماعي والألعاب
  الإلكترونية التي تجّد العنف وتقدّمه نموذجًا للقوة.

  وأمام هذا الواقع المقلق، لا يسع المجتمع بكل مكوّناته إلّا أن يتكاتف في
  مواجهة هذه الآفة الخطيرة. فالأسرة مدعوّة إلى تعزيز قيم الحوار
  والاحترام داخل البيت، والدولة مطالبة بتفعيل القوانين الرادعة وتوفير
  برامج الدعم النفسي والاجتماعي للتلاميذ في خطر.
]
