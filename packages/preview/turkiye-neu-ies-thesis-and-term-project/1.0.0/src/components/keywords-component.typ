// Anahtar kelime dizisini aralarında virgül koyarak birleştirip Özet metninin sonunda yer alan anahtar kelimeler kısmını oluşturan bileşen fonksiyonudur. [A function that joins the keyword array with commas and creates the keywords section in the abstract.]\
// Örnek [Example]: [*Anahtar Kelimeler:* Anahtar kelime 1, Anahtar kelime 2, Anahtar kelime 3]
#let keywords-component(
  keywords-title: none,
  keywords: none,
) = {
  // Yazıyı sola hizala. [Align the text to the left.]
  set align(left)

  // Paragraf ayarlarını ayarla. [Set paragraph settings.]
  set par(
    // Paragrafın ilk satır girintisini 0 yap. [Set the first line indent of the paragraph to 0.]
    first-line-indent: 0cm,
    // Paragraflar arası boşluk miktarını 0 yap. [Set the spacing between paragraphs to 0.]
    spacing: 0pt,
  )

  // Kalın yazı ile "Anahtar Kelimeler" satır içi başlığını oluştur ve anahtar kelime dizisini virgülle birleştir. [Create a bold text "Keywords" heading inside a row and join the keyword array with commas.]
  text(weight: "bold", keywords-title + ": ") + keywords.join(", ")
}
