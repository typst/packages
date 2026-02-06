// Kod ve kod figürü örneği.
*Blok kod ekleme örneği aşağıdaki gibidir:*
// Blok kod örneği.
```r
# hello_world.r

hello_world <- function() {
  print("Hello World!")
}
```
*Satır içi kod ekleme örneği aşağıdaki gibidir:*\
// Satır içi kod örneği.
R programlama dilinde yazılan ```r hello_world()``` fonksiyonu konsola `Hello World!` yazdırır.

Yukarıda da görüldüğü gibi, "\`" şeklindeki tek ters tırnak karakterleri arasında yazılan metin ham biçimde gözükecektir.

Yukarıda da görüldüğü gibi, "\`\`\`" şeklindeki üç ters tırnak karakterleri arasında yazılan metin belirtilen programlama diline göre renklendirilmiş bir kod biçimde gözükecektir. Birden fazla satır kullanıldığında kod bloğu haline alır. Tek satırda yazıldığında satır içi kod halinde olur.

*Kodlarınızı figür haline getirerek atıfda bulunabilirsiniz:*
// Kod figürü örneği.
#figure(
  // Figürün başlığı yazılır.
  caption: [R programlama dilinde fonksiyon örneği],
  // Figürün içeriği eklenir. Blok ya da satır içi kod eklenebilir.
  ```r
  # hello_world.r

  hello_world <- function() {
    print("Hello World!")
  }
  ```,
) <figür-kod-R-programlama-dilinde-fonksiyon-örneği> // Figüre atıf yapılırken kullanılacak etiket belirtilir. Bütün figürler 'figür' kelimesi ve türü de (şekilse 'şekil'; tabloysa 'tablo'; kodsa 'kod' vb.) şeklinde sistemli yazılırsa istenen figür aranırken bulması kolaylaşır.

@figür-kod-R-programlama-dilinde-fonksiyon-örneği'de R programlama dilinde yazılan ```r hello_world()``` fonksiyonu konsola `Hello World!` yazdırır.
