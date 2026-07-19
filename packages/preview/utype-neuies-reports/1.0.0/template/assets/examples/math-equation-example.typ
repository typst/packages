// Matematiksel semboller
*Denklemlerde matematiksel semboller kullanma örneği aşağıdaki gibidir:*\
$ A = pi r^2 $
$ "Alan" = pi dot "yarıçap"^2 $
$
  cal(A) := { x in RR | x "bir reel sayı" }
$
// Tanımladığınız değişkenleri denklemlerin içinde kullanabilirsiniz:
#let x = 5
$ #x < 17 $

#v(0.5cm)

/*
Matematiksel denklemler metinle satır içi veya ayrı bir blok biçiminde görüntülenebilir. Bir denklem, açılış dolar işaretinden sonra en az bir boşluk ve kapanış dolar işaretinden önce bir boşluk olmasıyla blok düzeyinde olur.
Blok deklem bir satırı kaplarlar.
*/
*Satır içi denklem ekleme örneği aşağıdaki gibidir:*\
$a$, $b$, ve $c$ dik açılı üçgenin kenar uzunlukları olsun. O zaman:

*Blok denklem ekleme örneği aşağıdaki gibidir:*
$ a^2 + b^2 = c^2 $

#v(0.5cm)

/*
"&" İşareti ve Hizalama: Her "&" işareti, kendinden önceki kısmın hizalamasını belirler ve dolaylı olarak her zaman sonraki kısmın hizalaması önceki kısmın zıttı olur.

Tek Sayıda "&" İşareti: Eğer "&" işaretleri tek sayıda ise (1, 3, 5, ...), önceki kısım sola hizalanır ve sonraki kısım sağa hizalanır.

Çift Sayıda "&" İşareti: Eğer "&" işaretleri çift sayıda ise (2, 4, 6, ...), önceki kısım sağa hizalanır ve sonraki kısım sola hizalanır.

Kısaca, tek sayıda "&" işareti önceki kısmı sola hizalarken çift sayıda "&" işareti önceki kısmı sağa hizalar ve her zaman sonraki kısmın hizalaması önceki kısmın zıttı olur.\
*/
*Denklemlerde hizalama örneği:*\
Aşağıdaki örnekte denklemler "=" işaretinin konumuna göre hizlandı:
$
  (3x + y) / 7 &= 9\
  3x + y &= 63\
  3x &= 63 - y\
  x &= 21 - y / 3
$

#v(0.5cm)

*Denklemlerinize etiketler koyarak atıfda bulunabilirsiniz:*\
Ardışık sayıların toplamı:
$
  sum_(k=1)^n k = (n(n+1)) / 2
$ <denklem-ardışık-sayıların-toplamı> // Denkleme atıf yapılırken kullanılacak etiket belirtilir. Bütün denklemler 'denklme' kelimesi şeklinde sistemli yazılırsa istenen figür aranırken bulması kolaylaşır.

@denklem-ardışık-sayıların-toplamı ardışık sayıların toplamının formülüdür.

#v(0.5cm)

Daha fazla bilgi için #link("https://typst.app/docs/reference/math/") adresini ziyaret edebilirsiniz.
