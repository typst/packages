#import "/src/constants/language-free-string-constants.typ": STRING-CITY-NAME
#import "/src/constants/date-constants.typ": ONLY-YEAR-DATE-FORMAT

// Şehir adı ve yıl bilgisi. [City name and year information.]\
// Örnek [Example]: "Konya - 2025"
#let city-name-with-year-component(date: none) = [#STRING-CITY-NAME #sym.dash #date.display(ONLY-YEAR-DATE-FORMAT)]
