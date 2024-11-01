#let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

#let indic-digits = (
  "assamese": ("০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯"),
  "bengali": ("০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯"),
  "gujarati": ("૦", "૧", "૨", "૩", "૪", "૫", "૬", "૭", "૮", "૯"),
  "hindi": ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९"),
  "kannada": ("೦", "೧", "೨", "೩", "೪", "೫", "೬", "೭", "೮", "೯"),
  "malayalam": ("൦", "൧", "൨", "൩", "൪", "൫", "൬", "൭", "൮", "൯"),
  "marathi": ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९"),
  "nepali": ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९"),
  "odia": ("୦", "୧", "୨", "୩", "୪", "୫", "୬", "୭", "୮", "୯"),
  "punjabi": ("੦", "੧", "੨", "੩", "੪", "੫", "੬", "੭", "੮", "੯"),
  "tamil": ("௦", "௧", "௨", "௩", "௪", "௫", "௬", "௭", "௮", "௯"),
  "telugu": ("౦", "౧", "౨", "౩", "౪", "౫", "౬", "౭", "౮", "౯"),
  "urdu": ("۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹")
)

#let convert-number(number, source-digits, target-digits) = {
  let string = str(number)
  
  for i in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9) {
    string = string.replace(source-digits.at(i), target-digits.at(i))
  }
  
  return string
}

#let arabic-to-indic(number, language) = {
  let indic-digits-selected = indic-digits.at(language)
  
  return convert-number(number, arabic-digits, indic-digits-selected)
}

#let indic-to-arabic(number, language) = {
  let indic-digits-selected = indic-digits.at(language)
  
  return convert-number(number, indic-digits-selected, arabic-digits)
}
