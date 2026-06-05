// İTÜ Lisansüstü Tez Şablonu — NUM (sayılı atıf) sürümü
// Kaynakça IEEE/sayılı stilde ([1], [2], …) gösterilir.
//
// Derleme:  typst compile main.typ tez.pdf

#import "@preview/itu-thesis:0.1.0": thesis

#show: thesis.with(
  // ===== KİŞİSEL BİLGİLER =====
  ad: "Öğrenci Adı",
  soyad: "SOYADI",
  ogrenci-no: "123456789",
  unvan: "",

  // ===== TEZ BAŞLIKLARI (en çok 3 satır) =====
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

  // ===== AKADEMİK BİLGİLER =====
  anabilim-dali-tr: "Bilgisayar Mühendisliği Anabilim Dalı",
  anabilim-dali-en: "Department of Computer Engineering",
  program-tr: "Bilgisayar Mühendisliği Programı",
  program-en: "Computer Engineering Programme",
  // "lisansustu" | "bilisim" | "fenbilimleri" | "sosyalbilimler" | "enerji" | "avrasya"
  enstitu: "lisansustu",

  // ===== DANIŞMAN =====
  danisman: "Prof. Dr. Adı SOYADI",
  danisman-univ: "İstanbul Teknik Üniversitesi",
  danisman-en: "Prof. Dr. Name SURNAME",
  danisman-univ-en: "Istanbul Technical University",
  es-danisman: "",
  es-danisman-univ: "",
  es-danisman-en: "",
  es-danisman-univ-en: "",

  // ===== JÜRİ ÜYELERİ =====
  juri: (
    (ad: "Prof. Dr. Adı SOYADI", univ: "İstanbul Teknik Üniversitesi"),
    (ad: "Prof. Dr. Adı SOYADI", univ: "Yıldız Teknik Üniversitesi"),
    (ad: "Prof. Dr. Adı SOYADI", univ: "Boğaziçi Üniversitesi"),
  ),

  // ===== TARİHLER =====
  savunma-tarihi-tr: "Aralık 2024",
  savunma-tarihi-en: "December 2024",
  teslim-tarihi-tr: "22 Eylül 2024",
  teslim-tarihi-en: "22 September 2024",
  savunma-tarihi-onay-tr: "21 Aralık 2024",
  savunma-tarihi-onay-en: "21 December 2024",

  // ===== AYARLAR =====
  dil: "tr",                 // "tr" / "en"
  derece: "yukseklisans",    // "yukseklisans" / "doktora"
  cilt: "bez",               // "bez" / "karton"

  // ===== ÖN/ARKA MATERYAL =====
  ithaf: "Aileme,",
  onsoz: include "onsoz.typ",
  kisaltmalar: include "kisaltmalar.typ",
  semboller: include "semboller.typ",
  ozet: include "ozet.typ",
  summary: include "summary.typ",
  kaynakca: bibliography("refs.bib", style: "ieee", title: "KAYNAKLAR"),
  ekler: include "ekler.typ",
  ozgecmis: include "ozgecmis.typ",
)

// =====================================================================
//  BÖLÜMLER (gövde)
// =====================================================================

= Giriş

Bu tez şablonu İstanbul Teknik Üniversitesi lisansüstü programları için
hazırlanmış olup, Typst belgeleme sisteminde yazılan tezlerin sunumuna
yönelik standartları belirtmektedir. Kaynak göstermek için @ornek2024
biçiminde atıf yapabilirsiniz.

== Tezin Amacı

Tez yazımında tutarlılığı sağlamak ve kurumsal standartlara uygun belgeler
oluşturmak amaçlanmıştır.

=== Alt Başlık Örneği

Üçüncü seviye başlıkları bu şekilde gösterilir. Formüller şöyle yazılır:

$ E = m c^2 $

== Literatür Taraması

Mevcut araştırmalar incelenerek özet halinde sunulmuştur.

= Yöntem

Bu bölümde araştırmanın yöntemi açıklanır. Şekil ve çizelge örnekleri aşağıdadır.

#figure(
  image("fig/example.png", width: 80%),
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

= Bulgular

Araştırmanın bulguları bu bölümde sunulmuştur.

= Tartışma

Bulguların değerlendirilmesi ve literatürle karşılaştırılması yapılmıştır.

= Sonuç

Sonuç bölümü özet niteliğinde olup, ulaşılan ana bulguları içermektedir.
