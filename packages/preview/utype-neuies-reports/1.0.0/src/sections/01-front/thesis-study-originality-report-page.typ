#import "/src/components/full-date-with-author-fullname-component.typ": full-date-with-author-fullname-component
#import "/src/components/fullname-with-title-component.typ": fullname-with-title-component
#import "/src/components/date-component.typ": date-component
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Tez Çalışması Orijinallik Raporu sayfası. [Thesis Study Originality Report page.]
#let thesis-study-originality-report-page(
  report-title: none,
  author: none,
  advisor: none,
  date: none,
  included-page-count: none,
  similarity-score: none,
) = {
  // Sayfa başlığını ekle. [Add page header.]
  heading(level: 1, upper(translator(key: language-keys.THESIS-STUDY-ORIGINALITY-REPORT)))

  // Sayfa içeriğini ekle. [Add page content.]
  // Metin ekle. [Add text.]
  [#text(style: "italic", report-title.tur.title-case) başlıklı tez çalışmamın toplam #included-page-count sayfalık kısmına ilişkin, #date-component(date: date) tarihinde tez danışmanım tarafından #text(weight: "bold")[Turnitin] adlı intihal tespit programından aşağıda belirtilen filtrelemeler uygulanarak alınmış olan orijinallik raporuna göre, tezimin benzerlik oranı #text(weight: "bold")[%#similarity-score] olarak belirlenmiştir.]

  // Bir miktar boşluk bırak. [Leave some space.]
  v(0.5em)

  // Paragraf ilk satır girintisini kaldırarak metin ekle. [Remove the first line indent of the paragraph and add text.]
  par(first-line-indent: 0cm)[Uygulanan filtrelemeler:]

  // Bir miktar boşluk bırak. [Leave some space.]
  v(0.5em)

  // Listeyi ekle. [Add list.]
  [
    + Tez çalışması orijinallik raporu sayfası hariç
    + Bilimsel etik beyannamesi sayfası hariç
    + Önsöz hariç
    + İçindekiler hariç
    + Simgeler ve kısaltmalar hariç
    + Kaynaklar hariç
    + Alıntılar dahil
    + 7 kelimeden daha az örtüşme içeren metin kısımları hariç
  ]

  // Bir miktar boşluk bırak. [Leave some space.]
  v(0.5em)

  // Metin ekle. [Add text.]
  [Necmettin Erbakan Üniversitesi Tez Çalışması Orijinallik Raporu Uygulama Esaslarını inceledim ve tez çalışmamın, bu uygulama esaslarında belirtilen azami benzerlik oranının (%30) altında olduğunu ve intihal içermediğini; aksinin tespit edileceği muhtemel durumda doğabilecek her türlü hukuki sorumluluğu kabul ettiğimi ve yukarıda vermiş olduğum bilgilerin doğru olduğunu beyan ederim.]

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2em)

  // Yazar ve tarih bilgilerini ekle. [Add author and date information.]
  full-date-with-author-fullname-component(
    author: author,
    date: date,
  )

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2em)

  // Danışman bilgilerini ekle. [Add advisor information.]
  align(
    center,
    fullname-with-title-component(
      title: advisor.academic-member-title,
      first-name: advisor.first-name,
      last-name: advisor.last-name,
    ),
  )

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
