= Wstęp i cel pracy <wstep>

Rozdział 1. nakreśla problematykę opisaną lub rozwiązywaną w~pracy dyplomowej wraz z~uzasadnieniem celowości jej realizacji. Podaje cel i~ewentualnie tezę (hipotezę). Syntetycznie opisuje dotychczasowe dokonania w~danej tematyce, założenia techniczne oraz może zwięźle przedstawić zawartość poszczególnych rozdziałów.

Szablon realizuje wymagania edytorskie Politechniki Gdańskiej automatycznie. Ogólne wymagania dotyczące formatowania pracy dyplomowej wymienione zostały poniżej:

- format arkusza: A4,
- orientacja papieru: pionowa,
- czcionka: Arial (zgodna z~Księgą Identyfikacji Wizualnej PG),
- wielkość czcionki podstawowej: 10 pkt,
- odstęp między wierszami (interlinia): 1,5 wiersza,
- marginesy (w odbiciu lustrzanym): górny 2,5 cm, dolny 2,5 cm, wewnętrzny 3,5 cm, zewnętrzny 2,5 cm,
- tekst pracy wyrównany do obydwu marginesów (wyjustowany),
- każdy akapit rozpoczyna się wcięciem 1,25 cm.

Praca przygotowywana jest do druku dwustronnego. Numeracja stron jest umieszczona w~stopce dokumentu i~wyśrodkowana. Na stronie tytułowej i~na stronie 2 (oświadczenie lub odwrocie strony tytułowej) numer strony nie jest widoczny. Od strony zawierającej Streszczenie (strona nr 3) aż do ostatniej strony pracy numeracja jest ciągła i~zapisana cyframi arabskimi czcionką Arial 9 pkt.

Każdy element listy rozpoczyna się punktorem, a~następujący za nim tekst małą literą. Wiersze wyliczania należy zakończyć przecinkiem albo średnikiem, a~w~przypadku ostatniego elementu wyliczania – kropką.

Krój czcionek stosowanych w~nagłówkach przedstawiono w~tabeli @naglowki.

#figure(
  table(
    columns: (1fr, 1.2fr, 1.4fr),
    table.header[Poziom nagłówka][Przykład][Wielkość i~styl czcionki],
    [Nagłówek 1. stopnia], [*1. TYTUŁ ROZDZIAŁU*], [12 pkt, WERSALIKI, pogrubiona],
    [Nagłówek 2. stopnia], [*_1.1. Podtytuł rozdziału_*], [10 pkt, pogrubiona i~kursywa],
    [Nagłówek 3. stopnia], [_1.1.1. Punkt podrozdziału_], [10 pkt, kursywa],
  ),
  caption: [Wielkość czcionki stosowanej w~nagłówkach],
) <naglowki>

Nazwa tabeli jest umieszczona bezpośrednio nad nią, czcionką o~wielkości 9 pkt, bez kropki na końcu. Numeracja tabel jest ciągła w~ramach rozdziału. Numer porządkowy tabeli poprzedzony jest słowem Tabela oraz numerem rozdziału i~kropką (np. Tabela 1.1. Wielkość …). Każda tabela musi być przywołana w~tekście pracy, na przykład jak w~zdaniu: „W tabeli @naglowki zamieszczono …”.

Na końcach wierszy nie pozostawia się jednoliterowych spójników i~przyimków (a, i, o, u, w, z). Szablon automatycznie wiąże je z~następnym wyrazem twardą spacją; w~innych miejscach można użyć znaku `~`.

== Zawartość pracy

Pracę rozpoczyna strona tytułowa pobrana z~portalu Moja PG, po której następują Streszczenie, Abstract, Spis treści oraz Wykaz ważniejszych oznaczeń i~skrótów. Następnie umieszcza się rozdziały pracy, z~których ostatni nosi tytuł Podsumowanie, Wykaz literatury, wykazy rysunków i~tabel oraz dodatki. Szablon składa te elementy we właściwej kolejności – wystarczy uzupełnić parametry w~pliku `main.typ`.
