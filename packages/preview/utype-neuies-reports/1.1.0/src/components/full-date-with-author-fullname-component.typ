#import "/src/constants/date-constants.typ": FULL-DATE-FORMAT
#import "/src/components/fullname-component.typ": fullname-component
#import "/src/components/date-component.typ": date-component

// Tarihi ekler ve bunun altına da yeni bir satıra yazar adı ve soyadını ekler. [Adds the date and then adds the author's first name and last name below it.]\
/* Örnek [Example]:\
  [15/03/2025]\n[Öğrenci Adı SOYADI]
*/
#let full-date-with-author-fullname-component(
  author: none,
  date: none,
) = {
  // Bileşenin yapısını oluştur. [Construct the component's structure.]
  grid(
    // Yazıyı sayfanın %70'lik kısmından sonrasına koyar. [Places the text after the %70 of the page.]
    columns: (70%, auto),
    rows: auto,
    // Satırlar arasına 1 karater kadar miktarda boşluk bırakır. [Leave a space of 1 character between the rows.]
    row-gutter: 1em,
    // İçeriği ortalar. [Aligns the content.]
    align: center,
    // İçeriğin ikinci sütuna koyulması için satırların birinci sütunlarına boş içerik eklendi. [Adds empty content to the first column of the rows to be placed in the second column.]
    // 1. satır 2. sütuna tarih koyuldu. [The date was placed in the second column of the first row.]
    [], date-component(date: date, display-format: FULL-DATE-FORMAT),
    // 2. satır 2. sütuna yazar adı ve soyadı koyuldu. [The author's first name and last name were placed in the second column of the second row.]
    [], fullname-component(first-name: author.first-name, last-name: author.last-name),
  )
}
