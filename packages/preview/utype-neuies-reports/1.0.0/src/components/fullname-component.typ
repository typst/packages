// Yazar adı ve soyadını arada bir karakter boşlukla birleştiren içeriği oluşturan bileşen fonksiyonudur. [A function that creates a space-separated string of the author's first name and last name.]\
// Örnek: [Example]: [Adı] [SOYADI]
#let fullname-component(first-name: none, last-name: none) = [#first-name #upper(last-name)]
