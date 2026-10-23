#import "@preview/pg-unofficial-thesis:1.0.1": ang, written-by

// W pracy zespołowej autora rozdziału lub podrozdziału podaje się po
// tytule – w treści i w spisie treści: `= Tytuł #written-by[Imię Nazwisko]`.
= Elementy pracy #written-by[Jan Kowalski]

Kolejne rozdziały rozpoczynają się od krótkiego wprowadzenia, po czym szczegółowo charakteryzuje się poszczególne problemy, ich rozwiązanie i~obliczenia. Ten rozdział pokazuje, jak w~szablonie umieszcza się rysunki, tabele, wzory, kod źródłowy i~odwołania do literatury.

== Rysunki <rysunki>

Nazwę rysunku umieszcza się bezpośrednio pod nim. Rysunki numerowane są w~ramach rozdziału, a~każdy z~nich musi być przywołany w~tekście, np. „schemat przetwarzania przedstawiono na rys. @schemat”. W~polskiej pracy odwołanie `@etykieta` wstawia sam numer, aby można było odmienić poprzedzający go wyraz (na rysunku, w~tabeli, we wzorze).

#figure(
  image("../figures/schemat.svg", width: 80%),
  caption: [Schemat przetwarzania danych],
) <schemat>

Kilka obrazów w~jednym rysunku można ułożyć siatką (rys. @siatka).

#figure(
  grid(
    columns: 2,
    gutter: 1em,
    image("../figures/schemat.svg"), image("../figures/schemat.svg"),
  ),
  caption: [Dwa obrazy w~jednym rysunku],
) <siatka>

== Tabele

Dane w~tabeli zapisuje się czcionką 9 pkt, wyrównując tekst do lewych krawędzi komórek. Jeśli tabela dzieli się między strony, nagłówek (`table.header`) powtarza się na każdej z~nich – w~tym celu należy zezwolić na łamanie, jak w~tabeli @dluga.

#[
  #show figure: set block(breakable: true)
  #figure(
    table(
      columns: (auto, 1fr, auto),
      table.header[Lp.][Nazwa][Wartość],
      ..range(1, 6).map(i => ([#i], [Pozycja nr #i], [#(i * 10) ms])).flatten(),
    ),
    caption: [Tabela, która może zostać podzielona między strony],
  ) <dluga>
]

Pierwszy akapit pod tabelą rozpoczyna się odstępem górnym wynoszącym 12 pkt – szablon dodaje go automatycznie.

== Wzory

Wzory numerowane są w~ramach rozdziału, a~numer umieszcza się w~nawiasach przy prawym marginesie (wzór @energia).

$ E = m c^2 $ <energia>

gdzie:
/ $E$: energia [J],
/ $m$: masa [kg],
/ $c$: prędkość światła w~próżni [m/s].

== Kod źródłowy

Krótkie fragmenty kodu, jak `fetch()`, zapisuje się w~tekście czcionką o~stałej szerokości. Dłuższe listingi można opatrzyć nazwą (listing @przyklad-kodu) lub umieścić bez niej.

#figure(
  ```typescript
  async function getUser(id: number): Promise<User> {
    const response = await fetch(`/api/users/${id}`);
    return response.json();
  }
  ```,
  caption: [Pobieranie danych użytkownika],
) <przyklad-kodu>

== Literatura i~przypisy

Wykaz literatury zawiera tylko te pozycje, z~których korzystano w~trakcie pisania pracy, numerowane w~kolejności cytowania zgodnie z~normą PN-ISO 690 @kowalski2002 @barzykowski2004. Cytowania można grupować @nowak2002 @ncbi i~uzupełniać o~numer strony @barzykowski2004[s. 12]. Treści wygenerowane z~użyciem narzędzi GenAI również należy umieścić w~wykazie literatury @genai.

Terminy obcojęzyczne opatruje się tłumaczeniem przy pierwszym użyciu, np. inżynieria dokumentu #ang[document engineering]#footnote[Przypisy umieszcza się u~dołu strony.].
