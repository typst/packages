// nibframe — four full pages and a framed certificate.
//   typst compile --root . examples/frames.typ                  (français)
//   typst compile --root . --input lang=en examples/frames.typ  (English)
#import "../lib.typ": *

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }
#set text(font: "Libertinus Serif", size: 11pt, fill: rgb("#2b2622"), lang: lang)
#set page(paper: "a4", fill: rgb("#fbf7ee"))

#let ink = rgb("#2b2622")

// ── four full pages
#let page-with(style, title, blurb, ..opts) = {
  set page(margin: frame-margin(style: style, gap: 8mm, ..opts), background: frame-background(style: style, ..opts))
  align(center + horizon)[
    #text(size: 30pt, weight: "bold", fill: ink)[#title]\
    #v(4pt)
    #text(size: 11pt, style: "italic")[#blurb]
    #v(14pt)
    #raw("#show: framed.with(style: \"" + style + "\")", lang: "typ")
  ]
}
#page-with("arabesque", "Arabesque", T("Une vigne calligraphique : tiges, vrilles, feuilles, fleurs aux coins.", "A calligraphic vine: stems, tendrils, leaves, corner flowers."), color: rgb("#1d5e5c"), accent: rgb("#b07a1c"))
#page-with("celtic", "Celtic", T("Une tresse à deux brins : le dessus/dessous est calculé par nibart.", "A two-strand plait: nibart computes the over/under."))
#page-with("banknote", "Banknote", T("Des rosettes de guilloché en filets fins, comme sur un billet.", "Guilloché rosettes in fine lines, as on a banknote."), color: rgb("#1d5e5c"), accent: rgb("#9a3324"))
#page-with("islamic", "Islamic", T("Des étoiles à huit pointes entrelacées (deux carrés tissés).", "Interlaced eight-pointed stars (two woven squares)."), color: rgb("#1c7a78"), accent: rgb("#b07a1c"))

// ── a certificate: the frame hugs its content (frame-box), any style works
#{
  set page(margin: 20mm)
  align(center + horizon)[
    #frame-box(width: 15cm, height: 10.5cm, style: "celtic", band: 10mm, inset: 4mm, gap: 10mm, color: rgb("#2f628c"), accent: rgb("#b07a1c"))[
      #text(size: 11pt, tracking: 2pt)[#upper(T("Certificat", "Certificate"))]\
      #v(3pt)
      #text(size: 24pt, weight: "bold")[#T("Maître des nœuds", "Master of Knots")]\
      #v(6pt)
      #text(size: 11pt, style: "italic")[#T("décerné pour un entrelacs parfaitement alterné", "awarded for a perfectly alternating interlace")]
    ]
    #v(8mm)
    #text(size: 9pt, fill: luma(110))[`frame-box(…, style: "celtic")` — #T("le cadre s'adapte à n'importe quelle boîte", "the frame fits any box")]
  ]
}
