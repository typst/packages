// To compile this file : typst compile --root .. .\test_formats.typ

#import "../src/formats.typ": custom-date-format 

#let date = datetime(year: 2024, month: 8, day: 29)

#assert(custom-date-format(date, "YYYY-MM-DD") == "2024-08-29")
#assert(custom-date-format(date, "MM/DD/YYYY") == "08/29/2024")
#assert(custom-date-format(date, "Month DD, YYYY") == "August 29, 2024")
#assert(custom-date-format(date, "month DD, YYYY") == "august 29, 2024")
#assert(custom-date-format(date, "month DDth, YYYY") == "august 29th, 2024")

#let french_date = datetime(year: 2024, month: 5, day: 23)
#assert(custom-date-format(french_date, "Day, DD Month YYYY", "fr") == "Jeudi, 23 Mai 2024")

#let french_date = datetime(year: 2024, month: 8, day: 23)
#assert(custom-date-format(french_date, "Day, DD MMM YYYY", "fr") == "Vendredi, 23 aoû 2024")

#let spanish_date = datetime(year: 2023, month: 2, day: 23)
#assert(custom-date-format(spanish_date, "day, DD de month de YYYY", "es") == "jueves, 23 de febrero de 2023")

#let spanish_date = datetime(year: 2024, month: 8, day: 9)
#assert(custom-date-format(spanish_date, "day, DD de month de YYYY", "es") == "viernes, 09 de agosto de 2024")

#let portuguese_date = datetime(year: 2024, month: 10, day: 23)
#assert(custom-date-format(portuguese_date, "day, DD de month de YYYY", "pt") == "quarta-feira, 23 de outubro de 2024")

#let portuguese_date = datetime(year: 2024, month: 7, day: 7)
#assert(custom-date-format(portuguese_date, "day, DD de month de YYYY", "pt") == "domingo, 07 de julho de 2024")