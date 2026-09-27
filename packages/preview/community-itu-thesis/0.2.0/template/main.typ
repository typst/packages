// ITU Graduate Thesis Template — NUM (numeric citation) edition
// References are shown in IEEE/numeric style ([1], [2], …).
//
// Compile:  typst compile main.typ tez.pdf

#import "@preview/community-itu-thesis:0.2.0": thesis

#show: thesis.with(
  // ===== PERSONAL INFORMATION =====
  name: "Öğrenci Adı",
  surname: "SOYADI",
  student-id: "123456789",

  // ===== THESIS TITLES (up to 3 lines) =====
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

  // ===== ACADEMIC INFORMATION =====
  department-tr: "Bilgisayar Mühendisliği Anabilim Dalı",
  department-en: "Department of Computer Engineering",
  program-tr: "Bilgisayar Mühendisliği Programı",
  program-en: "Computer Engineering Programme",
  // "graduate" | "informatics" | "science" | "social-sciences" | "energy" | "eurasia"
  institute: "graduate",

  // ===== ADVISOR =====
  advisor-tr: "Prof. Dr. Adı SOYADI",
  advisor-univ-tr: "İstanbul Teknik Üniversitesi",
  advisor-en: "Prof. Dr. Name SURNAME",
  advisor-univ-en: "Istanbul Technical University",
  co-advisor-tr: "",
  co-advisor-univ-tr: "",
  co-advisor-en: "",
  co-advisor-univ-en: "",

  // ===== JURY MEMBERS =====
  jury: (
    (name: "Prof. Dr. Adı SOYADI", univ: "İstanbul Teknik Üniversitesi"),
    (name: "Prof. Dr. Adı SOYADI", univ: "Yıldız Teknik Üniversitesi"),
    (name: "Prof. Dr. Adı SOYADI", univ: "Boğaziçi Üniversitesi"),
  ),

  // ===== DATES =====
  cover-date-tr: "Aralık 2024",
  cover-date-en: "December 2024",
  submission-date-tr: "22 Eylül 2024",
  submission-date-en: "22 September 2024",
  defense-date-tr: "21 Aralık 2024",
  defense-date-en: "21 December 2024",

  // ===== SETTINGS =====
  lang: "tr",               // "tr" / "en"
  degree: "masters",        // "masters" / "phd"
  binding: "hardcover",     // "hardcover" / "softcover"

  // ===== FRONT/BACK MATTER =====
  dedication: "Aileme,",
  foreword: include "foreword.typ",
  abbreviations: include "abbreviations.typ",
  symbols: include "symbols.typ",
  abstract-tr: include "abstract-tr.typ",
  abstract-en: include "abstract-en.typ",
  bibliography: bibliography("refs.bib", style: "ieee", title: "KAYNAKLAR"),
  appendices: include "appendices.typ",
  cv: include "cv.typ",
)

// =====================================================================
//  CHAPTERS (body)
// =====================================================================

= GİRİŞ

Bu tez şablonu İstanbul Teknik Üniversitesi lisansüstü programları için
hazırlanmış olup, Typst belgeleme sisteminde yazılan tezlerin sunumuna
yönelik standartları belirtmektedir. Kaynak göstermek için @ornek2024
biçiminde atıf yapabilirsiniz.

== Tezin Amacı

Tez yazımında tutarlılığı sağlamak ve kurumsal standartlara uygun belgeler
oluşturmak amaçlanmıştır.

=== Alt başlık örneği

Üçüncü seviye başlıkları bu şekilde gösterilir. Formüller şöyle yazılır:

$ E = m c^2 $

== Literatür Taraması

Mevcut araştırmalar incelenerek özet halinde sunulmuştur.

= YÖNTEM

Bu bölümde araştırmanın yöntemi açıklanır. Şekil ve çizelge örnekleri aşağıdadır.

// To add a real image, create a "fig" folder and use:
//   #figure(image("fig/sekil.png", width: 80%), caption: [Açıklama])
// The placeholder below shows how a figure is laid out.
#figure(
  rect(width: 80%, height: 5cm, fill: luma(240), stroke: 0.5pt + luma(160))[
    #align(center + horizon)[
      #text(fill: luma(120))[Görsel buraya gelir \ (image("fig/...") ile ekleyin)]
    ]
  ],
  caption: [Örnek şekil açıklaması],
)

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [Başlık 1], [Başlık 2], [Başlık 3],
    [Satır 1-1], [Satır 1-2], [Satır 1-3],
    [Satır 2-1], [Satır 2-2], [Satır 2-3],
  ),
  caption: [Örnek çizelge],
)

= BULGULAR

Araştırmanın bulguları bu bölümde sunulmuştur.

= TARTIŞMA

Bulguların değerlendirilmesi ve literatürle karşılaştırılması yapılmıştır.

= SONUÇ

Sonuç bölümü özet niteliğinde olup, ulaşılan ana bulguları içermektedir.
