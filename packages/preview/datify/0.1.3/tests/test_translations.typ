// To compile this file : typst compile --root .. .\test_translations.typ

#import "../src/translations.typ": day-name, month-name

#assert(day-name(1, "fr") == "lundi")
#assert(month-name(1, "fr") == "janvier")
#assert(day-name(1, "en", true) == "Monday")
#assert(month-name(1, "en", true) == "January")
#assert(day-name(1, "es") == "lunes")
#assert(month-name(1, "es") == "enero")
#assert(day-name(1, "pt") == "segunda-feira")
#assert(month-name(1, "pt") == "janeiro")
