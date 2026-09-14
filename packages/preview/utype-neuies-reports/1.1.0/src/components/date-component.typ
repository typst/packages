#import "/src/constants/date-constants.typ": FULL-DATE-FORMAT, STRING-MONTH-NAMES
#import "/src/core/custom-functions/long-month-name-by-language.typ": long-month-name-by-language

// İstenilen formatta tarih eklemek için oluşturulan tarih bileşeni fonksiyonudur ve format uzun ay adını içeriyorsa bunu dil'e göre değiştirerek ekler. [A function that adds a date in the desired format and, if it contains the long month name, changes it according to the language.]\
// Örnek [Example]: "25 Eylül 2025", "25/09/2025", "Eylül 2025".
#let date-component(
  date: datetime.today(),
  display-format: FULL-DATE-FORMAT,
) = {
  // İstenilen formatta tarih ekle ve dil'e göre uzun ay adını değiştir. [Add the date in the desired format and change the long month name according to the language.]
  show: long-month-name-by-language(
    date: date,
    month-names: STRING-MONTH-NAMES,
    date.display(display-format),
  )
}
