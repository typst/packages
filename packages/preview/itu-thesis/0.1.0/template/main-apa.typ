// İTÜ Lisansüstü Tez Şablonu — APA (yazar-yıl atıf) sürümü
// Kaynakça APA stilinde gösterilir. NUM sürümü için main.typ'a bakın.
//
// Derleme:  typst compile main-apa.typ tez.pdf

#import "@preview/itu-thesis:0.1.0": thesis

#show: thesis.with(
  ad: "Öğrenci Adı",
  soyad: "SOYADI",
  ogrenci-no: "123456789",

  tez-basligi: (
    "TEZ BAŞLIĞININ BİRİNCİ SATIRI",
    "GEREKLİYSE İKİNCİ SATIR",
    "GEREKLİYSE ÜÇÜNCÜ SATIR",
  ),
  thesis-title: (
    "FIRST LINE OF THESIS TITLE",
    "SECOND LINE IF NECESSARY",
    "THIRD LINE IF NECESSARY",
  ),

  anabilim-dali-tr: "Bilgisayar Mühendisliği Anabilim Dalı",
  anabilim-dali-en: "Department of Computer Engineering",
  program-tr: "Bilgisayar Mühendisliği Programı",
  program-en: "Computer Engineering Programme",
  enstitu: "lisansustu",

  danisman: "Prof. Dr. Adı SOYADI",
  danisman-univ: "İstanbul Teknik Üniversitesi",
  danisman-en: "Prof. Dr. Name SURNAME",
  danisman-univ-en: "Istanbul Technical University",

  juri: (
    (ad: "Prof. Dr. Adı SOYADI", univ: "İstanbul Teknik Üniversitesi"),
    (ad: "Prof. Dr. Adı SOYADI", univ: "Yıldız Teknik Üniversitesi"),
    (ad: "Prof. Dr. Adı SOYADI", univ: "Boğaziçi Üniversitesi"),
  ),

  savunma-tarihi-tr: "Aralık 2024",
  savunma-tarihi-en: "December 2024",
  teslim-tarihi-tr: "22 Eylül 2024",
  teslim-tarihi-en: "22 September 2024",
  savunma-tarihi-onay-tr: "21 Aralık 2024",
  savunma-tarihi-onay-en: "21 December 2024",

  dil: "tr",
  derece: "yukseklisans",
  cilt: "bez",

  ithaf: "Aileme,",
  onsoz: include "onsoz.typ",
  kisaltmalar: include "kisaltmalar.typ",
  semboller: include "semboller.typ",
  ozet: include "ozet.typ",
  summary: include "summary.typ",
  // APA stili için "apa" kullanılır:
  kaynakca: bibliography("refs.bib", style: "apa", title: "KAYNAKLAR"),
  ekler: include "ekler.typ",
  ozgecmis: include "ozgecmis.typ",
)

= Giriş

Bu örnek, APA (yazar-yıl) atıf stilini kullanır. Metin içinde @ornek2024
biçiminde atıf yaptığınızda kaynak APA formatında listelenir.

== Tezin Amacı

Tez yazımında tutarlılığı sağlamak amaçlanmıştır.

= Yöntem

// Gerçek görsel eklemek için bir "fig" klasörü oluşturup şöyle kullanın:
//   #figure(image("fig/sekil.png", width: 80%), caption: [Açıklama])
#figure(
  rect(width: 80%, height: 5cm, fill: luma(240), stroke: 0.5pt + luma(160))[
    #align(center + horizon)[
      #text(fill: luma(120))[Görsel buraya gelir \ (image("fig/...") ile ekleyin)]
    ]
  ],
  caption: [Örnek şekil açıklaması],
)

= Sonuç

Sonuç bölümü ulaşılan ana bulguları içerir.
