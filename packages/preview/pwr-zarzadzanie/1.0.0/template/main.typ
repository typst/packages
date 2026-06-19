#import "@preview/pwr-zarzadzanie:1.0.0": praca-dyplomowa, zalacznik, zrodlo

#show: praca-dyplomowa.with(
  tytul: [
    PROJEKT PROJEKTOWANIA PROJEKTU PROCESU W FIRMIE PROJEKTUJĄCEJ
  ],
  autor: "Jan Kowalski",
  kierunek: [Zarządzanie zarządzaniem],
  specjalnosc: [zarządzanie],
  slowa_kluczowe: [
    Psy \
    Koty \
    Węże \
    Zarządzanie
  ],
  rodzaj_pracy: [inżynierska],
  opiekun: [Juzek],
  krotkie_streszczenie: [
    #lorem(50)
  ],
  rok: [2026],
  streszczenie: [
    #lorem(200)
  ],
  abstract: [
    #lorem(200)
  ],
  zalaczniki: [
    Załączniki ponumerować kolejno, jednostopniowo („Załącznik 1”). Tytuł załącznika
    należy umieścić centralnie nad załącznikiem, 10 pkt odstępu od tekstu zasadniczego nad
    tytułem. Źródło jego pochodzenia należy podać pod załącznikiem. Należy zrobić 10 pkt
    odstępu pomiędzy podaniem źródła a tekstem zasadniczym.

    #zalacznik("Kod źródłowy aplikacji")

    Poniżej znajduje się treść pierwszego załącznika. Załączniki są numerowane jednostopniowo na końcu pracy, każdy może zaczynać się od nowej strony.
  ],
  biblio: path("biblio.bib"),
  spis-rysunkow: true,
  spis-tabel: true,
)

#heading(numbering: none)[Wprowadzenie]
Tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny,
tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny.

= Tytuł rozdziału

Tekst podstawowy jest wyjustowany. Pierwszy wiersz nowego akapitu posiada wcięcie 0.7 cm. Zgodnie z wymaganiami czcionka to Times New Roman, 12 pkt. Przejście do nowego rozdziału automatycznie generuje nową stronę. 

Kolejny akapit tekstu w celu weryfikacji wcięć. Tutaj dodajemy przypis dolny#footnote[To jest przykładowy przypis dolny. Jest napisany czcionką 10 pkt i interlinia jest pojedyncza.]. 

== Wymagania szczegółowe
Podrozdział ma rozmiar 13 pkt, jest pogrubiony. Odstęp przed i po wynosi 6 pkt. Poniżej znajduje się przykład tabeli wraz ze źródłem.

#figure(
  table(
    columns: (auto, auto, auto),
    // fill: (x, y) => if y == 0 { luma(230) } else { none },
    [*Lp.*], [*Parametr*], [*Wartość*],
    [1], [Szerokość marginesu], [3.0 cm],
    [2], [Rozmiar czcionki], [12 pkt],
  ),
  
  caption: [Zestawienie podstawowych parametrów formatowania.],
)

#zrodlo[dog ausgfouasvbfoubgv]

=== Paragraf (poziom 3)
Paragraf to nagłówek trzeciego poziomu. Ma rozmiar 12 pkt, jest pogrubiony, posiada odstępy 6 pkt przed i po. 

Zgodnie z punktem 9, wzory matematyczne muszą być umieszczane centralnie i numerowane w nawiasach do prawego marginesu:

$ E = m c^2 $

Nie wszystkie wzory muszą być numerowane – tylko te, do których jest odwołanie w tekście. Wzór bez numeracji uzyskuje się pomijając blok równania (używając nawiasów zamiast znaków dolara) @dupa.

$ 
E = m c^2 \ 
sum_(x=1) x^2 
$ <dupa>

== Rysunki w tekście
Podpis rysunku umieszczany jest centralnie pod rysunkiem. Pod podpisem musi znaleźć się źródło, oddalone o 10 pkt.

#figure(
  rect(width: 60%, height: 3cm, fill: rgb("e1e1e1"), align(center + horizon)[Miejsce na obraz]),
  caption: [Podpis automatyczny – polecenie Odwołania/Wstaw podpis ],
)
#zrodlo[opracowanie własne]

= Tytuł rozdziału

Tekst podstawowy jest wyjustowany. Pierwszy wiersz nowego akapitu posiada wcięcie 0.7 cm. Zgodnie z wymaganiami czcionka to Times New Roman, 12 pkt. Przejście do nowego rozdziału automatycznie generuje nową stronę.

Kolejny akapit tekstu w celu weryfikacji wcięć. Tutaj dodajemy przypis dolny#footnote[To jest przykładowy przypis dolny. Jest napisany czcionką 10 pkt i interlinia jest pojedyncza.]. 

== Wymagania szczegółowe
Podrozdział ma rozmiar 13 pkt, jest pogrubiony. Odstęp przed i po wynosi 6 pkt. Poniżej znajduje się przykład tabeli wraz ze źródłem.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    fill: (x, y) => if y == 0 { luma(230) } else { none },
    [*Lp.*], [*Parametr*], [*Wartość*],
    [1], [Szerokość marginesu], [3.0 cm],
    [2], [Rozmiar czcionki], [12 pkt],
  ),
  caption: [Zestawienie podstawowych parametrów formatowania.],
)
#zrodlo[opracowanie własne]


=== Paragraf (poziom 3)
Paragraf to nagłówek trzeciego poziomu. Ma rozmiar 12 pkt, jest pogrubiony, posiada odstępy 6 pkt przed i po. 

Zgodnie z punktem 9, wzory matematyczne muszą być umieszczane centralnie i numerowane w nawiasach do prawego marginesu:

$ E = m c^2 $

Nie wszystkie wzory muszą być numerowane – tylko te, do których jest odwołanie w tekście. Wzór bez numeracji uzyskuje się pomijając blok równania (używając nawiasów zamiast znaków dolara) @dupa2.

$ 
E = m c^2 \ 
sum_(x=1) x^2 
$ <dupa2>

== Rysunki w tekście
Podpis rysunku umieszczany jest centralnie pod rysunkiem. Pod podpisem musi znaleźć się źródło, oddalone o 10 pkt.

#figure(
  rect(width: 60%, height: 3cm, fill: rgb("e1e1e1"), align(center + horizon)[Miejsce na obraz]),
  caption: [Podpis automatyczny – polecenie Odwołania/Wstaw podpis ],
)
#zrodlo[opracowanie własne]

= Tytuł rozdziału
== Tytuł podrozdziału
=== Tytuł paragrafu
Tytuły rozdziałów i podrozdziałów każdego poziomu 1/2/3 formatujemy stylami
nagłówkowymi – Nagłówek 1/2/3.

=== Zasadniczy tekst i przypisy dolne
Zwykły tekst formatujemy stylem Normalny. Jeżeli zachodzi potrzeba dodania dygresji,
objaśnienia terminu itp., wstawiamy przypis dolny1 jak tu z lewej do słowa „dolny” – z
odsyłaczem w postaci cyfry. Nie powołujemy się na źródła literaturowe w przypisach
dolnych.

=== Powoływanie się na źródła literaturowe

Chcąc odwołać się do źródła (książki, czasopisma, strony internetowej itp.),
zamieszczamy odwołanie poleceniem Odwołania / Wstaw cytat, ustawiając jednorazowo
styl cytowań „Harvard” (Zymonik, 2020), czyli nazwisko i rok w nawiasach okrągłych
(Malara & Ziembicki, 2020) <= jak dwa w tym zdaniu.

== Tytuł podrozdziału

=== Tytuł paragrafu

Tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny.

- lista punktowana
- dwa
  - podpunkt
  - podpunkt
- trzy

Tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny.

=== Tytuł paragrafu specjalnie taki bardzo długi, żeby było widać jak wygląda tu oraz w spisie treści

Tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny.

+ lista numerowana,
+ dwa,
+ trzy

Tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny.

Tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst
normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny, tekst normalny. @aho_projektowanie_1983


#heading(numbering: none)[Zakończenie]

W zakończeniu pracy należy przedstawić syntetyczne wnioski płynące z całej pracy
nawiązujące do celu i zakresu pracy. Należy określić w jakim stopniu osiągnięto założony
cel pracy. W przypadku częściowej realizacji celu, podać przyczyny niepowodzeń. Można
wskazać kierunki dalszych działań. Nie należy poruszać nowych wątków, prezentować
nowych zagadnień, które nie były wcześniej omawiane w pracy.