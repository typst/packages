= Tips for Polish writers <chap:polish-tips>
#set text(lang: "pl")


== Znaki specjalne

Należy pamiętać o zasadach polskiej interpunkcji i ortografii. Po spójnikach
jednoliterowych warto wstawić znak tyldy (˜), który jest tak zwaną „twardą”
(albo nierozdzielającą) spacją i~powoduje, że wyrazy nią połączone nie będą
rozdzielane na dwie linie tekstu:

#align(center)[
  ```typst
  I~wtedy pomyślałem, że to życie może jednak jest coś warte.
  ```
]

Polskie znaki interpunkcyjne różnią się nieco od angielskich: to jest "polski",
a to jest #text(lang: "en")["angielski"] cudzysłów. Typst automatycznie stawia
poprawny wariant w zależności od obecnego języka tekstu:

#align(center)[
  ```typst
  #set text(lang: "pl")
  To jest "polski", a to jest #text(lang: "en")["angielski"] cudzysłów.
  ```
]

Analogicznie zapisuje się (rzadko stosowany w tekście, ale spotykany w
informatyce) cudzysłów pojedynczy: #text(lang: "en")['character']).

Pozostałe zasady interpunkcji i typografii można znaleźć w słownikach.

== Gramatyczna odmiana generowanych odnośników

Pisząc po polsku, kiedy chcemy odwołać się np. do rozdziału lub rysunku, istotne
jest zachowanie właściwej formy suplementu odnośnika. Jeśli zdanie wymaga formy
mianownikowej, to nie ma problemu. Piszemy po prostu:

#align(center)[
  ```typst
  @sec:topic-and-scope opowiada o tematyce pracy.
  ```
]

Natomiast przykładowo takie zdanie:

#align(center)[
  ```typst
  W~@sec:topic-and-scope omawiany jest zakres pracy.
  ```
]

Zostanie przełożone na "W~@sec:topic-and-scope omawiany jest temat pracy", co
jest gramatycznie niepoprawne i nieładnie wygląda. W takich sytuacjach
przydatne jest tymczasowe nadpisanie tzw.~suplementu (w tym wypadku słowa
"Rozdział"). Na szczęście twórcy Typst przewidzieli ten~problem i~wbudowali
w~język specjalną składnię, która nam to umożliwia:

#align(center)[
  ```typst
  W~@sec:topic-and-scope[Rozdziale] omawiany jest zakres pracy.
  ```
]

Taka forma skutkuje poprawnym "W~@sec:topic-and-scope[Rozdziale] omawiany jest
temat pracy". Równocześnie, całe sformułowanie
"@sec:topic-and-scope[Rozdziale]" będzie poprawnie wygenerowane jako klikalny
odnośnik do odpowiedniego miejsca w pracy.

To samo tyczy się odwołań do rysunków, tabel, równań, etc. Dla ciekawych,
dokumentacja funkcji ```typst ref()```, która jest wewnętrznie wywoływana
dla każdego odwołania:\ https://typst.app/docs/reference/model/ref/.


== Przecinek jako separator dziesiętny

W momencie tworzenia tego szablonu, Typst 0.13.0 nie posiada wbudowanego wsparcia
dla matematycznych separatorów dziesiętnych innych niż kropka. Dostępne są dwa
rozwiązania:

1. Użyć reguły ```typst show``` aby podmienić kropkę na przecinek w
  wyświetlanym tekście. Przykładowa reguła poniżej. Powinna zostać
  zdefiniowana na początku dokumentu:
  ```typst
  #show math.equation: it => {
    show regex("\d+\.\d+"): num => num.text.replace(".", ",")
    it
  }
  ```
  To rozwiązanie to "hack" -- nie ma gwarancji, że będzie działać zgodnie
  z oczekiwaniami w każdej sytuacji.

2. Skorzystać z zewnętrznej paczki, która dodaje tę funkcjonalność. Zdaje się,
  że przynajmniej jedną taką paczką jest
  #link("https://typst.app/universe/package/zero")[zero].

Aktualny stan tego problemu może być śledzony tutaj:
- https://github.com/typst/typst/issues/1093 ~// Add invisible space in regular font; workaround for ugly vertical spacing caused by https://github.com/typst/typst/issues/1204
