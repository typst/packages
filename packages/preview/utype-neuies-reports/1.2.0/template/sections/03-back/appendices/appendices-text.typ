// Ekler metnini yazınız.
Herhangi bir eki referans göstermek: @ek-meb-izin-kağıdı.

@ek-görüşme-örneği

@ek-ilk-sıradaki-ek

@ek-ikinci-sıradaki-ek

/*
İsterseniz tek bir dosyada bütün ekleri ekleyebilirsiniz.
Ya da "appendices" klasöründe oluşturacağınız ayrı ayrı dosyaları aşağıdaki gibi ekleyebilir, böylece her bir eki ayrı bir dosyada olacak şekilde ayırarak da yapabilirsiniz. Diğer bölümler için de benzer işlem yapılabilir.
*/
// Başka bir '.typ' uzantılı Typst dosyasındaki içeriği eklemek için "include" komutunu kullanabilirsiniz.
#include "/template/sections/03-back/appendices/appendix-1.typ"

// Başka bir '.typ' uzantılı Typst dosyasındaki içeriği eklemek için "include" komutunu kullanabilirsiniz.
#include "/template/sections/03-back/appendices/appendix-2.typ"

// Devamındaki içeriğin yeni bir sayfadan başlamasını sağlamak için "pagebreak()" fonksiyonunu kullanabilirsiniz.
#pagebreak()

// Her 2. düzey başlık bir ektir ve İçindekiler tablosunda yer alır.
== Meb İzin Kağıdı <ek-meb-izin-kağıdı>
#lorem(50)

...
// 3. düzey ve sonrası başlıklarla devam edin.
// Her 3. düzey başlık bir alt ektir ve İçindekiler tablosunda yer alır.
=== Örnek başlık 3
#lorem(20)
==== Örnek başlık 4
#lorem(20)
===== Örnek başlık 5
#lorem(20)
====== Örnek başlık 6
#lorem(20)

...

// Her 2. düzey başlık bir ektir ve İçindekiler tablosunda yer alır.
== Görüşme Örneği <ek-görüşme-örneği>
#lorem(50)

...
// 3. düzey ve sonrası başlıklarla devam edin.
// Her 3. düzey başlık bir alt ektir ve İçindekiler tablosunda yer alır.
=== Örnek başlık 3
#lorem(20)
==== Örnek başlık 4
#lorem(20)
===== Örnek başlık 5
#lorem(20)
====== Örnek başlık 6
#lorem(20)

...
