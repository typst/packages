// Idraaak Step Cards. SPDX-License-Identifier: MIT-0

// A screenshot is content (for example image("capture.png")), not a path.
// This keeps user images relative to the user's own document.
#let step-cards(
  title: "Step-by-step notes",
  subtitle: none,
  steps: (),
  lang: "en",
  paper: "a4",
  per-page: 2,
  accent: rgb("#12675F"),
  font: "DejaVu Sans",
  body,
) = {
  assert(type(title) == str, message: "title must be a string")
  assert(lang in ("en", "ar"), message: "lang must be en or ar")
  assert(per-page in (1, 2), message: "per-page must be 1 or 2")
  assert(type(steps) == array, message: "steps must be an array")
  assert(steps.len() > 0, message: "provide at least one step")
  for step in steps {
    assert(type(step) == dictionary, message: "each step must be a dictionary")
    assert("title" in step, message: "each step needs a title")
    assert("instruction" in step, message: "each step needs an instruction")
  }

  let arabic = lang == "ar"
  let labels = if arabic {
    (step: "الخطوة", check: "تحقق من النتيجة", continued: "تابع الخطوات", page: "صفحة")
  } else {
    (step: "STEP", check: "CHECK", continued: "CONTINUED", page: "Page")
  }
  let align-start = if arabic { right } else { left }
  let digits = n => {
    let raw = str(n)
    if arabic {
      let west = "0123456789"
      let east = "٠١٢٣٤٥٦٧٨٩"
      raw.clusters().map(c => {
        let pos = west.position(c)
        if pos == none { c } else { east.clusters().at(pos) }
      }).join()
    } else { raw }
  }

  set document(title: str(title), author: "")
  set text(font: font, lang: lang, dir: if arabic { rtl } else { ltr }, size: 10pt, fill: rgb("#20323E"))
  set par(justify: false, leading: 0.65em)
  set page(
    paper,
    margin: (x: 18mm, top: 16mm, bottom: 18mm),
    footer: context align(center, text(size: 8pt, fill: rgb("#61717B"))[
      #labels.page #digits(counter(page).get().first())
    ]),
  )
  set align(align-start)

  let page-count = calc.ceil(steps.len() / per-page)
  for page-index in range(page-count) {
    if page-index > 0 { pagebreak() }
    text(size: if page-index == 0 { 23pt } else { 16pt }, weight: "bold", fill: accent)[#title]
    v(3mm)
    if page-index == 0 and subtitle != none {
      text(size: 9pt, fill: rgb("#61717B"))[#subtitle]
      v(3mm)
    } else if page-index > 0 {
      text(size: 8pt, fill: rgb("#61717B"))[#labels.continued]
      v(3mm)
    }
    block(width: 100%, height: 0.8pt, fill: accent)
    v(5mm)
    let start = page-index * per-page
    let stop = calc.min(start + per-page, steps.len())
    for index in range(start, stop) {
      let step = steps.at(index)
      block(
        width: 100%,
        breakable: false,
        inset: 4mm,
        radius: 2mm,
        stroke: 0.6pt + rgb("#D3E1E4"),
        fill: rgb("#F7FAFB"),
      )[
        #text(size: 8pt, weight: "bold", fill: accent)[#labels.step #digits(index + 1)]
        #v(1.5mm)
        #text(size: 13pt, weight: "bold")[#step.title]
        #v(2mm)
        #step.instruction
        #if step.at("screenshot", default: none) != none {
          v(3mm)
          block(width: 100%, inset: 2mm, radius: 1mm, fill: white)[
            #set text(dir: ltr)
            #align(center, box(width: 100%, height: if per-page == 2 { 40mm } else { 105mm })[
                #step.screenshot
              ])
          ]
        }
        #if step.at("check", default: none) != none {
          v(3mm)
          text(size: 8pt, weight: "bold", fill: accent)[#labels.check]
          v(1mm)
          text(size: 9pt)[#step.check]
        }
      ]
      if index + 1 < stop { v(4mm) }
    }
  }
  if body != [] {
    v(5mm)
    body
  }
}
