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
