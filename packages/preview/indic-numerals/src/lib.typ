#let arabic-to-assamese(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-bengali(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-gujarati(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("૦", "૧", "૨", "૩", "૪", "૫", "૬", "૭", "૮", "૯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-hindi(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-kannada(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("೦", "೧", "೨", "೩", "೪", "೫", "೬", "೭", "೮", "೯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-malayalam(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("൦", "൧", "൨", "൩", "൪", "൫", "൬", "൭", "൮", "൯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-marathi(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-nepali(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-odia(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("୦", "୧", "୨", "୩", "୪", "୫", "୬", "୭", "୮", "୯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-punjabi(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("੦", "੧", "੨", "੩", "੪", "੫", "੬", "੭", "੮", "੯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-tamil(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("௦", "௧", "௨", "௩", "௪", "௫", "௬", "௭", "௮", "௯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-telugu(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let indic-digits = ("౦", "౧", "౨", "౩", "౪", "౫", "౬", "౭", "౮", "౯")
  let string = str(number)
  return string.replace(arabic-digits.at(0), indic-digits.at(0))
               .replace(arabic-digits.at(1), indic-digits.at(1))
               .replace(arabic-digits.at(2), indic-digits.at(2))
               .replace(arabic-digits.at(3), indic-digits.at(3))
               .replace(arabic-digits.at(4), indic-digits.at(4))
               .replace(arabic-digits.at(5), indic-digits.at(5))
               .replace(arabic-digits.at(6), indic-digits.at(6))
               .replace(arabic-digits.at(7), indic-digits.at(7))
               .replace(arabic-digits.at(8), indic-digits.at(8))
               .replace(arabic-digits.at(9), indic-digits.at(9))
}

#let arabic-to-urdu(number) = {
  let arabic-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
  let urdu-digits = ("۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹")
  let string = str(number)
  return string.replace(arabic-digits.at(0), urdu-digits.at(0))
               .replace(arabic-digits.at(1), urdu-digits.at(1))
               .replace(arabic-digits.at(2), urdu-digits.at(2))
               .replace(arabic-digits.at(3), urdu-digits.at(3))
               .replace(arabic-digits.at(4), urdu-digits.at(4))
               .replace(arabic-digits.at(5), urdu-digits.at(5))
               .replace(arabic-digits.at(6), urdu-digits.at(6))
               .replace(arabic-digits.at(7), urdu-digits.at(7))
               .replace(arabic-digits.at(8), urdu-digits.at(8))
               .replace(arabic-digits.at(9), urdu-digits.at(9))
}

#let arabic-to-indic(number, language) = {
  if language == "assamese" {
    return arabic-to-assamese(number)
  } else if language == "bengali" {
    return arabic-to-bengali(number)
  } else if language == "gujarati" {
    return arabic-to-gujarati(number)
  } else if language == "hindi" {
    return arabic-to-hindi(number)
  } else if language == "kannada" {
    return arabic-to-kannada(number)
  } else if language == "malayalam" {
    return arabic-to-malayalam(number)
  } else if language == "marathi" {
    return arabic-to-marathi(number)
  } else if language == "nepali" {
    return arabic-to-nepali(number)
  } else if language == "odia" {
    return arabic-to-odia(number)
  } else if language == "punjabi" {
    return arabic-to-punjabi(number)
  } else if language == "tamil" {
    return arabic-to-tamil(number)
  } else if language == "telugu" {
    return arabic-to-telugu(number)
  } else if language == "urdu" {
    return arabic-to-urdu(number)
  } else {
    return "Language not supported"
  }
}

#let assamese-to-arabic(number) = {
  let digits = ("০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let bengali-to-arabic(number) = {
  let digits = ("০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let gujarati-to-arabic(number) = {
  let digits = ("૦", "૧", "૨", "૩", "૪", "૫", "૬", "૭", "૮", "૯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let hindi-to-arabic(number) = {
  let digits = ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let kannada-to-arabic(number) = {
  let digits = ("೦", "೧", "೨", "೩", "೪", "೫", "೬", "೭", "೮", "೯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let malayalam-to-arabic(number) = {
  let digits = ("൦", "൧", "൨", "൩", "൪", "൫", "൬", "൭", "൮", "൯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let marathi-to-arabic(number) = {
  let digits = ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let nepali-to-arabic(number) = {
  let digits = ("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let odia-to-arabic(number) = {
  let digits = ("୦", "୧", "୨", "୩", "୪", "୫", "୬", "୭", "୮", "୯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let punjabi-to-arabic(number) = {
  let digits = ("੦", "੧", "੨", "੩", "੪", "੫", "੬", "੭", "੮", "੯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let tamil-to-arabic(number) = {
  let digits = ("௦", "௧", "௨", "௩", "௪", "௫", "௬", "௭", "௮", "௯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let telugu-to-arabic(number) = {
  let digits = ("౦", "౧", "౨", "౩", "౪", "౫", "౬", "౭", "౮", "౯")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let urdu-to-arabic(number) = {
  let digits = ("۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹")
  let number = str(number)
  return number.replace(digits.at(0), "0")
               .replace(digits.at(1), "1")
               .replace(digits.at(2), "2")
               .replace(digits.at(3), "3")
               .replace(digits.at(4), "4")
               .replace(digits.at(5), "5")
               .replace(digits.at(6), "6")
               .replace(digits.at(7), "7")
               .replace(digits.at(8), "8")
               .replace(digits.at(9), "9")
}

#let indic-to-arabic(number) = {
    if number.contains("০") or number.contains("১") or number.contains("২") or number.contains("৩") or number.contains("৪") or number.contains("৫") or number.contains("৬") or number.contains("৭") or number.contains("৮") or number.contains("৯") {
        assamese-to-arabic(number)
    } else if number.contains("૦") or number.contains("૧") or number.contains("૨") or number.contains("૩") or number.contains("૪") or number.contains("૫") or number.contains("૬") or number.contains("૭") or number.contains("૮") or number.contains("૯") {
        gujarati-to-arabic(number)
    } else if number.contains("०") or number.contains("१") or number.contains("२") or number.contains("३") or number.contains("४") or number.contains("५") or number.contains("६") or number.contains("७") or number.contains("८") or number.contains("९") {
        hindi-to-arabic(number)
    } else if number.contains("೦") or number.contains("೧") or number.contains("೨") or number.contains("೩") or number.contains("೪") or number.contains("೫") or number.contains("೬") or number.contains("೭") or number.contains("೮") or number.contains("೯") {
        kannada-to-arabic(number)
    } else if number.contains("൦") or number.contains("൧") or number.contains("൨") or number.contains("൩") or number.contains("൪") or number.contains("൫") or number.contains("൬") or number.contains("൭") or number.contains("൮") or number.contains("൯") {
        malayalam-to-arabic(number)
    } else if number.contains("୦") or number.contains("୧") or number.contains("୨") or number.contains("୩") or number.contains("୪") or number.contains("୫") or number.contains("୬") or number.contains("୭") or number.contains("୮") or number.contains("୯") {
        odia-to-arabic(number)
    } else if number.contains("੦") or number.contains("੧") or number.contains("੨") or number.contains("੩") or number.contains("੪") or number.contains("੫") or number.contains("੬") or number.contains("੭") or number.contains("੮") or number.contains("੯") {
        punjabi-to-arabic(number)
    } else if number.contains("௦") or number.contains("௧") or number.contains("௨") or number.contains("௩") or number.contains("௪") or number.contains("௫") or number.contains("௬") or number.contains("௭") or number.contains("௮") or number.contains("௯") {
        tamil-to-arabic(number)
    } else if number.contains("౦") or number.contains("౧") or number.contains("౨") or number.contains("౩") or number.contains("౪") or number.contains("౫") or number.contains("౬") or number.contains("౭") or number.contains("౮") or number.contains("౯") {
        telugu-to-arabic(number)
    } else if number.contains("۰") or number.contains("۱") or number.contains("۲") or number.contains("۳") or number.contains("۴") or number.contains("۵") or number.contains("۶") or number.contains("۷") or number.contains("۸") or number.contains("۹") {
        urdu-to-arabic(number)
    } else {
        "Language not supported"
    }
}


#tamil-to-arabic("௧௨௩௪௫௬௭௮௯௦")