// Dil'e göre uzun ay adını değiştiren fonksiyondur. [A function that changes the long month name according to the language.]
#let long-month-name-by-language(
  date: none,
  month-names: none,
  content,
) = {
  // Regex ile ay adını al ve dile göre değiştir. [Get the month name with regex and change it according to the language.]
  show regex("[a-zA-Z]+"): month-name => month-names.at(date.month() - 1)

  content
}
