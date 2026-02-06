#import "/src/styles/abstract-page-style.typ": abstract-page-style
#import "/src/components/report-title-text-component.typ": report-title-text-component
#import "/src/components/fullname-component.typ": fullname-component
#import "/src/components/keywords-component.typ": keywords-component

// Özet sayfasının yapısını belirleyen fonksiyon. [Function that defines the structure of the abstract page.]\
/* Örnek [Example]:\
  [*ÖZET*]\n[Üniversite Adı, Enstitü Adı]\n[Ana Bilim Dalı]\n[Bilim Dalı]\n[Tez Türü]\n[*TEZİN BAŞLIĞI*]\n[Öğrenci Adı SOYADI]\n[Özet Metni]\n[*Anahtar Kelimeler:* Anahtar kelime 1, Anahtar kelime 2, Anahtar kelime 3]
*/
#let abstract-page-component(
  page-title: none,
  university-name: none,
  institute-name: none,
  department: none,
  program: none,
  report-type: none,
  report-title: none,
  author: none,
  abstract-text-content-file-path: none,
  keywords-title: none,
  keywords: none,
) = {
  // Özet sayfası stilini uygula. [Apply the style of the abstract page.]
  show: abstract-page-style

  // Özet sayfasının başlığı. [Abstract page title.]
  heading(level: 1, upper(page-title))

  // Üniversite ve enstitü bilgisi. [University and institution information.]
  align(center, university-name + ", " + institute-name)

  // Ana Bilim Dalı bilgisi. [Department information.]
  align(center, department)

  // Program bilgisi. [Program information.]
  align(center, program)

  // Rapor türü bilgisi. [Report type information.]
  align(center, report-type)

  // 1 karakter kadar miktarda boşluk bırak. [Leave a space of 1 character.]
  v(1em)

  // Rapor başlığı. [Report title.]
  align(center, report-title-text-component(report-title: report-title))

  // 1 karakter kadar miktarda boşluk bırak. [Leave a space of 1 character.]
  v(1em)

  // Yazar bilgisi. [Author information.]
  align(center, fullname-component(first-name: author.first-name, last-name: author.last-name))

  // Bir miktar boşluk bırak. [Leave some space.]
  v(24pt)

  // Yazılan özet metinini ekle. [Add the abstract text.]
  include abstract-text-content-file-path

  // Varsa anahtar kelimeler ekle. [Add keywords if they exist.]
  if keywords-title != none and keywords != none {
    // Bir miktar boşluk bırak. [Leave some space.]
    v(10pt)

    // Anahtar kelimeleri ekle. [Add keywords.]
    keywords-component(
      keywords-title: keywords-title,
      keywords: keywords,
    )
  }

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
