#import "@preview/dorost:0.2.0": document, cover-page, page-chrome, section-title, badge, note, quote-frame, prompt-example, checklist, labeled-field, data-table, code-inline, resource-link, ltr, rtl, persian-digits, slides, slide-cover, slide-columns, slide-content, slide-statement

// One editable source, two outputs: --input showcase=document|slides.
#let mode = sys.inputs.at("showcase", default: "document")
#assert(mode in ("document", "slides"), message: "showcase must be document or slides")
#show: document.with(lang: "en", direction: "ltr", text: (size: 11pt))

#let identity = [Mina Farzan · Studio Cedar]
#let edition = [#ltr[2026-10-11] / #ltr[#persian-digits("2026-10-11")]]

#if mode == "document" [
  #v(22mm)
  #cover-page(
    [One foundation.\ Many voices.],
    subtitle: [English, Persian, and everything between.\ #rtl[یک پایه، چند زبان]],
    author: identity,
    date: edition,
    logo: badge[CEDAR / FIELD NOTES],
    details: [
      #v(12mm)
      #note(title: [A shared language for ideas])[
        Compose a cover, a clear body, and a presentation from the same small set of tools.
        #v(5mm)
        #rtl[از جلد تا متن و اسلاید، ساختار و هویت را خودتان انتخاب کنید.]
      ]
      #v(12mm)
      #grid(columns: (1fr, 1fr, 1fr), gutter: 12pt,
        labeled-field([Edition], [01 / #persian-digits(1)], row-gutter: 5pt),
        labeled-field([Prepared by], identity, row-gutter: 5pt),
        labeled-field([Format], [Bilingual study], row-gutter: 5pt),
      )
    ],
  )
  #pagebreak()
  #page-chrome(header: [STUDIO CEDAR / #rtl[یادداشت‌های طراحی]], footer: [Dorost · Composition study])[
    #section-title[Small pieces, clear structure]
    A fictional studio explores how ideas travel across languages. Shared typography keeps the pages coherent; native Typst keeps the composition editable.
    #grid(columns: (1fr, 1fr), gutter: 16pt,
      [
        #note(title: [01 / Observe], tone: "accent")[Start with readable text and a visible hierarchy.]
        #quote-frame(attribution: identity)[Good structure gives every voice room.]
      ],
      [
        #align(right)[
          #set text(lang: "fa", dir: std.rtl)
          #note(title: [۰۲ / ترکیب])[
            فارسی و English در کنار هم، با کنترل مستقل زبان و جهت.
          ]
          شناسه: #code-inline("API.get(2)")\
          تاریخ: #ltr[#persian-digits("2026-10-11")]
        ]
      ],
    )
    #v(8pt)
    #section-title[Caller-owned data]
    #data-table(3, (
      ([Element], [English], [#rtl[فارسی]]),
      ([Cover], [Identity + context], [#rtl[هویت و زمینه]]),
      ([Body], [Notes + tables], [#rtl[یادداشت و جدول]]),
      ([Slides], [One idea per page], [#rtl[هر صفحه، یک ایده]]),
    ))
    #prompt-example([Try a local direction change])[
      #rtl[در متن فارسی، شناسهٔ #ltr[CEDAR-42] و پیوند #ltr[example.com/a?b=2] را خوانا نگه دارید.]
    ]
    #checklist(([Choose your language and direction.], [Keep digit conversion explicit: #persian-digits(42).]))
    #resource-link("https://typst.app", [Continue composing with Typst])
  ]
] else [
  #slides(footer: [Studio Cedar / #rtl[استودیو سدر]])[
    #slide-cover([Ideas across languages], subtitle: [#rtl[ایده‌ها در چند زبان]], author: identity, date: edition)
    #slide-columns(
      [
        #note(title: [One clear idea], tone: "accent")[Use the same components on the page and on the screen.]
        #v(6mm)
        Identifiers keep their shape: #code-inline("CEDAR-42").
      ],
      [
        #align(right)[
          #set text(lang: "fa", dir: std.rtl)
          #note(title: [یک ایدهٔ روشن])[
            جهت متن را محلی تنظیم کنید.\
            شناسه: #ltr[API.get(2)]\
            شماره: #persian-digits(42)
          ]
        ]
      ],
      title: [A shared composition / #rtl[ترکیب مشترک]],
    )
    #align(right)[
          #set text(lang: "fa", dir: std.rtl)
      #slide-content(title: [از متن تا ارائه])[
        #note(title: [ساختار روشن])[
          هر اسلاید یک پیام دارد؛ زبان، جهت و ارقام را مستقل انتخاب کنید.
        ]
        #v(7mm)
        #ltr[English stays readable beside Persian.]
      ]
    ]
    #slide-statement([Give every voice room.\ #rtl[به هر صدا فضا بدهید.]], attribution: identity)
  ]
]
