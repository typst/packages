// ITU Graduate Thesis Template — APA (author-year citation) edition
// References are shown in APA style. See main.typ for the NUM edition.
//
// Compile:  typst compile main-apa.typ tez.pdf

#import "@preview/community-itu-thesis:0.2.0": thesis

#show: thesis.with(
  name: "Öğrenci Adı",
  surname: "SOYADI",
  student-id: "123456789",

  title-tr: (
    "TEZ BAŞLIĞININ BİRİNCİ SATIRI",
    "GEREKLİYSE İKİNCİ SATIR",
    "GEREKLİYSE ÜÇÜNCÜ SATIR",
  ),
  title-en: (
    "FIRST LINE OF THESIS TITLE",
    "SECOND LINE IF NECESSARY",
    "THIRD LINE IF NECESSARY",
  ),

  department-tr: "Bilgisayar Mühendisliği Anabilim Dalı",
  department-en: "Department of Computer Engineering",
  program-tr: "Bilgisayar Mühendisliği Programı",
  program-en: "Computer Engineering Programme",
  institute: "graduate",

  advisor-tr: "Prof. Dr. Adı SOYADI",
  advisor-univ-tr: "İstanbul Teknik Üniversitesi",
  advisor-en: "Prof. Dr. Name SURNAME",
  advisor-univ-en: "Istanbul Technical University",

  jury: (
    (name: "Prof. Dr. Adı SOYADI", univ: "İstanbul Teknik Üniversitesi"),
    (name: "Prof. Dr. Adı SOYADI", univ: "Yıldız Teknik Üniversitesi"),
    (name: "Prof. Dr. Adı SOYADI", univ: "Boğaziçi Üniversitesi"),
  ),

  cover-date-tr: "Aralık 2024",
  cover-date-en: "December 2024",
  submission-date-tr: "22 Eylül 2024",
  submission-date-en: "22 September 2024",
  defense-date-tr: "21 Aralık 2024",
  defense-date-en: "21 December 2024",

  lang: "tr",
  degree: "masters",
  binding: "hardcover",

  dedication: "Aileme,",
  foreword: include "foreword.typ",
  abbreviations: include "abbreviations.typ",
  symbols: include "symbols.typ",
  abstract-tr: include "abstract-tr.typ",
  abstract-en: include "abstract-en.typ",
  // Use "apa" for APA style:
  bibliography: bibliography("refs.bib", style: "apa", title: "KAYNAKLAR"),
  appendices: include "appendices.typ",
  cv: include "cv.typ",
)

= GİRİŞ

Bu örnek, APA (yazar-yıl) atıf stilini kullanır. Metin içinde @ornek2024
biçiminde atıf yaptığınızda kaynak APA formatında listelenir.

== Tezin Amacı

Tez yazımında tutarlılığı sağlamak amaçlanmıştır.

= YÖNTEM

// To add a real image, create a "fig" folder and use:
//   #figure(image("fig/sekil.png", width: 80%), caption: [Açıklama])
#figure(
  rect(width: 80%, height: 5cm, fill: luma(240), stroke: 0.5pt + luma(160))[
    #align(center + horizon)[
      #text(fill: luma(120))[Görsel buraya gelir \ (image("fig/...") ile ekleyin)]
    ]
  ],
  caption: [Örnek şekil açıklaması],
)

= SONUÇ

Sonuç bölümü ulaşılan ana bulguları içerir.
