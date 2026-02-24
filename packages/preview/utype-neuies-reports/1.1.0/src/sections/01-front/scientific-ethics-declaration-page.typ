#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/components/full-date-with-author-fullname-component.typ": full-date-with-author-fullname-component

// Bilimsel Etik Beyannamesi sayfası. [Scientific Ethics Declaration page.]
#let scientific-ethics-declaration-page(
  author: none,
  date: none,
) = {
  // Sayfa başlığını ekle. [Add page header.]
  heading(level: 1, upper(translator(key: language-keys.SCIENTIFIC-ETHIC-DECLARATION)))

  // Sayfa içeriğini ekle. [Add page content.]
  [
    Bu tezin tamamının kendi çalışmam olduğunu, planlanmasından yazımına kadar tüm aşamalarında bilimsel etiğe ve akademik kurallara özenle riayet edildiğini, tez içindeki bütün bilgilerin etik davranış ve akademik kurallar çerçevesinde elde edilerek sunulduğunu, ayrıca tez hazırlama kurallarına uygun olarak hazırlanan bu çalışmada başkalarının eserlerinden yararlanılması durumunda bilimsel kurallara uygun olarak atıf yapıldığını ve bu kaynakların kaynaklar listesine eklendiğini beyan ederim.
  ]

  // Bir miktar boşluk bırak. [Leave some space.]
  v(2em)

  // Yazar ve tarih bilgilerini ekle. [Add author and date information.]
  full-date-with-author-fullname-component(
    author: author,
    date: date,
  )

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
