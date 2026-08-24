// Reproduction of an Arabic mathematics lesson sheet.
// Typst 0.15.1 · CeTZ 0.5.2 · local checkout of fergousA/scrawl.
#import "@preview/cetz:0.5.2": canvas, draw
#import "../vendor/scrawl/lib.typ": scrawl, rounded-rect-pts, rect-pts, circle-pts

#let navy = rgb("#003B78")
#let navy-soft = rgb("#0B4A88")
#let red = rgb("#B52329")
#let graphite = rgb("#202020")
#let rule-grey = rgb("#83909B")
#let paper-blue = rgb("#F8FBFE")

// Virtual design grid. It is scaled as one unit by `worksheet`, so every
// coordinate, stroke, font size and inset remains proportional to the sheet.
#let sheet-w = 19.4
#let sheet-h = 27.3
#let sheet-base-w = sheet-w * 1cm
#let sheet-base-h = sheet-h * 1cm

#let normal-background() = canvas(length: 1cm, {
  let y(top, h: 0) = sheet-h - top - h
  let stroke(colour: navy, thickness: 1pt) = (
    paint: colour, thickness: thickness, join: "round", cap: "round",
  )
  let box(x, top, w, h, radius: 0.16, fill: none,
          paint: navy, weight: 1pt) = {
    draw.rect((x, y(top, h: h)), (x + w, y(top)), radius: radius,
      fill: fill, stroke: stroke(colour: paint, thickness: weight))
  }
  let line(x1, top1, x2, top2, paint: navy, weight: 0.75pt) = {
    draw.line((x1, sheet-h - top1), (x2, sheet-h - top2),
      stroke: stroke(colour: paint, thickness: weight))
  }
  let dots(x1, top, x2, paint: rule-grey, weight: 0.45pt) = {
    let step = 0.16
    let count = int((x2 - x1) / step)
    for i in range(count) {
      let a = x1 + i * step
      draw.line((a, sheet-h - top), (calc.min(a + 0.07, x2), sheet-h - top),
        stroke: stroke(colour: paint, thickness: weight))
    }
  }
  let vdots(x, top1, top2, paint: rule-grey, weight: 0.45pt) = {
    let step = 0.16
    let count = int((top2 - top1) / step)
    for i in range(count) {
      let a = top1 + i * step
      draw.line((x, sheet-h - a), (x, sheet-h - calc.min(a + 0.07, top2)),
        stroke: stroke(colour: paint, thickness: weight))
    }
  }
  let circle(x, top, radius, fill: none, paint: navy, weight: .8pt) = {
    draw.circle((x, sheet-h - top), radius: radius, fill: fill,
      stroke: stroke(colour: paint, thickness: weight))
  }

  // Identity band
  box(0, 0.08, sheet-w, 1.65, radius: 0.22, fill: paper-blue, weight: 1.15pt)
  line(5.8, 0.16, 5.8, 1.64, weight: 0.85pt)
  line(13.6, 0.16, 13.6, 1.64, weight: 0.85pt)
  // Three simple line icons: calendar, school and teacher.
  box(4.38, .74, .56, .62, radius: .04, fill: none, weight: .78pt)
  line(4.38, .92, 4.94, .92, weight: .68pt)
  line(4.52, .64, 4.52, .83, weight: .78pt)
  line(4.81, .64, 4.81, .83, weight: .78pt)
  circle(4.54, 1.06, .035, fill: navy, weight: 0pt)
  circle(4.78, 1.06, .035, fill: navy, weight: 0pt)
  circle(4.54, 1.22, .035, fill: navy, weight: 0pt)
  circle(4.78, 1.22, .035, fill: navy, weight: 0pt)
  line(12.06, 1.39, 12.06, 1.04, weight: .78pt)
  line(12.06, 1.04, 12.40, .74, weight: .78pt)
  line(12.40, .74, 12.76, 1.04, weight: .78pt)
  line(12.76, 1.04, 12.76, 1.39, weight: .78pt)
  line(12.06, 1.39, 12.76, 1.39, weight: .78pt)
  box(12.30, 1.18, .18, .21, radius: 0, fill: none, weight: .62pt)
  box(12.14, 1.12, .10, .10, radius: 0, fill: none, weight: .58pt)
  box(12.58, 1.12, .10, .10, radius: 0, fill: none, weight: .58pt)
  circle(18.40, .81, .17, fill: none, weight: .78pt)
  line(18.12, 1.49, 18.22, 1.16, weight: .78pt)
  line(18.22, 1.16, 18.40, 1.06, weight: .78pt)
  line(18.40, 1.06, 18.61, 1.16, weight: .78pt)
  line(18.61, 1.16, 18.73, 1.49, weight: .78pt)
  line(18.12, 1.49, 18.73, 1.49, weight: .78pt)
  line(18.40, 1.13, 18.40, 1.34, weight: .58pt)

  // Context box
  box(0.08, 2.15, sheet-w - .16, 2.65, radius: .18, fill: white, weight: 1.05pt)
  line(.18, 3.47, sheet-w - .18, 3.47, paint: rule-grey, weight: .42pt)
  dots(.18, 3.47, sheet-w - .18)
  vdots(9.7, 2.27, 4.68, paint: rule-grey, weight: .42pt)

  // Two curriculum bars
  box(.12, 5.1, sheet-w - .24, .92, radius: .14, fill: paper-blue, weight: .85pt)
  box(.12, 6.2, sheet-w - .24, .92, radius: .14, fill: paper-blue, weight: .85pt)
  box(15.02, 5.1, 4.26, .92, radius: .10, fill: navy, paint: navy, weight: .75pt)
  box(15.02, 6.2, 4.26, .92, radius: .10, fill: navy, paint: navy, weight: .75pt)

  // Lesson flow table
  box(.12, 7.48, sheet-w - .24, 16.12, radius: .22, fill: white, weight: 1.1pt)
  box(.14, 7.50, sheet-w - .28, 1.00, radius: .10, fill: navy, paint: navy, weight: .2pt)
  line(3.58, 7.52, 3.58, 23.56, weight: .8pt)
  line(15.55, 7.52, 15.55, 23.56, weight: .8pt)
  line(17.02, 7.52, 17.02, 23.56, weight: .8pt)
  dots(.22, 8.50, sheet-w - .22)
  dots(3.60, 11.50, sheet-w - .22)
  dots(3.60, 19.06, sheet-w - .22)
  dots(3.60, 21.42, sheet-w - .22)

  // Pedagogical notes box
  box(1.28, 24.04, 16.84, 2.23, radius: .25, fill: paper-blue, weight: 1.05pt)
  box(1.36, 24.12, 16.68, 2.07, radius: .18, fill: none, weight: .55pt)
})

#let rough-background(roughness: 1.25) = scrawl(
  width: sheet-w * 1cm,
  height: sheet-h * 1cm,
  hand: true,
  roughness: roughness,
  seed: 826,
  (shape, ..) => {
    let y(top, h: 0) = sheet-h - top - h
    let rr(x, top, w, h, radius: .16, fill: none,
           paint: navy, weight: 1pt, seed: 1) = {
      shape(rounded-rect-pts((x, y(top, h: h)), (x + w, y(top)), radius: radius),
        fill: fill, paint: paint, weight: weight, seed: seed)
    }
    let rule(x1, top1, x2, top2, paint: navy, weight: .75pt, seed: 1) = {
      shape(((x1, sheet-h - top1), (x2, sheet-h - top2)), closed: false,
        paint: paint, weight: weight, seed: seed)
    }
    let dots(x1, top, x2, paint: rule-grey, weight: .45pt, seed: 1) = {
      let step = .16
      let count = int((x2 - x1) / step)
      for i in range(count) {
        let a = x1 + i * step
        rule(a, top, calc.min(a + .07, x2), top,
          paint: paint, weight: weight, seed: seed + i * 5)
      }
    }
    let vdots(x, top1, top2, paint: rule-grey, weight: .45pt, seed: 1) = {
      let step = .16
      let count = int((top2 - top1) / step)
      for i in range(count) {
        let a = top1 + i * step
        rule(x, a, x, calc.min(a + .07, top2),
          paint: paint, weight: weight, seed: seed + i * 5)
      }
    }
    let circ(x, top, radius, fill: none, paint: navy, weight: .8pt, seed: 1) = {
      shape(circle-pts((x, sheet-h - top), radius), fill: fill,
        paint: paint, weight: weight, seed: seed)
    }

    rr(0, .08, sheet-w, 1.65, radius: .22, fill: paper-blue, weight: 1.15pt, seed: 10)
    rule(5.8, .16, 5.8, 1.64, weight: .85pt, seed: 20)
    rule(13.6, .16, 13.6, 1.64, weight: .85pt, seed: 21)
    // The same icons, but every contour is scrawled.
    rr(4.38, .74, .56, .62, radius: .04, fill: none, weight: .78pt, seed: 22)
    rule(4.38, .92, 4.94, .92, weight: .68pt, seed: 23)
    rule(4.52, .64, 4.52, .83, weight: .78pt, seed: 24)
    rule(4.81, .64, 4.81, .83, weight: .78pt, seed: 25)
    circ(4.54, 1.06, .035, fill: navy, weight: 0pt, seed: 26)
    circ(4.78, 1.06, .035, fill: navy, weight: 0pt, seed: 27)
    circ(4.54, 1.22, .035, fill: navy, weight: 0pt, seed: 28)
    circ(4.78, 1.22, .035, fill: navy, weight: 0pt, seed: 29)
    rule(12.06, 1.39, 12.06, 1.04, weight: .78pt, seed: 30)
    rule(12.06, 1.04, 12.40, .74, weight: .78pt, seed: 31)
    rule(12.40, .74, 12.76, 1.04, weight: .78pt, seed: 32)
    rule(12.76, 1.04, 12.76, 1.39, weight: .78pt, seed: 33)
    rule(12.06, 1.39, 12.76, 1.39, weight: .78pt, seed: 34)
    rr(12.30, 1.18, .18, .21, radius: 0, fill: none, weight: .62pt, seed: 35)
    rr(12.14, 1.12, .10, .10, radius: 0, fill: none, weight: .58pt, seed: 36)
    rr(12.58, 1.12, .10, .10, radius: 0, fill: none, weight: .58pt, seed: 37)
    circ(18.40, .81, .17, fill: none, weight: .78pt, seed: 38)
    rule(18.12, 1.49, 18.22, 1.16, weight: .78pt, seed: 39)
    rule(18.22, 1.16, 18.40, 1.06, weight: .78pt, seed: 40)
    rule(18.40, 1.06, 18.61, 1.16, weight: .78pt, seed: 41)
    rule(18.61, 1.16, 18.73, 1.49, weight: .78pt, seed: 42)
    rule(18.12, 1.49, 18.73, 1.49, weight: .78pt, seed: 43)
    rule(18.40, 1.13, 18.40, 1.34, weight: .58pt, seed: 44)

    rr(.08, 2.15, sheet-w - .16, 2.65, radius: .18, fill: white, weight: 1.05pt, seed: 50)
    dots(.18, 3.47, sheet-w - .18, seed: 51)
    vdots(9.7, 2.27, 4.68, seed: 52)

    rr(.12, 5.1, sheet-w - .24, .92, radius: .14, fill: paper-blue, weight: .85pt, seed: 50)
    rr(.12, 6.2, sheet-w - .24, .92, radius: .14, fill: paper-blue, weight: .85pt, seed: 51)
    rr(15.02, 5.1, 4.26, .92, radius: .10, fill: navy, paint: navy, weight: .75pt, seed: 52)
    rr(15.02, 6.2, 4.26, .92, radius: .10, fill: navy, paint: navy, weight: .75pt, seed: 53)

    rr(.12, 7.48, sheet-w - .24, 16.12, radius: .22, fill: white, weight: 1.1pt, seed: 60)
    rr(.14, 7.50, sheet-w - .28, 1.00, radius: .10, fill: navy, paint: navy, weight: .2pt, seed: 61)
    rule(3.58, 7.52, 3.58, 23.56, weight: .8pt, seed: 62)
    rule(15.55, 7.52, 15.55, 23.56, weight: .8pt, seed: 63)
    rule(17.02, 7.52, 17.02, 23.56, weight: .8pt, seed: 64)
    dots(.22, 8.50, sheet-w - .22, seed: 65)
    dots(3.60, 11.50, sheet-w - .22, seed: 66)
    dots(3.60, 19.06, sheet-w - .22, seed: 67)
    dots(3.60, 21.42, sheet-w - .22, seed: 68)

    rr(1.28, 24.04, 16.84, 2.23, radius: .25, fill: paper-blue, weight: 1.05pt, seed: 70)
    rr(1.36, 24.12, 16.68, 2.07, radius: .18, fill: none, weight: .55pt, seed: 71)
  },
)

#let ar(body, size: 10pt, weight: "regular", fill: graphite) = {
  text(font: "Amiri", lang: "ar", dir: rtl, size: size, weight: weight, fill: fill)[#body]
}

#let put(x, yy, width, body, height: auto, alignment: right) = {
  place(top + left, dx: x * 1cm, dy: yy * 1cm,
    block(width: width * 1cm, height: height,
      inset: 0pt, align(alignment, body)))
}

#let formula(body, size: 9.6pt, fill: graphite) = {
  text(font: "Libertinus Serif", lang: "en", dir: ltr, size: size, fill: fill)[#body]
}

#let worksheet-art(mode: "normal", roughness: 1.25) = {
  block(width: sheet-w * 1cm, height: sheet-h * 1cm, {
    // Structural layer: CeTZ in normal mode, all strokes from scrawl in rough mode.
    place(top + left, if mode == "rough" {
      rough-background(roughness: roughness)
    } else {
      normal-background()
    })

    // Identity band
    put(13.8, .25, 3.85, ar(size: 11.2pt, weight: "bold", fill: navy)[الأستاذ:])
    put(13.8, .82, 3.85, ar(size: 12pt)[صفية عمري])
    put(6.0, .25, 5.70, ar(size: 11.2pt, weight: "bold", fill: navy)[المؤسسة:])
    put(5.95, .82, 5.75, ar(size: 10.4pt)[متوسطة مناني محمد الساسي بالرقم])
    put(.38, .25, 3.40, ar(size: 11.2pt, weight: "bold", fill: navy)[السنة الدراسية:])
    put(.45, .84, 3.15, text(font: "Amiri", size: 12pt)[2025/2026], alignment: center)

    // Context and stated competency
    put(10.0, 2.46, 8.85, ar(size: 12.2pt)[
      #text(fill: red, weight: "bold")[الميدان:] أنشطة عددية
    ])
    put(.52, 2.46, 8.70, ar(size: 12.2pt)[
      #text(fill: red, weight: "bold")[المستوى:] الثالثة متوسط
    ])
    put(10.0, 3.70, 8.85, ar(size: 11.9pt)[
      #text(fill: red, weight: "bold")[المقطع الثالث:] القوى ذات أسس نسبية صحيحة
    ])
    put(.52, 3.70, 8.72, ar(size: 11.3pt)[
      #text(fill: red, weight: "bold")[الكفاءات الختامية:] يستعمل خواص القوى ذات أسس نسبية
    ])

    // Knowledge and skill bars
    put(15.15, 5.29, 3.95, ar(size: 12.1pt, weight: "bold", fill: white)[المورد المعرفي], alignment: center)
    put(.55, 5.31, 13.95, ar(size: 11.7pt)[قواعد الحساب على قوى ذات عدد نسبي], alignment: center)
    put(15.15, 6.39, 3.95, ar(size: 12.1pt, weight: "bold", fill: white)[مستوى من الكفاءة], alignment: center)
    put(.55, 6.41, 13.95, ar(size: 11.7pt)[يتعرف على قواعد الحساب في عدد نسبي], alignment: center)

    // Lesson-flow header
    put(17.08, 7.69, 2.10, ar(size: 12.8pt, weight: "bold", fill: white)[المراحل], alignment: center)
    put(15.61, 7.69, 1.35, ar(size: 12.5pt, weight: "bold", fill: white)[المدة], alignment: center)
    put(3.70, 7.69, 11.65, ar(size: 12.8pt, weight: "bold", fill: white)[سير الدرس], alignment: center)
    put(.32, 7.69, 2.95, ar(size: 12.3pt, weight: "bold", fill: white)[التقويم والإصلاح], alignment: center)

    // Warm-up row
    put(17.16, 9.52, 1.72, ar(size: 12.0pt, weight: "bold", fill: navy)[تهيئة], alignment: center)
    put(15.62, 9.53, 1.32, ar(size: 12.0pt, weight: "bold")[5د], alignment: center)
    put(3.86, 8.77, 11.20, ar(size: 11.0pt, weight: "bold", fill: red)[أستعد:])
    put(3.86, 9.25, 11.20, ar(size: 10.9pt)[أنجز العمليات التالية :])
    put(3.92, 9.76, 11.05, formula(size: 11.0pt)[
      $2 times 2 times 2 times 2 times 2 times 2 quad ; quad (-3) times (-3) times (-3)$
    ], alignment: center)
    put(3.86, 10.43, 11.20, ar(size: 10.5pt, weight: "bold", fill: red)[حل وضعية تعلمية 8], alignment: center)

    // Objectives-and-resources row
    put(17.17, 14.26, 1.70, ar(size: 11.8pt, weight: "bold", fill: navy)[أهداف وبناء الموارد], alignment: center)
    put(15.62, 14.72, 1.32, ar(size: 11.7pt, weight: "bold")[25د], alignment: center)
    put(.40, 13.00, 2.72, ar(size: 9.7pt)[التعرف و تفسير], alignment: center)
    put(.40, 13.35, 2.72, ar(size: 9.7pt)[معنى (قوة عدد], alignment: center)
    put(.40, 13.70, 2.72, ar(size: 9.7pt)[نسبي) وكذلك], alignment: center)
    put(.40, 14.05, 2.72, ar(size: 9.7pt)[الكتابة aⁿ، حيث], alignment: center)
    put(.40, 14.40, 2.72, ar(size: 9.7pt)[a عدد نسبي و n], alignment: center)
    put(.40, 14.75, 2.72, ar(size: 9.7pt)[عدد صحيح موجب], alignment: center)

    put(3.87, 11.73, 11.10, ar(size: 10.9pt)[(1) أقوم :])
    put(3.86, 12.16, 11.10, formula(size: 10.8pt)[
      $3^2 times 3^4 = 3 times 3 times 3 times 3 times 3 times 3 = 3^6$
    ], alignment: center)
    put(3.87, 12.70, 11.10, ar(size: 10.9pt)[(2) تحديد العبارات :])
    put(3.84, 13.15, 11.16, formula(size: 9.9pt)[
      $A = 5^2 times 5^6 = 5^8 quad ; quad B = 5 times 5^6 times 5 = 5^8$
    ], alignment: center)
    put(3.84, 13.61, 11.16, formula(size: 9.65pt)[
      $E = 5^8 quad ; quad D = 5^2 times 5^2 times 5^2 times 5^2 = 5^8 quad ; quad C = 5^4 times 5^2 = 5^6$
    ], alignment: center)
    put(3.87, 14.18, 11.10, ar(size: 10.9pt)[(3) أقوم :])
    put(3.77, 14.68, 11.30, formula(size: 8.65pt)[
      $3^(-2) times 3^7 = 1/3^2 times 3^7 = frac(3^7, 3^2) = frac(3 times 3 times 3 times 3 times 3 times 3 times 3, 3 times 3) = 3^5$
    ], alignment: center)
    put(3.77, 15.32, 11.30, formula(size: 8.45pt)[
      $4^2 times 4^(-5) = 4^2 times 1/4^5 = frac(4^2, 4^5) = frac(4 times 4, 4 times 4 times 4 times 4 times 4) = 1/4^3 = 4^(-3)$
    ], alignment: center)
    put(3.77, 15.95, 11.30, formula(size: 8.85pt)[
      $2^(-3) times 2^(-4) = 1/2^3 times 1/2^4 = 1/(2^3 times 2^4) = 1/2^7 = 2^(-7)$
    ], alignment: center)

    // Definition row
    put(15.62, 19.85, 1.32, ar(size: 11.7pt, weight: "bold")[15د], alignment: center)
    put(3.86, 19.29, 11.13, ar(size: 10.4pt)[
      (4) استنادا إلى نتائج الأمثلة السابقة، يدل أن :
    ])
    put(3.85, 19.75, 11.15, formula(size: 10.7pt)[$a^n times a^m = a^(n+m)$], alignment: center)
    put(3.86, 20.23, 11.13, ar(size: 10.9pt, weight: "bold", fill: red)[تعريف])
    put(3.82, 20.68, 11.20, ar(size: 10.1pt)[
      #formula[$a$] عدد نسبي ، #formula[$n$] و #formula[$m$] عددان صحيحان : #formula[$a^n times a^m = a^(n+m)$]
    ], alignment: center)

    // Reinvestment row
    put(17.15, 22.14, 1.76, ar(size: 11.5pt, weight: "bold", fill: navy)[إعادة الاستثمار], alignment: center)
    put(15.62, 22.14, 1.32, ar(size: 11.7pt, weight: "bold")[15د], alignment: center)
    put(3.86, 21.72, 11.12, ar(size: 10.9pt, weight: "bold", fill: red)[تمرين مقترح :])
    put(3.86, 22.15, 11.12, ar(size: 10.4pt)[
      أكتب على الشكل #formula[$a^n$] كل عدد من الأعداد الآتية
    ], alignment: center)
    put(3.74, 22.62, 11.38, formula(size: 10.05pt)[
      $3^5 times 5^4 quad ; quad 3^6 times 3^(-2) quad ; quad 7^4 times 7 quad ; quad 8 times 2^5 quad ; quad 3^5 times 9$
    ], alignment: center)

    // Pedagogical notes
    put(10.3, 24.23, 7.1, ar(size: 10.7pt, weight: "bold", fill: navy)[ملاحظات بيداغوجية :])
    put(1.62, 24.74, 15.75, ar(size: 9.65pt)[✓ يعتمد الأستاذ على الوضعيات التعليمية المقترحة لتنشيط التعلمات.], alignment: center)
    put(1.62, 25.19, 15.75, ar(size: 9.65pt)[✓ يستثمر أنشطة التمارين في بناء المفاهيم وتثبيتها.], alignment: center)
    put(1.62, 25.64, 15.75, ar(size: 9.65pt)[✓ يدعم التعلم باستعمال أمثلة متنوعة وتقويم مستمر.], alignment: center)
  })
}

// Responsive public entry point. The usable area is measured at layout time;
// its margins are percentages of the current page. The fixed design is then
// uniformly scaled to fit, preserving the worksheet's proportions on A4, A5,
// Letter or any custom paper size.
#let worksheet(mode: "normal", roughness: 1.25,
               outer-x: 3.8%, outer-y: 3.8%) = layout(area => {
  let margin-x = area.width * outer-x
  let margin-y = area.height * outer-y
  let usable-w = area.width - 2 * margin-x
  let usable-h = area.height - 2 * margin-y
  let factor = calc.min(usable-w / sheet-base-w, usable-h / sheet-base-h)
  let rendered-w = sheet-base-w * factor
  let rendered-h = sheet-base-h * factor

  block(width: area.width, height: area.height, {
    place(top + left,
      dx: (area.width - rendered-w) / 2,
      dy: (area.height - rendered-h) / 2,
      scale(x: factor * 100%, y: factor * 100%, origin: top + left,
        reflow: false,
        worksheet-art(mode: mode, roughness: roughness),
      ),
    )
  })
})

