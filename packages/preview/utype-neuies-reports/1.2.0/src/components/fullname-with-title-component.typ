#import "/src/components/fullname-component.typ": fullname-component

// Yazarın ünvanı ve adı, soyadını arada bir karakter boşlukla birleştiren içeriği oluşturan bileşen fonksiyonudur. [A function that creates a space-separated string of the author's title, first name, and last name.]\
// Örnek [Example]: [Ünvan] [Adı SOYADI]
#let fullname-with-title-component(
  title: none,
  first-name: none,
  last-name: none,
) = [#title #fullname-component(first-name: first-name, last-name: last-name)]
