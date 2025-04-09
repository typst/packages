#import "/src/constants/document-settings-constants.typ": (
  SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
  ZERO-PARAGRAPH-SPACING-SIZE,
)

// İç Kapak sayfası stili. [Inner Cover page style.]
#let inner-cover-page-style(content) = {
  // Sayfa ayarlarını ayarla. [Set page settings.]
  set page(
    // Sayfanın üst bilgisi kısmını kaldır. [Remove header of the page.]
    header: none,
    // Sayfanın alt bilgisi kısmını kaldırarak sayfa numarasını gizle. [Hide page number by removing footer of the page.]
    footer: none,
    // Tek sütun. [Single column.]
    columns: 1,
  )

  // Her şey ortaya hizalandı. [Everything is centered.]
  set align(center)

  /*
  Paragraf boşluklarını ayarla.\
  Office 365 Word'ün 'Single Line Spacing' ayarı ilk satırın üstü ile ikinci satırın üstü arasındaki mesafeyi ayarlar ve varsayılan değeri font büyüklüğünün %117'sidir. Typst ise ilk satırın altı ile ikinci satırın üstü arasındaki mesafeyi ayarladığı için %17'lik bir boşluk bırakmak Word'deki boşluk miktarını elde etmeyi sağlar.\
  [Set paragraph spacing.]\
  [Office 365 Word's 'Single Line Spacing' setting sets the distance between the top of the first line and the top of the second line and the default value is 117% of the font size. Typst sets the distance between the bottom of the first line and the top of the second line, so %17 spacing creates the same space amount as Word.]
  */
  set par(
    leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
    spacing: ZERO-PARAGRAPH-SPACING-SIZE,
  )

  /*
  Paragraf boşluklarını ayarla. [Set paragraph spacing.]\
  Office 365 Word'ün 'Single Line Spacing' ayarı ilk satırın üstü ile ikinci satırın üstü arasındaki mesafeyi ayarlar ve varsayılan değeri font büyüklüğünün %117'sidir. Typst ise ilk satırın altı ile ikinci satırın üstü arasındaki mesafeyi ayarladığı için `top-edge` ve `bottom-edge` varsayılanlarıyla %40'lık bir boşluk bırakmak Word'deki boşluk miktarına çok yakın bir değer elde etmeyi sağlar. `top-edge` ve `bottom-edge` varsayılanlarını Word'de olduğu gibi yapıp %17'lik bir boşluk bırakmakla Times New Roman (12pt) yazı tipinde aynı sonucu verdi. [Office 365 Word's 'Single Line Spacing' setting sets the distance between the top of the first line and the top of the second line and the default value is 117% of the font size. Typst sets the distance between the bottom of the first line and the top of the second line, so `top-edge` and `bottom-edge` defaults with %40 spacing creates a value close to the space amount of Word. `top-edge` and `bottom-edge` defaults with the same as Word and %17 spacing gives the same result in Times New Roman (12pt).]
  */
  /*
  set par(
    leading: 0.4em,
    spacing: 0em,
  )
  */

  content
}
