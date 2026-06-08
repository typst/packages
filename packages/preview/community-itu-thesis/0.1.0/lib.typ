// İTÜ Lisansüstü Tez Şablonu — Typst sürümü
// İstanbul Teknik Üniversitesi · Lisansüstü Eğitim Enstitüsü
//
// Bu şablon, resmi LaTeX şablonu (itutez.cls v1.7.1, Ocak 2025) temel alınarak
// Typst için yeniden yazılmıştır. Aşağıdaki resmi öğeleri üretir:
//   · Dış kapak + Türkçe iç kapak + İngilizce iç kapak
//   · Jüri onay/imza sayfası (KABUL VE ONAY)
//   · İthaf, Önsöz, İçindekiler, Kısaltmalar, Semboller
//   · Çizelge Listesi, Şekil Listesi
//   · Özet / Summary
//   · Ön materyalde roma (i, ii, …), gövdede arabik (1, 2, …) sayfa numarası
//   · Numaralı bölümler ("BÖLÜM 1. ...") ve numarasız ön/arka materyal başlıkları
//   · Ekler (+ EKLER kapağı), Kaynaklar, Özgeçmiş

#let thesis(
  // ===== KİŞİSEL BİLGİLER =====
  ad: "",
  soyad: "",
  ogrenci-no: "",
  unvan: "",

  // ===== TEZ BAŞLIKLARI (en çok 3 satır) =====
  tez-basligi: ("", "", ""),      // Türkçe (kapak + Türkçe iç kapak)
  thesis-title: ("", "", ""),     // İngilizce (İngilizce iç kapak + onay)

  // ===== AKADEMİK BİLGİLER =====
  anabilim-dali-tr: "",
  anabilim-dali-en: "",
  program-tr: "",
  program-en: "",
  // enstitu: "lisansustu" | "bilisim" | "fenbilimleri" | "sosyalbilimler" | "enerji" | "avrasya"
  enstitu: "lisansustu",

  // ===== DANIŞMAN =====
  danisman: "",
  danisman-univ: "",
  danisman-en: "",
  danisman-univ-en: "",
  es-danisman: "",
  es-danisman-univ: "",
  es-danisman-en: "",
  es-danisman-univ-en: "",

  // ===== JÜRİ ÜYELERİ =====
  // (ad: "...", univ: "...") sözlüklerinden oluşan dizi
  juri: (),

  // ===== TARİHLER =====
  savunma-tarihi-tr: "",   // Büyük kapaktaki tarih (ör. "Aralık 2024")
  savunma-tarihi-en: "",
  teslim-tarihi-tr: "",    // Onay sayfası teslim tarihi (ör. "22 Eylül 2024")
  teslim-tarihi-en: "",
  savunma-tarihi-onay-tr: "",  // Onay sayfası savunma tarihi (ör. "21 Aralık 2024")
  savunma-tarihi-onay-en: "",

  // ===== AYARLAR =====
  dil: "tr",                // "tr" | "turkce"  /  "en" | "ingilizce"
  derece: "yukseklisans",   // "yukseklisans" | "doktora"
  cilt: "bez",              // "bez" (ciltli) | "karton"

  // ===== ÖN/ARKA MATERYAL (içerik blokları) =====
  ithaf: none,              // İthaf metni (ör. "Aileme,")
  onsoz: none,              // Önsöz içeriği
  kisaltmalar: none,        // Kısaltmalar tablosu/içeriği
  semboller: none,          // Semboller tablosu/içeriği
  ozet: none,               // Türkçe özet içeriği (anahtar kelimeler dahil)
  summary: none,            // İngilizce summary içeriği (keywords dahil)
  sekil-listesi: true,      // Şekil Listesi üretilsin mi?
  cizelge-listesi: true,    // Çizelge Listesi üretilsin mi?
  kaynakca: none,           // bibliography(...) çağrısı buraya geçirilir
  ekler: none,              // Ekler içeriği
  ozgecmis: none,           // Özgeçmiş içeriği

  body,
) = {
  // ---- Dil ----
  let ingilizce = dil == "en" or dil == "ingilizce" or dil == "english"
  let lang-code = if ingilizce { "en" } else { "tr" }

  // ---- Enstitü adları ----
  let enstitu-tr = (
    "lisansustu": "Lisansüstü Eğitim Enstitüsü",
    "bilisim": "Bilişim Enstitüsü",
    "fenbilimleri": "Fen Bilimleri Enstitüsü",
    "sosyalbilimler": "Sosyal Bilimler Enstitüsü",
    "enerji": "Enerji Enstitüsü",
    "avrasya": "Avrasya Yer Bilimleri Enstitüsü",
  ).at(enstitu, default: "Lisansüstü Eğitim Enstitüsü")
  let enstitu-en = (
    "lisansustu": "Graduate School",
    "bilisim": "Informatics Institute",
    "fenbilimleri": "Graduate School of Science Engineering and Technology",
    "sosyalbilimler": "Graduate School of Social Sciences",
    "enerji": "Energy Institute",
    "avrasya": "Eurasia Institute of Earth Sciences",
  ).at(enstitu, default: "Graduate School")

  // ---- Büyük harf çevrimi ----
  // upper() Unicode varsayılanını kullanır ve Türkçe "i → İ" eşlemesini yapmaz
  // (yanlış "İÇINDEKILER" üretir). Genel çözüm: tek sorunlu harf olan "i"yi
  // upper()'dan önce "İ" ile değiştirmek; diğer harfleri (ç, ş, ğ, ö, ü, ı)
  // upper() zaten doğru çevirir. İngilizce metinlerde düz upper() kullanılır.
  let tr-upper(s) = upper(str(s).replace("i", "İ"))
  let en-upper(s) = upper(str(s))

  let enstitu-ust-tr = tr-upper("İstanbul Teknik Üniversitesi ★ " + enstitu-tr)
  let enstitu-ust-en = en-upper("İstanbul Technical University ★ " + enstitu-en)

  // ---- Tez seviyesi ----
  let seviye-tr = if derece == "doktora" { "DOKTORA TEZİ" } else { "YÜKSEK LİSANS TEZİ" }
  let seviye-en = if derece == "doktora" { "Ph.D. THESIS" } else { "M.Sc. THESIS" }

  let isim-soyisim = (ad + " " + soyad).trim()

  // ---- Başlık satırlarını birleştiren yardımcı (cas: çevrim fonksiyonu) ----
  let basliklar(satirlar, cas) = {
    let temiz = satirlar.filter(s => s != none and str(s).trim() != "")
    text(size: 14pt, weight: "bold")[
      #temiz.map(s => cas(s)).join(linebreak())
    ]
  }

  // =====================================================================
  //  GENEL AYARLAR
  // =====================================================================
  set document(title: tez-basligi.at(0, default: ""), author: isim-soyisim)
  set text(
    font: ("Times New Roman", "Libertinus Serif"),
    size: 12pt,
    lang: lang-code,
    hyphenate: false,   // LaTeX şablonundaki gibi (hyphenpenalty=10000) tireleme kapalı
  )
  set par(leading: 1.45em, spacing: 0.6em, justify: true)
  show math.equation: set block(spacing: 0.65em)

  // ---- Başlık stilleri ----
  // LaTeX itutez.cls'e göre (\@makechapterhead): gövde bölümü "1. BAŞLIK" biçiminde
  // (önünde "BÖLÜM" YOK), 12pt kalın, sola dayalı. Ön/arka materyal başlıkları numarasız.
  show heading: it => {
    let numarali = it.numbering != none
    if it.level == 1 {
      pagebreak(weak: true)
      v(18.5mm)
      if numarali {
        text(weight: "bold", size: 12pt)[#counter(heading).display(). #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
      v(12pt)
    } else if it.level == 2 {
      v(12pt)
      if numarali {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
      v(8pt)
    } else if it.level == 3 {
      v(8pt)
      if numarali {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
      v(4pt)
    } else {
      v(6pt)
      if numarali {
        text(weight: "bold", size: 12pt)[#counter(heading).display() #it.body]
      } else {
        text(weight: "bold", size: 12pt)[#it.body]
      }
    }
  }

  // ---- Şekil ve çizelge ----
  let sekil-sozu = if ingilizce { "Figure" } else { "Şekil" }
  let cizelge-sozu = if ingilizce { "Table" } else { "Çizelge" }
  show figure.where(kind: image): set figure(supplement: sekil-sozu)
  show figure.where(kind: table): set figure(supplement: cizelge-sozu)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => {
    text(weight: "bold")[#it.supplement #it.counter.display(): #it.body]
  }

  // =====================================================================
  //  KAPAKLAR  (numarasız sayfalar, dar kenar boşluğu)
  // =====================================================================
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: none,
  )

  // ---- Tek bir kapak iskeleti ----
  let kapak(enstitu-ust, baslik-blok, seviye, kimlik, anabilim, program, danisman-satir, tarih) = {
    set par(justify: false, leading: 0.65em)
    align(center)[
      #v(2mm)
      #underline(text(weight: "bold")[#enstitu-ust])
      #v(50mm)
      #baslik-blok
      #v(50mm)
      #text(weight: "bold")[#seviye]
      #v(8mm)
      #text(weight: "bold")[#kimlik]
      #v(22mm)
      #text(weight: "bold")[#anabilim]
      #v(2mm)
      #text(weight: "bold")[#program]
      #if danisman-satir != none {
        v(12mm)
        danisman-satir
      } else {
        v(12mm)
      }
      #v(18mm)
      #text(weight: "bold")[#tarih]
    ]
  }

  // (1) DIŞ KAPAK
  kapak(
    if ingilizce { enstitu-ust-en } else { enstitu-ust-tr },
    if ingilizce { basliklar(thesis-title, en-upper) } else { basliklar(tez-basligi, tr-upper) },
    if ingilizce { seviye-en } else { seviye-tr },
    isim-soyisim,
    if ingilizce { anabilim-dali-en } else { anabilim-dali-tr },
    if ingilizce { program-en } else { program-tr },
    // Bez ciltte dış kapakta danışman yok; kartonda var
    if cilt == "karton" {
      let etiket = if ingilizce { "Thesis Advisor" } else { "Tez Danışmanı" }
      text(weight: "bold")[#etiket: #(if ingilizce { danisman-en } else { danisman })]
    } else { none },
    if ingilizce { savunma-tarihi-en } else { savunma-tarihi-tr },
  )
  pagebreak(weak: true)

  // (2) TÜRKÇE İÇ KAPAK
  let danisman-blok-tr = {
    text(weight: "bold")[Tez Danışmanı: #danisman]
    if es-danisman.trim() != "" {
      linebreak()
      text(weight: "bold")[Eş Danışman: #es-danisman]
    }
  }
  kapak(
    enstitu-ust-tr, basliklar(tez-basligi, tr-upper), seviye-tr,
    [#isim-soyisim (#ogrenci-no)],
    anabilim-dali-tr, program-tr, danisman-blok-tr, savunma-tarihi-tr,
  )
  pagebreak(weak: true)

  // (3) İNGİLİZCE İÇ KAPAK
  let danisman-blok-en = {
    text(weight: "bold")[Thesis Advisor: #danisman-en]
    if es-danisman-en.trim() != "" {
      linebreak()
      text(weight: "bold")[Co-Advisor: #es-danisman-en]
    }
  }
  kapak(
    enstitu-ust-en, basliklar(thesis-title, en-upper), seviye-en,
    [#isim-soyisim (#ogrenci-no)],
    anabilim-dali-en, program-en, danisman-blok-en, savunma-tarihi-en,
  )

  // =====================================================================
  //  JÜRİ ONAY / İMZA SAYFASI  (KABUL VE ONAY)
  // =====================================================================
  {
    set par(justify: true, leading: 1.1em)
    pagebreak(weak: true)
    v(18mm)

    // Açıklama paragrafı
    let derece-sozu-tr = if derece == "doktora" { "Doktora" } else { "Yüksek Lisans" }
    let derece-sozu-en = if derece == "doktora" { "Ph.D." } else { "M.Sc." }
    let baslik-tirnak-tr = tez-basligi.filter(s => str(s).trim() != "").map(s => tr-upper(s)).join(" ")
    let baslik-tirnak-en = thesis-title.filter(s => str(s).trim() != "").map(s => en-upper(s)).join(" ")

    if ingilizce {
      [#isim-soyisim, a #derece-sozu-en student of ITU #enstitu-en student ID #ogrenci-no, successfully defended the thesis entitled "#baslik-tirnak-en", which he/she prepared after fulfilling the requirements specified in the associated legislations, before the jury whose signatures are below.]
    } else {
      [İTÜ #enstitu-tr'nün #ogrenci-no numaralı #derece-sozu-tr Öğrencisi #isim-soyisim, ilgili yönetmeliklerin belirlediği gerekli tüm şartları yerine getirdikten sonra hazırladığı "#baslik-tirnak-tr" başlıklı tezini aşağıda imzaları olan jüri önünde başarı ile sunmuştur.]
    }

    v(14mm)

    // İmza satırları
    let dots = "."*30
    let satir(rol, isim, univ) = (
      text(weight: "bold")[#rol], [#text(weight: "bold")[#isim] \ #univ], align(right)[#dots],
    )
    let bos = ([], [], [])

    let danisman-rol = if ingilizce { "Thesis Advisor :" } else { "Tez Danışmanı :" }
    let es-rol = if ingilizce { "Co-advisor :" } else { "Eş Danışman :" }
    let juri-rol = if ingilizce { "Jury Members :" } else { "Jüri Üyeleri :" }

    let rows = ()
    rows += satir(danisman-rol,
      if ingilizce { danisman-en } else { danisman },
      if ingilizce { danisman-univ-en } else { danisman-univ })
    if (if ingilizce { es-danisman-en } else { es-danisman }).trim() != "" {
      rows += bos
      rows += satir(es-rol,
        if ingilizce { es-danisman-en } else { es-danisman },
        if ingilizce { es-danisman-univ-en } else { es-danisman-univ })
    }
    // Jüri üyeleri
    for (i, uye) in juri.enumerate() {
      rows += bos
      rows += satir(if i == 0 { juri-rol } else { "" }, uye.ad, uye.at("univ", default: ""))
    }

    grid(
      columns: (34mm, 1fr, auto),
      row-gutter: 10pt,
      column-gutter: 4pt,
      align: (left + top, left + top, right + bottom),
      ..rows,
    )

    v(8mm)
    let teslim-etiket = if ingilizce { "Date of Submission :" } else { "Teslim Tarihi :" }
    let savunma-etiket = if ingilizce { "Date of Defense :" } else { "Savunma Tarihi :" }
    grid(
      columns: (auto, auto),
      row-gutter: 6pt,
      column-gutter: 8pt,
      text(weight: "bold")[#teslim-etiket],
      text(weight: "bold")[#(if ingilizce { teslim-tarihi-en } else { teslim-tarihi-tr })],
      text(weight: "bold")[#savunma-etiket],
      text(weight: "bold")[#(if ingilizce { savunma-tarihi-onay-en } else { savunma-tarihi-onay-tr })],
    )
  }

  // =====================================================================
  //  ÖN MATERYAL  (roma rakamı, normal kenar boşluğu)
  // =====================================================================
  set page(
    margin: (left: 4cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: "i",
    number-align: center + bottom,
  )
  counter(page).update(1)

  // Ön/arka materyal başlıklarını numarasız yap
  set heading(numbering: none)
  // LaTeX'te ön materyal tek satır aralığı (\singlespacing); gövde 1.5 (\oneandonehalf)
  set par(leading: 0.65em)

  // "Sayfa" / "Page" sütun başlığı (cls: \cftaftertoctitle ... \bf\underline{Sayfa})
  let sayfa-etiket = if ingilizce { "Page" } else { "Sayfa" }

  // ---- İTHAF ---- (cls: \vspace*{0.4\textheight} sonra sağa dayalı)
  if ithaf != none and str(ithaf).trim() != "" {
    v(40%)
    align(right)[#emph(strong(ithaf))]
    pagebreak(weak: true)
  }

  // ---- ÖNSÖZ ----
  if onsoz != none {
    heading(level: 1, if ingilizce { "FOREWORD" } else { "ÖNSÖZ" })
    onsoz
  }

  // ---- İÇİNDEKİLER ----
  [
    #set heading(outlined: false)
    #heading(level: 1, if ingilizce { "TABLE OF CONTENTS" } else { "İÇİNDEKİLER" })
  ]
  align(right)[#strong(underline(sayfa-etiket))]
  [
    // Bölüm ve ön/arka materyal (1. seviye) girdileri kalın — cls'teki gibi
    #show outline.entry.where(level: 1): strong
    #outline(title: none, depth: 4, indent: auto)
  ]

  // ---- KISALTMALAR ----
  if kisaltmalar != none {
    heading(level: 1, if ingilizce { "ABBREVIATIONS" } else { "KISALTMALAR" })
    kisaltmalar
  }

  // ---- SEMBOLLER ----
  if semboller != none {
    heading(level: 1, if ingilizce { "SYMBOLS" } else { "SEMBOLLER" })
    semboller
  }

  // ---- ÇİZELGE LİSTESİ ----
  if cizelge-listesi {
    heading(level: 1, if ingilizce { "LIST OF TABLES" } else { "ÇİZELGE LİSTESİ" })
    align(right)[#strong(underline(sayfa-etiket))]
    outline(title: none, target: figure.where(kind: table))
  }

  // ---- ŞEKİL LİSTESİ ----
  if sekil-listesi {
    heading(level: 1, if ingilizce { "LIST OF FIGURES" } else { "ŞEKİL LİSTESİ" })
    align(right)[#strong(underline(sayfa-etiket))]
    outline(title: none, target: figure.where(kind: image))
  }

  // ---- ÖZET / SUMMARY ----
  // Türkçe tezde önce ÖZET, İngilizce tezde önce SUMMARY
  let ozet-blok = if ozet != none {
    heading(level: 1, "ÖZET")
    ozet
  }
  let summary-blok = if summary != none {
    heading(level: 1, "SUMMARY")
    summary
  }
  if ingilizce {
    summary-blok
    ozet-blok
  } else {
    ozet-blok
    summary-blok
  }

  // Gövde ve sonrası (kaynaklar, ekler, özgeçmiş) 1.5 satır aralığına döner
  set par(leading: 1.45em)

  // =====================================================================
  //  GÖVDE  (arabik rakam, numaralı bölümler)
  // =====================================================================
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  [
    #set heading(numbering: "1.1.1.1")
    #set par(leading: 1.45em)   // gövde: 1.5 satır aralığı (\oneandonehalf)
    #body
  ]

  // =====================================================================
  //  KAYNAKLAR
  // =====================================================================
  if kaynakca != none {
    kaynakca
  }

  // =====================================================================
  //  EKLER
  // =====================================================================
  if ekler != none {
    heading(level: 1, if ingilizce { "APPENDICES" } else { "EKLER" })
    ekler
  }

  // =====================================================================
  //  ÖZGEÇMİŞ
  // =====================================================================
  if ozgecmis != none {
    heading(level: 1, if ingilizce { "CURRICULUM VITAE" } else { "ÖZGEÇMİŞ" })
    ozgecmis
  }
}
